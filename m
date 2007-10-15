From: Moni Shoua <monis@voltaire.com>
Subject: PATCH V6 7/8] net/bonding: Delay sending of gratuitous ARP to avoid
 failure
Date: Mon, 15 Oct 2007 18:13:55 +0200
Message-ID: <471391C3.6060108@voltaire.com>
References: <47138EB7.40703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: jgarzik@pobox.com, fubar@us.ibm.com, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:43050 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757973AbXJOQOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 12:14:00 -0400
In-Reply-To: <47138EB7.40703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Delay sending a gratuitous_arp when LINK_STATE_LINKWATCH_PENDING bit
in dev->state field is on. This improves the chances for the arp packet to
be transmitted.

Signed-off-by: Moni Shoua <monis at voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   24 +++++++++++++++++++++---
 drivers/net/bonding/bonding.h   |    1 +
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3f082dc..c017042 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1103,8 +1103,14 @@ void bond_change_active_slave(struct bon
 		if (new_active && !bond->do_set_mac_addr)
 			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
 				new_active->dev->addr_len);
-
-		bond_send_gratuitous_arp(bond);
+		if (bond->curr_active_slave &&
+			test_bit(__LINK_STATE_LINKWATCH_PENDING,
+					&bond->curr_active_slave->dev->state)) {
+			dprintk("delaying gratuitous arp on %s\n",
+				bond->curr_active_slave->dev->name);
+			bond->send_grat_arp = 1;
+		} else
+			bond_send_gratuitous_arp(bond);
 	}
 }
 
@@ -2074,6 +2080,17 @@ void bond_mii_monitor(struct net_device 
 	 * program could monitor the link itself if needed.
 	 */
 
+	if (bond->send_grat_arp) {
+		if (bond->curr_active_slave && test_bit(__LINK_STATE_LINKWATCH_PENDING,
+				&bond->curr_active_slave->dev->state))
+			dprintk("Needs to send gratuitous arp but not yet\n");
+		else {
+			dprintk("sending delayed gratuitous arp on on %s\n",
+				bond->curr_active_slave->dev->name);
+			bond_send_gratuitous_arp(bond);
+			bond->send_grat_arp = 0;
+		}
+	}
 	read_lock(&bond->curr_slave_lock);
 	oldcurrent = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
@@ -2475,7 +2492,7 @@ static void bond_send_gratuitous_arp(str
 
 	if (bond->master_ip) {
 		bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
-				  bond->master_ip, 0);
+				bond->master_ip, 0);
 	}
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
@@ -4281,6 +4298,7 @@ static int bond_init(struct net_device *
 	bond->current_arp_slave = NULL;
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
+	bond->send_grat_arp = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ad9c632..e0e06a8 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -187,6 +187,7 @@ struct bonding {
 	struct   timer_list arp_timer;
 	s8       kill_timers;
 	s8       do_set_mac_addr;
+	s8	 send_grat_arp;
 	struct   net_device_stats stats;
 #ifdef CONFIG_PROC_FS
 	struct   proc_dir_entry *proc_entry;

