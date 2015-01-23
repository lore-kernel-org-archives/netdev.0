From: subashab@codeaurora.org
Subject: [PATCH] ping: Fix race in free in receive path
Date: Fri, 23 Jan 2015 22:26:02 -0000
Message-ID: <45fab13fce077924f957cba84ba20ba4.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:56261 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbbAWW0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 17:26:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An exception is seen in ICMP ping receive path where the skb
destructor sock_rfree() tries to access a freed socket. This happens
because ping_rcv() releases socket reference with sock_put() and this
internally frees up the socket. Later icmp_rcv() will try to free the
skb and as part of this, skb destructor is called and which leads
to a kernel panic as the socket is freed already in ping_rcv().

-->|exception
-007|sk_mem_uncharge
-007|sock_rfree
-008|skb_release_head_state
-009|skb_release_all
-009|__kfree_skb
-010|kfree_skb
-011|icmp_rcv
-012|ip_local_deliver_finish

Fix this incorrect free by cloning this skb and processing this cloned
skb instead.

This patch was suggested by Eric Dumazet

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ping.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index c0d82f7..2a3720f 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -966,8 +966,11 @@ bool ping_rcv(struct sk_buff *skb)

 	sk = ping_lookup(net, skb, ntohs(icmph->un.echo.id));
 	if (sk != NULL) {
+		struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
+
 		pr_debug("rcv on socket %p\n", sk);
-		ping_queue_rcv_skb(sk, skb_get(skb));
+		if (skb2)
+			ping_queue_rcv_skb(sk, skb2);
 		sock_put(sk);
 		return true;
 	}
-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project
