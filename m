From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 7/7] rtnetlink: rtnl_have_link_slave_info doesn't need rtnl
Date: Thu, 21 Sep 2017 18:59:02 +0200
Message-ID: <20170921165902.10746-8-fw@strlen.de>
References: <20170921165902.10746-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39132 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751738AbdIUQ7J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 12:59:09 -0400
In-Reply-To: <20170921165902.10746-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it can be switched to rcu.
rtnl_link_slave_info_fill on the other hand does need it,
at least for now.  Add ASSERT_RTNL annotation as a reminder.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 7af9774aec40..9fd48b437d64 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -524,11 +524,15 @@ static size_t rtnl_link_get_af_size(const struct net_device *dev,
 static bool rtnl_have_link_slave_info(const struct net_device *dev)
 {
 	struct net_device *master_dev;
+	bool ret = false;
 
-	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
+	rcu_read_lock();
+
+	master_dev = netdev_master_upper_dev_get_rcu((struct net_device *) dev);
 	if (master_dev && master_dev->rtnl_link_ops)
-		return true;
-	return false;
+		ret = true;
+	rcu_read_unlock();
+	return ret;
 }
 
 static int rtnl_link_slave_info_fill(struct sk_buff *skb,
@@ -539,6 +543,8 @@ static int rtnl_link_slave_info_fill(struct sk_buff *skb,
 	struct nlattr *slave_data;
 	int err;
 
+	ASSERT_RTNL();
+
 	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
 	if (!master_dev)
 		return 0;
@@ -570,6 +576,8 @@ static int rtnl_link_info_fill(struct sk_buff *skb,
 	struct nlattr *data;
 	int err;
 
+	ASSERT_RTNL();
+
 	if (!ops)
 		return 0;
 	if (nla_put_string(skb, IFLA_INFO_KIND, ops->kind) < 0)
@@ -600,6 +608,8 @@ static int rtnl_link_fill(struct sk_buff *skb, const struct net_device *dev)
 	struct nlattr *linkinfo;
 	int err = -EMSGSIZE;
 
+	ASSERT_RTNL();
+
 	linkinfo = nla_nest_start(skb, IFLA_LINKINFO);
 	if (linkinfo == NULL)
 		goto out;
-- 
2.13.5
