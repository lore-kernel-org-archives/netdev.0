From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH 1/2] bridge: fdb dumping takes a filter device
Date: Sat,  7 Jun 2014 10:27:23 -0400
Message-ID: <1402151244-3324-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:41198 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbaFGO1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 10:27:39 -0400
Received: by mail-ig0-f176.google.com with SMTP id a13so1872835igq.9
        for <netdev@vger.kernel.org>; Sat, 07 Jun 2014 07:27:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

 Dumping a bridge fdb dumps every fdb entry
 held. With this change we are going to filter
 on selected bridge port.

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c      |    3 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    5 +++--
 include/linux/netdevice.h                        |    1 +
 include/linux/rtnetlink.h                        |    1 +
 net/bridge/br_fdb.c                              |    5 +++++
 net/bridge/br_private.h                          |    2 +-
 net/core/rtnetlink.c                             |    7 ++++---
 7 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 63147a6..7bc806c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6817,13 +6817,14 @@ static int i40e_ndo_fdb_del(struct ndmsg *ndm,
 static int i40e_ndo_fdb_dump(struct sk_buff *skb,
 			     struct netlink_callback *cb,
 			     struct net_device *dev,
+			     struct net_device *filter_dev,
 			     int idx)
 {
 	struct i40e_netdev_priv *np = netdev_priv(dev);
 	struct i40e_pf *pf = np->vsi->back;
 
 	if (pf->flags & I40E_FLAG_SRIOV_ENABLED)
-		idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
+		idx = ndo_dflt_fdb_dump(skb, cb, dev, filter_dev, idx);
 
 	return idx;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index f06ba90b..233f282 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -427,12 +427,13 @@ static int qlcnic_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 }
 
 static int qlcnic_fdb_dump(struct sk_buff *skb, struct netlink_callback *ncb,
-			struct net_device *netdev, int idx)
+			struct net_device *netdev, struct net_device *filter_dev,
+			int idx)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 
 	if (!adapter->fdb_mac_learn)
-		return ndo_dflt_fdb_dump(skb, ncb, netdev, idx);
+		return ndo_dflt_fdb_dump(skb, ncb, netdev, filter_dev, idx);
 
 	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
 	    qlcnic_sriov_check(adapter))
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 774e539..a464057 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1114,6 +1114,7 @@ struct net_device_ops {
 	int			(*ndo_fdb_dump)(struct sk_buff *skb,
 						struct netlink_callback *cb,
 						struct net_device *dev,
+						struct net_device *filter_dev,
 						int idx);
 
 	int			(*ndo_bridge_setlink)(struct net_device *dev,
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 953937e..167bae7 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -78,6 +78,7 @@ extern void __rtnl_unlock(void);
 extern int ndo_dflt_fdb_dump(struct sk_buff *skb,
 			     struct netlink_callback *cb,
 			     struct net_device *dev,
+			     struct net_device *filter_dev,
 			     int idx);
 extern int ndo_dflt_fdb_add(struct ndmsg *ndm,
 			    struct nlattr *tb[],
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index b524c36..48449fc 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -678,6 +678,7 @@ errout:
 int br_fdb_dump(struct sk_buff *skb,
 		struct netlink_callback *cb,
 		struct net_device *dev,
+		struct net_device *filter_dev,
 		int idx)
 {
 	struct net_bridge *br = netdev_priv(dev);
@@ -693,6 +694,10 @@ int br_fdb_dump(struct sk_buff *skb,
 			if (idx < cb->args[0])
 				goto skip;
 
+			if (filter_dev && (!f->dst || !f->dst->dev ||
+					   f->dst->dev != filter_dev))
+				goto skip;
+
 			if (fdb_fill_info(skb, br, f,
 					  NETLINK_CB(cb->skb).portid,
 					  cb->nlh->nlmsg_seq,
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index bc17210..d72daf3 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -398,7 +398,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
 	       const unsigned char *addr, u16 nlh_flags);
 int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct net_device *dev, int idx);
+		struct net_device *dev, struct net_device *fdev, int idx);
 int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
 void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 741b22c..8721f1b 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2494,6 +2494,7 @@ skip:
 int ndo_dflt_fdb_dump(struct sk_buff *skb,
 		      struct netlink_callback *cb,
 		      struct net_device *dev,
+		      struct net_device *filter_dev,
 		      int idx)
 {
 	int err;
@@ -2524,13 +2525,13 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			br_dev = netdev_master_upper_dev_get(dev);
 			ops = br_dev->netdev_ops;
 			if (ops->ndo_fdb_dump)
-				idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
+				idx = ops->ndo_fdb_dump(skb, cb, dev, NULL, idx);
 		}
 
 		if (dev->netdev_ops->ndo_fdb_dump)
-			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, idx);
+			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, NULL, idx);
 		else
-			idx = ndo_dflt_fdb_dump(skb, cb, dev, idx);
+			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
 	}
 	rcu_read_unlock();
 
-- 
1.7.9.5
