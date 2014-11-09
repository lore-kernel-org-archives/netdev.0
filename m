From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 06/10] bridge: introduce fdb offloading via switchdev
Date: Sun,  9 Nov 2014 11:51:16 +0100
Message-ID: <1415530280-9190-7-git-send-email-jiri@resnulli.us>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-wi0-f171.google.com ([209.85.212.171]:34268 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbaKIKva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 05:51:30 -0500
Received: by mail-wi0-f171.google.com with SMTP id r20so8032047wiv.16
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 02:51:29 -0800 (PST)
In-Reply-To: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add two new ndos: ndo_sw_port_fdb_add/del to offload static bridge
fdb entries.  Static bridge FDB entries are installed, for example,
using iproute2 bridge cmd:

       bridge fdb add ADDR dev DEV master vlan VID

This would install ADDR into the bridge's FDB for port DEV on vlan VID.  The
switch driver implements two ndo_swdev ops to add/delete FDB entries in the
switch device:

       int ndo_sw_port_fdb_add(struct net_device *dev,
                               const unsigned char *addr,
                               u16 vid);

       int ndo_sw_port_fdb_del(struct net_device *dev,
                               const unsigned char *addr,
                               u16 vid);

The driver returns 0 on success, negative error code on failure.

Note: the switch driver would not implement ndo_fdb_add/del/dump on a port
netdev as these are intended for devices maintaining their own FDB.  In our
case, we want the Linux bridge to own the FBD.

Note: by default, the bridge does not filter on VLAN and only bridges untagged
traffic.  To enable VLAN support, turn on VLAN filtering:

      echo 1 >/sys/class/net/<bridge>/bridge/vlan_filtering

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h | 16 ++++++++++++++++
 include/net/switchdev.h   | 17 +++++++++++++++++
 net/bridge/br_fdb.c       | 10 +++++++++-
 net/switchdev/switchdev.c | 41 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 83 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97eade9..116a19d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1023,6 +1023,16 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	Called to get an ID of the switch chip this port is part of.
  *	If driver implements this, it indicates that it represents a port
  *	of a switch chip.
+ *
+ * int (*ndo_sw_port_fdb_add)(struct net_device *dev,
+ *			      const unsigned char *addr,
+ *			      u16 vid);
+ *	Called to add a fdb to switch device port.
+ *
+ * int (*ndo_sw_port_fdb_del)(struct net_device *dev,
+ *			      const unsigned char *addr,
+ *			      u16 vid);
+ *	Called to delete a fdb from switch device port.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1177,6 +1187,12 @@ struct net_device_ops {
 #ifdef CONFIG_NET_SWITCHDEV
 	int			(*ndo_sw_parent_id_get)(struct net_device *dev,
 							struct netdev_phys_item_id *psid);
+	int			(*ndo_sw_port_fdb_add)(struct net_device *dev,
+						       const unsigned char *addr,
+						       u16 vid);
+	int			(*ndo_sw_port_fdb_del)(struct net_device *dev,
+						       const unsigned char *addr,
+						       u16 vid);
 #endif
 };
 
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 79bf9bd..130cef7 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -1,6 +1,7 @@
 /*
  * include/net/switchdev.h - Switch device API
  * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2014 Scott Feldman <sfeldma@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -16,6 +17,10 @@
 
 int netdev_sw_parent_id_get(struct net_device *dev,
 			    struct netdev_phys_item_id *psid);
+int netdev_sw_port_fdb_add(struct net_device *dev,
+			   const unsigned char *addr, u16 vid);
+int netdev_sw_port_fdb_del(struct net_device *dev,
+			   const unsigned char *addr, u16 vid);
 
 #else
 
@@ -25,6 +30,18 @@ static inline int netdev_sw_parent_id_get(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline int netdev_sw_port_fdb_add(struct net_device *dev,
+					 const unsigned char *addr, u16 vid)
+{
+	return -EOPNOTSUPP;
+}
+
+static inline int netdev_sw_port_fdb_del(struct net_device *dev,
+					 const unsigned char *addr, u16 vid)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 6f6c95c..f6f8bb5 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -24,6 +24,7 @@
 #include <linux/atomic.h>
 #include <asm/unaligned.h>
 #include <linux/if_vlan.h>
+#include <net/switchdev.h>
 #include "br_private.h"
 
 static struct kmem_cache *br_fdb_cache __read_mostly;
@@ -132,8 +133,12 @@ static void fdb_del_hw(struct net_bridge *br, const unsigned char *addr)
 
 static void fdb_delete(struct net_bridge *br, struct net_bridge_fdb_entry *f)
 {
-	if (f->is_static)
+	if (f->is_static) {
 		fdb_del_hw(br, f->addr.addr);
+		if (f->dst)
+			netdev_sw_port_fdb_del(f->dst->dev,
+					       f->addr.addr, f->vlan_id);
+	}
 
 	hlist_del_rcu(&f->hlist);
 	fdb_notify(br, f, RTM_DELNEIGH);
@@ -755,18 +760,21 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
 			if (!fdb->is_static) {
 				fdb->is_static = 1;
 				fdb_add_hw(br, addr);
+				netdev_sw_port_fdb_add(source->dev, addr, vid);
 			}
 		} else if (state & NUD_NOARP) {
 			fdb->is_local = 0;
 			if (!fdb->is_static) {
 				fdb->is_static = 1;
 				fdb_add_hw(br, addr);
+				netdev_sw_port_fdb_add(source->dev, addr, vid);
 			}
 		} else {
 			fdb->is_local = 0;
 			if (fdb->is_static) {
 				fdb->is_static = 0;
 				fdb_del_hw(br, addr);
+				netdev_sw_port_fdb_del(source->dev, addr, vid);
 			}
 		}
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 5010f646..93d47b7 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -1,6 +1,7 @@
 /*
  * net/switchdev/switchdev.c - Switch device API
  * Copyright (c) 2014 Jiri Pirko <jiri@resnulli.us>
+ * Copyright (c) 2014 Scott Feldman <sfeldma@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -31,3 +32,43 @@ int netdev_sw_parent_id_get(struct net_device *dev,
 	return ops->ndo_sw_parent_id_get(dev, psid);
 }
 EXPORT_SYMBOL(netdev_sw_parent_id_get);
+
+/**
+ *	netdev_sw_port_fdb_add - Add a fdb into switch port
+ *	@dev: port device
+ *	@addr: mac address
+ *	@vid: vlan id
+ *
+ *	Add a fdb into switch port.
+ */
+int netdev_sw_port_fdb_add(struct net_device *dev,
+			   const unsigned char *addr, u16 vid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_sw_port_fdb_add)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_sw_parent_id_get);
+	return ops->ndo_sw_port_fdb_add(dev, addr, vid);
+}
+EXPORT_SYMBOL(netdev_sw_port_fdb_add);
+
+/**
+ *	netdev_sw_port_fdb_del - Delete a fdb from switch port
+ *	@dev: port device
+ *	@addr: mac address
+ *	@vid: vlan id
+ *
+ *	Delete a fdb from switch port.
+ */
+int netdev_sw_port_fdb_del(struct net_device *dev,
+			   const unsigned char *addr, u16 vid)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_sw_port_fdb_del)
+		return -EOPNOTSUPP;
+	WARN_ON(!ops->ndo_sw_parent_id_get);
+	return ops->ndo_sw_port_fdb_del(dev, addr, vid);
+}
+EXPORT_SYMBOL(netdev_sw_port_fdb_del);
-- 
1.9.3
