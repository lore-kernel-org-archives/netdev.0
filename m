From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH] tcp: fix tcp_shifted_skb() adjustment of lost_cnt_hint for FACK
Date: Tue, 14 Feb 2012 01:22:08 -0500
Message-ID: <1329200528-19718-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f202.google.com ([209.85.160.202]:63957 "EHLO
	mail-gy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185Ab2BNGWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 01:22:11 -0500
Received: by ghrr17 with SMTP id r17so631360ghr.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 22:22:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit ensures that lost_cnt_hint is correctly updated in
tcp_shifted_skb() for FACK TCP senders. The lost_cnt_hint adjustment
in tcp_sacktag_one() only applies to non-FACK senders, so FACK senders
need their own adjustment.

This applies the spirit of 1e5289e121372a3494402b1b131b41bfe1cf9b7f -
except now that the sequence range passed into tcp_sacktag_one() is
correct we need only have a special case adjustment for FACK.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8116d06..53c8ce4 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1403,6 +1403,10 @@ static int tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 
 	BUG_ON(!pcount);
 
+	/* Adjust hint for FACK. Non-FACK is handled in tcp_sacktag_one(). */
+	if (tcp_is_fack(tp) && (skb == tp->lost_skb_hint))
+		tp->lost_cnt_hint += pcount;
+
 	TCP_SKB_CB(prev)->end_seq += shifted;
 	TCP_SKB_CB(skb)->seq += shifted;
 
-- 
1.7.7.3
