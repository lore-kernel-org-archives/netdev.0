From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] loopback: use u64_stats_sync infrastructure
Date: Wed, 23 Jun 2010 00:44:11 +0200
Message-ID: <1277246651.2591.249.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53682 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054Ab0FVWoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 18:44:15 -0400
Received: by wyi11 with SMTP id 11so300828wyi.19
        for <netdev@vger.kernel.org>; Tue, 22 Jun 2010 15:44:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 6b10de38f0ef (loopback: Implement 64bit stats on 32bit arches)
introduced 64bit stats in loopback driver, using a private seqcount and
private helpers.

David suggested to introduce a generic infrastructure, added in (net:
Introduce u64_stats_sync infrastructure)

This patch reimplements loopback 64bit stats using the u64_stats_sync
infrastructure.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/loopback.c |   62 ++++++++++-----------------------------
 1 file changed, 16 insertions(+), 46 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 09334f8..4dd0510 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -58,53 +58,15 @@
 #include <linux/tcp.h>
 #include <linux/percpu.h>
 #include <net/net_namespace.h>
+#include <linux/u64_stats_sync.h>
 
 struct pcpu_lstats {
-	u64 packets;
-	u64 bytes;
-#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
-	seqcount_t seq;
-#endif
-	unsigned long drops;
+	u64			packets;
+	u64			bytes;
+	struct u64_stats_sync	syncp;
+	unsigned long		drops;
 };
 
-#if BITS_PER_LONG==32 && defined(CONFIG_SMP)
-static void inline lstats_update_begin(struct pcpu_lstats *lstats)
-{
-	write_seqcount_begin(&lstats->seq);
-}
-static void inline lstats_update_end(struct pcpu_lstats *lstats)
-{
-	write_seqcount_end(&lstats->seq);
-}
-static void inline lstats_fetch_and_add(u64 *packets, u64 *bytes, const struct pcpu_lstats *lstats)
-{
-	u64 tpackets, tbytes;
-	unsigned int seq;
-
-	do {
-		seq = read_seqcount_begin(&lstats->seq);
-		tpackets = lstats->packets;
-		tbytes = lstats->bytes;
-	} while (read_seqcount_retry(&lstats->seq, seq));
-
-	*packets += tpackets;
-	*bytes += tbytes;
-}
-#else
-static void inline lstats_update_begin(struct pcpu_lstats *lstats)
-{
-}
-static void inline lstats_update_end(struct pcpu_lstats *lstats)
-{
-}
-static void inline lstats_fetch_and_add(u64 *packets, u64 *bytes, const struct pcpu_lstats *lstats)
-{
-	*packets += lstats->packets;
-	*bytes += lstats->bytes;
-}
-#endif
-
 /*
  * The higher levels take care of making this non-reentrant (it's
  * called with bh's disabled).
@@ -126,10 +88,10 @@ static netdev_tx_t loopback_xmit(struct sk_buff *skb,
 
 	len = skb->len;
 	if (likely(netif_rx(skb) == NET_RX_SUCCESS)) {
-		lstats_update_begin(lb_stats);
+		u64_stats_update_begin(&lb_stats->syncp);
 		lb_stats->bytes += len;
 		lb_stats->packets++;
-		lstats_update_end(lb_stats);
+		u64_stats_update_end(&lb_stats->syncp);
 	} else
 		lb_stats->drops++;
 
@@ -148,10 +110,18 @@ static struct rtnl_link_stats64 *loopback_get_stats64(struct net_device *dev)
 	pcpu_lstats = (void __percpu __force *)dev->ml_priv;
 	for_each_possible_cpu(i) {
 		const struct pcpu_lstats *lb_stats;
+		u64 tbytes, tpackets;
+		unsigned int start;
 
 		lb_stats = per_cpu_ptr(pcpu_lstats, i);
-		lstats_fetch_and_add(&packets, &bytes, lb_stats);
+		do {
+			start = u64_stats_fetch_begin(&lb_stats->syncp);
+			tbytes = lb_stats->bytes;
+			tpackets = lb_stats->packets;
+		} while (u64_stats_fetch_retry(&lb_stats->syncp, start));
 		drops   += lb_stats->drops;
+		bytes   += tbytes;
+		packets += tpackets;
 	}
 	stats->rx_packets = packets;
 	stats->tx_packets = packets;


