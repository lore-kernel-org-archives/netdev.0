From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 2/3] tcp: allow segment with FIN in tcp_try_coalesce()
Date: Mon, 15 Sep 2014 04:19:52 -0700
Message-ID: <1410779993-31464-3-git-send-email-edumazet@google.com>
References: <1410779993-31464-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f74.google.com ([209.85.218.74]:54602 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753332AbaIOLUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 07:20:16 -0400
Received: by mail-oi0-f74.google.com with SMTP id e131so558543oig.1
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 04:20:15 -0700 (PDT)
In-Reply-To: <1410779993-31464-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can allow a segment with FIN to be aggregated,
if we take care to add tcp flags,
and if skb_try_coalesce() takes care of zero sized skbs.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c    | 3 ++-
 net/ipv4/tcp_input.c | 4 +---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c8259ac38745..29f7f0121491 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3936,7 +3936,8 @@ bool skb_try_coalesce(struct sk_buff *to, struct sk_buff *from,
 		return false;
 
 	if (len <= skb_tailroom(to)) {
-		BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
+		if (len)
+			BUG_ON(skb_copy_bits(from, 0, skb_put(to, len), len));
 		*delta_truesize = 0;
 		return true;
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 8f639a4face9..228bf0c5ff19 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4143,9 +4143,6 @@ static bool tcp_try_coalesce(struct sock *sk,
 
 	*fragstolen = false;
 
-	if (tcp_hdr(from)->fin)
-		return false;
-
 	/* Its possible this segment overlaps with prior segment in queue */
 	if (TCP_SKB_CB(from)->seq != TCP_SKB_CB(to)->end_seq)
 		return false;
@@ -4158,6 +4155,7 @@ static bool tcp_try_coalesce(struct sock *sk,
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPRCVCOALESCE);
 	TCP_SKB_CB(to)->end_seq = TCP_SKB_CB(from)->end_seq;
 	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;
+	TCP_SKB_CB(to)->tcp_flags |= TCP_SKB_CB(from)->tcp_flags;
 	return true;
 }
 
-- 
2.1.0.rc2.206.gedb03e5
