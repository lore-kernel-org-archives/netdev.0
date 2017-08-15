From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v4 iproute2 2/7] rdma: Add dev object
Date: Tue, 15 Aug 2017 16:00:15 +0300
Message-ID: <20170815130020.29509-3-leonro@mellanox.com>
References: <20170815130020.29509-1-leonro@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170815130020.29509-1-leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Device (dev) object represents struct ib_device to the user space.

Device properties:
 * Device capabilities
 * FW version to the device output
 * node_guid and sys_image_guid
 * node_type

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 rdma/Makefile |   2 +-
 rdma/dev.c    | 227 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rdma/rdma.c   |   3 +-
 rdma/rdma.h   |  13 ++++
 rdma/utils.c  |  54 +++++++++++++-
 5 files changed, 296 insertions(+), 3 deletions(-)
 create mode 100644 rdma/dev.c

diff --git a/rdma/Makefile b/rdma/Makefile
index 64da2142..123d7ac5 100644
--- a/rdma/Makefile
+++ b/rdma/Makefile
@@ -2,7 +2,7 @@ include ../Config
 
 ifeq ($(HAVE_MNL),y)
 
-RDMA_OBJ = rdma.o utils.o
+RDMA_OBJ = rdma.o utils.o dev.o
 
 TARGETS=rdma
 CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
diff --git a/rdma/dev.c b/rdma/dev.c
new file mode 100644
index 00000000..e984f805
--- /dev/null
+++ b/rdma/dev.c
@@ -0,0 +1,227 @@
+/*
+ * dev.c	RDMA tool
+ *
+ *              This program is free software; you can redistribute it and/or
+ *              modify it under the terms of the GNU General Public License
+ *              as published by the Free Software Foundation; either version
+ *              2 of the License, or (at your option) any later version.
+ *
+ * Authors:     Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
+ */
+
+#include "rdma.h"
+
+static int dev_help(struct rd *rd)
+{
+	pr_out("Usage: %s dev show [DEV]\n", rd->filename);
+	return 0;
+}
+
+static const char *dev_caps_to_str(uint32_t idx)
+{
+	uint64_t cap = 1 << idx;
+
+	switch (cap) {
+	case RDMA_DEV_RESIZE_MAX_WR: return "RESIZE_MAX_WR";
+	case RDMA_DEV_BAD_PKEY_CNTR: return "BAD_PKEY_CNTR";
+	case RDMA_DEV_BAD_QKEY_CNTR: return "BAD_QKEY_CNTR";
+	case RDMA_DEV_RAW_MULTI: return "RAW_MULTI";
+	case RDMA_DEV_AUTO_PATH_MIG: return "AUTO_PATH_MIG";
+	case RDMA_DEV_CHANGE_PHY_PORT: return "CHANGE_PHY_POR";
+	case RDMA_DEV_UD_AV_PORT_ENFORCE: return "UD_AV_PORT_ENFORCE";
+	case RDMA_DEV_CURR_QP_STATE_MOD: return "CURR_QP_STATE_MOD";
+	case RDMA_DEV_SHUTDOWN_PORT: return "SHUTDOWN_PORT";
+	case RDMA_DEV_INIT_TYPE: return "INIT_TYPE";
+	case RDMA_DEV_PORT_ACTIVE_EVENT: return "PORT_ACTIVE_EVENT";
+	case RDMA_DEV_SYS_IMAGE_GUID: return "SYS_IMAGE_GUID";
+	case RDMA_DEV_RC_RNR_NAK_GEN: return "RC_RNR_NAK_GEN";
+	case RDMA_DEV_SRQ_RESIZE: return "SRQ_RESIZE";
+	case RDMA_DEV_N_NOTIFY_CQ: return "N_NOTIFY_CQ";
+	case RDMA_DEV_LOCAL_DMA_LKEY: return "LOCAL_DMA_LKEY";
+	case RDMA_DEV_MEM_WINDOW: return "MEM_WINDOW";
+	case RDMA_DEV_UD_IP_CSUM: return "UD_IP_CSUM";
+	case RDMA_DEV_UD_TSO: return "UD_TSO";
+	case RDMA_DEV_XRC: return "XRC";
+	case RDMA_DEV_MEM_MGT_EXTENSIONS: return "MEM_MGT_EXTENSIONS";
+	case RDMA_DEV_BLOCK_MULTICAST_LOOPBACK:
+					return "BLOCK_MULTICAST_LOOPBACK";
+	case RDMA_DEV_MEM_WINDOW_TYPE_2A: return "MEM_WINDOW_TYPE_2A";
+	case RDMA_DEV_MEM_WINDOW_TYPE_2B: return "MEM_WINDOW_TYPE_2B";
+	case RDMA_DEV_RC_IP_CSUM: return "RC_IP_CSUM";
+	case RDMA_DEV_RAW_IP_CSUM: return "RAW_IP_CSUM";
+	case RDMA_DEV_CROSS_CHANNEL: return "CROSS_CHANNEL";
+	case RDMA_DEV_MANAGED_FLOW_STEERING: return "MANAGED_FLOW_STEERING";
+	case RDMA_DEV_SIGNATURE_HANDOVER: return "SIGNATURE_HANDOVER";
+	case RDMA_DEV_ON_DEMAND_PAGING: return "ON_DEMAND_PAGING";
+	case RDMA_DEV_SG_GAPS_REG: return "SG_GAPS_REG";
+	case RDMA_DEV_VIRTUAL_FUNCTION: return "VIRTUAL_FUNCTION";
+	case RDMA_DEV_RAW_SCATTER_FCS: return "RAW_SCATTER_FCS";
+	case RDMA_DEV_RDMA_NETDEV_OPA_VNIC: return "RDMA_NETDEV_OPA_VNIC";
+	default: return "UNKNOWN";
+	}
+}
+
+static void dev_print_caps(struct nlattr **tb)
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
+			pr_out("%s", dev_caps_to_str(idx));
+			if (caps >> 0x1)
+				pr_out(", ");
+		}
+		caps >>= 0x1;
+	}
+
+	pr_out(">");
+}
+
+static void dev_print_fw(struct nlattr **tb)
+{
+	if (!tb[RDMA_NLDEV_ATTR_FW_VERSION])
+		return;
+
+	pr_out("fw %s ",
+	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_FW_VERSION]));
+}
+
+static void dev_print_node_guid(struct nlattr **tb)
+{
+	uint64_t node_guid;
+
+	if (!tb[RDMA_NLDEV_ATTR_NODE_GUID])
+		return;
+
+	node_guid = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_NODE_GUID]);
+	rd_print_u64("node_guid", node_guid);
+}
+
+static void dev_print_sys_image_guid(struct nlattr **tb)
+{
+	uint64_t sys_image_guid;
+
+	if (!tb[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID])
+		return;
+
+	sys_image_guid = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID]);
+	rd_print_u64("sys_image_guid", sys_image_guid);
+}
+
+static const char *node_type_to_str(uint8_t node_type)
+{
+	switch (node_type) {
+	case RDMA_NODE_IB_CA: return "ca";
+	case RDMA_NODE_IB_SWITCH: return "switch";
+	case RDMA_NODE_IB_ROUTER: return "router";
+	case RDMA_NODE_RNIC: return "rnic";
+	case RDMA_NODE_USNIC: return "usnic";
+	case RDMA_NODE_USNIC_UDP: return "usnic_dp";
+	default: return "unknown";
+	}
+}
+
+static void dev_print_node_type(struct nlattr **tb)
+{
+	uint8_t node_type;
+
+	if (!tb[RDMA_NLDEV_ATTR_DEV_NODE_TYPE])
+		return;
+
+	node_type = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_DEV_NODE_TYPE]);
+	pr_out("node_type %s ", node_type_to_str(node_type));
+}
+
+static int dev_parse_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
+	struct rd *rd = data;
+
+	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
+	if (!tb[RDMA_NLDEV_ATTR_DEV_INDEX] || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
+		return MNL_CB_ERROR;
+
+	pr_out("%u: %s: ",
+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]),
+	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]));
+	dev_print_node_type(tb);
+	dev_print_fw(tb);
+	dev_print_node_guid(tb);
+	dev_print_sys_image_guid(tb);
+	if (rd->show_details)
+		dev_print_caps(tb);
+
+	pr_out("\n");
+	return MNL_CB_OK;
+}
+
+static int dev_no_args(struct rd *rd)
+{
+	uint32_t seq;
+	int ret;
+
+	rd_prepare_msg(rd, RDMA_NLDEV_CMD_GET,
+		       &seq, (NLM_F_REQUEST | NLM_F_ACK));
+	mnl_attr_put_u32(rd->nlh, RDMA_NLDEV_ATTR_DEV_INDEX, rd->dev_idx);
+	ret = rd_send_msg(rd);
+	if (ret)
+		return ret;
+
+	return rd_recv_msg(rd, dev_parse_cb, rd, seq);
+}
+
+static int dev_one_show(struct rd *rd)
+{
+	const struct rd_cmd cmds[] = {
+		{ NULL,		dev_no_args},
+		{ 0 }
+	};
+
+	return rd_exec_cmd(rd, cmds, "parameter");
+}
+
+static int dev_show(struct rd *rd)
+{
+	struct dev_map *dev_map;
+	int ret = 0;
+
+	if (rd_no_arg(rd)) {
+		list_for_each_entry(dev_map, &rd->dev_map_list, list) {
+			rd->dev_idx = dev_map->idx;
+			ret = dev_one_show(rd);
+			if (ret)
+				return ret;
+		}
+
+	} else {
+		dev_map = dev_map_lookup(rd, false);
+		if (!dev_map) {
+			pr_err("Wrong device name\n");
+			return -ENOENT;
+		}
+		rd_arg_inc(rd);
+		rd->dev_idx = dev_map->idx;
+		ret = dev_one_show(rd);
+	}
+	return ret;
+}
+
+int cmd_dev(struct rd *rd)
+{
+	const struct rd_cmd cmds[] = {
+		{ NULL,		dev_show },
+		{ "show",	dev_show },
+		{ "list",	dev_show },
+		{ "help",	dev_help },
+		{ 0 }
+	};
+
+	return rd_exec_cmd(rd, cmds, "dev command");
+}
diff --git a/rdma/rdma.c b/rdma/rdma.c
index d850e396..9c2bdc8f 100644
--- a/rdma/rdma.c
+++ b/rdma/rdma.c
@@ -15,7 +15,7 @@
 static void help(char *name)
 {
 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
-	       "where  OBJECT := { help }\n"
+	       "where  OBJECT := { dev | help }\n"
 	       "       OPTIONS := { -V[ersion] | -d[etails]}\n", name);
 }
 
@@ -30,6 +30,7 @@ static int rd_cmd(struct rd *rd)
 	const struct rd_cmd cmds[] = {
 		{ NULL,		cmd_help },
 		{ "help",	cmd_help },
+		{ "dev",	cmd_dev },
 		{ 0 }
 	};
 
diff --git a/rdma/rdma.h b/rdma/rdma.h
index 361888b8..b9d75d29 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -40,6 +40,8 @@ struct rd {
 	char *filename;
 	bool show_details;
 	struct list_head dev_map_list;
+	uint32_t dev_idx;
+	uint32_t port_idx;
 	struct mnl_socket *nl;
 	struct nlmsghdr *nlh;
 	char *buff;
@@ -56,12 +58,23 @@ struct rd_cmd {
 bool rd_no_arg(struct rd *rd);
 void rd_arg_inc(struct rd *rd);
 
+char *rd_argv(struct rd *rd);
+uint32_t get_port_from_argv(struct rd *rd);
+
+void rd_print_u64(char *name, uint64_t val);
+/*
+ * Commands interface
+ */
+int cmd_dev(struct rd *rd);
+int cmd_link(struct rd *rd);
 int rd_exec_cmd(struct rd *rd, const struct rd_cmd *c, const char *str);
 
 /*
  * Device manipulation
  */
 void rd_free_devmap(struct rd *rd);
+struct dev_map *dev_map_lookup(struct rd *rd, bool allow_port_index);
+struct dev_map *_dev_map_lookup(struct rd *rd, const char *dev_name);
 
 /*
  * Netlink
diff --git a/rdma/utils.c b/rdma/utils.c
index 9bd7418f..0e32eefe 100644
--- a/rdma/utils.c
+++ b/rdma/utils.c
@@ -16,7 +16,7 @@ static int rd_argc(struct rd *rd)
 	return rd->argc;
 }
 
-static char *rd_argv(struct rd *rd)
+char *rd_argv(struct rd *rd)
 {
 	if (!rd_argc(rd))
 		return NULL;
@@ -50,6 +50,23 @@ bool rd_no_arg(struct rd *rd)
 	return rd_argc(rd) == 0;
 }
 
+uint32_t get_port_from_argv(struct rd *rd)
+{
+	char *slash;
+
+	slash = strchr(rd_argv(rd), '/');
+	/* if no port found, return 0 */
+	return slash ? atoi(slash + 1) : 0;
+}
+
+void rd_print_u64(char *name, uint64_t val)
+{
+	uint16_t vp[4];
+
+	memcpy(vp, &val, sizeof(uint64_t));
+	pr_out("%s %04x:%04x:%04x:%04x ", name, vp[3], vp[2], vp[1], vp[0]);
+}
+
 static struct dev_map *dev_map_alloc(const char *dev_name)
 {
 	struct dev_map *dev_map;
@@ -83,8 +100,14 @@ static void dev_map_cleanup(struct rd *rd)
 }
 
 static const enum mnl_attr_data_type nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
+	[RDMA_NLDEV_ATTR_DEV_INDEX] = MNL_TYPE_U32,
 	[RDMA_NLDEV_ATTR_DEV_NAME] = MNL_TYPE_NUL_STRING,
 	[RDMA_NLDEV_ATTR_PORT_INDEX] = MNL_TYPE_U32,
+	[RDMA_NLDEV_ATTR_CAP_FLAGS] = MNL_TYPE_U64,
+	[RDMA_NLDEV_ATTR_FW_VERSION] = MNL_TYPE_NUL_STRING,
+	[RDMA_NLDEV_ATTR_NODE_GUID] = MNL_TYPE_U64,
+	[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID] = MNL_TYPE_U64,
+	[RDMA_NLDEV_ATTR_DEV_NODE_TYPE] = MNL_TYPE_U8,
 };
 
 int rd_attr_cb(const struct nlattr *attr, void *data)
@@ -215,3 +238,32 @@ int rd_recv_msg(struct rd *rd, mnl_cb_t callback, void *data, unsigned int seq)
 	mnl_socket_close(rd->nl);
 	return ret;
 }
+
+struct dev_map *_dev_map_lookup(struct rd *rd, const char *dev_name)
+{
+	struct dev_map *dev_map;
+
+	list_for_each_entry(dev_map, &rd->dev_map_list, list)
+		if (strcmp(dev_name, dev_map->dev_name) == 0)
+			return dev_map;
+
+	return NULL;
+}
+
+struct dev_map *dev_map_lookup(struct rd *rd, bool allow_port_index)
+{
+	struct dev_map *dev_map;
+	char *dev_name;
+	char *slash;
+
+	dev_name = strdup(rd_argv(rd));
+	if (allow_port_index) {
+		slash = strrchr(dev_name, '/');
+		if (slash)
+			*slash = '\0';
+	}
+
+	dev_map = _dev_map_lookup(rd, dev_name);
+	free(dev_name);
+	return dev_map;
+}
-- 
2.14.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
