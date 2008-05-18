From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/8] bonding: remove test for IP in ARP monitor
Date: Sat, 17 May 2008 21:10:08 -0700
Message-ID: <12110838151104-git-send-email-fubar@us.ibm.com>
References: <12110838143907-git-send-email-fubar@us.ibm.com>
 <12110838151824-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:57514 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbYEREKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 00:10:25 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4I4ALmQ024267
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 00:10:22 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4I4AGot078642
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4I4AGFh004557
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:16 -0600
In-Reply-To: <12110838151824-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Remove bond_has_ip and all references to it.  With this change,
the ARP monitor will always send ARP probes if the master is up and has
at least one slave.  If the bond has an IP address, it is used in the
ARP probe; if not, the probes are sent with all zeros in the sender's
IP address (which is consistent with an RFC 2131 4.4.1 duplicate address
probe).

	This is useful for cases when bonding itself is hidden underneath
a layer of virtual devices, e.g., with Xen.

	Change suggested by Tsutomu Fujii <t-fujii@nb.jp.nec.com>, who
included a one-line patch that only affected active-backup mode.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   31 ++++---------------------------
 1 files changed, 4 insertions(+), 27 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 12c7158..e3da1e5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2426,25 +2426,6 @@ out:
 	return addr;
 }
 
-static int bond_has_ip(struct bonding *bond)
-{
-	struct vlan_entry *vlan, *vlan_next;
-
-	if (bond->master_ip)
-		return 1;
-
-	if (list_empty(&bond->vlan_list))
-		return 0;
-
-	list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-				 vlan_list) {
-		if (vlan->vlan_ip)
-			return 1;
-	}
-
-	return 0;
-}
-
 static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 {
 	struct vlan_entry *vlan, *vlan_next;
@@ -2764,8 +2745,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 			 * if we don't know our ip yet
 			 */
 			if (time_after_eq(jiffies, slave->dev->trans_start + 2*delta_in_ticks) ||
-			    (time_after_eq(jiffies, slave->dev->last_rx + 2*delta_in_ticks) &&
-			     bond_has_ip(bond))) {
+			    (time_after_eq(jiffies, slave->dev->last_rx + 2*delta_in_ticks))) {
 
 				slave->link  = BOND_LINK_DOWN;
 				slave->state = BOND_STATE_BACKUP;
@@ -2900,8 +2880,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 			if ((slave != bond->curr_active_slave) &&
 			    (!bond->current_arp_slave) &&
-			    (time_after_eq(jiffies, slave_last_rx(bond, slave) + 3*delta_in_ticks) &&
-			     bond_has_ip(bond))) {
+			    (time_after_eq(jiffies, slave_last_rx(bond, slave) + 3*delta_in_ticks))) {
 				/* a backup slave has gone down; three times
 				 * the delta allows the current slave to be
 				 * taken out before the backup slave.
@@ -2947,8 +2926,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 		 * if it is up and needs to take over as the curr_active_slave
 		 */
 		if ((time_after_eq(jiffies, slave->dev->trans_start + 2*delta_in_ticks) ||
-			(time_after_eq(jiffies, slave_last_rx(bond, slave) + 2*delta_in_ticks) &&
-			 bond_has_ip(bond))) &&
+		     (time_after_eq(jiffies, slave_last_rx(bond, slave) + 2*delta_in_ticks))) &&
 			time_after_eq(jiffies, slave->jiffies + 2*delta_in_ticks)) {
 
 			slave->link  = BOND_LINK_DOWN;
@@ -3000,9 +2978,8 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 		/* the current slave must tx an arp to ensure backup slaves
 		 * rx traffic
 		 */
-		if (slave && bond_has_ip(bond)) {
+		if (slave && IS_UP(slave->dev))
 			bond_arp_send_all(bond, slave);
-		}
 	}
 
 	/* if we don't have a curr_active_slave, search for the next available
-- 
1.5.2.4

