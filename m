From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] net: add skb.old_queue_mapping
Date: Mon, 13 Dec 2010 17:56:52 +0100
Message-ID: <1292259412.2759.57.camel@edumazet-laptop>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
	 <1292251414-5154-5-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f171.google.com ([209.85.215.171]:46323 "EHLO
	mail-ey0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018Ab0LMQ45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 11:56:57 -0500
Received: by eyg5 with SMTP id 5so4319831eyg.2
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 08:56:56 -0800 (PST)
In-Reply-To: <1292251414-5154-5-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 d=C3=A9cembre 2010 =C3=A0 22:43 +0800, Changli Gao a =C3=A9=
crit :
> For the skbs returned from ifb, we should use the queue_mapping
> saved before ifb.
>=20
> We save old queue_mapping in old_queue_mapping just before calling=20
> dev_queue_xmit, and restore the old_queue_mapping to queue_mapping
> just before reinjecting the skb.
>=20
> dev_pick_tx() use the current queue_mapping for the skbs reinjected
> by ifb.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  drivers/net/ifb.c      |    1 +
>  include/linux/skbuff.h |    3 +++
>  net/core/dev.c         |    5 +++++
>  net/sched/act_mirred.c |    1 +
>  4 files changed, 10 insertions(+)
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 16c767b..481e4b1 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -95,6 +95,7 @@ static void ri_tasklet(unsigned long _dev)
>  		u64_stats_update_end(&qp->syncp);
>  		skb->skb_iif =3D dev->ifindex;
> =20
> +		skb->queue_mapping =3D skb->old_queue_mapping;
>  		if (from & AT_EGRESS) {
>  			dev_queue_xmit(skb);
>  		} else if (from & AT_INGRESS) {
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 19f37a6..2ce2a96 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -403,6 +403,9 @@ struct sk_buff {
>  	};
> =20
>  	__u16			vlan_tci;
> +#ifdef CONFIG_NET_CLS_ACT
> +	__u16			old_queue_mapping;
> +#endif
> =20

Are you sure we need this field here ? Why not using cb[] for example ?


>  	sk_buff_data_t		transport_header;
>  	sk_buff_data_t		network_header;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d28b3a0..8e97cfd 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2190,6 +2190,11 @@ static struct netdev_queue *dev_pick_tx(struct=
 net_device *dev,
>  	int queue_index;
>  	const struct net_device_ops *ops =3D dev->netdev_ops;
> =20
> +#ifdef CONFIG_NET_CLS_ACT
> +	if (skb->tc_verd & TC_NCLS)
> +		queue_index =3D skb_get_queue_mapping(skb);
> +	else
> +#endif
>  	if (dev->real_num_tx_queues =3D=3D 1)
>  		queue_index =3D 0;
>  	else if (ops->ndo_select_queue) {
> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index 0c311be..853eb30 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -197,6 +197,7 @@ static int tcf_mirred(struct sk_buff *skb, struct=
 tc_action *a,
> =20
>  	skb2->skb_iif =3D skb->dev->ifindex;
>  	skb2->dev =3D dev;
> +	skb2->old_queue_mapping =3D skb->queue_mapping;
>  	dev_queue_xmit(skb2);
>  	err =3D 0;
> =20


