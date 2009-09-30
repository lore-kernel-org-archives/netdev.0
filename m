From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] bonding: send ARP requests on interfaces other than
 the primary for tlb/alb
Date: Wed, 30 Sep 2009 07:20:23 +0200
Message-ID: <4AC2EA97.5010809@gmail.com>
References: <1254269731-7341-1-git-send-email-fubar@us.ibm.com> <1254269731-7341-2-git-send-email-fubar@us.ibm.com> <1254269731-7341-3-git-send-email-fubar@us.ibm.com> <1254269731-7341-4-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35383 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbZI3FUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 01:20:39 -0400
In-Reply-To: <1254269731-7341-4-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh a =E9crit :
> From: Andy Gospodarek <andy@greyhouse.net>
>=20
> This patch sends ARP request on the correct destination output interf=
ace
> rather than always sending them on the primary interface.  I've also
> added some bits to make sure that the source and destination address =
in
> the ARP header are correct since simply changing the source MAC and
> output interface will not be that helpful.
>=20
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>=20
> ---
>  drivers/net/bonding/bond_alb.c |   45 ++++++++++++++++++------------=
---------
>  1 files changed, 21 insertions(+), 24 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bon=
d_alb.c
> index 5cd0400..9148c75 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -726,35 +726,32 @@ static struct slave *rlb_arp_xmit(struct sk_buf=
f *skb, struct bonding *bond)
>  	struct arp_pkt *arp =3D arp_pkt(skb);
>  	struct slave *tx_slave =3D NULL;
> =20
> -	if (arp->op_code =3D=3D htons(ARPOP_REPLY)) {
> -		/* the arp must be sent on the selected
> -		* rx channel
> -		*/
> -		tx_slave =3D rlb_choose_channel(skb, bond);
> -		if (tx_slave) {
> -			memcpy(arp->mac_src,tx_slave->dev->dev_addr, ETH_ALEN);
> -		}
> -		pr_debug("Server sent ARP Reply packet\n");
> -	} else if (arp->op_code =3D=3D htons(ARPOP_REQUEST)) {
> -		/* Create an entry in the rx_hashtbl for this client as a
> -		 * place holder.
> -		 * When the arp reply is received the entry will be updated
> -		 * with the correct unicast address of the client.
> -		 */
> -		rlb_choose_channel(skb, bond);
> +	/* Choose an output channel for the ARP frame */
> +	tx_slave =3D rlb_choose_channel(skb, bond);
> =20
> -		/* The ARP relpy packets must be delayed so that
> -		 * they can cancel out the influence of the ARP request.
> -		 */

COmments should have the following form :
/*
 * This is a fine comment
 */

> +	/* If a valid interface is returned, make sure the sender and targe=
t MAC
> +	 * addresses are correct based on the interface that will be transm=
itting
> +	 * the frame. */
> +	if (tx_slave) {
> +		/* If sender mac is the bond's address, rewrite */
> +		if (!compare_ether_addr_64bits(arp->mac_src,bond->dev->dev_addr))
> +			memcpy(arp->mac_src,tx_slave->dev->dev_addr,bond->dev->addr_len);

Hmm, you use compare_ether_addr_64bits(), implying a fix ETH_ALEN (6 by=
tes) address, then
you memcpy( ..., ..., bond->dev->addr_len);
Why not use ETH_ALEN to help compiler ?
Also add a space after a comma

> +
> +		/* If target mac is the bond's address, rewrite */
> +		if (!compare_ether_addr_64bits(arp->mac_dst,bond->dev->dev_addr))
> +			memcpy(arp->mac_dst,tx_slave->dev->dev_addr,bond->dev->addr_len);
> +
> +	} else if (arp->op_code =3D=3D htons(ARPOP_REQUEST)) {
> +		/* if tx_slave is NULL, the periodic ARP replies must
> +		 * be delayed so they can cancel out the influence of
> +		 * the ARP request. */
>  		bond->alb_info.rlb_update_delay_counter =3D RLB_UPDATE_DELAY;
> =20
> -		/* arp requests are broadcast and are sent on the primary
> -		 * the arp request will collapse all clients on the subnet to
> +		/* ARP requests are broadcast and are sent on the primary
> +		 * the ARP request will collapse all clients on the subnet to
>  		 * the primary slave. We must register these clients to be

Could you reformulate this comment, it is not readable as is :

 /*
  * ARP requests are broadcast and are sent on the primary.
  * The ARP request will collapse all clients on the subnet to
  * the primary slave. We must register these clients to be
  * updated with their assigned MAC.
  */


> -		 * updated with their assigned mac.
> -		 */
> +		 * updated with their assigned MAC. */
>  		rlb_req_update_subnet_clients(bond, arp->ip_src);
> -		pr_debug("Server sent ARP Request packet\n");
>  	}
> =20
>  	return tx_slave;

