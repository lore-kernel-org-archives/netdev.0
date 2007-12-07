From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 8/8] bonding: Fix race at module unload
Date: Thu,  6 Dec 2007 23:40:35 -0800
Message-ID: <11970132404031-git-send-email-fubar@us.ibm.com>
References: <11970132353950-git-send-email-fubar@us.ibm.com>
 <11970132363756-git-send-email-fubar@us.ibm.com>
 <11970132372293-git-send-email-fubar@us.ibm.com>
 <1197013237259-git-send-email-fubar@us.ibm.com>
 <11970132382296-git-send-email-fubar@us.ibm.com>
 <11970132381345-git-send-email-fubar@us.ibm.com>
 <11970132394126-git-send-email-fubar@us.ibm.com>
 <1197013239283-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:41556 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803AbXLGHkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 02:40:42 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB77efbl012753
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 02:40:41 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB77efBo037478
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:41 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB77ef3L018181
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:41 -0700
In-Reply-To: <1197013239283-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Fixes a race condition in module unload.  Without this change,
workqueue events may fire while bonding data structures are partially
freed but before bond_close() is invoked by unregister_netdevice().

	Update version to 3.2.3.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   43 ++++++++++++++++++++-------------------
 drivers/net/bonding/bonding.h   |    2 +-
 2 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 08879d5..b0b2603 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4492,6 +4492,27 @@ static void bond_deinit(struct net_device *bond_dev)
 #endif
 }
 
+static void bond_work_cancel_all(struct bonding *bond)
+{
+	write_lock_bh(&bond->lock);
+	bond->kill_timers = 1;
+	write_unlock_bh(&bond->lock);
+
+	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
+		cancel_delayed_work(&bond->mii_work);
+
+	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
+		cancel_delayed_work(&bond->arp_work);
+
+	if (bond->params.mode == BOND_MODE_ALB &&
+	    delayed_work_pending(&bond->alb_work))
+		cancel_delayed_work(&bond->alb_work);
+
+	if (bond->params.mode == BOND_MODE_8023AD &&
+	    delayed_work_pending(&bond->ad_work))
+		cancel_delayed_work(&bond->ad_work);
+}
+
 /* Unregister and free all bond devices.
  * Caller must hold rtnl_lock.
  */
@@ -4502,6 +4523,7 @@ static void bond_free_all(void)
 	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
 		struct net_device *bond_dev = bond->dev;
 
+		bond_work_cancel_all(bond);
 		bond_mc_list_destroy(bond);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
@@ -4902,27 +4924,6 @@ out_rtnl:
 	return res;
 }
 
-static void bond_work_cancel_all(struct bonding *bond)
-{
-	write_lock_bh(&bond->lock);
-	bond->kill_timers = 1;
-	write_unlock_bh(&bond->lock);
-
-	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
-		cancel_delayed_work(&bond->mii_work);
-
-	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
-		cancel_delayed_work(&bond->arp_work);
-
-	if (bond->params.mode == BOND_MODE_ALB &&
-	    delayed_work_pending(&bond->alb_work))
-		cancel_delayed_work(&bond->alb_work);
-
-	if (bond->params.mode == BOND_MODE_8023AD &&
-	    delayed_work_pending(&bond->ad_work))
-		cancel_delayed_work(&bond->ad_work);
-}
-
 static int __init bonding_init(void)
 {
 	int i;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ccafc74..e1e4734 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,7 +22,7 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.2"
+#define DRV_VERSION	"3.2.3"
 #define DRV_RELDATE	"December 6, 2007"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
-- 
1.5.3.4.206.g58ba4-dirty

