From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] rtnetlink: fdb dump: optimize by saving last interface markers
Date: Tue, 30 Aug 2016 21:56:45 -0700
Message-ID: <1472619405-50802-1-git-send-email-roopa@cumulusnetworks.com>
Cc: nikolay@cumulusnetworks.com, wkok@cumulusnetworks.com,
        stephen@networkplumber.org, jhs@mojatatu.com,
        makita.toshiaki@lab.ntt.co.jp, jiri@resnulli.us,
        idosch@mellanox.com, netdev@vger.kernel.org, minoura@valinux.co.jp,
        Dept-GELinuxNICDev@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36664 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcHaE6r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 00:58:47 -0400
Received: by mail-pf0-f179.google.com with SMTP id h186so15227108pfg.3
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 21:58:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

fdb dumps spanning multiple skb's currently restart from the first
interface again for every skb. This results in unnecessary
iterations on the already visited interfaces and their fdb
entries. In large scale setups, we have seen this to slow
down fdb dumps considerably. On a system with 30k macs we
see fdb dumps spanning across more than 300 skbs.

To fix the problem, this patch replaces the existing single fdb
marker with three markers: netdev hash entries, netdevs and fdb
index to continue where we left off instead of restarting from the
first netdev. This is consistent with link dumps.

In the process of fixing the performance issue, this patch also
re-implements fix done by
commit 472681d57a5d ("net: ndo_fdb_dump should report -EMSGSIZE to rtnl_fdb_dump")
(with an internal fix from Wilson Kok) in the following ways:
- change ndo_fdb_dump handlers to return error code instead
of the last fdb index
- use cb->args strictly for dump frag markers and not error codes.
This is consistent with other dump functions.

Below results were taken on a system with 1000 netdevs
and 35085 fdb entries:
before patch:
$time bridge fdb show | wc -l
15065

real    1m11.791s
user    0m0.070s
sys 1m8.395s

(existing code does not return all macs)

after patch:
$time bridge fdb show | wc -l
35085

real    0m2.017s
user    0m0.113s
sys 0m1.942s

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   7 +-
 drivers/net/vxlan.c                              |  14 ++-
 include/linux/netdevice.h                        |   4 +-
 include/linux/rtnetlink.h                        |   2 +-
 include/net/switchdev.h                          |   4 +-
 net/bridge/br_fdb.c                              |  23 ++---
 net/bridge/br_private.h                          |   2 +-
 net/core/rtnetlink.c                             | 105 ++++++++++++++---------
 net/switchdev/switchdev.c                        |  10 +--
 9 files changed, 98 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 3ebef27..3ae3968 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -432,18 +432,19 @@ static int qlcnic_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 
 static int qlcnic_fdb_dump(struct sk_buff *skb, struct netlink_callback *ncb,
 			struct net_device *netdev,
-			struct net_device *filter_dev, int idx)
+			struct net_device *filter_dev, int *idx)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	int err = 0;
 
 	if (!adapter->fdb_mac_learn)
 		return ndo_dflt_fdb_dump(skb, ncb, netdev, filter_dev, idx);
 
 	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
 	    qlcnic_sriov_check(adapter))
-		idx = ndo_dflt_fdb_dump(skb, ncb, netdev, filter_dev, idx);
+		err = ndo_dflt_fdb_dump(skb, ncb, netdev, filter_dev, idx);
 
-	return idx;
+	return err;
 }
 
 static void qlcnic_82xx_cancel_idc_work(struct qlcnic_adapter *adapter)
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index c0dda6f..f5b381d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -861,20 +861,20 @@ out:
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
+				if (*idx < cb->args[2])
 					goto skip;
 
 				err = vxlan_fdb_info(skb, vxlan, f,
@@ -882,17 +882,15 @@ static int vxlan_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 						     cb->nlh->nlmsg_seq,
 						     RTM_NEWNEIGH,
 						     NLM_F_MULTI, rd);
-				if (err < 0) {
-					cb->args[1] = err;
+				if (err < 0)
 					goto out;
-				}
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
index d122be9..67bb978 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1031,7 +1031,7 @@ struct netdev_xdp {
  *	Deletes the FDB entry from dev coresponding to addr.
  * int (*ndo_fdb_dump)(struct sk_buff *skb, struct netlink_callback *cb,
  *		       struct net_device *dev, struct net_device *filter_dev,
- *		       int idx)
+ *		       int *idx)
  *	Used to add FDB entries to dump requests. Implementers should add
  *	entries to skb and update idx with the number of entries.
  *
@@ -1263,7 +1263,7 @@ struct net_device_ops {
 						struct netlink_callback *cb,
 						struct net_device *dev,
 						struct net_device *filter_dev,
-						int idx);
+						int *idx);
 
 	int			(*ndo_bridge_setlink)(struct net_device *dev,
 						      struct nlmsghdr *nlh,
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 2daece8..57e5484 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -105,7 +105,7 @@ extern int ndo_dflt_fdb_dump(struct sk_buff *skb,
 			     struct netlink_callback *cb,
 			     struct net_device *dev,
 			     struct net_device *filter_dev,
-			     int idx);
+			     int *idx);
 extern int ndo_dflt_fdb_add(struct ndmsg *ndm,
 			    struct nlattr *tb[],
 			    struct net_device *dev,
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 82f5e04..6279f2f 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -222,7 +222,7 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 			   u16 vid);
 int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *dev,
-			    struct net_device *filter_dev, int idx);
+			    struct net_device *filter_dev, int *idx);
 void switchdev_port_fwd_mark_set(struct net_device *dev,
 				 struct net_device *group_dev,
 				 bool joining);
@@ -342,7 +342,7 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
 					  struct netlink_callback *cb,
 					  struct net_device *dev,
 					  struct net_device *filter_dev,
-					  int idx)
+					  int *idx)
 {
        return idx;
 }
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index cd620fa..6b43c8c 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -710,24 +710,27 @@ int br_fdb_dump(struct sk_buff *skb,
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
+		if (err < 0)
+			goto out;
+	}
 
 	for (i = 0; i < BR_HASH_SIZE; i++) {
 		struct net_bridge_fdb_entry *f;
 
 		hlist_for_each_entry_rcu(f, &br->hash[i], hlist) {
-			int err;
 
-			if (idx < cb->args[0])
+			if (*idx < cb->args[2])
 				goto skip;
 
 			if (filter_dev &&
@@ -750,17 +753,15 @@ int br_fdb_dump(struct sk_buff *skb,
 					    cb->nlh->nlmsg_seq,
 					    RTM_NEWNEIGH,
 					    NLM_F_MULTI);
-			if (err < 0) {
-				cb->args[1] = err;
-				break;
-			}
+			if (err < 0)
+				goto out;
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
index 2379b2b..3d36493 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -508,7 +508,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
 	       const unsigned char *addr, u16 vid, u16 nlh_flags);
 int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct net_device *dev, struct net_device *fdev, int idx);
+		struct net_device *dev, struct net_device *fdev, int *idx);
 int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
 void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
 int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 318fc52..1dfca1c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3068,7 +3068,7 @@ static int nlmsg_populate_fdb(struct sk_buff *skb,
 	seq = cb->nlh->nlmsg_seq;
 
 	list_for_each_entry(ha, &list->list, list) {
-		if (*idx < cb->args[0])
+		if (*idx < cb->args[2])
 			goto skip;
 
 		err = nlmsg_populate_fdb_fill(skb, dev, ha->addr, 0,
@@ -3095,19 +3095,18 @@ int ndo_dflt_fdb_dump(struct sk_buff *skb,
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
-	cb->args[1] = err;
-	return idx;
+	return err;
 }
 EXPORT_SYMBOL(ndo_dflt_fdb_dump);
 
@@ -3120,9 +3119,13 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	const struct net_device_ops *cops = NULL;
 	struct ifinfomsg *ifm = nlmsg_data(cb->nlh);
 	struct net *net = sock_net(skb->sk);
+	struct hlist_head *head;
 	int brport_idx = 0;
 	int br_idx = 0;
-	int idx = 0;
+	int h, s_h;
+	int idx = 0, s_idx;
+	int err = 0;
+	int fidx = 0;
 
 	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
 			ifla_policy) == 0) {
@@ -3140,49 +3143,71 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		ops = br_dev->netdev_ops;
 	}
 
-	cb->args[1] = 0;
-	for_each_netdev(net, dev) {
-		if (brport_idx && (dev->ifindex != brport_idx))
-			continue;
+	s_h = cb->args[0];
+	s_idx = cb->args[1];
 
-		if (!br_idx) { /* user did not specify a specific bridge */
-			if (dev->priv_flags & IFF_BRIDGE_PORT) {
-				br_dev = netdev_master_upper_dev_get(dev);
-				cops = br_dev->netdev_ops;
-			}
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		hlist_for_each_entry(dev, head, index_hlist) {
 
-		} else {
-			if (dev != br_dev &&
-			    !(dev->priv_flags & IFF_BRIDGE_PORT))
+			if (brport_idx && (dev->ifindex != brport_idx))
 				continue;
 
-			if (br_dev != netdev_master_upper_dev_get(dev) &&
-			    !(dev->priv_flags & IFF_EBRIDGE))
-				continue;
+			if (!br_idx) { /* user did not specify a specific bridge */
+				if (dev->priv_flags & IFF_BRIDGE_PORT) {
+					br_dev = netdev_master_upper_dev_get(dev);
+					cops = br_dev->netdev_ops;
+				}
+			} else {
+				if (dev != br_dev &&
+				    !(dev->priv_flags & IFF_BRIDGE_PORT))
+					continue;
 
-			cops = ops;
-		}
+				if (br_dev != netdev_master_upper_dev_get(dev) &&
+				    !(dev->priv_flags & IFF_EBRIDGE))
+					continue;
+				cops = ops;
+			}
 
-		if (dev->priv_flags & IFF_BRIDGE_PORT) {
-			if (cops && cops->ndo_fdb_dump)
-				idx = cops->ndo_fdb_dump(skb, cb, br_dev, dev,
-							 idx);
-		}
-		if (cb->args[1] == -EMSGSIZE)
-			break;
+			if (idx < s_idx)
+				goto cont;
 
-		if (dev->netdev_ops->ndo_fdb_dump)
-			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, NULL,
-							    idx);
-		else
-			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
-		if (cb->args[1] == -EMSGSIZE)
-			break;
+			if (dev->priv_flags & IFF_BRIDGE_PORT) {
+				if (cops && cops->ndo_fdb_dump) {
+					err = cops->ndo_fdb_dump(skb, cb,
+								br_dev, dev,
+								&fidx);
+					if (err == -EMSGSIZE)
+						goto out;
+				}
+			}
 
-		cops = NULL;
+			if (dev->netdev_ops->ndo_fdb_dump)
+				err = dev->netdev_ops->ndo_fdb_dump(skb, cb,
+								    dev, NULL,
+								    &fidx);
+			else
+				err = ndo_dflt_fdb_dump(skb, cb, dev, NULL,
+							&fidx);
+			if (err == -EMSGSIZE)
+				goto out;
+
+			cops = NULL;
+
+			/* reset fdb offset to 0 for rest of the interfaces */
+			cb->args[2] = 0;
+			fidx = 0;
+cont:
+			idx++;
+		}
 	}
 
-	cb->args[0] = idx;
+out:
+	cb->args[0] = h;
+	cb->args[1] = idx;
+	cb->args[2] = fidx;
+
 	return skb->len;
 }
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 1031a03..10b8193 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1042,7 +1042,7 @@ static int switchdev_port_fdb_dump_cb(struct switchdev_obj *obj)
 	struct nlmsghdr *nlh;
 	struct ndmsg *ndm;
 
-	if (dump->idx < dump->cb->args[0])
+	if (dump->idx < dump->cb->args[2])
 		goto skip;
 
 	nlh = nlmsg_put(dump->skb, portid, seq, RTM_NEWNEIGH,
@@ -1089,7 +1089,7 @@ nla_put_failure:
  */
 int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *dev,
-			    struct net_device *filter_dev, int idx)
+			    struct net_device *filter_dev, int *idx)
 {
 	struct switchdev_fdb_dump dump = {
 		.fdb.obj.orig_dev = dev,
@@ -1097,14 +1097,14 @@ int switchdev_port_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
 		.dev = dev,
 		.skb = skb,
 		.cb = cb,
-		.idx = idx,
+		.idx = *idx,
 	};
 	int err;
 
 	err = switchdev_port_obj_dump(dev, &dump.fdb.obj,
 				      switchdev_port_fdb_dump_cb);
-	cb->args[1] = err;
-	return dump.idx;
+	*idx = dump.idx;
+	return err;
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_dump);
 
-- 
1.9.1
