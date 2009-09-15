From: Christian Samsel <Christian.Samsel@rwth-aachen.de>
Subject: [PATCH] early retransmit
Date: Tue, 15 Sep 2009 11:31:20 +0000 (GMT)
Message-ID: <fbcff4b4d3bd.4aaf7b08@rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:41452 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752031AbZIOLbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 07:31:17 -0400
Content-disposition: inline
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KQ000DHBG08UK20@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 15 Sep 2009 13:31:20 +0200 (CEST)
Received: from mem-1.ms.rz.rwth-aachen.de
 (ms-frontend-134-130-7-83.nn.RWTH-Aachen.DE [134.130.7.83] (may be forged))
	by smarthost.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id n8FBVKXX015504
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 13:31:20 +0200 (CEST)
Received: from msg-int.RWTH-Aachen.de (localhost [127.0.0.1])
	by mem-1.ms.rz.rwth-aachen.de (8.13.8+Sun/8.13.8) with ESMTP id n8FBVKPJ015501
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 13:31:20 +0200 (CEST)
Content-language: de
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements draft-ietf-tcpm-early-rexmt.
It prevents a rto by lowering the dupack threshold in case
we expect less dupacks then the usual threshold.
Signed-off-by: Christian Samsel <christian.samsel@rwth-aachen.de>

---
 net/ipv4/tcp_input.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index af6d6fa..c0cc4fd 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2913,6 +2913,7 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	int do_lost = is_dupack || ((flag & FLAG_DATA_SACKED) &&
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit = 0, mib_idx;
+	u32 in_flight;
 
 	if (WARN_ON(!tp->packets_out && tp->sacked_out))
 		tp->sacked_out = 0;
@@ -3062,6 +3063,21 @@ static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int flag)
 	if (do_lost || (tcp_is_fack(tp) && tcp_head_timedout(sk)))
 		tcp_update_scoreboard(sk, fast_rexmit);
 	tcp_cwnd_down(sk, flag);
+        
+
+	/* draft-ietf-tcpm-early-rexmt: lowers dup ack threshold to prevent rto
+	 * in case we don't expect enough dup ack. if number of outstanding 
+	 * packets is less than four and there is either no unsent data ready
+	 * for transmission or the advertised window does not permit new 
+	 * segments.
+	 */
+	in_flight = tcp_packets_in_flight(tp);
+	if ( in_flight < 4 && (skb_queue_empty(&sk->sk_write_queue) || 
+		tcp_may_send_now(sk) == 0) )
+		tp->reordering = in_flight - 1;
+	else if (tp->reordering != sysctl_tcp_reordering)
+		tp->reordering = sysctl_tcp_reordering;
+	
 	tcp_xmit_retransmit_queue(sk);
 }
 
-- 
1.6.4.1
