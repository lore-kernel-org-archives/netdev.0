From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v3 2/6] bonding: implement bond_poll_controller()
Date: Wed, 11 Feb 2015 20:24:25 -0800
Message-ID: <1423715065-9304-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f201.google.com ([74.125.82.201]:33451 "EHLO
	mail-we0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688AbbBLEaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2015 23:30:30 -0500
Received: by mail-we0-f201.google.com with SMTP id k11so954210wes.0
        for <netdev@vger.kernel.org>; Wed, 11 Feb 2015 20:30:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches implements the poll_controller support for all
bonding driver. If the slaves have poll_controller net_op defined,
this implementation calls them. This is mode agnostic implementation
and iterates through all slaves (based on mode) and calls respective
handler.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v1:
   Initial version
v2:
   Eliminate bool variable.
v3:
   Rebase

 drivers/net/bonding/bond_3ad.c  | 24 ++++++++++++++++++++++++
 drivers/net/bonding/bond_main.c | 33 +++++++++++++++++++++++++++++++++
 include/net/bond_3ad.h          |  1 +
 3 files changed, 58 insertions(+)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 9b436696b95e..14f2ebe786c5 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2477,6 +2477,30 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 	return ret;
 }
 
+#define BOND_3AD_PORT_OPERATIONAL \
+		(AD_STATE_DISTRIBUTING | AD_STATE_COLLECTING | \
+		 AD_STATE_SYNCHRONIZATION | AD_STATE_AGGREGATION)
+
+static int bond_3ad_port_operational(struct slave *slave)
+{
+	port_t *port = &SLAVE_AD_INFO(slave)->port;
+
+	return bond_slave_can_tx(slave) &&
+	       (port->actor_oper_port_state & port->partner_oper.port_state &
+		BOND_3AD_PORT_OPERATIONAL) == BOND_3AD_PORT_OPERATIONAL;
+}
+
+/* bond_3ad_port_is_active - check if a slave port is active or not. A port
+ * is active when it can forward traffic.
+ *
+ * @slave: slave port to check state for.
+ * Returns: 0 if not active else is active.
+ */
+int bond_3ad_port_is_active(struct slave *slave)
+{
+	return bond_3ad_port_operational(slave);
+}
+
 int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave)
 {
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b979c265fc51..8433fe464f95 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -928,6 +928,39 @@ static inline void slave_disable_netpoll(struct slave *slave)
 
 static void bond_poll_controller(struct net_device *bond_dev)
 {
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave = NULL;
+	struct list_head *iter;
+	struct ad_info ad_info;
+	struct netpoll_info *ni;
+	const struct net_device_ops *ops;
+
+	if (BOND_MODE(bond) == BOND_MODE_8023AD)
+		if (bond_3ad_get_active_agg_info(bond, &ad_info))
+			return;
+
+	bond_for_each_slave(bond, slave, iter) {
+		ops = slave->dev->netdev_ops;
+		if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
+			continue;
+
+		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
+			struct aggregator *agg =
+			    SLAVE_AD_INFO(slave)->port.aggregator;
+
+			if (agg && agg->aggregator_identifier !=
+				   ad_info.aggregator_id)
+				continue;
+		    if (!bond_3ad_port_is_active(slave) || ad_info.ports != 1)
+				continue;
+		}
+
+		ni = rcu_dereference_bh(slave->dev->npinfo);
+		if (down_trylock(&ni->dev_lock))
+			continue;
+		ops->ndo_poll_controller(slave->dev);
+		up(&ni->dev_lock);
+	}
 }
 
 static void bond_netpoll_cleanup(struct net_device *bond_dev)
diff --git a/include/net/bond_3ad.h b/include/net/bond_3ad.h
index f04cdbb7848e..6c455c646d61 100644
--- a/include/net/bond_3ad.h
+++ b/include/net/bond_3ad.h
@@ -278,5 +278,6 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
 			 struct slave *slave);
 int bond_3ad_set_carrier(struct bonding *bond);
 void bond_3ad_update_lacp_rate(struct bonding *bond);
+int bond_3ad_port_is_active(struct slave *slave);
 #endif /* _NET_BOND_3AD_H */
 
-- 
2.2.0.rc0.207.ga3a616c
