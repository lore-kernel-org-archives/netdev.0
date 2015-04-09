From: "Sokolowski, Hubert" <hubert.sokolowski@intel.com>
Subject: [PATCH net-next] net: Pass VLAN ID to rtnl_fdb_notify.
Date: Thu, 9 Apr 2015 12:16:17 +0000
Message-ID: <C039B2B452EFF24BA495644ED97341911BD52B94@IRSMSX107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Varlese, Marco" <marco.varlese@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:29645 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753605AbbDIMQZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 08:16:25 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an FDB entry is added or deleted the information about VLAN
is not passed to listening applications like 'bridge monitor fdb'.
With this patch VLAN ID is passed if it was set in the original
netlink message.

Also remove an unused bdev variable.

Signed-off-by: Hubert Sokolowski <hubert.sokolowski@intel.com>
---
 net/core/rtnetlink.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5e02260..c3bf190 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2404,7 +2404,7 @@ EXPORT_SYMBOL(rtmsg_ifinfo);
 
 static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
 				   struct net_device *dev,
-				   u8 *addr, u32 pid, u32 seq,
+				   u8 *addr, u16 vid, u32 pid, u32 seq,
 				   int type, unsigned int flags,
 				   int nlflags)
 {
@@ -2426,6 +2426,9 @@ static int nlmsg_populate_fdb_fill(struct sk_buff *skb,
 
 	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, addr))
 		goto nla_put_failure;
+	if (vid)
+		if (nla_put(skb, NDA_VLAN, sizeof(u16), &vid))
+			goto nla_put_failure;
 
 	nlmsg_end(skb, nlh);
 	return 0;
@@ -2440,7 +2443,7 @@ static inline size_t rtnl_fdb_nlmsg_size(void)
 	return NLMSG_ALIGN(sizeof(struct ndmsg)) + nla_total_size(ETH_ALEN);
 }
 
-static void rtnl_fdb_notify(struct net_device *dev, u8 *addr, int type)
+static void rtnl_fdb_notify(struct net_device *dev, u8 *addr, u16 vid, int type)
 {
 	struct net *net = dev_net(dev);
 	struct sk_buff *skb;
@@ -2450,7 +2453,8 @@ static void rtnl_fdb_notify(struct net_device *dev, u8 *addr, int type)
 	if (!skb)
 		goto errout;
 
-	err = nlmsg_populate_fdb_fill(skb, dev, addr, 0, 0, type, NTF_SELF, 0);
+	err = nlmsg_populate_fdb_fill(skb, dev, addr, vid,
+				      0, 0, type, NTF_SELF, 0);
 	if (err < 0) {
 		kfree_skb(skb);
 		goto errout;
@@ -2585,7 +2589,7 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 					       nlh->nlmsg_flags);
 
 		if (!err) {
-			rtnl_fdb_notify(dev, addr, RTM_NEWNEIGH);
+			rtnl_fdb_notify(dev, addr, vid, RTM_NEWNEIGH);
 			ndm->ndm_flags &= ~NTF_SELF;
 		}
 	}
@@ -2686,7 +2690,7 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 			err = ndo_dflt_fdb_del(ndm, tb, dev, addr, vid);
 
 		if (!err) {
-			rtnl_fdb_notify(dev, addr, RTM_DELNEIGH);
+			rtnl_fdb_notify(dev, addr, vid, RTM_DELNEIGH);
 			ndm->ndm_flags &= ~NTF_SELF;
 		}
 	}
@@ -2711,7 +2715,7 @@ static int nlmsg_populate_fdb(struct sk_buff *skb,
 		if (*idx < cb->args[0])
 			goto skip;
 
-		err = nlmsg_populate_fdb_fill(skb, dev, ha->addr,
+		err = nlmsg_populate_fdb_fill(skb, dev, ha->addr, 0,
 					      portid, seq,
 					      RTM_NEWNEIGH, NTF_SELF,
 					      NLM_F_MULTI);
@@ -2754,7 +2758,6 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net_device *dev;
 	struct nlattr *tb[IFLA_MAX+1];
-	struct net_device *bdev = NULL;
 	struct net_device *br_dev = NULL;
 	const struct net_device_ops *ops = NULL;
 	const struct net_device_ops *cops = NULL;
@@ -2778,7 +2781,6 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			return -ENODEV;
 
 		ops = br_dev->netdev_ops;
-		bdev = br_dev;
 	}
 
 	for_each_netdev(net, dev) {
@@ -2791,7 +2793,6 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 				cops = br_dev->netdev_ops;
 			}
 
-			bdev = dev;
 		} else {
 			if (dev != br_dev &&
 			    !(dev->priv_flags & IFF_BRIDGE_PORT))
@@ -2801,7 +2802,6 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 			    !(dev->priv_flags & IFF_EBRIDGE))
 				continue;
 
-			bdev = br_dev;
 			cops = ops;
 		}
 
-- 
1.9.3
