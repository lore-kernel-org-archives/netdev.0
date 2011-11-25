From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] l2tp: ensure sk->dst is still valid
Date: Fri, 25 Nov 2011 17:47:16 +0100
Message-ID: <1322239636-1839-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	James Chapman <jchapman@katalix.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:33974 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751072Ab1KYQp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 11:45:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using l2tp over ipsec, the tunnel will hang when rekeying
occurs. Reason is that the transformer bundle attached to the dst entry
is now in STATE_DEAD and thus xfrm_output_one() drops all packets
(XfrmOutStateExpired increases).

Fix this by calling __sk_dst_check (which drops the stale dst
if xfrm dst->check callback finds that the bundle is no longer valid).

Cc: James Chapman <jchapman@katalix.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/l2tp/l2tp_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index cf0f308..89ff8c6 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1072,7 +1072,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 
 	/* Get routing info from the tunnel socket */
 	skb_dst_drop(skb);
-	skb_dst_set(skb, dst_clone(__sk_dst_get(sk)));
+	skb_dst_set(skb, dst_clone(__sk_dst_check(sk, 0)));
 
 	inet = inet_sk(sk);
 	fl = &inet->cork.fl;
-- 
1.7.3.4
