From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/4] bonding: fix enslavement error unwinds
Date: Fri,  2 May 2008 17:49:40 -0700
Message-ID: <12097757841898-git-send-email-fubar@us.ibm.com>
References: <12097757801056-git-send-email-fubar@us.ibm.com>
 <12097757822222-git-send-email-fubar@us.ibm.com>
 <12097757832778-git-send-email-fubar@us.ibm.com>
 <12097757842821-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:47064 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765631AbYECAtt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 20:49:49 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m430nklN012014
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:46 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m430nke2280396
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:46 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m430njg9010547
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 20:49:46 -0400
In-Reply-To: <12097757842821-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	For commit c2edacf80e155ef54ae4774379d461b60896bc2e, two steps
were rearranged in the enslavement process: netdev_set_master is now
before the call to dev_open to open the slave.

	This patch updates the error cases and unwind process at the
end of bond_enslave to match the new order.  Without this patch, it is
possible for the enslavement to fail, but leave the slave with IFF_SLAVE
set in its flags.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3977760..b99ccd2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1425,13 +1425,13 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	res = netdev_set_master(slave_dev, bond_dev);
 	if (res) {
 		dprintk("Error %d calling netdev_set_master\n", res);
-		goto err_close;
+		goto err_restore_mac;
 	}
 	/* open the slave since the application closed it */
 	res = dev_open(slave_dev);
 	if (res) {
 		dprintk("Openning slave %s failed\n", slave_dev->name);
-		goto err_restore_mac;
+		goto err_unset_master;
 	}
 
 	new_slave->dev = slave_dev;
@@ -1444,7 +1444,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 */
 		res = bond_alb_init_slave(bond, new_slave);
 		if (res) {
-			goto err_unset_master;
+			goto err_close;
 		}
 	}
 
@@ -1619,7 +1619,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	res = bond_create_slave_symlinks(bond_dev, slave_dev);
 	if (res)
-		goto err_unset_master;
+		goto err_close;
 
 	printk(KERN_INFO DRV_NAME
 	       ": %s: enslaving %s as a%s interface with a%s link.\n",
@@ -1631,12 +1631,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	return 0;
 
 /* Undo stages on error */
-err_unset_master:
-	netdev_set_master(slave_dev, NULL);
-
 err_close:
 	dev_close(slave_dev);
 
+err_unset_master:
+	netdev_set_master(slave_dev, NULL);
+
 err_restore_mac:
 	if (!bond->params.fail_over_mac) {
 		memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
-- 
1.5.2.4

