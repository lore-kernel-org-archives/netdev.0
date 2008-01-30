From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/7] bonding: fix set_multicast_list locking
Date: Tue, 29 Jan 2008 18:07:44 -0800
Message-ID: <12016588714065-git-send-email-fubar@us.ibm.com>
References: <12016588691476-git-send-email-fubar@us.ibm.com>
 <12016588701127-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:52700 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053AbYA3CH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 21:07:58 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0U27q3b005919
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 21:07:52 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0U27qDm205166
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:52 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0U27plT015802
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:52 -0700
In-Reply-To: <12016588701127-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	This patch eliminates a problem (reported by lockdep) in the
bond_set_multicast_list function.  It first reduces the locking on
bond->lock to a simple read_lock, and second, adds netif_tx locking
around the bonding mc_list manipulations that occur outside of the
set_multicast_list function.

	The original problem was related to IPv6 addrconf activity.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f3b1e02..591b8b4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1464,10 +1464,12 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			dev_set_allmulti(slave_dev, 1);
 		}
 
+		netif_tx_lock_bh(bond_dev);
 		/* upload master's mc_list to new slave */
 		for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
 			dev_mc_add (slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
+		netif_tx_unlock_bh(bond_dev);
 	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
@@ -1821,7 +1823,9 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 
 		/* flush master's mc_list from slave */
+		netif_tx_lock_bh(bond_dev);
 		bond_mc_list_flush(bond_dev, slave_dev);
+		netif_tx_unlock_bh(bond_dev);
 	}
 
 	netdev_set_master(slave_dev, NULL);
@@ -1942,7 +1946,9 @@ static int bond_release_all(struct net_device *bond_dev)
 			}
 
 			/* flush master's mc_list from slave */
+			netif_tx_lock_bh(bond_dev);
 			bond_mc_list_flush(bond_dev, slave_dev);
+			netif_tx_unlock_bh(bond_dev);
 		}
 
 		netdev_set_master(slave_dev, NULL);
@@ -3937,8 +3943,6 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	struct bonding *bond = bond_dev->priv;
 	struct dev_mc_list *dmi;
 
-	write_lock_bh(&bond->lock);
-
 	/*
 	 * Do promisc before checking multicast_mode
 	 */
@@ -3959,6 +3963,8 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 		bond_set_allmulti(bond, -1);
 	}
 
+	read_lock(&bond->lock);
+
 	bond->flags = bond_dev->flags;
 
 	/* looking for addresses to add to slaves' mc list */
@@ -3979,7 +3985,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
 	bond_mc_list_destroy(bond);
 	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 }
 
 /*
@@ -4526,7 +4532,9 @@ static void bond_free_all(void)
 		struct net_device *bond_dev = bond->dev;
 
 		bond_work_cancel_all(bond);
+		netif_tx_lock_bh(bond_dev);
 		bond_mc_list_destroy(bond);
+		netif_tx_unlock_bh(bond_dev);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
 		bond_deinit(bond_dev);
-- 
1.5.3.4.206.g58ba4-dirty

