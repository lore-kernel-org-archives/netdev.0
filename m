From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v4 net-next 1/3] bridge: Add a default_pvid sysfs attribute
Date: Fri,  3 Oct 2014 11:29:16 -0400
Message-ID: <1412350158-19061-2-git-send-email-vyasevic@redhat.com>
References: <1412350158-19061-1-git-send-email-vyasevic@redhat.com>
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	toshiaki.makita1@gmail.com, cwang@twopensource.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:56343 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301AbaJCP3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 11:29:32 -0400
Received: by mail-qc0-f177.google.com with SMTP id c9so1161407qcz.36
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 08:29:32 -0700 (PDT)
In-Reply-To: <1412350158-19061-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the user to set and retrieve default_pvid
value.  A new value can only be stored when vlan filtering
is disabled.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_private.h  |  2 ++
 net/bridge/br_sysfs_br.c | 17 +++++++++++++++++
 net/bridge/br_vlan.c     | 29 +++++++++++++++++++++++++++++
 3 files changed, 48 insertions(+)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index fe7463c..5a347eb 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -299,6 +299,7 @@ struct net_bridge
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	u8				vlan_enabled;
 	__be16				vlan_proto;
+	u16				default_pvid;
 	struct net_port_vlans __rcu	*vlan_info;
 #endif
 };
@@ -605,6 +606,7 @@ void br_recalculate_fwd_mask(struct net_bridge *br);
 int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val);
 int br_vlan_set_proto(struct net_bridge *br, unsigned long val);
 void br_vlan_init(struct net_bridge *br);
+int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index cb431c6..4c97fc5 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -725,6 +725,22 @@ static ssize_t vlan_protocol_store(struct device *d,
 	return store_bridge_parm(d, buf, len, br_vlan_set_proto);
 }
 static DEVICE_ATTR_RW(vlan_protocol);
+
+static ssize_t default_pvid_show(struct device *d,
+				 struct device_attribute *attr,
+				 char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%d\n", br->default_pvid);
+}
+
+static ssize_t default_pvid_store(struct device *d,
+				  struct device_attribute *attr,
+				  const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, br_vlan_set_default_pvid);
+}
+static DEVICE_ATTR_RW(default_pvid);
 #endif
 
 static struct attribute *bridge_attrs[] = {
@@ -771,6 +787,7 @@ static struct attribute *bridge_attrs[] = {
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	&dev_attr_vlan_filtering.attr,
 	&dev_attr_vlan_protocol.attr,
+	&dev_attr_default_pvid.attr,
 #endif
 	NULL
 };
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 3ba57fc..dfa7c9a 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -499,9 +499,38 @@ err_filt:
 	goto unlock;
 }
 
+int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val)
+{
+	u16 pvid = val;
+	int err = 0;
+
+	if (!val || val >= VLAN_VID_MASK)
+		return -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (pvid == br->default_pvid)
+		goto unlock;
+
+	/* Only allow default pvid change when filtering is disabled */
+	if (br->vlan_enabled) {
+		pr_info_once("Please disable vlan filtering to change default_pvid\n");
+		err = -EPERM;
+		goto unlock;
+	}
+
+	br->default_pvid = pvid;
+
+unlock:
+	rtnl_unlock();
+	return err;
+}
+
 void br_vlan_init(struct net_bridge *br)
 {
 	br->vlan_proto = htons(ETH_P_8021Q);
+	br->default_pvid = 1;
 }
 
 /* Must be protected by RTNL.
-- 
1.9.3
