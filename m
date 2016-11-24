From: fgao@ikuai8.com
Subject: [PATCH net 1/1] driver: ipvlan: Fix one possible memleak in ipvlan_link_new
Date: Thu, 24 Nov 2016 23:39:59 +0800
Message-ID: <1480001999-10500-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG179.QQ.COM ([119.147.194.222]:43610 "EHLO
        smtpbg179.qq.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967047AbcKXPkw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 10:40:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When ipvlan_link_new fails and creates one ipvlan port, it does not
destroy the ipvlan port created. It causes mem leak and the physical
device contains invalid ipvlan data.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index f442eb3..0fef178 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -497,6 +497,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	struct net_device *phy_dev;
 	int err;
 	u16 mode = IPVLAN_MODE_L3;
+	bool create = false;
 
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
@@ -513,6 +514,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 		err = ipvlan_port_create(phy_dev);
 		if (err < 0)
 			return err;
+		create = true;
 	}
 
 	if (data && data[IFLA_IPVLAN_MODE])
@@ -536,22 +538,27 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 
 	err = register_netdevice(dev);
 	if (err < 0)
-		return err;
+		goto destroy_ipvlan_port;
 
 	err = netdev_upper_dev_link(phy_dev, dev);
 	if (err) {
-		unregister_netdevice(dev);
-		return err;
+		goto unregister_netdev;
 	}
 	err = ipvlan_set_port_mode(port, mode);
 	if (err) {
-		unregister_netdevice(dev);
-		return err;
+		goto unregister_netdev;
 	}
 
 	list_add_tail_rcu(&ipvlan->pnode, &port->ipvlans);
 	netif_stacked_transfer_operstate(phy_dev, dev);
 	return 0;
+
+unregister_netdev:
+	unregister_netdevice(dev);
+destroy_ipvlan_port:
+	if (create)
+		ipvlan_port_destroy(phy_dev);
+	return err;
 }
 
 static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
-- 
1.9.1
