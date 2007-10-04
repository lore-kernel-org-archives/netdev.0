From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: [RFC][PATCH 2/2] TCP: skip processing cached SACK blocks
Date: Thu, 04 Oct 2007 18:44:56 +0900 (JST)
Message-ID: <20071004.184456.40407483.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: y-kodama@aist.go.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:63832 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756293AbXJDKR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 06:17:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows to process only newly reported SACK blocks at the
sender side. An ACK packet contains up to three SACK blocks, and some
of them may be already reported and processed blocks.  This patch 
prevents processing of such already processed SACK blocks.

Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
Signed-off-by: Yuetsu Kodama <y-kodama@aist.go.jp>
---
 net/ipv4/tcp_input.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bbad2cd..9615fc9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -978,6 +978,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	int cached_fack_count;
 	int i;
 	int first_sack_index;
+	u8 sack_block_skip[4] = {0,0,0,0};
 
 	if (!tp->sacked_out)
 		tp->fackets_out = 0;
@@ -1012,6 +1013,21 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	if (before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una - tp->max_window))
 		return 0;
 
+	/* Skip processing cached SACK blocks. */
+	for (i = 0; i < num_sacks; i++) {
+		__be32 start_seq = sp[i].start_seq;
+		__be32 end_seq = sp[i].end_seq;
+		int j;
+
+		for (j = 0; j < ARRAY_SIZE(tp->recv_sack_cache); j++) {
+			if ((tp->recv_sack_cache[j].start_seq == start_seq) &&
+			    (tp->recv_sack_cache[j].end_seq == end_seq)) {
+				sack_block_skip[i] = 1;
+				break;
+			}
+		}
+	}
+
 	/* SACK fastpath:
 	 * if the only SACK change is the increase of the end_seq of
 	 * the first block then only apply that SACK block
@@ -1051,11 +1067,16 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 				if (after(ntohl(sp[j].start_seq),
 					  ntohl(sp[j+1].start_seq))){
 					struct tcp_sack_block_wire tmp;
+					u8 sbtmp;
 
 					tmp = sp[j];
 					sp[j] = sp[j+1];
 					sp[j+1] = tmp;
 
+					sbtmp = sack_block_skip[j];
+					sack_block_skip[j] = sack_block_skip[j+1];
+					sack_block_skip[j+1] = sbtmp;
+
 					/* Track where the first SACK block goes to */
 					if (j == first_sack_index)
 						first_sack_index = j+1;
@@ -1083,6 +1104,9 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 		int fack_count;
 		int dup_sack = (found_dup_sack && (i == first_sack_index));
 
+		if (sack_block_skip[i])
+			continue;
+
 		skb = cached_skb;
 		fack_count = cached_fack_count;
 
-- 
1.5.2.4

