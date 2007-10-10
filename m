From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 7/9] net/bonding: Delay sending of gratuitous ARP to avoid failure
Date: Tue,  9 Oct 2007 19:43:42 -0700
Message-ID: <11919842281663-git-send-email-fubar@us.ibm.com>
References: <1191984224957-git-send-email-fubar@us.ibm.com>
 <1191984225129-git-send-email-fubar@us.ibm.com>
 <11919842261485-git-send-email-fubar@us.ibm.com>
 <11919842263810-git-send-email-fubar@us.ibm.com>
 <1191984226411-git-send-email-fubar@us.ibm.com>
 <11919842273755-git-send-email-fubar@us.ibm.com>
 <11919842272176-git-send-email-fubar@us.ibm.com>
Cc: Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:59761 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801AbXJJCnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 22:43:50 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9A2hn3P017510
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 22:43:49 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A2hmJh289400
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:48 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A2hmBm002101
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:48 -0600
In-Reply-To: <11919842272176-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

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
index 7be2336..19fd351 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1103,8 +1103,14 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
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
 
@@ -2073,6 +2079,17 @@ void bond_mii_monitor(struct net_device *bond_dev)
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
@@ -2474,7 +2491,7 @@ static void bond_send_gratuitous_arp(struct bonding *bond)
 
 	if (bond->master_ip) {
 		bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
-				  bond->master_ip, 0);
+				bond->master_ip, 0);
 	}
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
@@ -4280,6 +4297,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
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
-- 
1.5.3.1

