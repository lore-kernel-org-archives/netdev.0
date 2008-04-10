From: Moni Shoua <monis@voltaire.com>
Subject: [PATCH] net/bonding: Send more than one gratuitous ARP when slave
 takes over
Date: Thu, 10 Apr 2008 18:07:25 +0300
Message-ID: <47FE2D2D.2040504@voltaire.com>
Reply-To: monis@voltaire.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Olga Stern <olgas@voltaire.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:17938 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755573AbYDJOEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2008 10:04:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With IPoIB, reception of gratuitous ARP by neighboring hosts
is essential for a successful change of slaves in case of failure.
Otherwise, they won't learn about the HW address change and need
to wait a long time until the neighboring system gives up and sends
an ARP request to learn the new HW address.  This patch decreases
the chance for a lost of a gratuitous ARP packet by sending it more
than once. The number retries is configurable and can be set with a module param.

Signed-off-by: Moni Shoua <monis@voltaire.com>
---
 drivers/net/bonding/bond_main.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0942d82..c066dc0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -88,6 +88,7 @@ #define BOND_LINK_MON_INTERV	0
 #define BOND_LINK_ARP_INTERV	0
 
 static int max_bonds	= BOND_DEFAULT_MAX_BONDS;
+static int num_grat_arp = 1;
 static int miimon	= BOND_LINK_MON_INTERV;
 static int updelay	= 0;
 static int downdelay	= 0;
@@ -104,6 +105,8 @@ struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
+module_param(num_grat_arp, int, 0644);
+MODULE_PARM_DESC(num_grat_arp, "Number of gratuitous ARP packet to sned on failover");
 module_param(miimon, int, 0);
 MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
 module_param(updelay, int, 0);
@@ -1109,14 +1112,16 @@ void bond_change_active_slave(struct bon
 		if (new_active && bond->params.fail_over_mac)
 			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
 				new_active->dev->addr_len);
+		bond->send_grat_arp = num_grat_arp;
 		if (bond->curr_active_slave &&
 			test_bit(__LINK_STATE_LINKWATCH_PENDING,
-					&bond->curr_active_slave->dev->state)) {
+					&bond->curr_active_slave->dev->state))
 			dprintk("delaying gratuitous arp on %s\n",
 				bond->curr_active_slave->dev->name);
-			bond->send_grat_arp = 1;
-		} else
+		else {
 			bond_send_gratuitous_arp(bond);
+			bond->send_grat_arp--;
+		}
 	}
 }
 
@@ -2144,7 +2149,7 @@ static int __bond_mii_monitor(struct bon
 			dprintk("sending delayed gratuitous arp on on %s\n",
 				bond->curr_active_slave->dev->name);
 			bond_send_gratuitous_arp(bond);
-			bond->send_grat_arp = 0;
+			bond->send_grat_arp--;
 		}
 	}
 	read_lock(&bond->curr_slave_lock);
