From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v4 3/4] rtnetlink: add helpers to dump netnsid information
Date: Tue, 26 Sep 2017 13:58:42 +0200
Message-ID: <20170926115843.12013-4-fw@strlen.de>
References: <20170926115843.12013-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58792 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S964827AbdIZL6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 07:58:36 -0400
In-Reply-To: <20170926115843.12013-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reviewed-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 No changes in v4.

 net/core/rtnetlink.c | 30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d504e78cd01f..d524609c587c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1362,6 +1362,23 @@ static int nla_put_iflink(struct sk_buff *skb, const struct net_device *dev)
 	return nla_put_u32(skb, IFLA_LINK, ifindex);
 }
 
+static int rtnl_fill_link_netnsid(struct sk_buff *skb,
+				  const struct net_device *dev)
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
@@ -1451,17 +1468,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
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
