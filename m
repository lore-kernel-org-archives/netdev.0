From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] rtnl: simplify error return path in rtnl_create_link()
Date: Mon, 20 Feb 2017 16:32:06 +0100
Message-ID: <20170220153206.23498-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:55520 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753758AbdBTPcZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 10:32:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is only one possible error path which reaches the err label, so
return ERR_PTR(-ENOMEM) directly if alloc_netdev_mqs() fails. This also
allows to omit the err variable.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/core/rtnetlink.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e3286d32eca5..c4e84c558240 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2358,7 +2358,6 @@ struct net_device *rtnl_create_link(struct net *net,
 	const char *ifname, unsigned char name_assign_type,
 	const struct rtnl_link_ops *ops, struct nlattr *tb[])
 {
-	int err;
 	struct net_device *dev;
 	unsigned int num_tx_queues = 1;
 	unsigned int num_rx_queues = 1;
@@ -2373,11 +2372,10 @@ struct net_device *rtnl_create_link(struct net *net,
 	else if (ops->get_num_rx_queues)
 		num_rx_queues = ops->get_num_rx_queues();
 
-	err = -ENOMEM;
 	dev = alloc_netdev_mqs(ops->priv_size, ifname, name_assign_type,
 			       ops->setup, num_tx_queues, num_rx_queues);
 	if (!dev)
-		goto err;
+		return ERR_PTR(-ENOMEM);
 
 	dev_net_set(dev, net);
 	dev->rtnl_link_ops = ops;
@@ -2403,9 +2401,6 @@ struct net_device *rtnl_create_link(struct net *net,
 		dev_set_group(dev, nla_get_u32(tb[IFLA_GROUP]));
 
 	return dev;
-
-err:
-	return ERR_PTR(err);
 }
 EXPORT_SYMBOL(rtnl_create_link);
 
-- 
2.11.0
