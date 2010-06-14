From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] loopback: Implement 64bit stats on 32bit
 arches
Date: Mon, 14 Jun 2010 17:59:22 +0200
Message-ID: <1276531162.2478.121.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44503 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401Ab0FNP71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 11:59:27 -0400
Received: by wyb40 with SMTP id 40so3996307wyb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 08:59:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Uses a seqcount_t to synchronize stat producer and consumer, for packets
and bytes counter, now u64 types.

(dropped counter being rarely used, stay a native "unsigned long" type)

No noticeable performance impact on x86, as it only adds two increments
per frame. It might be more expensive on arches where smp_wmb() is not
free.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/loopback.c |   61 ++++++++++++++++++++++++++++++++-------
 1 file changed, 51 insertions(+), 10 deletions(-)
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 72b7949..09334f8 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -60,11 +60,51 @@
 #include <net/net_namespace.h>
 
 struct pcpu_lstats {
-	unsigned long packets;
-	unsigned long bytes;
+	u64 packets;
+	u64 bytes;
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
+	seqcount_t seq;
+#endif
 	unsigned long drops;
 };
 
+#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
+static void inline lstats_update_begin(struct pcpu_lstats *lstats)
+{
+	write_seqcount_begin(&lstats->seq);
+}
+static void inline lstats_update_end(struct pcpu_lstats *lstats)
+{
+	write_seqcount_end(&lstats->seq);
+}
+static void inline lstats_fetch_and_add(u64 *packets, u64 *bytes, const struct pcpu_lstats *lstats)
+{
+	u64 tpackets, tbytes;
+	unsigned int seq;
+
+	do {
+		seq = read_seqcount_begin(&lstats->seq);
+		tpackets = lstats->packets;
+		tbytes = lstats->bytes;
+	} while (read_seqcount_retry(&lstats->seq, seq));
+
+	*packets += tpackets;
+	*bytes += tbytes;
+}
+#else
+static void inline lstats_update_begin(struct pcpu_lstats *lstats)
+{
+}
+static void inline lstats_update_end(struct pcpu_lstats *lstats)
+{
+}
+static void inline lstats_fetch_and_add(u64 *packets, u64 *bytes, const struct pcpu_lstats *lstats)
+{
+	*packets += lstats->packets;
+	*bytes += lstats->bytes;
+}
+#endif
+
 /*
  * The higher levels take care of making this non-reentrant (it's
  * called with bh's disabled).
@@ -86,21 +126,23 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 
 	len = skb->len;
 	if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
+		lstats_update_begin(lb_stats);
 		lb_stats->bytes += len;
 		lb_stats->packets++;
+		lstats_update_end(lb_stats);
 	} else
 		lb_stats->drops++;
 
 	return NETDEV_TX_OK;
 }
 
-static struct net_device_stats *loopback_get_stats(struct net_device *dev)
+static struct rtnl_link_stats64 *loopback_get_stats64(struct net_device *dev)
 {
 	const struct pcpu_lstats __percpu *pcpu_lstats;
-	struct net_device_stats *stats = &dev->stats;
-	unsigned long bytes = 0;
-	unsigned long packets = 0;
-	unsigned long drops = 0;
+	struct rtnl_link_stats64 *stats = &dev->stats64;
+	u64 bytes = 0;
+	u64 packets = 0;
+	u64 drops = 0;
 	int i;
 
 	pcpu_lstats = (void __percpu __force *)dev->ml_priv;
@@ -108,8 +150,7 @@ static struct net_device_stats *loopback_get_stats(struct net_device *dev)
 		const struct pcpu_lstats *lb_stats;
 
 		lb_stats = per_cpu_ptr(pcpu_lstats, i);
-		bytes   += lb_stats->bytes;
-		packets += lb_stats->packets;
+		lstats_fetch_and_add(&packets, &bytes, lb_stats);
 		drops   += lb_stats->drops;
 	}
 	stats->rx_packets = packets;
@@ -158,7 +199,7 @@ static void loopback_dev_free(struct net_device *dev)
 static const struct net_device_ops loopback_ops = {
 	.ndo_init      = loopback_dev_init,
 	.ndo_start_xmit= loopback_xmit,
-	.ndo_get_stats = loopback_get_stats,
+	.ndo_get_stats64 = loopback_get_stats64,
 };
 
 /*


