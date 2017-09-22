From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v2 5/6] rtnetlink: add helpers to dump vf and netnsid information
Date: Fri, 22 Sep 2017 08:10:07 +0200
Message-ID: <20170922061008.14723-6-fw@strlen.de>
References: <20170922061008.14723-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41600 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751795AbdIVGKI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 02:10:08 -0400
In-Reply-To: <20170922061008.14723-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

similar to earlier patches, split out more parts of this function to
better see what is happening and where we assume rtnl is locked.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 80 ++++++++++++++++++++++++++++++++--------------------
 1 file changed, 50 insertions(+), 30 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 42ff582a010e..590823f70cc3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1211,6 +1211,36 @@ static noinline_for_stack int rtnl_fill_vfinfo(struct sk_buff *skb,
 	return -EMSGSIZE;
 }
 
+static noinline_for_stack int rtnl_fill_vf(struct sk_buff *skb,
+					   struct net_device *dev,
+					   u32 ext_filter_mask)
+{
+	struct nlattr *vfinfo;
+	int i, num_vfs;
+
+	if (!dev->dev.parent || ((ext_filter_mask & RTEXT_FILTER_VF) == 0))
+		return 0;
+
+	num_vfs = dev_num_vf(dev->dev.parent);
+	if (nla_put_u32(skb, IFLA_NUM_VF, num_vfs))
+		return -EMSGSIZE;
+
+	if (!dev->netdev_ops->ndo_get_vf_config)
+		return 0;
+
+	vfinfo = nla_nest_start(skb, IFLA_VFINFO_LIST);
+	if (!vfinfo)
+		return -EMSGSIZE;
+
+	for (i = 0; i < num_vfs; i++) {
+		if (rtnl_fill_vfinfo(skb, dev, i, vfinfo))
+			return -EMSGSIZE;
+	}
+
+	nla_nest_end(skb, vfinfo);
+	return 0;
+}
+
 static int rtnl_fill_link_ifmap(struct sk_buff *skb, struct net_device *dev)
 {
 	struct rtnl_link_ifmap map;
@@ -1355,6 +1385,23 @@ static noinline int nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static noinline int rtnl_fill_link_netnsid(struct sk_buff *skb,
+					   const struct net_device *dev)
+{
+	if (dev->rtnl_link_ops && dev->rtnl_link_ops->get_link_net) {
+		struct net *link_net = dev->rtnl_link_ops->get_link_net(dev);
+
+		if (!net_eq(dev_net(dev), link_net)) {
+			int id = peernet2id_alloc(dev_net(dev), link_net);
+
+			if (nla_put_s32(skb, IFLA_LINK_NETNSID, id))
+				return -EMSGSIZE;
+		}
+	}
+
+	return 0;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask,
@@ -1428,27 +1475,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (rtnl_fill_stats(skb, dev))
 		goto nla_put_failure;
 
-	if (dev->dev.parent && (ext_filter_mask & RTEXT_FILTER_VF) &&
-	    nla_put_u32(skb, IFLA_NUM_VF, dev_num_vf(dev->dev.parent)))
+	if (rtnl_fill_vf(skb, dev, ext_filter_mask))
 		goto nla_put_failure;
 
-	if (dev->netdev_ops->ndo_get_vf_config && dev->dev.parent &&
-	    ext_filter_mask & RTEXT_FILTER_VF) {
-		int i;
-		struct nlattr *vfinfo;
-		int num_vfs = dev_num_vf(dev->dev.parent);
-
-		vfinfo = nla_nest_start(skb, IFLA_VFINFO_LIST);
-		if (!vfinfo)
-			goto nla_put_failure;
-		for (i = 0; i < num_vfs; i++) {
-			if (rtnl_fill_vfinfo(skb, dev, i, vfinfo))
-				goto nla_put_failure;
-		}
-
-		nla_nest_end(skb, vfinfo);
-	}
-
 	if (rtnl_port_fill(skb, dev, ext_filter_mask))
 		goto nla_put_failure;
 
@@ -1460,17 +1489,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			goto nla_put_failure;
 	}
 
-	if (dev->rtnl_link_ops &&
-	    dev->rtnl_link_ops->get_link_net) {
-		struct net *link_net = dev->rtnl_link_ops->get_link_net(dev);
-
-		if (!net_eq(dev_net(dev), link_net)) {
-			int id = peernet2id_alloc(dev_net(dev), link_net);
-
-			if (nla_put_s32(skb, IFLA_LINK_NETNSID, id))
-				goto nla_put_failure;
-		}
-	}
+	if (rtnl_fill_link_netnsid(skb, dev))
+		goto nla_put_failure;
 
 	if (!(af_spec = nla_nest_start(skb, IFLA_AF_SPEC)))
 		goto nla_put_failure;
-- 
2.13.5
