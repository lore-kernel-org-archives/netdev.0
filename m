From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: do not rearm RTO when future data are sacked
Date: Thu, 24 Oct 2013 08:59:27 -0700
Message-ID: <1382630367-21964-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	brakmo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:47164 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756182Ab3JXP76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 11:59:58 -0400
Received: by mail-pa0-f73.google.com with SMTP id kp14so71465pab.2
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 08:59:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch ed08495c3 "tcp: use RTT from SACK for RTO" always re-arms RTO upon
obtaining a RTT sample from newly sacked data.

But technically RTO should only be re-armed when the data sent before
the last (re)transmission of write queue head are (s)acked. Otherwise
the RTO may continue to extend during loss recovery on data sent
in the future.

Note that RTTs from ACK or timestamps do not have this problem, as the RTT
source must be from data sent before.

The new RTO re-arm policy is
1) Always re-arm RTO if SND.UNA is advanced
2) Re-arm RTO if sack RTT is available, provided the sacked data was
   sent before the last time write_queue_head was sent.

Signed-off-by: Larry Brakmo <brakmo@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 6ffe41a..068c8fb 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2987,6 +2987,7 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	s32 seq_rtt = -1;
 	s32 ca_seq_rtt = -1;
 	ktime_t last_ackt = net_invalid_timestamp();
+	bool rtt_update;
 
 	while ((skb = tcp_write_queue_head(sk)) && skb != tcp_send_head(sk)) {
 		struct tcp_skb_cb *scb = TCP_SKB_CB(skb);
@@ -3063,14 +3064,13 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	if (skb && (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_ACKED))
 		flag |= FLAG_SACK_RENEGING;
 
-	if (tcp_ack_update_rtt(sk, flag, seq_rtt, sack_rtt) ||
-	    (flag & FLAG_ACKED))
-		tcp_rearm_rto(sk);
+	rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt, sack_rtt);
 
 	if (flag & FLAG_ACKED) {
 		const struct tcp_congestion_ops *ca_ops
 			= inet_csk(sk)->icsk_ca_ops;
 
+		tcp_rearm_rto(sk);
 		if (unlikely(icsk->icsk_mtup.probe_size &&
 			     !after(tp->mtu_probe.probe_seq_end, tp->snd_una))) {
 			tcp_mtup_probe_success(sk);
@@ -3109,6 +3109,13 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 			ca_ops->pkts_acked(sk, pkts_acked, rtt_us);
 		}
+	} else if (skb && rtt_update && sack_rtt >= 0 &&
+		   sack_rtt > (s32)(now - TCP_SKB_CB(skb)->when)) {
+		/* Do not re-arm RTO if the sack RTT is measured from data sent
+		 * after when the head was last (re)transmitted. Otherwise the
+		 * timeout may continue to extend in loss recovery.
+		 */
+		tcp_rearm_rto(sk);
 	}
 
 #if FASTRETRANS_DEBUG > 0
-- 
1.8.4.1
