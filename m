From: Henrik Austad <henrik@austad.us>
Subject: [very-RFC 5/8] Add TSN machinery to drive the traffic from a shim over the network
Date: Sun, 12 Jun 2016 01:01:33 +0200
Message-ID: <1465686096-22156-6-git-send-email-henrik@austad.us>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
Cc: linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
	netdev@vger.kernel.org, henrk@austad.us,
	Henrik Austad <haustad@cisco.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465686096-22156-1-git-send-email-henrik@austad.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Henrik Austad <haustad@cisco.com>

In short summary:

* tsn_core.c is the main driver of tsn, all new links go through
  here and all data to/form the shims are handled here
  core also manages the shim-interface.

* tsn_configfs.c is the API to userspace. TSN is driven from userspace
  and a link is created, configured, enabled, disabled and removed
  purely from userspace. All attributes requried must be determined by
  userspace, preferrably via IEEE 1722.1 (discovery and enumeration).

* tsn_header.c small part that handles the actual header of the frames
  we send. Kept out of core for cleanliness.

* tsn_net.c handles operations towards the networking layer.

The current driver is under development. This means that from the moment it
is enabled with a shim, it will send traffic, either 0-traffic (frames of
reserved length but with payload 0) or actual traffic. This will change
once the driver stabilizes.

For more detail, see Documentation/networking/tsn/

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Henrik Austad <haustad@cisco.com>
---
 net/Makefile           |   1 +
 net/tsn/Makefile       |   6 +
 net/tsn/tsn_configfs.c | 623 +++++++++++++++++++++++++++++++
 net/tsn/tsn_core.c     | 975 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/tsn/tsn_header.c   | 203 ++++++++++
 net/tsn/tsn_internal.h | 383 +++++++++++++++++++
 net/tsn/tsn_net.c      | 403 ++++++++++++++++++++
 7 files changed, 2594 insertions(+)
 create mode 100644 net/tsn/Makefile
 create mode 100644 net/tsn/tsn_configfs.c
 create mode 100644 net/tsn/tsn_core.c
 create mode 100644 net/tsn/tsn_header.c
 create mode 100644 net/tsn/tsn_internal.h
 create mode 100644 net/tsn/tsn_net.c

diff --git a/net/Makefile b/net/Makefile
index bdd1455..c15482e 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -79,3 +79,4 @@ ifneq ($(CONFIG_NET_L3_MASTER_DEV),)
 obj-y				+= l3mdev/
 endif
 obj-$(CONFIG_QRTR)		+= qrtr/
+obj-$(CONFIG_TSN)		+= tsn/
diff --git a/net/tsn/Makefile b/net/tsn/Makefile
new file mode 100644
index 0000000..0d87687
--- /dev/null
+++ b/net/tsn/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Linux TSN subsystem
+#
+
+obj-$(CONFIG_TSN) += tsn.o
+tsn-objs :=tsn_core.o tsn_configfs.o tsn_net.o tsn_header.o
diff --git a/net/tsn/tsn_configfs.c b/net/tsn/tsn_configfs.c
new file mode 100644
index 0000000..f3d0986
--- /dev/null
+++ b/net/tsn/tsn_configfs.c
@@ -0,0 +1,623 @@
+/*
+ *   ConfigFS interface to TSN
+ *   Copyright (C) 2015- Henrik Austad <haustad@cisco.com>
+ *
+ *   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; either version 2 of the License, or
+ *   (at your option) any later version.
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ */
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/configfs.h>
+#include <linux/netdevice.h>
+#include <linux/rtmutex.h>
+#include <linux/tsn.h>
+#include "tsn_internal.h"
+
+static inline struct tsn_link *to_tsn_link(struct config_item *item)
+{
+	/* this line causes checkpatch to WARN. making checkpatch happy,
+	 * makes code messy..
+	 */
+	return item ? container_of(to_config_group(item), struct tsn_link, group) : NULL;
+}
+
+static inline struct tsn_nic *to_tsn_nic(struct config_group *group)
+{
+	return group ? container_of(group, struct tsn_nic, group) : NULL;
+}
+
+/* -----------------------------------------------
+ * Tier2 attributes
+ *
+ * The content of the links userspace can see/modify
+ * -----------------------------------------------
+*/
+static ssize_t _tsn_max_payload_size_show(struct config_item *item,
+					  char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%u\n", (u32)link->max_payload_size);
+}
+
+static ssize_t _tsn_max_payload_size_store(struct config_item *item,
+					   const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	u16 mpl_size = 0;
+	int ret = 0;
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change Payload size on on enabled link\n");
+		return -EINVAL;
+	}
+	ret = kstrtou16(page, 0, &mpl_size);
+	if (ret)
+		return ret;
+
+	/* 802.1BA-2011 6.4 payload must be <1500 octets (excluding
+	 * headers, tags etc) However, this is not directly mappable to
+	 * how some hw handles things, so to be conservative, we
+	 * restrict it down to [26..1485]
+	 *
+	 * This is also the _payload_ size, which does not include the
+	 * AVTPDU header. This is an upper limit to how much raw data
+	 * the shim can transport in each frame.
+	 */
+	if (!tsnh_payload_size_valid(mpl_size, link->shim_header_size)) {
+		pr_err("%s: payload (%u) should be [26..1480] octets.\n",
+		       __func__, (u32)mpl_size);
+		return -EINVAL;
+	}
+	link->max_payload_size = mpl_size;
+	return count;
+}
+
+static ssize_t _tsn_shim_header_size_show(struct config_item *item,
+					  char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%u\n", (u32)link->shim_header_size);
+}
+
+static ssize_t _tsn_shim_header_size_store(struct config_item *item,
+					   const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	u16 hdr_size = 0;
+	int ret = 0;
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change shim-header size on on enabled link\n");
+		return -EINVAL;
+	}
+
+	ret = kstrtou16(page, 0, &hdr_size);
+	if (ret)
+		return ret;
+
+	if (!tsnh_payload_size_valid(link->max_payload_size, hdr_size))
+		return -EINVAL;
+
+	link->shim_header_size = hdr_size;
+	return count;
+}
+
+static ssize_t _tsn_stream_id_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%llu\n", link->stream_id);
+}
+
+static ssize_t _tsn_stream_id_store(struct config_item *item,
+				    const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	u64 sid;
+	int ret = 0;
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change StreamID on on enabled link\n");
+		return -EINVAL;
+	}
+	ret = kstrtou64(page, 0, &sid);
+	if (ret)
+		return ret;
+
+	if (sid == link->stream_id)
+		return count;
+
+	if (tsn_find_by_stream_id(sid)) {
+		pr_warn("Cannot set sid to %llu - exists\n", sid);
+		return -EEXIST;
+	}
+	if (sid != link->stream_id)
+		tsn_readd_link(link, sid);
+	return count;
+}
+
+static ssize_t _tsn_buffer_size_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%zu\n", link->buffer_size);
+}
+
+static ssize_t _tsn_buffer_size_store(struct config_item *item,
+				      const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	u32 tmp;
+	int ret = 0;
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change Buffer Size on on enabled link\n");
+		return -EINVAL;
+	}
+
+	ret = kstrtou32(page, 0, &tmp);
+	/* only allow buffers !0 and smaller than 8MB for now */
+	if (!ret && tmp) {
+		pr_info("%s: update buffer_size from %zu to %u\n",
+			__func__, link->buffer_size, tmp);
+		link->buffer_size = (size_t)tmp;
+		return count;
+	}
+	return -EINVAL;
+}
+
+static ssize_t _tsn_class_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%s\n", (link->class_a ? "A" : "B"));
+}
+
+static ssize_t _tsn_class_store(struct config_item *item,
+				const char *page, size_t count)
+{
+	char class[2] = { 0 };
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change Class-type on on enabled link\n");
+		return -EINVAL;
+	}
+	if (strncpy(class, page, 1)) {
+		if (strcmp(class, "a") == 0 || strcmp(class, "A") == 0)
+			link->class_a = 1;
+		else if (strcmp(class, "b") == 0 || strcmp(class, "B") == 0)
+			link->class_a = 0;
+		return count;
+	}
+
+	pr_err("%s: Could not copy new class into buffer\n", __func__);
+	return -EINVAL;
+}
+
+static ssize_t _tsn_vlan_id_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%u\n", link->vlan_id);
+}
+
+static ssize_t _tsn_vlan_id_store(struct config_item *item,
+				  const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	u16 vlan_id;
+	int ret = 0;
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change VLAN-ID on on enabled link\n");
+		return -EINVAL;
+	}
+	ret = kstrtou16(page, 0, &vlan_id);
+	if (ret)
+		return ret;
+	if (vlan_id > 0xfff)
+		return -EINVAL;
+	link->vlan_id = vlan_id & 0xfff;
+	return count;
+}
+
+static ssize_t _tsn_pcp_a_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "0x%x\n", link->pcp_a);
+}
+
+static ssize_t _tsn_pcp_a_store(struct config_item *item,
+				const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	int ret = 0;
+	u8 pcp;
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change PCP-A on enabled link.\n");
+		return -EINVAL;
+	}
+	ret = kstrtou8(page, 0, &pcp);
+	if (ret)
+		return ret;
+	if (pcp > 0x7)
+		return -EINVAL;
+	link->pcp_a = pcp & 0x7;
+	return count;
+}
+
+static ssize_t _tsn_pcp_b_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "0x%x\n", link->pcp_b);
+}
+
+static ssize_t _tsn_pcp_b_store(struct config_item *item,
+				const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	int ret = 0;
+	u8 pcp;
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change PCP-B on enabled link.\n");
+		return -EINVAL;
+	}
+	ret = kstrtou8(page, 0, &pcp);
+	if (ret)
+		return ret;
+	if (pcp > 0x7)
+		return -EINVAL;
+	link->pcp_b = pcp & 0x7;
+	return count;
+}
+
+static ssize_t _tsn_end_station_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%s\n",
+		      (link->estype_talker ? "Talker" : "Listener"));
+}
+
+static ssize_t _tsn_end_station_store(struct config_item *item,
+				      const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	char estype[9] = {0};
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change End-station type on enabled link.\n");
+		return -EINVAL;
+	}
+	if (strncpy(estype, page, 8)) {
+		if (strncmp(estype, "Talker", 6) == 0 ||
+		    strncmp(estype, "talker", 6) == 0) {
+			link->estype_talker = 1;
+			return count;
+		} else if (strncmp(estype, "Listener", 8) == 0 ||
+			   strncmp(estype, "listener", 8) == 0) {
+			link->estype_talker = 0;
+			return count;
+		}
+	}
+	return -EINVAL;
+}
+
+static ssize_t _tsn_enabled_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%s\n", tsn_shim_get_active(link));
+}
+
+static ssize_t _tsn_enabled_store(struct config_item *item,
+				  const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	char driver_type[SHIM_NAME_SIZE] = { 0 };
+	struct tsn_shim_ops *shim_ops;
+	size_t len;
+	int ret = 0;
+
+	if (!link)
+		return -EINVAL;
+
+	strncpy(driver_type, page, SHIM_NAME_SIZE - 1);
+	len = strlen(driver_type);
+	while (len-- > 0) {
+		if (driver_type[len] == '\n')
+			driver_type[len] = 0x00;
+	}
+	if (tsn_link_is_on(link)) {
+		if (strncmp(driver_type, "off", 3) == 0) {
+			tsn_teardown_link(link);
+		} else {
+			pr_err("Unknown value (%s), ignoring\n", driver_type);
+			return -EINVAL;
+		}
+	} else {
+		shim_ops = tsn_shim_find_by_name(driver_type);
+
+		if (!shim_ops) {
+			pr_info("%s: could not enable desired shim, %s is not available\n",
+				__func__, driver_type);
+			return -EINVAL;
+		}
+
+		ret = tsn_prepare_link(link, shim_ops);
+		if (ret != 0) {
+			pr_err("%s: Trouble perparing link, somethign went wrong - %d\n",
+			       __func__, ret);
+			return ret;
+		}
+	}
+	return count;
+}
+
+static ssize_t _tsn_remote_mac_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%pM\n", link->remote_mac);
+}
+
+static ssize_t _tsn_remote_mac_store(struct config_item *item,
+				     const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	unsigned char mac[6] = {0};
+	int ret = 0;
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change Remote MAC on enabled link.\n");
+		return -EINVAL;
+	}
+	ret = sscanf(page, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+		     &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]);
+	if (ret > 0) {
+		pr_info("Got MAC, copying to storage\n");
+		memcpy(link->remote_mac, mac, 6);
+		return count;
+	}
+	return -EINVAL;
+}
+
+static ssize_t _tsn_local_mac_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%pMq\n", link->nic->dev->perm_addr);
+}
+
+CONFIGFS_ATTR(_tsn_, max_payload_size);
+CONFIGFS_ATTR(_tsn_, shim_header_size);
+CONFIGFS_ATTR(_tsn_, stream_id);
+CONFIGFS_ATTR(_tsn_, buffer_size);
+CONFIGFS_ATTR(_tsn_, class);
+CONFIGFS_ATTR(_tsn_, vlan_id);
+CONFIGFS_ATTR(_tsn_, pcp_a);
+CONFIGFS_ATTR(_tsn_, pcp_b);
+CONFIGFS_ATTR(_tsn_, end_station);
+CONFIGFS_ATTR(_tsn_, enabled);
+CONFIGFS_ATTR(_tsn_, remote_mac);
+CONFIGFS_ATTR_RO(_tsn_, local_mac);
+static struct configfs_attribute *tsn_tier2_attrs[] = {
+	&_tsn_attr_max_payload_size,
+	&_tsn_attr_shim_header_size,
+	&_tsn_attr_stream_id,
+	&_tsn_attr_buffer_size,
+	&_tsn_attr_class,
+	&_tsn_attr_vlan_id,
+	&_tsn_attr_pcp_a,
+	&_tsn_attr_pcp_b,
+	&_tsn_attr_end_station,
+	&_tsn_attr_enabled,
+	&_tsn_attr_remote_mac,
+	&_tsn_attr_local_mac,
+	NULL,
+};
+
+static struct config_item_type group_tsn_tier2_type = {
+	.ct_owner     = THIS_MODULE,
+	.ct_attrs     = tsn_tier2_attrs,
+	.ct_group_ops = NULL,
+};
+
+/* -----------------------------------------------
+ * Tier1
+ *
+ * The only interesting info at this level are the available links
+ * belonging to this nic. This will be the subdirectories. Apart from
+ * making/removing tier-2 folders, nothing else is required here.
+ */
+static struct config_group *group_tsn_1_make_group(struct config_group *group,
+						   const char *name)
+{
+	struct tsn_nic *nic = to_tsn_nic(group);
+	struct tsn_link *link = tsn_create_and_add_link(nic);
+
+	if (!nic || !link)
+		return ERR_PTR(-ENOMEM);
+
+	config_group_init_type_name(&link->group, name, &group_tsn_tier2_type);
+
+	return &link->group;
+}
+
+static void group_tsn_1_drop_group(struct config_group *group,
+				   struct config_item *item)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	struct tsn_nic *nic = to_tsn_nic(group);
+
+	if (link) {
+		tsn_teardown_link(link);
+		tsn_remove_link(link);
+	}
+	pr_info("Dropping %s from NIC: %s\n", item->ci_name, nic->name);
+}
+
+static struct configfs_attribute *tsn_tier1_attrs[] = {
+	NULL,
+};
+
+static struct configfs_group_operations group_tsn_1_group_ops = {
+	.make_group	= group_tsn_1_make_group,
+	.drop_item      = group_tsn_1_drop_group,
+};
+
+static struct config_item_type group_tsn_tier1_type = {
+	.ct_group_ops	= &group_tsn_1_group_ops,
+	.ct_attrs	= tsn_tier1_attrs,
+	.ct_owner	= THIS_MODULE,
+};
+
+/* -----------------------------------------------
+ * Tier0
+ *
+ * Top level. This will expose all the TSN-capable NICs as well as
+ * currently active StreamIDs and registered shims. 'Global' info goes
+ * here.
+ */
+static ssize_t _tsn_used_sids_show(struct config_item *item, char *page)
+{
+	return tsn_get_stream_ids(page, PAGE_SIZE);
+}
+
+static ssize_t _tsn_available_shims_show(struct config_item *item, char *page)
+{
+	return tsn_shim_export_probe_triggers(page);
+}
+
+static struct configfs_attribute tsn_used_sids = {
+	.ca_owner = THIS_MODULE,
+	.ca_name  = "stream_ids",
+	.ca_mode  = S_IRUGO,
+	.show     = _tsn_used_sids_show,
+};
+
+static struct configfs_attribute available_shims = {
+	.ca_owner = THIS_MODULE,
+	.ca_name  = "available_shims",
+	.ca_mode  = S_IRUGO,
+	.show     = _tsn_available_shims_show,
+};
+
+static struct configfs_attribute *group_tsn_attrs[] = {
+	&tsn_used_sids,
+	&available_shims,
+	NULL,
+};
+
+static struct config_item_type group_tsn_tier0_type = {
+	.ct_group_ops	= NULL,
+	.ct_attrs	= group_tsn_attrs,
+	.ct_owner	= THIS_MODULE,
+};
+
+int tsn_configfs_init(struct tsn_list *tlist)
+{
+	int ret = 0;
+	struct tsn_nic *next;
+	struct configfs_subsystem *subsys;
+
+	if (!tlist || !tlist->num_avail)
+		return -EINVAL;
+
+	/* Tier-0 */
+	subsys = &tlist->tsn_subsys;
+	strncpy(subsys->su_group.cg_item.ci_namebuf, "tsn",
+		CONFIGFS_ITEM_NAME_LEN);
+	subsys->su_group.cg_item.ci_type = &group_tsn_tier0_type;
+
+	config_group_init(&subsys->su_group);
+	mutex_init(&subsys->su_mutex);
+
+	/* Tier-1
+	 * (tsn-capable NICs), automatic subgroups
+	 */
+	list_for_each_entry(next, &tlist->head, list) {
+		config_group_init_type_name(&next->group, next->name,
+					    &group_tsn_tier1_type);
+		configfs_add_default_group(&next->group, &subsys->su_group);
+	}
+
+	/* This is the final step, once done, system is live, make sure
+	 * init has completed properly
+	 */
+	ret = configfs_register_subsystem(subsys);
+	if (ret) {
+		pr_err("Trouble registering TSN ConfigFS subsystem\n");
+		return ret;
+	}
+
+	pr_warn("configfs_init_module() OK\n");
+	return 0;
+}
+
+void tsn_configfs_exit(struct tsn_list *tlist)
+{
+	if (!tlist)
+		return;
+	configfs_unregister_subsystem(&tlist->tsn_subsys);
+	pr_warn("configfs_exit_module()\n");
+}
diff --git a/net/tsn/tsn_core.c b/net/tsn/tsn_core.c
new file mode 100644
index 0000000..51f1d13
--- /dev/null
+++ b/net/tsn/tsn_core.c
@@ -0,0 +1,975 @@
+/*
+ *   TSN Core main part of TSN driver
+ *
+ *   Copyright (C) 2015- Henrik Austad <haustad@cisco.com>
+ *
+ *   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; either version 2 of the License, or
+ *   (at your option) any later version.
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ */
+
+#include <linux/pci.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/random.h>
+#include <linux/rtmutex.h>
+#include <linux/hashtable.h>
+#include <linux/netdevice.h>
+#include <linux/net.h>
+#include <linux/dma-mapping.h>
+#include <net/sock.h>
+#include <net/net_namespace.h>
+#include <linux/hrtimer.h>
+#include <linux/configfs.h>
+
+#define CREATE_TRACE_POINTS
+#include <trace/events/tsn.h>
+#include "tsn_internal.h"
+
+static struct tsn_list tlist;
+static int in_debug;
+static int on_cpu = -1;
+
+#define TLINK_HASH_BITS 8
+DEFINE_HASHTABLE(tlinks, TLINK_HASH_BITS);
+
+static LIST_HEAD(tsn_shim_ops);
+
+/* Called with link->lock held */
+static inline size_t _get_low_water(struct tsn_link *link)
+{
+	/* use max_payload_size and give a rough estimate of how many
+	 * bytes that would be for low_water_ms
+	 */
+	int low_water_ms = 20;
+	int numframes = low_water_ms * 8;
+
+	if (link->class_a)
+		numframes *= 2;
+	return link->max_payload_size * numframes;
+}
+
+/* Called with link->lock held */
+static inline size_t _get_high_water(struct tsn_link *link)
+{
+	size_t low_water =  _get_low_water(link);
+
+	return max(link->used_buffer_size - low_water, low_water);
+}
+
+/**
+ * _tsn_set_buffer - register a memory region to use as the buffer
+ *
+ * This is used when we are operating in !external_buffer mode.
+ *
+ * TSN expects a ring-buffer and will update pointers to keep track of
+ * where we are. When the buffer is refilled, head and tail will be
+ * updated accordingly.
+ *
+ * @param link		the link that should hold the buffer
+ * @param buffer	the new buffer
+ * @param bufsize	size of new buffer.
+ *
+ * @returns 0 on success, negative on error
+ *
+ * Must be called with tsn_lock() held.
+ */
+static int _tsn_set_buffer(struct tsn_link *link, void *buffer, size_t bufsize)
+{
+	if (link->buffer) {
+		pr_err("%s: Cannot add buffer, buffer already registred\n",
+		       __func__);
+		return -EINVAL;
+	}
+
+	trace_tsn_set_buffer(link, bufsize);
+	link->buffer = buffer;
+	link->head = link->buffer;
+	link->tail = link->buffer;
+	link->end = link->buffer + bufsize;
+	link->buffer_size = bufsize;
+	link->used_buffer_size = bufsize;
+	return 0;
+}
+
+/**
+ * _tsn_free_buffer - remove internal buffers
+ *
+ * This is the buffer where we store data before shipping it to TSN, or
+ * where incoming data is staged.
+ *
+ * @param link   - the link that holds the buffer
+ *
+ * Must be called with tsn_lock() held.
+ */
+static void _tsn_free_buffer(struct tsn_link *link)
+{
+	if (!link)
+		return;
+	trace_tsn_free_buffer(link);
+	kfree(link->buffer);
+	link->buffer = NULL;
+	link->head   = NULL;
+	link->tail   = NULL;
+	link->end    = NULL;
+}
+
+int tsn_set_buffer_size(struct tsn_link *link, size_t bsize)
+{
+	if (!link)
+		return -EINVAL;
+
+	if (bsize > link->buffer_size) {
+		pr_err("%s: requested buffer (%zd) larger than allocated memory (%zd)\n",
+		       __func__, bsize, link->buffer_size);
+		return -ENOMEM;
+	}
+
+	tsn_lock(link);
+	link->used_buffer_size = bsize;
+	link->tail = link->buffer;
+	link->head = link->buffer;
+	link->end = link->buffer + link->used_buffer_size;
+	link->low_water_mark = _get_low_water(link);
+	link->high_water_mark = _get_high_water(link);
+	tsn_unlock(link);
+
+	pr_info("Set buffer_size, size: %zd, lowwater: %zd, highwater: %zd\n",
+		link->used_buffer_size, link->low_water_mark,
+		link->high_water_mark);
+	return 0;
+}
+EXPORT_SYMBOL(tsn_set_buffer_size);
+
+int tsn_clear_buffer_size(struct tsn_link *link)
+{
+	if (!link)
+		return -EINVAL;
+
+	tsn_lock(link);
+	link->tail = link->buffer;
+	link->head = link->buffer;
+	link->end = link->buffer + link->buffer_size;
+	memset(link->buffer, 0,  link->used_buffer_size);
+	link->used_buffer_size = link->buffer_size;
+	link->low_water_mark = _get_low_water(link);
+	link->high_water_mark = _get_high_water(link);
+	tsn_unlock(link);
+	return 0;
+}
+EXPORT_SYMBOL(tsn_clear_buffer_size);
+
+void *tsn_set_external_buffer(struct tsn_link *link, void *buffer,
+			      size_t buffer_size)
+{
+	void *old_buffer;
+
+	if (!link)
+		return NULL;
+	if (buffer_size < link->max_payload_size)
+		pr_warn("%s: buffer_size (%zu) < max_payload_size (%u)\n",
+			__func__, buffer_size, link->max_payload_size);
+
+	tsn_lock(link);
+	if (!link->external_buffer && link->buffer)
+		_tsn_free_buffer(link);
+
+	old_buffer = link->buffer;
+	link->external_buffer = 1;
+	link->buffer_size = buffer_size;
+	link->used_buffer_size = buffer_size;
+	link->buffer = buffer;
+	link->head = link->buffer;
+	link->tail = link->buffer;
+	link->end = link->buffer + link->used_buffer_size;
+	tsn_unlock(link);
+	return old_buffer;
+}
+EXPORT_SYMBOL(tsn_set_external_buffer);
+
+/* Caller must hold link->lock!
+ *
+ * Write data *into* buffer, either from net or from shim due to a
+ * closing underflow event.
+ */
+static void __tsn_buffer_write(struct tsn_link *link, void *src, size_t bytes)
+{
+	int rem = 0;
+
+	/* No Need To Wrap, if overflow we will overwrite without
+	 * warning.
+	 */
+	trace_tsn_buffer_write(link, bytes);
+	if (link->head + bytes < link->end) {
+		memcpy(link->head, src, bytes);
+		link->head += bytes;
+	} else {
+		rem = link->end - link->head;
+		memcpy(link->head, src, rem);
+		memcpy(link->buffer, (src + rem), bytes - rem);
+		link->head = link->buffer + (bytes - rem);
+	}
+}
+
+int tsn_buffer_write(struct tsn_link *link, void *src, size_t bytes)
+{
+	if (!link)
+		return -EINVAL;
+
+	/* We should not do anything if link has gone inactive */
+	if (!tsn_link_is_on(link))
+		return 0;
+
+	/* Copied a batch of data and if link is disabled, it is now
+	 * safe to enable it. Otherwise we will continue to send
+	 * null-frames to remote.
+	 */
+	if (!tsn_lb(link))
+		tsn_lb_enable(link);
+
+	__tsn_buffer_write(link, src, bytes);
+
+	return bytes;
+}
+EXPORT_SYMBOL(tsn_buffer_write);
+
+/**
+ * tsn_buffer_write_net - take data from a skbuff and write it into buffer
+ *
+ * When we receive a frame, we grab data from the skbuff and add it to
+ * link->buffer.
+ *
+ * Note that this routine does NOT CARE about channels, samplesize etc,
+ * it is a _pure_ copy that handles ringbuffer wraps etc.
+ *
+ * This function have side-effects as it will update internal tsn_link
+ * values and trigger refill() should the buffer run low.
+ *
+ * NOTE: called from tsn_rx_handler() -> _tsnh_handle_du(), with
+ *	 tsn_lock held.
+ *
+ * @param link current link that holds the buffer
+ * @param buffer the buffer to copy from
+ * @param bytes number of bytes
+ * @returns Bytes copied into link->buffer, negative value upon error.
+ */
+int tsn_buffer_write_net(struct tsn_link *link, void *src, size_t bytes)
+{
+	size_t used;
+
+	if (!link)
+		return -EINVAL;
+
+	/* Driver has not been enabled yet, i.e. it is in state 'off' and we
+	 * have no way of knowing the state of the buffers.
+	 * Silently drop the data, pretend write went ok
+	 */
+	trace_tsn_buffer_write_net(link, bytes);
+	if (!tsn_lb(link))
+		return bytes;
+
+	__tsn_buffer_write(link, src, bytes);
+
+	/* If we stored more data than high_water, we need to drain
+	 *
+	 * In ALSA, this will trigger a snd_pcm_period_elapsed() for the
+	 * substream connected to this particular link.
+	 */
+	used = _tsn_buffer_used(link);
+	if (used > link->high_water_mark) {
+		trace_tsn_buffer_drain(link, used);
+		link->ops->buffer_drain(link);
+	}
+
+	return bytes;
+}
+
+/* caller must hold link->lock!
+ *
+ * Read data *from* buffer, either to net or to shim due to a
+ * closing overflow event.
+ *
+ * Function will *not* care if you read past head and into unchartered
+ * territory, caller must ascertain validity of bytes.
+ */
+static void __tsn_buffer_read(struct tsn_link *link, void *dst, size_t bytes)
+{
+	int rem = 0;
+
+	trace_tsn_buffer_read(link, bytes);
+	if ((link->tail + bytes) < link->end) {
+		memcpy(dst, link->tail, bytes);
+		link->tail += bytes;
+	} else {
+		rem = link->end - link->tail;
+		memcpy(dst, link->tail, rem);
+		memcpy(dst + rem, link->buffer, bytes - rem);
+		link->tail = link->buffer + bytes - rem;
+	}
+}
+
+/**
+ * tsn_buffer_read_net - read data from link->buffer and give to network layer
+ *
+ * When we send a frame, we grab data from the buffer and add it to the
+ * sk_buff->data, this is primarily done by the Tx-subsystem in tsn_net
+ * and is typically done in small chunks
+ *
+ * @param link current link that holds the buffer
+ * @param buffer the buffer to copy into, must be at least of size bytes
+ * @param bytes number of bytes.
+ *
+ * Note that this routine does NOT CARE about channels, samplesize etc,
+ * it is a _pure_ copy that handles ringbuffer wraps etc.
+ *
+ * This function have side-effects as it will update internal tsn_link
+ * values and trigger refill() should the buffer run low.
+ *
+ * NOTE: expects to be called with locks held
+ *
+ * @return Bytes copied into link->buffer, negative value upon error.
+ */
+int tsn_buffer_read_net(struct tsn_link *link, void *buffer, size_t bytes)
+{
+	size_t used;
+
+	if (!link)
+		return -EINVAL;
+
+	/* link is currently inactive, e.g. we send frames, but without
+	 * content
+	 *
+	 * This can be done before we ship data, or if we are muted
+	 * (without expressively stating that over 1722.1
+	 *
+	 * We do not need to grab any locks here as we won't touch the
+	 * link
+	 */
+	if (!tsn_lb(link)) {
+		memset(buffer, 0, bytes);
+		goto out;
+	}
+
+	/* sanity check of bytes to read
+	 * FIXME
+	 */
+
+	__tsn_buffer_read(link, buffer, bytes);
+
+	/* Trigger refill from client app */
+	used = _tsn_buffer_used(link);
+	if (used < link->low_water_mark) {
+		trace_tsn_refill(link, used);
+		link->ops->buffer_refill(link);
+	}
+out:
+	return bytes;
+}
+
+int tsn_buffer_read(struct tsn_link *link, void *buffer, size_t bytes)
+{
+	if (!link)
+		return -EINVAL;
+
+	/* We should not do anything if link has gone inactive */
+	if (!tsn_link_is_on(link))
+		return 0;
+
+	tsn_lock(link);
+	__tsn_buffer_read(link, buffer, bytes);
+	tsn_unlock(link);
+	return bytes;
+}
+EXPORT_SYMBOL(tsn_buffer_read);
+
+static int _tsn_send_batch(struct tsn_link *link)
+{
+	int ret = 0;
+	int num_frames = (link->class_a ? 8 : 4);
+	u64 ts_base_ns = ktime_to_ns(ktime_get()) + (link->class_a ? 2000000 : 50000000);
+	u64 ts_delta_ns = (link->class_a ? 125000 : 250000);
+
+	trace_tsn_send_batch(link, num_frames, ts_base_ns, ts_delta_ns);
+	ret = tsn_net_send_set(link, num_frames, ts_base_ns, ts_delta_ns);
+	if (ret < 0)
+		pr_err("%s: could not send frame - %d\n", __func__, ret);
+
+	return ret;
+}
+
+static int _tsn_hrtimer_callback(struct tsn_link *link)
+{
+	int ret = _tsn_send_batch(link);
+
+	if (ret) {
+		pr_err("%s: Error sending frames (%d), disabling link.\n",
+		       __func__, ret);
+		tsn_teardown_link(link);
+		return 0;
+	}
+	return 0;
+}
+
+static enum hrtimer_restart tsn_hrtimer_callback(struct hrtimer *hrt)
+{
+	struct tsn_list *list = container_of(hrt, struct tsn_list, tsn_timer);
+	struct tsn_link *link;
+	struct hlist_node *tmp;
+	int bkt = 0;
+
+	if (!tsn_core_running(list))
+		return HRTIMER_NORESTART;
+
+	hrtimer_forward_now(hrt, ns_to_ktime(list->period_ns));
+
+	hash_for_each_safe(tlinks, bkt, tmp, link, node) {
+		if (tsn_link_is_on(link) && link->estype_talker)
+			_tsn_hrtimer_callback(link);
+	}
+
+	return HRTIMER_RESTART;
+}
+
+static long tsn_hrtimer_init(void *arg)
+{
+	/* Run every 1ms, _tsn_send_batch will figure out how many
+	 * frames to send for active frames
+	 */
+	struct tsn_list *list = (struct tsn_list *)arg;
+
+	hrtimer_init(&list->tsn_timer, CLOCK_MONOTONIC,
+		     HRTIMER_MODE_REL | HRTIMER_MODE_PINNED);
+
+	list->tsn_timer.function = tsn_hrtimer_callback;
+	hrtimer_cancel(&list->tsn_timer);
+	atomic_set(&list->running, 1);
+
+	hrtimer_start(&list->tsn_timer, ns_to_ktime(list->period_ns),
+		      HRTIMER_MODE_REL);
+	return 0;
+}
+
+static void tsn_hrtimer_exit(struct tsn_list *list)
+{
+	atomic_set(&list->running, 0);
+	hrtimer_cancel(&list->tsn_timer);
+}
+
+/**
+ * tsn_prepare_link - prepare link for role as Talker/Receiver
+ *
+ * Iow; this will start shipping data through the network-layer.
+ *
+ * @link: the actual link
+ *
+ * Current status: each link will get a periodic hrtimer that interrupts
+ * and ships data every 1ms. This will change once we have proper driver
+ * for hw (i.e. i210 driver).
+ */
+int tsn_prepare_link(struct tsn_link *link, struct tsn_shim_ops *shim_ops)
+{
+	int ret = 0;
+	void *buffer;
+	u16 framesize;
+	struct net_device *netdev;
+
+	/* TODO: use separate buckets (lists/rbtrees/whatever) for
+	 * class_a and class_b talker streams. hrtimer-callback should
+	 * not iterate over all.
+	 */
+
+	if (!link || !shim_ops || !shim_ops->probe)
+		return -EINVAL;
+
+	pr_info("TSN: allocating buffer, %zd bytes\n", link->buffer_size);
+
+	tsn_lock(link);
+
+	/* configure will calculate idle_slope based on framesize
+	 * (header + payload)
+	 */
+	netdev = link->nic->dev;
+	if (netdev->netdev_ops->ndo_tsn_link_configure) {
+		framesize  = link->max_payload_size +
+			     link->shim_header_size + tsnh_len_all();
+		ret = netdev->netdev_ops->ndo_tsn_link_configure(netdev, link->class_a,
+								 framesize, link->vlan_id & 0xfff);
+		if (ret < 0)
+			pr_err("Could not configure link - %d\n", ret);
+	}
+
+	link->ops = shim_ops;
+	tsn_unlock(link);
+	ret = link->ops->probe(link);
+	if (ret != 0) {
+		pr_err("%s: Could not probe shim (%d), cannot create link\n",
+		       __func__, ret);
+		link->ops = NULL;
+		goto out;
+	}
+
+	tsn_lock(link);
+	if (!link->external_buffer) {
+		buffer = kmalloc(link->buffer_size, GFP_KERNEL);
+		if (!buffer) {
+			pr_err("%s: Could not allocate memory (%zu) for buffer\n",
+			       __func__, link->buffer_size);
+			link->ops = NULL;
+			ret = -ENOMEM;
+			goto unlock_out;
+		}
+
+		ret = _tsn_set_buffer(link, buffer, link->buffer_size);
+		if (ret != 0) {
+			pr_err("%s: Could not set buffer for TSN, got %d\n",
+			       __func__, ret);
+			goto unlock_out;
+		}
+	} else {
+		/* FIXME: not handled */
+		pr_info("TSN does not currently handle externally hosted buffers. This is on the TODO-list\n");
+		ret = -EINVAL;
+		goto unlock_out;
+	}
+
+	tsn_link_on(link);
+
+unlock_out:
+	tsn_unlock(link);
+out:
+	pr_info("%s: ret=%d\n", __func__, ret);
+	return ret;
+}
+
+int tsn_teardown_link(struct tsn_link *link)
+{
+	if (!link)
+		return -EINVAL;
+
+	tsn_lock(link);
+	tsn_lb_disable(link);
+	tsn_link_off(link);
+	tsn_unlock(link);
+
+	/* Need to call media_close() without (spin-)locks held.
+	 */
+	if (link->ops)
+		link->ops->media_close(link);
+
+	tsn_lock(link);
+	link->ops = NULL;
+	_tsn_free_buffer(link);
+	tsn_unlock(link);
+	pr_info("%s: disabling all parts of link\n", __func__);
+	return 0;
+}
+
+int tsn_shim_register_ops(struct tsn_shim_ops *shim_ops)
+{
+	if (!shim_ops)
+		return -EINVAL;
+
+	if (!shim_ops->buffer_refill || !shim_ops->buffer_drain ||
+	    !shim_ops->media_close || !shim_ops->copy_size ||
+	    !shim_ops->validate_header || !shim_ops->assemble_header ||
+	    !shim_ops->get_payload_data)
+		return -EINVAL;
+
+	INIT_LIST_HEAD(&shim_ops->head);
+	list_add_tail(&shim_ops->head, &tsn_shim_ops);
+	return 0;
+}
+EXPORT_SYMBOL(tsn_shim_register_ops);
+
+void tsn_shim_deregister_ops(struct tsn_shim_ops *shim_ops)
+{
+	struct tsn_link *link;
+	struct hlist_node *tmp;
+	int bkt;
+
+	hash_for_each_safe(tlinks, bkt, tmp, link, node) {
+		if (!link)
+			continue;
+		if (link->ops == shim_ops)
+			tsn_teardown_link(link);
+	}
+	list_del(&shim_ops->head);
+}
+EXPORT_SYMBOL(tsn_shim_deregister_ops);
+
+char *tsn_shim_get_active(struct tsn_link *link)
+{
+	if (!link || !link->ops)
+		return "off";
+	return link->ops->shim_name;
+}
+
+struct tsn_shim_ops *tsn_shim_find_by_name(const char *name)
+{
+	struct tsn_shim_ops *ops;
+
+	if (!name || list_empty(&tsn_shim_ops))
+		return NULL;
+
+	list_for_each_entry(ops, &tsn_shim_ops, head) {
+		if (strcmp(name, ops->shim_name) == 0)
+			return ops;
+	}
+	return NULL;
+}
+
+ssize_t tsn_shim_export_probe_triggers(char *page)
+{
+	struct tsn_shim_ops *ops;
+	ssize_t res = 0;
+
+	if (!page || list_empty(&tsn_shim_ops))
+		return 0;
+	list_for_each_entry(ops, &tsn_shim_ops, head) {
+		res += snprintf((page + res), PAGE_SIZE - res, "%s\n",
+				 ops->shim_name);
+	}
+	return res;
+}
+
+struct tsn_link *tsn_create_and_add_link(struct tsn_nic *nic)
+{
+	u64 sid = 0;
+	struct tsn_link *link = kzalloc(sizeof(*link), GFP_KERNEL);
+
+	if (!link)
+		return NULL;
+	if (!nic) {
+		kfree(link);
+		return NULL;
+	}
+
+	spin_lock_init(&link->lock);
+	tsn_lock(link);
+	tsn_link_off(link);
+	tsn_lb_disable(link);
+	do {
+		sid = prandom_u32();
+		sid |= prandom_u32() << 31;
+	} while (tsn_find_by_stream_id(sid));
+	link->stream_id = sid;
+
+	/* There's a slim chance that we actually hit on the first frame
+	 * of data, but if we do, remote seqnr is most likely 0. If this
+	 * is not up to par,, fix in rx_handler
+	 */
+	link->last_seqnr = 0xff;
+
+	/* class B audio 48kHz sampling, S16LE, 2ch and IEC61883-6 CIP
+	 * header
+	 */
+	link->max_payload_size = 48;
+	link->shim_header_size =  8;
+
+	/* Default VLAN ID is SR_PVID (2) unless otherwise supplied from
+	 * MSRP, PCP is default 3 for class A, 2 for Class B (See IEEE
+	 * 802.1Q-2011, table 6-6)
+	 */
+	link->vlan_id = 0x2;
+	link->pcp_a = 3;
+	link->pcp_b = 2;
+	link->class_a = 0;
+
+	link->buffer_size = 16536;
+	/* default: talker since listener isn't implemented yet. */
+	link->estype_talker = 1;
+
+	link->nic = nic;
+	tsn_unlock(link);
+
+	/* Add the newly created link to the hashmap of all active links.
+	 *
+	 * test if sid is present in hashmap already (barf on that)
+	 */
+
+	mutex_lock(&tlist.lock);
+	hash_add(tlinks, &link->node, link->stream_id);
+	mutex_unlock(&tlist.lock);
+	pr_info("%s: added link with stream_id: %llu\n",
+		__func__, link->stream_id);
+
+	return link;
+}
+
+ssize_t tsn_get_stream_ids(char *page, ssize_t len)
+{
+	struct tsn_link *link;
+	struct hlist_node *tmp;
+	char *buffer = page;
+	int bkt;
+
+	if (!page)
+		return 0;
+
+	if (hash_empty(tlinks))
+		return sprintf(buffer, "no links registered\n");
+
+	hash_for_each_safe(tlinks, bkt, tmp, link, node)
+		buffer += sprintf(buffer, "%llu\n", link->stream_id);
+
+	return (buffer - page);
+}
+
+struct tsn_link *tsn_find_by_stream_id(u64 sid)
+{
+	struct tsn_link *link;
+
+	if (hash_empty(tlinks))
+		return 0;
+
+	hash_for_each_possible(tlinks, link, node, sid) {
+		if (link->stream_id == sid)
+			return link;
+	}
+
+	return NULL;
+}
+
+void tsn_remove_link(struct tsn_link *link)
+{
+	if (!link)
+		return;
+	tsn_net_close(link);
+	mutex_lock(&tlist.lock);
+	hash_del(&link->node);
+	if (link->ops) {
+		link->ops->media_close(link);
+		link->ops = NULL;
+	}
+
+	mutex_unlock(&tlist.lock);
+}
+
+void tsn_readd_link(struct tsn_link *link, u64 newkey)
+{
+	if (!link)
+		return;
+	tsn_lock(link);
+	if (hash_hashed(&link->node)) {
+		pr_info("%s: updating link with stream_id %llu -> %llu\n",
+			__func__, link->stream_id, newkey);
+		tsn_remove_link(link);
+	}
+
+	link->stream_id = newkey;
+	tsn_unlock(link);
+
+	hash_add(tlinks, &link->node, link->stream_id);
+}
+
+static int _tsn_capable_nic(struct net_device *netdev, struct tsn_nic *nic)
+{
+	if (!nic || !netdev || !netdev->netdev_ops ||
+	    !netdev->netdev_ops->ndo_tsn_capable)
+		return -EINVAL;
+
+	if (netdev->netdev_ops->ndo_tsn_capable(netdev) > 0)
+		nic->capable = 1;
+
+	return 0;
+}
+
+/* Identify all TSN-capable NICs in the system
+ */
+static int tsn_nic_probe(void)
+{
+	struct net *net;
+	struct net_device *netdev;
+	struct tsn_nic *nic;
+
+	net = &init_net;
+	rcu_read_lock();
+	for_each_netdev_rcu(net, netdev) {
+		pr_info("Found %s, alias %s on irq %d\n",
+			netdev->name,
+			netdev->ifalias,
+			netdev->irq);
+		pr_info("MAC: %pM", netdev->dev_addr);
+		if (netdev->tx_queue_len)
+			pr_info("Tx queue length: %lu\n", netdev->tx_queue_len);
+		nic = kzalloc(sizeof(*nic), GFP_KERNEL);
+		if (!nic) {
+			pr_err("Could not allocate memory for tsn_nic!\n");
+			return -ENOMEM;
+		}
+		nic->dev = netdev;
+		nic->txq = netdev->num_tx_queues;
+		nic->name = netdev->name;
+		nic->tsn_list = &tlist;
+		nic->dma_size = 1048576;
+
+		_tsn_capable_nic(netdev, nic);
+
+		/* if not capable and we are not in debug-mode, drop nic
+		 * and continue
+		 */
+		if (!nic->capable && !in_debug) {
+			pr_info("Invalid capabilities for NIC (%s), dropping from TSN list\n",
+				netdev->name);
+			kfree(nic);
+			continue;
+		}
+
+		INIT_LIST_HEAD(&nic->list);
+		mutex_lock(&tlist.lock);
+		list_add_tail(&nic->list, &tlist.head);
+		tlist.num_avail++;
+		mutex_unlock(&tlist.lock);
+	}
+	rcu_read_unlock();
+
+	return 0;
+}
+
+static void tsn_free_nic_list(struct tsn_list *list)
+{
+	struct tsn_nic *tmp, *next;
+
+	mutex_lock(&list->lock);
+	list_for_each_entry_safe(tmp, next, &list->head, list) {
+		pr_info("Dropping %s from list\n", tmp->dev->name);
+		list_del(&tmp->list);
+		tmp->dev = NULL;
+		kfree(tmp);
+	}
+	mutex_unlock(&list->lock);
+}
+
+/* all active links are stored in hashmap 'tlinks'
+ */
+static void tsn_remove_all_links(void)
+{
+	int bkt;
+	struct tsn_link *link;
+	struct hlist_node *tmp;
+
+	hash_for_each_safe(tlinks, bkt, tmp, link, node) {
+		pr_info("%s removing a link\n", __func__);
+		if (!tsn_teardown_link(link))
+			tsn_remove_link(link);
+	}
+
+	pr_info("%s: all links have been removed\n", __func__);
+}
+
+static int __init tsn_init_module(void)
+{
+	int ret = 0;
+
+	INIT_LIST_HEAD(&tlist.head);
+	mutex_init(&tlist.lock);
+
+	atomic_set(&tlist.running, 0);
+	tlist.period_ns =  1000000;
+
+	/* Find all NICs, attach a rx-handler for sniffing out TSN
+	 * traffic on *all* of them.
+	 */
+	tlist.num_avail = 0;
+	ret = tsn_nic_probe();
+	if (ret < 0) {
+		pr_err("%s: somethign went awry whilst probing for NICs, aborting\n",
+		       __func__);
+		goto out;
+	}
+
+	if (!tlist.num_avail) {
+		pr_err("%s: No capable NIC found. Perhaps load with in_debug=1 ?\n",
+		       __func__);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* register Rx-callbacks for all (valid) NICs */
+	ret = tsn_net_add_rx(&tlist);
+	if (ret < 0) {
+		pr_err("%s: Could add Rx-handler, aborting\n", __func__);
+		goto error_rx_out;
+	}
+
+	/* init DMA regions etc */
+	ret = tsn_net_prepare_tx(&tlist);
+	if (ret < 0) {
+		pr_err("%s: could not prepare Tx, aborting\n", __func__);
+		goto error_tx_out;
+	}
+
+	/* init hashtable */
+	hash_init(tlinks);
+
+	/* init configfs */
+	ret = tsn_configfs_init(&tlist);
+	if (ret < 0) {
+		pr_err("%s: Could not initialize configfs properly (%d), aborting\n",
+		       __func__, ret);
+		goto error_cfs_out;
+	}
+
+	/* Test to see if on_cpu is available */
+	if (on_cpu >= 0) {
+		pr_info("%s: pinning timer on CPU %d\n", __func__, on_cpu);
+		ret = work_on_cpu(on_cpu, tsn_hrtimer_init, &tlist);
+		if (ret != 0) {
+			pr_err("%s: could not init hrtimer properly on CPU %d, aborting\n",
+			       __func__, on_cpu);
+			goto error_hrt_out;
+		}
+	} else {
+		ret = tsn_hrtimer_init(&tlist);
+		if (ret < 0) {
+			pr_err("%s: could not init hrtimer properly, aborting\n",
+			       __func__);
+			goto error_hrt_out;
+		}
+	}
+	pr_info("TSN subsystem init OK\n");
+	return 0;
+
+error_hrt_out:
+	tsn_remove_all_links();
+	tsn_configfs_exit(&tlist);
+error_cfs_out:
+	tsn_net_disable_tx(&tlist);
+error_tx_out:
+	tsn_net_remove_rx(&tlist);
+error_rx_out:
+	tsn_free_nic_list(&tlist);
+out:
+	return ret;
+}
+
+static void __exit tsn_exit_module(void)
+{
+	pr_warn("removing module TSN\n");
+	tsn_hrtimer_exit(&tlist);
+
+	tsn_remove_all_links();
+	tsn_configfs_exit(&tlist);
+
+	/* Unregister Rx-handlers if set */
+	tsn_net_remove_rx(&tlist);
+
+	tsn_net_disable_tx(&tlist);
+
+	tsn_free_nic_list(&tlist);
+
+	pr_warn("TSN exit\n");
+}
+module_param(in_debug, int, S_IRUGO);
+module_param(on_cpu, int, S_IRUGO);
+module_init(tsn_init_module);
+module_exit(tsn_exit_module);
+MODULE_AUTHOR("Henrik Austad");
+MODULE_LICENSE("GPL");
diff --git a/net/tsn/tsn_header.c b/net/tsn/tsn_header.c
new file mode 100644
index 0000000..a0d31c5
--- /dev/null
+++ b/net/tsn/tsn_header.c
@@ -0,0 +1,203 @@
+/*
+ *   Network header handling for TSN
+ *
+ *   Copyright (C) 2015- Henrik Austad <haustad@cisco.com>
+ *
+ *   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; either version 2 of the License, or
+ *   (at your option) any later version.
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ */
+#include <linux/tsn.h>
+#include <trace/events/tsn.h>
+
+#include "tsn_internal.h"
+
+#define AVTP_GPTP_TIMEMASK 0xFFFFFFFF
+
+static u32 tsnh_avtp_timestamp(u64 ptime_ns)
+{
+	/* See 1722-2011, 5.4.8
+	 *
+	 * (AS_sec * 1e9 + AS_ns) % 2^32
+	 *
+	 * Just use ktime_get_ns() and grab lower 32 bits of it.
+	 */
+	/* u64 ns = ktime_to_ns(ktime_get()); */
+	u32 gptp_ts = ptime_ns & AVTP_GPTP_TIMEMASK;
+	return gptp_ts;
+}
+
+int tsnh_ch_init(struct avtp_ch *header)
+{
+	if (!header)
+		return -EINVAL;
+	header = memset(header, 0, sizeof(*header));
+
+	/* This should be changed when setting control / data
+	 * content. Set to experimental to allow for strange content
+	 * should callee not do job properly
+	 */
+	header->subtype = AVTP_EXPERIMENTAL;
+
+	header->version = 0;
+	return 0;
+}
+
+int _tsnh_validate_du_header(struct tsn_link *link, struct avtp_ch *ch,
+			     struct sk_buff *skb)
+{
+	struct avtpdu_header *header = (struct avtpdu_header *)ch;
+	struct sockaddr_ll *sll;
+	u16 bytes;
+	u8 seqnr;
+
+	if  (ch->cd)
+		return -EINVAL;
+
+	/* As a minimum, we should match the sender's MAC to the
+	 * expected MAC before we pass the frame along.
+	 *
+	 * This does not give much in the way of security (a malicious
+	 * user could probably fake this), but it should remove most
+	 * accidents.
+	 */
+	sll = (struct sockaddr_ll *)&skb->cb;
+	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
+	if (sll->sll_halen != 6) {
+		trace_printk("%s: received MAC address length mismatch. Expected 6 bytes, got %d\n",
+			     __func__, sll->sll_halen);
+		return -EPROTO;
+	}
+
+	if (memcmp(link->remote_mac, &sll->sll_addr, 6)) {
+		trace_printk("%s: received MAC-address mismatch (expected %pM, got %pM), dropping frame\n",
+			     __func__, link->remote_mac, &sll->sll_addr);
+		return -EPROTO;
+	}
+
+	/* Current iteration of TSNis 0b000 only */
+	if (ch->version)
+		return -EPROTO;
+
+	/* Invalid StreamID, should not have ended up here in the first
+	 * place (since we do DU only), if invalid sid, how did we find
+	 * the link?
+	 */
+	if (!ch->sv)
+		return -EPROTO;
+
+	/* Check seqnr, if we have lost one frame, we _could_ insert an
+	 * empty frame, but since we have frame-guarantee from 802.1Qav,
+	 * we don't
+	 */
+	seqnr = (link->last_seqnr + 1) & 0xff;
+	if (header->seqnr != seqnr) {
+		trace_printk("%llu: seqnr mismatch. Got %u, expected %u\n",
+			     link->stream_id, header->seqnr, seqnr);
+		return -EPROTO;
+	}
+
+	bytes = ntohs(header->sd_len);
+	if (bytes == 0 || bytes > link->max_payload_size) {
+		trace_printk("%llu: payload size larger than expected (%u, expected %u)\n",
+			     link->stream_id, bytes, link->max_payload_size);
+		return -EINVAL;
+	}
+
+	/* let shim validate header here as well */
+	if (link->ops->validate_header &&
+	    link->ops->validate_header(link, header) != 0)
+		return -EINVAL;
+
+	return 0;
+}
+
+int tsnh_assemble_du(struct tsn_link *link, struct avtpdu_header *header,
+		     size_t bytes, u64 ts_pres_ns)
+{
+	int ret = 0;
+	void *data;
+
+	if (!header || !link)
+		return -EINVAL;
+
+	tsnh_ch_init((struct avtp_ch *)header);
+	header->cd = 0;
+	header->sv = 1;
+	header->mr = 0;
+	header->gv = 0;
+	header->tv = 1;
+	header->tu = 0;
+	header->avtp_timestamp = htonl(tsnh_avtp_timestamp(ts_pres_ns));
+	header->gateway_info = 0;
+	header->sd_len = htons(bytes);
+
+	tsn_lock(link);
+	if (!link->ops) {
+		pr_err("%s: No available ops, cannot assemble data-unit\n",
+		       __func__);
+		ret = -EINVAL;
+		goto unlock_out;
+	}
+	/* get pointer to where data starts */
+	data = link->ops->get_payload_data(link, header);
+
+	if (bytes > link->used_buffer_size) {
+		pr_err("bytes > buffer_size (%zd >  %zd)\n",
+		       bytes, link->used_buffer_size);
+		ret = -EINVAL;
+		goto unlock_out;
+	}
+
+	header->stream_id = cpu_to_be64(link->stream_id);
+	header->seqnr = link->last_seqnr++;
+	link->ops->assemble_header(link, header, bytes);
+	tsn_unlock(link);
+
+	/* payload */
+	ret = tsn_buffer_read_net(link, data, bytes);
+	if (ret != bytes) {
+		pr_err("%s: Could not copy %zd bytes of data. Res: %d\n",
+		       __func__, bytes, ret);
+		/* FIXME: header cleanup */
+		goto out;
+	}
+	ret = 0;
+out:
+	return ret;
+unlock_out:
+	tsn_unlock(link);
+	return ret;
+}
+
+int _tsnh_handle_du(struct tsn_link *link, struct avtp_ch *ch)
+{
+	struct avtpdu_header *header = (struct avtpdu_header *)ch;
+	void *data;
+	u16 bytes;
+	int ret;
+
+	bytes = ntohs(header->sd_len);
+
+	trace_tsn_du(link, bytes);
+	/* bump seqnr */
+	data = link->ops->get_payload_data(link, header);
+	if (!data)
+		return -EINVAL;
+
+	link->last_seqnr = header->seqnr;
+	ret = tsn_buffer_write_net(link, data, bytes);
+	if (ret != bytes) {
+		trace_printk("%s: Could not copy %u bytes of data. Res: %d\n",
+			     __func__, bytes, ret);
+		return ret;
+	}
+
+	return 0;
+}
diff --git a/net/tsn/tsn_internal.h b/net/tsn/tsn_internal.h
new file mode 100644
index 0000000..d0d2201
--- /dev/null
+++ b/net/tsn/tsn_internal.h
@@ -0,0 +1,383 @@
+/*
+ *   Copyright (C) 2015- Henrik Austad <haustad@cisco.com>
+ *
+ *   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; either version 2 of the License, or
+ *   (at your option) any later version.
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ */
+#ifndef _TSN_INTERNAL_H_
+#define _TSN_INTERNAL_H_
+#include <linux/tsn.h>
+
+#include <linux/mutex.h>
+#include <linux/spinlock.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+
+/* TODO:
+ * - hide tsn-structs and provide handlers
+ * - decouple config/net from core
+ */
+
+struct avtpdu_header;
+struct tsn_link;
+struct tsn_shim_ops;
+
+#define IS_TSN_FRAME(x) (ntohs(x) == ETH_P_TSN)
+#define IS_PTP_FRAME(x) (ntohs(x) == ETH_P_1588)
+#define IS_1Q_FRAME(x)  (ntohs(x) == ETH_P_8021Q)
+
+/**
+ * tsn_add_link - create and add a new link to the system
+ *
+ * Note: this will not enable the link, just allocate most of the data
+ * required for the link. One notable exception being the buffer as we
+ * can modify the buffersize before we start the link.
+ *
+ * @param nic : the nic the link is tied to
+ * @returns the new link
+ */
+struct tsn_link *tsn_create_and_add_link(struct tsn_nic *nic);
+
+/**
+ * tsn_get_stream_ids - write all current Stream IDs into the page.
+ *
+ * @param page the page to write into
+ * @param len size of page
+ * @returns the number of bytes written
+ */
+ssize_t tsn_get_stream_ids(char *page, ssize_t len);
+
+/**
+ * tsn_find_by_stream_id - given a sid, find the corresponding link
+ *
+ * @param sid stream_id
+ * @returns tsn_link struct or NULL if not found
+ */
+struct tsn_link *tsn_find_by_stream_id(u64 sid);
+
+/**
+ * tsn_readd_link - make sure a link is moved to the correct bucket when
+ * stream_id is updated
+ *
+ * @link the TSN link
+ * @old_key previous key for which it can be located in the hashmap
+ *
+ */
+void tsn_readd_link(struct tsn_link *link, u64 old_key);
+
+/**
+ * tsn_remove_link: cleanup and remove from internal storage
+ *
+ * @link: the link to be removed
+ */
+void tsn_remove_link(struct tsn_link *link);
+
+/**
+ * tsn_prepare_link - make link ready for usage
+ *
+ * Caller is happy with the different knobs, this will create the link and start
+ * pushing the data.
+ *
+ * Requirement:
+ *	- callback registered
+ *	- State set to either Talker or Listener
+ *
+ * @param active link
+ * @param the shim_ops to use for the new link
+ * @return 0 on success, negative on error
+ */
+int tsn_prepare_link(struct tsn_link *link, struct tsn_shim_ops *shim_ops);
+int tsn_teardown_link(struct tsn_link *link);
+
+/**
+ * tsn_set_external_buffer - force an update of the buffer
+ *
+ * This will cause tsn_core to use an external buffer. If external
+ * buffering is already in use, this has the effect of forcing an update
+ * of the buffer.
+ *
+ * This will cause tsn_core to swap buffers. The current buffer is
+ * returned and the new is used in place.
+ *
+ * Note: If the new buffer is NULL or buffer_size is less than
+ * max_payload_size, the result can be interesting (by calling this
+ * function, you claim to know what you are doing and should pass sane
+ * values).
+ *
+ * This can also be used if you need to resize the buffer in use.
+ *
+ * Core will continue to use the tsn_shim_swap when the new buffer is
+ * full.
+ *
+ * @param link current link owning the buffer
+ * @param buffer new buffer to use
+ * @param buffer_size size of new buffer
+ * @return old buffer
+ */
+void *tsn_set_external_buffer(struct tsn_link *link, void *buffer,
+			      size_t buffer_size);
+
+/**
+ * tsn_buffer_write_net - write data *into* link->buffer from the network layer
+ *
+ * Used by tsn_net and will typicall accept very small pieces of data.
+ *
+ * @param link  the link associated with the stream_id in the frame
+ * @param src   pointer to data in buffer
+ * @param bytes number of bytes to copy
+ * @return number of bytes copied into the buffer
+ */
+int tsn_buffer_write_net(struct tsn_link *link, void *src, size_t bytes);
+
+/**
+ * tsn_buffer_read_net - read data from link->buffer and give to network layer
+ *
+ * When we send a frame, we grab data from the buffer and add it to the
+ * sk_buff->data, this is primarily done by the Tx-subsystem in tsn_net
+ * and is typically done in small chunks
+ *
+ * @param link current link that holds the buffer
+ * @param buffer the buffer to copy into, must be at least of size bytes
+ * @param bytes number of bytes.
+ *
+ * Note that this routine does NOT CARE about channels, samplesize etc,
+ * it is a _pure_ copy that handles ringbuffer wraps etc.
+ *
+ * This function have side-effects as it will update internal tsn_link
+ * values and trigger refill() should the buffer run low.
+ *
+ * @return Bytes copied into link->buffer, negative value upon error.
+ */
+int tsn_buffer_read_net(struct tsn_link *link, void *buffer, size_t bytes);
+
+/**
+ * tsn_core_running(): test if the link is running
+ *
+ * By running, we mean that it is configured and a proper shim has been
+ * loaded. It does *not* mean that we are currently pushing data in any
+ * direction, see tsn_net_buffer_disabled() for this
+ *
+ * @param struct tsn_link active link
+ * @returns 1 if core is running
+ */
+static inline int tsn_core_running(struct tsn_list *list)
+{
+	if (list)
+		return atomic_read(&list->running);
+	return 0;
+}
+
+/**
+ * _tsn_buffer_used - how much of the buffer is filled with valid data
+ *
+ * - assumes link->running in state running
+ * - will ignore change changed state
+ *
+ * We write to head, read from tail.
+ */
+static inline size_t _tsn_buffer_used(struct tsn_link *link)
+{
+	return  (link->head - link->tail) % link->used_buffer_size;
+}
+
+static inline void tsn_lock(struct tsn_link *link)
+{
+	spin_lock(&link->lock);
+}
+
+static inline void tsn_unlock(struct tsn_link *link)
+{
+	spin_unlock(&link->lock);
+}
+
+/* -----------------------------
+ * ConfigFS handling
+ */
+int tsn_configfs_init(struct tsn_list *tlist);
+void tsn_configfs_exit(struct tsn_list *tlist);
+
+/* -----------------------------
+ * TSN Header
+ */
+
+static inline size_t tsnh_len(void)
+{
+	/* include 802.1Q tag */
+	return sizeof(struct avtpdu_header);
+}
+
+static inline u16 tsnh_len_all(void)
+{
+	return (u16)tsnh_len() + ETH_HLEN;
+}
+
+/**
+ * tsnh_payload_size_valid - if the entire payload is within size-limit
+ *
+ * Ensure that max_payload_size and shim_header_size is within acceptable limits
+ *
+ * We need both values to calculate the payload size when reserving
+ * bandwidth, but only payload-size when instructing the shim to copy
+ * out data for us.
+ *
+ * @param max_payload_size requested payload to send in each frame (upper limit)
+ * @return 0 on invalid, 1 on valid
+ */
+static inline int tsnh_payload_size_valid(u16 max_payload_size,
+					  u16 shim_hdr_size)
+{
+	/* VLAN_ETH_ZLEN	64 */
+	/* VLAN_ETH_FRAME_LEN	1518 */
+	u32 framesize = max_payload_size + tsnh_len_all() + shim_hdr_size;
+
+	return framesize >= VLAN_ETH_ZLEN && framesize <= VLAN_ETH_FRAME_LEN;
+}
+
+/**
+ * _tsnh_validate_du_header - basic header validation
+ *
+ * This expects the parameters to be present and the link-lock to be
+ * held.
+ *
+ * @param header header to verify
+ * @param link owner of stream
+ * @param socket_buffer
+ * @return 0 on valid, negative on invalid/error
+ */
+int _tsnh_validate_du_header(struct tsn_link *link, struct avtp_ch *ch,
+			     struct sk_buff *skb);
+
+/**
+ * tsnh_assemble_du - assemble header and copy data from buffer
+ *
+ * This function will initialize the header and pass final init to
+ * shim->assemble_header before copying data into the buffer.
+ *
+ * It assumes that 'bytes' is a sane value, i.e. that it is a valid
+ * multiple of number of channels, sample size etc.
+ *
+ * @param link   Current TSN link, also holds the buffer
+ *
+ * @param header header to assemble for data
+ *
+ * @param bytes  Number of bytes to send in this frame
+ *
+ * @param ts_pres_ns current for when the frame should be presented or
+ *                   considered valid by the receiving end. In
+ *                   nanoseconds since epoch, will be converted to gPTP
+ *                   compatible timestamp.
+ *
+ * @return 0 on success, negative on error
+ */
+int tsnh_assemble_du(struct tsn_link *link, struct avtpdu_header *header,
+		     size_t bytes, u64 ts_pres_ns);
+
+/**
+ * _tsnh_handle_du - handle incoming data and store to media-buffer
+ *
+ * This assumes that the frame actually belongs to the link and that it
+ * has passed basic validation.
+ *
+ * It also expects the link lock to be held.
+ *
+ * @param link    Link associated with stream_id
+ * @param header  Header of incoming frame
+ * @return number of bytes copied to buffer or negative on error
+ */
+int _tsnh_handle_du(struct tsn_link *link, struct avtp_ch *ch);
+
+static inline struct avtp_ch *tsnh_ch_from_skb(struct sk_buff *skb)
+{
+	if (!skb)
+		return NULL;
+	if (!IS_TSN_FRAME(eth_hdr(skb)->h_proto))
+		return NULL;
+
+	return (struct avtp_ch *)skb->data;
+}
+
+/**
+ * tsn_net_add_rx - add Rx handler for all NICs listed
+ *
+ * @param list tsn_list to add Rx handler to
+ * @return 0 on success, negative on error
+ */
+int tsn_net_add_rx(struct tsn_list *list);
+
+/**
+ * tsn_net_remove_rx - remove Rx-handlers for all tsn_nics
+ *
+ * Go through all NICs and remove those Rx-handlers we have
+ * registred. If someone else has added an Rx-handler to the NIC, we do
+ * not touch it.
+ *
+ * @param list list of all tsn_nics (with links)
+ */
+void tsn_net_remove_rx(struct tsn_list *list);
+
+/**
+ * tsn_net_open_tx - prepare all capable links for Tx
+ *
+ * This will prepare all NICs for Tx, and those marked as 'capable'
+ * will be initialized with DMA regions. Note that this is not the final
+ * step for preparing for Tx, it is only when we have active links that
+ * we know how much bandwidth we need and then can set the appropriate
+ * idleSlope params etc.
+ *
+ * @tlist: list of all available card
+ * @return: negative on error, on success the number of prepared NICS
+ *          are returned.
+ */
+int tsn_net_prepare_tx(struct tsn_list *tlist);
+
+/**
+ * tsn_net_disable_tx - disable Tx on card
+ *
+ * This frees DMA-memory from capable NICs
+ *
+ * @param tsn_list: link to all available NICs used by TSN
+ */
+void tsn_net_disable_tx(struct tsn_list *tlist);
+
+/**
+ * tsn_net_set_vlan - try to register the VLAN on the NIC
+ *
+ * Some NICs will handle VLAN themselves, try to register this vlan with
+ * the card to enable hw-support for Tx via this VLAN
+ *
+ * @param: tsn_link the active link
+ * @return: 0 on success, negative on error.
+ */
+int tsn_net_set_vlan(struct tsn_link *link);
+
+/**
+ * tsn_net_close - close down link properly
+ *
+ * @param struct tsn_link * active link to close down
+ */
+void tsn_net_close(struct tsn_link *link);
+
+/**
+ * tsn_net_send_set - send a set of frames
+ *
+ * We want to assemble a number of sk_buffs at a time and ship them off
+ * in a single go and then go back to sleep. Pacing should be done by
+ * hardware, or if we are in in_debug, we don't really care anyway
+ *
+ * @param link        : current TSN-link
+ * @param num         : the number of frames to create
+ * @param ts_base_ns  : base timestamp for when the frames should be
+ *		        considered valid
+ * @param ts_delta_ns : time between each frame in the set
+ */
+int tsn_net_send_set(struct tsn_link *link, size_t num, u64 ts_base_ns,
+		     u64 ts_delta_ns);
+
+#endif	/* _TSN_INTERNAL_H_ */
diff --git a/net/tsn/tsn_net.c b/net/tsn/tsn_net.c
new file mode 100644
index 0000000..560e2fd
--- /dev/null
+++ b/net/tsn/tsn_net.c
@@ -0,0 +1,403 @@
+/*
+ *   Network part of TSN
+ *
+ *   Copyright (C) 2015- Henrik Austad <haustad@cisco.com>
+ *
+ *   This program is free software; you can redistribute it and/or modify
+ *   it under the terms of the GNU General Public License as published by
+ *   the Free Software Foundation; either version 2 of the License, or
+ *   (at your option) any later version.
+ *
+ *   This program is distributed in the hope that it will be useful,
+ *   but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *   GNU General Public License for more details.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/socket.h>
+#include <linux/skbuff.h>
+#include <linux/if_vlan.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+
+#include <linux/tsn.h>
+#include <trace/events/tsn.h>
+#include "tsn_internal.h"
+
+/**
+ * tsn_rx_handler - consume all TSN-tagged frames and forward to tsn_link.
+ *
+ * This handler, if it regsters properly, will consume all TSN-tagged
+ * frames belonging to registered Stream IDs
+ *
+ * Unknown StreamIDs will be passed through without being touched.
+ *
+ * @param pskb sk_buff with incomign data
+ * @returns RX_HANDLER_CONSUMED for TSN frames to known StreamIDs,
+ *	    RX_HANDLER_PASS for everything else.
+ */
+static rx_handler_result_t tsn_rx_handler(struct sk_buff **pskb)
+{
+	struct sk_buff *skb = *pskb;
+	const struct ethhdr *ethhdr = eth_hdr(skb);
+	struct avtp_ch *ch;
+	struct tsn_link *link;
+	rx_handler_result_t ret = RX_HANDLER_PASS;
+
+	ch = tsnh_ch_from_skb(skb);
+	if (!ch)
+		return RX_HANDLER_PASS;
+	/* We do not (currently) touch control_data frames. */
+	if (ch->cd)
+		return RX_HANDLER_PASS;
+
+	link = tsn_find_by_stream_id(be64_to_cpu(ch->stream_id));
+	if (!link)
+		return RX_HANDLER_PASS;
+
+	tsn_lock(link);
+
+	if (!tsn_link_is_on(link))
+		goto out_unlock;
+
+	/* If link->ops is not set yet, there's nothing we can do, just
+	 * ignore this frame
+	 */
+	if (!link->ops)
+		goto out_unlock;
+
+	if (_tsnh_validate_du_header(link, ch, skb))
+		goto out_unlock;
+
+	trace_tsn_rx_handler(link, ethhdr, be64_to_cpu(ch->stream_id));
+
+	/* Handle dataunit, if it failes, pass on the frame and let
+	 * userspace pick it up.
+	 */
+	if (_tsnh_handle_du(link, ch) < 0)
+		goto out_unlock;
+
+	/* Done, data has been copied, free skb and return consumed */
+	consume_skb(skb);
+	ret = RX_HANDLER_CONSUMED;
+
+out_unlock:
+	tsn_unlock(link);
+	return ret;
+}
+
+int tsn_net_add_rx(struct tsn_list *tlist)
+{
+	struct tsn_nic *nic;
+
+	if (!tlist)
+		return -EINVAL;
+
+	/* Setup receive handler for TSN traffic.
+	 *
+	 * Receive will happen all the time, once a link is active as a
+	 * Listener, we will add a hook into the receive-handler to
+	 * steer the frames to the correct link.
+	 *
+	 * We try to add Rx-handlers to all the card listed in tlist (we
+	 * assume core has filtered the NICs appropriatetly sothat only
+	 * TSN-capable cards are present).
+	 */
+	mutex_lock(&tlist->lock);
+	list_for_each_entry(nic, &tlist->head, list) {
+		rtnl_lock();
+		if (netdev_rx_handler_register(nic->dev, tsn_rx_handler, nic) < 0) {
+			pr_err("%s: could not attach an Rx-handler to %s, this link will not be able to accept TSN traffic\n",
+			       __func__, nic->name);
+			rtnl_unlock();
+			continue;
+		}
+		rtnl_unlock();
+		pr_info("%s: attached rx-handler to %s\n",
+			__func__, nic->name);
+		nic->rx_registered = 1;
+	}
+	mutex_unlock(&tlist->lock);
+	return 0;
+}
+
+void tsn_net_remove_rx(struct tsn_list *tlist)
+{
+	struct tsn_nic *nic;
+
+	if (!tlist)
+		return;
+	mutex_lock(&tlist->lock);
+	list_for_each_entry(nic, &tlist->head, list) {
+		rtnl_lock();
+		if (nic->rx_registered)
+			netdev_rx_handler_unregister(nic->dev);
+		rtnl_unlock();
+		nic->rx_registered = 0;
+		pr_info("%s: RX-handler for %s removed\n",
+			__func__, nic->name);
+	}
+	mutex_unlock(&tlist->lock);
+}
+
+int tsn_net_prepare_tx(struct tsn_list *tlist)
+{
+	struct tsn_nic *nic;
+	struct device *dev;
+	int ret = 0;
+
+	if (!tlist)
+		return -EINVAL;
+
+	mutex_lock(&tlist->lock);
+	list_for_each_entry(nic, &tlist->head, list) {
+		if (!nic)
+			continue;
+		if (!nic->capable)
+			continue;
+
+		if (!nic->dev->netdev_ops)
+			continue;
+
+		dev = nic->dev->dev.parent;
+		nic->dma_mem = dma_alloc_coherent(dev, nic->dma_size,
+						  &nic->dma_handle, GFP_KERNEL);
+		if (!nic->dma_mem) {
+			nic->capable = 0;
+			nic->dma_size = 0;
+			continue;
+		}
+		ret++;
+	}
+	mutex_unlock(&tlist->lock);
+	pr_info("%s: configured %d cards to use DMA\n", __func__, ret);
+	return ret;
+}
+
+void tsn_net_disable_tx(struct tsn_list *tlist)
+{
+	struct tsn_nic *nic;
+	struct device *dev;
+	int res = 0;
+
+	if (!tlist)
+		return;
+	mutex_lock(&tlist->lock);
+	list_for_each_entry(nic, &tlist->head, list) {
+		if (nic->capable && nic->dma_mem) {
+			dev = nic->dev->dev.parent;
+			dma_free_coherent(dev, nic->dma_size, nic->dma_mem,
+					  nic->dma_handle);
+			res++;
+		}
+	}
+	mutex_unlock(&tlist->lock);
+	pr_info("%s: freed DMA regions from %d cards\n", __func__, res);
+}
+
+void tsn_net_close(struct tsn_link *link)
+{
+	/* struct tsn_rx_handler_data *rx_data; */
+
+	/* Careful! we need to make sure that we actually succeeded in
+	 * registering the handler in open unless we want to unregister
+	 * some random rx_handler..
+	 */
+	if (!link->estype_talker) {
+		;
+		/* Make sure we notify rx-handler so it doesn't write
+		 * into NULL
+		 */
+	}
+}
+
+int tsn_net_set_vlan(struct tsn_link *link)
+{
+	int err;
+	struct tsn_nic *nic = link->nic;
+	const struct net_device_ops *ops = nic->dev->netdev_ops;
+
+	int vf   = 2;
+	u16 vlan = link->vlan_id;
+	u8 qos   = link->class_a ? link->pcp_a : link->pcp_b;
+
+	pr_info("%s:%s Setting vlan=%u,vf=%d,qos=%u\n",
+		__func__, nic->name, vlan, vf, qos);
+	if (ops->ndo_set_vf_vlan) {
+		err = ops->ndo_set_vf_vlan(nic->dev, vf, vlan, qos);
+		if (err != 0) {
+			pr_err("%s:%s could not set VLAN to %u, got %d\n",
+			       __func__,  nic->name, vlan, err);
+			return -EINVAL;
+		}
+		return 0;
+	}
+	return -1;
+}
+
+static inline u16 _get_8021q_vid(struct tsn_link *link)
+{
+	u16 pcp = link->class_a ? link->pcp_a : link->pcp_b;
+	/* If not explicitly provided, use SR_PVID 0x2*/
+	return (link->vlan_id & VLAN_VID_MASK) | ((pcp & 0x7) << 13);
+}
+
+/* create and initialize a sk_buff with appropriate TSN Header values
+ *
+ * layout of frame:
+ * - Ethernet header
+ *   dst (6) | src (6) | 802.1Q (4) | EtherType (2)
+ * - 1722 (sizeof struct avtpdu)
+ * - payload data
+ *	- type header (e.g. iec61883-6 hdr)
+ *	- payload data
+ *
+ * Required size:
+ *  Ethernet: 18 -> VLAN_ETH_HLEN
+ *  1722: tsnh_len()
+ *  payload: shim_hdr_size + data_bytes
+ *
+ * Note:
+ *	- seqnr is not set
+ *	- payload is not set
+ */
+static struct sk_buff *_skbuf_create_init(struct tsn_link *link,
+					  size_t data_bytes,
+					  size_t shim_hdr_size,
+					  u64 ts_pres_ns, u8 more)
+{
+	struct sk_buff *skb = NULL;
+	struct avtpdu_header *avtpdu;
+	struct net_device *netdev = link->nic->dev;
+	int queue_idx;
+	int res = 0;
+	int hard_hdr_len;
+
+	/* length is size of AVTPDU + data
+	 * +-----+ <-- head
+	 * | - link layer header
+	 * | - 1722 header (avtpdu_header)
+	 * +-----+ <-- data
+	 * | - shim_header
+	 * | - data
+	 * +-----+ <-- tail
+	 * |
+	 * +-----+ <--end
+	 * We stuff all of TSN-related
+	 * headers in the data-segment to make it easy
+	 */
+	size_t hdr_len = VLAN_ETH_HLEN;
+	size_t avtpdu_len = tsnh_len() + shim_hdr_size + data_bytes;
+
+	skb = alloc_skb(hdr_len + avtpdu_len + netdev->needed_tailroom,
+			GFP_ATOMIC | GFP_DMA);
+	if (!skb)
+		return NULL;
+	skb_reserve(skb, hdr_len);
+
+	skb->protocol = htons(ETH_P_TSN);
+	skb->pkt_type = PACKET_OUTGOING;
+	skb->priority = (link->class_a ? link->pcp_a : link->pcp_b);
+	skb->dev = link->nic->dev;
+	skb_shinfo(skb)->tx_flags |= SKBTX_HW_TSTAMP;
+	skb->xmit_more = (more > 0 ? 1 : 0);
+	skb_set_mac_header(skb, 0);
+
+	/* We are using a ethernet-type frame (even though we could send
+	 * TSN over other medium.
+	 *
+	 * - skb_push(skb, ETH_HLEN)
+	 * - set header htons(header)
+	 * - set source addr (netdev mac addr)
+	 * - set dest addr
+	 * - return ETH_HLEN
+	 */
+	hard_hdr_len = dev_hard_header(skb, skb->dev, ETH_P_TSN,
+				       link->remote_mac, NULL, 6);
+
+	skb = vlan_insert_tag(skb, htons(ETH_P_8021Q), _get_8021q_vid(link));
+	if (!skb) {
+		pr_err("%s: could not insert tag in buffer, aborting\n",
+		       __func__);
+		return NULL;
+	}
+
+	/* tsnh_assemble_du() will deref avtpdu to find start of data
+	 * segment and use that, this is to update the skb
+	 * appropriately.
+	 *
+	 * tsnh_assemble_du() will grab tsn-lock before updating link
+	 */
+	avtpdu = (struct avtpdu_header *)skb_put(skb, avtpdu_len);
+	res = tsnh_assemble_du(link, avtpdu, data_bytes, ts_pres_ns);
+	if (res < 0) {
+		pr_err("%s: Error initializing header (-> %d) , we are in an inconsistent state!\n",
+		       __func__, res);
+		kfree_skb(skb);
+		return NULL;
+	}
+
+	/* FIXME: Find a suitable Tx-queue
+	 *
+	 * For igb, this returns -1
+	 */
+	queue_idx = sk_tx_queue_get(skb->sk);
+	if (queue_idx < 0 || queue_idx >= netdev->real_num_tx_queues)
+		queue_idx = 0;
+	skb_set_queue_mapping(skb, queue_idx);
+	skb->queue_mapping = 0;
+
+	skb->csum = skb_checksum(skb, 0, hdr_len + data_bytes, 0);
+	return skb;
+}
+
+/**
+ * Send a set of frames as efficiently as possible
+ */
+int tsn_net_send_set(struct tsn_link *link, size_t num, u64 ts_base_ns,
+		     u64 ts_delta_ns)
+{
+	struct sk_buff *skb;
+	struct net_device *dev;
+	size_t data_size;
+	int res;
+	struct netdev_queue *txq;
+	u64 ts_pres_ns = ts_base_ns;
+
+	if (!link)
+		return -EINVAL;
+	dev = link->nic->dev;
+
+	/* create and init sk_buff_head */
+	while (num-- > 0) {
+		data_size = tsn_shim_get_framesize(link);
+
+		skb = _skbuf_create_init(link, data_size,
+					 tsn_shim_get_hdr_size(link),
+					 ts_pres_ns, (num > 0));
+		if (!skb) {
+			pr_err("%s: could not allocate memory for skb\n",
+			       __func__);
+			return -ENOMEM;
+		}
+
+		trace_tsn_pre_tx(link, skb, data_size);
+		txq = skb_get_tx_queue(dev, skb);
+		if (!txq) {
+			pr_err("%s: Could not get tx_queue, dropping sending\n",
+			       __func__);
+			kfree_skb(skb);
+			return -EINVAL;
+		}
+		res = netdev_start_xmit(skb, dev, txq, (num > 0));
+		if (res != NETDEV_TX_OK) {
+			pr_err("%s: Tx FAILED\n", __func__);
+			return res;
+		}
+		ts_pres_ns += ts_delta_ns;
+	}
+	return 0;
+}
-- 
2.7.4
