From: sfeldma@gmail.com
Subject: [PATCH net-next v4 7/8] fib: hook IPv4 fib for hardware offload
Date: Thu,  5 Mar 2015 21:21:19 -0800
Message-ID: <1425619280-27492-8-git-send-email-sfeldma@gmail.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:41717 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116AbbCFFUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:20:47 -0500
Received: by pdjy10 with SMTP id y10so2501674pdj.8
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 21:20:46 -0800 (PST)
In-Reply-To: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Call into the switchdev driver any time an IPv4 fib entry is
added/modified/deleted from the kernel's FIB.  The switchdev driver may or
may not install the route to the offload device.  In the case where the
driver tries to install the route and something goes wrong (device's routing
table is full, etc), then all of the offloaded routes will be flushed from the
device, route forwarding falls back to the kernel, and no more routes are
offloading.

We can refine this logic later.  For now, use the simplist model of offloading
routes up to the point of failure, and then on failure, undo everything and
mark IPv4 offloading disabled.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |    5 +++++
 net/ipv4/fib_trie.c       |   31 ++++++++++++++++++++++++++++++-
 net/switchdev/switchdev.c |   28 ++++++++++++++++++++++++++--
 3 files changed, 61 insertions(+), 3 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 8d2ac66..dc0a5cc 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -55,6 +55,7 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			       u8 tos, u8 type, u32 tb_id);
 int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 			       u8 tos, u8 type, u32 tb_id);
+void netdev_switch_fib_ipv4_abort(struct fib_info *fi);
 
 #else
 
@@ -128,6 +129,10 @@ static inline int netdev_switch_fib_ipv4_del(u32 dst, int dst_len,
 	return 0;
 }
 
+void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
+{
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2de4395..6544f1a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -79,6 +79,7 @@
 #include <net/tcp.h>
 #include <net/sock.h>
 #include <net/ip_fib.h>
+#include <net/switchdev.h>
 #include "fib_lookup.h"
 
 #define MAX_STAT_DEPTH 32
@@ -1135,7 +1136,18 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
 			new_fa->fa_slen = fa->fa_slen;
 
+			err = netdev_switch_fib_ipv4_add(key, plen, fi,
+							 new_fa->fa_tos,
+							 cfg->fc_type,
+							 tb->tb_id);
+			if (err) {
+				netdev_switch_fib_ipv4_abort(fi);
+				kmem_cache_free(fn_alias_kmem, new_fa);
+				goto out;
+			}
+
 			hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
+
 			alias_free_mem_rcu(fa);
 
 			fib_release_info(fi_drop);
@@ -1171,10 +1183,18 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->fa_state = 0;
 	new_fa->fa_slen = slen;
 
+	/* (Optionally) offload fib entry to switch hardware. */
+	err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
+					 cfg->fc_type, tb->tb_id);
+	if (err) {
+		netdev_switch_fib_ipv4_abort(fi);
+		goto out_free_new_fa;
+	}
+
 	/* Insert new entry to the list. */
 	err = fib_insert_alias(t, tp, l, new_fa, fa, key);
 	if (err)
-		goto out_free_new_fa;
+		goto out_sw_fib_del;
 
 	if (!plen)
 		tb->tb_num_default++;
@@ -1185,6 +1205,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 succeeded:
 	return 0;
 
+out_sw_fib_del:
+	netdev_switch_fib_ipv4_del(key, plen, fi, tos, cfg->fc_type, tb->tb_id);
 out_free_new_fa:
 	kmem_cache_free(fn_alias_kmem, new_fa);
 out:
@@ -1456,6 +1478,9 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	if (!fa_to_delete)
 		return -ESRCH;
 
+	netdev_switch_fib_ipv4_del(key, plen, fa_to_delete->fa_info, tos,
+				   cfg->fc_type, tb->tb_id);
+
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
@@ -1650,6 +1675,10 @@ backtrace:
 		struct fib_info *fi = fa->fa_info;
 
 		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
+			netdev_switch_fib_ipv4_del(n->key,
+						   KEYLENGTH - fa->fa_slen,
+						   fi, fa->fa_tos,
+						   fa->fa_type, tb->tb_id);
 			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 99907d8..f4fd575 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -305,8 +305,12 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	const struct net_device_ops *ops;
 	int err = 0;
 
-	/* Don't offload route if using custom ip rules */
-	if (fi->fib_net->ipv4.fib_has_custom_rules)
+	/* Don't offload route if using custom ip rules or if
+	 * IPv4 FIB offloading has been disabled completely.
+	 */
+
+	if (fi->fib_net->ipv4.fib_has_custom_rules |
+	    fi->fib_net->ipv4.fib_offload_disabled)
 		return 0;
 
 	dev = netdev_switch_get_dev_by_nhs(fi);
@@ -362,3 +366,23 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	return err;
 }
 EXPORT_SYMBOL(netdev_switch_fib_ipv4_del);
+
+/**
+ *	netdev_switch_fib_ipv4_abort - Abort an IPv4 FIB operation
+ *
+ *	@fi: route FIB info structure
+ */
+void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
+{
+	/* There was a problem installing this route to the offload
+	 * device.  For now, until we come up with more refined
+	 * policy handling, abruptly end IPv4 fib offloading for
+	 * for entire net by flushing offload device(s) of all
+	 * IPv4 routes, and mark IPv4 fib offloading broken from
+	 * this point forward.
+	 */
+
+	fib_flush_external(fi->fib_net);
+	fi->fib_net->ipv4.fib_offload_disabled = true;
+}
+EXPORT_SYMBOL(netdev_switch_fib_ipv4_abort);
-- 
1.7.10.4
