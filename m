From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] rxrpc: rxrpc_kernel_send_data() needs to handle failed
 call better
Date: Thu, 09 Mar 2017 08:10:32 +0000
Message-ID: <148904703242.5036.16866085054034840990.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60924 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752976AbdCIIKp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 03:10:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If rxrpc_kernel_send_data() is asked to send data through a call that has
already failed (due to a remote abort, received protocol error or network
error), then return the associated error code saved in the call rather than
ESHUTDOWN.

This allows the caller to work out whether to ask for the abort code or not
based on this.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/sendmsg.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 47ccfeacc1c6..97ab214ca411 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -618,8 +618,9 @@ int rxrpc_kernel_send_data(struct socket *sock, struct rxrpc_call *call,
 		ret = rxrpc_send_data(rxrpc_sk(sock->sk), call, msg, len);
 		break;
 	case RXRPC_CALL_COMPLETE:
-		/* It's too late for this call */
-		ret = -ESHUTDOWN;
+		read_lock_bh(&call->state_lock);
+		ret = -call->error;
+		read_unlock_bh(&call->state_lock);
 		break;
 	default:
 		 /* Request phase complete for this client call */
