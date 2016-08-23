From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/3] rxrpc: Set connection expiry on idle, not put
Date: Tue, 23 Aug 2016 16:29:01 +0100
Message-ID: <147196614120.28436.6884470678228833391.stgit@warthog.procyon.org.uk>
References: <147196613431.28436.14522158196410989643.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147196613431.28436.14522158196410989643.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set the connection expiry time when a connection becomes idle rather than
doing this in rxrpc_put_connection().  This makes the put path more
efficient (it is likely to be called occasionally whilst a connection has
outstanding calls because active workqueue items needs to be given a ref).

The time is also preset in the connection allocator in case the connection
never gets used.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   11 +++++++++--
 net/rxrpc/conn_object.c |   42 +++++++++++++++++-------------------------
 2 files changed, 26 insertions(+), 27 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 8cb517fbbd23..66c917077880 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -313,7 +313,7 @@ struct rxrpc_connection {
 	struct rxrpc_crypt	csum_iv;	/* packet checksum base */
 	unsigned long		flags;
 	unsigned long		events;
-	unsigned long		put_time;	/* Time at which last put */
+	unsigned long		idle_timestamp;	/* Time at which last became idle */
 	spinlock_t		state_lock;	/* state-change lock */
 	atomic_t		usage;
 	enum rxrpc_conn_proto_state state : 8;	/* current state of connection */
@@ -565,7 +565,7 @@ struct rxrpc_connection *rxrpc_find_connection_rcu(struct rxrpc_local *,
 						   struct sk_buff *);
 void __rxrpc_disconnect_call(struct rxrpc_call *);
 void rxrpc_disconnect_call(struct rxrpc_call *);
-void rxrpc_put_connection(struct rxrpc_connection *);
+void __rxrpc_put_connection(struct rxrpc_connection *);
 void __exit rxrpc_destroy_all_connections(void);
 
 static inline bool rxrpc_conn_is_client(const struct rxrpc_connection *conn)
@@ -589,6 +589,13 @@ struct rxrpc_connection *rxrpc_get_connection_maybe(struct rxrpc_connection *con
 	return atomic_inc_not_zero(&conn->usage) ? conn : NULL;
 }
 
+static inline void rxrpc_put_connection(struct rxrpc_connection *conn)
+{
+	if (conn && atomic_dec_return(&conn->usage) == 1)
+		__rxrpc_put_connection(conn);
+}
+
+
 static inline bool rxrpc_queue_conn(struct rxrpc_connection *conn)
 {
 	if (!rxrpc_get_connection_maybe(conn))
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index 6a5a17efc538..743f0bb4aaa8 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -56,6 +56,7 @@ struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 		atomic_set(&conn->avail_chans, RXRPC_MAXCALLS);
 		conn->size_align = 4;
 		conn->header_size = sizeof(struct rxrpc_wire_header);
+		conn->idle_timestamp = jiffies;
 	}
 
 	_leave(" = %p{%d}", conn, conn ? conn->debug_id : 0);
@@ -191,29 +192,16 @@ void rxrpc_disconnect_call(struct rxrpc_call *call)
 	spin_unlock(&conn->channel_lock);
 
 	call->conn = NULL;
+	conn->idle_timestamp = jiffies;
 	rxrpc_put_connection(conn);
 }
 
 /*
  * release a virtual connection
  */
-void rxrpc_put_connection(struct rxrpc_connection *conn)
+void __rxrpc_put_connection(struct rxrpc_connection *conn)
 {
-	if (!conn)
-		return;
-
-	_enter("%p{u=%d,d=%d}",
-	       conn, atomic_read(&conn->usage), conn->debug_id);
-
-	ASSERTCMP(atomic_read(&conn->usage), >, 1);
-
-	conn->put_time = ktime_get_seconds();
-	if (atomic_dec_return(&conn->usage) == 1) {
-		_debug("zombie");
-		rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
-	}
-
-	_leave("");
+	rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
 }
 
 /*
@@ -248,14 +236,14 @@ static void rxrpc_destroy_connection(struct rcu_head *rcu)
 static void rxrpc_connection_reaper(struct work_struct *work)
 {
 	struct rxrpc_connection *conn, *_p;
-	unsigned long reap_older_than, earliest, put_time, now;
+	unsigned long reap_older_than, earliest, idle_timestamp, now;
 
 	LIST_HEAD(graveyard);
 
 	_enter("");
 
-	now = ktime_get_seconds();
-	reap_older_than =  now - rxrpc_connection_expiry;
+	now = jiffies;
+	reap_older_than = now - rxrpc_connection_expiry * HZ;
 	earliest = ULONG_MAX;
 
 	write_lock(&rxrpc_connection_lock);
@@ -264,10 +252,14 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 		if (likely(atomic_read(&conn->usage) > 1))
 			continue;
 
-		put_time = READ_ONCE(conn->put_time);
-		if (time_after(put_time, reap_older_than)) {
-			if (time_before(put_time, earliest))
-				earliest = put_time;
+		idle_timestamp = READ_ONCE(conn->idle_timestamp);
+		_debug("reap CONN %d { u=%d,t=%ld }",
+		       conn->debug_id, atomic_read(&conn->usage),
+		       (long)reap_older_than - (long)idle_timestamp);
+
+		if (time_after(idle_timestamp, reap_older_than)) {
+			if (time_before(idle_timestamp, earliest))
+				earliest = idle_timestamp;
 			continue;
 		}
 
@@ -288,9 +280,9 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 
 	if (earliest != ULONG_MAX) {
 		_debug("reschedule reaper %ld", (long) earliest - now);
-		ASSERTCMP(earliest, >, now);
+		ASSERT(time_after(earliest, now));
 		rxrpc_queue_delayed_work(&rxrpc_connection_reap,
-					 (earliest - now) * HZ);
+					 earliest - now);
 	}
 
 	while (!list_empty(&graveyard)) {
