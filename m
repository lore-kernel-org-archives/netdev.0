From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] rxrpc: Fix potential NULL-pointer exception
Date: Thu, 02 Mar 2017 23:26:13 +0000
Message-ID: <148849717388.26285.3477243497908119377.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60192 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751150AbdCBXu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
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
index 75c5179227f2..344c2a60627b 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -518,6 +518,13 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		ret = -EBADSLT;
 		if (cmd != RXRPC_CMD_SEND_DATA)
 			goto error_release_sock;
+		call = rxrpc_new_client_call_for_sendmsg(rx, msg, user_call_ID,
+							 exclusive);
+		/* The socket is now unlocked... */
+		if (IS_ERR(call))
+			return PTR_ERR(call);
+		/* ... and we have the call lock. */
+	} else {
 		switch (READ_ONCE(call->state)) {
 		case RXRPC_CALL_UNINITIALISED:
 		case RXRPC_CALL_CLIENT_AWAIT_CONN:
@@ -529,13 +536,7 @@ int rxrpc_do_sendmsg(struct rxrpc_sock *rx, struct msghdr *msg, size_t len)
 		default:
 			break;
 		}
-		call = rxrpc_new_client_call_for_sendmsg(rx, msg, user_call_ID,
-							 exclusive);
-		/* The socket is now unlocked... */
-		if (IS_ERR(call))
-			return PTR_ERR(call);
-		/* ... and we have the call lock. */
-	} else {
+
 		ret = mutex_lock_interruptible(&call->user_mutex);
 		release_sock(&rx->sk);
 		if (ret < 0) {
