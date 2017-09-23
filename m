From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v3 5/6] rtnetlink: add helpers to dump netnsid information
Date: Sat, 23 Sep 2017 21:26:35 +0200
Message-ID: <20170923192636.3932-6-fw@strlen.de>
References: <20170923192636.3932-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46832 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751726AbdIWT0h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 15:26:37 -0400
In-Reply-To: <20170923192636.3932-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reviewed-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v2:
 this hunk was part of patch #4.

 net/core/rtnetlink.c | 30 +++++++++++++++++++-----------
 1 file changed, 19 insertions(+), 11 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 625342d27c44..e858a2b48d7e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1370,6 +1370,23 @@ static noinline int nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)
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
@@ -1458,17 +1475,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
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
