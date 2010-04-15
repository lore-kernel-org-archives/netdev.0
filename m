From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v2] net: fix softnet_stat
Date: Thu, 15 Apr 2010 13:30:53 +0800
Message-ID: <1271309453-14987-1-git-send-email-xiaosuo@gmail.com>
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:49476 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754698Ab0DOFaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 01:30:30 -0400
Received: by pzk42 with SMTP id 42so813019pzk.4
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 22:30:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix softnet_stat

Per cpu variable softnet_data.total was shared between IRQ and SoftIRQ context
without any protection. And enqueue_to_backlog should update the netdev_rx_stat
of the target CPU.

This patch splits softnet_data.total into softnet_data.received and
softnet_data.dropped internally, in order to avoid it sharing between IRQ and
SoftIRQ. The old ABI softnet_data.total is kept by summing softnet_data.received
and softnet_data.dropped when exporting it to userland. And softnet_data.dropped
is protected in the corresponding input_pkt_queue.lock, if RPS is enabled.

This patch also fixed a bug: packets received by enqueue_to_backlog() were
counted twice: one in enqueue_to_backlog(), and the other in
__netif_receive_skb(), although they maybe not on the same CPUs, if RPS is
involved.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |    7 +++----
 2 files changed, 4 insertions(+), 5 deletions(-)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d1a21b5..394e850 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -219,7 +219,7 @@ struct neigh_parms;
 struct sk_buff;
 
 struct netif_rx_stats {
-	unsigned total;
+	unsigned received;
 	unsigned dropped;
 	unsigned time_squeeze;
 	unsigned cpu_collision;
diff --git a/net/core/dev.c b/net/core/dev.c
index a10a216..5817f0e 100644
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
@@ -2679,7 +2678,7 @@ static int __netif_receive_skb(struct sk_buff *skb)
 			skb->dev = master;
 	}
 
-	__get_cpu_var(netdev_rx_stat).total++;
+	__get_cpu_var(netdev_rx_stat).received++;
 
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
@@ -3565,7 +3564,7 @@ static int softnet_seq_show(struct seq_file *seq, void *v)
 	struct netif_rx_stats *s = v;
 
 	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
-		   s->total, s->dropped, s->time_squeeze, 0,
+		   s->received + s->dropped, s->dropped, s->time_squeeze, 0,
 		   0, 0, 0, 0, /* was fastroute */
 		   s->cpu_collision, s->received_rps);
 	return 0;
