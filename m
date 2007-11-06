From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/2] bonding: fix rtnl locking merge error
Date: Tue,  6 Nov 2007 13:33:28 -0800
Message-ID: <11943848132752-git-send-email-fubar@us.ibm.com>
References: <11943848091427-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:42325 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbXKFVdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 16:33:36 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA6LXa00025911
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 16:33:36 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA6LXYYC130046
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 14:33:35 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA6LXXI7004252
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 14:33:34 -0700
In-Reply-To: <11943848091427-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Looks like I incorrectly merged one of the rtnl lock changes,
so that one function, bonding_show_active_slave, held rtnl but didn't
release it, and another, bonding_store_active_slave, never held rtnl but
did release it.

	Fixed so the first function doesn't mess with rtnl, and the
second correctly acquires and releases rtnl.

	Bug reported by Moni Shoua <monis@voltaire.com>


Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---
 drivers/net/bonding/bond_sysfs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 7a06ade..b29330d 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1193,8 +1193,6 @@ static ssize_t bonding_show_active_slave(struct device *d,
 	struct bonding *bond = to_bond(d);
 	int count;
 
-	rtnl_lock();
-
 	read_lock(&bond->curr_slave_lock);
 	curr = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
@@ -1216,7 +1214,9 @@ static ssize_t bonding_store_active_slave(struct device *d,
         struct slave *new_active = NULL;
 	struct bonding *bond = to_bond(d);
 
+	rtnl_lock();
 	write_lock_bh(&bond->lock);
+
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
 		       ": %s: Unable to change active slave; %s is in mode %d\n",
-- 
1.5.3.4.206.g58ba4-dirty

