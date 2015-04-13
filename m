From: sfeldma@gmail.com
Subject: [PATCH net-next v4 23/24] switchdev: convert fib_ipv4_add/del over to swdev_port_obj_add/del
Date: Sun, 12 Apr 2015 23:17:17 -0700
Message-ID: <1428905838-14920-24-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34123 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108AbbDMGQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:57 -0400
Received: by pacyx8 with SMTP id yx8so91991318pac.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:56 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The IPv4 FIB ops convert nicely to the swdev objs and we're left with only
four swdev ops: port get/set and port add/del.  Other objs will follow, such
as FDB.  So go ahead and convert IPv4 FIB over to swdev obj for consistency,
anticipating more objs to come.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   42 ++++++-----------
 include/net/switchdev.h              |   44 ++++++++----------
 net/ipv4/fib_trie.c                  |   38 +++++++---------
 net/switchdev/switchdev.c            |   83 ++++++++++++++++++++--------------
 4 files changed, 99 insertions(+), 108 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index e927e22..261cb7f 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4395,6 +4395,7 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 static int rocker_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct swdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	rocker_port->trans = obj->trans;
@@ -4414,6 +4415,12 @@ static int rocker_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
 	case SWDEV_OBJ_PORT_VLAN:
 		err = rocker_port_vlans_add(rocker_port, &obj->vlan);
 		break;
+	case SWDEV_OBJ_IPV4_FIB:
+		fib4 = &obj->ipv4_fib;
+		err = rocker_port_fib_ipv4(rocker_port, fib4->dst,
+					   fib4->dst_len, fib4->fi,
+					   fib4->tb_id, 0);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4455,12 +4462,20 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
 static int rocker_port_obj_del(struct net_device *dev, struct swdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct swdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	switch (obj->id) {
 	case SWDEV_OBJ_PORT_VLAN:
 		err = rocker_port_vlans_del(rocker_port, &obj->vlan);
 		break;
+	case SWDEV_OBJ_IPV4_FIB:
+		fib4 = &obj->ipv4_fib;
+		err = rocker_port_fib_ipv4(rocker_port, fib4->dst,
+					   fib4->dst_len, fib4->fi,
+					   fib4->tb_id,
+					   ROCKER_OP_FLAG_REMOVE);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4469,38 +4484,11 @@ static int rocker_port_obj_del(struct net_device *dev, struct swdev_obj *obj)
 	return err;
 }
 
-static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
-					  __be32 dst, int dst_len,
-					  struct fib_info *fi,
-					  u8 tos, u8 type,
-					  u32 nlflags, u32 tb_id)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	int flags = 0;
-
-	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
-				    fi, tb_id, flags);
-}
-
-static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
-					  __be32 dst, int dst_len,
-					  struct fib_info *fi,
-					  u8 tos, u8 type, u32 tb_id)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	int flags = ROCKER_OP_FLAG_REMOVE;
-
-	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
-				    fi, tb_id, flags);
-}
-
 static const struct swdev_ops rocker_port_swdev_ops = {
 	.swdev_port_attr_get		= rocker_port_attr_get,
 	.swdev_port_attr_set		= rocker_port_attr_set,
 	.swdev_port_obj_add		= rocker_port_obj_add,
 	.swdev_port_obj_del		= rocker_port_obj_del,
-	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
-	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
 };
 
 /********************
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d04322e..85f0c0d 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -46,6 +46,7 @@ struct fib_info;
 enum swdev_obj_id {
 	SWDEV_OBJ_UNDEFINED,
 	SWDEV_OBJ_PORT_VLAN,
+	SWDEV_OBJ_IPV4_FIB,
 };
 
 struct swdev_obj {
@@ -58,6 +59,15 @@ struct swdev_obj {
 			u16 vid_start;
 			u16 vid_end;
 		} vlan;
+		struct swdev_obj_ipv4_fib {		/* IPV4_FIB */
+			u32 dst;
+			int dst_len;
+			struct fib_info *fi;
+			u8 tos;
+			u8 type;
+			u32 nlflags;
+			u32 tb_id;
+		} ipv4_fib;
 	};
 };
 
@@ -71,10 +81,6 @@ struct swdev_obj {
  * @swdev_port_obj_add: Add an object to port (see swdev_obj).
  *
  * @swdev_port_obj_del: Delete an object from port (see swdev_obj).
- *
- * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
- *
- * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
  */
 struct swdev_ops {
 	int	(*swdev_port_attr_get)(struct net_device *dev,
@@ -85,13 +91,6 @@ struct swdev_ops {
 				      struct swdev_obj *obj);
 	int	(*swdev_port_obj_del)(struct net_device *dev,
 				      struct swdev_obj *obj);
-	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
-				      int dst_len, struct fib_info *fi,
-				      u8 tos, u8 type, u32 nlflags,
-				      u32 tb_id);
-	int	(*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
-				      int dst_len, struct fib_info *fi,
-				      u8 tos, u8 type, u32 tb_id);
 };
 
 enum netdev_switch_notifier_type {
@@ -131,11 +130,11 @@ int register_netdev_switch_notifier(struct notifier_block *nb);
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
 
@@ -198,22 +197,19 @@ static inline int call_netdev_switch_notifiers(unsigned long val, struct net_dev
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
index e13fcc6..f108714 100644
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
index 6866e0c..bb3481d 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -573,7 +573,7 @@ int swdev_port_bridge_dellink(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(swdev_port_bridge_dellink);
 
-static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
+static struct net_device *swdev_get_lowest_dev(struct net_device *dev)
 {
 	const struct swdev_ops *ops = dev->swdev_ops;
 	struct net_device *lower_dev;
@@ -588,7 +588,7 @@ static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 		return dev;
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		port_dev = netdev_switch_get_lowest_dev(lower_dev);
+		port_dev = swdev_get_lowest_dev(lower_dev);
 		if (port_dev)
 			return port_dev;
 	}
@@ -596,7 +596,7 @@ static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 	return NULL;
 }
 
-static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
+static struct net_device *swdev_get_dev_by_nhs(struct fib_info *fi)
 {
 	struct swdev_attr attr = {
 		.id = SWDEV_ATTR_PORT_PARENT_ID,
@@ -613,7 +613,7 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
 		if (!nh->nh_dev)
 			return NULL;
 
-		dev = netdev_switch_get_lowest_dev(nh->nh_dev);
+		dev = swdev_get_lowest_dev(nh->nh_dev);
 		if (!dev)
 			return NULL;
 
@@ -635,7 +635,7 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
 }
 
 /**
- *	netdev_switch_fib_ipv4_add - Add IPv4 route entry to switch
+ *	swdev_fib_ipv4_add - Add IPv4 route entry to switch
  *
  *	@dst: route's IPv4 destination address
  *	@dst_len: destination address length (prefix length)
@@ -647,11 +647,22 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
  *
  *	Add IPv4 route entry to switch device.
  */
-int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
-			       u8 tos, u8 type, u32 nlflags, u32 tb_id)
+int swdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
+		       u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
+	struct swdev_obj fib_obj = {
+		.id = SWDEV_OBJ_IPV4_FIB,
+		.ipv4_fib = {
+			.dst = htonl(dst),
+			.dst_len = dst_len,
+			.fi = fi,
+			.tos = tos,
+			.type = type,
+			.nlflags = nlflags,
+			.tb_id = tb_id,
+		},
+	};
 	struct net_device *dev;
-	const struct swdev_ops *ops;
 	int err = 0;
 
 	/* Don't offload route if using custom ip rules or if
@@ -666,25 +677,20 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	if (fi->fib_net->ipv4.fib_offload_disabled)
 		return 0;
 
-	dev = netdev_switch_get_dev_by_nhs(fi);
+	dev = swdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
-	ops = dev->swdev_ops;
-
-	if (ops->swdev_fib_ipv4_add) {
-		err = ops->swdev_fib_ipv4_add(dev, htonl(dst), dst_len,
-					      fi, tos, type, nlflags,
-					      tb_id);
-		if (!err)
-			fi->fib_flags |= RTNH_F_EXTERNAL;
-	}
+
+	err = swdev_port_obj_add(dev, &fib_obj);
+	if (!err)
+		fi->fib_flags |= RTNH_F_EXTERNAL;
 
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
@@ -695,38 +701,45 @@ EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_add);
  *
  *	Delete IPv4 route entry from switch device.
  */
-int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
-			       u8 tos, u8 type, u32 tb_id)
+int swdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+		       u8 tos, u8 type, u32 tb_id)
 {
+	struct swdev_obj fib_obj = {
+		.id = SWDEV_OBJ_IPV4_FIB,
+		.ipv4_fib = {
+			.dst = htonl(dst),
+			.dst_len = dst_len,
+			.fi = fi,
+			.tos = tos,
+			.type = type,
+			.nlflags = 0,
+			.tb_id = tb_id,
+		},
+	};
 	struct net_device *dev;
-	const struct swdev_ops *ops;
 	int err = 0;
 
 	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
 		return 0;
 
-	dev = netdev_switch_get_dev_by_nhs(fi);
+	dev = swdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
-	ops = dev->swdev_ops;
 
-	if (ops->swdev_fib_ipv4_del) {
-		err = ops->swdev_fib_ipv4_del(dev, htonl(dst), dst_len,
-					      fi, tos, type, tb_id);
-		if (!err)
-			fi->fib_flags &= ~RTNH_F_EXTERNAL;
-	}
+	err = swdev_port_obj_del(dev, &fib_obj);
+	if (!err)
+		fi->fib_flags &= ~RTNH_F_EXTERNAL;
 
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
@@ -739,4 +752,4 @@ void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
 	fib_flush_external(fi->fib_net);
 	fi->fib_net->ipv4.fib_offload_disabled = true;
 }
-EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_abort);
+EXPORT_SYMBOL_GPL(swdev_fib_ipv4_abort);
-- 
1.7.10.4
