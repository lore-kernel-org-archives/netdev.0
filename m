From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] RxRPC: use copy_to_user() instead of memcpy()
Date: Mon, 18 Mar 2013 13:55:03 +0300
Message-ID: <20130318105503.GA17102@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37956 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879Ab3CRK4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 06:56:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a user pointer.  Changing the memcpy() to copy_to_user()
fixes a hang on my system.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I'm not very familiar with this code, so please review this
carefully.

diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index 4b48687..428501f 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -143,10 +143,15 @@ int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		/* copy the peer address and timestamp */
 		if (!continue_call) {
-			if (msg->msg_name && msg->msg_namelen > 0)
-				memcpy(msg->msg_name,
-				       &call->conn->trans->peer->srx,
-				       sizeof(call->conn->trans->peer->srx));
+			if (msg->msg_name && msg->msg_namelen > 0) {
+				ret = copy_to_user((void __user *)msg->msg_name,
+					&call->conn->trans->peer->srx,
+					sizeof(call->conn->trans->peer->srx));
+				if (ret) {
+					ret = -EFAULT;
+					goto copy_error;
+				}
+			}
 			sock_recv_ts_and_drops(msg, &rx->sk, skb);
 		}
 
