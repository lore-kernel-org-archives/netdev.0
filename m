From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 07/14] rxrpc: Fix the putting of client connections
Date: Sun, 18 Sep 2016 00:18:33 +0100
Message-ID: <147415431330.17897.9485510346492293460.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53116 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935781AbcIQXSf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:18:35 -0400
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rxrpc_put_one_client_conn(), if a connection has RXRPC_CONN_COUNTED set
on it, then it's accounted for in rxrpc_nr_client_conns and may be on
various lists - and this is cleaned up correctly.

However, if the connection doesn't have RXRPC_CONN_COUNTED set on it, then
the put routine returns rather than just skipping the extra bit of cleanup.

Fix this by making the extra bit of clean up conditional instead and always
killing off the connection.

This manifests itself as connections with a zero usage count hanging around
in /proc/net/rxrpc_conns because the connection allocated, but discarded,
due to a race with another process that set up a parallel connection, which
was then shared instead.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_client.c |   28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 9344a8416ceb..5a675c43cace 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -818,7 +818,7 @@ idle_connection:
 static struct rxrpc_connection *
 rxrpc_put_one_client_conn(struct rxrpc_connection *conn)
 {
-	struct rxrpc_connection *next;
+	struct rxrpc_connection *next = NULL;
 	struct rxrpc_local *local = conn->params.local;
 	unsigned int nr_conns;
 
@@ -834,24 +834,22 @@ rxrpc_put_one_client_conn(struct rxrpc_connection *conn)
 
 	ASSERTCMP(conn->cache_state, ==, RXRPC_CONN_CLIENT_INACTIVE);
 
-	if (!test_bit(RXRPC_CONN_COUNTED, &conn->flags))
-		return NULL;
-
-	spin_lock(&rxrpc_client_conn_cache_lock);
-	nr_conns = --rxrpc_nr_client_conns;
+	if (test_bit(RXRPC_CONN_COUNTED, &conn->flags)) {
+		spin_lock(&rxrpc_client_conn_cache_lock);
+		nr_conns = --rxrpc_nr_client_conns;
+
+		if (nr_conns < rxrpc_max_client_connections &&
+		    !list_empty(&rxrpc_waiting_client_conns)) {
+			next = list_entry(rxrpc_waiting_client_conns.next,
+					  struct rxrpc_connection, cache_link);
+			rxrpc_get_connection(next);
+			rxrpc_activate_conn(next);
+		}
 
-	next = NULL;
-	if (nr_conns < rxrpc_max_client_connections &&
-	    !list_empty(&rxrpc_waiting_client_conns)) {
-		next = list_entry(rxrpc_waiting_client_conns.next,
-				  struct rxrpc_connection, cache_link);
-		rxrpc_get_connection(next);
-		rxrpc_activate_conn(next);
+		spin_unlock(&rxrpc_client_conn_cache_lock);
 	}
 
-	spin_unlock(&rxrpc_client_conn_cache_lock);
 	rxrpc_kill_connection(conn);
-
 	if (next)
 		rxrpc_activate_channels(next);
 
