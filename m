From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: init ingress queue
Date: Sat, 04 Dec 2010 09:47:07 +0100
Message-ID: <1291452427.2806.90.camel@edumazet-laptop>
References: <1291441558-3196-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43424 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751372Ab0LDIrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 03:47:12 -0500
Received: by wyb28 with SMTP id 28so10296526wyb.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 00:47:11 -0800 (PST)
In-Reply-To: <1291441558-3196-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 d=C3=A9cembre 2010 =C3=A0 13:45 +0800, Changli Gao a =C3=A9=
crit :
> The dev field of ingress queue is forgot to initialized, then NULL
> pointer dereference happens in qdisc_alloc().

< deleted oops >

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  net/core/dev.c |    2 ++
>  1 file changed, 2 insertions(+)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index cd24374..8083c68 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5577,6 +5577,8 @@ struct netdev_queue *dev_ingress_queue_create(s=
truct net_device *dev)
>  	queue =3D kzalloc(sizeof(*queue), GFP_KERNEL);
>  	if (!queue)
>  		return NULL;
> +	netdev_queue_numa_node_write(queue, -1);
> +	queue->dev =3D dev;
>  	netdev_init_one_queue(dev, queue, NULL);
>  	queue->qdisc =3D &noop_qdisc;
>  	queue->qdisc_sleeping =3D &noop_qdisc;

Hi Changli, thanks for bug report and patch.

IMHO there is no point to include this long Oops report in Changelog fo=
r
a net-next-2.6 temporary problem, there wont be any bugzilla report.=20

Instead, you could say it is a followup patch for commits 1d24eb4815d1e=
0
and f2cd2d3e9b3ef960. Two or three lines with relevant information.

I suggest you submit following patch instead, as this seems cleaner to
me ?

(factorize the two inits in netdev_init_one_queue())


diff --git a/net/core/dev.c b/net/core/dev.c
index cd24374..36e10b4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5113,7 +5113,6 @@ static int netif_alloc_netdev_queues(struct net_d=
evice *dev)
 {
 	unsigned int count =3D dev->num_tx_queues;
 	struct netdev_queue *tx;
-	int i;
=20
 	BUG_ON(count < 1);
=20
@@ -5125,10 +5124,6 @@ static int netif_alloc_netdev_queues(struct net_=
device *dev)
 	}
 	dev->_tx =3D tx;
=20
-	for (i =3D 0; i < count; i++) {
-		netdev_queue_numa_node_write(&tx[i], -1);
-		tx[i].dev =3D dev;
-	}
 	return 0;
 }
=20
@@ -5140,6 +5135,8 @@ static void netdev_init_one_queue(struct net_devi=
ce *dev,
 	spin_lock_init(&queue->_xmit_lock);
 	netdev_set_xmit_lockdep_class(&queue->_xmit_lock, dev->type);
 	queue->xmit_lock_owner =3D -1;
+	netdev_queue_numa_node_write(queue, -1);
+	queue->dev =3D dev;
 }
=20
 static void netdev_init_queues(struct net_device *dev)


