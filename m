From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 16/26] bonding: implement lower state change propagation
Date: Tue,  1 Dec 2015 14:48:54 +0100
Message-ID: <1448977744-17930-17-git-send-email-jiri@resnulli.us>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37778 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756231AbbLANt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 08:49:28 -0500
Received: by wmww144 with SMTP id w144so14077170wmw.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 05:49:27 -0800 (PST)
In-Reply-To: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Let netdev notifier listeners know about link and slave state change.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/bonding/bond_main.c | 10 ++++++++++
 include/net/bonding.h           |  7 +++++++
 2 files changed, 17 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c9943fc..e153a87 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1315,6 +1315,16 @@ void bond_queue_slave_event(struct slave *slave)
 	queue_delayed_work(slave->bond->wq, &nnw->work, 0);
 }
 
+void bond_lower_state_changed(struct slave *slave)
+{
+	struct netdev_lag_lower_state_info info;
+
+	info.link_up = slave->link == BOND_LINK_UP ||
+		       slave->link == BOND_LINK_FAIL;
+	info.tx_enabled = bond_is_active_slave(slave);
+	netdev_lower_state_changed(slave->dev, &info);
+}
+
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
diff --git a/include/net/bonding.h b/include/net/bonding.h
index 50496ec..5c75446 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -247,6 +247,7 @@ struct bonding {
 	((struct slave *) rtnl_dereference(dev->rx_handler_data))
 
 void bond_queue_slave_event(struct slave *slave);
+void bond_lower_state_changed(struct slave *slave);
 
 struct bond_vlan_tag {
 	__be16		vlan_proto;
@@ -328,6 +329,7 @@ static inline void bond_set_active_slave(struct slave *slave)
 	if (slave->backup) {
 		slave->backup = 0;
 		bond_queue_slave_event(slave);
+		bond_lower_state_changed(slave);
 		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 	}
 }
@@ -337,6 +339,7 @@ static inline void bond_set_backup_slave(struct slave *slave)
 	if (!slave->backup) {
 		slave->backup = 1;
 		bond_queue_slave_event(slave);
+		bond_lower_state_changed(slave);
 		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 	}
 }
@@ -349,6 +352,7 @@ static inline void bond_set_slave_state(struct slave *slave,
 
 	slave->backup = slave_state;
 	if (notify) {
+		bond_lower_state_changed(slave);
 		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
 		bond_queue_slave_event(slave);
 		slave->should_notify = 0;
@@ -380,6 +384,7 @@ static inline void bond_slave_state_notify(struct bonding *bond)
 
 	bond_for_each_slave(bond, tmp, iter) {
 		if (tmp->should_notify) {
+			bond_lower_state_changed(tmp);
 			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_ATOMIC);
 			tmp->should_notify = 0;
 		}
@@ -514,6 +519,7 @@ static inline void bond_set_slave_link_state(struct slave *slave, int state,
 	slave->link = state;
 	if (notify) {
 		bond_queue_slave_event(slave);
+		bond_lower_state_changed(slave);
 		slave->should_notify_link = 0;
 	} else {
 		if (slave->should_notify_link)
@@ -531,6 +537,7 @@ static inline void bond_slave_link_notify(struct bonding *bond)
 	bond_for_each_slave(bond, tmp, iter) {
 		if (tmp->should_notify_link) {
 			bond_queue_slave_event(tmp);
+			bond_lower_state_changed(tmp);
 			tmp->should_notify_link = 0;
 		}
 	}
-- 
1.9.3
