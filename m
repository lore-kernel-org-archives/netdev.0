From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/5] tcp: remove obsolete check in tcp_set_skb_tso_segs()
Date: Thu, 11 Jun 2015 09:15:19 -0700
Message-ID: <1434039319-31309-6-git-send-email-edumazet@google.com>
References: <1434039319-31309-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:33715 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753421AbbFKQP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 12:15:57 -0400
Received: by iebgx4 with SMTP id gx4so8578205ieb.0
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2015 09:15:56 -0700 (PDT)
In-Reply-To: <1434039319-31309-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We had various issues in the past when TCP stack was modifying
gso_size/gso_segs while clones were in flight.

Commit c52e2421f73 ("tcp: must unclone packets before mangling them")
fixed these bugs and added a WARN_ON_ONCE(skb_cloned(skb)); in
tcp_set_skb_tso_segs()

These bugs are now fixed, and because TCP stack now only sets
shinfo->gso_size|segs on the clone itself, the check can be removed.

As a result of this change, compiler inlines tcp_set_skb_tso_segs() in
tcp_init_tso_segs()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 787f57ff87c4..b1c218df2c85 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1066,9 +1066,6 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 /* Initialize TSO segments for a packet. */
 static void tcp_set_skb_tso_segs(struct sk_buff *skb, unsigned int mss_now)
 {
-	/* Make sure we own this skb before messing gso_size/gso_segs */
-	WARN_ON_ONCE(skb_cloned(skb));
-
 	if (skb->len <= mss_now || skb->ip_summed == CHECKSUM_NONE) {
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
-- 
2.2.0.rc0.207.ga3a616c
