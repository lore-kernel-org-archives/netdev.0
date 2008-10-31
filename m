From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/3] bonding: Clean up resource leaks
Date: Thu, 30 Oct 2008 17:41:15 -0700
Message-ID: <1225413676-13579-3-git-send-email-fubar@us.ibm.com>
References: <1225413676-13579-1-git-send-email-fubar@us.ibm.com>
 <1225413676-13579-2-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:43061 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754723AbYJaAlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 20:41:19 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m9V0ec33007572
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 18:40:38 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9V0fJVs149362
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 18:41:19 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9V0fIBd014919
	for <netdev@vger.kernel.org>; Thu, 30 Oct 2008 18:41:19 -0600
In-Reply-To: <1225413676-13579-2-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reworks the resource free logic performed at the time
a bonding device is released.  This (a) closes two resource leaks, one
for workqueues and one for multicast lists, and (b) improves commonality
of code between the "destroy one" and "destroy all" paths by performing
final free activity via destructor instead of explicitly (and differently)
in each path.

	"Sean E. Millichamp" <sean@bruenor.org> reported the workqueue
leak, and included a different patch.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   49 ++++++++++++++++++++++++--------------
 1 files changed, 31 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 85de1d0..a3efba5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1979,6 +1979,20 @@ void bond_destroy(struct bonding *bond)
 	unregister_netdevice(bond->dev);
 }
 
+static void bond_destructor(struct net_device *bond_dev)
+{
+	struct bonding *bond = bond_dev->priv;
+
+	if (bond->wq)
+		destroy_workqueue(bond->wq);
+
+	netif_addr_lock_bh(bond_dev);
+	bond_mc_list_destroy(bond);
+	netif_addr_unlock_bh(bond_dev);
+
+	free_netdev(bond_dev);
+}
+
 /*
 * First release a slave and than destroy the bond if no more slaves iare left.
 * Must be under rtnl_lock when this function is called.
@@ -4553,7 +4567,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 
 	bond_set_mode_ops(bond, bond->params.mode);
 
-	bond_dev->destructor = free_netdev;
+	bond_dev->destructor = bond_destructor;
 
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
@@ -4592,20 +4606,6 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	return 0;
 }
 
-/* De-initialize device specific data.
- * Caller must hold rtnl_lock.
- */
-static void bond_deinit(struct net_device *bond_dev)
-{
-	struct bonding *bond = bond_dev->priv;
-
-	list_del(&bond->bond_list);
-
-#ifdef CONFIG_PROC_FS
-	bond_remove_proc_entry(bond);
-#endif
-}
-
 static void bond_work_cancel_all(struct bonding *bond)
 {
 	write_lock_bh(&bond->lock);
@@ -4627,6 +4627,22 @@ static void bond_work_cancel_all(struct bonding *bond)
 		cancel_delayed_work(&bond->ad_work);
 }
 
+/* De-initialize device specific data.
+ * Caller must hold rtnl_lock.
+ */
+static void bond_deinit(struct net_device *bond_dev)
+{
+	struct bonding *bond = bond_dev->priv;
+
+	list_del(&bond->bond_list);
+
+	bond_work_cancel_all(bond);
+
+#ifdef CONFIG_PROC_FS
+	bond_remove_proc_entry(bond);
+#endif
+}
+
 /* Unregister and free all bond devices.
  * Caller must hold rtnl_lock.
  */
@@ -4638,9 +4654,6 @@ static void bond_free_all(void)
 		struct net_device *bond_dev = bond->dev;
 
 		bond_work_cancel_all(bond);
-		netif_addr_lock_bh(bond_dev);
-		bond_mc_list_destroy(bond);
-		netif_addr_unlock_bh(bond_dev);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
 		bond_destroy(bond);
-- 
1.6.0.2

