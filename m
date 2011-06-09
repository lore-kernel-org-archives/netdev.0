From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next 2/5] bonding:delete lacp_fast from ad_bond_info
Date: Thu,  9 Jun 2011 15:19:02 +0800
Message-ID: <3817de7b47ccfd48b0028f38f268ff241a34e9ec.1307603621.git.panweiping3@gmail.com>
References: <cover.1307603621.git.panweiping3@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Weiping Pan <panweiping3@gmail.com>
To: fubar@us.ibm.com, andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:38573 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756832Ab1FIHSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 03:18:36 -0400
In-Reply-To: <cover.1307603621.git.panweiping3@gmail.com>
In-Reply-To: <cover.1307603621.git.panweiping3@gmail.com>
References: <cover.1307603621.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These is also a bug, that if you modify lacp_rate via sysfs,
and add new slaves in bonding, new slaves won't use the latest lacp_rate,
since ad_bond_info->lacp_fast is initialized only once,
in bond_3ad_initialize().

Since both struct bond_params and ad_bond_info have lacp_fast,
they are duplicate and need extra synchronization.

bond_3ad_bind_slave() can use bond_params->lacp_fast to initialize port.
So we can just remove lacp_fast from struct ad_bond_info.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_3ad.c  |    7 +++----
 drivers/net/bonding/bond_3ad.h  |    5 +----
 drivers/net/bonding/bond_main.c |    3 +--
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 4512bc4..013a801 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1868,11 +1868,10 @@ static u16 aggregator_identifier;
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
@@ -1880,7 +1879,6 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fas
 
 		aggregator_identifier = 0;
 
-		BOND_AD_INFO(bond).lacp_fast = lacp_fast;
 		BOND_AD_INFO(bond).system.sys_priority = 0xFFFF;
 		BOND_AD_INFO(bond).system.sys_mac_addr = *((struct mac_addr *)bond->dev->dev_addr);
 
@@ -1903,6 +1901,7 @@ void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fas
 int bond_3ad_bind_slave(struct slave *slave)
 {
 	struct bonding *bond = bond_get_bond_by_slave(slave);
+	int lacp_fast = bond->params.lacp_fast;
 	struct port *port;
 	struct aggregator *aggregator;
 
@@ -1918,7 +1917,7 @@ int bond_3ad_bind_slave(struct slave *slave)
 		// port initialization
 		port = &(SLAVE_AD_INFO(slave).port);
 
-		ad_initialize_port(port, BOND_AD_INFO(bond).lacp_fast);
+		ad_initialize_port(port, lacp_fast);
 
 		port->slave = slave;
 		port->actor_port_number = SLAVE_AD_INFO(slave).id;
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
index e466faf..9782785 100644
--- a/drivers/net/bonding/bond_3ad.h
+++ b/drivers/net/bonding/bond_3ad.h
@@ -254,9 +254,6 @@ struct ad_bond_info {
 	struct ad_system system;	    /* 802.3ad system structure */
 	u32 agg_select_timer;	    // Timer to select aggregator after all adapter's hand shakes
 	u32 agg_select_mode;	    // Mode of selection of active aggregator(bandwidth/count)
-	int lacp_fast;		/* whether fast periodic tx should be
-				 * requested
-				 */
 	struct timer_list ad_timer;
 };
 
@@ -269,7 +266,7 @@ struct ad_slave_info {
 };
 
 // ================= AD Exported functions to the main bonding code ==================
-void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution, int lacp_fast);
+void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution);
 int  bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
 void bond_3ad_state_machine_handler(struct work_struct *);
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
-- 
1.7.4.4

