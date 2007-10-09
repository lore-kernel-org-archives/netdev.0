From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: [PATCH net-2.6.24][trivial] fix inconsistency of terms
Date: Tue, 09 Oct 2007 15:32:34 +0900 (JST)
Message-ID: <20071009.153234.108020718.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: y-kodama@aist.go.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:59005 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbXJIGcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 02:32:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fix inconsistency of terms:
1) D-SACK
2) F-RTO

Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
---
 Documentation/networking/ip-sysctl.txt |    6 +++---
 net/ipv4/tcp_input.c                   |   16 ++++++++--------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 6ae2fef..829a4d8 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -184,14 +184,14 @@ tcp_frto - INTEGER
 	F-RTO is an enhanced recovery algorithm for TCP retransmission
 	timeouts.  It is particularly beneficial in wireless environments
 	where packet loss is typically due to random radio interference
-	rather than intermediate router congestion.  FRTO is sender-side
+	rather than intermediate router congestion.  F-RTO is sender-side
 	only modification.  Therefore it does not require any support from
 	the peer, but in a typical case, however, where wireless link is
 	the local access link and most of the data flows downlink, the
-	faraway servers should have FRTO enabled to take advantage of it.
+	faraway servers should have F-RTO enabled to take advantage of it.
 	If set to 1, basic version is enabled.  2 enables SACK enhanced
 	F-RTO if flow uses SACK.  The basic version can be used also when
-	SACK is in use though scenario(s) with it exists where FRTO
+	SACK is in use though scenario(s) with it exists where F-RTO
 	interacts badly with the packet counting of the SACK enabled TCP
 	flow.
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e8c3948..372ff6f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -103,7 +103,7 @@ int sysctl_tcp_abc __read_mostly;
 #define FLAG_SLOWPATH		0x100 /* Do not skip RFC checks for window update.*/
 #define FLAG_ONLY_ORIG_SACKED	0x200 /* SACKs only non-rexmit sent before RTO */
 #define FLAG_SND_UNA_ADVANCED	0x400 /* Snd_una was changed (!= FLAG_DATA_ACKED) */
-#define FLAG_DSACKING_ACK	0x800 /* SACK blocks contained DSACK info */
+#define FLAG_DSACKING_ACK	0x800 /* SACK blocks contained D-SACK info */
 #define FLAG_NONHEAD_RETRANS_ACKED	0x1000 /* Non-head rexmitted data was ACKed */
 
 #define FLAG_ACKED		(FLAG_DATA_ACKED|FLAG_SYN_ACKED)
@@ -866,7 +866,7 @@ static void tcp_disable_fack(struct tcp_sock *tp)
 	tp->rx_opt.sack_ok &= ~2;
 }
 
-/* Take a notice that peer is sending DSACKs */
+/* Take a notice that peer is sending D-SACKs */
 static void tcp_dsack_seen(struct tcp_sock *tp)
 {
 	tp->rx_opt.sack_ok |= 4;
@@ -1058,7 +1058,7 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
  *
  * With D-SACK the lower bound is extended to cover sequence space below
  * SND.UNA down to undo_marker, which is the last point of interest. Yet
- * again, DSACK block must not to go across snd_una (for the same reason as
+ * again, D-SACK block must not to go across snd_una (for the same reason as
  * for the normal SACK blocks, explained above). But there all simplicity
  * ends, TCP might receive valid D-SACKs below that. As long as they reside
  * fully below undo_marker they do not affect behavior in anyway and can
@@ -1080,7 +1080,7 @@ static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
 	if (!before(start_seq, tp->snd_nxt))
 		return 0;
 
-	/* In outstanding window? ...This is valid exit for DSACKs too.
+	/* In outstanding window? ...This is valid exit for D-SACKs too.
 	 * start_seq == snd_una is non-sensical (see comments above)
 	 */
 	if (after(start_seq, tp->snd_una))
@@ -1581,7 +1581,7 @@ void tcp_enter_frto(struct sock *sk)
 	     !icsk->icsk_retransmits)) {
 		tp->prior_ssthresh = tcp_current_ssthresh(sk);
 		/* Our state is too optimistic in ssthresh() call because cwnd
-		 * is not reduced until tcp_enter_frto_loss() when previous FRTO
+		 * is not reduced until tcp_enter_frto_loss() when previous F-RTO
 		 * recovery has not yet completed. Pattern would be this: RTO,
 		 * Cumulative ACK, RTO (2xRTO for the same segment does not end
 		 * up here twice).
@@ -1760,7 +1760,7 @@ void tcp_enter_loss(struct sock *sk, int how)
 	tcp_set_ca_state(sk, TCP_CA_Loss);
 	tp->high_seq = tp->snd_nxt;
 	TCP_ECN_queue_cwr(tp);
-	/* Abort FRTO algorithm if one is in progress */
+	/* Abort F-RTO algorithm if one is in progress */
 	tp->frto_counter = 0;
 }
 
@@ -1905,7 +1905,7 @@ static int tcp_time_to_recover(struct sock *sk)
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 packets_out;
 
-	/* Do not perform any recovery during FRTO algorithm */
+	/* Do not perform any recovery during F-RTO algorithm */
 	if (tp->frto_counter)
 		return 0;
 
@@ -2921,7 +2921,7 @@ static int tcp_process_frto(struct sock *sk, int flag)
 	}
 
 	if (tp->frto_counter == 1) {
-		/* Sending of the next skb must be allowed or no FRTO */
+		/* Sending of the next skb must be allowed or no F-RTO */
 		if (!tcp_send_head(sk) ||
 		    after(TCP_SKB_CB(tcp_send_head(sk))->end_seq,
 				     tp->snd_una + tp->snd_wnd)) {
-- 
1.5.0.6

