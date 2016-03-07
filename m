From: David Howells <dhowells@redhat.com>
Subject: [PATCH 09/11] rxrpc: Add /proc/net/rxrpc_peers to display the known
 remote endpoints
Date: Mon, 07 Mar 2016 14:39:02 +0000
Message-ID: <20160307143902.18567.80508.stgit@warthog.procyon.org.uk>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add /proc/net/rxrpc_peers to display the remote endpoint records that are
resident in the peer cache.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c    |    3 +++
 net/rxrpc/peer-object.c |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 5f0ffb5f8306..b1849c4e3fd3 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -845,6 +845,8 @@ static int __init af_rxrpc_init(void)
 		    &rxrpc_connection_seq_fops);
 	proc_create_data("rxrpc_locals", 0, init_net.proc_net,
 			 &objcache_seq_fops, &rxrpc_local_cache);
+	proc_create_data("rxrpc_peers", 0, init_net.proc_net,
+			 &objcache_seq_fops, &rxrpc_peer_cache);
 #endif
 	return 0;
 
@@ -887,6 +889,7 @@ static void __exit af_rxrpc_exit(void)
 
 	_debug("flush scheduled work");
 	flush_workqueue(rxrpc_workqueue);
+	remove_proc_entry("rxrpc_peers", init_net.proc_net);
 	remove_proc_entry("rxrpc_locals", init_net.proc_net);
 	remove_proc_entry("rxrpc_conns", init_net.proc_net);
 	remove_proc_entry("rxrpc_calls", init_net.proc_net);
diff --git a/net/rxrpc/peer-object.c b/net/rxrpc/peer-object.c
index 35157c659bf7..2dd8c241302d 100644
--- a/net/rxrpc/peer-object.c
+++ b/net/rxrpc/peer-object.c
@@ -21,6 +21,7 @@
 #include <net/route.h>
 #include "ar-internal.h"
 
+static int rxrpc_peer_seq_show(struct seq_file *, void *);
 static unsigned long rxrpc_peer_hash_key(const void *);
 static int rxrpc_peer_cmp_key(const struct obj_node *, const void *);
 static void rxrpc_peer_gc_rcu(struct rcu_head *);
@@ -29,6 +30,7 @@ static struct hlist_head rxrpc_peer_cache_hash[256];
 
 struct objcache rxrpc_peer_cache = {
 	.name		= "peers",
+	.seq_show	= rxrpc_peer_seq_show,
 	.gc_rcu		= rxrpc_peer_gc_rcu,
 	.hash_key	= rxrpc_peer_hash_key,
 	.cmp_key	= rxrpc_peer_cmp_key,
@@ -261,3 +263,33 @@ struct rxrpc_peer *rxrpc_lookup_peer(struct sockaddr_rxrpc *srx, gfp_t gfp)
 	_leave(" = %p {u=%d}", peer, usage);
 	return peer;
 }
+
+/*
+ * Display a remote endpoint in /proc/net/rxrpc_peers.
+ */
+static int rxrpc_peer_seq_show(struct seq_file *seq, void *v)
+{
+	struct rxrpc_peer *peer;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "Use SvID Proto MTU   RTT   RPort Remote\n");
+		return 0;
+	}
+
+	peer = hlist_entry(v, struct rxrpc_peer, obj.link);
+
+	switch (peer->srx.transport.family) {
+	case AF_INET:
+		seq_printf(seq,
+			   "%3d %4x UDP   %5u %5lu %5hu %pI4\n",
+			   atomic_read(&peer->obj.usage),
+			   peer->srx.srx_service,
+			   peer->mtu,
+			   peer->rtt,
+			   ntohs(peer->srx.transport.sin.sin_port),
+			   &peer->srx.transport.sin.sin_addr);
+		break;
+	}
+
+	return 0;
+}
