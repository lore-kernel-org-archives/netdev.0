From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v5 09/21] bridge: call netdev_sw_port_stp_update when bridge port STP status changes
Date: Fri, 28 Nov 2014 14:34:20 +0100
Message-ID: <1417181672-11531-10-git-send-email-jiri@resnulli.us>
References: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org, hemal@broadcom.co
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:40515 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbaK1Neo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2014 08:34:44 -0500
Received: by mail-wi0-f172.google.com with SMTP id n3so18572671wiv.11
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2014 05:34:43 -0800 (PST)
In-Reply-To: <1417181672-11531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

To notify switch driver of change in STP state of bridge port, add new
.ndo op and provide switchdev wrapper func to call ndo op. Use it in bridge
code then.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
Acked-by: Florian Fainelli <f.fainelli@gmail.com>
---
v4->v5:
-no change
v3->v4:
-added warning when call to netdev_sw_port_stp_update was not successful
 suggested by Andy
v2->v3:
-changed "sw" string to "switch" to avoid confusion
v1->v2:
-no change
---
 include/linux/netdevice.h |  5 +++++
 include/net/switchdev.h   |  7 +++++++
 net/bridge/br_stp.c       |  7 +++++++
 net/switchdev/switchdev.c | 19 +++++++++++++++++++
 4 files changed, 38 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3603f31..29c92ee 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1024,6 +1024,9 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Called to get an ID of the switch chip this port is part of.
  *	If driver implements this, it indicates that it represents a port
  *	of a switch chip.
+ * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
+ *	Called to notify switch device port of bridge port STP
+ *	state change.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1180,6 +1183,8 @@ struct net_device_ops {
 #ifdef CONFIG_NET_SWITCHDEV
 	int			(*ndo_switch_parent_id_get)(struct net_device *dev,
 							    struct netdev_phys_item_id *psid);
+	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
+							      u8 state);
 #endif
 };
 
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 7a52360..8a6d164 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -16,6 +16,7 @@
 
 int netdev_switch_parent_id_get(struct net_device *dev,
 				struct netdev_phys_item_id *psid);
+int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
 
 #else
 
@@ -25,6 +26,12 @@ static inline int netdev_switch_parent_id_get(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int netdev_switch_port_stp_update(struct net_device *dev,
+						u8 state)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 2b047bc..fb3ebe6 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -12,6 +12,7 @@
  */
 #include <linux/kernel.h>
 #include <linux/rculist.h>
+#include <net/switchdev.h>
 
 #include "br_private.h"
 #include "br_private_stp.h"
@@ -38,7 +39,13 @@ void br_log_state(const struct net_bridge_port *p)
 
 void br_set_state(struct net_bridge_port *p, unsigned int state)
 {
+	int err;
+
 	p->state = state;
+	err = netdev_switch_port_stp_update(p->dev, state);
+	if (err && err != -EOPNOTSUPP)
+		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
+				(unsigned int) p->port_no, p->dev->name);
 }
 
 /* called under bridge lock */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 66973de..d162b21 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -31,3 +31,22 @@ int netdev_switch_parent_id_get(struct net_device *dev,
 	return ops->ndo_switch_parent_id_get(dev, psid);
 }
 EXPORT_SYMBOL(netdev_switch_parent_id_get);
+
+/**
+ *	netdev_switch_port_stp_update - Notify switch device port of STP
+ *					state change
+ *	@dev: port device
+ *	@state: port STP state
+ *
+ *	Notify switch device port of bridge port STP state change.
+ */
+int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_switch_port_stp_update)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_switch_parent_id_get);
+	return ops->ndo_switch_port_stp_update(dev, state);
+}
+EXPORT_SYMBOL(netdev_switch_port_stp_update);
-- 
1.9.3
