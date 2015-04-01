From: sfeldma@gmail.com
Subject: [PATCH net-next v2 23/26] switchdev: rename netdev_switch_fib_* to swdev_fib_*
Date: Wed,  1 Apr 2015 03:07:59 -0700
Message-ID: <1427882882-2533-24-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34717 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbbDAKGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:54 -0400
Received: by pactp5 with SMTP id tp5so47808481pac.1
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:53 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

To be consistent with other swdev code, rename the L3 FIB ops with swdev_
prefix.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   23 ++++++++++-------------
 net/ipv4/fib_trie.c       |   38 ++++++++++++++++----------------------
 net/switchdev/switchdev.c |   34 +++++++++++++++++-----------------
 3 files changed, 43 insertions(+), 52 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d46809b..55f9347 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -123,11 +123,11 @@ int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
 				 struct netdev_switch_notifier_info *info);
-int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
-			       u8 tos, u8 type, u32 nlflags, u32 tb_id);
-int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
-			       u8 tos, u8 type, u32 tb_id);
-void netdev_switch_fib_ipv4_abort(struct fib_info *fi);
+int swdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
+		       u8 tos, u8 type, u32 nlflags, u32 tb_id);
+int swdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+		       u8 tos, u8 type, u32 tb_id);
+void swdev_fib_ipv4_abort(struct fib_info *fi);
 
 #else
 
@@ -190,22 +190,19 @@ static inline int call_netdev_switch_notifiers(unsigned long val, struct net_dev
 	return NOTIFY_DONE;
 }
 
-static inline int netdev_switch_fib_ipv4_add(u32 dst, int dst_len,
-					     struct fib_info *fi,
-					     u8 tos, u8 type,
-					     u32 nlflags, u32 tb_id)
+static inline int swdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
+				     u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
 	return 0;
 }
 
-static inline int netdev_switch_fib_ipv4_del(u32 dst, int dst_len,
-					     struct fib_info *fi,
-					     u8 tos, u8 type, u32 tb_id)
+static inline int swdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+				     u8 tos, u8 type, u32 tb_id)
 {
 	return 0;
 }
 
-static inline void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
+static inline void swdev_fib_ipv4_abort(struct fib_info *fi)
 {
 }
 
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 2c7c299..a452f38 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1165,13 +1165,11 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
 			new_fa->fa_slen = fa->fa_slen;
 
-			err = netdev_switch_fib_ipv4_add(key, plen, fi,
-							 new_fa->fa_tos,
-							 cfg->fc_type,
-							 cfg->fc_nlflags,
-							 tb->tb_id);
+			err = swdev_fib_ipv4_add(key, plen, fi, new_fa->fa_tos,
+						 cfg->fc_type, cfg->fc_nlflags,
+						 tb->tb_id);
 			if (err) {
-				netdev_switch_fib_ipv4_abort(fi);
+				swdev_fib_ipv4_abort(fi);
 				kmem_cache_free(fn_alias_kmem, new_fa);
 				goto out;
 			}
@@ -1215,12 +1213,10 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->tb_id = tb->tb_id;
 
 	/* (Optionally) offload fib entry to switch hardware. */
-	err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
-					 cfg->fc_type,
-					 cfg->fc_nlflags,
-					 tb->tb_id);
+	err = swdev_fib_ipv4_add(key, plen, fi, tos, cfg->fc_type,
+				 cfg->fc_nlflags, tb->tb_id);
 	if (err) {
-		netdev_switch_fib_ipv4_abort(fi);
+		swdev_fib_ipv4_abort(fi);
 		goto out_free_new_fa;
 	}
 
@@ -1239,7 +1235,7 @@ succeeded:
 	return 0;
 
 out_sw_fib_del:
-	netdev_switch_fib_ipv4_del(key, plen, fi, tos, cfg->fc_type, tb->tb_id);
+	swdev_fib_ipv4_del(key, plen, fi, tos, cfg->fc_type, tb->tb_id);
 out_free_new_fa:
 	kmem_cache_free(fn_alias_kmem, new_fa);
 out:
@@ -1517,8 +1513,8 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	if (!fa_to_delete)
 		return -ESRCH;
 
-	netdev_switch_fib_ipv4_del(key, plen, fa_to_delete->fa_info, tos,
-				   cfg->fc_type, tb->tb_id);
+	swdev_fib_ipv4_del(key, plen, fa_to_delete->fa_info, tos,
+			   cfg->fc_type, tb->tb_id);
 
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
@@ -1767,10 +1763,9 @@ void fib_table_flush_external(struct fib_table *tb)
 			if (!fi || !(fi->fib_flags & RTNH_F_EXTERNAL))
 				continue;
 
-			netdev_switch_fib_ipv4_del(n->key,
-						   KEYLENGTH - fa->fa_slen,
-						   fi, fa->fa_tos,
-						   fa->fa_type, tb->tb_id);
+			swdev_fib_ipv4_del(n->key, KEYLENGTH - fa->fa_slen,
+					   fi, fa->fa_tos, fa->fa_type,
+					   tb->tb_id);
 		}
 
 		/* update leaf slen */
@@ -1835,10 +1830,9 @@ int fib_table_flush(struct fib_table *tb)
 				continue;
 			}
 
-			netdev_switch_fib_ipv4_del(n->key,
-						   KEYLENGTH - fa->fa_slen,
-						   fi, fa->fa_tos,
-						   fa->fa_type, tb->tb_id);
+			swdev_fib_ipv4_del(n->key, KEYLENGTH - fa->fa_slen,
+					   fi, fa->fa_tos, fa->fa_type,
+					   tb->tb_id);
 			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index bcf7ccb..3142c57 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -458,7 +458,7 @@ int swdev_port_bridge_dellink(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(swdev_port_bridge_dellink);
 
-static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
+static struct net_device *swdev_get_lowest_dev(struct net_device *dev)
 {
 	const struct swdev_ops *ops = dev->swdev_ops;
 	struct net_device *lower_dev;
@@ -473,7 +473,7 @@ static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 		return dev;
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		port_dev = netdev_switch_get_lowest_dev(lower_dev);
+		port_dev = swdev_get_lowest_dev(lower_dev);
 		if (port_dev)
 			return port_dev;
 	}
@@ -481,7 +481,7 @@ static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 	return NULL;
 }
 
-static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
+static struct net_device *swdev_get_dev_by_nhs(struct fib_info *fi)
 {
 	struct swdev_attr attr = {
 		.id = SWDEV_ATTR_PORT_PARENT_ID,
@@ -498,7 +498,7 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
 		if (!nh->nh_dev)
 			return NULL;
 
-		dev = netdev_switch_get_lowest_dev(nh->nh_dev);
+		dev = swdev_get_lowest_dev(nh->nh_dev);
 		if (!dev)
 			return NULL;
 
@@ -520,7 +520,7 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
 }
 
 /**
- *	netdev_switch_fib_ipv4_add - Add IPv4 route entry to switch
+ *	swdev_fib_ipv4_add - Add IPv4 route entry to switch
  *
  *	@dst: route's IPv4 destination address
  *	@dst_len: destination address length (prefix length)
@@ -532,8 +532,8 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
  *
  *	Add IPv4 route entry to switch device.
  */
-int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
-			       u8 tos, u8 type, u32 nlflags, u32 tb_id)
+int swdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
+		       u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
 	struct net_device *dev;
 	const struct swdev_ops *ops;
@@ -551,7 +551,7 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	if (fi->fib_net->ipv4.fib_offload_disabled)
 		return 0;
 
-	dev = netdev_switch_get_dev_by_nhs(fi);
+	dev = swdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
 	ops = dev->swdev_ops;
@@ -566,10 +566,10 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_add);
+EXPORT_SYMBOL_GPL(swdev_fib_ipv4_add);
 
 /**
- *	netdev_switch_fib_ipv4_del - Delete IPv4 route entry from switch
+ *	swdev_fib_ipv4_del - Delete IPv4 route entry from switch
  *
  *	@dst: route's IPv4 destination address
  *	@dst_len: destination address length (prefix length)
@@ -580,8 +580,8 @@ EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_add);
  *
  *	Delete IPv4 route entry from switch device.
  */
-int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
-			       u8 tos, u8 type, u32 tb_id)
+int swdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+		       u8 tos, u8 type, u32 tb_id)
 {
 	struct net_device *dev;
 	const struct swdev_ops *ops;
@@ -590,7 +590,7 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
 		return 0;
 
-	dev = netdev_switch_get_dev_by_nhs(fi);
+	dev = swdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
 	ops = dev->swdev_ops;
@@ -604,14 +604,14 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_del);
+EXPORT_SYMBOL_GPL(swdev_fib_ipv4_del);
 
 /**
- *	netdev_switch_fib_ipv4_abort - Abort an IPv4 FIB operation
+ *	swdev_fib_ipv4_abort - Abort an IPv4 FIB operation
  *
  *	@fi: route FIB info structure
  */
-void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
+void swdev_fib_ipv4_abort(struct fib_info *fi)
 {
 	/* There was a problem installing this route to the offload
 	 * device.  For now, until we come up with more refined
@@ -624,4 +624,4 @@ void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
 	fib_flush_external(fi->fib_net);
 	fi->fib_net->ipv4.fib_offload_disabled = true;
 }
-EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_abort);
+EXPORT_SYMBOL_GPL(swdev_fib_ipv4_abort);
-- 
1.7.10.4
