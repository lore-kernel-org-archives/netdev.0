From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 4/6] bond: Simplify bond device destruction
Date: Thu, 29 Oct 2009 17:18:24 -0700
Message-ID: <1256861906-5059-4-git-send-email-ebiederm@xmission.com>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:56331 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755783AbZJ3ASn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 20:18:43 -0400
In-Reply-To: <m1tyxhwxah.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@aristanetworks.com>

Manually inline the code from bond_deinit to bond_uninit.  bond_uninit
is the only caller and it is short.

Move the call of bond_release_all from the netdev notifier into
bond_uninit.  The call site is effectively the same and performing
the call explicitly allows all the paths for destroying a
bonding device to behave the same way.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/bonding/bond_main.c |   45 +++++++++++++-------------------------
 1 files changed, 16 insertions(+), 29 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3ce31e7..7a37ecf 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -227,7 +227,7 @@ struct bond_parm_tbl ad_select_tbl[] = {
 
 static void bond_send_gratuitous_arp(struct bonding *bond);
 static int bond_init(struct net_device *bond_dev);
-static void bond_deinit(struct net_device *bond_dev);
+static void bond_uninit(struct net_device *bond_dev);
 
 /*---------------------------- General routines -----------------------------*/
 
@@ -2003,24 +2003,6 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 }
 
 /*
-* Destroy a bonding device.
-* Must be under rtnl_lock when this function is called.
-*/
-static void bond_uninit(struct net_device *bond_dev)
-{
-	struct bonding *bond = netdev_priv(bond_dev);
-
-	bond_deinit(bond_dev);
-
-	if (bond->wq)
-		destroy_workqueue(bond->wq);
-
-	netif_addr_lock_bh(bond_dev);
-	bond_mc_list_destroy(bond);
-	netif_addr_unlock_bh(bond_dev);
-}
-
-/*
 * First release a slave and than destroy the bond if no more slaves are left.
 * Must be under rtnl_lock when this function is called.
 */
@@ -3467,9 +3449,6 @@ static int bond_master_netdev_event(unsigned long event,
 	switch (event) {
 	case NETDEV_CHANGENAME:
 		return bond_event_changename(event_bond);
-	case NETDEV_UNREGISTER:
-		bond_release_all(event_bond->dev);
-		break;
 	default:
 		break;
 	}
@@ -4608,18 +4587,29 @@ static void bond_work_cancel_all(struct bonding *bond)
 		cancel_delayed_work(&bond->ad_work);
 }
 
-/* De-initialize device specific data.
- * Caller must hold rtnl_lock.
- */
-static void bond_deinit(struct net_device *bond_dev)
+/*
+* Destroy a bonding device.
+* Must be under rtnl_lock when this function is called.
+*/
+static void bond_uninit(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
+	/* Release the bonded slaves */
+	bond_release_all(bond_dev);
+
 	list_del(&bond->bond_list);
 
 	bond_work_cancel_all(bond);
 
 	bond_remove_proc_entry(bond);
+
+	if (bond->wq)
+		destroy_workqueue(bond->wq);
+
+	netif_addr_lock_bh(bond_dev);
+	bond_mc_list_destroy(bond);
+	netif_addr_unlock_bh(bond_dev);
 }
 
 /* Unregister and free all bond devices.
@@ -4632,9 +4622,6 @@ static void bond_free_all(void)
 	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
 		struct net_device *bond_dev = bond->dev;
 
-		bond_work_cancel_all(bond);
-		/* Release the bonded slaves */
-		bond_release_all(bond_dev);
 		unregister_netdevice(bond_dev);
 	}
 
-- 
1.6.3.1.54.g99dd.dirty

