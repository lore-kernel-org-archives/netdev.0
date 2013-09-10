From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 05/27] bonding: populate neighbour's private on enslave
Date: Tue, 10 Sep 2013 22:57:49 +0200
Message-ID: <1378846691-9717-6-git-send-email-vfalico@redhat.com>
References: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18364 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983Ab3IJU6R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 16:58:17 -0400
In-Reply-To: <1378846691-9717-1-git-send-email-vfalico@redhat.com>
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

Notes:
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Move the patch right after the introduction of ->private, to immediately
    use it - easier for review and more logical.

 drivers/net/bonding/bond_main.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 72bdb8b..f862dc8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1233,11 +1233,12 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
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
@@ -1413,17 +1414,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
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
@@ -1637,6 +1632,13 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		goto err_dest_symlinks;
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
@@ -1646,6 +1648,9 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	return 0;
 
 /* Undo stages on error */
+err_unregister:
+	netdev_rx_handler_unregister(slave_dev);
+
 err_dest_symlinks:
 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
 
@@ -1675,9 +1680,6 @@ err_close:
 	slave_dev->priv_flags &= ~IFF_BONDING;
 	dev_close(slave_dev);
 
-err_unset_master:
-	bond_upper_dev_unlink(bond_dev, slave_dev);
-
 err_restore_mac:
 	if (!bond->params.fail_over_mac) {
 		/* XXX TODO - fom follow mode needs to change master's
@@ -1748,6 +1750,8 @@ static int __bond_release_one(struct net_device *bond_dev,
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
