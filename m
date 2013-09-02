From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 09/21] bonding: populate neighbour's private on enslave
Date: Mon,  2 Sep 2013 23:39:13 +0200
Message-ID: <1378157965-17537-10-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54619 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759113Ab3IBVjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:39:23 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the new provided function when attaching the lower slave to populate
its ->private with struct slave *new_slave. Also, move it to the end to
be able to 'find' it only after it was completely initialized, and
deinitialize in the first place on release.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b347b3d..427d943 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1242,11 +1242,12 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 }
 
 static int bond_master_upper_dev_link(struct net_device *bond_dev,
-				      struct net_device *slave_dev)
+				      struct net_device *slave_dev,
+				      struct slave *slave)
 {
 	int err;
 
-	err = netdev_master_upper_dev_link(slave_dev, bond_dev);
+	err = netdev_master_upper_dev_link_private(slave_dev, bond_dev, slave);
 	if (err)
 		return err;
 	slave_dev->flags |= IFF_SLAVE;
@@ -1422,17 +1423,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 	}
 
-	res = bond_master_upper_dev_link(bond_dev, slave_dev);
-	if (res) {
-		pr_debug("Error %d calling bond_master_upper_dev_link\n", res);
-		goto err_restore_mac;
-	}
-
 	/* open the slave since the application closed it */
 	res = dev_open(slave_dev);
 	if (res) {
 		pr_debug("Opening slave %s failed\n", slave_dev->name);
-		goto err_unset_master;
+		goto err_restore_mac;
 	}
 
 	new_slave->bond = bond;
@@ -1642,6 +1637,13 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_detach;
 	}
 
+	res = bond_master_upper_dev_link(bond_dev, slave_dev, new_slave);
+	if (res) {
+		pr_debug("Error %d calling bond_master_upper_dev_link\n", res);
+		goto err_unregister;
+	}
+
+
 	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
 		bond_dev->name, slave_dev->name,
 		bond_is_active_slave(new_slave) ? "n active" : " backup",
@@ -1651,6 +1653,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	return 0;
 
 /* Undo stages on error */
+err_unregister:
+	netdev_rx_handler_unregister(slave_dev);
+
 err_detach:
 	if (!USES_PRIMARY(bond->params.mode))
 		bond_hw_addr_flush(bond_dev, slave_dev);
@@ -1677,9 +1682,6 @@ err_close:
 	slave_dev->priv_flags &= ~IFF_BONDING;
 	dev_close(slave_dev);
 
-err_unset_master:
-	bond_upper_dev_unlink(bond_dev, slave_dev);
-
 err_restore_mac:
 	if (!bond->params.fail_over_mac) {
 		/* XXX TODO - fom follow mode needs to change master's
@@ -1750,6 +1752,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 	}
 
 	write_unlock_bh(&bond->lock);
+
+	bond_upper_dev_unlink(bond_dev, slave_dev);
 	/* unregister rx_handler early so bond_handle_frame wouldn't be called
 	 * for this slave anymore.
 	 */
@@ -1866,8 +1870,6 @@ static int __bond_release_one(struct net_device *bond_dev,
 		bond_hw_addr_flush(bond_dev, slave_dev);
 	}
 
-	bond_upper_dev_unlink(bond_dev, slave_dev);
-
 	slave_disable_netpoll(slave);
 
 	/* close slave before restoring its mac address */
-- 
1.8.4
