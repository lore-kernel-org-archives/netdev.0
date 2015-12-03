From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 18/28] bonding: implement lower state change propagation
Date: Thu,  3 Dec 2015 12:12:20 +0100
Message-ID: <1449141150-8172-19-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34259 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760100AbbLCLNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:13:00 -0500
Received: by wmvv187 with SMTP id v187so21662223wmv.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:58 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
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
index 7695490..2f11450 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1317,6 +1317,16 @@ void bond_queue_slave_event(struct slave *slave)
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
index 1df4377..ee6c520 100644
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
