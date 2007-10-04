From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: [RFC][PATCH 1/2] TCP: fix lost retransmit detection
Date: Thu, 04 Oct 2007 18:45:19 +0900 (JST)
Message-ID: <20071004.184519.16476818.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: y-kodama@aist.go.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:62001 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753360AbXJDKRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 06:17:53 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows to detect loss of retransmitted packets more
accurately by using the highest end sequence number among SACK 
blocks.  Before the retransmission queue is scanned, the highest
end sequence number (high_end_seq) is retrieved, and this value
is compared with the ack_seq of each packet.

Signed-off-by: Ryousei Takano <takano-ryousei@aist.go.jp>
Signed-off-by: Yuetsu Kodama <y-kodama@aist.go.jp>
---
 net/ipv4/tcp_input.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index bbad2cd..12db4b3 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -978,6 +978,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	int cached_fack_count;
 	int i;
 	int first_sack_index;
+	__u32 high_end_seq;
 
 	if (!tp->sacked_out)
 		tp->fackets_out = 0;
@@ -1012,6 +1013,14 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 	if (before(TCP_SKB_CB(ack_skb)->ack_seq, prior_snd_una - tp->max_window))
 		return 0;
 
+	/* Retrieve the highest end_seq among SACK blocks. */
+	high_end_seq = ntohl(sp[0].end_seq);
+	for (i = 1; i < num_sacks; i++) {
+		__u32 end_seq = ntohl(sp[i].end_seq);
+		if (after(end_seq, high_end_seq))
+			high_end_seq = end_seq;
+	}
+
 	/* SACK fastpath:
 	 * if the only SACK change is the increase of the end_seq of
 	 * the first block then only apply that SACK block
@@ -1161,9 +1170,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct sk_buff *ack_skb, u32 prior_snd_
 			}
 
 			if ((sacked&TCPCB_SACKED_RETRANS) &&
-			    after(end_seq, TCP_SKB_CB(skb)->ack_seq) &&
-			    (!lost_retrans || after(end_seq, lost_retrans)))
-				lost_retrans = end_seq;
+			    after(high_end_seq, TCP_SKB_CB(skb)->ack_seq))
+				lost_retrans = high_end_seq;
 
 			if (!in_sack)
 				continue;
-- 
1.5.2.4

