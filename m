From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 2/2] tcp: fix range tcp_shifted_skb() passes to tcp_sacktag_one()
Date: Sun, 12 Feb 2012 23:37:10 -0500
Message-ID: <1329107830-3351-2-git-send-email-ncardwell@google.com>
References: <1329107830-3351-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f202.google.com ([209.85.215.202]:53005 "EHLO
	mail-ey0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754793Ab2BMEhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2012 23:37:32 -0500
Received: by eaaf13 with SMTP id f13so136114eaa.1
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2012 20:37:31 -0800 (PST)
In-Reply-To: <1329107830-3351-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the newly-SACKed range to be the range of newly-shifted bytes.

Previously - since 832d11c5cd076abc0aa1eaf7be96c81d1a59ce41 -
tcp_shifted_skb() incorrectly called tcp_sacktag_one() with the start
and end sequence numbers of the skb it passes in set to the range just
beyond the range that is newly-SACKed.

This commit also removes a special-case adjustment to lost_cnt_hint in
tcp_shifted_skb() since the pre-existing adjustment of lost_cnt_hint
in tcp_sacktag_one() now properly handles this things now that the
correct start sequence number is passed in.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4e8a81f..8116d06 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1388,6 +1388,9 @@ static u8 tcp_sacktag_one(struct sock *sk,
 	return sacked;
 }
 
+/* Shift newly-SACKed bytes from this skb to the immediately previous
+ * already-SACKed sk_buff. Mark the newly-SACKed bytes as such.
+ */
 static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 			   struct tcp_sacktag_state *state,
 			   unsigned int pcount, int shifted, int mss,
@@ -1395,12 +1398,11 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct sk_buff *prev = tcp_write_queue_prev(sk, skb);
+	u32 start_seq = TCP_SKB_CB(skb)->seq;	/* start of newly-SACKed */
+	u32 end_seq = start_seq + shifted;	/* end of newly-SACKed */
 
 	BUG_ON(!pcount);
 
-	if (skb == tp->lost_skb_hint)
-		tp->lost_cnt_hint += pcount;
-
 	TCP_SKB_CB(prev)->end_seq += shifted;
 	TCP_SKB_CB(skb)->seq += shifted;
 
@@ -1424,12 +1426,11 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 		skb_shinfo(skb)->gso_type = 0;
 	}
 
-	/* We discard results */
-	tcp_sacktag_one(sk, state,
-			TCP_SKB_CB(skb)->sacked,
-			TCP_SKB_CB(skb)->seq,
-			TCP_SKB_CB(skb)->end_seq,
-			dup_sack, pcount);
+	/* Adjust counters and hints for the newly sacked sequence range but
+	 * discard the return value since prev is already marked.
+	 */
+	tcp_sacktag_one(sk, state, TCP_SKB_CB(skb)->sacked,
+			start_seq, end_seq, dup_sack, pcount);
 
 	/* Difference in this won't matter, both ACKed by the same cumul. ACK */
 	TCP_SKB_CB(prev)->sacked |= (TCP_SKB_CB(skb)->sacked & TCPCB_EVER_RETRANS);
-- 
1.7.7.3
