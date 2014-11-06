From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/10] bridge: call netdev_sw_port_stp_update when bridge port STP status changes
Date: Thu,  6 Nov 2014 10:20:07 +0100
Message-ID: <1415265610-9338-8-git-send-email-jiri@resnulli.us>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
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
	bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:46398 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbaKFJUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 04:20:21 -0500
Received: by mail-wg0-f41.google.com with SMTP id k14so672085wgh.14
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 01:20:20 -0800 (PST)
In-Reply-To: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

To notify switch driver of change in STP state of bridge port, add new
.ndo op and provide swdev wrapper func to call ndo op. Use it in bridge
code then.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |  6 ++++++
 include/net/switchdev.h   |  6 ++++++
 net/bridge/br_netlink.c   |  2 ++
 net/bridge/br_stp.c       |  4 ++++
 net/bridge/br_stp_if.c    |  3 +++
 net/bridge/br_stp_timer.c |  2 ++
 net/switchdev/switchdev.c | 19 +++++++++++++++++++
 7 files changed, 42 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7de65c5..21e5869 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1033,6 +1033,10 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *			      const unsigned char *addr,
  *			      u16 vid);
  *	Called to delete a fdb from switch device port.
+ *
+ * int (*ndo_sw_port_stp_update)(struct net_device *dev, u8 state);
+ *	Called to notify switch device port of bridge port STP
+ *	state change.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1193,6 +1197,8 @@ struct net_device_ops {
 	int			(*ndo_sw_port_fdb_del)(struct net_device *dev,
 						       const unsigned char *addr,
 						       u16 vid);
+	int			(*ndo_sw_port_stp_update)(struct net_device *dev,
+							  u8 state);
 #endif
 };
 
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 130cef7..bbf7369 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -21,6 +21,7 @@ int netdev_sw_port_fdb_add(struct net_device *dev,
 			   const unsigned char *addr, u16 vid);
 int netdev_sw_port_fdb_del(struct net_device *dev,
 			   const unsigned char *addr, u16 vid);
+int netdev_sw_port_stp_update(struct net_device *dev, u8 state);
 
 #else
 
@@ -42,6 +43,11 @@ static inline int netdev_sw_port_fdb_del(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int netdev_sw_port_stp_update(struct net_device *dev, u8 state)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 86c239b..13fecf1 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -17,6 +17,7 @@
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <uapi/linux/if_bridge.h>
+#include <net/switchdev.h>
 
 #include "br_private.h"
 #include "br_private_stp.h"
@@ -304,6 +305,7 @@ static int br_set_port_state(struct net_bridge_port *p, u8 state)
 
 	br_set_state(p, state);
 	br_log_state(p);
+	netdev_sw_port_stp_update(p->dev, p->state);
 	br_port_state_selection(p->br);
 	return 0;
 }
diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 2b047bc..c00139b 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -12,6 +12,7 @@
  */
 #include <linux/kernel.h>
 #include <linux/rculist.h>
+#include <net/switchdev.h>
 
 #include "br_private.h"
 #include "br_private_stp.h"
@@ -114,6 +115,7 @@ static void br_root_port_block(const struct net_bridge *br,
 
 	br_set_state(p, BR_STATE_LISTENING);
 	br_log_state(p);
+	netdev_sw_port_stp_update(p->dev, p->state);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	if (br->forward_delay > 0)
@@ -394,6 +396,7 @@ static void br_make_blocking(struct net_bridge_port *p)
 
 		br_set_state(p, BR_STATE_BLOCKING);
 		br_log_state(p);
+		netdev_sw_port_stp_update(p->dev, p->state);
 		br_ifinfo_notify(RTM_NEWLINK, p);
 
 		del_timer(&p->forward_delay_timer);
@@ -419,6 +422,7 @@ static void br_make_forwarding(struct net_bridge_port *p)
 
 	br_multicast_enable_port(p);
 	br_log_state(p);
+	netdev_sw_port_stp_update(p->dev, p->state);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	if (br->forward_delay != 0)
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 4114687..91279f8 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -15,6 +15,7 @@
 #include <linux/kmod.h>
 #include <linux/etherdevice.h>
 #include <linux/rtnetlink.h>
+#include <net/switchdev.h>
 
 #include "br_private.h"
 #include "br_private_stp.h"
@@ -89,6 +90,7 @@ void br_stp_enable_port(struct net_bridge_port *p)
 	br_init_port(p);
 	br_port_state_selection(p->br);
 	br_log_state(p);
+	netdev_sw_port_stp_update(p->dev, p->state);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 }
 
@@ -105,6 +107,7 @@ void br_stp_disable_port(struct net_bridge_port *p)
 	p->config_pending = 0;
 
 	br_log_state(p);
+	netdev_sw_port_stp_update(p->dev, p->state);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	del_timer(&p->message_age_timer);
diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
index 4fcaa67..5bb8997 100644
--- a/net/bridge/br_stp_timer.c
+++ b/net/bridge/br_stp_timer.c
@@ -13,6 +13,7 @@
 
 #include <linux/kernel.h>
 #include <linux/times.h>
+#include <net/switchdev.h>
 
 #include "br_private.h"
 #include "br_private_stp.h"
@@ -97,6 +98,7 @@ static void br_forward_delay_timer_expired(unsigned long arg)
 		netif_carrier_on(br->dev);
 	}
 	br_log_state(p);
+	netdev_sw_port_stp_update(p->dev, p->state);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 	spin_unlock(&br->lock);
 }
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 93d47b7..75997a5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -72,3 +72,22 @@ int netdev_sw_port_fdb_del(struct net_device *dev,
 	return ops->ndo_sw_port_fdb_del(dev, addr, vid);
 }
 EXPORT_SYMBOL(netdev_sw_port_fdb_del);
+
+/**
+ *	netdev_sw_port_stp_update - Notify switch device port of STP
+ *				    state change
+ *	@dev: port device
+ *	@state: port STP state
+ *
+ *	Notify switch device port of bridge port STP state change.
+ */
+int netdev_sw_port_stp_update(struct net_device *dev, u8 state)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_sw_port_stp_update)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_sw_parent_id_get);
+	return ops->ndo_sw_port_stp_update(dev, state);
+}
+EXPORT_SYMBOL(netdev_sw_port_stp_update);
-- 
1.9.3
