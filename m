From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH linux-2.6] bonding: two small fixes for IPoIB support
Date: Mon, 15 Oct 2007 16:44:27 -0700
Message-ID: <9245.1192491867@death>
References: <47138EB7.40703@gmail.com> <4713B006.9090908@pobox.com> <27349.1192480486@death> <4713D28F.3010904@pobox.com> <31162.1192485233@death> <4713E20F.9080305@pobox.com>
Cc: Moni Shoua <monisonlists@gmail.com>, rdreier@cisco.com,
	netdev@vger.kernel.org, general@lists.openfabrics.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:33344 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755692AbXJOXou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 19:44:50 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9FNin5a029080
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 19:44:49 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9FNiolG554108
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 19:44:50 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9FNidRJ005326
	for <netdev@vger.kernel.org>; Mon, 15 Oct 2007 19:44:39 -0400
In-reply-to: <4713E20F.9080305@pobox.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Two small fixes to IPoIB support for bonding:

	1- copy header_ops from slave to bonding for IPoIB slaves
	2- move release and destroy logic to UNREGISTER from GOING_DOWN
	   notifier to avoid double release

	Set bonding to version 3.2.1.

Signed-off-by: Moni Shoua <monis at voltaire.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

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

