From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] switchdev: s/netdev_switch_/switchdev_/
Date: Mon, 13 Apr 2015 16:14:34 +0200
Message-ID: <1428934475-15349-2-git-send-email-jiri@resnulli.us>
References: <1428934475-15349-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, roopa@cumulusnetworks.com,
	f.fainelli@gmail.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34976 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932291AbbDMOOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:14:41 -0400
Received: by widdi4 with SMTP id di4so74280633wid.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:14:40 -0700 (PDT)
In-Reply-To: <1428934475-15349-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turned out that "switchdev" sticks. So just unify all releated terms to
use this prefix.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c      |   4 +-
 drivers/net/ethernet/rocker/rocker.c |  10 +--
 drivers/net/team/team.c              |   4 +-
 include/net/switchdev.h              | 106 +++++++++++++--------------
 net/bridge/br.c                      |  18 ++---
 net/bridge/br_netlink.c              |   6 +-
 net/bridge/br_stp.c                  |   2 +-
 net/core/net-sysfs.c                 |   2 +-
 net/core/rtnetlink.c                 |   2 +-
 net/ipv4/fib_trie.c                  |  40 +++++------
 net/switchdev/switchdev.c            | 134 +++++++++++++++++------------------
 11 files changed, 161 insertions(+), 167 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 78dde56..e96f029 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4037,8 +4037,8 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_add_slave		= bond_enslave,
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
-	.ndo_bridge_setlink	= ndo_dflt_netdev_switch_port_bridge_setlink,
-	.ndo_bridge_dellink	= ndo_dflt_netdev_switch_port_bridge_dellink,
+	.ndo_bridge_setlink	= ndo_dflt_switchdev_port_bridge_setlink,
+	.ndo_bridge_dellink	= ndo_dflt_switchdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
 
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a87b177..6d31aeb 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3377,17 +3377,17 @@ static void rocker_port_fdb_learn_work(struct work_struct *work)
 		container_of(work, struct rocker_fdb_learn_work, work);
 	bool removing = (lw->flags & ROCKER_OP_FLAG_REMOVE);
 	bool learned = (lw->flags & ROCKER_OP_FLAG_LEARNED);
-	struct netdev_switch_notifier_fdb_info info;
+	struct switchdev_notifier_fdb_info info;
 
 	info.addr = lw->addr;
 	info.vid = lw->vid;
 
 	if (learned && removing)
-		call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_DEL,
-					     lw->dev, &info.info);
+		call_switchdev_notifiers(NETDEV_SWITCH_FDB_DEL,
+					 lw->dev, &info.info);
 	else if (learned && !removing)
-		call_netdev_switch_notifiers(NETDEV_SWITCH_FDB_ADD,
-					     lw->dev, &info.info);
+		call_switchdev_notifiers(NETDEV_SWITCH_FDB_ADD,
+					 lw->dev, &info.info);
 
 	kfree(work);
 }
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 6928448..cfe8496 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1977,8 +1977,8 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_del_slave		= team_del_slave,
 	.ndo_fix_features	= team_fix_features,
 	.ndo_change_carrier     = team_change_carrier,
-	.ndo_bridge_setlink     = ndo_dflt_netdev_switch_port_bridge_setlink,
-	.ndo_bridge_dellink     = ndo_dflt_netdev_switch_port_bridge_dellink,
+	.ndo_bridge_setlink     = ndo_dflt_switchdev_port_bridge_setlink,
+	.ndo_bridge_dellink     = ndo_dflt_switchdev_port_bridge_dellink,
 	.ndo_features_check	= passthru_features_check,
 };
 
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d2e69ee..9b43228 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -43,124 +43,124 @@ struct swdev_ops {
 				      u8 tos, u8 type, u32 tb_id);
 };
 
-enum netdev_switch_notifier_type {
+enum switchdev_notifier_type {
 	NETDEV_SWITCH_FDB_ADD = 1,
 	NETDEV_SWITCH_FDB_DEL,
 };
 
-struct netdev_switch_notifier_info {
+struct switchdev_notifier_info {
 	struct net_device *dev;
 };
 
-struct netdev_switch_notifier_fdb_info {
-	struct netdev_switch_notifier_info info; /* must be first */
+struct switchdev_notifier_fdb_info {
+	struct switchdev_notifier_info info; /* must be first */
 	const unsigned char *addr;
 	u16 vid;
 };
 
 static inline struct net_device *
-netdev_switch_notifier_info_to_dev(const struct netdev_switch_notifier_info *info)
+switchdev_notifier_info_to_dev(const struct switchdev_notifier_info *info)
 {
 	return info->dev;
 }
 
 #ifdef CONFIG_NET_SWITCHDEV
 
-int netdev_switch_parent_id_get(struct net_device *dev,
-				struct netdev_phys_item_id *psid);
-int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
-int register_netdev_switch_notifier(struct notifier_block *nb);
-int unregister_netdev_switch_notifier(struct notifier_block *nb);
-int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
-				 struct netdev_switch_notifier_info *info);
-int netdev_switch_port_bridge_setlink(struct net_device *dev,
-				struct nlmsghdr *nlh, u16 flags);
-int netdev_switch_port_bridge_dellink(struct net_device *dev,
-				struct nlmsghdr *nlh, u16 flags);
-int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
-					       struct nlmsghdr *nlh, u16 flags);
-int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
-					       struct nlmsghdr *nlh, u16 flags);
-int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
-			       u8 tos, u8 type, u32 nlflags, u32 tb_id);
-int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
-			       u8 tos, u8 type, u32 tb_id);
-void netdev_switch_fib_ipv4_abort(struct fib_info *fi);
+int switchdev_parent_id_get(struct net_device *dev,
+			    struct netdev_phys_item_id *psid);
+int switchdev_port_stp_update(struct net_device *dev, u8 state);
+int register_switchdev_notifier(struct notifier_block *nb);
+int unregister_switchdev_notifier(struct notifier_block *nb);
+int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
+			     struct switchdev_notifier_info *info);
+int switchdev_port_bridge_setlink(struct net_device *dev,
+				  struct nlmsghdr *nlh, u16 flags);
+int switchdev_port_bridge_dellink(struct net_device *dev,
+				  struct nlmsghdr *nlh, u16 flags);
+int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
+					   struct nlmsghdr *nlh, u16 flags);
+int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
+					   struct nlmsghdr *nlh, u16 flags);
+int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
+			   u8 tos, u8 type, u32 nlflags, u32 tb_id);
+int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+			   u8 tos, u8 type, u32 tb_id);
+void switchdev_fib_ipv4_abort(struct fib_info *fi);
 
 #else
 
-static inline int netdev_switch_parent_id_get(struct net_device *dev,
-					      struct netdev_phys_item_id *psid)
+static inline int switchdev_parent_id_get(struct net_device *dev,
+					  struct netdev_phys_item_id *psid)
 {
 	return -EOPNOTSUPP;
 }
 
-static inline int netdev_switch_port_stp_update(struct net_device *dev,
-						u8 state)
+static inline int switchdev_port_stp_update(struct net_device *dev,
+					    u8 state)
 {
 	return -EOPNOTSUPP;
 }
 
-static inline int register_netdev_switch_notifier(struct notifier_block *nb)
+static inline int register_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
 }
 
-static inline int unregister_netdev_switch_notifier(struct notifier_block *nb)
+static inline int unregister_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
 }
 
-static inline int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
-					       struct netdev_switch_notifier_info *info)
+static inline int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
+					   struct switchdev_notifier_info *info)
 {
 	return NOTIFY_DONE;
 }
 
-static inline int netdev_switch_port_bridge_setlink(struct net_device *dev,
-						    struct nlmsghdr *nlh,
-						    u16 flags)
+static inline int switchdev_port_bridge_setlink(struct net_device *dev,
+						struct nlmsghdr *nlh,
+						u16 flags)
 {
 	return -EOPNOTSUPP;
 }
 
-static inline int netdev_switch_port_bridge_dellink(struct net_device *dev,
-						    struct nlmsghdr *nlh,
-						    u16 flags)
+static inline int switchdev_port_bridge_dellink(struct net_device *dev,
+						struct nlmsghdr *nlh,
+						u16 flags)
 {
 	return -EOPNOTSUPP;
 }
 
-static inline int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
-							struct nlmsghdr *nlh,
-							u16 flags)
+static inline int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
+							 struct nlmsghdr *nlh,
+							 u16 flags)
 {
 	return 0;
 }
 
-static inline int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
-							struct nlmsghdr *nlh,
-							u16 flags)
+static inline int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
+							 struct nlmsghdr *nlh,
+							 u16 flags)
 {
 	return 0;
 }
 
-static inline int netdev_switch_fib_ipv4_add(u32 dst, int dst_len,
-					     struct fib_info *fi,
-					     u8 tos, u8 type,
-					     u32 nlflags, u32 tb_id)
+static inline int switchdev_fib_ipv4_add(u32 dst, int dst_len,
+					 struct fib_info *fi,
+					 u8 tos, u8 type,
+					 u32 nlflags, u32 tb_id)
 {
 	return 0;
 }
 
-static inline int netdev_switch_fib_ipv4_del(u32 dst, int dst_len,
-					     struct fib_info *fi,
-					     u8 tos, u8 type, u32 tb_id)
+static inline int switchdev_fib_ipv4_del(u32 dst, int dst_len,
+					 struct fib_info *fi,
+					 u8 tos, u8 type, u32 tb_id)
 {
 	return 0;
 }
 
-static inline void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
+static inline void switchdev_fib_ipv4_abort(struct fib_info *fi)
 {
 }
 
diff --git a/net/bridge/br.c b/net/bridge/br.c
index 02c24cf..8ef26d0 100644
--- a/net/bridge/br.c
+++ b/net/bridge/br.c
@@ -121,13 +121,13 @@ static struct notifier_block br_device_notifier = {
 	.notifier_call = br_device_event
 };
 
-static int br_netdev_switch_event(struct notifier_block *unused,
-				  unsigned long event, void *ptr)
+static int br_switchdev_event(struct notifier_block *unused,
+			      unsigned long event, void *ptr)
 {
-	struct net_device *dev = netdev_switch_notifier_info_to_dev(ptr);
+	struct net_device *dev = switchdev_notifier_info_to_dev(ptr);
 	struct net_bridge_port *p;
 	struct net_bridge *br;
-	struct netdev_switch_notifier_fdb_info *fdb_info;
+	struct switchdev_notifier_fdb_info *fdb_info;
 	int err = NOTIFY_DONE;
 
 	rtnl_lock();
@@ -159,8 +159,8 @@ out:
 	return err;
 }
 
-static struct notifier_block br_netdev_switch_notifier = {
-	.notifier_call = br_netdev_switch_event,
+static struct notifier_block br_switchdev_notifier = {
+	.notifier_call = br_switchdev_event,
 };
 
 static void __net_exit br_net_exit(struct net *net)
@@ -214,7 +214,7 @@ static int __init br_init(void)
 	if (err)
 		goto err_out3;
 
-	err = register_netdev_switch_notifier(&br_netdev_switch_notifier);
+	err = register_switchdev_notifier(&br_switchdev_notifier);
 	if (err)
 		goto err_out4;
 
@@ -235,7 +235,7 @@ static int __init br_init(void)
 	return 0;
 
 err_out5:
-	unregister_netdev_switch_notifier(&br_netdev_switch_notifier);
+	unregister_switchdev_notifier(&br_switchdev_notifier);
 err_out4:
 	unregister_netdevice_notifier(&br_device_notifier);
 err_out3:
@@ -253,7 +253,7 @@ static void __exit br_deinit(void)
 {
 	stp_proto_unregister(&br_stp_proto);
 	br_netlink_fini();
-	unregister_netdev_switch_notifier(&br_netdev_switch_notifier);
+	unregister_switchdev_notifier(&br_switchdev_notifier);
 	unregister_netdevice_notifier(&br_device_notifier);
 	brioctl_set(NULL);
 	unregister_pernet_subsys(&br_net_ops);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 0e4ddb8..8f66366 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -631,8 +631,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
 		/* set bridge attributes in hardware if supported
 		 */
-		ret_offload = netdev_switch_port_bridge_setlink(dev, nlh,
-								flags);
+		ret_offload = switchdev_port_bridge_setlink(dev, nlh, flags);
 		if (ret_offload && ret_offload != -EOPNOTSUPP)
 			br_warn(p->br, "error setting attrs on port %u(%s)\n",
 				(unsigned int)p->port_no, p->dev->name);
@@ -671,8 +670,7 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
 		/* del bridge attributes in hardware
 		 */
-		ret_offload = netdev_switch_port_bridge_dellink(dev, nlh,
-								flags);
+		ret_offload = switchdev_port_bridge_dellink(dev, nlh, flags);
 		if (ret_offload && ret_offload != -EOPNOTSUPP)
 			br_warn(p->br, "error deleting attrs on port %u (%s)\n",
 				(unsigned int)p->port_no, p->dev->name);
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index fb3ebe6..28e3f4b 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -42,7 +42,7 @@ void br_set_state(struct net_bridge_port *p, unsigned int state)
 	int err;
 
 	p->state = state;
-	err = netdev_switch_port_stp_update(p->dev, state);
+	err = switchdev_port_stp_update(p->dev, state);
 	if (err && err != -EOPNOTSUPP)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 4238d6d..be86a7c 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -460,7 +460,7 @@ static ssize_t phys_switch_id_show(struct device *dev,
 	if (dev_isalive(netdev)) {
 		struct netdev_phys_item_id ppid;
 
-		ret = netdev_switch_parent_id_get(netdev, &ppid);
+		ret = switchdev_parent_id_get(netdev, &ppid);
 		if (!ret)
 			ret = sprintf(buf, "%*phN\n", ppid.id_len, ppid.id);
 	}
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 358d52a..145bbe7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1006,7 +1006,7 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 	int err;
 	struct netdev_phys_item_id psid;
 
-	err = netdev_switch_parent_id_get(dev, &psid);
+	err = switchdev_parent_id_get(dev, &psid);
 	if (err) {
 		if (err == -EOPNOTSUPP)
 			return 0;
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index e13fcc6..03444c6 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1165,13 +1165,13 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			new_fa->fa_state = state & ~FA_S_ACCESSED;
 			new_fa->fa_slen = fa->fa_slen;
 
-			err = netdev_switch_fib_ipv4_add(key, plen, fi,
-							 new_fa->fa_tos,
-							 cfg->fc_type,
-							 cfg->fc_nlflags,
-							 tb->tb_id);
+			err = switchdev_fib_ipv4_add(key, plen, fi,
+						     new_fa->fa_tos,
+						     cfg->fc_type,
+						     cfg->fc_nlflags,
+						     tb->tb_id);
 			if (err) {
-				netdev_switch_fib_ipv4_abort(fi);
+				switchdev_fib_ipv4_abort(fi);
 				kmem_cache_free(fn_alias_kmem, new_fa);
 				goto out;
 			}
@@ -1215,12 +1215,10 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	new_fa->tb_id = tb->tb_id;
 
 	/* (Optionally) offload fib entry to switch hardware. */
-	err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
-					 cfg->fc_type,
-					 cfg->fc_nlflags,
-					 tb->tb_id);
+	err = switchdev_fib_ipv4_add(key, plen, fi, tos, cfg->fc_type,
+				     cfg->fc_nlflags, tb->tb_id);
 	if (err) {
-		netdev_switch_fib_ipv4_abort(fi);
+		switchdev_fib_ipv4_abort(fi);
 		goto out_free_new_fa;
 	}
 
@@ -1239,7 +1237,7 @@ succeeded:
 	return 0;
 
 out_sw_fib_del:
-	netdev_switch_fib_ipv4_del(key, plen, fi, tos, cfg->fc_type, tb->tb_id);
+	switchdev_fib_ipv4_del(key, plen, fi, tos, cfg->fc_type, tb->tb_id);
 out_free_new_fa:
 	kmem_cache_free(fn_alias_kmem, new_fa);
 out:
@@ -1517,8 +1515,8 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	if (!fa_to_delete)
 		return -ESRCH;
 
-	netdev_switch_fib_ipv4_del(key, plen, fa_to_delete->fa_info, tos,
-				   cfg->fc_type, tb->tb_id);
+	switchdev_fib_ipv4_del(key, plen, fa_to_delete->fa_info, tos,
+			       cfg->fc_type, tb->tb_id);
 
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
@@ -1767,10 +1765,9 @@ void fib_table_flush_external(struct fib_table *tb)
 			if (!fi || !(fi->fib_flags & RTNH_F_EXTERNAL))
 				continue;
 
-			netdev_switch_fib_ipv4_del(n->key,
-						   KEYLENGTH - fa->fa_slen,
-						   fi, fa->fa_tos,
-						   fa->fa_type, tb->tb_id);
+			switchdev_fib_ipv4_del(n->key, KEYLENGTH - fa->fa_slen,
+					       fi, fa->fa_tos, fa->fa_type,
+					       tb->tb_id);
 		}
 
 		/* update leaf slen */
@@ -1835,10 +1832,9 @@ int fib_table_flush(struct fib_table *tb)
 				continue;
 			}
 
-			netdev_switch_fib_ipv4_del(n->key,
-						   KEYLENGTH - fa->fa_slen,
-						   fi, fa->fa_tos,
-						   fa->fa_type, tb->tb_id);
+			switchdev_fib_ipv4_del(n->key, KEYLENGTH - fa->fa_slen,
+					       fi, fa->fa_tos, fa->fa_type,
+					       tb->tb_id);
 			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 46568b8..52613ed 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -19,14 +19,14 @@
 #include <net/switchdev.h>
 
 /**
- *	netdev_switch_parent_id_get - Get ID of a switch
+ *	switchdev_parent_id_get - Get ID of a switch
  *	@dev: port device
  *	@psid: switch ID
  *
  *	Get ID of a switch this port is part of.
  */
-int netdev_switch_parent_id_get(struct net_device *dev,
-				struct netdev_phys_item_id *psid)
+int switchdev_parent_id_get(struct net_device *dev,
+			    struct netdev_phys_item_id *psid)
 {
 	const struct swdev_ops *ops = dev->swdev_ops;
 
@@ -34,17 +34,17 @@ int netdev_switch_parent_id_get(struct net_device *dev,
 		return -EOPNOTSUPP;
 	return ops->swdev_parent_id_get(dev, psid);
 }
-EXPORT_SYMBOL_GPL(netdev_switch_parent_id_get);
+EXPORT_SYMBOL_GPL(switchdev_parent_id_get);
 
 /**
- *	netdev_switch_port_stp_update - Notify switch device port of STP
+ *	switchdev_port_stp_update - Notify switch device port of STP
  *					state change
  *	@dev: port device
  *	@state: port STP state
  *
  *	Notify switch device port of bridge port STP state change.
  */
-int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
+int switchdev_port_stp_update(struct net_device *dev, u8 state)
 {
 	const struct swdev_ops *ops = dev->swdev_ops;
 	struct net_device *lower_dev;
@@ -55,57 +55,57 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
 		return ops->swdev_port_stp_update(dev, state);
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = netdev_switch_port_stp_update(lower_dev, state);
+		err = switchdev_port_stp_update(lower_dev, state);
 		if (err && err != -EOPNOTSUPP)
 			return err;
 	}
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
+EXPORT_SYMBOL_GPL(switchdev_port_stp_update);
 
-static DEFINE_MUTEX(netdev_switch_mutex);
-static RAW_NOTIFIER_HEAD(netdev_switch_notif_chain);
+static DEFINE_MUTEX(switchdev_mutex);
+static RAW_NOTIFIER_HEAD(switchdev_notif_chain);
 
 /**
- *	register_netdev_switch_notifier - Register notifier
+ *	register_switchdev_notifier - Register notifier
  *	@nb: notifier_block
  *
  *	Register switch device notifier. This should be used by code
  *	which needs to monitor events happening in particular device.
  *	Return values are same as for atomic_notifier_chain_register().
  */
-int register_netdev_switch_notifier(struct notifier_block *nb)
+int register_switchdev_notifier(struct notifier_block *nb)
 {
 	int err;
 
-	mutex_lock(&netdev_switch_mutex);
-	err = raw_notifier_chain_register(&netdev_switch_notif_chain, nb);
-	mutex_unlock(&netdev_switch_mutex);
+	mutex_lock(&switchdev_mutex);
+	err = raw_notifier_chain_register(&switchdev_notif_chain, nb);
+	mutex_unlock(&switchdev_mutex);
 	return err;
 }
-EXPORT_SYMBOL_GPL(register_netdev_switch_notifier);
+EXPORT_SYMBOL_GPL(register_switchdev_notifier);
 
 /**
- *	unregister_netdev_switch_notifier - Unregister notifier
+ *	unregister_switchdev_notifier - Unregister notifier
  *	@nb: notifier_block
  *
  *	Unregister switch device notifier.
  *	Return values are same as for atomic_notifier_chain_unregister().
  */
-int unregister_netdev_switch_notifier(struct notifier_block *nb)
+int unregister_switchdev_notifier(struct notifier_block *nb)
 {
 	int err;
 
-	mutex_lock(&netdev_switch_mutex);
-	err = raw_notifier_chain_unregister(&netdev_switch_notif_chain, nb);
-	mutex_unlock(&netdev_switch_mutex);
+	mutex_lock(&switchdev_mutex);
+	err = raw_notifier_chain_unregister(&switchdev_notif_chain, nb);
+	mutex_unlock(&switchdev_mutex);
 	return err;
 }
-EXPORT_SYMBOL_GPL(unregister_netdev_switch_notifier);
+EXPORT_SYMBOL_GPL(unregister_switchdev_notifier);
 
 /**
- *	call_netdev_switch_notifiers - Call notifiers
+ *	call_switchdev_notifiers - Call notifiers
  *	@val: value passed unmodified to notifier function
  *	@dev: port device
  *	@info: notifier information data
@@ -114,21 +114,21 @@ EXPORT_SYMBOL_GPL(unregister_netdev_switch_notifier);
  *	when it needs to propagate hardware event.
  *	Return values are same as for atomic_notifier_call_chain().
  */
-int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
-				 struct netdev_switch_notifier_info *info)
+int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
+			     struct switchdev_notifier_info *info)
 {
 	int err;
 
 	info->dev = dev;
-	mutex_lock(&netdev_switch_mutex);
-	err = raw_notifier_call_chain(&netdev_switch_notif_chain, val, info);
-	mutex_unlock(&netdev_switch_mutex);
+	mutex_lock(&switchdev_mutex);
+	err = raw_notifier_call_chain(&switchdev_notif_chain, val, info);
+	mutex_unlock(&switchdev_mutex);
 	return err;
 }
-EXPORT_SYMBOL_GPL(call_netdev_switch_notifiers);
+EXPORT_SYMBOL_GPL(call_switchdev_notifiers);
 
 /**
- *	netdev_switch_port_bridge_setlink - Notify switch device port of bridge
+ *	switchdev_port_bridge_setlink - Notify switch device port of bridge
  *	port attributes
  *
  *	@dev: port device
@@ -137,8 +137,8 @@ EXPORT_SYMBOL_GPL(call_netdev_switch_notifiers);
  *
  *	Notify switch device port of bridge port attributes
  */
-int netdev_switch_port_bridge_setlink(struct net_device *dev,
-				      struct nlmsghdr *nlh, u16 flags)
+int switchdev_port_bridge_setlink(struct net_device *dev,
+				  struct nlmsghdr *nlh, u16 flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
@@ -150,10 +150,10 @@ int netdev_switch_port_bridge_setlink(struct net_device *dev,
 
 	return ops->ndo_bridge_setlink(dev, nlh, flags);
 }
-EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_setlink);
+EXPORT_SYMBOL_GPL(switchdev_port_bridge_setlink);
 
 /**
- *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
+ *	switchdev_port_bridge_dellink - Notify switch device port of bridge
  *	port attribute delete
  *
  *	@dev: port device
@@ -162,8 +162,8 @@ EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_setlink);
  *
  *	Notify switch device port of bridge port attribute delete
  */
-int netdev_switch_port_bridge_dellink(struct net_device *dev,
-				      struct nlmsghdr *nlh, u16 flags)
+int switchdev_port_bridge_dellink(struct net_device *dev,
+				  struct nlmsghdr *nlh, u16 flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
@@ -175,11 +175,11 @@ int netdev_switch_port_bridge_dellink(struct net_device *dev,
 
 	return ops->ndo_bridge_dellink(dev, nlh, flags);
 }
-EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_dellink);
+EXPORT_SYMBOL_GPL(switchdev_port_bridge_dellink);
 
 /**
- *	ndo_dflt_netdev_switch_port_bridge_setlink - default ndo bridge setlink
- *						     op for master devices
+ *	ndo_dflt_switchdev_port_bridge_setlink - default ndo bridge setlink
+ *						 op for master devices
  *
  *	@dev: port device
  *	@nlh: netlink msg with bridge port attributes
@@ -187,8 +187,8 @@ EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_dellink);
  *
  *	Notify master device slaves of bridge port attributes
  */
-int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
-					       struct nlmsghdr *nlh, u16 flags)
+int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
+					   struct nlmsghdr *nlh, u16 flags)
 {
 	struct net_device *lower_dev;
 	struct list_head *iter;
@@ -198,18 +198,18 @@ int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
 		return ret;
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = netdev_switch_port_bridge_setlink(lower_dev, nlh, flags);
+		err = switchdev_port_bridge_setlink(lower_dev, nlh, flags);
 		if (err && err != -EOPNOTSUPP)
 			ret = err;
 	}
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_bridge_setlink);
+EXPORT_SYMBOL_GPL(ndo_dflt_switchdev_port_bridge_setlink);
 
 /**
- *	ndo_dflt_netdev_switch_port_bridge_dellink - default ndo bridge dellink
- *						     op for master devices
+ *	ndo_dflt_switchdev_port_bridge_dellink - default ndo bridge dellink
+ *						 op for master devices
  *
  *	@dev: port device
  *	@nlh: netlink msg with bridge port attributes
@@ -217,8 +217,8 @@ EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_bridge_setlink);
  *
  *	Notify master device slaves of bridge port attribute deletes
  */
-int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
-					       struct nlmsghdr *nlh, u16 flags)
+int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
+					   struct nlmsghdr *nlh, u16 flags)
 {
 	struct net_device *lower_dev;
 	struct list_head *iter;
@@ -228,16 +228,16 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
 		return ret;
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = netdev_switch_port_bridge_dellink(lower_dev, nlh, flags);
+		err = switchdev_port_bridge_dellink(lower_dev, nlh, flags);
 		if (err && err != -EOPNOTSUPP)
 			ret = err;
 	}
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_bridge_dellink);
+EXPORT_SYMBOL_GPL(ndo_dflt_switchdev_port_bridge_dellink);
 
-static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
+static struct net_device *switchdev_get_lowest_dev(struct net_device *dev)
 {
 	const struct swdev_ops *ops = dev->swdev_ops;
 	struct net_device *lower_dev;
@@ -253,7 +253,7 @@ static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 		return dev;
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		port_dev = netdev_switch_get_lowest_dev(lower_dev);
+		port_dev = switchdev_get_lowest_dev(lower_dev);
 		if (port_dev)
 			return port_dev;
 	}
@@ -261,7 +261,7 @@ static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 	return NULL;
 }
 
-static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
+static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 {
 	struct netdev_phys_item_id psid;
 	struct netdev_phys_item_id prev_psid;
@@ -276,11 +276,11 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
 		if (!nh->nh_dev)
 			return NULL;
 
-		dev = netdev_switch_get_lowest_dev(nh->nh_dev);
+		dev = switchdev_get_lowest_dev(nh->nh_dev);
 		if (!dev)
 			return NULL;
 
-		if (netdev_switch_parent_id_get(dev, &psid))
+		if (switchdev_parent_id_get(dev, &psid))
 			return NULL;
 
 		if (nhsel > 0) {
@@ -297,7 +297,7 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
 }
 
 /**
- *	netdev_switch_fib_ipv4_add - Add IPv4 route entry to switch
+ *	switchdev_fib_ipv4_add - Add IPv4 route entry to switch
  *
  *	@dst: route's IPv4 destination address
  *	@dst_len: destination address length (prefix length)
@@ -309,8 +309,8 @@ static struct net_device *netdev_switch_get_dev_by_nhs(struct fib_info *fi)
  *
  *	Add IPv4 route entry to switch device.
  */
-int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
-			       u8 tos, u8 type, u32 nlflags, u32 tb_id)
+int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
+			   u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
 	struct net_device *dev;
 	const struct swdev_ops *ops;
@@ -328,7 +328,7 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	if (fi->fib_net->ipv4.fib_offload_disabled)
 		return 0;
 
-	dev = netdev_switch_get_dev_by_nhs(fi);
+	dev = switchdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
 	ops = dev->swdev_ops;
@@ -343,10 +343,10 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_add);
+EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_add);
 
 /**
- *	netdev_switch_fib_ipv4_del - Delete IPv4 route entry from switch
+ *	switchdev_fib_ipv4_del - Delete IPv4 route entry from switch
  *
  *	@dst: route's IPv4 destination address
  *	@dst_len: destination address length (prefix length)
@@ -357,8 +357,8 @@ EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_add);
  *
  *	Delete IPv4 route entry from switch device.
  */
-int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
-			       u8 tos, u8 type, u32 tb_id)
+int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
+			   u8 tos, u8 type, u32 tb_id)
 {
 	struct net_device *dev;
 	const struct swdev_ops *ops;
@@ -367,7 +367,7 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
 		return 0;
 
-	dev = netdev_switch_get_dev_by_nhs(fi);
+	dev = switchdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
 	ops = dev->swdev_ops;
@@ -381,14 +381,14 @@ int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 
 	return err;
 }
-EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_del);
+EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_del);
 
 /**
- *	netdev_switch_fib_ipv4_abort - Abort an IPv4 FIB operation
+ *	switchdev_fib_ipv4_abort - Abort an IPv4 FIB operation
  *
  *	@fi: route FIB info structure
  */
-void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
+void switchdev_fib_ipv4_abort(struct fib_info *fi)
 {
 	/* There was a problem installing this route to the offload
 	 * device.  For now, until we come up with more refined
@@ -401,4 +401,4 @@ void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
 	fib_flush_external(fi->fib_net);
 	fi->fib_net->ipv4.fib_offload_disabled = true;
 }
-EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_abort);
+EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_abort);
-- 
1.9.3
