From: David Howells <dhowells@redhat.com>
Subject: [PATCH 05/11] rxrpc: procfs file to list local endpoints
Date: Mon, 07 Mar 2016 14:38:34 +0000
Message-ID: <20160307143834.18567.84577.stgit@warthog.procyon.org.uk>
References: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59675 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752904AbcCGOig (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2016 09:38:36 -0500
In-Reply-To: <20160307143759.18567.8234.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a proc file to list local rxrpc endpoints using the object cache
facility to do much of the work.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c     |    3 +++
 net/rxrpc/local-object.c |   29 +++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index a27d8e3ef854..23ebb127cac1 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -842,6 +842,8 @@ static int __init af_rxrpc_init(void)
 	proc_create("rxrpc_calls", 0, init_net.proc_net, &rxrpc_call_seq_fops);
 	proc_create("rxrpc_conns", 0, init_net.proc_net,
 		    &rxrpc_connection_seq_fops);
+	proc_create_data("rxrpc_locals", 0, init_net.proc_net,
+			 &objcache_seq_fops, &rxrpc_local_cache);
 #endif
 	return 0;
 
@@ -883,6 +885,7 @@ static void __exit af_rxrpc_exit(void)
 
 	_debug("flush scheduled work");
 	flush_workqueue(rxrpc_workqueue);
+	remove_proc_entry("rxrpc_locals", init_net.proc_net);
 	remove_proc_entry("rxrpc_conns", init_net.proc_net);
 	remove_proc_entry("rxrpc_calls", init_net.proc_net);
 	destroy_workqueue(rxrpc_workqueue);
diff --git a/net/rxrpc/local-object.c b/net/rxrpc/local-object.c
index 4f44e86e70fe..cc6354675026 100644
--- a/net/rxrpc/local-object.c
+++ b/net/rxrpc/local-object.c
@@ -19,6 +19,7 @@
 #include <net/af_rxrpc.h>
 #include "ar-internal.h"
 
+static int rxrpc_local_seq_show(struct seq_file *, void *);
 static void rxrpc_local_prepare_for_gc(struct obj_node *);
 static void rxrpc_local_gc_rcu(struct rcu_head *);
 static unsigned long rxrpc_local_hash_key(const void *);
@@ -29,6 +30,7 @@ static struct hlist_head rxrpc_local_cache_hash[16];
 
 struct objcache rxrpc_local_cache = {
 	.name		= "locals",
+	.seq_show	= rxrpc_local_seq_show,
 	.prepare_for_gc	= rxrpc_local_prepare_for_gc,
 	.gc_rcu		= rxrpc_local_gc_rcu,
 	.hash_key	= rxrpc_local_hash_key,
@@ -309,3 +311,30 @@ static void rxrpc_local_gc_rcu(struct rcu_head *rcu)
 	objcache_obj_rcu_done(&rxrpc_local_cache);
 	_leave("");
 }
+
+/*
+ * Display a local endpoint in /proc/net/rxrpc_locals.
+ */
+static int rxrpc_local_seq_show(struct seq_file *seq, void *v)
+{
+	struct rxrpc_local *local;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "Use Proto LPort Local\n");
+		return 0;
+	}
+
+	local = hlist_entry(v, struct rxrpc_local, obj.link);
+
+	switch (local->srx.transport.family) {
+	case AF_INET:
+		seq_printf(seq,
+			   "%3d UDP   %5hu %pI4\n",
+			   atomic_read(&local->obj.usage),
+			   ntohs(local->srx.transport.sin.sin_port),
+			   &local->srx.transport.sin.sin_addr);
+		break;
+	}
+
+	return 0;
+}
