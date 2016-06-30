From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 06/19] rxrpc: Check that the client conns cache is
 empty before module removal
Date: Thu, 30 Jun 2016 15:11:25 +0100
Message-ID: <146729588538.26306.13628963933419857885.stgit@warthog.procyon.org.uk>
References: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146729584148.26306.13038965408565743258.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check that the client conns cache is empty before module removal and bug if
not, listing any offending connections that are still present.  Unfortunately,
if there are connections still around, then the transport socket is still
unexpectedly open and active, so we can't just unallocate the connections.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c    |    3 +--
 net/rxrpc/ar-internal.h |    1 +
 net/rxrpc/conn_client.c |   19 +++++++++++++++++++
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 5d3e795a7c48..d5073eb02498 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -807,8 +807,7 @@ static void __exit af_rxrpc_exit(void)
 	_debug("synchronise RCU");
 	rcu_barrier();
 	_debug("destroy locals");
-	ASSERT(idr_is_empty(&rxrpc_client_conn_ids));
-	idr_destroy(&rxrpc_client_conn_ids);
+	rxrpc_destroy_client_conn_ids();
 	rxrpc_destroy_all_locals();
 
 	remove_proc_entry("rxrpc_conns", init_net.proc_net);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 6f62b0eef0e0..2a8710dac3c5 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -542,6 +542,7 @@ extern struct idr rxrpc_client_conn_ids;
 
 int rxrpc_get_client_connection_id(struct rxrpc_connection *, gfp_t);
 void rxrpc_put_client_connection_id(struct rxrpc_connection *);
+void rxrpc_destroy_client_conn_ids(void);
 
 /*
  * conn_event.c
diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index 82488d6adb83..be437d5e90ce 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -92,3 +92,22 @@ void rxrpc_put_client_connection_id(struct rxrpc_connection *conn)
 		spin_unlock(&rxrpc_conn_id_lock);
 	}
 }
+
+/*
+ * Destroy the client connection ID tree.
+ */
+void rxrpc_destroy_client_conn_ids(void)
+{
+	struct rxrpc_connection *conn;
+	int id;
+
+	if (!idr_is_empty(&rxrpc_client_conn_ids)) {
+		idr_for_each_entry(&rxrpc_client_conn_ids, conn, id) {
+			pr_err("AF_RXRPC: Leaked client conn %p {%d}\n",
+			       conn, atomic_read(&conn->usage));
+		}
+		BUG();
+	}
+
+	idr_destroy(&rxrpc_client_conn_ids);
+}
