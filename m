From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bonding: allow bond in mode balance-alb to work
 properly in bridge -try4.3
Date: Thu, 28 May 2009 13:41:59 +0200
Message-ID: <4A1E7887.4000102@gmail.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090326155205.GA28868@psychotron.englab.brq.redhat.com> <20090526151717.GB11147@psychotron.englab.brq.redhat.com> <20090527135351.GD1652@psychotron.englab.brq.redhat.com> <20090528110459.GE22391@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, andy@greyhouse.net,
	oleg@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54865 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762459AbZE1LtH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 07:49:07 -0400
In-Reply-To: <20090528110459.GE22391@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko a =E9crit :
> [PATCH net-next] bonding: allow bond in mode balance-alb to work prop=
erly in bridge -try4.3
>=20
> (updated)
> changes v4.2 -> v4.3
> - memcpy the address always, not just in case it differs from master-=
>dev_addr
> - compare_ether_addr_64bits() is not used so there is no direct need =
to make new
>   header file (I think it would be good to have bond stuff in separat=
e file
>   anyway).

Yes, this could be done in a future cleanup patch.
I find this (short) version easier to review for a new feature.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

>=20
> changes v4.1 -> v4.2
> - use skb->pkt_type =3D=3D PACKET_HOST compare rather then comparing =
skb dest addr
>   against skb->dev->dev_addr
>=20
> Hi all.
>=20
> The problem is described in following bugzilla:
> https://bugzilla.redhat.com/show_bug.cgi?id=3D487763
>=20
> Basically here's what's going on. In every mode, bonding interface us=
es the same
> mac address for all enslaved devices (except fail_over_mac). Only bal=
ance-alb
> will simultaneously use multiple MAC addresses across different slave=
s. When you
> put this kind of bond device into a bridge it will only add one of ma=
c adresses
> into a hash list of mac addresses, say X. This mac address is marked =
as local.
> But this bonding interface also has mac address Y. Now then packet ar=
rives with
> destination address Y, this address is not marked as local and the pa=
cked looks
> like it needs to be forwarded. This packet is then lost which is wron=
g.
>=20
> Notice that interfaces can be added and removed from bond while it is=
 in bridge.
>=20
> ***
> When the multiple addresses for bridge port approach failed to solve =
this issue
> due to STP I started to think other way to solve this. I returned to =
previous
> solution but tweaked one.
>=20
> This patch solves the situation in the bonding without touching bridg=
e code.
> For every incoming frame to bonding the destination address is compar=
ed to
> current address of the slave device from which tha packet came. If th=
ese two
> match destination address is replaced by mac address of the master. T=
his address
> is known by bridge so it is delivered properly. Note that the compars=
ion is not
> made directly, it's used skb->pkt_type =3D=3D PACKET_HOST instead. Th=
is is "set"
> previously in eth_type_trans().
>=20
> I experimentally tried that this works as good as searching through t=
he slave
> list (v4 of this patch).
>=20
> Jirka
>=20
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 371ece5..9b4db94 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1920,6 +1920,16 @@ static inline void netif_set_gso_max_size(stru=
ct net_device *dev,
>  	dev->gso_max_size =3D size;
>  }
> =20
> +static inline void skb_bond_set_mac_by_master(struct sk_buff *skb,
> +					      struct net_device *master)
> +{
> +	if (skb->pkt_type =3D=3D PACKET_HOST) {
> +		u16 *dest =3D (u16 *) eth_hdr(skb)->h_dest;
> +
> +		memcpy(dest, master->dev_addr, ETH_ALEN);
> +	}
> +}
> +
>  /* On bonding slaves other than the currently active slave, suppress
>   * duplicates except for 802.3ad ETH_P_SLOW, alb non-mcast/bcast, an=
d
>   * ARP on active-backup slaves with arp_validate enabled.
> @@ -1933,6 +1943,14 @@ static inline int skb_bond_should_drop(struct =
sk_buff *skb)
>  		if (master->priv_flags & IFF_MASTER_ARPMON)
>  			dev->last_rx =3D jiffies;
> =20
> +		if ((master->priv_flags & IFF_MASTER_ALB) && master->br_port) {
> +			/* Do address unmangle. The local destination address
> +			 * will be always the one master has. Provides the right
> +			 * functionality in a bridge.
> +			 */
> +			skb_bond_set_mac_by_master(skb, master);
> +		}
> +
>  		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
>  			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
>  			    skb->protocol =3D=3D __cpu_to_be16(ETH_P_ARP))


