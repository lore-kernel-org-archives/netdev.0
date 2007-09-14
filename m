From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 9/11] net/bonding: Delay sending of gratuitous ARP to avoid failure
Date: Fri, 14 Sep 2007 16:40:28 -0700
Message-ID: <11898132472055-git-send-email-fubar@us.ibm.com>
References: <11898132301664-git-send-email-fubar@us.ibm.com>
 <11898132322950-git-send-email-fubar@us.ibm.com>
 <1189813234208-git-send-email-fubar@us.ibm.com>
 <11898132352341-git-send-email-fubar@us.ibm.com>
 <11898132372856-git-send-email-fubar@us.ibm.com>
 <11898132411426-git-send-email-fubar@us.ibm.com>
 <1189813242354-git-send-email-fubar@us.ibm.com>
 <11898132441599-git-send-email-fubar@us.ibm.com>
 <11898132452802-git-send-email-fubar@us.ibm.com>
Cc: monisonlists@gmail.com, ogerlitz@voltaire.com, jgarzik@pobox.com,
	davem@davemloft.net, general@lists.openfabrics.org,
	Moni Shoua <monis@voltaire.com>
To: netdev@vger.kernel.org, rdreier@cisco.com, monis@voltaire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:52820 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758420AbXINXku (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 19:40:50 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8ENenHf015504
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:49 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8ENenQh664712
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:49 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8ENem2Z008936
	for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 19:40:49 -0400
In-Reply-To: <11898132452802-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Moni Shoua <monis@voltaire.com>

Delay sending a gratuitous_arp when LINK_STATE_LINKWATCH_PENDING bit
in dev->state field is on. This improves the chances for the arp packet to
be transmitted.

Signed-off-by: Moni Shoua <monis@voltaire.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |   24 +++++++++++++++++++++---
 drivers/net/bonding/bonding.h   |    1 +
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9ff2cf6..dfbfb00 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1102,8 +1102,14 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
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
 
@@ -2083,6 +2089,17 @@ void bond_mii_monitor(struct net_device *bond_dev)
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
@@ -2484,7 +2501,7 @@ static void bond_send_gratuitous_arp(struct bonding *bond)
 
 	if (bond->master_ip) {
 		bond_arp_send(slave->dev, ARPOP_REPLY, bond->master_ip,
-				  bond->master_ip, 0);
+				bond->master_ip, 0);
 	}
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
@@ -4293,6 +4310,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond->current_arp_slave = NULL;
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
+	bond->send_grat_arp = 0;
 	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b7b4f4a..b1cdb1f 100644
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
1.5.2-rc2.GIT

