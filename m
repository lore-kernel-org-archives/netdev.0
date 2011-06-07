From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH] bonding: use new value of lacp_rate and ad_select
Date: Tue,  7 Jun 2011 10:24:15 +0800
Message-ID: <1307413455-6942-1-git-send-email-panweiping3@gmail.com>
Cc: Weiping Pan <panweiping3@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com> (supporter:BONDING DRIVER),
	Andy Gospodarek <andy@greyhouse.net> (supporter:BONDING DRIVER),
	netdev@vger.kernel.org (open list:BONDING DRIVER),
	linux-kernel@vger.kernel.org (open list)
To: jpirko@redhat.com, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:48694 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757055Ab1FGCX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 22:23:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is bug that when you modify lacp_rate via sysfs,
802.3ad won't use the new value of lacp_rate to transmit packets.
This is because port->actor_oper_port_state isn't changed.

As for ad_select, it can work,
but both struct bond_params and ad_bond_info have lacp_fast and ad_select,
they are duplicate and need extra synchronization.
802.3ad can get them from bond_params directly every time.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_3ad.c   |   41 ++++++++++++++++++++++++++++++++-----
 drivers/net/bonding/bond_3ad.h   |    7 +----
 drivers/net/bonding/bond_main.c  |    3 +-
 drivers/net/bonding/bond_sysfs.c |    1 +
 4 files changed, 39 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c7537abc..6122725 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -262,7 +262,7 @@ static inline u32 __get_agg_selection_mode(struct port *port)
 	if (bond == NULL)
 		return BOND_AD_STABLE;
 
-	return BOND_AD_INFO(bond).agg_select_mode;
+	return bond->params.ad_select;
 }
 
 /**
@@ -1859,7 +1859,6 @@ static void ad_marker_response_received(struct bond_marker *marker,
 void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout)
 {
 	BOND_AD_INFO(bond).agg_select_timer = timeout;
-	BOND_AD_INFO(bond).agg_select_mode = bond->params.ad_select;
 }
 
 static u16 aggregator_identifier;
@@ -1868,11 +1867,10 @@ static u16 aggregator_identifier;
  * bond_3ad_initialize - initialize a bond's 802.3ad parameters and structures
  * @bond: bonding struct to work on
  * @tick_resolution: tick duration (millisecond resolution)
- * @lacp_fast: boolean. whether fast periodic should be used
  *
  * Can be called only after the mac address of the bond is set.
  */
-void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast)
+void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution)
 {
 	// check that the bond is not initialized yet
 	if (MAC_ADDRESS_COMPARE(&(BOND_AD_INFO(bond).system.sys_mac_addr),
@@ -1880,7 +1878,6 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fas
 
 		aggregator_identifier = 0;
 
-		BOND_AD_INFO(bond).lacp_fast = lacp_fast;
 		BOND_AD_INFO(bond).system.sys_priority = 0xFFFF;
 		BOND_AD_INFO(bond).system.sys_mac_addr = *((struct mac_addr *)bond->dev->dev_addr);
 
@@ -1903,6 +1900,7 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fas
 int bond_3ad_bind_slave(struct slave *slave)
 {
 	struct bonding *bond = bond_get_bond_by_slave(slave);
+	int lacp_fast = bond->params.lacp_fast;
 	struct port *port;
 	struct aggregator *aggregator;
 
@@ -1918,7 +1916,7 @@ int bond_3ad_bind_slave(struct slave *slave)
 		// port initialization
 		port = &(SLAVE_AD_INFO(slave).port);
 
-		ad_initialize_port(port, BOND_AD_INFO(bond).lacp_fast);
+		ad_initialize_port(port, lacp_fast);
 
 		port->slave = slave;
 		port->actor_port_number = SLAVE_AD_INFO(slave).id;
@@ -2473,3 +2471,34 @@ void bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
 	bond_3ad_rx_indication((struct lacpdu *) skb->data, slave, skb->len);
 	read_unlock(&bond->lock);
 }
+
+/*
+ * When modify lacp_rate parameter via sysfs,
+ * update actor_oper_port_state of each port.
+ *
+ * Hold slave->state_machine_lock,
+ * so we can modify port->actor_oper_port_state,
+ * no matter bond is up or down.
+ */
+void bond_3ad_update_lacp_rate(struct bonding *bond)
+{
+	int i;
+	struct slave *slave;
+	struct port *port = NULL;
+	int lacp_fast;
+
+	read_lock(&bond->lock);
+	lacp_fast = bond->params.lacp_fast;
+
+	bond_for_each_slave(bond, slave, i) {
+		port = &(SLAVE_AD_INFO(slave).port);
+		__get_state_machine_lock(port);
+		if (lacp_fast)
+			port->actor_oper_port_state |= AD_STATE_LACP_TIMEOUT;
+		else
+			port->actor_oper_port_state &= ~AD_STATE_LACP_TIMEOUT;
+		__release_state_machine_lock(port);
+	}
+
+	read_unlock(&bond->lock);
+}
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index 0ee3f16..1682e69 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -253,10 +253,6 @@ struct ad_system {
 struct ad_bond_info {
 	struct ad_system system;	    /* 802.3ad system structure */
 	u32 agg_select_timer;	    // Timer to select aggregator after all adapter's hand shakes
-	u32 agg_select_mode;	    // Mode of selection of active aggregator(bandwidth/count)
-	int lacp_fast;		/* whether fast periodic tx should be
-				 * requested
-				 */
 	struct timer_list ad_timer;
 };
 
@@ -269,7 +265,7 @@ struct ad_slave_info {
 };
 
 // ================= AD Exported functions to the main bonding code ==================
-void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast);
+void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution);
 int  bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
 void bond_3ad_state_machine_handler(struct work_struct *);
@@ -282,5 +278,6 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
 void bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
 			  struct slave *slave);
 int bond_3ad_set_carrier(struct bonding *bond);
+void bond_3ad_update_lacp_rate(struct bonding *bond);
 #endif //__BOND_3AD_H__
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 716c852..bb1af9c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1843,8 +1843,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 			/* Initialize AD with the number of times that the AD timer is called in 1 second
 			 * can be called only after the mac address of the bond is set
 			 */
-			bond_3ad_initialize(bond, 1000/AD_TIMER_INTERVAL,
-					    bond->params.lacp_fast);
+			bond_3ad_initialize(bond, 1000/AD_TIMER_INTERVAL);
 		} else {
 			SLAVE_AD_INFO(new_slave).id =
 				SLAVE_AD_INFO(new_slave->prev).id + 1;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 88fcb25..03d1196 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -804,6 +804,7 @@ static ssize_t bonding_store_lacp(struct device *d,
 
 	if ((new_value == 1) || (new_value == 0)) {
 		bond->params.lacp_fast = new_value;
+		bond_3ad_update_lacp_rate(bond);
 		pr_info("%s: Setting LACP rate to %s (%d).\n",
 			bond->dev->name, bond_lacp_tbl[new_value].modename,
 			new_value);
-- 
1.7.4.4

