From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v2] bonding: implement bond_poll_controller()
Date: Wed,  4 Mar 2015 21:57:52 -0800
Message-ID: <1425535072-23068-1-git-send-email-maheshb@google.com>
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
Received: from mail-qa0-f74.google.com ([209.85.216.74]:52936 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbbCEF54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 00:57:56 -0500
Received: by mail-qa0-f74.google.com with SMTP id w8so7072517qac.1
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 21:57:56 -0800 (PST)
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
  Initial patch
v2:
  Corrected rcu mismatch.

 drivers/net/bonding/bond_main.c | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index af5908a2190c..19eabea2d7d9 100644
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
+	rcu_read_lock_bh();
+	bond_for_each_slave_rcu(bond, slave, iter) {
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
+	rcu_read_unlock_bh();
 }
 
 static void bond_netpoll_cleanup(struct net_device *bond_dev)
-- 
2.2.0.rc0.207.ga3a616c
