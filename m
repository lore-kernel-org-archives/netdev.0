From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 12/28] bonding: fill-up LAG changeupper info struct and pass it along
Date: Thu,  3 Dec 2015 12:12:14 +0100
Message-ID: <1449141150-8172-13-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36356 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760089AbbLCLMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:12:52 -0500
Received: by wmww144 with SMTP id w144so16361456wmw.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:51 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Initialize netdev_lag_upper_info structure by TX type according to
current bonding mode and pass it along via netdev_master_upper_dev_link.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v1->v2:
-added mode broadcast suggested by Nik
---
 drivers/net/bonding/bond_main.c | 45 ++++++++++++++++++++++++++++-------------
 1 file changed, 31 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index fa3ed1d..e94e79a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1198,26 +1198,43 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 	return ret;
 }
 
-static int bond_master_upper_dev_link(struct net_device *bond_dev,
-				      struct net_device *slave_dev,
-				      struct slave *slave)
+static enum netdev_lag_tx_type bond_lag_tx_type(struct bonding *bond)
 {
+	switch (BOND_MODE(bond)) {
+	case BOND_MODE_ROUNDROBIN:
+		return NETDEV_LAG_TX_TYPE_ROUNDROBIN;
+	case BOND_MODE_ACTIVEBACKUP:
+		return NETDEV_LAG_TX_TYPE_ACTIVEBACKUP;
+	case BOND_MODE_BROADCAST:
+		return NETDEV_LAG_TX_TYPE_BROADCAST;
+	case BOND_MODE_XOR:
+	case BOND_MODE_8023AD:
+		return NETDEV_LAG_TX_TYPE_HASH;
+	default:
+		return NETDEV_LAG_TX_TYPE_UNKNOWN;
+	}
+}
+
+static int bond_master_upper_dev_link(struct bonding *bond, struct slave *slave)
+{
+	struct netdev_lag_upper_info lag_upper_info;
 	int err;
 
-	err = netdev_master_upper_dev_link(slave_dev, bond_dev, slave, NULL);
+	lag_upper_info.tx_type = bond_lag_tx_type(bond);
+	err = netdev_master_upper_dev_link(slave->dev, bond->dev, slave,
+					   &lag_upper_info);
 	if (err)
 		return err;
-	slave_dev->flags |= IFF_SLAVE;
-	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
+	slave->dev->flags |= IFF_SLAVE;
+	rtmsg_ifinfo(RTM_NEWLINK, slave->dev, IFF_SLAVE, GFP_KERNEL);
 	return 0;
 }
 
-static void bond_upper_dev_unlink(struct net_device *bond_dev,
-				  struct net_device *slave_dev)
+static void bond_upper_dev_unlink(struct bonding *bond, struct slave *slave)
 {
-	netdev_upper_dev_unlink(slave_dev, bond_dev);
-	slave_dev->flags &= ~IFF_SLAVE;
-	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
+	netdev_upper_dev_unlink(slave->dev, bond->dev);
+	slave->dev->flags &= ~IFF_SLAVE;
+	rtmsg_ifinfo(RTM_NEWLINK, slave->dev, IFF_SLAVE, GFP_KERNEL);
 }
 
 static struct slave *bond_alloc_slave(struct bonding *bond)
@@ -1662,7 +1679,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_detach;
 	}
 
-	res = bond_master_upper_dev_link(bond_dev, slave_dev, new_slave);
+	res = bond_master_upper_dev_link(bond, new_slave);
 	if (res) {
 		netdev_dbg(bond_dev, "Error %d calling bond_master_upper_dev_link\n", res);
 		goto err_unregister;
@@ -1698,7 +1715,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 /* Undo stages on error */
 err_upper_unlink:
-	bond_upper_dev_unlink(bond_dev, slave_dev);
+	bond_upper_dev_unlink(bond, new_slave);
 
 err_unregister:
 	netdev_rx_handler_unregister(slave_dev);
@@ -1804,7 +1821,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	/* recompute stats just before removing the slave */
 	bond_get_stats(bond->dev, &bond->bond_stats);
 
-	bond_upper_dev_unlink(bond_dev, slave_dev);
+	bond_upper_dev_unlink(bond, slave);
 	/* unregister rx_handler early so bond_handle_frame wouldn't be called
 	 * for this slave anymore.
 	 */
-- 
1.9.3
