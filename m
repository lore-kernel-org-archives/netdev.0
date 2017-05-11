From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: avoid fragmenting peculiar skbs in SACK
Date: Wed, 10 May 2017 17:01:27 -0700
Message-ID: <20170511000127.4249-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34734 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdEKABf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 20:01:35 -0400
Received: by mail-pf0-f179.google.com with SMTP id e64so5093653pfd.1
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 17:01:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a bug in splitting an SKB during SACK
processing. Specifically if an skb contains multiple
packets and is only partially sacked in the higher sequences,
tcp_match_sack_to_skb() splits the skb and marks the second fragment
as SACKed.

The current code further attempts rounding up the first fragment
to MSS boundaries. But it misses a boundary condition when the
rounded-up fragment size (pkt_len) is exactly skb size.  Spliting
such an skb is pointless and causses a kernel warning and aborts
the SACK processing. This patch universally checks such over-split
before calling tcp_fragment to prevent these unnecessary warnings.

Fixes: adb92db857ee ("tcp: Make SACK code to split only at mss boundaries")
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_input.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5a3ad09e2786..06e2dbc2b4a2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1179,13 +1179,14 @@ static int tcp_match_skb_to_sack(struct sock *sk, struct sk_buff *skb,
 		 */
 		if (pkt_len > mss) {
 			unsigned int new_len = (pkt_len / mss) * mss;
-			if (!in_sack && new_len < pkt_len) {
+			if (!in_sack && new_len < pkt_len)
 				new_len += mss;
-				if (new_len >= skb->len)
-					return 0;
-			}
 			pkt_len = new_len;
 		}
+
+		if (pkt_len >= skb->len && !in_sack)
+			return 0;
+
 		err = tcp_fragment(sk, skb, pkt_len, mss, GFP_ATOMIC);
 		if (err < 0)
 			return err;
-- 
2.13.0.rc2.291.g57267f2277-goog
