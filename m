From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/6] rxrpc: When activating client conn channels,
 do state check inside lock
Date: Thu, 29 Sep 2016 23:15:48 +0100
Message-ID: <147518734848.29235.10081904206033928537.stgit@warthog.procyon.org.uk>
References: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48410 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934927AbcI2WPv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Sep 2016 18:15:51 -0400
In-Reply-To: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rxrpc_activate_channels(), the connection cache state is checked outside
of the lock, which means it can change whilst we're waking calls up,
thereby changing whether or not we're allowed to wake calls up.

Fix this by moving the check inside the locked region.  The check to see if
all the channels are currently busy can stay outside of the locked region.

Whilst we're at it:

 (1) Split the locked section out into its own function so that we can call
     it from other places in a later patch.

 (2) Determine the mask of channels dependent on the state as we're going
     to add another state in a later patch that will restrict the number of
     simultaneous calls to 1 on a connection.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_client.c |   36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index f5ee8bfa5bef..60ef9605167e 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -576,28 +576,42 @@ static void rxrpc_activate_one_channel(struct rxrpc_connection *conn,
 }
 
 /*
+ * Assign channels and callNumbers to waiting calls with channel_lock
+ * held by caller.
+ */
+static void rxrpc_activate_channels_locked(struct rxrpc_connection *conn)
+{
+	u8 avail, mask;
+
+	switch (conn->cache_state) {
+	case RXRPC_CONN_CLIENT_ACTIVE:
+		mask = RXRPC_ACTIVE_CHANS_MASK;
+		break;
+	default:
+		return;
+	}
+
+	while (!list_empty(&conn->waiting_calls) &&
+	       (avail = ~conn->active_chans,
+		avail &= mask,
+		avail != 0))
+		rxrpc_activate_one_channel(conn, __ffs(avail));
+}
+
+/*
  * Assign channels and callNumbers to waiting calls.
  */
 static void rxrpc_activate_channels(struct rxrpc_connection *conn)
 {
-	unsigned char mask;
-
 	_enter("%d", conn->debug_id);
 
 	trace_rxrpc_client(conn, -1, rxrpc_client_activate_chans);
 
-	if (conn->cache_state != RXRPC_CONN_CLIENT_ACTIVE ||
-	    conn->active_chans == RXRPC_ACTIVE_CHANS_MASK)
+	if (conn->active_chans == RXRPC_ACTIVE_CHANS_MASK)
 		return;
 
 	spin_lock(&conn->channel_lock);
-
-	while (!list_empty(&conn->waiting_calls) &&
-	       (mask = ~conn->active_chans,
-		mask &= RXRPC_ACTIVE_CHANS_MASK,
-		mask != 0))
-		rxrpc_activate_one_channel(conn, __ffs(mask));
-
+	rxrpc_activate_channels_locked(conn);
 	spin_unlock(&conn->channel_lock);
 	_leave("");
 }
