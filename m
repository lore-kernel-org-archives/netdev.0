From: David Sterba <dsterba@suse.cz>
Subject: [PATCH] bonding: Fix time comparison
Date: Wed, 05 Dec 2007 09:52:05 +0100
Message-ID: <20071205085205.7220.98225.stgit@ds.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dsterba@suse.cz, bonding-devel@lists.sourceforge.net,
	fubar@us.ibm.com, ctindel@users.sourceforge.net,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:43298 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750892AbXLEIwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 03:52:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bonding: Fix time comparison

Use macros for comparing jiffies. Jiffies' wrap caused missed events and hangs.
Module reinsert was needed to make bonding work again.

Signed-off-by: David Sterba <dsterba@suse.cz>
---

 drivers/net/bonding/bond_main.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 423298c..e4a4714 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -74,6 +74,7 @@
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
 #include <linux/if_bonding.h>
+#include <linux/jiffies.h>
 #include <net/route.h>
 #include <net/net_namespace.h>
 #include "bonding.h"
@@ -2722,8 +2723,8 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	 */
 	bond_for_each_slave(bond, slave, i) {
 		if (slave->link != BOND_LINK_UP) {
-			if (((jiffies - slave->dev->trans_start) <= delta_in_ticks) &&
-			    ((jiffies - slave->dev->last_rx) <= delta_in_ticks)) {
+			if (time_before_eq(jiffies, slave->dev->trans_start + delta_in_ticks) &&
+			    time_before_eq(jiffies, slave->dev->last_rx + delta_in_ticks)) {
 
 				slave->link  = BOND_LINK_UP;
 				slave->state = BOND_STATE_ACTIVE;
@@ -2754,8 +2755,8 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 			 * when the source ip is 0, so don't take the link down
 			 * if we don't know our ip yet
 			 */
-			if (((jiffies - slave->dev->trans_start) >= (2*delta_in_ticks)) ||
-			    (((jiffies - slave->dev->last_rx) >= (2*delta_in_ticks)) &&
+			if (time_after_eq(jiffies, slave->dev->trans_start + 2*delta_in_ticks) ||
+			    (time_after_eq(jiffies, slave->dev->last_rx + 2*delta_in_ticks) &&
 			     bond_has_ip(bond))) {
 
 				slave->link  = BOND_LINK_DOWN;
@@ -2848,8 +2849,8 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 	 */
 	bond_for_each_slave(bond, slave, i) {
 		if (slave->link != BOND_LINK_UP) {
-			if ((jiffies - slave_last_rx(bond, slave)) <=
-			     delta_in_ticks) {
+			if (time_before_eq(jiffies,
+			    slave_last_rx(bond, slave) + delta_in_ticks)) {
 
 				slave->link = BOND_LINK_UP;
 
@@ -2858,7 +2859,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 				write_lock_bh(&bond->curr_slave_lock);
 
 				if ((!bond->curr_active_slave) &&
-				    ((jiffies - slave->dev->trans_start) <= delta_in_ticks)) {
+				    time_before_eq(jiffies, slave->dev->trans_start + delta_in_ticks)) {
 					bond_change_active_slave(bond, slave);
 					bond->current_arp_slave = NULL;
 				} else if (bond->curr_active_slave != slave) {
@@ -2897,7 +2898,7 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 
 			if ((slave != bond->curr_active_slave) &&
 			    (!bond->current_arp_slave) &&
-			    (((jiffies - slave_last_rx(bond, slave)) >= 3*delta_in_ticks) &&
+			    (time_after_eq(jiffies, slave_last_rx(bond, slave) + 3*delta_in_ticks) &&
 			     bond_has_ip(bond))) {
 				/* a backup slave has gone down; three times
 				 * the delta allows the current slave to be
@@ -2943,10 +2944,10 @@ void bond_activebackup_arp_mon(struct work_struct *work)
 		 * before being taken out. if a primary is being used, check
 		 * if it is up and needs to take over as the curr_active_slave
 		 */
-		if ((((jiffies - slave->dev->trans_start) >= (2*delta_in_ticks)) ||
-	    (((jiffies - slave_last_rx(bond, slave)) >= (2*delta_in_ticks)) &&
-	     bond_has_ip(bond))) &&
-		    ((jiffies - slave->jiffies) >= 2*delta_in_ticks)) {
+		if ((time_after_eq(jiffies, slave->dev->trans_start + 2*delta_in_ticks) ||
+			(time_after_eq(jiffies, slave_last_rx(bond, slave) + 2*delta_in_ticks) &&
+			 bond_has_ip(bond))) &&
+			time_after_eq(jiffies, slave->jiffies + 2*delta_in_ticks)) {
 
 			slave->link  = BOND_LINK_DOWN;
 

