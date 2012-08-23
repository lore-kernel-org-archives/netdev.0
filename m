From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH bridge 5/5] bridge: Add sysfs interface to display VLANS
Date: Thu, 23 Aug 2012 15:29:55 -0400
Message-ID: <1345750195-31598-6-git-send-email-vyasevic@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9655 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934223Ab2HWTaB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 15:30:01 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7NJU1d0023146
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 15:30:01 -0400
In-Reply-To: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a binary sysfs file that will dump out vlans currently configured on the
port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/if_bridge.h |    1 +
 net/bridge/br_if.c        |   34 ++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h   |    2 ++
 net/bridge/br_sysfs_if.c  |   28 ++++++++++++++++++++++++++++
 4 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index ab750dd..d0f869b 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -20,6 +20,7 @@
 #define SYSFS_BRIDGE_PORT_SUBDIR "brif"
 #define SYSFS_BRIDGE_PORT_ATTR	"brport"
 #define SYSFS_BRIDGE_PORT_LINK	"bridge"
+#define SYSFS_BRIDGE_PORT_VLANS "vlans"
 
 #define BRCTL_VERSION 1
 
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 90c1038..3963748 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -510,6 +510,40 @@ int br_del_port_vlan(struct net_bridge_port *p, unsigned long vlan)
 	return 0;
 }
 
+size_t br_port_fill_vlans(struct net_bridge_port *p, char* buf,
+			unsigned long max, unsigned long skip)
+{
+	unsigned long *map;
+	unsigned short *vid = (unsigned short *)buf;
+	unsigned short i;
+	int num = 0;
+
+	if (skip > (VLAN_N_VID+1))
+		return -EINVAL;
+
+	memset(buf, 0, max * sizeof(unsigned short));
+
+	rcu_read_lock();
+	map = rcu_dereference(p->vlan_map);
+	if (!map)
+		goto out;
+
+	for (i = skip + 1; i < VLAN_N_VID + 1; i++) {
+		if (test_bit(i, map)) {
+			if (num > max)
+				goto out;
+
+			*vid = i-1;
+			vid++;
+			num++;
+		}
+	}
+out:
+	rcu_read_unlock();
+
+	return num*sizeof(unsigned short);
+}
+
 void __net_exit br_net_exit(struct net *net)
 {
 	struct net_device *dev;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 5639c1c..cf95cd7 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -404,6 +404,8 @@ extern netdev_features_t br_features_recompute(struct net_bridge *br,
 	netdev_features_t features);
 extern int br_set_port_vlan(struct net_bridge_port *p, unsigned long vid);
 extern int br_del_port_vlan(struct net_bridge_port *p, unsigned long vid);
+extern size_t br_port_fill_vlans(struct net_bridge_port *p, char *buf,
+				unsigned long max, unsigned long skip);
 
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 13b36bd..a81e2ef 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -234,6 +234,29 @@ const struct sysfs_ops brport_sysfs_ops = {
 };
 
 /*
+ * Export the vlan table for a given port as a binary file.
+ * The records are unsgined shorts.
+ *
+ * Returns the number of bytes read.
+ */
+static ssize_t brport_vlans_read(struct file *filp, struct kobject *kobj,
+				struct bin_attribute *bin_attr,
+				char *buf, loff_t off, size_t count)
+{
+	struct net_bridge_port *p = to_brport(kobj);
+
+	return br_port_fill_vlans(p, buf,
+				count/sizeof(unsigned short),
+				off/sizeof(unsigned short));
+}
+
+static struct bin_attribute port_vlans = {
+	.attr = { .name = SYSFS_BRIDGE_PORT_VLANS,
+		  .mode = S_IRUGO, },
+	.read = brport_vlans_read,
+};
+
+/*
  * Add sysfs entries to ethernet device added to a bridge.
  * Creates a brport subdirectory with bridge attributes.
  * Puts symlink in bridge's brif subdirectory
@@ -255,6 +278,11 @@ int br_sysfs_addif(struct net_bridge_port *p)
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
