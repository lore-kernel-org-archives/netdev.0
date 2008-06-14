From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/5] bonding: Rework / fix multiple gratuitous ARP support
Date: Fri, 13 Jun 2008 18:12:03 -0700
Message-ID: <12134059261828-git-send-email-fubar@us.ibm.com>
References: <12134059242107-git-send-email-fubar@us.ibm.com>
 <12134059253135-git-send-email-fubar@us.ibm.com>
 <12134059253839-git-send-email-fubar@us.ibm.com>
 <12134059261873-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:33386 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757596AbYFNBMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 21:12:13 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5E1C8Zr027601
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 21:12:08 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5E1C7WK167322
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:07 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5E1C7r5030289
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:07 -0600
In-Reply-To: <12134059261873-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Support for sending multiple gratuitous ARPs during failovers
was added by commit:

commit 7893b2491a2d5f716540ac5643d78d37a7f6628b
Author: Moni Shoua <monis@voltaire.com>
Date:   Sat May 17 21:10:12 2008 -0700

    bonding: Send more than one gratuitous ARP when slave takes over

	This change modifies that support to remove duplicated code,
add support for ARP monitor (the original only supported miimon), clear
the grat ARP counter in bond_close (lest a later "ifconfig up" immediately
start spewing ARPs), and add documentation for the module parameter.

	Also updated driver version to 3.3.0.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 Documentation/networking/bonding.txt |   11 +++++++++
 drivers/net/bonding/bond_main.c      |   42 +++++++++++++++++----------------
 drivers/net/bonding/bonding.h        |    4 +-
 3 files changed, 35 insertions(+), 22 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 8e6b8d3..370b7da 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -539,6 +539,17 @@ mode
 		swapped with the new curr_active_slave that was
 		chosen.
 
+num_grat_arp
+
+	Specifies the number of gratuitous ARPs to be issued after a
+	failover event.  One gratuitous ARP is issued immediately after
+	the failover, subsequent ARPs are sent at a rate of one per link
+	monitor interval (arp_interval or miimon, whichever is active).
+
+	The valid range is 0 - 255; the default value is 1.  This option
+	affects only the active-backup mode.  This option was added for
+	bonding version 3.3.0.
+
 primary
 
 	A string (eth0, eth2, etc) specifying which slave is the
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 925402b..3b6d66a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1195,14 +1195,7 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 						      old_active);
 
 			bond->send_grat_arp = bond->params.num_grat_arp;
-			if (!test_bit(__LINK_STATE_LINKWATCH_PENDING,
-					&bond->curr_active_slave->dev->state)) {
-				bond_send_gratuitous_arp(bond);
-				bond->send_grat_arp--;
-			} else {
-				dprintk("delaying gratuitous arp on %s\n",
-					bond->curr_active_slave->dev->name);
-			}
+			bond_send_gratuitous_arp(bond);
 
 			write_unlock_bh(&bond->curr_slave_lock);
 			read_unlock(&bond->lock);
@@ -2241,17 +2234,6 @@ static int __bond_mii_monitor(struct bonding *bond, int have_locks)
 	 * program could monitor the link itself if needed.
 	 */
 
-	if (bond->send_grat_arp) {
-		if (bond->curr_active_slave && test_bit(__LINK_STATE_LINKWATCH_PENDING,
-				&bond->curr_active_slave->dev->state))
-			dprintk("Needs to send gratuitous arp but not yet\n");
-		else {
-			dprintk("sending delayed gratuitous arp on on %s\n",
-				bond->curr_active_slave->dev->name);
-			bond_send_gratuitous_arp(bond);
-			bond->send_grat_arp--;
-		}
-	}
 	read_lock(&bond->curr_slave_lock);
 	oldcurrent = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
@@ -2492,6 +2474,13 @@ void bond_mii_monitor(struct work_struct *work)
 		read_unlock(&bond->lock);
 		return;
 	}
+
+	if (bond->send_grat_arp) {
+		read_lock(&bond->curr_slave_lock);
+		bond_send_gratuitous_arp(bond);
+		read_unlock(&bond->curr_slave_lock);
+	}
+
 	if (__bond_mii_monitor(bond, 0)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -2657,6 +2646,8 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 /*
  * Kick out a gratuitous ARP for an IP on the bonding master plus one
  * for each VLAN above us.
+ *
+ * Caller must hold curr_slave_lock for read or better
  */
 static void bond_send_gratuitous_arp(struct bonding *bond)
 {
@@ -2666,9 +2657,13 @@ static void bond_send_gratuitous_arp(struct bonding *bond)
 
 	dprintk("bond_send_grat_arp: bond %s slave %s\n", bond->dev->name,
 				slave ? slave->dev->name : "NULL");
-	if (!slave)
+
+	if (!slave || !bond->send_grat_arp ||
+	    test_bit(__LINK_STATE_LINKWATCH_PENDING, &slave->dev->state))
 		return;
 
+	bond->send_grat_arp--;
+
 	if (bond->master_ip) {
 		bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
 				bond->master_ip, 0);
@@ -3172,6 +3167,12 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 	if (bond->slave_cnt == 0)
 		goto re_arm;
 
+	if (bond->send_grat_arp) {
+		read_lock(&bond->curr_slave_lock);
+		bond_send_gratuitous_arp(bond);
+		read_unlock(&bond->curr_slave_lock);
+	}
+
 	if (bond_ab_arp_inspect(bond, delta_in_ticks)) {
 		read_unlock(&bond->lock);
 		rtnl_lock();
@@ -3846,6 +3847,7 @@ static int bond_close(struct net_device *bond_dev)
 
 	write_lock_bh(&bond->lock);
 
+	bond->send_grat_arp = 0;
 
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 89fd996..fb730ec 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,8 +22,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"3.2.5"
-#define DRV_RELDATE	"March 21, 2008"
+#define DRV_VERSION	"3.3.0"
+#define DRV_RELDATE	"June 10, 2008"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 
-- 
1.5.2.4

