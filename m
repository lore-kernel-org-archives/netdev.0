From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH] dccp: fix freeing skb too early for IPV6_RECVPKTINFO
Date: Thu, 16 Feb 2017 17:22:46 +0100
Message-ID: <20170216162246.12783-1-andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
        Gerrit Renker <gerrit@erg.abdn.ac.uk>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34903 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932316AbdBPQXC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 11:23:02 -0500
Received: by mail-wm0-f49.google.com with SMTP id v186so70591861wmd.0
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 08:23:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current DCCP implementation an skb for a DCCP_PKT_REQUEST packet
is forcibly freed via __kfree_skb in dccp_rcv_state_process if
dccp_v6_conn_request successfully returns.

However, if IPV6_RECVPKTINFO is set on a socket, the address of the skb
is saved to ireq->pktopts and the ref count for skb is incremented in
dccp_v6_conn_request, so skb is still in use. Nevertheless, it gets freed
in dccp_rcv_state_process.

Fix by calling consume_skb instead of doing goto discard and therefore
calling __kfree_skb.

Similar fixes for TCP:

fb7e2399ec17f1004c0e0ccfd17439f8759ede01 [TCP]: skb is unexpectedly freed.
0aea76d35c9651d55bbaf746e7914e5f9ae5a25d tcp: SYN packets are now
simply consumed

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 net/dccp/input.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dccp/input.c b/net/dccp/input.c
index ba347184bda9..8fedc2d49770 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -606,7 +606,8 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			if (inet_csk(sk)->icsk_af_ops->conn_request(sk,
 								    skb) < 0)
 				return 1;
-			goto discard;
+			consume_skb(skb);
+			return 0;
 		}
 		if (dh->dccph_type == DCCP_PKT_RESET)
 			goto discard;
-- 
2.11.0.483.g087da7b7c-goog
