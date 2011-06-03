From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to
 physical device (v4)
Date: Fri, 03 Jun 2011 21:48:51 +0200
Message-ID: <1307130531.2600.8.camel@edumazet-laptop>
References: <1307123978.2789.53.camel@bwh-desktop>
	 <1307129073-3769-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43196 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752096Ab1FCTsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 15:48:54 -0400
Received: by wya21 with SMTP id 21so1633145wya.19
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2011 12:48:53 -0700 (PDT)
In-Reply-To: <1307129073-3769-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 03 juin 2011 =C3=A0 15:24 -0400, Neil Horman a =C3=A9crit :
> The bonding driver is multiqueue enabled, in which each queue represe=
nts a slave
> to enable optional steering of output frames to given slaves against =
the default
> output policy.  However, it needs to reset the skb->queue_mapping pri=
or to
> queuing to the physical device or the physical slave (if it is multiq=
ueue) could
> wind up transmitting on an unintended tx queue
>=20
> Change Notes:
> v2) Based on first pass review, updated the patch to restore the orig=
ional queue
> mapping that was found in bond_select_queue, rather than simply reset=
ting to
> zero.  This preserves the value of queue_mapping when it was set on r=
eceive in
> the forwarding case which is desireable.
>=20
> v3) Fixed spelling an casting error in skb->cb
>=20
> v4) fixed to store raw queue_mapping to avoid double decrement
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Jay Vosburgh <fubar@us.ibm.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: "David S. Miller" <davem@davemloft.net>
> ---
>  drivers/net/bonding/bond_main.c |    8 ++++++++
>  1 files changed, 8 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 17b4dd9..76adf27 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -400,6 +400,9 @@ int bond_dev_queue_xmit(struct bonding *bond, str=
uct sk_buff *skb,
>  {
>  	skb->dev =3D slave_dev;
>  	skb->priority =3D 1;
> +
> +	skb->queue_mapping =3D ((u16 *)skb->cb)[0];

Please dont do that. Use a helper.

=46or example :

#define bond_queue_mapping(skb) (*(unsigned int *)((skb)->cb))


	skb->queue_mapping =3D bond_queue_mapping(skb);
=09

> +
>  	if (unlikely(netpoll_tx_running(slave_dev)))
>  		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb)=
;
>  	else
> @@ -4216,6 +4219,11 @@ static u16 bond_select_queue(struct net_device=
 *dev, struct sk_buff *skb)
>  	 */
>  	u16 txq =3D skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
> =20
> +	/*
> + 	 * Save the original txq to restore before passing to the driver
> + 	 */
> +	((u16 *)skb->cb)[0] =3D skb->queue_mapping;
=09
	bond_queue_mapping(skb) =3D skb->queue_mapping;

> +
>  	if (unlikely(txq >=3D dev->real_num_tx_queues)) {
>  		do {
>  			txq -=3D dev->real_num_tx_queues;


