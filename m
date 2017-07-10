From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH iproute2 V3 2/4] rdma: Add dev object
Date: Mon, 10 Jul 2017 10:01:02 +0200
Message-ID: <20170710080102.GC1853@nanopsycho>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170704075541.12544-3-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170704075541.12544-3-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Tue, Jul 04, 2017 at 09:55:39AM CEST, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org wrote:
>From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>
>Device (dev) object represents struct ib_device to the user space.
>
>Device properties:
> * Device capabilities
> * FW version to the device output
> * node_guid and sys_image_guid
> * node_type
>
>Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>---
> rdma/Makefile |   2 +-
> rdma/dev.c    | 235 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> rdma/rdma.c   |   3 +-
> rdma/rdma.h   |  12 ++-
> rdma/utils.c  |  46 +++++++++++-
> 5 files changed, 293 insertions(+), 5 deletions(-)
> create mode 100644 rdma/dev.c
>
>diff --git a/rdma/Makefile b/rdma/Makefile
>index 64da2142..123d7ac5 100644
>--- a/rdma/Makefile
>+++ b/rdma/Makefile
>@@ -2,7 +2,7 @@ include ../Config
>
> ifeq ($(HAVE_MNL),y)
>
>-RDMA_OBJ = rdma.o utils.o
>+RDMA_OBJ = rdma.o utils.o dev.o
>
> TARGETS=rdma
> CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
>diff --git a/rdma/dev.c b/rdma/dev.c
>new file mode 100644
>index 00000000..b80e5288
>--- /dev/null
>+++ b/rdma/dev.c
>@@ -0,0 +1,235 @@
>+/*
>+ * dev.c	RDMA tool
>+ *
>+ *              This program is free software; you can redistribute it and/or
>+ *              modify it under the terms of the GNU General Public License
>+ *              as published by the Free Software Foundation; either version
>+ *              2 of the License, or (at your option) any later version.
>+ *
>+ * Authors:     Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
>+ */
>+
>+#include "rdma.h"
>+
>+static int dev_help(struct rdma *rd)
>+{
>+	pr_out("Usage: %s dev show [DEV]\n", rd->filename);
>+	return 0;
>+}
>+
>+static void dev_print_caps(struct nlattr **tb)
>+{
>+	uint64_t caps;
>+	uint32_t idx;
>+
>+	/*
>+	 * FIXME: move to indexes when kernel will start exporting them.
>+	 */
>+	static const char *dev_caps[64] = {

	static const char *dev_caps[] = {


>+		"RESIZE_MAX_WR",
>+		"BAD_PKEY_CNTR",
>+		"BAD_QKEY_CNTR",
>+		"RAW_MULTI",
>+		"AUTO_PATH_MIG",
>+		"CHANGE_PHY_PORT",
>+		"UD_AV_PORT_ENFORCE",
>+		"CURR_QP_STATE_MOD",
>+		"SHUTDOWN_PORT",
>+		"INIT_TYPE",
>+		"PORT_ACTIVE_EVENT",
>+		"SYS_IMAGE_GUID",
>+		"RC_RNR_NAK_GEN",
>+		"SRQ_RESIZE",
>+		"N_NOTIFY_CQ",
>+		"LOCAL_DMA_LKEY",
>+		"RESERVED",
>+		"MEM_WINDOW",
>+		"UD_IP_CSUM",
>+		"UD_TSO",
>+		"XRC",
>+		"MEM_MGT_EXTENSIONS",
>+		"BLOCK_MULTICAST_LOOPBACK",
>+		"MEM_WINDOW_TYPE_2A",
>+		"MEM_WINDOW_TYPE_2B",
>+		"RC_IP_CSUM",
>+		"RAW_IP_CSUM",
>+		"CROSS_CHANNEL",
>+		"MANAGED_FLOW_STEERING",
>+		"SIGNATURE_HANDOVER",
>+		"ON_DEMAND_PAGING",
>+		"SG_GAPS_REG",
>+		"VIRTUAL_FUNCTION",
>+		"RAW_SCATTER_FCS",
>+		"RDMA_NETDEV_OPA_VNIC",
>+	};
>+
>+	if (!tb[RDMA_NLDEV_ATTR_CAP_FLAGS])
>+	       return;
>+
>+	caps = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_CAP_FLAGS]);
>+
>+	pr_out("\n    caps: <");
>+	for (idx = 0; idx < 64; idx++) {
>+		if (caps & 0x1) {
>+			pr_out("%s", dev_caps[idx]?dev_caps[idx]:"UNKNONW");
>+			if (caps >> 0x1)
>+				pr_out(", ");
>+		}
>+		caps >>= 0x1;
>+	}
>+
>+	pr_out(">");
>+}
>+
>+static void dev_print_fw(struct nlattr **tb)
>+{
>+	if (!tb[RDMA_NLDEV_ATTR_FW_VERSION])
>+		return;
>+
>+	pr_out("fw %s ",
>+	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_FW_VERSION]));
>+}
>+
>+static void _dev_print_be64(char *name, uint64_t val)

Why the initial "_"? I think it could be avoided.

Wait, I'm confused. Does kernel actually exposes BE64 in U64 attribute?
That is wrong. Please fix it while there is still a time (if it is).


>+{
>+	uint16_t vp[4];
>+
>+	memcpy(vp, &val, sizeof(uint64_t));
>+	pr_out("%s %04x:%04x:%04x:%04x ", name, vp[3], vp[2], vp[1], vp[0]);
>+}
>+
>+static void dev_print_node_guid(struct nlattr **tb)
>+{
>+	uint64_t node_guid;
>+
>+	if (!tb[RDMA_NLDEV_ATTR_NODE_GUID])
>+		return;
>+
>+	node_guid = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_NODE_GUID]);
>+	_dev_print_be64("node_guid", node_guid);
>+}
>+
>+static void dev_print_sys_image_guid(struct nlattr **tb)
>+{
>+       uint64_t	sys_image_guid;
>+
>+	if (!tb[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID])
>+		return;
>+
>+	sys_image_guid = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID]);
>+	_dev_print_be64("sys_image_guid", sys_image_guid);
>+}
>+
>+static void dev_print_node_type(struct nlattr **tb)
>+{
>+	uint8_t node_type;
>+	/*
>+	 * FIXME: move to index exported by the kernel
>+	 */

So fix it rightaway :)


>+	static const char *str[] = {
>+		"UNKNOWN",
>+		"SWITCH",
>+		"ROUTER",
>+		"RNIC",
>+		"USNIC",
>+		"USNIC_UDP",
>+	};
>+
>+	if (!tb[RDMA_NLDEV_ATTR_DEV_NODE_TYPE])
>+		return;
>+
>+	node_type = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_DEV_NODE_TYPE]);
>+
>+	if (node_type < 7 )

Magic? :O


>+		pr_out("node_type %s ", str[node_type]);
>+	else
>+		pr_out("node_type UNKNOWN ");
>+}
>+
>+static int dev_parse_cb(const struct nlmsghdr *nlh, void *data)
>+{
>+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
>+	struct rdma *rd = data;
>+
>+	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
>+	if (!tb[RDMA_NLDEV_ATTR_DEV_INDEX] || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
>+		return MNL_CB_ERROR;
>+
>+	pr_out("%u: %s: ",
>+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]),
>+	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]));
>+	dev_print_node_type(tb);
>+	dev_print_fw(tb);
>+	dev_print_node_guid(tb);
>+	dev_print_sys_image_guid(tb);
>+	if (rd->show_details)
>+		dev_print_caps(tb);
>+
>+	pr_out("\n");
>+	return MNL_CB_OK;
>+}
>+
>+
>+static int dev_no_args(struct rdma *rd)
>+{
>+	uint32_t seq;
>+	int ret;
>+
>+	rdma_prepare_msg(rd, RDMA_NLDEV_CMD_GET, &seq, (NLM_F_REQUEST | NLM_F_ACK));
>+	mnl_attr_put_u32(rd->nlh, RDMA_NLDEV_ATTR_DEV_INDEX, rd->dev_idx);
>+	if ((ret = rdma_send_msg(rd)))
>+		return ret;
>+
>+	return rdma_recv_msg(rd, dev_parse_cb, rd, seq);
>+}
>+
>+static int dev_one_show(struct rdma *rd)
>+{
>+	const struct rdma_cmd cmds[] = {
>+		{ NULL,		dev_no_args},
>+		{ 0 }
>+	};
>+
>+	return rdma_exec_cmd(rd, cmds, "parameter");
>+

Drop the extra empty line.


>+}
>+
>+static int dev_show(struct rdma *rd)
>+{
>+	struct dev_map *dev_map;
>+	int ret = 0;
>+
>+	if (rd_no_arg(rd)) {
>+		list_for_each_entry(dev_map, &rd->dev_map_list, list) {
>+			rd->dev_idx = dev_map->idx;
>+			ret = dev_one_show(rd);
>+			if (ret)
>+				return ret;
>+		}
>+

Drop the extra empty line.


>+	}
>+	else {

"} else {"

Checkpatch should warn you. Did you run it?



>+		dev_map = dev_map_lookup(rd, false);
>+		if (!dev_map) {
>+			pr_err("Wrong device name\n");
>+			return -ENOENT;
>+		}
>+		rd_arg_inc(rd);
>+		rd->dev_idx = dev_map->idx;
>+		ret = dev_one_show(rd);
>+	}
>+	return ret;
>+}
>+
>+int cmd_dev(struct rdma *rd)
>+{
>+	const struct rdma_cmd cmds[] = {
>+		{ NULL,		dev_show },
>+		{ "show",	dev_show },
>+		{ "list",	dev_show },
>+		{ "help",	dev_help },
>+		{ 0 }
>+	};
>+
>+	return rdma_exec_cmd(rd, cmds, "dev command");
>+}
>diff --git a/rdma/rdma.c b/rdma/rdma.c
>index 29273839..dfebd71e 100644
>--- a/rdma/rdma.c
>+++ b/rdma/rdma.c
>@@ -18,7 +18,7 @@
> static void help(char *name)
> {
> 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
>-	       "where  OBJECT := { help }\n"
>+	       "where  OBJECT := { dev | help }\n"
> 	       "       OPTIONS := { -V[ersion] | -d[etails]}\n", name);
> }
>
>@@ -33,6 +33,7 @@ static int rd_cmd(struct rdma *rd)
> 	const struct rdma_cmd cmds[] = {
> 		{ NULL,		cmd_help },
> 		{ "help",	cmd_help },
>+		{ "dev",	cmd_dev },
> 		{ 0 }
> 	};
>
>diff --git a/rdma/rdma.h b/rdma/rdma.h
>index 0c01b091..2856e592 100644
>--- a/rdma/rdma.h
>+++ b/rdma/rdma.h
>@@ -16,7 +16,6 @@
> #include <errno.h>
> #include <getopt.h>
> #include <libmnl/libmnl.h>
>-

:) Please push this line removal to the previous patch.


> #include <rdma/rdma_netlink.h>
> #include "list.h"
>
>@@ -36,6 +35,8 @@ struct rdma {
> 	char *filename;
> 	bool show_details;
> 	struct list_head dev_map_list;
>+	uint32_t dev_idx;
>+	uint32_t port_idx;
> 	struct mnl_socket *nl;
> 	struct nlmsghdr *nlh;
> 	char *buff;
>@@ -51,13 +52,22 @@ struct rdma_cmd {
>  */
> bool rd_no_arg(struct rdma *rd);
> void rd_arg_inc(struct rdma *rd);
>+char *rd_argv(struct rdma *rd);
>+uint32_t get_port_from_argv(struct rdma *rd);
>
>+/*
>+ * Commands interface
>+ */
>+int cmd_dev(struct rdma *rd);
>+int cmd_link(struct rdma *rd);
> int rdma_exec_cmd(struct rdma *rd, const struct rdma_cmd *c, const char *str);
>
> /*
>  * Device manipulation
>  */
> void rdma_free_devmap(struct rdma *rd);
>+struct dev_map *dev_map_lookup(struct rdma *rd, bool allow_port_index);
>+struct dev_map *_dev_map_lookup(struct rdma *rd, const char *dev_name);
>
> /*
>  * Netlink
>diff --git a/rdma/utils.c b/rdma/utils.c
>index b554eff7..bee490da 100644
>--- a/rdma/utils.c
>+++ b/rdma/utils.c
>@@ -21,7 +21,7 @@ static int rd_argc(struct rdma *rd)
> 	return rd->argc;
> }
>
>-static char *rd_argv(struct rdma *rd)
>+char *rd_argv(struct rdma *rd)
> {
> 	if (!rd_argc(rd))
> 		return NULL;
>@@ -55,6 +55,15 @@ bool rd_no_arg(struct rdma *rd)
> 	return rd_argc(rd) == 0;
> }
>
>+uint32_t get_port_from_argv(struct rdma *rd)
>+{
>+        char *slash;
>+
>+        slash = strchr(rd_argv(rd), '/');
>+        /* if no port found, return 0 */
>+        return (slash) ? (atoi(slash + 1)):0;

	return slash ? atoi(slash + 1) : 0;



>+}
>+
> static struct dev_map *dev_map_alloc(const char *dev_name)
> {
> 	struct dev_map *dev_map;
>@@ -88,8 +97,14 @@ static void dev_map_cleanup(struct rdma *rd)
> }
>
> static const enum mnl_attr_data_type nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
>+	[RDMA_NLDEV_ATTR_DEV_INDEX] = MNL_TYPE_U32,
> 	[RDMA_NLDEV_ATTR_DEV_NAME] = MNL_TYPE_NUL_STRING,
> 	[RDMA_NLDEV_ATTR_PORT_INDEX] = MNL_TYPE_U32,
>+	[RDMA_NLDEV_ATTR_CAP_FLAGS] = MNL_TYPE_U64,
>+	[RDMA_NLDEV_ATTR_FW_VERSION] = MNL_TYPE_NUL_STRING,
>+	[RDMA_NLDEV_ATTR_NODE_GUID] = MNL_TYPE_U64,
>+	[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID] = MNL_TYPE_U64,
>+	[RDMA_NLDEV_ATTR_DEV_NODE_TYPE] = MNL_TYPE_U8,
> };
>
> int rd_attr_cb(const struct nlattr *attr, void *data)
>@@ -134,7 +149,6 @@ int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data)
>
> 	dev_map->num_ports = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
> 	dev_map->idx = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
>-

Again, should be part of the previous patch.


> 	return MNL_CB_OK;
> }
>
>@@ -221,3 +235,31 @@ int rdma_recv_msg(struct rdma *rd, mnl_cb_t callback, void *data, unsigned int s
> 	mnl_socket_close(rd->nl);
> 	return ret;
> }
>+
>+struct dev_map *_dev_map_lookup(struct rdma *rd, const char *dev_name)
>+{
>+	struct dev_map *dev_map;
>+
>+	list_for_each_entry(dev_map, &rd->dev_map_list, list)
>+		if (strcmp(dev_name, dev_map->dev_name) == 0)
>+			return dev_map;
>+
>+	return NULL;
>+}
>+struct dev_map *dev_map_lookup(struct rdma *rd, bool allow_port_index)
>+{
>+	struct dev_map *dev_map;
>+	char *dev_name;
>+	char *slash;
>+
>+	dev_name = strdup(rd_argv(rd));
>+	if (allow_port_index) {
>+		slash = strrchr(dev_name, '/');
>+		if (slash)
>+			*slash = '\0';
>+	}
>+
>+	dev_map = _dev_map_lookup(rd, dev_name);
>+	free(dev_name);
>+	return dev_map;
>+}
>--
>2.13.2
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
