From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/5] bonding: bond_change_active_slave() cleanup under active-backup
Date: Fri, 13 Jun 2008 18:12:01 -0700
Message-ID: <12134059253839-git-send-email-fubar@us.ibm.com>
References: <12134059242107-git-send-email-fubar@us.ibm.com>
 <12134059253135-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:58393 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757763AbYFNBMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 21:12:18 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5E1C7ai010054
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 21:12:07 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5E1C6wt167320
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5E1C6q6030223
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:06 -0600
In-Reply-To: <12134059253135-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@voltaire.com>

simplified the code of bond_change_active_slave() such that under
active-backup mode there's one "if (new_active)" test and the rest
of the code only does extra checks on top of it. This removed an
unneeded "if (bond->send_grat_arp > 0)" check and avoid calling
bond_send_gratuitous_arp when there's no active slave.

Jay Vosburgh made minor coding style changes to the orignal patch.

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 5b4af3c..2db2d05 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1189,21 +1189,19 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 
 		if (new_active) {
 			bond_set_slave_active_flags(new_active);
-		}
 
-		if (new_active && bond->params.fail_over_mac)
-			bond_do_fail_over_mac(bond, new_active, old_active);
+			if (bond->params.fail_over_mac)
+				bond_do_fail_over_mac(bond, new_active,
+						      old_active);
 
-		bond->send_grat_arp = bond->params.num_grat_arp;
-		if (bond->curr_active_slave &&
-			test_bit(__LINK_STATE_LINKWATCH_PENDING,
+			bond->send_grat_arp = bond->params.num_grat_arp;
+			if (!test_bit(__LINK_STATE_LINKWATCH_PENDING,
 					&bond->curr_active_slave->dev->state)) {
-			dprintk("delaying gratuitous arp on %s\n",
-				bond->curr_active_slave->dev->name);
-		} else {
-			if (bond->send_grat_arp > 0) {
 				bond_send_gratuitous_arp(bond);
 				bond->send_grat_arp--;
+			} else {
+				dprintk("delaying gratuitous arp on %s\n",
+					bond->curr_active_slave->dev->name);
 			}
 		}
 	}
-- 
1.5.2.4

