From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] tun: stop tx queue when limit is hit
Date: Sun, 20 Jul 2014 20:51:25 +0200
Message-ID: <1405882285-3072-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:51799 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751401AbaGTS6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2014 14:58:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently tun just frees the skb and returns NETDEV_TX_OK
when queue length exceeds txqlen.

This causes severe packetloss and unneeded resource
consumption on host when sending to vm connected via tun.

Instead, lets stop the transmit queue and start it once
packets are consumed from the queue.  This allows the network
stack to control applications that send data via tun device.

Before:
time netperf -H 10.1.1.2 -t UDP_STREAM -- -m 1024
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992    1024   10.00     5712540      0    4679.65
212992           10.00      804441            658.99
0.40s user 9.62s system 71% cpu 14.030 total

After:
time netperf -H 10.1.1.2 -t UDP_STREAM -- -m 1024
Socket  Message  Elapsed      Messages
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec
212992    1024   10.00     2060473      0    1687.92
212992           10.00      904187            740.70
0.18s user 5.14s system 37% cpu 14.028 total

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/tun.c | 42 ++++++++++++++++++++++++++++++++++++------
 1 file changed, 36 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index acaaf67..c020215 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -733,6 +733,24 @@ static int tun_net_close(struct net_device *dev)
 	return 0;
 }
 
+static unsigned long tun_queue_len(const struct tun_file *tfile, u32 numqueues)
+{
+	return skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueues;
+}
+
+static bool tun_queue_should_stop(const struct net_device *dev,
+				  const struct tun_file *tfile, u32 numqueues)
+{
+	return tun_queue_len(tfile, numqueues) > dev->tx_queue_len;
+}
+
+static bool tun_queue_should_wake(const struct net_device *dev,
+				  const struct tun_file *tfile, u32 numqueues)
+{
+	return !tun_queue_should_stop(dev, tfile, numqueues);
+}
+
+
 /* Net device start xmit */
 static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -779,12 +797,19 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	    sk_filter(tfile->socket.sk, skb))
 		goto drop;
 
-	/* Limit the number of packets queued by dividing txq length with the
-	 * number of queues.
-	 */
-	if (skb_queue_len(&tfile->socket.sk->sk_receive_queue) * numqueues
-			  >= dev->tx_queue_len)
-		goto drop;
+	if (tun_queue_should_stop(dev, tfile, numqueues)) {
+		if (netif_subqueue_stopped(dev, skb))
+			goto drop;
+
+		netif_stop_subqueue(dev, txq);
+
+		/* concurrent reader must not miss 'stopped queue' */
+		smp_mb__after_atomic();
+
+		/* reader might have drained queue before stop_subqueue */
+		if (tun_queue_should_wake(dev, tfile, numqueues))
+			netif_start_subqueue(dev, txq);
+	}
 
 	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
 		goto drop;
@@ -1346,6 +1371,11 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 				  &peeked, &off, &err);
 	if (skb) {
 		ret = tun_put_user(tun, tfile, skb, iv, len);
+
+		if (netif_subqueue_stopped(tun->dev, skb) &&
+		    tun_queue_should_wake(tun->dev, tfile, tun->numqueues))
+			netif_wake_subqueue(tun->dev, skb->queue_mapping);
+
 		kfree_skb(skb);
 	} else
 		ret = err;
-- 
1.8.1.5
