From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/5] bonding: deliver netdev event for fail-over under the active-backup mode
Date: Fri, 13 Jun 2008 18:12:02 -0700
Message-ID: <12134059261873-git-send-email-fubar@us.ibm.com>
References: <12134059242107-git-send-email-fubar@us.ibm.com>
 <12134059253135-git-send-email-fubar@us.ibm.com>
 <12134059253839-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:58279 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757855AbYFNBMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 21:12:18 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5E1C75a008562
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 21:12:07 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5E1C7gf076502
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:07 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5E1C6Eh030254
	for <netdev@vger.kernel.org>; Fri, 13 Jun 2008 19:12:07 -0600
In-Reply-To: <12134059253839-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@voltaire.com>

under active-backup mode and when there's actual new_active slave,
have bond_change_active_slave() call the networking core to deliver
NETDEV_BONDING_FAILOVER event such that the fail-over can be notable
by code outside of the bonding driver such as the RDMA stack and
monitoring tools.

As the correct context of locking appropriate for notifier calls is RTNL
and nothing else, bond->curr_slave_lock and bond->lock are unlocked and
later locked again. This is ensured by the rest of the code to be safe
under backup-mode AND when new_active is not NULL.

Jay Vosburgh modified the original patch for formatting and fixed a
compiler error.

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2db2d05..925402b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1203,6 +1203,14 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 				dprintk("delaying gratuitous arp on %s\n",
 					bond->curr_active_slave->dev->name);
 			}
+
+			write_unlock_bh(&bond->curr_slave_lock);
+			read_unlock(&bond->lock);
+
+			netdev_bonding_change(bond->dev);
+
+			read_lock(&bond->lock);
+			write_lock_bh(&bond->curr_slave_lock);
 		}
 	}
 }
-- 
1.5.2.4

