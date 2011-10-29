From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH] net: allow vlan traffic to be received under
 bond
Date: Fri, 28 Oct 2011 19:20:32 -0700
Message-ID: <4EAB62F0.2040101@intel.com>
References: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903179@ESESSCMS0356.eemea.ericsson.se>  <4E972301.4030004@intel.com>  <CAEP_g=9dk_ERdnw4Hw_8RO8Z23E1g2Q9G=AxPkiaVhwbHvo47A@mail.gmail.com>  <20111018.234723.1235424375699917420.davem@davemloft.net>  <1319796053.23112.92.camel@edumazet-laptop> <1319799986.23112.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"hans.schillstrom@ericsson.com" <hans.schillstrom@ericsson.com>,
	"jpirko@redhat.com" <jpirko@redhat.com>,
	"mbizon@freebox.fr" <mbizon@freebox.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63413 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756064Ab1J2CUd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Oct 2011 22:20:33 -0400
In-Reply-To: <1319799986.23112.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2011 4:06 AM, Eric Dumazet wrote:
> Le vendredi 28 octobre 2011 =C3=A0 12:00 +0200, Eric Dumazet a =C3=A9=
crit :
>=20
>> Oh well, this broke my setup, a very basic one.
>>
>> eth1 and eth2 on a bonding device, bond0, active-backup
>>
>> some vlans on top of bond0, say vlan.103
>>
>> $ ip link show dev vlan.103
>> 8: vlan.103@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
>> pfifo_fast state UP qlen 100
>>     link/ether 00:1e:0b:ec:d3:d2 brd ff:ff:ff:ff:ff:ff
>>
>>
>> arp_rcv() now gets packets with skb->type PACKET_OTHERHOST and drops
>> such packets.
>>
>>      [000] 52870.115435: skb_gro_reset_offset <-napi_gro_receive
>>      [000] 52870.115435: dev_gro_receive <-napi_gro_receive
>>      [000] 52870.115435: napi_skb_finish <-napi_gro_receive
>>      [000] 52870.115435: netif_receive_skb <-napi_skb_finish
>>      [000] 52870.115435: get_rps_cpu <-netif_receive_skb
>>      [000] 52870.115435: __netif_receive_skb <-netif_receive_skb
>>      [000] 52870.115436: vlan_do_receive <-__netif_receive_skb
>>      [000] 52870.115436: bond_handle_frame <-__netif_receive_skb
>>      [000] 52870.115436: vlan_do_receive <-__netif_receive_skb
>>      [000] 52870.115436: arp_rcv <-__netif_receive_skb
>>      [000] 52870.115436: kfree_skb <-arp_rcv
>>      [000] 52870.115437: __kfree_skb <-kfree_skb
>>      [000] 52870.115437: skb_release_head_state <-__kfree_skb
>>      [000] 52870.115437: skb_release_data <-__kfree_skb
>>      [000] 52870.115437: kfree <-skb_release_data
>>      [000] 52870.115437: kmem_cache_free <-__kfree_skb
>>
>>
>> By the way, we have no SNMP counter here so I spent some time to tra=
ck
>> this. I'll send a patch for this.
>>
>> If this host initiates the trafic, all is well.
>>
>> Please guys, can we get back ARP or revert this patch ?
>=20
> Following patch cures the problem, I am not sure its the right fix.
>=20
> Problem is we dont know how many times vlan_do_receive() can be calle=
d
> for a packet.
>=20
> Only last call should set/mess pkt_type to PACKET_OTHERHOST.
>=20
> So the caller should be responsible for this, not vlan_do_receive()
>=20
>=20
> Alternative would be to check skb->dev->rx_handler being NULL,
> but its not clean.
>=20
> Following patch is a hack because it handles multicast/broadcast traf=
ic
> only. Unicast is already handled in lines 26-33, this is why we didnt
> catch the problem.
>=20
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index f1f2f7b..6861899 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -13,7 +13,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
> =20
>  	vlan_dev =3D vlan_find_dev(skb->dev, vlan_id);
>  	if (!vlan_dev) {
> -		if (vlan_id)
> +		if (vlan_id && skb->pkt_type =3D=3D PACKET_HOST)
>  			skb->pkt_type =3D PACKET_OTHERHOST;
>  		return false;
>  	}
>=20

Thanks Eric! Thought about this some and I haven't come up
with anything better yet. Even though this might be a slight
hack I would prefer this to reverting the patch.

I'll think about this more tomorrow. Would you be against
submitting this patch?

=2EJohn
