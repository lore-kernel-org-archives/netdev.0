From: Colin Ian King <colin.king@canonical.com>
Subject: re: rxrpc: Fix deadlock between call creation and sendmsg/recvmsg
Date: Thu, 2 Mar 2017 13:33:46 +0000
Message-ID: <383d28fd-9a64-77ac-b8c0-f23408afc0ce@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Howells <dhowells@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I think the following part of the patch is problematic:

        call = rxrpc_find_call_by_user_ID(rx, user_call_ID);
        if (!call) {
+               ret = -EBADSLT;
                if (cmd != RXRPC_CMD_SEND_DATA)
-                       return -EBADSLT;
+                       goto error_release_sock;
+               ret = -EBUSY;

At this point call is null, so the following code is performing a null
pointer dereference on call when accessing call->state.

Detected by CoverityScan CID#1414316 ("Dereference after null check")

+               if (call->state == RXRPC_CALL_UNINITIALISED ||
+                   call->state == RXRPC_CALL_CLIENT_AWAIT_CONN ||
+                   call->state == RXRPC_CALL_SERVER_PREALLOC ||
+                   call->state == RXRPC_CALL_SERVER_SECURING ||
+                   call->state == RXRPC_CALL_SERVER_ACCEPTING)
+                       goto error_release_sock;
                call = rxrpc_new_client_call_for_sendmsg(rx, msg,
user_call_ID,
