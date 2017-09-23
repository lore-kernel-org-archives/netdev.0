From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v3 4/6] rtnetlink: add helpers to dump vf information
Date: Sat, 23 Sep 2017 21:26:34 +0200
Message-ID: <20170923192636.3932-5-fw@strlen.de>
References: <20170923192636.3932-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46828 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751726AbdIWT0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 15:26:32 -0400
In-Reply-To: <20170923192636.3932-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

similar to earlier patches, split out more parts of this function to
better see what is happening and where we assume rtnl is locked.

Reviewed-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 changes since v2: split this patch into two, last submission also
 added netnsid helper, which was moved to next patch.

 net/core/rtnetlink.c | 50 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 31 insertions(+), 19 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 47c17c3de79a..625342d27c44 100644
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
@@ -1414,27 +1444,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
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
 
-- 
2.13.5
