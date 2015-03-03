From: sfeldma@gmail.com
Subject: [PATCH net-next v3 6/7] fib: hook IPv4 fib for hardware offload
Date: Tue,  3 Mar 2015 15:31:59 -0800
Message-ID: <1425425520-34017-7-git-send-email-sfeldma@gmail.com>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:41191 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757714AbbCCXbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 18:31:04 -0500
Received: by pablj1 with SMTP id lj1so21967628pab.8
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 15:31:03 -0800 (PST)
In-Reply-To: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Call into the switchdev driver any time an IPv4 fib entry is
added/modified/deleted from the kernel's FIB.  The switchdev driver may or
may not install the route to the offload device.  In the case where the
driver tries to install the route and something goes wrong (device's routing
table is full, etc), then all of the offloaded routes will be flushed from the
device, and route forwarding falls back to the kernel.

We can refine this fail-over logic in subsequent patches.  For now, use the
simplist model of offloading routes up to the point of failure, and then on
failure, undo everything.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 net/ipv4/fib_trie.c |   36 +++++++++++++++++++++++++++++++++---
 1 file changed, 33 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 32c0117..668f09b 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -79,6 +79,7 @@
 #include <net/tcp.h>
 #include <net/sock.h>
 #include <net/ip_fib.h>
+#include <net/switchdev.h>
 #include "fib_lookup.h"
 
 #define MAX_STAT_DEPTH 32
@@ -1161,7 +1162,18 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
 			new_fa->fa_slen = fa->fa_slen;
 
+			err = netdev_switch_fib_ipv4_add(key, plen, fi,
+							 new_fa->fa_tos,
+							 cfg->fc_type,
+							 tb->tb_id);
+			if (err) {
+				fib_flush_external(fi->fib_net);
+				kmem_cache_free(fn_alias_kmem, new_fa);
+				goto out;
+			}
+
 			hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
+
 			alias_free_mem_rcu(fa);
 
 			fib_release_info(fi_drop);
@@ -1197,12 +1209,20 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_state = 0;
 	new_fa->fa_slen = slen;
 
+	/* (Optionally) offload fib entry to switch hardware. */
+	err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
+					 cfg->fc_type, tb->tb_id);
+	if (err) {
+		fib_flush_external(fi->fib_net);
+		goto out_free_new_fa;
+	}
+
 	/* Insert new entry to the list. */
 	if (!l) {
 		l = fib_insert_node(t, key, plen);
 		if (unlikely(!l)) {
 			err = -ENOMEM;
-			goto out_free_new_fa;
+			goto out_sw_fib_del;
 		}
 	}
 
@@ -1217,6 +1237,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 succeeded:
 	return 0;
 
+out_sw_fib_del:
+	netdev_switch_fib_ipv4_del(key, plen, fi, tos, cfg->fc_type, tb->tb_id);
 out_free_new_fa:
 	kmem_cache_free(fn_alias_kmem, new_fa);
 out:
@@ -1475,6 +1497,10 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 		return -ESRCH;
 
 	fa = fa_to_delete;
+
+	netdev_switch_fib_ipv4_del(key, plen, fa->fa_info, tos,
+				   cfg->fc_type, tb->tb_id);
+
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
@@ -1511,7 +1537,7 @@ static void trie_flush_leaf_external(struct fib_table *tb, struct tnode *l)
 	}
 }
 
-static int trie_flush_leaf(struct tnode *l)
+static int trie_flush_leaf(struct fib_table *tb, struct tnode *l)
 {
 	struct hlist_node *tmp;
 	unsigned char slen = 0;
@@ -1522,6 +1548,10 @@ static int trie_flush_leaf(struct tnode *l)
 		struct fib_info *fi = fa->fa_info;
 
 		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
+			netdev_switch_fib_ipv4_del(l->key,
+						   KEYLENGTH - fa->fa_slen,
+						   fi, fa->fa_tos,
+						   fa->fa_type, tb->tb_id);
 			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
@@ -1610,7 +1640,7 @@ int fib_table_flush(struct fib_table *tb)
 	int found = 0;
 
 	for (l = trie_firstleaf(t); l; l = trie_nextleaf(l)) {
-		found += trie_flush_leaf(l);
+		found += trie_flush_leaf(tb, l);
 
 		if (ll) {
 			if (hlist_empty(&ll->leaf))
-- 
1.7.10.4
