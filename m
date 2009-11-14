From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] check the return value of ndo_select_queue()
Date: Sat, 14 Nov 2009 08:54:04 +0100
Message-ID: <4AFE621C.1020004@gmail.com>
References: <412e6f7f0911131650j6d13f95bt20aa607f9f44c3af@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44276 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693AbZKNHyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 02:54:03 -0500
In-Reply-To: <412e6f7f0911131650j6d13f95bt20aa607f9f44c3af@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =E9crit :
> check the return value of ndo_select_queue()
>=20
> Check the return value of ndo_select_queue(). If the value isn't smal=
ler
> than the real_num_tx_queues, print a warning message, and reset it to=
 zero.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  net/core/dev.c |   33 ++++++++++++++++++++++++---------
>  1 file changed, 24 insertions(+), 9 deletions(-)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index bf629ac..74a3824 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1849,22 +1849,37 @@ static struct netdev_queue *dev_pick_tx(struc=
t
> net_device *dev,
>  {
>  	u16 queue_index;
>  	struct sock *sk =3D skb->sk;
> +	unsigned int real_num_tx_queues =3D dev->real_num_tx_queues;
>=20
>  	if (sk_tx_queue_recorded(sk)) {
>  		queue_index =3D sk_tx_queue_get(sk);
> +		if (unlikely(queue_index >=3D real_num_tx_queues)) {
> +			do {
> +				queue_index -=3D real_num_tx_queues;
> +			} while (queue_index >=3D real_num_tx_queues);
> +			sk_tx_queue_set(sk, queue_index);
> +		}
>  	} else {
> -		const struct net_device_ops *ops =3D dev->netdev_ops;
> +		u16 (*select_queue)(struct net_device *, struct sk_buff *);
>=20
> -		if (ops->ndo_select_queue) {
> -			queue_index =3D ops->ndo_select_queue(dev, skb);
> -		} else {
> +		if (real_num_tx_queues =3D=3D 1) {
>  			queue_index =3D 0;
> -			if (dev->real_num_tx_queues > 1)
> -				queue_index =3D skb_tx_hash(dev, skb);
> -
> -			if (sk && sk->sk_dst_cache)
> -				sk_tx_queue_set(sk, queue_index);
> +		} else if((select_queue =3D dev->netdev_ops->ndo_select_queue)) {
> +			queue_index =3D select_queue(dev, skb);
> +			if (unlikely(queue_index >=3D real_num_tx_queues)) {
> +				if (net_ratelimit())
> +					WARN(1, "%s selects TX queue %d, but "
> +					     "real number of TX queues is %d\n",
> +					     dev->name, queue_index,
> +					     real_num_tx_queues);
> +				queue_index =3D 0;
> +			}
> +		} else {
> +			queue_index =3D skb_tx_hash(dev, skb);
>  		}
> +
> +		if (sk && sk->sk_dst_cache)
> +			sk_tx_queue_set(sk, queue_index);
>  	}
>=20
>  	skb_set_queue_mapping(skb, queue_index);


Please always use scripts/checkpatch.pl before sending patches

} else if((select_queue =3D dev->netdev_ops->ndo_select_queue)) {

A space is required after the "if"

It seems to me this patch is not matching its ChangeLog :

You moved the :

if (sk && sk->sk_dst_cache)
	sk_tx_queue_set(sk, queue_index);

Why not using much readable patch like :


[PATCH] check the return value of ndo_select_queue()

check the return value of ndo_select_queue()

Check the return value of ndo_select_queue(). If the value isn't smalle=
r
than the real_num_tx_queues, print a warning message, and reset it to z=
ero.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
----

diff --git a/net/core/dev.c b/net/core/dev.c
index ad8e320..bbc9a41 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1845,6 +1845,20 @@ u16 skb_tx_hash(const struct net_device *dev, co=
nst struct sk_buff *skb)
 }
 EXPORT_SYMBOL(skb_tx_hash);
=20
+static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_in=
dex)
+{
+	if (unlikely(queue_index >=3D dev->real_num_tx_queues)) {
+		if (net_ratelimit()) {
+			WARN(1, "%s selects TX queue %d, but "
+			     "real number of TX queues is %d\n",
+			     dev->name, queue_index,
+			     dev->real_num_tx_queues);
+		}
+		return 0;
+	}
+	return queue_index;
+}
+
 static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
@@ -1858,6 +1872,7 @@ static struct netdev_queue *dev_pick_tx(struct ne=
t_device *dev,
=20
 		if (ops->ndo_select_queue) {
 			queue_index =3D ops->ndo_select_queue(dev, skb);
+			queue_index =3D dev_cap_txqueue(dev, queue_index);
 		} else {
 			queue_index =3D 0;
 			if (dev->real_num_tx_queues > 1)


