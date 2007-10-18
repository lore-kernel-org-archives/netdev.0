From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] 	Two small fixes to IPoIB support for bonding:
Date: Wed, 17 Oct 2007 17:37:46 -0700
Message-ID: <11926678763205-git-send-email-fubar@us.ibm.com>
References: <1192667871139-git-send-email-fubar@us.ibm.com>
 <1192667875793-git-send-email-fubar@us.ibm.com>
Cc: andy@greyhouse.net, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:38714 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761768AbXJRAh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 20:37:59 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9I0bvf0024998
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 20:37:57 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9I0bvn1357840
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 18:37:57 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9I0buIp021289
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 18:37:57 -0600
In-Reply-To: <1192667875793-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	1- copy header_ops from slave to bonding for IPoIB slaves
	2- move release and destroy logic to UNREGISTER from GOING_DOWN
	   notifier to prevent double release

	Set bonding to version 3.2.1.
---
 drivers/net/bonding/bond_main.c |   11 +++++------
 drivers/net/bonding/bonding.h   |    4 ++--
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index db80f24..6f85cc3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1263,6 +1263,7 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
 	struct bonding *bond = bond_dev->priv;
 
 	bond_dev->neigh_setup           = slave_dev->neigh_setup;
+	bond_dev->header_ops		= slave_dev->header_ops;
 
 	bond_dev->type		    = slave_dev->type;
 	bond_dev->hard_header_len   = slave_dev->hard_header_len;
@@ -3351,7 +3352,10 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
 	switch (event) {
 	case NETDEV_UNREGISTER:
 		if (bond_dev) {
-			bond_release(bond_dev, slave_dev);
+			if (bond->setup_by_slave)
+				bond_release_and_destroy(bond_dev, slave_dev);
+			else
+				bond_release(bond_dev, slave_dev);
 		}
 		break;
 	case NETDEV_CHANGE:
@@ -3366,11 +3370,6 @@ static int bond_slave_netdev_event(unsigned long event, struct net_device *slave
 		 * ... Or is it this?
 		 */
 		break;
-	case NETDEV_GOING_DOWN:
-		dprintk("slave %s is going down\n", slave_dev->name);
-		if (bond->setup_by_slave)
-			bond_release_and_destroy(bond_dev, slave_dev);
-		break;
 	case NETDEV_CHANGEMTU:
 		/*
 		 * TODO: Should slaves be allowed to
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index a8bbd56..b818060 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.0"
-#define DRV_RELDATE	"September 13, 2007"
+#define DRV_VERSION	"3.2.1"
+#define DRV_RELDATE	"October 15, 2007"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
-- 
1.5.3.1

