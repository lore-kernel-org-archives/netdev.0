From: David Herrmann <dh.herrmann@gmail.com>
Subject: [PATCH v3 1/4] net: add name_assign_type netdev attribute
Date: Mon, 17 Mar 2014 18:03:45 +0100
Message-ID: <1395075825-5824-1-git-send-email-dh.herrmann@gmail.com>
References: <1394990490-1076-2-git-send-email-dh.herrmann@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>,
	Johannes berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <ben@decadent.org.uk>,
	David Herrmann <dh.herrmann@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394990490-1076-2-git-send-email-dh.herrmann@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The name_assign_type attribute gives hints where the interface name of a
given net-device comes from. Three different values are currently defined:
  NET_NAME_ENUM:
    This is the default. The ifname is provided by the kernel with an
    enumerated suffix. Names may be reused and unstable.
  NET_NAME_USER:
    The ifname was provided by user-space during net-device setup.
  NET_NAME_RENAMED:
    The net-device has been renamed via RTNL. Once this type is set, it
    cannot change again.

This attribute comes in handy for reliable net-device names. If an ifname
is provided by user-space, we can safely assume that the naming-policy
avoids reuse and is stable. Only if it was set by the kernel, the
interfaces might need to be renamed.

The NET_NAME_RENAMED value allows us to detect whether some-one else
already renamed the device, in which case we shouldn't touch it again. The
NET_NAME_USER value allows us to detect whether some other naming policy
created the device, in which case there's no need to rename it.

The most significant use-case is to detect virtual wifi-P2P devices, which
are named by wpa_supplicant et al. We shouldn't rename them as wpas
already provides a proper naming-policy.

Note that this patch only provides the core infrastructure. The different
net-dev types need to be manually fixed to use NET_NAME_USER instead of
the default (NET_NAME_ENUM). NET_NAME_ENUM is the least restrictive,
though, so it seems safe to use it as fallback for non-converted net-dev
types.

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
Acked-by: Tom Gundersen <teg@jklm.no>
---
v3:
 - move constants to uapi header (suggested by Ben)

 include/linux/netdevice.h      | 1 +
 include/uapi/linux/netdevice.h | 4 ++++
 net/core/dev.c                 | 7 +++++++
 net/core/net-sysfs.c           | 2 ++
 net/core/rtnetlink.c           | 2 ++
 5 files changed, 16 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index b8d8c80..6698e87 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1248,6 +1248,7 @@ struct net_device {
 	 * of the interface.
 	 */
 	char			name[IFNAMSIZ];
+	unsigned char		name_assign_type; /* name assignment type */
 
 	/* device name hash chain, please keep it close to name[] */
 	struct hlist_node	name_hlist;
diff --git a/include/uapi/linux/netdevice.h b/include/uapi/linux/netdevice.h
index 6b9500b..ea963e4 100644
--- a/include/uapi/linux/netdevice.h
+++ b/include/uapi/linux/netdevice.h
@@ -36,6 +36,10 @@
 /* Initial net device group. All devices belong to group 0 by default. */
 #define INIT_NETDEV_GROUP	0
 
+/* interface name assignment types (sysfs name_assign_type attribute) */
+#define NET_NAME_ENUM		0	/* enumerated by kernel (default) */
+#define NET_NAME_USER		1	/* provided by user-space */
+#define NET_NAME_RENAMED	2	/* renamed by user-space */
 
 
 /* Media selection options. */
diff --git a/net/core/dev.c b/net/core/dev.c
index 587f9fb..4a2b360 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1083,6 +1083,7 @@ static int dev_get_valid_name(struct net *net,
 int dev_change_name(struct net_device *dev, const char *newname)
 {
 	char oldname[IFNAMSIZ];
+	unsigned char old_assign_type;
 	int err = 0;
 	int ret;
 	struct net *net;
@@ -1109,10 +1110,14 @@ int dev_change_name(struct net_device *dev, const char *newname)
 		return err;
 	}
 
+	old_assign_type = dev->name_assign_type;
+	dev->name_assign_type = NET_NAME_RENAMED;
+
 rollback:
 	ret = device_rename(&dev->dev, dev->name);
 	if (ret) {
 		memcpy(dev->name, oldname, IFNAMSIZ);
+		dev->name_assign_type = old_assign_type;
 		write_seqcount_end(&devnet_rename_seq);
 		return ret;
 	}
@@ -1141,6 +1146,8 @@ rollback:
 			write_seqcount_begin(&devnet_rename_seq);
 			memcpy(dev->name, oldname, IFNAMSIZ);
 			memcpy(oldname, newname, IFNAMSIZ);
+			dev->name_assign_type = old_assign_type;
+			old_assign_type = NET_NAME_RENAMED;
 			goto rollback;
 		} else {
 			pr_err("%s: name change rollback failed: %d\n",
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index daed9a6..886403e 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -105,6 +105,7 @@ static ssize_t netdev_store(struct device *dev, struct device_attribute *attr,
 
 NETDEVICE_SHOW_RO(dev_id, fmt_hex);
 NETDEVICE_SHOW_RO(dev_port, fmt_dec);
+NETDEVICE_SHOW_RO(name_assign_type, fmt_dec);
 NETDEVICE_SHOW_RO(addr_assign_type, fmt_dec);
 NETDEVICE_SHOW_RO(addr_len, fmt_dec);
 NETDEVICE_SHOW_RO(iflink, fmt_dec);
@@ -377,6 +378,7 @@ static struct attribute *net_class_attrs[] = {
 	&dev_attr_dev_port.attr,
 	&dev_attr_iflink.attr,
 	&dev_attr_ifindex.attr,
+	&dev_attr_name_assign_type.attr,
 	&dev_attr_addr_assign_type.attr,
 	&dev_attr_addr_len.attr,
 	&dev_attr_link_mode.attr,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index fc122fd..f1bd0fe 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1967,6 +1967,8 @@ replay:
 		}
 
 		dev->ifindex = ifm->ifi_index;
+		if (tb[IFLA_IFNAME])
+			dev->name_assign_type = NET_NAME_USER;
 
 		if (ops->newlink) {
 			err = ops->newlink(net, dev, tb, data);
-- 
1.9.0
