From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCHv2 bridge 6/7] bridge: Add sysfs interface to display VLANS
Date: Wed, 19 Sep 2012 08:42:15 -0400
Message-ID: <1348058536-22607-7-git-send-email-vyasevic@redhat.com>
References: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1904 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756433Ab2ISMmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 08:42:23 -0400
In-Reply-To: <1348058536-22607-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a binary sysfs file that will dump out vlans currently configured on the
port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/if_bridge.h |    1 +
 net/bridge/br_sysfs_if.c  |   70 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 8476d6f..cc85739 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -20,6 +20,7 @@
 #define SYSFS_BRIDGE_PORT_SUBDIR "brif"
 #define SYSFS_BRIDGE_PORT_ATTR	"brport"
 #define SYSFS_BRIDGE_PORT_LINK	"bridge"
+#define SYSFS_BRIDGE_PORT_VLANS "vlans"
 
 #define BRCTL_VERSION 1
 
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 13b36bd..b07a743 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -234,6 +234,71 @@ const struct sysfs_ops brport_sysfs_ops = {
 };
 
 /*
+ * Export the vlan table for a given port as a binary file.
+ * The entire bitmap is exported.
+ *
+ * Returns the number of bytes read.
+ */
+static ssize_t brport_vlans_read(struct file *filp, struct kobject *kobj,
+				struct bin_attribute *bin_attr,
+				char *buf, loff_t off, size_t count)
+{
+	struct net_bridge_port *p = to_brport(kobj);
+	unsigned long *map = rcu_dereference(p->vlan_map);
+	ssize_t map_len;
+
+	/* Just write the map back to userspace.  brctl will interpret
+	 * it correctly.
+	 */
+	map_len = BITS_TO_LONGS(br_vid(VLAN_N_VID));
+	memcpy(buf, map, map_len);
+	return map_len;
+}
+
+/* Set a vlan id specified in @buf into the vlan map of the port.  The vlan id
+ * is specified as an unsinged short.
+ */
+static ssize_t brport_vlans_write(struct file *filp, struct kobject *kobj,
+				struct bin_attribute *bin_attr,
+				char *buf, loff_t off, size_t count)
+{
+	struct net_bridge_port *p = to_brport(kobj);
+	unsigned short val;
+	int rc = 0;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (count < sizeof(unsigned short))
+		return -EINVAL;
+
+	val = *(unsigned short *)buf;
+
+	if (val > VLAN_N_VID)
+		return -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (p->dev && p->br) {
+		rc = br_set_port_vlan(p, val);
+
+		if (rc == 0)
+			rc = count;
+	}
+
+	rtnl_unlock();
+	return rc;
+}
+
+static struct bin_attribute port_vlans = {
+	.attr = { .name = SYSFS_BRIDGE_PORT_VLANS,
+		  .mode = S_IRUGO | S_IWUSR, },
+	.read = brport_vlans_read,
+	.write = brport_vlans_write,
+};
+
+/*
  * Add sysfs entries to ethernet device added to a bridge.
  * Creates a brport subdirectory with bridge attributes.
  * Puts symlink in bridge's brif subdirectory
@@ -255,6 +320,11 @@ int br_sysfs_addif(struct net_bridge_port *p)
 			return err;
 	}
 
+	err = sysfs_create_bin_file(&p->kobj, &port_vlans);
+	if (err) {
+		return err;
+	}
+
 	strlcpy(p->sysfs_name, p->dev->name, IFNAMSIZ);
 	return sysfs_create_link(br->ifobj, &p->kobj, p->sysfs_name);
 }
-- 
1.7.7.6
