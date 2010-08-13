From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 2/3] dccp ccid-2: Use existing function to test for data packets
Date: Fri, 13 Aug 2010 07:21:40 +0200
Message-ID: <1281676901-7018-3-git-send-email-gerrit@erg.abdn.ac.uk>
References: <ccid2_cwv_dccp_test_tree>
 <1281676901-7018-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1281676901-7018-2-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: netdev@vger.kernel.org, Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:51741 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751785Ab0HMFfU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Aug 2010 01:35:20 -0400
In-Reply-To: <1281676901-7018-2-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replaces a switch statement with a test using the equivalent function
dccp_data_packet(skb).
It also doubles the range of the field `rx_num_data_pkts' by changing the
type from `int' to `u32' (avoiding signed/unsigned comparison with the u16
field `dccps_r_ack_ratio').

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.h |    6 +++++-
 net/dccp/ccids/ccid2.c |   16 ++++++----------
 2 files changed, 11 insertions(+), 11 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -88,8 +88,12 @@ static inline bool ccid2_cwnd_network_limited(struct ccid2_hc_tx_sock *hc)
 	return (hc->tx_pipe >= hc->tx_cwnd);
 }
 
+/**
+ * struct ccid2_hc_rx_sock  -  Receiving end of CCID-2 half-connection
+ * @rx_num_data_pkts: number of data packets received since last feedback
+ */
 struct ccid2_hc_rx_sock {
-	int	rx_data;
+	u32	rx_num_data_pkts;
 };
 
 static inline struct ccid2_hc_tx_sock *ccid2_hc_tx_sk(const struct sock *sk)
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -629,18 +629,14 @@ static void ccid2_hc_tx_exit(struct sock *sk)
 
 static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_rx_sock *hc = ccid2_hc_rx_sk(sk);
 
-	switch (DCCP_SKB_CB(skb)->dccpd_type) {
-	case DCCP_PKT_DATA:
-	case DCCP_PKT_DATAACK:
-		hc->rx_data++;
-		if (hc->rx_data >= dp->dccps_r_ack_ratio) {
-			dccp_send_ack(sk);
-			hc->rx_data = 0;
-		}
-		break;
+	if (!dccp_data_packet(skb))
+		return;
+
+	if (++hc->rx_num_data_pkts >= dccp_sk(sk)->dccps_r_ack_ratio) {
+		dccp_send_ack(sk);
+		hc->rx_num_data_pkts = 0;
 	}
 }
 
