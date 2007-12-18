From: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Subject: Re: [PATCH/RFC] [v2] TCP: use non-delayed ACK for congestion	control
 RTT
Date: Tue, 18 Dec 2007 20:40:22 +0000
Message-ID: <20071218204022.GA8936@nuim.ie>
References: <20071217134425.GD7409@nuim.ie>
Reply-To: Gavin McCullagh <Gavin.McCullagh@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from banyan.nuim.ie ([149.157.1.4]:50721 "EHLO mango.nuim.ie"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752017AbXLRUkT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2007 15:40:19 -0500
Content-disposition: inline
Received: from boing.hamilton.local ([149.157.192.252])
 by mango.nuim.ie (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3
 2007; 32bit)) with ESMTP id <0JT9007B7IR36S50@mango.nuim.ie> for
 netdev@vger.kernel.org; Tue, 18 Dec 2007 20:40:15 +0000 (GMT)
In-reply-to: <20071217134425.GD7409@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The last attempt didn't take account of the situation where a timestamp
wasn't available and tcp_clean_rtx_queue() has to feed both the RTO and the
congestion avoidance.  This updated patch stores both RTTs, making the
delayed one available for the RTO and the other (ca_seq_rtt) available for
congestion control.


Signed-off-by: Gavin McCullagh <gavin.mccullagh@nuim.ie> 


diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 889c893..6fb7989 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2651,6 +2651,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 	u32 cnt = 0;
 	u32 reord = tp->packets_out;
 	s32 seq_rtt = -1;
+	s32 ca_seq_rtt = -1;
 	ktime_t last_ackt = net_invalid_timestamp();
 
 	while ((skb = tcp_write_queue_head(sk)) && skb != tcp_send_head(sk)) {
@@ -2686,13 +2687,15 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 				if (sacked & TCPCB_SACKED_RETRANS)
 					tp->retrans_out -= packets_acked;
 				flag |= FLAG_RETRANS_DATA_ACKED;
+				ca_seq_rtt = -1;
 				seq_rtt = -1;
 				if ((flag & FLAG_DATA_ACKED) ||
 				    (packets_acked > 1))
 					flag |= FLAG_NONHEAD_RETRANS_ACKED;
 			} else {
+				ca_seq_rtt = now - scb->when;
 				if (seq_rtt < 0) {
-					seq_rtt = now - scb->when;
+					seq_rtt = ca_seq_rtt;
 					if (fully_acked)
 						last_ackt = skb->tstamp;
 				}
@@ -2709,8 +2712,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 			    !before(end_seq, tp->snd_up))
 				tp->urg_mode = 0;
 		} else {
+			ca_seq_rtt = now - scb->when;
 			if (seq_rtt < 0) {
-				seq_rtt = now - scb->when;
+				seq_rtt = ca_seq_rtt;
 				if (fully_acked)
 					last_ackt = skb->tstamp;
 			}
@@ -2772,8 +2776,8 @@ static int tcp_clean_rtx_queue(struct sock *sk, s32 *seq_rtt_p,
 						 net_invalid_timestamp()))
 					rtt_us = ktime_us_delta(ktime_get_real(),
 								last_ackt);
-				else if (seq_rtt > 0)
-					rtt_us = jiffies_to_usecs(seq_rtt);
+				else if (ca_seq_rtt > 0)
+					rtt_us = jiffies_to_usecs(ca_seq_rtt);
 			}
 
 			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);


