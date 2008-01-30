From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 5/7] bonding: do not acquire rtnl in ARP monitor
Date: Tue, 29 Jan 2008 18:07:47 -0800
Message-ID: <12016588733343-git-send-email-fubar@us.ibm.com>
References: <12016588691476-git-send-email-fubar@us.ibm.com>
 <12016588701127-git-send-email-fubar@us.ibm.com>
 <12016588714065-git-send-email-fubar@us.ibm.com>
 <12016588712034-git-send-email-fubar@us.ibm.com>
 <1201658872418-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:32864 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbYA3CIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 21:08:00 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0U14SAa023882
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 20:04:28 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0U27swd205172
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:54 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0U27rXb015873
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 19:07:54 -0700
In-Reply-To: <1201658872418-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	The ARP monitor functions currently acquire RTNL when performing
failover operations, but do so incorrectly (out of order).  This causes
various warnings from might_sleep.

	The ARP monitor isn't supported for any of the bonding modes
that actually require RTNL, so it is safe to not hold RTNL when
failing over in the ARP monitor.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0cc853e..b532125 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2801,14 +2801,11 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	}
 
 	if (do_failover) {
-		rtnl_lock();
 		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
 		write_unlock_bh(&bond->curr_slave_lock);
-		rtnl_unlock();
-
 	}
 
 re_arm:
@@ -2865,8 +2862,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 				slave->link = BOND_LINK_UP;
 
-				rtnl_lock();
-
 				write_lock_bh(&bond->curr_slave_lock);
 
 				if ((!bond->curr_active_slave) &&
@@ -2902,7 +2897,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 				}
 
 				write_unlock_bh(&bond->curr_slave_lock);
-				rtnl_unlock();
 			}
 		} else {
 			read_lock(&bond->curr_slave_lock);
@@ -2972,7 +2966,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 			       bond->dev->name,
 			       slave->dev->name);
 
-			rtnl_lock();
 			write_lock_bh(&bond->curr_slave_lock);
 
 			bond_select_active_slave(bond);
@@ -2980,8 +2973,6 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 			write_unlock_bh(&bond->curr_slave_lock);
 
-			rtnl_unlock();
-
 			bond->current_arp_slave = slave;
 
 			if (slave) {
@@ -2999,13 +2990,10 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 			       bond->primary_slave->dev->name);
 
 			/* primary is up so switch to it */
-			rtnl_lock();
 			write_lock_bh(&bond->curr_slave_lock);
 			bond_change_active_slave(bond, bond->primary_slave);
 			write_unlock_bh(&bond->curr_slave_lock);
 
-			rtnl_unlock();
-
 			slave = bond->primary_slave;
 			slave->jiffies = jiffies;
 		} else {
-- 
1.5.3.4.206.g58ba4-dirty

