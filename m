From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] rtnl_fdb_dump: catch errors from ndo_fdb_dump and ndo_dflt_fdb_dump
Date: Wed, 23 Sep 2015 09:21:01 -0700
Message-ID: <1443025261-14951-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com,
	jiri@resnulli.us, sfeldma@gmail.com, stephen@networkplumber.org,
	jhs@mojatatu.com, wkok@cumulusnetworks.com,
	nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33488 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755077AbbIWQVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 12:21:06 -0400
Received: by pacex6 with SMTP id ex6so44638844pac.0
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 09:21:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wilson Kok <wkok@cumulusnetworks.com>

current ndo_fdb_dump and ndo_dflt_fdb_dump always return the current
fdb index. They dont return errors. Which results in fdb dumps
continuing on errors.

In one such case where bridges and vxlan devices were involved,
bridge driver returned -EMSGSIZE on a bridge, but since it continued
on error, the next vxlan device fdb dump (which was smaller in size)
succeeded, leaving fdb idx at an inconsistent value. This
resulted in the bridge fdb entry getting skipped and vxlan
fdb entry getting dumped twice.

This patch changes ndo_fdb_dump() to return the status and pass the
idx by reference for update. The dump aborts if non-zero status is
returned.

Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  6 +++---
 drivers/net/vxlan.c                              | 12 ++++++------
 include/linux/netdevice.h                        |  4 ++--
 include/linux/rtnetlink.h                        |  2 +-
 include/net/switchdev.h                          |  4 ++--
 net/bridge/br_fdb.c                              | 21 +++++++++++++--------
 net/bridge/br_private.h                          |  2 +-
 net/core/rtnetlink.c                             | 24 +++++++++++++++---------
 net/switchdev/switchdev.c                        | 12 ++++++++----
 9 files changed, 51 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index d448145..546842a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -433,7 +433,7 @@ static int qlcnic_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 
 static int qlcnic_fdb_dump(struct sk_buff *skb, struct netlink_callback *ncb,
 			struct net_device *netdev,
-			struct net_device *filter_dev, int idx)
+			struct net_device *filter_dev, int *idx)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
@@ -442,9 +442,9 @@ static int qlcnic_fdb_dump(struct sk_buff *skb, struct netlink_callback *ncb,
 
 	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
 	    qlcnic_sriov_check(adapter))
-		idx = ndo_dflt_fdb_dump(skb, ncb, netdev, filter_dev, idx);
+		return ndo_dflt_fdb_dump(skb, ncb, netdev, filter_dev, idx);
 
-	return idx;
+	return 0;
 }
 
 static void qlcnic_82xx_cancel_idc_work(struct qlcnic_adapter *adapter)
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index bbac1d3..68c92c2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -911,20 +911,20 @@ out:
 /* Dump forwarding table */
 static int vxlan_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			  struct net_device *dev,
-			  struct net_device *filter_dev, int idx)
+			  struct net_device *filter_dev, int *idx)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	unsigned int h;
+	int err = 0;
 
 	for (h = 0; h < FDB_HASH_SIZE; ++h) {
 		struct vxlan_fdb *f;
-		int err;
 
 		hlist_for_each_entry_rcu(f, &vxlan->fdb_head[h], hlist) {
 			struct vxlan_rdst *rd;
 
 			list_for_each_entry_rcu(rd, &f->remotes, list) {
-				if (idx < cb->args[0])
+				if (*idx < cb->args[0])
 					goto skip;
 
 				err = vxlan_fdb_info(skb, vxlan, f,
@@ -932,15 +932,15 @@ static int vxlan_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 						     cb->nlh->nlmsg_seq,
 						     RTM_NEWNEIGH,
 						     NLM_F_MULTI, rd);
-				if (err < 0)
+				if (err)
 					goto out;
 skip:
-				++idx;
+				*idx += 1;
 			}
 		}
 	}
 out:
-	return idx;
+	return err;
 }
 
 /* Watch incoming packets to learn mapping between Ethernet address
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 88a0069..87fcacc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -976,7 +976,7 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Deletes the FDB entry from dev coresponding to addr.
  * int (*ndo_fdb_dump)(struct sk_buff *skb, struct netlink_callback *cb,
  *		       struct net_device *dev, struct net_device *filter_dev,
- *		       int idx)
+ *		       int *idx)
  *	Used to add FDB entries to dump requests. Implementers should add
  *	entries to skb and update idx with the number of entries.
  *
@@ -1182,7 +1182,7 @@ struct net_device_ops {
 						struct netlink_callback *cb,
 						struct net_device *dev,
 						struct net_device *filter_dev,
-						int idx);
+						int *idx);
 
 	int			(*ndo_bridge_setlink)(struct net_device *dev,
 						      struct nlmsghdr *nlh,
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 39adaa9..a44a7fa 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -99,7 +99,7 @@ extern int ndo_dflt_fdb_dump(struct sk_buff *skb,
 			     struct netlink_callback *cb,
 			     struct net_device *dev,
 			     struct net_device *filter_dev,
-			     int idx);
+			     int *idx);
 extern int ndo_dflt_fdb_add(struct ndmsg *ndm,
 			    struct nlattr *tb[],
 			    struct net_device *dev,
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 319baab..2ffee1a 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -157,7 +157,7 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			   u16 vid);
 int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *dev,
-			    struct net_device *filter_dev, int idx);
+			    struct net_device *filter_dev, int *idx);
 void switchdev_port_fwd_mark_set(struct net_device *dev,
 				 struct net_device *group_dev,
 				 bool joining);
@@ -270,7 +270,7 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
 					  struct netlink_callback *cb,
 					  struct net_device *dev,
 					  struct net_device *filter_dev,
-					  int idx)
+					  int *idx)
 {
 	return -EOPNOTSUPP;
 }
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 9e9875d..f9f5d40 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -699,22 +699,26 @@ int br_fdb_dump(struct sk_buff *skb,
 		struct netlink_callback *cb,
 		struct net_device *dev,
 		struct net_device *filter_dev,
-		int idx)
+		int *idx)
 {
 	struct net_bridge *br = netdev_priv(dev);
+	int err = 0;
 	int i;
 
 	if (!(dev->priv_flags & IFF_EBRIDGE))
 		goto out;
 
-	if (!filter_dev)
-		idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+	if (!filter_dev) {
+		err = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+		if (err)
+			goto out;
+	}
 
 	for (i = 0; i < BR_HASH_SIZE; i++) {
 		struct net_bridge_fdb_entry *f;
 
 		hlist_for_each_entry_rcu(f, &br->hash[i], hlist) {
-			if (idx < cb->args[0])
+			if (*idx < cb->args[0])
 				goto skip;
 
 			if (filter_dev &&
@@ -732,19 +736,20 @@ int br_fdb_dump(struct sk_buff *skb,
 			if (!filter_dev && f->dst)
 				goto skip;
 
-			if (fdb_fill_info(skb, br, f,
+			err = fdb_fill_info(skb, br, f,
 					  NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq,
 					  RTM_NEWNEIGH,
-					  NLM_F_MULTI) < 0)
+					  NLM_F_MULTI);
+			if (err)
 				break;
 skip:
-			++idx;
+			*idx += 1;
 		}
 	}
 
 out:
-	return idx;
+	return err;
 }
 
 /* Update (create or replace) forwarding database entry */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 213baf7..20eb05b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -403,7 +403,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
 	       const unsigned char *addr, u16 vid, u16 nlh_flags);
 int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct net_device *dev, struct net_device *fdev, int idx);
+		struct net_device *dev, struct net_device *fdev, int *idx);
 int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
 void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
 int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 0ec4840..b4d5635 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2847,18 +2847,18 @@ int ndo_dflt_fdb_dump(struct sk_buff *skb,
 		      struct netlink_callback *cb,
 		      struct net_device *dev,
 		      struct net_device *filter_dev,
-		      int idx)
+		      int *idx)
 {
 	int err;
 
 	netif_addr_lock_bh(dev);
-	err = nlmsg_populate_fdb(skb, cb, dev, &idx, &dev->uc);
+	err = nlmsg_populate_fdb(skb, cb, dev, idx, &dev->uc);
 	if (err)
 		goto out;
-	nlmsg_populate_fdb(skb, cb, dev, &idx, &dev->mc);
+	nlmsg_populate_fdb(skb, cb, dev, idx, &dev->mc);
 out:
 	netif_addr_unlock_bh(dev);
-	return idx;
+	return err;
 }
 EXPORT_SYMBOL(ndo_dflt_fdb_dump);
 
@@ -2874,6 +2874,7 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int brport_idx = 0;
 	int br_idx = 0;
 	int idx = 0;
+	int err = 0;
 
 	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
 			ifla_policy) == 0) {
@@ -2915,19 +2916,24 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 		if (dev->priv_flags & IFF_BRIDGE_PORT) {
 			if (cops && cops->ndo_fdb_dump)
-				idx = cops->ndo_fdb_dump(skb, cb, br_dev, dev,
-							 idx);
+				err = cops->ndo_fdb_dump(skb, cb, br_dev, dev,
+							 &idx);
+				if (err && err != -EOPNOTSUPP)
+					goto out;
 		}
 
 		if (dev->netdev_ops->ndo_fdb_dump)
-			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, NULL,
-							    idx);
+			err = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, NULL,
+							    &idx);
 		else
-			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
+			err = ndo_dflt_fdb_dump(skb, cb, dev, NULL, &idx);
+		if (err && err != -EOPNOTSUPP)
+			goto out;
 
 		cops = NULL;
 	}
 
+out:
 	cb->args[0] = idx;
 	return skb->len;
 }
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index fda38f8..5f1754c 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -842,8 +842,10 @@ nla_put_failure:
  */
 int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *dev,
-			    struct net_device *filter_dev, int idx)
+			    struct net_device *filter_dev, int *idx)
 {
+	int err;
+
 	struct switchdev_fdb_dump dump = {
 		.obj = {
 			.id = SWITCHDEV_OBJ_PORT_FDB,
@@ -851,11 +853,13 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		},
 		.skb = skb,
 		.cb = cb,
-		.idx = idx,
+		.idx = *idx,
 	};
 
-	switchdev_port_obj_dump(dev, &dump.obj);
-	return dump.idx;
+	err = switchdev_port_obj_dump(dev, &dump.obj);
+	*idx = dump.idx;
+
+	return err;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_dump);
 
-- 
1.9.1
