From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: fix false reordering signal in tcp_shifted_skb
Date: Sun, 26 Feb 2012 15:06:19 -0500
Message-ID: <1330286779-10462-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f202.google.com ([209.85.161.202]:41966 "EHLO
	mail-gx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701Ab2BZUMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2012 15:12:43 -0500
Received: by ggnp1 with SMTP id p1so464079ggn.1
        for <netdev@vger.kernel.org>; Sun, 26 Feb 2012 12:12:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tcp_shifted_skb() shifts bytes from the skb that is currently
pointed to by 'highest_sack' then the increment of
TCP_SKB_CB(skb)->seq implicitly advances tcp_highest_sack_seq(). This
implicit advancement, combined with the recent fix to pass the correct
SACKed range into tcp_sacktag_one(), caused tcp_sacktag_one() to think
that the newly SACKed range was before the tcp_highest_sack_seq(),
leading to a call to tcp_update_reordering() with a degree of
reordering matching the size of the newly SACKed range (typically just
1 packet, which is a NOP, but potentially larger).

This commit fixes this by simply calling tcp_sacktag_one() before the
TCP_SKB_CB(skb)->seq advancement that can advance our notion of the
highest SACKed sequence.

Correspondingly, we can simplify the code a little now that
tcp_shifted_skb() should update the lost_cnt_hint in all cases where
skb == tp->lost_skb_hint.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 53c8ce4..ee42d42 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1403,8 +1403,16 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 
 	BUG_ON(!pcount);
 
-	/* Adjust hint for FACK. Non-FACK is handled in tcp_sacktag_one(). */
-	if (tcp_is_fack(tp) && (skb == tp->lost_skb_hint))
+	/* Adjust counters and hints for the newly sacked sequence
+	 * range but discard the return value since prev is already
+	 * marked. We must tag the range first because the seq
+	 * advancement below implicitly advances
+	 * tcp_highest_sack_seq() when skb is highest_sack.
+	 */
+	tcp_sacktag_one(sk, state, TCP_SKB_CB(skb)->sacked,
+			start_seq, end_seq, dup_sack, pcount);
+
+	if (skb == tp->lost_skb_hint)
 		tp->lost_cnt_hint += pcount;
 
 	TCP_SKB_CB(prev)->end_seq += shifted;
@@ -1430,12 +1438,6 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 		skb_shinfo(skb)->gso_type = 0;
 	}
 
-	/* Adjust counters and hints for the newly sacked sequence range but
-	 * discard the return value since prev is already marked.
-	 */
-	tcp_sacktag_one(sk, state, TCP_SKB_CB(skb)->sacked,
-			start_seq, end_seq, dup_sack, pcount);
-
 	/* Difference in this won't matter, both ACKed by the same cumul. ACK */
 	TCP_SKB_CB(prev)->sacked |= (TCP_SKB_CB(skb)->sacked & TCPCB_EVER_RETRANS);
 
-- 
1.7.7.3
