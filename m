From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v3 6/6] rtnetlink: rtnl_have_link_slave_info doesn't need rtnl
Date: Sat, 23 Sep 2017 21:26:36 +0200
Message-ID: <20170923192636.3932-7-fw@strlen.de>
References: <20170923192636.3932-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46834 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751409AbdIWT0k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 15:26:40 -0400
In-Reply-To: <20170923192636.3932-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it can be switched to rcu.

Reviewed-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Changes since v2: remove ASSERT_RTNL.

 net/core/rtnetlink.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e858a2b48d7e..c69451964a44 100644
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
-- 
2.13.5
