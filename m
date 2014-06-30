From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2] net: Performance fix for process_backlog
Date: Mon, 30 Jun 2014 09:48:17 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406300943300.5624@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:46755 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbaF3QsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 12:48:18 -0400
Received: by mail-pd0-f201.google.com with SMTP id v10so1357661pde.2
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 09:48:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In process_backlog the input_pkt_queue is only checked once for new
packets and quota is artificially reduced to reflect precisely the
number of packets on the input_pkt_queue so that the loop exits
appropriately.

This patches changes the behavior to be more straightforward and
less convoluted. Packets are processed until either the quota
is met or there are no more packets to process.

This patch seems to provide a small, but noticeable performance
improvement. The performance improvement is a result of staying
in the process_backlog loop longer which can reduce number of IPI's.

Performance data using super_netperf TCP_RR with 200 flows:

Before fix:

88.06% CPU utilization
125/190/309 90/95/99% latencies
1.46808e+06 tps
1145382 intrs.sec.

With fix:

87.73% CPU utilization
122/183/296 90/95/99% latencies
1.4921e+06 tps
1021674.30 intrs./sec.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a04b12f..bb88964 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4227,9 +4227,8 @@ static int process_backlog(struct napi_struct *napi, int quota)
 #endif
 	napi->weight = weight_p;
 	local_irq_disable();
-	while (work < quota) {
+	while (1) {
 		struct sk_buff *skb;
-		unsigned int qlen;
 
 		while ((skb = __skb_dequeue(&sd->process_queue))) {
 			local_irq_enable();
@@ -4243,24 +4242,24 @@ static int process_backlog(struct napi_struct *napi, int quota)
 		}
 
 		rps_lock(sd);
-		qlen = skb_queue_len(&sd->input_pkt_queue);
-		if (qlen)
-			skb_queue_splice_tail_init(&sd->input_pkt_queue,
-						   &sd->process_queue);
-
-		if (qlen < quota - work) {
+		if (skb_queue_empty(&sd->input_pkt_queue)) {
 			/*
 			 * Inline a custom version of __napi_complete().
 			 * only current cpu owns and manipulates this napi,
-			 * and NAPI_STATE_SCHED is the only possible flag set on backlog.
-			 * we can use a plain write instead of clear_bit(),
+			 * and NAPI_STATE_SCHED is the only possible flag set
+			 * on backlog.
+			 * We can use a plain write instead of clear_bit(),
 			 * and we dont need an smp_mb() memory barrier.
 			 */
 			list_del(&napi->poll_list);
 			napi->state = 0;
+			rps_unlock(sd);
 
-			quota = work + qlen;
+			break;
 		}
+
+		skb_queue_splice_tail_init(&sd->input_pkt_queue,
+					   &sd->process_queue);
 		rps_unlock(sd);
 	}
 	local_irq_enable();
-- 
2.0.0.526.g5318336
