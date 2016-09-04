From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/9] rxrpc: Don't change the epoch
Date: Sun, 04 Sep 2016 22:02:58 +0100
Message-ID: <147302297842.28597.2212377699024442307.stgit@warthog.procyon.org.uk>
References: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems the local epoch should only be changed on boot, so remove the code
that changes it for client connections.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/conn_client.c |   32 ++++++++------------------------
 1 file changed, 8 insertions(+), 24 deletions(-)

diff --git a/net/rxrpc/conn_client.c b/net/rxrpc/conn_client.c
index e19804dd6c8d..82de1aeaef21 100644
--- a/net/rxrpc/conn_client.c
+++ b/net/rxrpc/conn_client.c
@@ -108,12 +108,12 @@ static DECLARE_DELAYED_WORK(rxrpc_client_conn_reap,
 /*
  * Get a connection ID and epoch for a client connection from the global pool.
  * The connection struct pointer is then recorded in the idr radix tree.  The
- * epoch is changed if this wraps.
+ * epoch doesn't change until the client is rebooted (or, at least, unless the
+ * module is unloaded).
  */
 static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 					  gfp_t gfp)
 {
-	u32 epoch;
 	int id;
 
 	_enter("");
@@ -121,34 +121,18 @@ static int rxrpc_get_client_connection_id(struct rxrpc_connection *conn,
 	idr_preload(gfp);
 	spin_lock(&rxrpc_conn_id_lock);
 
-	epoch = rxrpc_epoch;
-
-	/* We could use idr_alloc_cyclic() here, but we really need to know
-	 * when the thing wraps so that we can advance the epoch.
-	 */
-	if (rxrpc_client_conn_ids.cur == 0)
-		rxrpc_client_conn_ids.cur = 1;
-	id = idr_alloc(&rxrpc_client_conn_ids, conn,
-		       rxrpc_client_conn_ids.cur, 0x40000000, GFP_NOWAIT);
-	if (id < 0) {
-		if (id != -ENOSPC)
-			goto error;
-		id = idr_alloc(&rxrpc_client_conn_ids, conn,
-			       1, 0x40000000, GFP_NOWAIT);
-		if (id < 0)
-			goto error;
-		epoch++;
-		rxrpc_epoch = epoch;
-	}
-	rxrpc_client_conn_ids.cur = id + 1;
+	id = idr_alloc_cyclic(&rxrpc_client_conn_ids, conn,
+			      1, 0x40000000, GFP_NOWAIT);
+	if (id < 0)
+		goto error;
 
 	spin_unlock(&rxrpc_conn_id_lock);
 	idr_preload_end();
 
-	conn->proto.epoch = epoch;
+	conn->proto.epoch = rxrpc_epoch;
 	conn->proto.cid = id << RXRPC_CIDSHIFT;
 	set_bit(RXRPC_CONN_HAS_IDR, &conn->flags);
-	_leave(" [CID %x:%x]", epoch, conn->proto.cid);
+	_leave(" [CID %x]", conn->proto.cid);
 	return 0;
 
 error:
