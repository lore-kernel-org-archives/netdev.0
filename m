From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 1/2] fib: introduce fib notification infrastructure
Date: Tue,  6 Sep 2016 14:01:39 +0200
Message-ID: <1473163300-2045-2-git-send-email-jiri@resnulli.us>
References: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
        sfeldma@gmail.com, ast@plumgrid.com, edumazet@google.com,
        hannes@stressinduktion.org, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@intel.com,
        andrew@lunn.ch, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34864 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754722AbcIFMBt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 08:01:49 -0400
Received: by mail-wm0-f66.google.com with SMTP id a6so6889976wmc.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 05:01:48 -0700 (PDT)
In-Reply-To: <1473163300-2045-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This allows to pass information about added/deleted fib entries to
whoever is interested. This is done in a very similar way as devinet
notifies address additions/removals.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip_fib.h | 19 +++++++++++++++++++
 net/ipv4/fib_trie.c  | 43 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 4079fc1..9ad7ba9 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -22,6 +22,7 @@
 #include <net/fib_rules.h>
 #include <net/inetpeer.h>
 #include <linux/percpu.h>
+#include <linux/notifier.h>
 
 struct fib_config {
 	u8			fc_dst_len;
@@ -184,6 +185,24 @@ __be32 fib_info_update_nh_saddr(struct net *net, struct fib_nh *nh);
 #define FIB_RES_PREFSRC(net, res)	((res).fi->fib_prefsrc ? : \
 					 FIB_RES_SADDR(net, res))
 
+struct fib_notifier_info {
+	u32 dst;
+	int dst_len;
+	struct fib_info *fi;
+	u8 tos;
+	u8 type;
+	u32 tb_id;
+	u32 nlflags;
+};
+
+enum fib_event_type {
+	FIB_EVENT_TYPE_ADD,
+	FIB_EVENT_TYPE_DEL,
+};
+
+int register_fib_notifier(struct notifier_block *nb);
+int unregister_fib_notifier(struct notifier_block *nb);
+
 struct fib_table {
 	struct hlist_node	tb_hlist;
 	u32			tb_id;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index e2ffc2a..19ec471 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -73,6 +73,7 @@
 #include <linux/slab.h>
 #include <linux/export.h>
 #include <linux/vmalloc.h>
+#include <linux/notifier.h>
 #include <net/net_namespace.h>
 #include <net/ip.h>
 #include <net/protocol.h>
@@ -84,6 +85,36 @@
 #include <trace/events/fib.h>
 #include "fib_lookup.h"
 
+static BLOCKING_NOTIFIER_HEAD(fib_chain);
+
+int register_fib_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&fib_chain, nb);
+}
+EXPORT_SYMBOL(register_fib_notifier);
+
+int unregister_fib_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&fib_chain, nb);
+}
+EXPORT_SYMBOL(unregister_fib_notifier);
+
+static int call_fib_notifiers(enum fib_event_type event_type, u32 dst,
+			      int dst_len, struct fib_info *fi,
+			      u8 tos, u8 type, u32 tb_id, u32 nlflags)
+{
+	struct fib_notifier_info info = {
+		.dst = dst,
+		.dst_len = dst_len,
+		.fi = fi,
+		.tos = tos,
+		.type = type,
+		.tb_id = tb_id,
+		.nlflags = nlflags,
+	};
+	return blocking_notifier_call_chain(&fib_chain, event_type, &info);
+}
+
 #define MAX_STAT_DEPTH 32
 
 #define KEYLENGTH	(8*sizeof(t_key))
@@ -1190,6 +1221,10 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			fib_release_info(fi_drop);
 			if (state & FA_S_ACCESSED)
 				rt_cache_flush(cfg->fc_nlinfo.nl_net);
+
+			call_fib_notifiers(FIB_EVENT_TYPE_ADD, key, plen, fi,
+					   new_fa->fa_tos, cfg->fc_type,
+					   tb->tb_id, cfg->fc_nlflags);
 			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
 				tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
 
@@ -1241,6 +1276,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		tb->tb_num_default++;
 
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
+	call_fib_notifiers(FIB_EVENT_TYPE_ADD, key, plen, fi, tos,
+			   cfg->fc_type, tb->tb_id, cfg->fc_nlflags);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, new_fa->tb_id,
 		  &cfg->fc_nlinfo, nlflags);
 succeeded:
@@ -1542,6 +1579,8 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	switchdev_fib_ipv4_del(key, plen, fa_to_delete->fa_info, tos,
 			       cfg->fc_type, tb->tb_id);
 
+	call_fib_notifiers(FIB_EVENT_TYPE_DEL, key, plen, fa_to_delete->fa_info,
+			   tos, cfg->fc_type, tb->tb_id, 0);
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
@@ -1857,6 +1896,10 @@ int fib_table_flush(struct fib_table *tb)
 			switchdev_fib_ipv4_del(n->key, KEYLENGTH - fa->fa_slen,
 					       fi, fa->fa_tos, fa->fa_type,
 					       tb->tb_id);
+			call_fib_notifiers(FIB_EVENT_TYPE_DEL, n->key,
+					   KEYLENGTH - fa->fa_slen,
+					   fi, fa->fa_tos, fa->fa_type,
+					   tb->tb_id, 0);
 			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
-- 
2.5.5
