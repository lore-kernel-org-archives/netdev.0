From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 07/14] rxrpc: rxrpc_connection_lock shouldn't be a
 BH lock, but conn_lock is
Date: Wed, 22 Jun 2016 10:50:32 +0100
Message-ID: <146658903293.4550.1641939532002392976.stgit@warthog.procyon.org.uk>
References: <146658898230.4550.7226255613607733759.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146658898230.4550.7226255613607733759.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rxrpc_connection_lock shouldn't be accessed as a BH-excluding lock.  It's
only accessed in a few places and none of those are in BH-context.

rxrpc_transport::conn_lock, however, *is* a BH-excluding lock and should be
accessed so consistently.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_object.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 3b42fc4f4fe3..cab2f6dbc5a1 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -356,9 +356,9 @@ static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
 		return ret;
 	}
 
-	write_lock_bh(&rxrpc_connection_lock);
+	write_lock(&rxrpc_connection_lock);
 	list_add_tail(&conn->link, &rxrpc_connections);
-	write_unlock_bh(&rxrpc_connection_lock);
+	write_unlock(&rxrpc_connection_lock);
 
 	spin_lock(&trans->client_lock);
 	atomic_inc(&trans->usage);
@@ -677,9 +677,9 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans, struct sk_buff *skb)
 
 	write_unlock_bh(&trans->conn_lock);
 
-	write_lock_bh(&rxrpc_connection_lock);
+	write_lock(&rxrpc_connection_lock);
 	list_add_tail(&conn->link, &rxrpc_connections);
-	write_unlock_bh(&rxrpc_connection_lock);
+	write_unlock(&rxrpc_connection_lock);
 
 	new = "new";
 
@@ -828,7 +828,7 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 	now = ktime_get_seconds();
 	earliest = ULONG_MAX;
 
-	write_lock_bh(&rxrpc_connection_lock);
+	write_lock(&rxrpc_connection_lock);
 	list_for_each_entry_safe(conn, _p, &rxrpc_connections, link) {
 		_debug("reap CONN %d { u=%d,t=%ld }",
 		       conn->debug_id, atomic_read(&conn->usage),
@@ -838,7 +838,7 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 			continue;
 
 		spin_lock(&conn->trans->client_lock);
-		write_lock(&conn->trans->conn_lock);
+		write_lock_bh(&conn->trans->conn_lock);
 		reap_time = conn->put_time + rxrpc_connection_expiry;
 
 		if (atomic_read(&conn->usage) > 0) {
@@ -860,10 +860,10 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 			earliest = reap_time;
 		}
 
-		write_unlock(&conn->trans->conn_lock);
+		write_unlock_bh(&conn->trans->conn_lock);
 		spin_unlock(&conn->trans->client_lock);
 	}
-	write_unlock_bh(&rxrpc_connection_lock);
+	write_unlock(&rxrpc_connection_lock);
 
 	if (earliest != ULONG_MAX) {
 		_debug("reschedule reaper %ld", (long) earliest - now);
