From: John Heffner <jheffner@psc.edu>
Subject: Re: simplify microsecond rtt sampling
Date: Thu, 28 Sep 2006 13:35:16 +0100
Message-ID: <451BC184.1000707@psc.edu>
References: <451A5EC9.6090001@psc.edu> <451A9519.6000504@psc.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010800040700080906050007"
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:19146 "EHLO mailer2.psc.edu")
	by vger.kernel.org with ESMTP id S1751873AbWI1Mfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 08:35:36 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <451A9519.6000504@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010800040700080906050007
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Here is a corrected patch.


Signed-off-by: John Heffner <jheffner@psc.edu>


--------------010800040700080906050007
Content-Type: text/plain; x-mac-type="0"; x-mac-creator="0";
 name="rtt_sample_fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rtt_sample_fix.patch"

-static u32 tcp_usrtt(const struct sk_buff *skb)
+static u32 tcp_usrtt(struct timeval *tv)
 {
-	struct timeval tv, now;
+	struct timeval now;
 
 	do_gettimeofday(&now);
-	skb_get_timestamp(skb, &tv);
-	return (now.tv_sec - tv.tv_sec) * 1000000 + (now.tv_usec - tv.tv_usec);
+	return (now.tv_sec - tv->tv_sec) * 1000000 + (now.tv_usec - tv->tv_usec);
 }
 
 /* Remove acknowledged frames from the retransmission queue. */
@@ -2249,6 +2248,7 @@ static int tcp_clean_rtx_queue(struct so
 	u32 pkts_acked = 0;
 	void (*rtt_sample)(struct sock *sk, u32 usrtt)
 		= icsk->icsk_ca_ops->rtt_sample;
+	struct timeval tv;
 
 	while ((skb = skb_peek(&sk->sk_write_queue)) &&
 	       skb != sk->sk_send_head) {
@@ -2297,8 +2297,7 @@ static int tcp_clean_rtx_queue(struct so
 				seq_rtt = -1;
 			} else if (seq_rtt < 0) {
 				seq_rtt = now - scb->when;
-				if (rtt_sample)
-					(*rtt_sample)(sk, tcp_usrtt(skb));
+				skb_get_timestamp(skb, &tv);
 			}
 			if (sacked & TCPCB_SACKED_ACKED)
 				tp->sacked_out -= tcp_skb_pcount(skb);
@@ -2311,8 +2310,7 @@ static int tcp_clean_rtx_queue(struct so
 			}
 		} else if (seq_rtt < 0) {
 			seq_rtt = now - scb->when;
-			if (rtt_sample)
-				(*rtt_sample)(sk, tcp_usrtt(skb));
+			skb_get_timestamp(skb, &tv);
 		}
 		tcp_dec_pcount_approx(&tp->fackets_out, skb);
 		tcp_packets_out_dec(tp, skb);
@@ -2324,6 +2322,8 @@ static int tcp_clean_rtx_queue(struct so
 	if (acked&FLAG_ACKED) {
 		tcp_ack_update_rtt(sk, acked, seq_rtt);
 		tcp_ack_packets_out(sk, tp);
+		if (rtt_sample && !(acked & FLAG_RETRANS_DATA_ACKED))
+			(*rtt_sample)(sk, tcp_usrtt(&tv));
 
 		if (icsk->icsk_ca_ops->pkts_acked)
 			icsk->icsk_ca_ops->pkts_acked(sk, pkts_acked);

--------------010800040700080906050007--
