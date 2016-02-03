From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bonding: 3ad: apply ad_actor settings changes immediately
Date: Wed,  3 Feb 2016 13:17:01 +0100
Message-ID: <1454501821-22175-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:33839 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705AbcBCMRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 07:17:09 -0500
Received: by mail-wm0-f52.google.com with SMTP id 128so162509549wmz.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 04:17:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Currently the bonding allows to set ad_actor_system and prio while the
bond device is down, but these are actually applied only if there aren't
any slaves yet (applied to bond device when first slave shows up, and to
slaves at 3ad bind time). After this patch changes are applied immediately
and the new values can be used/seen after the bond's upped so it's not
necessary anymore to release all and enslave again to see the changes.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/bonding/bond_3ad.c     | 40 +++++++++++++++++++++++++++++++++++---
 drivers/net/bonding/bond_options.c |  4 ++++
 include/net/bond_3ad.h             |  1 +
 3 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 4cbb8b27a891..ee94056dbb2e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -357,6 +357,14 @@ static u8 __get_duplex(struct port *port)
 	return retval;
 }
 
+static void __ad_actor_update_port(struct port *port)
+{
+	const struct bonding *bond = bond_get_bond_by_slave(port->slave);
+
+	port->actor_system = BOND_AD_INFO(bond).system.sys_mac_addr;
+	port->actor_system_priority = BOND_AD_INFO(bond).system.sys_priority;
+}
+
 /* Conversions */
 
 /**
@@ -1963,9 +1971,7 @@ void bond_3ad_bind_slave(struct slave *slave)
 		port->actor_admin_port_key = bond->params.ad_user_port_key << 6;
 		ad_update_actor_keys(port, false);
 		/* actor system is the bond's system */
-		port->actor_system = BOND_AD_INFO(bond).system.sys_mac_addr;
-		port->actor_system_priority =
-		    BOND_AD_INFO(bond).system.sys_priority;
+		__ad_actor_update_port(port);
 		/* tx timer(to verify that no more than MAX_TX_IN_SECOND
 		 * lacpdu's are sent in one second)
 		 */
@@ -2148,6 +2154,34 @@ out:
 }
 
 /**
+ * bond_3ad_update_ad_actor_settings - reflect change of actor settings to ports
+ * @bond: bonding struct to work on
+ *
+ * If an ad_actor setting gets changed we need to update the individual port
+ * settings so the bond device will use the new values when it gets upped.
+ */
+void bond_3ad_update_ad_actor_settings(struct bonding *bond)
+{
+	struct list_head *iter;
+	struct slave *slave;
+
+	ASSERT_RTNL();
+
+	BOND_AD_INFO(bond).system.sys_priority = bond->params.ad_actor_sys_prio;
+	if (is_zero_ether_addr(bond->params.ad_actor_system))
+		BOND_AD_INFO(bond).system.sys_mac_addr =
+		    *((struct mac_addr *)bond->dev->dev_addr);
+	else
+		BOND_AD_INFO(bond).system.sys_mac_addr =
+		    *((struct mac_addr *)bond->params.ad_actor_system);
+
+	spin_lock_bh(&bond->mode_lock);
+	bond_for_each_slave(bond, slave, iter)
+		__ad_actor_update_port(&(SLAVE_AD_INFO(slave)->port));
+	spin_unlock_bh(&bond->mode_lock);
+}
+
+/**
  * bond_3ad_state_machine_handler - handle state machines timeout
  * @bond: bonding struct to work on
  *
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 55e93b6b6d21..ed0bdae64f5e 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -1392,6 +1392,8 @@ static int bond_option_ad_actor_sys_prio_set(struct bonding *bond,
 		    newval->value);
 
 	bond->params.ad_actor_sys_prio = newval->value;
+	bond_3ad_update_ad_actor_settings(bond);
+
 	return 0;
 }
 
@@ -1418,6 +1420,8 @@ static int bond_option_ad_actor_system_set(struct bonding *bond,
 
 	netdev_info(bond->dev, "Setting ad_actor_system to %pM\n", mac);
 	ether_addr_copy(bond->params.ad_actor_system, mac);
+	bond_3ad_update_ad_actor_settings(bond);
+
 	return 0;
 
 err:
diff --git a/include/net/bond_3ad.h b/include/net/bond_3ad.h
index f1fbc3b11962..f358ad5e4214 100644
--- a/include/net/bond_3ad.h
+++ b/include/net/bond_3ad.h
@@ -306,5 +306,6 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave);
 int bond_3ad_set_carrier(struct bonding *bond);
 void bond_3ad_update_lacp_rate(struct bonding *bond);
+void bond_3ad_update_ad_actor_settings(struct bonding *bond);
 #endif /* _NET_BOND_3AD_H */
 
-- 
2.4.3
