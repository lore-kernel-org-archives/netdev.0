From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] bonding: bond_slave_info_query() fix
Date: Thu, 23 Apr 2009 13:24:07 +0200
Message-ID: <49F04FD7.7080508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47414 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987AbZDWLYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 07:24:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_slave_info_query() should keep a read lock while accessing slave info,
or risk accessing stale data and corruption.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 63369b6..66697db 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2213,33 +2213,27 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
-	int i, found = 0;
+	int i, ret = -ENODEV;
 
-	if (info->slave_id < 0) {
+	if (info->slave_id < 0)
 		return -ENODEV;
-	}
 
 	read_lock(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		if (i == (int)info->slave_id) {
-			found = 1;
+			ret = 0;
+			strcpy(info->slave_name, slave->dev->name);
+			info->link = slave->link;
+			info->state = slave->state;
+			info->link_failure_count = slave->link_failure_count;
 			break;
 		}
 	}
 
 	read_unlock(&bond->lock);
 
-	if (found) {
-		strcpy(info->slave_name, slave->dev->name);
-		info->link = slave->link;
-		info->state = slave->state;
-		info->link_failure_count = slave->link_failure_count;
-	} else {
-		return -ENODEV;
-	}
-
-	return 0;
+	return ret;
 }
 
 /*-------------------------------- Monitoring -------------------------------*/
