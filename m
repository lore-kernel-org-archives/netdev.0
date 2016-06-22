From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 01/14] rxrpc: checking for IS_ERR() instead of NULL
 [ver #2]
Date: Wed, 22 Jun 2016 17:02:58 +0100
Message-ID: <146661137885.15011.9259809291817631304.stgit@warthog.procyon.org.uk>
References: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org,
	Dan Carpenter <dan.carpenter@oracle.com>,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146661137134.15011.10133465789054712595.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>

rxrpc_lookup_peer_rcu() and rxrpc_lookup_peer() return NULL on error, never
error pointers, so IS_ERR() can't be used.

Fix three callers of those functions.

Fixes: be6e6707f6ee ('rxrpc: Rework peer object handling to use hash table and RCU')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c    |    4 ++--
 net/rxrpc/call_accept.c |    2 +-
 net/rxrpc/input.c       |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index c83c3c75d665..9dd160bb16d2 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -247,8 +247,8 @@ struct rxrpc_transport *rxrpc_name_to_transport(struct rxrpc_sock *rx,
 
 	/* find a remote transport endpoint from the local one */
 	peer = rxrpc_lookup_peer(rx->local, srx, gfp);
-	if (IS_ERR(peer))
-		return ERR_CAST(peer);
+	if (!peer)
+		return ERR_PTR(-ENOMEM);
 
 	/* find a transport */
 	trans = rxrpc_get_transport(rx->local, peer, gfp);
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 50136c76ebd1..553b67c144e5 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -96,7 +96,7 @@ static int rxrpc_accept_incoming_call(struct rxrpc_local *local,
 	notification->mark = RXRPC_SKB_MARK_NEW_CALL;
 
 	peer = rxrpc_lookup_peer(local, srx, GFP_NOIO);
-	if (IS_ERR(peer)) {
+	if (!peer) {
 		_debug("no peer");
 		ret = -EBUSY;
 		goto error;
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 47fb167af3e4..e11e4d785127 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -639,7 +639,7 @@ static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
 	rxrpc_get_addr_from_skb(local, skb, &srx);
 	rcu_read_lock();
 	peer = rxrpc_lookup_peer_rcu(local, &srx);
-	if (IS_ERR(peer))
+	if (!peer)
 		goto cant_find_peer;
 
 	trans = rxrpc_find_transport(local, peer);
