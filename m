From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [RFC PATCH 2/3] net/bonding: bond_change_active_slave() cleanup
 under active-backup
Date: Mon, 2 Jun 2008 13:44:05 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0806021343090.31515@zuben.voltaire.com>
References: <Pine.LNX.4.64.0806021342120.31515@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:17443 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752986AbYFBKoE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 06:44:04 -0400
In-Reply-To: <Pine.LNX.4.64.0806021342120.31515@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

simplified the code of bond_change_active_slave() such that under active-backup mode
there's one "if (new_active)" test and the rest of the code only does extra checks
on top of it. This removed an unneeded "if (bond->send_grat_arp > 0)" check and
avoid calling bond_send_gratuitous_arp when there's no active slave.

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>

---
 drivers/net/bonding/bond_main.c |   18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

Index: netdev-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/bonding/bond_main.c	2008-06-02 10:54:11.000000000 +0300
+++ netdev-2.6/drivers/net/bonding/bond_main.c	2008-06-02 11:55:32.000000000 +0300
@@ -1189,22 +1189,18 @@ void bond_change_active_slave(struct bon

 		if (new_active) {
 			bond_set_slave_active_flags(new_active);
-		}

-		if (new_active && bond->params.fail_over_mac)
-			bond_do_fail_over_mac(bond, new_active, old_active);
+			if (bond->params.fail_over_mac)
+				bond_do_fail_over_mac(bond, new_active, old_active);

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
-			}
+			} else
+				dprintk("delaying gratuitous arp on %s\n",
+					bond->curr_active_slave->dev->name);
 		}
 	}
 }
