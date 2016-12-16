From: henrik@austad.us
Subject: [TSN RFC v2 6/9] Add TSN machinery to drive the traffic from a shim over the network
Date: Fri, 16 Dec 2016 18:59:10 +0100
Message-ID: <1481911153-549-7-git-send-email-henrik@austad.us>
References: <1481911153-549-1-git-send-email-henrik@austad.us>
Cc: Richard Cochran <richardcochran@gmail.com>, henrik@austad.us,
        Henrik Austad <haustad@cisco.com>, linux-media@vger.kernel.org,
        alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481911153-549-1-git-send-email-henrik@austad.us>
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

  New is that setting a shim will not automatically enable it, this is to
  allow shims to expose own attributes via ConfigFS. It will also make the
  steps a bit more obvious.

* tsn_header.c small part that handles the actual header of the frames
  we send. Kept out of core for cleanliness.

* tsn_net.c handles operations towards the networking layer. A *very*
  simple hook for handling backpressure in the tx-queue is added, but this
  is currently nowhere near sufficient.

The current driver is under development. This means that from the moment it
is enabled (with a registered shim), it will send traffic, either 0-traffic
(frames of reserved length but with payload 0) or actual traffic. This will
change once the driver stabilizes.

We also use a kthread to handle the lifting when transmitting frames. This
should remove some of the old timeouts and issues we had when doing all of
this via the hrtimer callback. Should a new timer fire before we are done,
it will be queued up and handled immediately. Note that this is a bug (we
*really* should be done before the next 1ms tick happens.

For more detail, see Documentation/networking/tsn/

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Henrik Austad <haustad@cisco.com>
---
 net/Makefile           |    1 +
 net/tsn/Makefile       |    6 +
 net/tsn/tsn_configfs.c |  673 +++++++++++++++++++++++++++
 net/tsn/tsn_core.c     | 1189 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/tsn/tsn_header.c   |  162 +++++++
 net/tsn/tsn_internal.h |  397 ++++++++++++++++
 net/tsn/tsn_net.c      |  392 ++++++++++++++++
 7 files changed, 2820 insertions(+)
 create mode 100644 net/tsn/Makefile
 create mode 100644 net/tsn/tsn_configfs.c
 create mode 100644 net/tsn/tsn_core.c
 create mode 100644 net/tsn/tsn_header.c
 create mode 100644 net/tsn/tsn_internal.h
 create mode 100644 net/tsn/tsn_net.c

diff --git a/net/Makefile b/net/Makefile
index 4cafaa2..a0f7d41 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -81,3 +81,4 @@ obj-y				+= l3mdev/
 endif
 obj-$(CONFIG_QRTR)		+= qrtr/
 obj-$(CONFIG_NET_NCSI)		+= ncsi/
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
index 0000000..9ace1aa
--- /dev/null
+++ b/net/tsn/tsn_configfs.c
@@ -0,0 +1,673 @@
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
+static inline struct tsn_nic *item_to_tsn_nic(struct config_item *item)
+{
+	return item ? container_of(to_config_group(item), struct tsn_nic, group) : NULL;
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
+		pr_err("ERROR: Cannot change Payload size on link\n");
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
+		pr_err("ERROR: Cannot change shim-header size on link\n");
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
+		pr_err("ERROR: Cannot change StreamID on link\n");
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
+		pr_err("ERROR: Cannot change Buffer Size on link\n");
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
+	return sprintf(page, "%s\n", (link->class == SR_CLASS_A ? "A" : "B"));
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
+		pr_err("ERROR: Cannot change Class-type on link\n");
+		return -EINVAL;
+	}
+	if (strncpy(class, page, 1)) {
+		if (strcmp(class, "a") == 0 || strcmp(class, "A") == 0)
+			link->class = SR_CLASS_A;
+		else if (strcmp(class, "b") == 0 || strcmp(class, "B") == 0)
+			link->class = SR_CLASS_B;
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
+		pr_err("ERROR: Cannot change VLAN-ID on link\n");
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
+		pr_err("ERROR: Cannot change End-station type on link.\n");
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
+static ssize_t _tsn_shim_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%s\n", tsn_shim_get_active(link));
+}
+
+static ssize_t _tsn_shim_store(struct config_item *item,
+			const char *page, size_t count)
+{
+	size_t len;
+	ssize_t ret;
+	char shim_name[SHIM_NAME_SIZE + 1] = { 0 };
+	struct tsn_shim_ops *shim_ops = NULL;
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("TSN ERROR: cannot change shim on link (is active)\n");
+		return -EINVAL;
+	}
+
+	strncpy(shim_name, page, SHIM_NAME_SIZE);
+	len = strlen(shim_name);
+	while (len-- > 0) {
+		if (shim_name[len] == '\n')
+			shim_name[len] = 0x00;
+	}
+
+	/* the only shim we allow to set shim_ops to NULL is 'off' */
+	if (strncmp(shim_name, "off", 3) != 0) {
+		shim_ops = tsn_shim_find_by_name(shim_name);
+		if (!shim_ops) {
+			pr_info("TSN ERROR: could not enable desired shim, %s is not available\n",
+				shim_name);
+			return -EINVAL;
+		}
+	}
+
+	ret = tsn_set_shim_ops(link, shim_ops);
+	if (ret != 0) {
+		pr_err("TSN ERROR: Could not set shim-ops for link - %zd\n", ret);
+		return ret;
+	}
+	pr_info("TSN: Set new shim_ops (%s)\n", shim_name);
+	return count;
+}
+
+static ssize_t _tsn_enabled_show(struct config_item *item, char *page)
+{
+	struct tsn_link *link = to_tsn_link(item);
+
+	if (!link)
+		return -EINVAL;
+	return sprintf(page, "%s\n", tsn_link_is_on(link) ? "on" : "off");
+}
+
+static ssize_t _tsn_enabled_store(struct config_item *item,
+				  const char *page, size_t count)
+{
+	struct tsn_link *link = to_tsn_link(item);
+	char link_state[8] = {0};
+	size_t len;
+	int ret = 0;
+
+	if (!link)
+		return -EINVAL;
+
+	strncpy(link_state, page, 7);
+	len = strlen(link_state);
+	while (len-- > 0) {
+		if (link_state[len] == '\n')
+			link_state[len] = 0x00;
+	}
+
+	/* only allowed state is off */
+	if (tsn_link_is_on(link) || tsn_link_is_err(link)) {
+		if (strncmp(link_state, "off", 3) != 0) {
+			pr_err("TSN ERROR: Invalid link_state for active link (%s), ignoring\n", link_state);
+			return -EINVAL;
+		}
+		tsn_teardown_link(link);
+		return count;
+	}
+	else if (strncmp(link_state, "on", 3) == 0) {
+		ret = tsn_prepare_link(link);
+		if (ret != 0) {
+			pr_err("TSN ERROR: Preparing link failed - %d\n", ret);
+			return ret;
+		}
+		return count;
+	}
+	return -EINVAL;
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
+	unsigned char mac[7] = {0};
+	int ret = 0;
+
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link)) {
+		pr_err("ERROR: Cannot change Remote MAC on link.\n");
+		return -EINVAL;
+	}
+	ret = sscanf(page, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
+		     &mac[0], &mac[1], &mac[2], &mac[3], &mac[4], &mac[5]);
+	if (ret > 0) {
+		pr_info("Got MAC (%pM), copying to storage\n", &mac);
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
+CONFIGFS_ATTR(_tsn_, end_station);
+CONFIGFS_ATTR(_tsn_, shim);
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
+	&_tsn_attr_end_station,
+	&_tsn_attr_shim,
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
+		tsn_remove_and_free_link(link);
+	}
+	pr_info("Dropping %s from NIC: %s\n", item->ci_name, nic->name);
+}
+
+
+static ssize_t _tsn_pcp_a_show(struct config_item *item, char *page)
+{
+	struct tsn_nic *nic = item_to_tsn_nic(item);
+
+	if (!nic)
+		return -EINVAL;
+	return sprintf(page, "0x%x\n", nic->pcp_a);
+}
+
+static ssize_t _tsn_pcp_a_store(struct config_item *item,
+				const char *page, size_t count)
+{
+	struct tsn_nic *nic = item_to_tsn_nic(item);
+	int ret = 0;
+	u8 pcp;
+
+	if (!nic)
+		return -EINVAL;
+
+	/* FIXME: need to check for *any* active links */
+
+	ret = kstrtou8(page, 0, &pcp);
+	if (ret)
+		return ret;
+	if (pcp > 0x7)
+		return -EINVAL;
+	nic->pcp_a = pcp & 0x7;
+	return count;
+}
+
+static ssize_t _tsn_pcp_b_show(struct config_item *item, char *page)
+{
+	struct tsn_nic *nic = item_to_tsn_nic(item);
+
+	if (!nic)
+		return -EINVAL;
+	return sprintf(page, "0x%x\n", nic->pcp_b);
+}
+
+static ssize_t _tsn_pcp_b_store(struct config_item *item,
+				const char *page, size_t count)
+{
+	struct tsn_nic *nic = item_to_tsn_nic(item);
+	int ret = 0;
+	u8 pcp;
+
+	if (!nic)
+		return -EINVAL;
+
+	/* FIXME: need to check for *any* active links */
+
+	ret = kstrtou8(page, 0, &pcp);
+	if (ret)
+		return ret;
+	if (pcp > 0x7)
+		return -EINVAL;
+	nic->pcp_b = pcp & 0x7;
+	return count;
+}
+
+CONFIGFS_ATTR(_tsn_, pcp_a);
+CONFIGFS_ATTR(_tsn_, pcp_b);
+
+static struct configfs_attribute *tsn_tier1_attrs[] = {
+	&_tsn_attr_pcp_a,
+	&_tsn_attr_pcp_b,
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
index 0000000..f243b0f
--- /dev/null
+++ b/net/tsn/tsn_core.c
@@ -0,0 +1,1189 @@
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
+#include <linux/kthread.h>
+#include <linux/sched.h>
+#include <linux/hashtable.h>
+#include <linux/netdevice.h>
+#include <linux/net.h>
+#include <linux/dma-mapping.h>
+#include <net/sock.h>
+#include <net/net_namespace.h>
+#include <linux/hrtimer.h>
+#include <linux/configfs.h>
+#include <linux/ktime.h>
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
+
+/* _get_low_water - return the number of bytes that signal the low-water
+ * mark in the buffer.
+ *
+ * class B sends frames every 250us (4 per ms), A doubles that.
+ */
+#define LOW_WATER_MS 20
+static inline size_t _get_low_water(struct tsn_link *link)
+{
+	int numframes = LOW_WATER_MS * (link->class == SR_CLASS_A ? 8 : 4);
+
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
+	trace_tsn_free_buffer(link, link->buffer_size);
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
+	if (tsn_link_is_err(link)) {
+		tsn_teardown_link(link);
+		return -EIO;
+	}
+
+	/* We should not do anything if link has gone inactive */
+	if (!tsn_link_is_on(link))
+		return 0;
+
+	__tsn_buffer_write(link, src, bytes);
+
+	/* Copied a batch of data and if link is disabled, it is now
+	 * safe to enable it. Otherwise we will continue to send
+	 * null-frames to remote.
+	 */
+	if (!tsn_lb(link))
+		tsn_lb_enable(link);
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
+ * NOTE: called from tsn_rx_handler() -> tsnh_handle_du(), with
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
+/* Note: this assumes that the frames will be sent out immediately and
+ * not kept in a queue somewhere awaiting enough credits. If that is the
+ * case, then this will probably fool the shim into thinking that the
+ * frames have been shipped out early.
+ *
+ * Ideally, this should be updated whenever the frame is actually transmittet.
+ *
+ * Workaround/idea:
+ * - find size of tx-queue on card
+ * - look at how many is to be sent
+ * - look at outgoing bw
+ * - find the actual rate of frames going out
+ * - use rate + time_now to determine time when frame will be shipped.
+ *
+ * Or, another approach; grab presentation time from frame and use that
+ * as basis for timestamp. If prsentation time is too far into the
+ * future, do not send this frame just yet. This also requires us to
+ * look at what timestamp previous frames have used.
+ */
+int tsn_update_net_time(struct tsn_link *link, u64 time_ns, int increment)
+{
+	u64 delta_ns;
+	u64 exp_avg;
+
+	if (time_ns < link->ts_net_ns || increment < 1)
+		return -EINVAL;
+
+	/* if increment > 1, we have sent a batch of frames, and */
+	delta_ns = time_ns - link->ts_net_ns;
+	if (increment > 1)
+		delta_ns = div_u64(delta_ns, increment);
+	do {
+		exp_avg = ((delta_ns * link->ts_exp_alpha) >> 14) + ((((1 << 14) - link->ts_exp_alpha) * link->ts_exp_avg) >> 14);
+		link->ts_exp_avg = exp_avg;
+	} while (--increment > 0);
+
+	link->ts_net_ns = time_ns;
+	link->ts_delta_ns = delta_ns;
+	trace_tsn_update_net_time(link);
+	return 0;
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
+	 * content. This is a debug-feature, if we don't have data to
+	 * send, we should not send zero-frames.
+	 *
+	 * This can be done before we ship data, or if we are muted
+	 * (without expressively stating that over 1722.1
+	 */
+	if (!tsn_lb(link)) {
+		memset(buffer, 0, bytes);
+		goto out;
+	}
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
+	size_t num_frames = (link->class == SR_CLASS_A ? 8 : 4);
+	u64 ts_base_ns = ktime_to_ns(ktime_get()) + (link->class == SR_CLASS_A ? 2000000 : 50000000);
+	u64 ts_delta_ns = (link->class == SR_CLASS_A ? 125000 : 250000);
+
+	trace_tsn_send_batch(link, num_frames, ts_base_ns, ts_delta_ns);
+	ret = tsn_net_send_set(link, num_frames, ts_base_ns, ts_delta_ns);
+	if (ret < 0)
+		return ret;
+	link->frames_sent += ret;
+
+	/* we sent ret number of frames, update timestamp with that. */
+	tsn_update_net_time(link, ktime_to_ns(ktime_get()), ret);
+
+	return 0;
+}
+
+static int tsn_worker_fn(void *data)
+{
+	struct tsn_link *link;
+	struct hlist_node *tmp;
+	int bkt = 0;
+	int err;
+	struct sched_param param = { .sched_priority = 10 };
+	struct tsn_list *list = (struct tsn_list *)data;
+	if (!data)
+		return -EINVAL;
+
+	/* FIXME: set affinity */
+	/* set sched_rr and prio */
+	sched_setscheduler(current, SCHED_RR, &param);
+
+	pr_info("tsn_worker ready to run\n");
+	while (!kthread_should_stop() && tsn_core_running(list)) {
+		if (list->should_run <= 0) {
+		sched_out:
+			/* task_interruptible */
+			set_current_state(TASK_INTERRUPTIBLE);
+			schedule();
+		}
+		if (!tsn_core_running(list) || kthread_should_stop())
+			break;
+
+		if (list->should_run <= 0)
+			goto sched_out;
+
+
+		hash_for_each_safe(tlinks, bkt, tmp, link, node) {
+			/* use the periodic wakeup to test if any of the
+			 * links has failed. If it has, clear it and
+			 * continue */
+			if (tsn_link_is_err(link)) {
+				tsn_teardown_link(link);
+				continue;
+			}
+
+			/* if the link is not on, we can ignore the link
+			 * for one iteration before we start sending
+			 * frames, we accept this race. */
+			if (!tsn_link_is_on(link))
+				continue;
+
+			tsn_lock(link);
+
+			/* In case we are killed while waiting for the lock */
+			if (kthread_should_stop()) {
+				tsn_unlock(link);
+				return 0;
+			}
+
+			/* FIXME: this should iterate over each link and
+			 * send *one* frame pr link until all links are
+			 * exhausted for this period, otherwise the
+			 * first link in a run will starve the other
+			 * links.
+			 */
+			if (tsn_link_is_on(link) && link->estype_talker) {
+				err = _tsn_send_batch(link);
+				if (err)
+					tsn_link_err(link);
+			}
+
+			tsn_unlock(link);
+		}
+		list->should_run--;
+	}
+	pr_info("tsn_worker_fn done, wrapping up and dying\n");
+	return 0;
+}
+
+static int tsn_worker_init(struct tsn_list *list)
+{
+	/* create wait-queue */
+	list->tsn_thread = kthread_create(tsn_worker_fn, list, "tsn_worker");
+	if (!list->tsn_thread)
+		return -ENOMEM;
+
+	/* prod the thread to make it ready if hrtimer calls it immediately */
+	wake_up_process(list->tsn_thread);
+	return 0;
+}
+
+static void tsn_worker_exit(struct tsn_list *list)
+{
+	atomic_set(&list->running, 0);
+	list->should_run = 0;
+	kthread_stop(list->tsn_thread);
+}
+
+static enum hrtimer_restart tsn_hrtimer_callback(struct hrtimer *hrt)
+{
+	struct tsn_list *list = container_of(hrt, struct tsn_list, tsn_timer);
+	if (!tsn_core_running(list))
+		return HRTIMER_NORESTART;
+
+	hrtimer_forward_now(hrt, ns_to_ktime(list->period_ns));
+
+	/* tsn_thread ready? */
+	if (tsn_core_running(list)) {
+		/* kick worker */
+		list->should_run++;
+		if (list->tsn_thread != TASK_RUNNING)
+			wake_up_process(list->tsn_thread);
+	}
+
+	return HRTIMER_RESTART;
+}
+
+static long tsn_hrtimer_init(struct tsn_list *list)
+{
+	/* Run every 1ms, _tsn_send_batch will figure out how many
+	 * frames to send for active frames
+	 */
+	hrtimer_init(&list->tsn_timer, CLOCK_MONOTONIC,
+		     HRTIMER_MODE_REL | HRTIMER_MODE_PINNED);
+
+	list->tsn_timer.function = tsn_hrtimer_callback;
+	hrtimer_cancel(&list->tsn_timer);
+
+	hrtimer_start(&list->tsn_timer, ns_to_ktime(list->period_ns),
+		      HRTIMER_MODE_REL);
+
+	atomic_set(&list->running, 1);
+	return 0;
+}
+
+static void tsn_hrtimer_exit(struct tsn_list *list)
+{
+	atomic_set(&list->running, 0);
+	hrtimer_cancel(&list->tsn_timer);
+}
+
+int tsn_set_shim_ops(struct tsn_link *link, struct tsn_shim_ops *shim_ops)
+{
+	if (!link)
+		return -EINVAL;
+	if (tsn_link_is_on(link))
+		return -EINVAL;
+
+	tsn_lock(link);
+	link->ops = shim_ops;
+	tsn_unlock(link);
+	return 0;
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
+int tsn_prepare_link(struct tsn_link *link)
+{
+	int ret = 0;
+	void *buffer;
+	struct net_device *netdev;
+
+	/* TODO: use separate buckets (lists/rbtrees/whatever) for
+	 * SR_CLASS_A and SR_CLASS_B talker streams. hrtimer-callback should
+	 * not iterate over all.
+	 */
+
+	if (!link || !link->ops) {
+		pr_err("TSN ERROR: link (%p) or link->ops (%p) not set\n",
+		       link, link ? link->ops : NULL);
+		return -EINVAL;
+	}
+
+
+	/* configure will calculate idle_slope based on framesize
+	 * (header + payload)
+	 *
+	 * Only do this if NIC is capable (ie, in_debug and a standard NIC)
+	 */
+	netdev = link->nic->dev;
+	if (link->nic->capable) {
+		pr_info("NIC has tsn_link_configre()\n");
+		tsn_lock(link);
+		ret = netdev->netdev_ops->ndo_tsn_link_configure(netdev, link->class,
+								 tsnh_frame_len(link), link->vlan_id & 0xfff, 1, link->nic->pcp_a, link->nic->pcp_b);
+		tsn_unlock(link);
+		/* NICs that have TSN support but has not enabled it
+		 * will fail at this stage when we load tsn with
+		 * in_debug=1.
+		 */
+		if (ret < 0)
+			goto err_out;
+	}
+
+	ret = link->ops->probe(link);
+	if (ret != 0) {
+		pr_err("%s: Could not probe shim (%d), cannot create link\n",
+		       __func__, ret);
+		goto err_out;
+	}
+
+	if (!link->external_buffer) {
+		pr_info("TSN: allocating buffer, %zd bytes\n", link->buffer_size);
+		buffer = kmalloc(link->buffer_size, GFP_KERNEL);
+		if (!buffer) {
+			pr_err("%s: Could not allocate memory (%zu) for buffer\n",
+			       __func__, link->buffer_size);
+			ret = -ENOMEM;
+			goto err_out;
+		}
+
+		tsn_lock(link);
+		ret = _tsn_set_buffer(link, buffer, link->buffer_size);
+		tsn_unlock(link);
+		if (ret != 0) {
+			pr_err("%s: Could not set buffer for TSN, got %d\n",
+			       __func__, ret);
+			goto err_out;
+		}
+	} else {
+		/* FIXME: not handled */
+		pr_info("TSN does not currently handle externally hosted buffers. This is on the TODO-list\n");
+		ret = -EINVAL;
+		goto err_out;
+	}
+
+	pr_info("Link is ready, marking it ON\n");
+	tsn_link_on(link);
+	return 0;
+
+err_out:
+	tsn_lock(link);
+	link->ops = NULL;
+	tsn_unlock(link);
+	pr_info("%s: FAILED - ret=%d\n", __func__, ret);
+	return ret;
+}
+
+int tsn_teardown_link(struct tsn_link *link)
+{
+	struct net_device *netdev;
+	u64 frames_sent;
+	int ret = 0;
+
+	if (!link)
+		return -EINVAL;
+
+	/* Careful dance, we currently grab this lock from hrtimer, so
+	 * make sure we grab the lock and disable the link quickly
+	 */
+	tsn_lock(link);
+	tsn_link_off(link);
+	tsn_lb_disable(link);
+	tsn_unlock(link);
+
+	/* Need to call media_close() without (spin-)locks held */
+	if (link->ops && link->ops->media_close)
+		link->ops->media_close(link);
+
+	/* we can now grab the link and not worry about blocking hrtimer
+	 * callback as link has been disabled, i.e. we will stop sending frames to the network layer
+	 */
+	pr_info("%s: closed shim, dropping rest of link\n", __func__);
+	tsn_lock(link);
+
+	if (!link->nic) {
+		pr_err("ERROR %s: link link->nic (%p) got yanked away, cannot tear down link properly\n",
+			__func__, link->nic);
+		tsn_unlock(link);
+		return 0;
+	}
+
+	netdev = link->nic->dev;
+	if (netdev->netdev_ops->ndo_tsn_link_configure) {
+		/* NOTE: this needs to be serialized
+		 */
+		ret = netdev->netdev_ops->ndo_tsn_link_configure(netdev, link->class, tsnh_frame_len(link), link->vlan_id & 0XFFF, 0, link->nic->pcp_a, link->nic->pcp_b);
+		if (ret < 0)
+			pr_err("Could not de-configure link - %d\n", ret);
+	}
+	frames_sent = link->frames_sent;
+	link->frames_sent = 0;
+	link->ops = NULL;
+	_tsn_free_buffer(link);
+	tsn_unlock(link);
+
+	pr_info("%s: disabling all parts of link, %llu frames sent in total\n", __func__, frames_sent);
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
+		return "None";
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
+	if (!page)
+		return 0;
+	res += snprintf((page + res), PAGE_SIZE - res, "none\n");
+	if (!list_empty(&tsn_shim_ops)) {
+		list_for_each_entry(ops, &tsn_shim_ops, head) {
+			res += snprintf((page + res), PAGE_SIZE - res, "%s\n",
+					ops->shim_name);
+		}
+	}
+	return res;
+}
+
+void tsn_lock_init(struct tsn_link *link)
+{
+	spin_lock_init(&link->tlock);
+	link->lflags = 0;
+	raw_spin_lock_init(&link->llock);
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
+	tsn_lock_init(link);
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
+	link->class = SR_CLASS_B;
+
+	link->buffer_size = 16536;
+	/* default: talker since listener isn't implemented yet. */
+	link->estype_talker = 1;
+
+	link->nic = nic;
+
+	link->ts_net_ns = ktime_to_ns(ktime_get());
+	link->ts_delta_ns = 250000; /* initial class i B */
+	link->ts_exp_alpha = 13107;	/* ~80% */
+
+	/* Add the newly created link to the hashmap of all active links.
+	 *
+	 * test if sid is present in hashmap already (barf on that)
+	 */
+
+	tsn_list_lock(&tlist);
+	hash_add(tlinks, &link->node, link->stream_id);
+	tsn_list_unlock(&tlist);
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
+	tsn_list_lock(&tlist);
+	hash_del(&link->node);
+	if (link->ops) {
+		link->ops->media_close(link);
+		link->ops = NULL;
+	}
+
+	tsn_list_unlock(&tlist);
+}
+
+void tsn_remove_and_free_link(struct tsn_link *link)
+{
+	if (!link)
+		return;
+	tsn_remove_link(link);
+	kfree(link);
+}
+
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
+	return -EINVAL;
+	if (!nic || !netdev || !netdev->netdev_ops ||
+	    !netdev->netdev_ops->ndo_tsn_capable)
+		return -EINVAL;
+
+	if (netdev->netdev_ops->ndo_tsn_capable(netdev) > 0)
+		nic->capable = 1;
+
+	pr_info("%s: ndo_tsn_capable() present, got %s\n", __func__, nic->capable ? "Capable" : "Not capable");
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
+
+		/* GFP_KERNEL is preferred, but we are in rcu_read_lock()-region */
+		nic = kzalloc(sizeof(*nic), GFP_ATOMIC);
+
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
+		/* This is the default values for A and B specified in 802.1Q */
+		nic->pcp_a = 3;
+		nic->pcp_b = 2;
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
+		tsn_list_lock(&tlist);
+		list_add_tail(&nic->list, &tlist.head);
+		tlist.num_avail++;
+		tsn_list_unlock(&tlist);
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
+	tsn_list_lock(list);
+	list_for_each_entry_safe(tmp, next, &list->head, list) {
+		pr_info("Dropping %s from list\n", tmp->dev->name);
+		list_del(&tmp->list);
+		tmp->dev = NULL;
+		kfree(tmp);
+	}
+	tsn_list_unlock(list);
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
+		if (!tsn_teardown_link(link)) {
+			tsn_lock(link);
+
+			tsn_unlock(link);
+		}
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
+	spin_lock_init(&tlist.lock);
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
+			__func__, ret);
+		goto error_cfs_out;
+	}
+	pr_info("%s: configfs created\n", __func__);
+
+	/* creating worker and thread.
+	 * hrtimer_init will wake tsn_worker when timer is ready
+	 *
+	 * FIXME: make it possible to pin both timer and worker to a
+	 * specific core.
+	 */
+	tlist.should_run = 0;
+	ret = tsn_worker_init(&tlist);
+	if (ret < 0) {
+		pr_err("Failed to create tsn_worker!\n");
+		goto error_hrt_out;
+	}
+
+	ret = tsn_hrtimer_init(&tlist);
+	if (ret < 0) {
+		pr_err("%s: could not init hrtimer properly, aborting\n",
+			__func__);
+		goto error_thread_out;
+	}
+
+	pr_info("TSN subsystem init OK\n");
+	return 0;
+
+error_thread_out:
+	tsn_worker_exit(&tlist);
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
+
+	tsn_worker_exit(&tlist);
+
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
index 0000000..1840783
--- /dev/null
+++ b/net/tsn/tsn_header.c
@@ -0,0 +1,162 @@
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
+	header->subtype = TSN_EF_STREAM;
+
+	header->version = 0;
+	return 0;
+}
+
+
+int tsnh_validate_du_header(struct tsn_link *link, struct avtp_ch *ch,
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
+	 * user could fake this), but it should remove accidents and
+	 * errors.
+	 */
+	sll = (struct sockaddr_ll *)&skb->cb;
+	sll->sll_halen = dev_parse_header(skb, sll->sll_addr);
+	if (sll->sll_halen != 6)
+		return -EPROTO;
+	if (memcmp(link->remote_mac, &sll->sll_addr, 6))
+		return -EPROTO;
+
+	/* Current iteration of TSN has version 0b000 only */
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
+	 * we don't. Shim should handle missing frames should they occur
+	 *
+	 * (TODO: need to propagate seqnr to shim)
+	 */
+	seqnr = (link->last_seqnr + 1) & 0xff;
+	if (header->seqnr != seqnr)
+		return -EPROTO;
+
+	bytes = ntohs(header->sd_len);
+	if (bytes == 0 || bytes > link->max_payload_size)
+		return -EINVAL;
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
+	if (!link->ops) {
+		pr_err("%s: No available ops, cannot assemble data-unit\n",
+		       __func__);
+		return  -EINVAL;
+	}
+
+	header->stream_id = cpu_to_be64(link->stream_id);
+	header->seqnr = link->last_seqnr++;
+	link->ops->assemble_header(link, header, bytes);
+
+	return 0;
+}
+
+int tsnh_handle_du(struct tsn_link *link, struct avtp_ch *ch)
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
+	if (ret != bytes)
+		return ret;
+
+	return 0;
+}
diff --git a/net/tsn/tsn_internal.h b/net/tsn/tsn_internal.h
new file mode 100644
index 0000000..41e1775
--- /dev/null
+++ b/net/tsn/tsn_internal.h
@@ -0,0 +1,397 @@
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
+ * tsn_remove_and_free_link: remove link and remove it from the list
+ *
+ * @param: the link to completely remove
+ */
+void tsn_remove_and_free_link(struct tsn_link *link);
+
+/**
+ * tsn_set_shim_ops - tie a shim to a link
+ *
+ * This will just set the shim-ops in the link.
+ *
+ * @link: active link
+ * @shim_ops: the shim to associate with this link
+ * @return: 0 on success, negative on error
+ */
+int tsn_set_shim_ops(struct tsn_link *link, struct tsn_shim_ops *shim_ops);
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
+ * @return 0 on success, negative on error
+ */
+int tsn_prepare_link(struct tsn_link *link);
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
+	return (u16)tsnh_len() + VLAN_ETH_HLEN;
+}
+
+static inline u16 tsnh_frame_len(struct tsn_link *link)
+{
+	if (!link)
+		return 0;
+	pr_info("max_payload_size=%u, shim_header_size=%u, tsnh_len_all()=%u\n",
+		link->max_payload_size, link->shim_header_size, tsnh_len_all());
+	return link->max_payload_size + link->shim_header_size + tsnh_len_all();
+}
+
+static inline u16 tsnh_data_len(struct avtpdu_header *header)
+{
+	if (!header)
+		return 0;
+	return ntohs(header->sd_len);
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
+ * tsnh_validate_du_header - basic header validation
+ *
+ * This expects the parameters to be present and the link-lock to be
+ * held.
+ *
+ * @param header header to verify
+ * @param link owner of stream
+ * @param socket_buffer
+ * @return 0 on valid, negative on invalid/error
+ */
+int tsnh_validate_du_header(struct tsn_link *link, struct avtp_ch *ch,
+			    struct sk_buff *skb);
+
+/**
+ * tsnh_assemble_du - assemble header and copy data from buffer
+ *
+ * It expects tsn-lock to be held when called
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
+ * tsnh_handle_du - handle incoming data and store to media-buffer
+ *
+ * This assumes that the frame actually belongs to the link and that it
+ * has passed basic validation. It expects the link-lock to be held.
+ *
+ * @param link    Link associated with stream_id
+ * @param header  Header of incoming frame
+ * @return number of bytes copied to buffer or negative on error
+ */
+int tsnh_handle_du(struct tsn_link *link, struct avtp_ch *ch);
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
+ *
+ * @returns then number of frames sent or negative on error
+ */
+int tsn_net_send_set(struct tsn_link *link, size_t num, u64 ts_base_ns,
+		     u64 ts_delta_ns);
+
+#endif	/* _TSN_INTERNAL_H_ */
diff --git a/net/tsn/tsn_net.c b/net/tsn/tsn_net.c
new file mode 100644
index 0000000..214c0d6
--- /dev/null
+++ b/net/tsn/tsn_net.c
@@ -0,0 +1,392 @@
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
+ * When registered, it will consume all TSN-tagged frames belonging to
+ * registered Stream IDs.
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
+	if (!tsn_link_is_on(link) || link->estype_talker)
+		goto out_unlock;
+
+	/* If link->ops is not set yet, there's nothing we can do, just
+	 * ignore this frame
+	 */
+	if (!link->ops)
+		goto out_unlock;
+
+	if (tsnh_validate_du_header(link, ch, skb))
+		goto out_unlock;
+
+	/* Update link network time
+	 *
+	 * TODO: using the time in the skb is flawed, we should use
+	 * actual time from the NIC and then correlate that to timestamp
+	 * in frame.
+	 */
+	tsn_update_net_time(link, ktime_to_ns(skb_get_ktime(skb)), 1);
+	trace_tsn_rx_handler(link, ethhdr, be64_to_cpu(ch->stream_id));
+
+	/* Handle dataunit, if it failes, pass on the frame and let
+	 * userspace pick it up.
+	 */
+	if (tsnh_handle_du(link, ch) < 0)
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
+	tsn_list_lock(tlist);
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
+	tsn_list_unlock(tlist);
+	return 0;
+}
+
+void tsn_net_remove_rx(struct tsn_list *tlist)
+{
+	struct tsn_nic *nic;
+
+	if (!tlist)
+		return;
+	tsn_list_lock(tlist);
+	list_for_each_entry(nic, &tlist->head, list) {
+		rtnl_lock();
+		if (nic->rx_registered)
+			netdev_rx_handler_unregister(nic->dev);
+		rtnl_unlock();
+		nic->rx_registered = 0;
+		pr_info("%s: RX-handler for %s removed\n",
+			__func__, nic->name);
+	}
+	tsn_list_unlock(tlist);
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
+	tsn_list_lock(tlist);
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
+	tsn_list_unlock(tlist);
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
+	tsn_list_lock(tlist);
+	list_for_each_entry(nic, &tlist->head, list) {
+		if (nic->capable && nic->dma_mem) {
+			dev = nic->dev->dev.parent;
+			dma_free_coherent(dev, nic->dma_size, nic->dma_mem,
+					  nic->dma_handle);
+			res++;
+		}
+	}
+	tsn_list_unlock(tlist);
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
+static inline u16 _get_8021q_vid(struct tsn_link *link)
+{
+	u16 pcp = sr_class_to_pcp(link->nic, link->class);
+	/* If not explicitly provided, use SR_PVID 0x2*/
+	return (link->vlan_id & VLAN_VID_MASK) | ((pcp & 0x7) << 13);
+}
+
+static u16 __tsn_pick_tx(struct net_device *dev, struct sk_buff *skb)
+{
+	printk_once(KERN_ERR "TSN ERROR: sending frame via NIC without valid ndo_select_queue, defaulting to tx-ring 0\n");
+	return 0;
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
+					  u64 ts_pres_ns)
+{
+	struct sk_buff *skb = NULL;
+	struct avtpdu_header *avtpdu;
+	struct net_device *dev = link->nic->dev;
+	int res = 0;
+	u16 queue_index = 0;
+	size_t hdr_len = VLAN_ETH_HLEN;
+	size_t avtpdu_len = tsnh_len() + shim_hdr_size;
+	u16 vlan_tci = _get_8021q_vid(link);
+
+	if (data_bytes > link->used_buffer_size) {
+		printk_once(KERN_ERR "%s: data_bytes (%zu) exceed buffer-size (%zd), reducing size\n",
+			__func__,data_bytes, link->used_buffer_size);
+		data_bytes = link->used_buffer_size;
+	}
+
+	skb = alloc_skb(hdr_len + avtpdu_len + data_bytes + dev->needed_tailroom,
+			GFP_ATOMIC);
+	if (!skb)
+		return NULL;
+
+	skb_reserve(skb, hdr_len + avtpdu_len);
+	skb->dev = link->nic->dev;
+	skb_reset_mac_header(skb);
+	skb->network_header = skb->mac_header + VLAN_ETH_HLEN;
+	skb->priority = sr_class_to_pcp(link->nic, link->class);
+
+	/* copy shim-data
+	 *
+	 * This all hinges on that the shim-header size is set correctly
+	 * via configfs, if that value is off, then this will fall
+	 * apart.
+	 */
+	res = tsn_buffer_read_net(link, skb_put(skb, data_bytes), data_bytes);
+	if (res != data_bytes) {
+		pr_err("%s: Could not copy %zd bytes of data. Res: %d\n",
+		       __func__, data_bytes, res);
+		kfree_skb(skb);
+		return NULL;
+	}
+
+	/* set avtpdu- && shim-header.
+	 * data_bytes is requried to set fields of header correctly
+	 */
+	avtpdu = (struct avtpdu_header *)skb_push(skb, avtpdu_len);
+	res = tsnh_assemble_du(link, avtpdu, data_bytes, ts_pres_ns);
+	if (res < 0) {
+		pr_err("%s: Error initializing header (-> %d) , we are in an inconsistent state!\n",
+		       __func__, res);
+		kfree_skb(skb);
+		return NULL;
+	}
+
+	/* set ethenet header */
+	res = skb_vlan_push(skb, htons(ETH_P_8021Q), vlan_tci);
+	if (res) {
+		pr_err("%s: could not insert tag (0x%04x) && proto (0x%04x) in buffer, aborting -> %d\n",
+		       __func__, vlan_tci, htons(ETH_P_8021Q), res);
+		return NULL;
+	}
+
+	skb->protocol = htons(ETH_P_TSN);
+	skb->pkt_type = PACKET_OUTGOING;
+
+	skb_shinfo(skb)->tx_flags |= SKBTX_HW_TSTAMP;
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
+	if (!dev_hard_header(skb, skb->dev, ETH_P_TSN, link->remote_mac, NULL, 6)) {
+		pr_err("%s: could not copy remote MAC to ether-frame\n", __func__);
+		kfree(skb);
+		return NULL;
+	}
+
+	/* Set txqueue, must set queue_mapping, via ndo_select_queue */
+	if (dev->netdev_ops->ndo_select_queue)
+		queue_index = dev->netdev_ops->ndo_select_queue(dev, skb, NULL, __tsn_pick_tx);
+	queue_index = netdev_cap_txqueue(dev, queue_index);
+	skb_set_queue_mapping(skb, queue_index);
+
+	skb->csum = skb_checksum(skb, 0, hdr_len + data_bytes, 0);
+	return skb;
+}
+
+/**
+ * Send a set of frames as efficiently as possible
+ */
+int tsn_net_send_set(struct tsn_link *link, size_t num, u64 ts_base_ns,
+		u64 ts_delta_ns)
+{
+	struct sk_buff *skb;
+	struct net_device *dev;
+	size_t data_size;
+	int res;
+	size_t sent = 0;
+	u64 ts_pres_ns = ts_base_ns;
+
+	if (!link)
+		return -EINVAL;
+	dev = link->nic->dev;
+
+	while (sent < num) {
+		data_size = tsn_shim_get_framesize(link);
+		skb = _skbuf_create_init(link, data_size,
+					tsn_shim_get_hdr_size(link),
+					ts_pres_ns);
+		if (!skb) {
+			pr_err("%s: could not allocate memory for skb\n",
+				__func__);
+			return -ENOMEM;
+		}
+
+
+		trace_tsn_pre_tx(link, skb, data_size);
+		res = dev_queue_xmit(skb);
+		if (res != NET_XMIT_SUCCESS) {
+			printk_once(KERN_WARNING "TSN ERROR: dev_queue_xmit() FAILED -> %d\n", res);
+			return sent;
+		}
+		ts_pres_ns += ts_delta_ns;
+		sent++;
+	}
+	trace_tsn_post_tx_set(link, sent);
+	return sent;
+}
-- 
2.7.4
