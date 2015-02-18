From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v5 2/6] bonding: implement bond_poll_controller()
Date: Wed, 18 Feb 2015 14:31:22 -0800
Message-ID: <1424298682-18227-1-git-send-email-maheshb@google.com>
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
Received: from mail-pd0-f201.google.com ([209.85.192.201]:34007 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752372AbbBRWbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 17:31:25 -0500
Received: by pdjy10 with SMTP id y10so1479703pdj.1
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2015 14:31:25 -0800 (PST)
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
v4:
   Removed 3AD port_operational check
v5:
   Added rtnl protection for bond_for_each_slave()

 drivers/net/bonding/bond_main.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b979c265fc51..63e6c0dbe7b3 100644
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
+	rtnl_lock();
+	bond_for_each_slave(bond, slave, iter) {
+		ops = slave->dev->netdev_ops;
+		if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
+			continue;
+
+		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
+			struct aggregator *agg =
+			    SLAVE_AD_INFO(slave)->port.aggregator;
+
+			if (agg &&
+			    agg->aggregator_identifier != ad_info.aggregator_id)
+				continue;
+		}
+
+		ni = rcu_dereference_bh(slave->dev->npinfo);
+		if (down_trylock(&ni->dev_lock))
+			continue;
+		ops->ndo_poll_controller(slave->dev);
+		up(&ni->dev_lock);
+	}
+	rtnl_unlock();
 }
 
 static void bond_netpoll_cleanup(struct net_device *bond_dev)
-- 
2.2.0.rc0.207.ga3a616c
