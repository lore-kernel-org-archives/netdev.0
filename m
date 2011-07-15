From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] [RFC] Batch statistics update in free_old_xmit_skbs
Date: Fri, 15 Jul 2011 14:46:26 +0530
Message-ID: <20110715091626.23018.311.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:34065 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965381Ab1GOJQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2011 05:16:38 -0400
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp06.au.ibm.com (8.14.4/8.13.1) with ESMTP id p6F9Fj1l013731
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 19:15:45 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6F9G3Ec884828
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 19:16:03 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6F9GSAf008845
	for <netdev@vger.kernel.org>; Fri, 15 Jul 2011 19:16:28 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve performance for update of stats counters for 32-bit
guests. The following table shows the average number of skbs
that were processed in free_old_xmit_skbs under various
cases:

-----------------------------------------------------------
#Procs      #packets (512 I/O)      #packets (16K I/O)
-----------------------------------------------------------
1           2.81                    1.23
4           4.52                    18.63
16          4.23                    17.58
32          9.81                    18.07
64          15.86                   17.69
96          21.30                   16.72
-----------------------------------------------------------

Batching u64_stats_update_begin/ends seems to be useful
for 32-bit guests, as free_old_xmit_skbs is called at
every xmit.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 drivers/net/virtio_net.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff -ruNp org/drivers/net/virtio_net.c new/drivers/net/virtio_net.c
--- org/drivers/net/virtio_net.c	2011-07-04 10:38:33.000000000 +0530
+++ new/drivers/net/virtio_net.c	2011-07-15 12:27:41.000000000 +0530
@@ -531,19 +531,27 @@ static unsigned int free_old_xmit_skbs(s
 {
 	struct sk_buff *skb;
 	unsigned int len, tot_sgs = 0;
-	struct virtnet_stats __percpu *stats = this_cpu_ptr(vi->stats);
+	u64 tx_bytes = 0, tx_packets = 0;
 
 	while ((skb = virtqueue_get_buf(vi->svq, &len)) != NULL) {
 		pr_debug("Sent skb %p\n", skb);
 
-		u64_stats_update_begin(&stats->syncp);
-		stats->tx_bytes += skb->len;
-		stats->tx_packets++;
-		u64_stats_update_end(&stats->syncp);
+		tx_bytes += skb->len;
+		tx_packets++;
 
 		tot_sgs += skb_vnet_hdr(skb)->num_sg;
 		dev_kfree_skb_any(skb);
 	}
+
+	if (tx_packets) {
+		struct virtnet_stats __percpu *stats = this_cpu_ptr(vi->stats);
+
+		u64_stats_update_begin(&stats->syncp);
+		stats->tx_bytes += tx_bytes;
+		stats->tx_packets += tx_packets;
+		u64_stats_update_end(&stats->syncp);
+	}
+
 	return tot_sgs;
 }
 
