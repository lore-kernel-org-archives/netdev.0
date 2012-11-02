From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [RFC] net: netlink -- Allow netlink_dump to return error code if
 protocol handler is missed
Date: Fri, 2 Nov 2012 21:35:50 +0400
Message-ID: <20121102173550.GH10877@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:46391 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763227Ab2KBRgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 13:36:17 -0400
Received: by mail-lb0-f174.google.com with SMTP id n3so2784975lbo.19
        for <netdev@vger.kernel.org>; Fri, 02 Nov 2012 10:36:16 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've observed that in case if UDP diag module is not
supported in kernel the netlink returns NLMSG_DONE without
notifying a caller that handler is missed.

This patch makes netlink_dump to return error code instead.

So as example it become possible to detect such situation
and handle it gracefully on userspace level.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
CC: David Miller <davem@davemloft.net>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Pavel Emelyanov <xemul@parallels.com>
---
 net/ipv4/inet_diag.c     |    5 ++++-
 net/netlink/af_netlink.c |    4 ++++
 2 files changed, 8 insertions(+), 1 deletion(-)

Index: linux-2.6.git/net/ipv4/inet_diag.c
===================================================================
--- linux-2.6.git.orig/net/ipv4/inet_diag.c
+++ linux-2.6.git/net/ipv4/inet_diag.c
@@ -895,13 +895,16 @@ static int __inet_diag_dump(struct sk_bu
 		struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
 	const struct inet_diag_handler *handler;
+	int err = 0;
 
 	handler = inet_diag_lock_handler(r->sdiag_protocol);
 	if (!IS_ERR(handler))
 		handler->dump(skb, cb, r, bc);
+	else
+		err = PTR_ERR(handler);
 	inet_diag_unlock_handler(handler);
 
-	return skb->len;
+	return err ? : skb->len;
 }
 
 static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
Index: linux-2.6.git/net/netlink/af_netlink.c
===================================================================
--- linux-2.6.git.orig/net/netlink/af_netlink.c
+++ linux-2.6.git/net/netlink/af_netlink.c
@@ -1740,6 +1740,10 @@ static int netlink_dump(struct sock *sk)
 		else
 			__netlink_sendskb(sk, skb);
 		return 0;
+	} else if (len < 0) {
+		err = len;
+		nlk->cb = NULL;
+		goto errout_skb;
 	}
 
 	nlh = nlmsg_put_answer(skb, cb, NLMSG_DONE, sizeof(len), NLM_F_MULTI);
