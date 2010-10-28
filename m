From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 4/4] dccp ccid-2: Stop polling
Date: Thu, 28 Oct 2010 07:16:28 +0200
Message-ID: <1288242988-5333-5-git-send-email-gerrit@erg.abdn.ac.uk>
References: <dccp_packet_dequeueing_interface_set_of_4>
 <1288242988-5333-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1288242988-5333-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1288242988-5333-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1288242988-5333-4-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:39579 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753436Ab0J1FQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 01:16:47 -0400
In-Reply-To: <1288242988-5333-4-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updates CCID-2 to use the CCID dequeuing mechanism, converting from
previous continuous-polling to a now event-driven mechanism.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   23 +++++++++++++++--------
 net/dccp/ccids/ccid2.h |    5 +++++
 2 files changed, 20 insertions(+), 8 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -81,6 +81,11 @@ struct ccid2_hc_tx_sock {
 	u64			tx_high_ack;
 };
 
+static inline bool ccid2_cwnd_network_limited(struct ccid2_hc_tx_sock *hc)
+{
+	return hc->tx_pipe >= hc->tx_cwnd;
+}
+
 struct ccid2_hc_rx_sock {
 	int	rx_data;
 };
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -78,12 +78,9 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hc)
 
 static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
-	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
-
-	if (hc->tx_pipe < hc->tx_cwnd)
-		return 0;
-
-	return 1; /* XXX CCID should dequeue when ready instead of polling */
+	if (ccid2_cwnd_network_limited(ccid2_hc_tx_sk(sk)))
+		return CCID_PACKET_WILL_DEQUEUE_LATER;
+	return CCID_PACKET_SEND_AT_ONCE;
 }
 
 static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
@@ -115,6 +112,7 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
 	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
+	const bool sender_was_blocked = ccid2_cwnd_network_limited(hc);
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
@@ -129,8 +127,6 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	if (hc->tx_rto > DCCP_RTO_MAX)
 		hc->tx_rto = DCCP_RTO_MAX;
 
-	sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
-
 	/* adjust pipe, cwnd etc */
 	hc->tx_ssthresh = hc->tx_cwnd / 2;
 	if (hc->tx_ssthresh < 2)
@@ -146,6 +142,12 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	hc->tx_rpseq    = 0;
 	hc->tx_rpdupack = -1;
 	ccid2_change_l_ack_ratio(sk, 1);
+
+	/* if we were blocked before, we may now send cwnd=1 packet */
+	if (sender_was_blocked)
+		tasklet_schedule(&dccp_sk(sk)->dccps_xmitlet);
+	/* restart backed-off timer */
+	sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
@@ -434,6 +436,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
+	const bool sender_was_blocked = ccid2_cwnd_network_limited(hc);
 	u64 ackno, seqno;
 	struct ccid2_seq *seqp;
 	unsigned char *vector;
@@ -631,6 +634,10 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		sk_stop_timer(sk, &hc->tx_rtotimer);
 	else
 		sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
+
+	/* check if incoming Acks allow pending packets to be sent */
+	if (sender_was_blocked && !ccid2_cwnd_network_limited(hc))
+		tasklet_schedule(&dccp_sk(sk)->dccps_xmitlet);
 }
 
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
