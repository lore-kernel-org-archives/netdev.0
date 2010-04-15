From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: fix softnet_stat
Date: Thu, 15 Apr 2010 11:01:53 +0800
Message-ID: <1271300513-9995-1-git-send-email-xiaosuo@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:56294 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756519Ab0DODBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 23:01:35 -0400
Received: by pva18 with SMTP id 18so544451pva.19
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 20:01:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix softnet_stat

Per cpu variable softnet_data.total was shared between IRQ and SoftIRQ context
without any protection. And enqueue_to_backlog should update the netdev_rx_stat
of the target CPU.

This patch changes the meaning of softnet_data.total to the number of packets
processed, not includes dropped, in order to avoid it sharing between IRQ and
SoftIRQ. And softnet_data.dropped is protected in the corresponding
input_pkt_queue.lock, if RPS is enabled.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/core/dev.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)
diff --git a/net/core/dev.c b/net/core/dev.c
index a10a216..b38a991 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2336,7 +2336,6 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu)
 	queue = &per_cpu(softnet_data, cpu);
 
 	local_irq_save(flags);
-	__get_cpu_var(netdev_rx_stat).total++;
 
 	rps_lock(queue);
 	if (queue->input_pkt_queue.qlen <= netdev_max_backlog) {
@@ -2366,9 +2365,9 @@ enqueue:
 		goto enqueue;
 	}
 
+	per_cpu(netdev_rx_stat, cpu).dropped++;
 	rps_unlock(queue);
 
-	__get_cpu_var(netdev_rx_stat).dropped++;
 	local_irq_restore(flags);
 
 	kfree_skb(skb);
@@ -3565,7 +3564,7 @@ static int softnet_seq_show(struct seq_file *seq, void *v)
 	struct netif_rx_stats *s = v;
 
 	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
-		   s->total, s->dropped, s->time_squeeze, 0,
+		   s->total + s->dropped, s->dropped, s->time_squeeze, 0,
 		   0, 0, 0, 0, /* was fastroute */
 		   s->cpu_collision, s->received_rps);
 	return 0;
