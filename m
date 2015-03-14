From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] bogus MSG_PEEK test in rxrpc_recvmsg()
Date: Sat, 14 Mar 2015 05:34:56 +0000
Message-ID: <20150314053456.GT29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49990 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbbCNFe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 01:34:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[I would really like an ACK on that one from dhowells; it appears to be
quite straightforward, but...]

MSG_PEEK isn't passed to ->recvmsg() via msg->msg_flags; as the matter of
fact, neither the kernel users of rxrpc, nor the syscalls ever set that bit
in there.  It gets passed via flags; in fact, another such check in the same
function is done correctly - as flags & MSG_PEEK.

It had been that way (effectively disabled) for 8 years, though, so the patch
needs beating up - that case had never been tested.  If it is correct, it's
-stable fodder.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index a4f883e..b92bede 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -87,7 +87,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 		if (!skb) {
 			/* nothing remains on the queue */
 			if (copied &&
-			    (msg->msg_flags & MSG_PEEK || timeo == 0))
+			    (flags & MSG_PEEK || timeo == 0))
 				goto out;
 
 			/* wait for a message to turn up */
