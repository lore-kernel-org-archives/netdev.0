From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] ifb: add multiqueue support
Date: Mon, 13 Dec 2010 18:05:31 +0100
Message-ID: <1292259931.2759.66.camel@edumazet-laptop>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
	 <1292251414-5154-4-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55714 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932138Ab0LMRFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 12:05:36 -0500
Received: by wyb28 with SMTP id 28so6104731wyb.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 09:05:35 -0800 (PST)
In-Reply-To: <1292251414-5154-4-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 d=C3=A9cembre 2010 =C3=A0 22:43 +0800, Changli Gao a =C3=A9=
crit :
> Each ifb NIC has nr_cpu_ids rx queues and nr_cpu_ids queues. Packets
> transmitted to ifb are enqueued to the corresponding per cpu tx queue=
s,
> and processed in the corresponding per cpu tasklet latter.
>=20
> The stats are converted to the u64 ones.
>=20
> tq is a stack variable now. It makes ifb_q_private smaller and tx que=
ue
> locked only once in ri_tasklet.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  drivers/net/ifb.c |  211 ++++++++++++++++++++++++++++++++++++-------=
-----------
>  1 file changed, 141 insertions(+), 70 deletions(-)
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index 57c5cfb..16c767b 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -37,56 +37,63 @@
>  #include <net/net_namespace.h>
> =20
>  #define TX_Q_LIMIT    32
> +struct ifb_q_private {
> +	struct tasklet_struct	ifb_tasklet;
> +	struct sk_buff_head	rq;
> +	struct u64_stats_sync	syncp;
> +	u64			rx_packets;
> +	u64			rx_bytes;
> +	u64			rx_dropped;
> +};
> +
>  struct ifb_private {
> -	struct tasklet_struct   ifb_tasklet;
> -	int     tasklet_pending;
> -	struct sk_buff_head     rq;
> -	struct sk_buff_head     tq;
> +	struct ifb_q_private __percpu	*q;
>  };
> =20
>  static int numifbs =3D 2;
> =20
> -static void ri_tasklet(unsigned long dev)
> +static void ri_tasklet(unsigned long _dev)
>  {
> -
> -	struct net_device *_dev =3D (struct net_device *)dev;
> -	struct ifb_private *dp =3D netdev_priv(_dev);
> -	struct net_device_stats *stats =3D &_dev->stats;
> +	struct net_device *dev =3D (struct net_device *)_dev;
> +	struct ifb_private *p =3D netdev_priv(dev);
> +	struct ifb_q_private *qp;
>  	struct netdev_queue *txq;
>  	struct sk_buff *skb;
> -
> -	txq =3D netdev_get_tx_queue(_dev, 0);
> -	skb =3D skb_peek(&dp->tq);
> -	if (skb =3D=3D NULL) {
> -		if (__netif_tx_trylock(txq)) {
> -			skb_queue_splice_tail_init(&dp->rq, &dp->tq);
> -			__netif_tx_unlock(txq);
> -		} else {
> -			/* reschedule */
> -			goto resched;
> -		}
> +	struct sk_buff_head tq;
> +
> +	__skb_queue_head_init(&tq);
> +	txq =3D netdev_get_tx_queue(dev, raw_smp_processor_id());
> +	qp =3D per_cpu_ptr(p->q, raw_smp_processor_id());


Hmm, this wont work with CPU HOTPLUG.

When we put a cpu offline, we can transfert tasklets from this cpu to
another 'online cpu'=20

To solve this, you need that ri_tasklet() not use a "device pointer"
parameter but a pointer to 'cpu' private data, since it can be differen=
t
than the data of the current cpu.

static void ri_tasklet(unsigned long arg)
{
struct ifb_q_private *qp =3D (struct ifb_q_private *)arg;

	...
}



