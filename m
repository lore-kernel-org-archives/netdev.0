From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/2] rxrpc: Dup the main conn list for the proc
 interface
Date: Wed, 24 Aug 2016 16:04:14 +0100
Message-ID: <147205105430.13653.170335638058242639.stgit@warthog.procyon.org.uk>
References: <147205104744.13653.18154187942560167277.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147205104744.13653.18154187942560167277.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The main connection list is used for two independent purposes: primarily it
is used to find connections to reap and secondarily it is used to list
connections in procfs.

Split the procfs list out from the reap list.  This allows us to stop using
the reap list for client connections when they acquire a separate
management strategy from service collections.

The client connections will not be on a management single list, and sometimes
won't be on a management list at all.  This doesn't leave them floating,
however, as they will also be on an rb-tree rooted on the socket so that the
socket can find them to dispatch calls.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h  |    2 ++
 net/rxrpc/conn_client.c  |    1 +
 net/rxrpc/conn_object.c  |    3 +++
 net/rxrpc/conn_service.c |    1 +
 net/rxrpc/proc.c         |    8 ++++----
 5 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 5292bf0bce52..2efbfba87cbe 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -310,6 +310,7 @@ struct rxrpc_connection {
 		struct rb_node	client_node;	/* Node in local->client_conns */
 		struct rb_node	service_node;	/* Node in peer->service_conns */
 	};
+	struct list_head	proc_link;	/* link in procfs list */
 	struct list_head	link;		/* link in master connection list */
 	struct sk_buff_head	rx_queue;	/* received conn-level packets */
 	const struct rxrpc_security *security;	/* applied security module */
@@ -564,6 +565,7 @@ void rxrpc_reject_packets(struct rxrpc_local *);
  */
 extern unsigned int rxrpc_connection_expiry;
 extern struct list_head rxrpc_connections;
+extern struct list_head rxrpc_connection_proc_list;
 extern rwlock_t rxrpc_connection_lock;
 
 int rxrpc_extract_addr_from_skb(struct sockaddr_rxrpc *, struct sk_buff *);
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 2d43c99e5360..6e1099ed1dbd 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -149,6 +149,7 @@ rxrpc_alloc_client_connection(struct rxrpc_conn_parameters *cp, gfp_t gfp)
 
 	write_lock(&rxrpc_connection_lock);
 	list_add_tail(&conn->link, &rxrpc_connections);
+	list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
 	write_unlock(&rxrpc_connection_lock);
 
 	/* We steal the caller's peer ref. */
diff --git a/net/rxrpc/conn_object.c b/net/rxrpc/conn_object.c
index b4af37ebb112..afc2d83d5995 100644
--- a/net/rxrpc/conn_object.c
+++ b/net/rxrpc/conn_object.c
@@ -27,6 +27,7 @@ unsigned int rxrpc_connection_expiry = 10 * 60;
 static void rxrpc_connection_reaper(struct work_struct *work);
 
 LIST_HEAD(rxrpc_connections);
+LIST_HEAD(rxrpc_connection_proc_list);
 DEFINE_RWLOCK(rxrpc_connection_lock);
 static DECLARE_DELAYED_WORK(rxrpc_connection_reap, rxrpc_connection_reaper);
 
@@ -44,6 +45,7 @@ struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 		spin_lock_init(&conn->channel_lock);
 		init_waitqueue_head(&conn->channel_wq);
 		INIT_WORK(&conn->processor, &rxrpc_process_connection);
+		INIT_LIST_HEAD(&conn->proc_link);
 		INIT_LIST_HEAD(&conn->link);
 		skb_queue_head_init(&conn->rx_queue);
 		conn->security = &rxrpc_no_security;
@@ -283,6 +285,7 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 			rxrpc_unpublish_service_conn(conn);
 
 		list_move_tail(&conn->link, &graveyard);
+		list_del_init(&conn->proc_link);
 	}
 	write_unlock(&rxrpc_connection_lock);
 
diff --git a/net/rxrpc/conn_service.c b/net/rxrpc/conn_service.c
index fd9027ccba8f..6ad6ae926cc3 100644
--- a/net/rxrpc/conn_service.c
+++ b/net/rxrpc/conn_service.c
@@ -187,6 +187,7 @@ struct rxrpc_connection *rxrpc_incoming_connection(struct rxrpc_local *local,
 
 	write_lock(&rxrpc_connection_lock);
 	list_add_tail(&conn->link, &rxrpc_connections);
+	list_add_tail(&conn->proc_link, &rxrpc_connection_proc_list);
 	write_unlock(&rxrpc_connection_lock);
 
 	/* Make the connection a target for incoming packets. */
diff --git a/net/rxrpc/proc.c b/net/rxrpc/proc.c
index 53872631a66d..060fb4892c39 100644
--- a/net/rxrpc/proc.c
+++ b/net/rxrpc/proc.c
@@ -126,13 +126,13 @@ const struct file_operations rxrpc_call_seq_fops = {
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
@@ -145,7 +145,7 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 	struct rxrpc_connection *conn;
 	char lbuff[4 + 4 + 4 + 4 + 5 + 1], rbuff[4 + 4 + 4 + 4 + 5 + 1];
 
-	if (v == &rxrpc_connections) {
+	if (v == &rxrpc_connection_proc_list) {
 		seq_puts(seq,
 			 "Proto Local                  Remote                "
 			 " SvID ConnID   End Use State    Key     "
@@ -154,7 +154,7 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 		return 0;
 	}
 
-	conn = list_entry(v, struct rxrpc_connection, link);
+	conn = list_entry(v, struct rxrpc_connection, proc_link);
 
 	sprintf(lbuff, "%pI4:%u",
 		&conn->params.local->srx.transport.sin.sin_addr,
