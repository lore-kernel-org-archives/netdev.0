From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] rxrpc: Fix potential NULL-pointer exception
Date: Thu, 02 Mar 2017 23:48:52 +0000
Message-ID: <148849853282.19232.4377425862338633345.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47258 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751255AbdCBXu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Mar 2017 18:50:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a potential NULL-pointer exception in rxrpc_do_sendmsg().  The call
state check that I added should have gone into the else-body of the
if-statement where we actually have a call to check.

Found by CoverityScan CID#1414316 ("Dereference after null check").

Fixes: 540b1c48c37a ("rxrpc: Fix deadlock between call creation and sendmsg/recvmsg")
Reported-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/sendmsg.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 31c1538c1a8d..27685d8cba1a 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -517,13 +517,6 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		ret = -EBADSLT;
 		if (cmd != RXRPC_CMD_SEND_DATA)
 			goto error_release_sock;
-		ret = -EBUSY;
-		if (call->state == RXRPC_CALL_UNINITIALISED ||
-		    call->state == RXRPC_CALL_CLIENT_AWAIT_CONN ||
-		    call->state == RXRPC_CALL_SERVER_PREALLOC ||
-		    call->state == RXRPC_CALL_SERVER_SECURING ||
-		    call->state == RXRPC_CALL_SERVER_ACCEPTING)
-			goto error_release_sock;
 		call = rxrpc_new_client_call_for_sendmsg(rx, msg, user_call_ID,
 							 exclusive);
 		/* The socket is now unlocked... */
@@ -531,6 +524,14 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 			return PTR_ERR(call);
 		/* ... and we have the call lock. */
 	} else {
+		ret = -EBUSY;
+		if (call->state == RXRPC_CALL_UNINITIALISED ||
+		    call->state == RXRPC_CALL_CLIENT_AWAIT_CONN ||
+		    call->state == RXRPC_CALL_SERVER_PREALLOC ||
+		    call->state == RXRPC_CALL_SERVER_SECURING ||
+		    call->state == RXRPC_CALL_SERVER_ACCEPTING)
+			goto error_release_sock;
+
 		ret = mutex_lock_interruptible(&call->user_mutex);
 		release_sock(&rx->sk);
 		if (ret < 0) {
