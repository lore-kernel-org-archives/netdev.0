From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [RFC 2/5] net: bridge - add managing of BRCTL_SET_VIA_PHYS_DEV and BRCTL_SET_MASTER_DEV
Date: Mon, 11 May 2009 15:46:41 +0400
Message-ID: <20090511125350.796823421@openvz.org>
References: <20090511114639.440944109@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, xemul@openvz.org,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:31090 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbZEKMx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 08:53:56 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2140700rvb.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2009 05:53:57 -0700 (PDT)
Content-Disposition: inline; filename=net-br-via_phys
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add managing via_phys_dev feature at sysctl level and ioctls as well.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---

Note: there is no changing done for __bridge_info structure and
in handling of BRCTL_GET_BRIDGE_INFO since they are part of
userspace. So returning info about master_dev could break
userpace applications. Not sure how to better handle it
and eventually decided to not touch it at all.

 include/linux/if_bridge.h |    2 ++
 net/bridge/br_if.c        |   22 ++++++++++++++++++++++
 net/bridge/br_ioctl.c     |   29 +++++++++++++++++++++++++++++
 net/bridge/br_private.h   |    2 ++
 net/bridge/br_sysfs_br.c  |   23 +++++++++++++++++++++++
 5 files changed, 78 insertions(+)

Index: linux-2.6.git/include/linux/if_bridge.h
=====================================================================
--- linux-2.6.git.orig/include/linux/if_bridge.h
+++ linux-2.6.git/include/linux/if_bridge.h
@@ -42,6 +42,8 @@
 #define BRCTL_SET_PORT_PRIORITY 16
 #define BRCTL_SET_PATH_COST 17
 #define BRCTL_GET_FDB_ENTRIES 18
+#define BRCTL_SET_VIA_PHYS_DEV 19
+#define BRCTL_SET_MASTER_DEV 20
 
 #define BR_STATE_DISABLED 0
 #define BR_STATE_LISTENING 1
Index: linux-2.6.git/net/bridge/br_if.c
=====================================================================
--- linux-2.6.git.orig/net/bridge/br_if.c
+++ linux-2.6.git/net/bridge/br_if.c
@@ -158,6 +158,11 @@ static void del_br(struct net_bridge *br
 {
 	struct net_bridge_port *p, *n;
 
+	if (br->master_dev) {
+		dev_put(br->master_dev);
+		br->master_dev = NULL;
+	}
+
 	list_for_each_entry_safe(p, n, &br->port_list, list) {
 		del_nbp(p);
 	}
@@ -412,6 +417,19 @@ int br_add_if(struct net_bridge *br, str
 	if ((dev->flags & IFF_UP) && netif_carrier_ok(dev) &&
 	    (br->dev->flags & IFF_UP))
 		br_stp_enable_port(p);
+
+	/*
+	 * since brctl utils could not have BRCTL_SET_MASTER_DEV
+	 * yet implemented we set first port as master device
+	 * if via_phys_dev is turned on
+	 */
+	if (br->via_phys_dev) {
+		if (!br->master_dev) {
+			dev_hold(dev);
+			br->master_dev = dev;
+		}
+	}
+
 	spin_unlock_bh(&br->lock);
 
 	br_ifinfo_notify(RTM_NEWLINK, p);
@@ -446,6 +464,10 @@ int br_del_if(struct net_bridge *br, str
 	spin_lock_bh(&br->lock);
 	br_stp_recalculate_bridge_id(br);
 	br_features_recompute(br);
+	if (br->master_dev == dev) {
+		br->master_dev = NULL;
+		dev_put(dev);
+	}
 	spin_unlock_bh(&br->lock);
 
 	return 0;
Index: linux-2.6.git/net/bridge/br_ioctl.c
=====================================================================
--- linux-2.6.git.orig/net/bridge/br_ioctl.c
+++ linux-2.6.git/net/bridge/br_ioctl.c
@@ -262,6 +262,35 @@ static int old_dev_ioctl(struct net_devi
 		br_stp_set_enabled(br, args[1]);
 		return 0;
 
+	case BRCTL_SET_VIA_PHYS_DEV:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		br->via_phys_dev = args[1] ? true : false;
+		return 0;
+
+	case BRCTL_SET_MASTER_DEV:
+	{
+		struct net_device *dev;
+
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (!br->via_phys_dev) {
+			pr_debug("Bridge: turn on via_phys_dev feature first\n");
+			return -EINVAL;
+		}
+
+		dev = dev_get_by_index(dev_net(br->dev), args[1]);
+		if (dev == NULL)
+			return -EINVAL;
+
+		if (br->master_dev)
+			dev_put(br->master_dev);
+		br->master_dev = dev;
+
+		return 0;
+	}
+
 	case BRCTL_SET_BRIDGE_PRIORITY:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
Index: linux-2.6.git/net/bridge/br_private.h
=====================================================================
--- linux-2.6.git.orig/net/bridge/br_private.h
+++ linux-2.6.git/net/bridge/br_private.h
@@ -89,6 +89,8 @@ struct net_bridge
 	spinlock_t			lock;
 	struct list_head		port_list;
 	struct net_device		*dev;
+	struct net_device		*master_dev;
+	bool				via_phys_dev;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 	struct list_head		age_list;
Index: linux-2.6.git/net/bridge/br_sysfs_br.c
=====================================================================
--- linux-2.6.git.orig/net/bridge/br_sysfs_br.c
+++ linux-2.6.git/net/bridge/br_sysfs_br.c
@@ -181,6 +181,28 @@ static ssize_t store_stp_state(struct de
 static DEVICE_ATTR(stp_state, S_IRUGO | S_IWUSR, show_stp_state,
 		   store_stp_state);
 
+static ssize_t show_via_phys_dev_state(struct device *cd,
+				struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(cd);
+	return sprintf(buf, "%d\n", br->via_phys_dev);
+}
+
+static int set_via_phys_dev_state(struct net_bridge *br, unsigned long val)
+{
+	br->via_phys_dev = val ? true : false;
+	return 0;
+}
+
+static ssize_t store_via_phys_dev_state(struct device *cd,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	return store_bridge_parm(cd, buf, len, set_via_phys_dev_state);
+}
+
+static DEVICE_ATTR(via_phys_dev, S_IRUGO | S_IWUSR, show_via_phys_dev_state,
+		store_via_phys_dev_state);
+
 static ssize_t show_priority(struct device *d, struct device_attribute *attr,
 			     char *buf)
 {
@@ -350,6 +372,7 @@ static struct attribute *bridge_attrs[] 
 	&dev_attr_max_age.attr,
 	&dev_attr_ageing_time.attr,
 	&dev_attr_stp_state.attr,
+	&dev_attr_via_phys_dev.attr,
 	&dev_attr_priority.attr,
 	&dev_attr_bridge_id.attr,
 	&dev_attr_root_id.attr,

