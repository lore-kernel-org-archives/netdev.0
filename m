From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/9] rxrpc: The client call state must be changed
 before attachment to conn
Date: Sun, 04 Sep 2016 22:02:44 +0100
Message-ID: <147302296490.28597.9688307516968449225.stgit@warthog.procyon.org.uk>
References: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36034 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754577AbcIDVEV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 4 Sep 2016 17:04:21 -0400
In-Reply-To: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must set the client call state to RXRPC_CALL_CLIENT_SEND_REQUEST before
attaching the call to the connection struct, not after, as it's liable to
receive errors and conn aborts as soon as the assignment is made - and
these will cause its state to be changed outside of the initiating thread's
control.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_object.c |    2 --
 net/rxrpc/conn_client.c |    4 ++++
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/call_object.c b/net/rxrpc/call_object.c
index 57e00fc9cff2..65691742199b 100644
--- a/net/rxrpc/call_object.c
+++ b/net/rxrpc/call_object.c
@@ -197,8 +197,6 @@ static int rxrpc_begin_client_call(struct rxrpc_call *call,
 	if (ret < 0)
 		return ret;
 
-	call->state = RXRPC_CALL_CLIENT_SEND_REQUEST;
-
 	spin_lock(&call->conn->params.peer->lock);
 	hlist_add_head(&call->error_link, &call->conn->params.peer->error_targets);
 	spin_unlock(&call->conn->params.peer->lock);
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 4b213bc0f554..e19804dd6c8d 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -537,6 +537,10 @@ static void rxrpc_activate_one_channel(struct rxrpc_connection *conn,
 					     struct rxrpc_call, chan_wait_link);
 	u32 call_id = chan->call_counter + 1;
 
+	write_lock_bh(&call->state_lock);
+	call->state = RXRPC_CALL_CLIENT_SEND_REQUEST;
+	write_unlock_bh(&call->state_lock);
+
 	rxrpc_see_call(call);
 	list_del_init(&call->chan_wait_link);
 	conn->active_chans |= 1 << channel;
