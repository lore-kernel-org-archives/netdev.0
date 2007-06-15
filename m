From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP]: Fix logic breakage due to DSACK separation
Date: Fri, 15 Jun 2007 16:07:37 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0706151606220.15358@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-55615407-1181912857=:15358"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52886 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753903AbXFONHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 09:07:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-55615407-1181912857=:15358
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Commit 6f74651ae626ec672028587bc700538076dfbefb is found guilty
of breaking DSACK counting, which should be done only for the
SACK block reported by the DSACK instead of every SACK block
that is received along with DSACK information.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d6d0f9b..c6a363b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -953,7 +953,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	int prior_fackets;
 	u32 lost_retrans = 0;
 	int flag = 0;
-	int dup_sack = 0;
+	int found_dup_sack = 0;
 	int cached_fack_count;
 	int i;
 	int first_sack_index;
@@ -964,20 +964,20 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 
 	/* Check for D-SACK. */
 	if (before(ntohl(sp[0].start_seq), TCP_SKB_CB(ack_skb)->ack_seq)) {
-		dup_sack = 1;
+		found_dup_sack = 1;
 		tp->rx_opt.sack_ok |= 4;
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKRECV);
 	} else if (num_sacks > 1 &&
 			!after(ntohl(sp[0].end_seq), ntohl(sp[1].end_seq)) &&
 			!before(ntohl(sp[0].start_seq), ntohl(sp[1].start_seq))) {
-		dup_sack = 1;
+		found_dup_sack = 1;
 		tp->rx_opt.sack_ok |= 4;
 		NET_INC_STATS_BH(LINUX_MIB_TCPDSACKOFORECV);
 	}
 
 	/* D-SACK for already forgotten data...
 	 * Do dumb counting. */
-	if (dup_sack &&
+	if (found_dup_sack &&
 			!after(ntohl(sp[0].end_seq), prior_snd_una) &&
 			after(ntohl(sp[0].end_seq), tp->undo_marker))
 		tp->undo_retrans--;
@@ -1058,6 +1058,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		__u32 start_seq = ntohl(sp->start_seq);
 		__u32 end_seq = ntohl(sp->end_seq);
 		int fack_count;
+		int dup_sack = (found_dup_sack && (i == first_sack_index));
 
 		skb = cached_skb;
 		fack_count = cached_fack_count;
-- 
1.5.0.6

---696243703-55615407-1181912857=:15358--
