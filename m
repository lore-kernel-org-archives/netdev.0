From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 6/6] Acquire correct locks in alb for promisc change
Date: Wed, 10 Oct 2007 21:14:09 -0700
Message-ID: <11920760543809-git-send-email-fubar@us.ibm.com>
References: <11920760494096-git-send-email-fubar@us.ibm.com>
 <11920760502756-git-send-email-fubar@us.ibm.com>
 <1192076051437-git-send-email-fubar@us.ibm.com>
 <11920760522759-git-send-email-fubar@us.ibm.com>
 <11920760532491-git-send-email-fubar@us.ibm.com>
 <11920760533281-git-send-email-fubar@us.ibm.com>
Cc: andy@greyhouse.net, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:45089 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbXJKEOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 00:14:17 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9B4EG46021332
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 00:14:16 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9B4EFf1374842
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 22:14:15 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9B4EEBH027317
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 22:14:15 -0600
In-Reply-To: <11920760533281-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Update ALB mode monitor to hold correct locks (RTNL and nothing
else) when calling dev_set_promiscuity.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_alb.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 6db5d76..25b8dbf 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1455,16 +1455,16 @@ void bond_alb_monitor(struct work_struct *work)
 
 	/* handle rlb stuff */
 	if (bond_info->rlb_enabled) {
-		/* the following code changes the promiscuity of the
-		 * the curr_active_slave. It needs to be locked with a
-		 * write lock to protect from other code that also
-		 * sets the promiscuity.
-		 */
-		write_lock_bh(&bond->curr_slave_lock);
-
 		if (bond_info->primary_is_promisc &&
 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
 
+			/*
+			 * dev_set_promiscuity requires rtnl and
+			 * nothing else.
+			 */
+			read_unlock(&bond->lock);
+			rtnl_lock();
+
 			bond_info->rlb_promisc_timeout_counter = 0;
 
 			/* If the primary was set to promiscuous mode
@@ -1473,9 +1473,10 @@ void bond_alb_monitor(struct work_struct *work)
 			 */
 			dev_set_promiscuity(bond->curr_active_slave->dev, -1);
 			bond_info->primary_is_promisc = 0;
-		}
 
-		write_unlock_bh(&bond->curr_slave_lock);
+			rtnl_unlock();
+			read_lock(&bond->lock);
+		}
 
 		if (bond_info->rlb_rebalance) {
 			bond_info->rlb_rebalance = 0;
-- 
1.5.3.1

