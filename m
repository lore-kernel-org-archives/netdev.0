From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 3/6] rtnetlink: switch rtnl_link_get_slave_info_data_size to rcu
Date: Thu, 10 Aug 2017 16:52:59 +0200
Message-ID: <20170810145302.30391-4-fw@strlen.de>
References: <20170810145302.30391-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:46632 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752612AbdHJOwz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 10:52:55 -0400
In-Reply-To: <20170810145302.30391-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern reports following splat:
 RTNL: assertion failed at net/core/dev.c (5717)
 netdev_master_upper_dev_get+0x5f/0x70
 if_nlmsg_size+0x158/0x240
 rtnl_calcit.isra.26+0xa3/0xf0

rtnl_link_get_slave_info_data_size currently assumes RTNL protection, but
there appears to be no hard requirement for this, so use rcu instead.

At the time of this writing, there are three 'get_slave_size' callbacks
(now invoked under rcu): bond_get_slave_size, vrf_get_slave_size and
br_port_get_slave_size, all return constant only (i.e. they don't sleep).

Fixes: 6853dd488119 ("rtnetlink: protect handler table with rcu")
Reported-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a9b5ebc1af21..087f2434813a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -402,16 +402,24 @@ static size_t rtnl_link_get_slave_info_data_size(const struct net_device *dev)
 {
 	struct net_device *master_dev;
 	const struct rtnl_link_ops *ops;
+	size_t size = 0;
 
-	master_dev = netdev_master_upper_dev_get((struct net_device *) dev);
+	rcu_read_lock();
+
+	master_dev = netdev_master_upper_dev_get_rcu((struct net_device *)dev);
 	if (!master_dev)
-		return 0;
+		goto out;
+
 	ops = master_dev->rtnl_link_ops;
 	if (!ops || !ops->get_slave_size)
-		return 0;
+		goto out;
 	/* IFLA_INFO_SLAVE_DATA + nested data */
-	return nla_total_size(sizeof(struct nlattr)) +
+	size = nla_total_size(sizeof(struct nlattr)) +
 	       ops->get_slave_size(master_dev, dev);
+
+out:
+	rcu_read_unlock();
+	return size;
 }
 
 static size_t rtnl_link_get_size(const struct net_device *dev)
-- 
2.13.0
