From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v2 6/6] rtnetlink: rtnl_have_link_slave_info doesn't need rtnl
Date: Fri, 22 Sep 2017 08:10:08 +0200
Message-ID: <20170922061008.14723-7-fw@strlen.de>
References: <20170922061008.14723-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41606 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751795AbdIVGKM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 02:10:12 -0400
In-Reply-To: <20170922061008.14723-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch it to rcu.

rtnl_link_slave_info_fill on to other hand does need rtnl mutex for now so
add an annotation to its caller as a reminder.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Change since v1:
  - don't add ASSERT_RTNL to rtnl_link_slave_info_fill and
  rtnl_link_info_fill they are only called via rtnl_link_fill.

 net/core/rtnetlink.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 590823f70cc3..e6f9e36d9d5a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -522,11 +522,15 @@ static size_t rtnl_link_get_af_size(const struct net_device *dev,
 static bool rtnl_have_link_slave_info(const struct net_device *dev)
 {
 	struct net_device *master_dev;
+	bool ret = false;
 
-	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
+	rcu_read_lock();
+
+	master_dev = netdev_master_upper_dev_get_rcu((struct net_device *)dev);
 	if (master_dev && master_dev->rtnl_link_ops)
-		return true;
-	return false;
+		ret = true;
+	rcu_read_unlock();
+	return ret;
 }
 
 static int rtnl_link_slave_info_fill(struct sk_buff *skb,
@@ -598,6 +602,8 @@ static int rtnl_link_fill(struct sk_buff *skb, const struct net_device *dev)
 	struct nlattr *linkinfo;
 	int err = -EMSGSIZE;
 
+	ASSERT_RTNL();
+
 	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
 	if (linkinfo == NULL)
 		goto out;
-- 
2.13.5
