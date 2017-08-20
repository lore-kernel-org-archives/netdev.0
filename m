From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH v6 iproute2 4/8] rdma: Add link object
Date: Sun, 20 Aug 2017 12:58:24 +0300
Message-ID: <20170820095828.13812-5-leon@kernel.org>
References: <20170820095828.13812-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        David Laight <David.Laight@ACULAB.COM>,
        Linux Netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:49152 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752378AbdHTJ6m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 20 Aug 2017 05:58:42 -0400
In-Reply-To: <20170820095828.13812-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

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
 rdma/link.c   | 277 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rdma/rdma.c   |   3 +-
 rdma/utils.c  |   5 ++
 4 files changed, 285 insertions(+), 2 deletions(-)
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
index 00000000..b0e5bee0
--- /dev/null
+++ b/rdma/link.c
@@ -0,0 +1,277 @@
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
+#define RDMA_PORT_FLAGS(x) \
+	x(SM, 1) \
+	x(NOTICE, 2) \
+	x(TRAP, 3) \
+	x(OPT_IPD, 4) \
+	x(AUTO_MIGR, 5) \
+	x(SL_MAP, 6) \
+	x(MKEY_NVRAM, 7) \
+	x(PKEY_NVRAM, 8) \
+	x(LED_INFO, 9) \
+	x(SM_DISABLED, 10) \
+	x(SYS_IMAGE_GUIG, 11) \
+	x(PKEY_SW_EXT_PORT_TRAP, 12) \
+	x(EXTENDED_SPEEDS, 14) \
+	x(CM, 16) \
+	x(SNMP_TUNNEL, 17) \
+	x(REINIT, 18) \
+	x(DEVICE_MGMT, 19) \
+	x(VENDOR_CLASS, 20) \
+	x(DR_NOTICE, 21) \
+	x(CAP_MASK_NOTICE, 22) \
+	x(BOOT_MGMT, 23) \
+	x(LINK_LATENCY, 24) \
+	x(CLIENT_REG, 23) \
+	x(IP_BASED_GIDS, 26)
+
+	enum { RDMA_PORT_FLAGS(RDMA_BITMAP_ENUM) };
+
+	static const char * const
+		rdma_port_names[] = { RDMA_PORT_FLAGS(RDMA_BITMAP_NAMES) };
+	#undef RDMA_PORT_FLAGS
+
+	if (idx < ARRAY_SIZE(rdma_port_names) && rdma_port_names[idx])
+		return rdma_port_names[idx];
+	return "UNKNOWN";
+}
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
+	static const char * const link_state_str[] = { "NOP", "DOWN",
+						       "INIT", "ARMED",
+						       "ACTIVE",
+						       "ACTIVE_DEFER" };
+	if (link_state < ARRAY_SIZE(link_state_str))
+		return link_state_str[link_state];
+	return "UNKNOWN";
+}
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
+	static const char * const phys_state_str[] = { "NOP", "SLEEP",
+						       "POLLING", "DISABLED",
+						       "ARMED", "LINK_UP",
+						       "LINK_ERROR_RECOVER",
+						       "PHY_TEST", "UNKNOWN",
+						       "OPA_OFFLINE",
+						       "UNKNOWN", "OPA_TEST" };
+	if (phys_state < ARRAY_SIZE(phys_state_str))
+		return phys_state_str[phys_state];
+	return "UNKNOWN";
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
2.14.1
