From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] fix potential wild pointer when NIC is dying
Date: Wed, 14 Apr 2010 20:18:23 +0800
Message-ID: <1271247503-2973-1-git-send-email-xiaosuo@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:39013 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777Ab0DNESM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 00:18:12 -0400
Received: by qw-out-2122.google.com with SMTP id 8so2705652qwh.37
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 21:18:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix potential wild pointer when NIC is dying.

flush_backlog() works with the assumption: the NIC doesn't enqueue packets to
linux kernel, so there are two places, which packets are in, softnet queue or
being processed in net-rx softirq. flush_backlog() is used to drop the first
kind of packets, and for the later, a grace period is used to wait the
finishing of the packets processing.

It always works without RPS. If RPS is used, although the NIC doesn't enqueue
packets to linux kernel, RPS may do. There may be condition, a grace period has
passed due to softirq running time limit, there are still packets, which refer
to the died NIC, and are enqueued by RPS after flush_backlog() returns.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/core/dev.c |   24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index a10a216..fe4a821 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -131,6 +131,7 @@
 #include <linux/random.h>
 #include <trace/events/napi.h>
 #include <linux/pci.h>
+#include <linux/stop_machine.h>
 
 #include "net-sysfs.h"
 
@@ -2791,19 +2792,24 @@ int netif_receive_skb(struct sk_buff *skb)
 EXPORT_SYMBOL(netif_receive_skb);
 
 /* Network device is going away, flush any packets still pending  */
-static void flush_backlog(void *arg)
+static int flush_backlog(void *arg)
 {
 	struct net_device *dev = arg;
-	struct softnet_data *queue = &__get_cpu_var(softnet_data);
 	struct sk_buff *skb, *tmp;
+	struct softnet_data *queue;
+	int cpu;
 
-	rps_lock(queue);
-	skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp)
-		if (skb->dev == dev) {
-			__skb_unlink(skb, &queue->input_pkt_queue);
-			kfree_skb(skb);
+	for_each_online_cpu(cpu) {
+		queue = &per_cpu(softnet_data, cpu);
+		skb_queue_walk_safe(&queue->input_pkt_queue, skb, tmp) {
+			if (skb->dev == dev) {
+				__skb_unlink(skb, &queue->input_pkt_queue);
+				kfree_skb(skb);
+			}
 		}
-	rps_unlock(queue);
+	}
+
+	return 0;
 }
 
 static int napi_gro_complete(struct sk_buff *skb)
@@ -5027,7 +5033,7 @@ void netdev_run_todo(void)
 
 		dev->reg_state = NETREG_UNREGISTERED;
 
-		on_each_cpu(flush_backlog, dev, 1);
+		stop_machine(flush_backlog, dev, NULL);
 
 		netdev_wait_allrefs(dev);
 
