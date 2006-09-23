From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 10/10] bonding: Fix primary selection error at enslavement time
Date: Fri, 22 Sep 2006 21:56:15 -0700
Message-ID: <200609230456.k8N4uFZt029814@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:50155 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751012AbWIWE4R
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 00:56:17 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8N4uGkv005596
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:56:16 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8N4uG0T246774
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:56:16 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8N4uFKb010347
	for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 22:56:16 -0600
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	At enslavement time, the primary slave might not be activated if
there is already an active slave and the new slave is the primary.
Replaced complicated logic with a call to bond_select_active_slave(),
which does the right thing.

	Fixes http://bugzilla.kernel.org/show_bug.cgi?id=6378

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 03b0aaa..4e7aaf9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1513,29 +1513,8 @@ int bond_enslave(struct net_device *bond
 
 	switch (bond->params.mode) {
 	case BOND_MODE_ACTIVEBACKUP:
-		/* if we're in active-backup mode, we need one and
-		 * only one active interface. The backup interfaces
-		 * will have their SLAVE_INACTIVE flag set because we
-		 * need them to be drop all packets. Thus, since we
-		 * guarantee that curr_active_slave always point to
-		 * the last usable interface, we just have to verify
-		 * this interface's flag.
-		 */
-		if (((!bond->curr_active_slave) ||
-		     (bond->curr_active_slave->dev->priv_flags & IFF_SLAVE_INACTIVE)) &&
-		    (new_slave->link != BOND_LINK_DOWN)) {
-			/* first slave or no active slave yet, and this link
-			   is OK, so make this interface the active one */
-			bond_change_active_slave(bond, new_slave);
-			printk(KERN_INFO DRV_NAME
-			       ": %s: first active interface up!\n",
-			       bond->dev->name);
-			netif_carrier_on(bond->dev);
-
-		} else {
-			dprintk("This is just a backup slave\n");
-			bond_set_slave_inactive_flags(new_slave);
-		}
+		bond_set_slave_inactive_flags(new_slave);
+		bond_select_active_slave(bond);
 		break;
 	case BOND_MODE_8023AD:
 		/* in 802.3ad mode, the internal mechanism
