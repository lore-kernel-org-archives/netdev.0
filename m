From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] caif: Add support for flow-control on device's
 tx-queue
Date: Fri, 02 Dec 2011 15:38:02 +0100
Message-ID: <1322836682.2762.8.camel@edumazet-laptop>
References: <1322834777-2486-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1322834777-2486-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Sjur =?ISO-8859-1?Q?Br=E6ndeland?=
	<sjur.brandeland@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:46386 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756751Ab1LBOiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 09:38:05 -0500
Received: by vcbfk14 with SMTP id fk14so2361505vcb.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 06:38:05 -0800 (PST)
In-Reply-To: <1322834777-2486-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 15:06 +0100, Sjur Br=C3=A6ndel=
and a =C3=A9crit :
> Flow control is implemented by inspecting the qdisc queue length
> in order to detect potential overflow on the TX queue. When a thresho=
ld
> is reached flow-off is sent upwards in the CAIF stack. At the same ti=
me
> the skb->destructor is hi-jacked in order to detect when the last pac=
ket
> put on queue is consumed. When this "hi-jacked" packet is consumed, f=
low-on
> is sent upwards in the CAIF stack.
>=20
> Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
> ---
>  net/caif/caif_dev.c |   48 +++++++++++++++++++++++++++++++++++++++++=
+++++++
>  1 files changed, 48 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/caif/caif_dev.c b/net/caif/caif_dev.c
> index f7e8c70..415353e 100644
> --- a/net/caif/caif_dev.c
> +++ b/net/caif/caif_dev.c
> @@ -34,6 +34,7 @@ struct caif_device_entry {
>  	struct list_head list;
>  	struct net_device *netdev;
>  	int __percpu *pcpu_refcnt;
> +	bool xoff;
>  };
> =20
>  struct caif_device_entry_list {
> @@ -48,6 +49,7 @@ struct caif_net {
>  };
> =20
>  static int caif_net_id;
> +static int q_high =3D 50; /* Percent */
> =20
>  struct cfcnfg *get_cfcnfg(struct net *net)
>  {
> @@ -126,9 +128,28 @@ static struct caif_device_entry *caif_get(struct=
 net_device *dev)
>  	return NULL;
>  }
> =20
> +void caif_flow_cb(struct sk_buff *skb)
> +{
> +	struct caif_device_entry *caifd;
> +	WARN_ON(skb->dev =3D=3D NULL);
> +
> +	rcu_read_lock();
> +	caifd =3D caif_get(skb->dev);
> +	caifd->xoff =3D 0;
> +	caifd_hold(caifd);
> +	rcu_read_unlock();
> +
> +	caifd->layer.up->
> +		ctrlcmd(caifd->layer.up,
> +			_CAIF_CTRLCMD_PHYIF_FLOW_ON_IND,
> +			caifd->layer.id);
> +	caifd_put(caifd);
> +}
> +
>  static int transmit(struct cflayer *layer, struct cfpkt *pkt)
>  {
>  	int err;
> +	struct caif_dev_common *caifdev;
>  	struct caif_device_entry *caifd =3D
>  	    container_of(layer, struct caif_device_entry, layer);
>  	struct sk_buff *skb;
> @@ -137,6 +158,33 @@ static int transmit(struct cflayer *layer, struc=
t cfpkt *pkt)
>  	skb->dev =3D caifd->netdev;
>  	skb_reset_network_header(skb);
>  	skb->protocol =3D htons(ETH_P_CAIF);
> +	caifdev =3D netdev_priv(caifd->netdev);
> +
> +	if (caifdev->flowctrl =3D=3D NULL && caifd->netdev->tx_queue_len > =
0 &&
> +			!caifd->xoff) {
> +		struct netdev_queue *txq;
> +		int high;
> +
> +		txq =3D netdev_get_tx_queue(skb->dev, 0);

Why queue 0 and not another one ?

> +		high =3D (caifd->netdev->tx_queue_len * q_high) / 100;
> +
> +		/* If we run with a TX queue, check if the queue is too long*/

Are you sure only this cpu can run here ? any lock is held ?

> +		if (netif_queue_stopped(caifd->netdev) ||
> +			qdisc_qlen(txq->qdisc) > high) {
> +
> +			pr_debug("queue stop(%d) or full (%d>%d) - XOFF\n",
> +					netif_queue_stopped(caifd->netdev),
> +					qdisc_qlen(txq->qdisc), high);
> +			caifd->xoff =3D 1;
> +			/* Hijack this skb free callback function. */
> +			skb_orphan(skb);
> +			skb->destructor =3D caif_flow_cb;
> +			caifd->layer.up->
> +				ctrlcmd(caifd->layer.up,
> +					_CAIF_CTRLCMD_PHYIF_FLOW_OFF_IND,
> +					caifd->layer.id);
> +		}
> +	}
> =20
>  	err =3D dev_queue_xmit(skb);
>  	if (err > 0)

What prevents dev_queue_xmit() to early orphan skb ?
