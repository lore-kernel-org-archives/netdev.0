From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [PATCH] net: inet_diag -- Return error code if protocol handler is
 missed
Date: Sat, 3 Nov 2012 23:30:34 +0400
Message-ID: <20121103193034.GF6055@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:56968 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab2KCTaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:30:39 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so3289478lag.19
        for <netdev@vger.kernel.org>; Sat, 03 Nov 2012 12:30:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've observed that in case if UDP diag module is not
supported in kernel the netlink returns NLMSG_DONE without
notifying a caller that handler is missed.

This patch makes __inet_diag_dump to return error code instead.

So as example it become possible to detect such situation
and handle it gracefully on userspace level.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
CC: David Miller <davem@davemloft.net>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: Pavel Emelyanov <xemul@parallels.com>
---
 net/ipv4/inet_diag.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

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
