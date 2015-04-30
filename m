From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: [PATCH v2 net-next 3/3] tcp: invoke pkts_acked hook on every ACK
Date: Fri,  1 May 2015 01:10:59 +0200
Message-ID: <1430435459-12805-4-git-send-email-kennetkl@ifi.uio.no>
References: <1430435459-12805-1-git-send-email-kennetkl@ifi.uio.no>
Cc: ycheng@google.com, Kenneth Klette Jonassen <kennetkl@ifi.uio.no>,
	Eric Dumazet <edumazet@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:33372 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750839AbbD3XLj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 19:11:39 -0400
In-Reply-To: <1430435459-12805-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Invoking pkts_acked is currently conditioned on FLAG_ACKED:
receiving a cumulative ACK of new data, or ACK with SYN flag set.

Remove this condition so that CC may get RTT measurements from all SACKs.

Cc: Yuchung Cheng <ycheng@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
---
 net/ipv4/tcp_input.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f563d2a..09bdc4a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3159,9 +3159,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 	rtt_update = tcp_ack_update_rtt(sk, flag, seq_rtt_us, sack_rtt_us);
 
 	if (flag & FLAG_ACKED) {
-		const struct tcp_congestion_ops *ca_ops
-			= inet_csk(sk)->icsk_ca_ops;
-
 		tcp_rearm_rto(sk);
 		if (unlikely(icsk->icsk_mtup.probe_size &&
 			     !after(tp->mtu_probe.probe_seq_end, tp->snd_una))) {
@@ -3184,9 +3181,6 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 
 		tp->fackets_out -= min(pkts_acked, tp->fackets_out);
 
-		if (ca_ops->pkts_acked)
-			ca_ops->pkts_acked(sk, pkts_acked, ca_rtt_us);
-
 	} else if (skb && rtt_update && sack_rtt_us >= 0 &&
 		   sack_rtt_us > skb_mstamp_us_delta(&now, &skb->skb_mstamp)) {
 		/* Do not re-arm RTO if the sack RTT is measured from data sent
@@ -3196,6 +3190,9 @@ static int tcp_clean_rtx_queue(struct sock *sk, int prior_fackets,
 		tcp_rearm_rto(sk);
 	}
 
+	if (icsk->icsk_ca_ops->pkts_acked)
+		icsk->icsk_ca_ops->pkts_acked(sk, pkts_acked, ca_rtt_us);
+
 #if FASTRETRANS_DEBUG > 0
 	WARN_ON((int)tp->sacked_out < 0);
 	WARN_ON((int)tp->lost_out < 0);
-- 
2.1.0
