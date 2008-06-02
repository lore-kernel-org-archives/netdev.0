From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: [RFC v2 PATCH 3/3] net/bonding: deliver netdev event for fail-over
 under the active-backup mode
Date: Mon, 2 Jun 2008 13:47:03 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0806021344270.31515@zuben.voltaire.com>
References: <Pine.LNX.4.64.0806021342120.31515@zuben.voltaire.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:18801 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752610AbYFBKrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 06:47:03 -0400
In-Reply-To: <Pine.LNX.4.64.0806021342120.31515@zuben.voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

under active-backup mode and when there's actual new_active slave, have bond_change_active_slave()
call the networking core to deliver NETDEV_BONDING_FAILOVER event such that the fail-over can
be notable by code outside of the bonding driver such as the RDMA stack and monitoring tools.

As the correct context of locking appropriate for notifier calls is RTNL and nothing else,
bond->curr_slave_lock and bond->lock are unlocked and later locked again. This is ensured
by the rest of the code to be safe under backup-mode AND when new_active is not NULL.

Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>

- changes from v1
 * set correct locking context for the notifier call
 * with these unlockings I don't see any more the "scheduling while atomic" warnings

---
 drivers/net/bonding/bond_main.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: netdev-2.6/drivers/net/bonding/bond_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/bonding/bond_main.c	2008-06-02 11:55:32.000000000 +0300
+++ netdev-2.6/drivers/net/bonding/bond_main.c	2008-06-02 11:56:07.000000000 +0300
@@ -1201,6 +1201,12 @@ void bond_change_active_slave(struct bon
 			} else
 				dprintk("delaying gratuitous arp on %s\n",
 					bond->curr_active_slave->dev->name);
+
+			write_unlock_bh(&bond->curr_slave_lock);
+			read_unlock(&bond->lock);
+			netdev_bonding_change(bond->dev)
+			read_lock(&bond->lock);
+			write_lock_bh(&bond->curr_slave_lock);
 		}
 	}
 }
