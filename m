From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 03/10] net/bonding: Notify state change on slaves
Date: Tue,  3 Feb 2015 16:48:31 +0200
Message-ID: <1422974919-28084-4-git-send-email-ogerlitz@mellanox.com>
References: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60039 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751725AbbBCOtl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 09:49:41 -0500
In-Reply-To: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

Use notifier chain to dispatch an event upon a change in slave state.
Event is dispatched with slave specific info.

Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/bonding/bond_main.c |   42 +++++++++++++++++++++++++++++++++++++++
 include/net/bonding.h           |   12 +++++++++++
 2 files changed, 54 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0665608..c9771f3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1191,6 +1191,47 @@ static void bond_fill_ifslave(struct slave *slave, struct ifslave *info)
 	info->link_failure_count = slave->link_failure_count;
 }
 
+static void bond_netdev_notify(struct slave *slave, struct net_device *dev)
+{
+	struct bonding *bond = slave->bond;
+	struct netdev_bonding_info bonding_info;
+
+	rtnl_lock();
+	/* make sure that slave is still valid */
+	if (dev->priv_flags & IFF_BONDING) {
+		bond_fill_ifslave(slave, &bonding_info.slave);
+		bond_fill_ifbond(bond, &bonding_info.master);
+		netdev_bonding_info_change(slave->dev, &bonding_info);
+	}
+	rtnl_unlock();
+}
+
+static void bond_netdev_notify_work(struct work_struct *_work)
+{
+	struct netdev_notify_work *w =
+		container_of(_work, struct netdev_notify_work, work.work);
+
+	bond_netdev_notify(w->slave, w->dev);
+	dev_put(w->dev);
+}
+
+void bond_queue_slave_event(struct slave *slave)
+{
+	struct netdev_notify_work *nnw = kzalloc(sizeof(*nnw), GFP_ATOMIC);
+
+	if (!nnw)
+		return;
+
+	INIT_DELAYED_WORK(&nnw->work, bond_netdev_notify_work);
+	nnw->slave = slave;
+	nnw->dev = slave->dev;
+
+	if (queue_delayed_work(slave->bond->wq, &nnw->work, 0))
+		dev_hold(slave->dev);
+	else
+		kfree(nnw);
+}
+
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
@@ -1585,6 +1626,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		    new_slave->link != BOND_LINK_DOWN ? "an up" : "a down");
 
 	/* enslave is successful */
+	bond_queue_slave_event(new_slave);
 	return 0;
 
 /* Undo stages on error */
diff --git a/include/net/bonding.h b/include/net/bonding.h
index d1367ec..4e17095 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -150,6 +150,12 @@ struct bond_parm_tbl {
 	int mode;
 };
 
+struct netdev_notify_work {
+	struct delayed_work	work;
+	struct slave		*slave;
+	struct net_device	*dev;
+};
+
 struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
 	struct bonding *bond; /* our master */
@@ -243,6 +249,8 @@ struct bonding {
 #define bond_slave_get_rtnl(dev) \
 	((struct slave *) rtnl_dereference(dev->rx_handler_data))
 
+void bond_queue_slave_event(struct slave *slave);
+
 struct bond_vlan_tag {
 	__be16		vlan_proto;
 	unsigned short	vlan_id;
@@ -315,6 +323,7 @@ static inline void bond_set_active_slave(struct slave *slave)
 {
 	if (slave->backup) {
 		slave->backup = 0;
+		bond_queue_slave_event(slave);
 		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 	}
 }
@@ -323,6 +332,7 @@ static inline void bond_set_backup_slave(struct slave *slave)
 {
 	if (!slave->backup) {
 		slave->backup = 1;
+		bond_queue_slave_event(slave);
 		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 	}
 }
@@ -336,6 +346,7 @@ static inline void bond_set_slave_state(struct slave *slave,
 	slave->backup = slave_state;
 	if (notify) {
 		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
+		bond_queue_slave_event(slave);
 		slave->should_notify = 0;
 	} else {
 		if (slave->should_notify)
@@ -493,6 +504,7 @@ static inline bool bond_is_slave_inactive(struct slave *slave)
 static inline void bond_set_slave_link_state(struct slave *slave, int state)
 {
 	slave->link = state;
+	bond_queue_slave_event(slave);
 }
 
 static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be32 local)
-- 
1.7.1
