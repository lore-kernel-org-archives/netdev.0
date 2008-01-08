From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/3] bonding: fix locking in sysfs primary/active selection
Date: Mon,  7 Jan 2008 17:56:58 -0800
Message-ID: <11997574222492-git-send-email-fubar@us.ibm.com>
References: <11997574203125-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Krzysztof Oledzki <olel@ans.pl>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:32929 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754093AbYAHB5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 20:57:05 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m081v45F024733
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:04 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m081v4Xi444792
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:04 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m081v3d2022350
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:04 -0500
In-Reply-To: <11997574203125-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Fix the functions that store the primary and active slave
options via sysfs to hold the correct locks in the correct order.

	The bond_change_active_slave and bond_select_active_slave
functions both require rtnl, bond->lock for read and curr_slave_lock for
write_bh, and no other locks.  This is so that the lower level
mode-specific functions (notably for balance-alb mode) can release locks
down to just rtnl in order to call, e.g., dev_set_mac_address with the
locks it expects (rtnl only).

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/bonding/bond_sysfs.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 11b76b3..28a2d80 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1075,7 +1075,10 @@ static ssize_t bonding_store_primary(struct device *d,
 	struct slave *slave;
 	struct bonding *bond = to_bond(d);
 
-	write_lock_bh(&bond->lock);
+	rtnl_lock();
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
 		       ": %s: Unable to set primary slave; %s is in mode %d\n",
@@ -1109,8 +1112,8 @@ static ssize_t bonding_store_primary(struct device *d,
 		}
 	}
 out:
-	write_unlock_bh(&bond->lock);
-
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
 	rtnl_unlock();
 
 	return count;
@@ -1190,7 +1193,8 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	struct bonding *bond = to_bond(d);
 
 	rtnl_lock();
-	write_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
 
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
@@ -1247,7 +1251,8 @@ static ssize_t bonding_store_active_slave(struct device *d,
 		}
 	}
 out:
-	write_unlock_bh(&bond->lock);
+	write_unlock_bh(&bond->curr_slave_lock);
+	read_unlock(&bond->lock);
 	rtnl_unlock();
 
 	return count;
-- 
1.5.3.4.206.g58ba4-dirty

