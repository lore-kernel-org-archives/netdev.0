From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v3 1/2] bridge: fdb dumping takes a filter device
Date: Wed, 25 Jun 2014 06:21:22 -0400
Message-ID: <1403691683-14290-2-git-send-email-jhs@emojatatu.com>
References: <1403691683-14290-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:61108 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756126AbaFYKVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 06:21:45 -0400
Received: by mail-pd0-f174.google.com with SMTP id y10so1471169pdj.5
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 03:21:44 -0700 (PDT)
In-Reply-To: <1403691683-14290-1-git-send-email-jhs@emojatatu.com>
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
index b167fc2..6d2df6d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7029,13 +7029,14 @@ static int i40e_ndo_fdb_del(struct ndmsg *ndm,
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
index 4fc1867..b82179d 100644
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
index 66f9a04..8d46984 100644
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
index 7be3366..6edecd1 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -676,6 +676,7 @@ errout:
 int br_fdb_dump(struct sk_buff *skb,
 		struct netlink_callback *cb,
 		struct net_device *dev,
+		struct net_device *filter_dev,
 		int idx)
 {
 	struct net_bridge *br = netdev_priv(dev);
@@ -691,6 +692,10 @@ int br_fdb_dump(struct sk_buff *skb,
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
index 23caf5b..62a7fa2 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -399,7 +399,7 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
 	       const unsigned char *addr, u16 nlh_flags);
 int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
-		struct net_device *dev, int idx);
+		struct net_device *dev, struct net_device *fdev, int idx);
 int br_fdb_sync_static(struct net_bridge *br, struct net_bridge_port *p);
 void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1063996..7471060 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2509,6 +2509,7 @@ skip:
 int ndo_dflt_fdb_dump(struct sk_buff *skb,
 		      struct netlink_callback *cb,
 		      struct net_device *dev,
+		      struct net_device *filter_dev,
 		      int idx)
 {
 	int err;
@@ -2539,13 +2540,13 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
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
