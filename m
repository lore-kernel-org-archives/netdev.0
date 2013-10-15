From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2] tcp: must unclone packets before mangling them
Date: Tue, 15 Oct 2013 11:54:30 -0700
Message-ID: <1381863270.2045.62.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:58011 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab3JOSyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 14:54:32 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so9202554pbb.34
        for <netdev@vger.kernel.org>; Tue, 15 Oct 2013 11:54:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP stack should make sure it owns skbs before mangling them.

We had various crashes using bnx2x, and it turned out gso_size
was cleared right before bnx2x driver was populating TC descriptor
of the _previous_ packet send. TCP stack can sometime retransmit
packets that are still in Qdisc.

Of course we could make bnx2x driver more robust (using
ACCESS_ONCE(shinfo->gso_size) for example), but the bug is TCP stack.

We have identified two points where skb_unclone() was needed.

This patch adds a WARN_ON_ONCE() to warn us if we missed another
fix of this kind.

Kudos to Neal for finding the root cause of this bug. Its visible
using small MSS.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_output.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index c6f01f2..8fad1c1 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -986,6 +986,9 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 				 unsigned int mss_now)
 {
+	/* Make sure we own this skb before messing gso_size/gso_segs */
+	WARN_ON_ONCE(skb_cloned(skb));
+
 	if (skb->len <= mss_now || !sk_can_gso(sk) ||
 	    skb->ip_summed == CHECKSUM_NONE) {
 		/* Avoid the costly divide in the normal
@@ -1067,9 +1070,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *skb, u32 len,
 	if (nsize < 0)
 		nsize = 0;
 
-	if (skb_cloned(skb) &&
-	    skb_is_nonlinear(skb) &&
-	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+	if (skb_unclone(skb, GFP_ATOMIC))
 		return -ENOMEM;
 
 	/* Get a new skb... force flag on. */
@@ -2344,6 +2345,8 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 		int oldpcount = tcp_skb_pcount(skb);
 
 		if (unlikely(oldpcount > 1)) {
+			if (skb_unclone(skb, GFP_ATOMIC))
+				return -ENOMEM;
 			tcp_init_tso_segs(sk, skb, cur_mss);
 			tcp_adjust_pcount(sk, skb, oldpcount - tcp_skb_pcount(skb));
 		}
