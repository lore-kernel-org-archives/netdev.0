From: Leon Romanovsky <leonro@mellanox.com>
Subject: [PATCH v4 iproute2 3/7] rdma: Add link object
Date: Tue, 15 Aug 2017 16:00:16 +0300
Message-ID: <20170815130020.29509-4-leonro@mellanox.com>
References: <20170815130020.29509-1-leonro@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:53978 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751568AbdHONAi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 09:00:38 -0400
In-Reply-To: <20170815130020.29509-1-leonro@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Link (port) object represent struct ib_port to the user space.

Link properties:
 * Port capabilities
 * IB subnet prefix
 * LID, SM_LID and LMC
 * Port state
 * Physical state

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 rdma/Makefile |   2 +-
 rdma/link.c   | 274 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rdma/rdma.c   |   3 +-
 rdma/utils.c  |   5 ++
 4 files changed, 282 insertions(+), 2 deletions(-)
 create mode 100644 rdma/link.c

diff --git a/rdma/Makefile b/rdma/Makefile
index 123d7ac5..1a9e4b1a 100644
--- a/rdma/Makefile
+++ b/rdma/Makefile
@@ -2,7 +2,7 @@ include ../Config
 
 ifeq ($(HAVE_MNL),y)
 
-RDMA_OBJ = rdma.o utils.o dev.o
+RDMA_OBJ = rdma.o utils.o dev.o link.o
 
 TARGETS=rdma
 CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
diff --git a/rdma/link.c b/rdma/link.c
new file mode 100644
index 00000000..51858965
--- /dev/null
+++ b/rdma/link.c
@@ -0,0 +1,274 @@
+/*
+ * link.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
+ */
+
+#include "rdma.h"
+
+static int link_help(struct rd *rd)
+{
+	pr_out("Usage: %s link show [DEV/PORT_INDEX]\n", rd->filename);
+	return 0;
+}
+
+static const char *caps_to_str(uint32_t idx)
+{
+	uint64_t cap = 1 << idx;
+
+	switch (cap) {
+	case RDMA_PORT_SM: return "SM";
+	case RDMA_PORT_NOTICE: return "NOTICE";
+	case RDMA_PORT_TRAP: return "TRAP";
+	case RDMA_PORT_OPT_IPD: return "OPT_IPD";
+	case RDMA_PORT_AUTO_MIGR: return "AUTO_MIG";
+	case RDMA_PORT_SL_MAP: return "SL_MAP";
+	case RDMA_PORT_MKEY_NVRAM: return "MKEY_NVRAM";
+	case RDMA_PORT_PKEY_NVRAM: return "PKEY_NVRAM";
+	case RDMA_PORT_LED_INFO: return "LED_INFO";
+	case RDMA_PORT_SM_DISABLED: return "SM_DISABLED";
+	case RDMA_PORT_SYS_IMAGE_GUID: return "SYS_IMAGE_GUID";
+	case RDMA_PORT_PKEY_SW_EXT_PORT_TRAP: return "PKEY_SW_EXT_PORT_TRAP";
+	case RDMA_PORT_EXTENDED_SPEEDS: return "EXTENDED_SPEEDS";
+	case RDMA_PORT_CM: return "CM";
+	case RDMA_PORT_SNMP_TUNNEL: return "SNMP_TUNNEL";
+	case RDMA_PORT_REINIT: return "REINIT";
+	case RDMA_PORT_DEVICE_MGMT: return "DEVICE_MGMT";
+	case RDMA_PORT_VENDOR_CLASS: return "VENDOR_CLASS";
+	case RDMA_PORT_DR_NOTICE: return "PORT_DR_NOTICE";
+	case RDMA_PORT_CAP_MASK_NOTICE: return "CAP_MASK_NOTICE";
+	case RDMA_PORT_BOOT_MGMT: return "BOOT_MGMT";
+	case RDMA_PORT_LINK_LATENCY: return "LINK_LATENCY";
+	case RDMA_PORT_CLIENT_REG: return "CLIENT_REG";
+	case RDMA_PORT_IP_BASED_GIDS: return "IP_BASED_GIDS";
+	default: return "UKNOWN";
+	}
+};
+
+static void link_print_caps(struct nlattr **tb)
+{
+	uint64_t caps;
+	uint32_t idx;
+
+	if (!tb[RDMA_NLDEV_ATTR_CAP_FLAGS])
+		return;
+
+	caps = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_CAP_FLAGS]);
+
+	pr_out("\n    caps: <");
+	for (idx = 0; caps; idx++) {
+		if (caps & 0x1) {
+			pr_out("%s", caps_to_str(idx));
+			if (caps >> 0x1)
+				pr_out(", ");
+		}
+		caps >>= 0x1;
+	}
+
+	pr_out(">");
+}
+
+static void link_print_subnet_prefix(struct nlattr **tb)
+{
+	uint64_t subnet_prefix;
+
+	if (!tb[RDMA_NLDEV_ATTR_SUBNET_PREFIX])
+		return;
+
+	subnet_prefix = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_SUBNET_PREFIX]);
+	rd_print_u64("subnet_prefix", subnet_prefix);
+}
+
+static void link_print_lid(struct nlattr **tb)
+{
+	if (!tb[RDMA_NLDEV_ATTR_LID])
+		return;
+
+	pr_out("lid %u ",
+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_LID]));
+}
+
+static void link_print_sm_lid(struct nlattr **tb)
+{
+	if (!tb[RDMA_NLDEV_ATTR_SM_LID])
+		return;
+
+	pr_out("sm_lid %u ",
+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_SM_LID]));
+}
+
+static void link_print_lmc(struct nlattr **tb)
+{
+	if (!tb[RDMA_NLDEV_ATTR_LMC])
+		return;
+
+	pr_out("lmc %u ", mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_LMC]));
+}
+
+static const char *link_state_to_str(uint8_t link_state)
+{
+	switch (link_state) {
+	case RDMA_LINK_STATE_NOP: return "NOP";
+	case RDMA_LINK_STATE_DOWN: return "DOWN";
+	case RDMA_LINK_STATE_INIT: return "INIT";
+	case RDMA_LINK_STATE_ARMED: return "ARMED";
+	case RDMA_LINK_STATE_ACTIVE: return "ACTIVE";
+	case RDMA_LINK_STATE_ACTIVE_DEFER: return "ACTIVE_DEFER";
+	default: return "UKNOWN";
+	}
+};
+
+static void link_print_state(struct nlattr **tb)
+{
+	uint8_t state;
+
+	if (!tb[RDMA_NLDEV_ATTR_PORT_STATE])
+		return;
+
+	state = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_PORT_STATE]);
+	pr_out("state %s ", link_state_to_str(state));
+}
+
+static const char *phys_state_to_str(uint8_t phys_state)
+{
+	switch (phys_state) {
+	case RDMA_LINK_PHYS_STATE_SLEEP: return "SLEEP";
+	case RDMA_LINK_PHYS_STATE_POLLING: return "POLLING";
+	case RDMA_LINK_PHYS_STATE_DISABLED: return "DISABLED";
+	case RDMA_LINK_PHYS_STATE_PORT_CONFIGURATION_TRAINING: return "ARMED";
+	case RDMA_LINK_PHYS_STATE_LINK_UP: return "LINK_UP";
+	case RDMA_LINK_PHYS_STATE_LINK_ERROR_RECOVER:
+						return "LINK_ERROR_RECOVER";
+	case RDMA_LINK_PHYS_STATE_LINK_PHY_TEST: return "PHY_TEST";
+	default: return "UKNOWN";
+	}
+};
+
+static void link_print_phys_state(struct nlattr **tb)
+{
+	uint8_t phys_state;
+
+	if (!tb[RDMA_NLDEV_ATTR_PORT_PHYS_STATE])
+		return;
+
+	phys_state = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_PORT_PHYS_STATE]);
+	pr_out("physical_state %s ", phys_state_to_str(phys_state));
+}
+
+static int link_parse_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
+	struct rd *rd = data;
+
+	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
+	if (!tb[RDMA_NLDEV_ATTR_DEV_INDEX] || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
+		return MNL_CB_ERROR;
+
+	if (!tb[RDMA_NLDEV_ATTR_PORT_INDEX]) {
+		pr_err("This tool doesn't support switches yet\n");
+		return MNL_CB_ERROR;
+	}
+
+	pr_out("%u/%u: %s/%u: ",
+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]),
+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]),
+	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]),
+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]));
+	link_print_subnet_prefix(tb);
+	link_print_lid(tb);
+	link_print_sm_lid(tb);
+	link_print_lmc(tb);
+	link_print_state(tb);
+	link_print_phys_state(tb);
+	if (rd->show_details)
+		link_print_caps(tb);
+
+	pr_out("\n");
+	return MNL_CB_OK;
+}
+
+static int link_no_args(struct rd *rd)
+{
+	uint32_t seq;
+	int ret;
+
+	rd_prepare_msg(rd, RDMA_NLDEV_CMD_PORT_GET, &seq,
+		       (NLM_F_REQUEST | NLM_F_ACK));
+	mnl_attr_put_u32(rd->nlh, RDMA_NLDEV_ATTR_DEV_INDEX, rd->dev_idx);
+	mnl_attr_put_u32(rd->nlh, RDMA_NLDEV_ATTR_PORT_INDEX, rd->port_idx);
+	ret = rd_send_msg(rd);
+	if (ret)
+		return ret;
+
+	return rd_recv_msg(rd, link_parse_cb, rd, seq);
+}
+
+static int link_one_show(struct rd *rd)
+{
+	const struct rd_cmd cmds[] = {
+		{ NULL,		link_no_args},
+		{ 0 }
+	};
+
+	return rd_exec_cmd(rd, cmds, "parameter");
+}
+
+static int link_show(struct rd *rd)
+{
+	struct dev_map *dev_map;
+	uint32_t port;
+	int ret;
+
+	if (rd_no_arg(rd)) {
+		list_for_each_entry(dev_map, &rd->dev_map_list, list) {
+			rd->dev_idx = dev_map->idx;
+			for (port = 1; port < dev_map->num_ports + 1; port++) {
+				rd->port_idx = port;
+				ret = link_one_show(rd);
+				if (ret)
+					return ret;
+			}
+		}
+
+	} else {
+		dev_map = dev_map_lookup(rd, true);
+		port = get_port_from_argv(rd);
+		if (!dev_map || port > dev_map->num_ports) {
+			pr_err("Wrong device name\n");
+			return -ENOENT;
+		}
+		rd_arg_inc(rd);
+		rd->dev_idx = dev_map->idx;
+		rd->port_idx = port ? : 1;
+		for (; rd->port_idx < dev_map->num_ports + 1; rd->port_idx++) {
+			ret = link_one_show(rd);
+			if (ret)
+				return ret;
+			if (port)
+				/*
+				 * We got request to show link for devname
+				 * with port index.
+				 */
+				break;
+		}
+	}
+	return 0;
+}
+
+int cmd_link(struct rd *rd)
+{
+	const struct rd_cmd cmds[] = {
+		{ NULL,		link_show },
+		{ "show",	link_show },
+		{ "list",	link_show },
+		{ "help",	link_help },
+		{ 0 }
+	};
+
+	return rd_exec_cmd(rd, cmds, "link command");
+}
diff --git a/rdma/rdma.c b/rdma/rdma.c
index 9c2bdc8f..74c09e8b 100644
--- a/rdma/rdma.c
+++ b/rdma/rdma.c
@@ -15,7 +15,7 @@
 static void help(char *name)
 {
 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
-	       "where  OBJECT := { dev | help }\n"
+	       "where  OBJECT := { dev | link | help }\n"
 	       "       OPTIONS := { -V[ersion] | -d[etails]}\n", name);
 }
 
@@ -31,6 +31,7 @@ static int rd_cmd(struct rd *rd)
 		{ NULL,		cmd_help },
 		{ "help",	cmd_help },
 		{ "dev",	cmd_dev },
+		{ "link",	cmd_link },
 		{ 0 }
 	};
 
diff --git a/rdma/utils.c b/rdma/utils.c
index 0e32eefe..91d05271 100644
--- a/rdma/utils.c
+++ b/rdma/utils.c
@@ -107,6 +107,11 @@ static const enum mnl_attr_data_type nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
 	[RDMA_NLDEV_ATTR_FW_VERSION] = MNL_TYPE_NUL_STRING,
 	[RDMA_NLDEV_ATTR_NODE_GUID] = MNL_TYPE_U64,
 	[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID] = MNL_TYPE_U64,
+	[RDMA_NLDEV_ATTR_LID] = MNL_TYPE_U32,
+	[RDMA_NLDEV_ATTR_SM_LID] = MNL_TYPE_U32,
+	[RDMA_NLDEV_ATTR_LMC] = MNL_TYPE_U8,
+	[RDMA_NLDEV_ATTR_PORT_STATE] = MNL_TYPE_U8,
+	[RDMA_NLDEV_ATTR_PORT_PHYS_STATE] = MNL_TYPE_U8,
 	[RDMA_NLDEV_ATTR_DEV_NODE_TYPE] = MNL_TYPE_U8,
 };
 
-- 
2.14.0
