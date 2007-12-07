From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 6/8] bonding: Fix time comparison
Date: Thu,  6 Dec 2007 23:40:33 -0800
Message-ID: <11970132394126-git-send-email-fubar@us.ibm.com>
References: <11970132353950-git-send-email-fubar@us.ibm.com>
 <11970132363756-git-send-email-fubar@us.ibm.com>
 <11970132372293-git-send-email-fubar@us.ibm.com>
 <1197013237259-git-send-email-fubar@us.ibm.com>
 <11970132382296-git-send-email-fubar@us.ibm.com>
 <11970132381345-git-send-email-fubar@us.ibm.com>
Cc: jgarzik@pobox.com, David Sterba <dsterba@suse.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:52979 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbXLGHkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 02:40:41 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB76d5V2031375
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 01:39:05 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB77eeYL120796
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:40 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB77edTu018134
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 00:40:40 -0700
In-Reply-To: <11970132381345-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Sterba <dsterba@suse.cz>

From: David Sterba <dsterba@suse.cz>

Use macros for comparing jiffies. Jiffies' wrap caused missed events and hangs.
Module reinsert was needed to make bonding work again.

Signed-off-by: David Sterba <dsterba@suse.cz>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
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
 
-- 
1.5.3.4.206.g58ba4-dirty

