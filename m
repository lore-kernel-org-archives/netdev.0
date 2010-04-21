From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 22 Apr 2010 01:05:49 +0200
Message-ID: <1271891149.7895.3751.camel@edumazet-laptop>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>, jamal <hadi@cyberus.ca>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:45617 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752431Ab0DUXGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 19:06:01 -0400
Received: by bwz1 with SMTP id 1so10800686bwz.2
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 16:05:59 -0700 (PDT)
In-Reply-To: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 17:52 +0800, Changli Gao a =C3=A9crit =
:
> batch skb dequeueing from softnet input_pkt_queue
>=20
> batch skb dequeueing from softnet input_pkt_queue to reduce potential=
 lock
> contention and irq disabling/enabling.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----

lock contention _is_ a problem, Jamal tests can show it.

irq disabling/enabling is not, and force to use stop_machine() killer.

I suggest something very simple, like a small buffer (16 slots), so tha=
t
process_backlog() can batch 16 buffers at once.

=46ollowing patch not tested, but its late here and I need to sleep ;)

This is a RFC, not for inclusion, and based on current net-next-2.6 tre=
e

[RFC] net: introduce a batch mode in process_backlog()

We see a lock contention on input_pkt_queue.lock in RPS benches.

As suggested by Changli Gao, we can batch several skbs at once in
process_backlog(), so that we dirty input_pkt_queue less often.

I chose to batch at most 16 skbs per round, and place them in
softnet_data zone where flush_backlog() can find them and eventually
free this skbs at device dismantle.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    2 +
 net/core/dev.c            |   48 +++++++++++++++++++++++++++---------
 2 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3c5ed5f..16da8db 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1383,11 +1383,13 @@ static inline int unregister_gifconf(unsigned i=
nt family)
 /*
  * Incoming packets are placed on per-cpu queues
  */
+#define SD_BATCH_SZ 16
 struct softnet_data {
 	struct Qdisc		*output_queue;
 	struct list_head	poll_list;
 	struct sk_buff		*completion_queue;
=20
+	struct sk_buff		*batch[SD_BATCH_SZ]; /* process_backlog() & flush_bac=
klog() */
 #ifdef CONFIG_RPS
 	struct softnet_data	*rps_ipi_list;
=20
diff --git a/net/core/dev.c b/net/core/dev.c
index e904c47..2673ce0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2932,6 +2932,7 @@ static void flush_backlog(void *arg)
 	struct net_device *dev =3D arg;
 	struct softnet_data *sd =3D &__get_cpu_var(softnet_data);
 	struct sk_buff *skb, *tmp;
+	int i;
=20
 	rps_lock(sd);
 	skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp)
@@ -2941,6 +2942,13 @@ static void flush_backlog(void *arg)
 			input_queue_head_incr(sd);
 		}
 	rps_unlock(sd);
+	for (i =3D 0; i < ARRAY_SIZE(sd->batch); i++) {
+		skb =3D sd->batch[i];
+		if (skb && skb->dev =3D=3D dev) {
+			kfree_skb(skb);
+			sd->batch[i] =3D NULL;
+		}
+	}
 }
=20
 static int napi_gro_complete(struct sk_buff *skb)
@@ -3245,29 +3253,47 @@ EXPORT_SYMBOL(napi_gro_frags);
=20
 static int process_backlog(struct napi_struct *napi, int quota)
 {
-	int work =3D 0;
+	int i, n, lim, work =3D 0;
 	struct softnet_data *sd =3D &__get_cpu_var(softnet_data);
+	struct sk_buff *skb;
=20
 	napi->weight =3D weight_p;
+	local_irq_disable();
+
 	do {
-		struct sk_buff *skb;
+		lim =3D quota - work;
+		if (lim > ARRAY_SIZE(sd->batch))
+			lim =3D ARRAY_SIZE(sd->batch);
+		/* batch at most 16 buffers */
=20
-		local_irq_disable();
 		rps_lock(sd);
-		skb =3D __skb_dequeue(&sd->input_pkt_queue);
-		if (!skb) {
+		for (n =3D 0; n < lim; n++) {
+			sd->batch[n] =3D __skb_dequeue(&sd->input_pkt_queue);
+			if (!sd->batch[n])
+				break;
+		}
+		if (!sd->input_pkt_queue.qlen) {
 			__napi_complete(napi);
-			rps_unlock(sd);
-			local_irq_enable();
-			break;
+			quota =3D 0;
 		}
-		input_queue_head_incr(sd);
 		rps_unlock(sd);
-		local_irq_enable();
=20
-		__netif_receive_skb(skb);
-	} while (++work < quota);
+		/* Now process our batch */
+		for (i =3D 0; i < n; i++) {
+			skb =3D sd->batch[i];
+			/* flush_backlog() might have stolen this skb */
+			input_queue_head_incr(sd);
+			if (likely(skb)) {
+				sd->batch[i] =3D NULL;
+				local_irq_enable();
+				__netif_receive_skb(skb);
+				local_irq_disable();
+			}
+		}
+		work +=3D n;
+	} while (work < quota);
=20
+	local_irq_enable();
 	return work;
 }
=20


