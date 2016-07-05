From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 06/24] rxrpc: Dup the main conn list for the proc
 interface
Date: Tue, 05 Jul 2016 14:12:54 +0100
Message-ID: <146772437424.21657.5653571141789810019.stgit@warthog.procyon.org.uk>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58976 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754924AbcGENM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2016 09:12:56 -0400
In-Reply-To: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The main connection list is used for two independent purposes: primarily it
is used to find connections to reap and secondarily it is used to list
connections in procfs.

Split the procfs list out from the reap list.  This allows the reap list to
be phased out in stages as the client conns and service conns acquire their
own separate connection management strategies.

Whilst we're at it, use the address information stored in conn->proto when
displaying through procfs rather than accessing the peer record.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    3 ++-
 net/rxrpc/conn_object.c |   12 +++++++++++-
 net/rxrpc/proc.c        |   14 ++++++--------
 3 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 45aef3ef7609..f2b1c6dd5e9a 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -271,6 +271,7 @@ struct rxrpc_connection {
 		struct rb_node	client_node;	/* Node in local->client_conns */
 		struct rb_node	service_node;	/* Node in peer->service_conns */
 	};
+	struct list_head	proc_link;	/* link in procfs list */
 	struct list_head	link;		/* link in master connection list */
 	struct rb_root		calls;		/* calls on this connection */
 	struct sk_buff_head	rx_queue;	/* received conn-level packets */
@@ -535,7 +536,7 @@ void rxrpc_reject_packets(struct rxrpc_local *);
  * conn_object.c
  */
 extern unsigned int rxrpc_connection_expiry;
-extern struct list_head rxrpc_connections;
+extern struct list_head rxrpc_connection_proc_list;
 extern rwlock_t rxrpc_connection_lock;
 
 int rxrpc_connect_call(struct rxrpc_call *, struct rxrpc_conn_parameters *,
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index c2c0926af546..b54e2be0a0b1 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -27,7 +27,8 @@ unsigned int rxrpc_connection_expiry = 10 * 60;
 
 static void rxrpc_connection_reaper(struct work_struct *work);
 
-LIST_HEAD(rxrpc_connections);
+static LIST_HEAD(rxrpc_connections);
+LIST_HEAD(rxrpc_connection_proc_list);
 DEFINE_RWLOCK(rxrpc_connection_lock);
 static DECLARE_DELAYED_WORK(rxrpc_connection_reap, rxrpc_connection_reaper);
 
@@ -45,6 +46,7 @@ static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 		spin_lock_init(&conn->channel_lock);
 		init_waitqueue_head(&conn->channel_wq);
 		INIT_WORK(&conn->processor, &rxrpc_process_connection);
+		INIT_LIST_HEAD(&conn->proc_link);
 		INIT_LIST_HEAD(&conn->link);
 		conn->calls = RB_ROOT;
 		skb_queue_head_init(&conn->rx_queue);
@@ -144,6 +146,7 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 
 	write_lock(&rxrpc_connection_lock);
 	list_add_tail(&conn->link, &rxrpc_connections);
+	list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
 	write_unlock(&rxrpc_connection_lock);
 
 	/* We steal the caller's peer ref. */
@@ -601,6 +604,7 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 	struct rxrpc_connection *conn, *_p;
 	struct rxrpc_peer *peer;
 	unsigned long now, earliest, reap_time;
+	bool remove;
 
 	LIST_HEAD(graveyard);
 
@@ -618,6 +622,7 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 		if (likely(atomic_read(&conn->usage) > 0))
 			continue;
 
+		remove = false;
 		if (rxrpc_conn_is_client(conn)) {
 			struct rxrpc_local *local = conn->params.local;
 			spin_lock(&local->client_conns_lock);
@@ -630,6 +635,7 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 				rxrpc_put_client_connection_id(conn);
 				rb_erase(&conn->client_node,
 					 &local->client_conns);
+				remove = true;
 			} else if (reap_time < earliest) {
 				earliest = reap_time;
 			}
@@ -646,12 +652,16 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 				list_move_tail(&conn->link, &graveyard);
 				rb_erase(&conn->service_node,
 					 &peer->service_conns);
+				remove = true;
 			} else if (reap_time < earliest) {
 				earliest = reap_time;
 			}
 
 			write_unlock_bh(&peer->conn_lock);
 		}
+
+		if (remove)
+			list_del_init(&conn->proc_link);
 	}
 	write_unlock(&rxrpc_connection_lock);
 
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index 500cdcdc843c..afb5e1bc1b6e 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -67,8 +67,7 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 	conn = call->conn;
 	if (conn)
 		sprintf(rbuff, "%pI4:%u",
-			&conn->params.peer->srx.transport.sin.sin_addr,
-			ntohs(conn->params.peer->srx.transport.sin.sin_port));
+			&conn->proto.ipv4_addr, ntohs(conn->proto.port));
 	else
 		strcpy(rbuff, "no_connection");
 
@@ -115,13 +114,13 @@ const struct file_operations rxrpc_call_seq_fops = {
 static void *rxrpc_connection_seq_start(struct seq_file *seq, loff_t *_pos)
 {
 	read_lock(&rxrpc_connection_lock);
-	return seq_list_start_head(&rxrpc_connections, *_pos);
+	return seq_list_start_head(&rxrpc_connection_proc_list, *_pos);
 }
 
 static void *rxrpc_connection_seq_next(struct seq_file *seq, void *v,
 				       loff_t *pos)
 {
-	return seq_list_next(v, &rxrpc_connections, pos);
+	return seq_list_next(v, &rxrpc_connection_proc_list, pos);
 }
 
 static void rxrpc_connection_seq_stop(struct seq_file *seq, void *v)
@@ -134,7 +133,7 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 	struct rxrpc_connection *conn;
 	char lbuff[4 + 4 + 4 + 4 + 5 + 1], rbuff[4 + 4 + 4 + 4 + 5 + 1];
 
-	if (v == &rxrpc_connections) {
+	if (v == &rxrpc_connection_proc_list) {
 		seq_puts(seq,
 			 "Proto Local                  Remote                "
 			 " SvID ConnID   Calls    End Use State    Key     "
@@ -143,15 +142,14 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 		return 0;
 	}
 
-	conn = list_entry(v, struct rxrpc_connection, link);
+	conn = list_entry(v, struct rxrpc_connection, proc_link);
 
 	sprintf(lbuff, "%pI4:%u",
 		&conn->params.local->srx.transport.sin.sin_addr,
 		ntohs(conn->params.local->srx.transport.sin.sin_port));
 
 	sprintf(rbuff, "%pI4:%u",
-		&conn->params.peer->srx.transport.sin.sin_addr,
-		ntohs(conn->params.peer->srx.transport.sin.sin_port));
+		&conn->proto.ipv4_addr, ntohs(conn->proto.port));
 
 	seq_printf(seq,
 		   "UDP   %-22.22s %-22.22s %4x %08x %08x %s %3u"
