From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 V3 3/4] rdma: Add link object
Date: Mon, 10 Jul 2017 10:13:07 +0200
Message-ID: <20170710081307.GE1853@nanopsycho>
References: <20170704075541.12544-1-leon@kernel.org>
 <20170704075541.12544-4-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34622 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752670AbdGJINK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 04:13:10 -0400
Received: by mail-wr0-f194.google.com with SMTP id k67so23147411wrc.1
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 01:13:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170704075541.12544-4-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 04, 2017 at 09:55:40AM CEST, leon@kernel.org wrote:
>From: Leon Romanovsky <leonro@mellanox.com>
>
>Link (port) object represent struct ib_port to the user space.
>
>Link properties:
> * Port capabilities
> * IB subnet prefix
> * LID, SM_LID and LMC
> * Port state
> * Physical state
>
>Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
>---
> rdma/Makefile |   2 +-
> rdma/link.c   | 280 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> rdma/rdma.c   |   3 +-
> rdma/utils.c  |   5 ++
> 4 files changed, 288 insertions(+), 2 deletions(-)
> create mode 100644 rdma/link.c
>
>diff --git a/rdma/Makefile b/rdma/Makefile
>index 123d7ac5..1a9e4b1a 100644
>--- a/rdma/Makefile
>+++ b/rdma/Makefile
>@@ -2,7 +2,7 @@ include ../Config
>
> ifeq ($(HAVE_MNL),y)
>
>-RDMA_OBJ = rdma.o utils.o dev.o
>+RDMA_OBJ = rdma.o utils.o dev.o link.o
>
> TARGETS=rdma
> CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
>diff --git a/rdma/link.c b/rdma/link.c
>new file mode 100644
>index 00000000..f92b4cef
>--- /dev/null
>+++ b/rdma/link.c
>@@ -0,0 +1,280 @@
>+/*
>+ * link.c	RDMA tool
>+ *
>+ *              This program is free software; you can redistribute it and/or
>+ *              modify it under the terms of the GNU General Public License
>+ *              as published by the Free Software Foundation; either version
>+ *              2 of the License, or (at your option) any later version.
>+ *
>+ * Authors:     Leon Romanovsky <leonro@mellanox.com>
>+ */
>+
>+#include "rdma.h"
>+
>+static int link_help(struct rdma *rd)
>+{
>+	pr_out("Usage: %s link show [DEV/PORT_INDEX]\n", rd->filename);
>+	return 0;
>+}
>+
>+static void link_print_caps(struct nlattr **tb)
>+{
>+	uint64_t caps;
>+	uint32_t idx;
>+
>+	/*
>+	 * FIXME: move to indexes when kernel will start exporting them.

Not exported yet?



>+	 */
>+	static const char *link_caps[64] = {

[]


>+		"UNKNOWN",
>+		"SM",
>+		"NOTICE",
>+		"TRAP",
>+		"OPT_IPD",
>+		"AUTO_MIGR",
>+		"SL_MAP",
>+		"MKEY_NVRAM",
>+		"PKEY_NVRAM",
>+		"LED_INFO",
>+		"SM_DISABLED",
>+		"SYS_IMAGE_GUID",
>+		"PKEY_SW_EXT_PORT_TRAP",
>+		"UNKNOWN",
>+		"EXTENDED_SPEEDS",
>+		"UNKNOWN",
>+		"CM",
>+		"SNMP_TUNNEL",
>+		"REINIT",
>+		"DEVICE_MGMT",
>+		"VENDOR_CLASS",
>+		"DR_NOTICE",
>+		"CAP_MASK_NOTICE",
>+		"BOOT_MGMT",
>+		"LINK_LATENCY",
>+		"CLIENT_REG",
>+		"IP_BASED_GIDS",
>+	};
>+
>+	if (!tb[RDMA_NLDEV_ATTR_CAP_FLAGS])
>+		return;
>+
>+	caps = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_CAP_FLAGS]);
>+
>+	pr_out("\n    caps: <");
>+	for (idx = 0; idx < 64; idx++) {
>+		if (caps & 0x1) {
>+			pr_out("%s", link_caps[idx]?link_caps[idx]:"UNKNONW");

"link_caps[idx] ? link_caps[idx] : "UNKNOWN""

note the s/UNKNONW/UNKNOWN/


>+			if (caps >> 0x1)
>+				pr_out(", ");
>+		}
>+		caps >>= 0x1;

Interesting. 


>+	}
>+
>+	pr_out(">");
>+}
>+
>+static void link_print_subnet_prefix(struct nlattr **tb)
>+{
>+	uint64_t subnet_prefix;
>+	uint16_t sp[4];
>+
>+	if (!tb[RDMA_NLDEV_ATTR_SUBNET_PREFIX])
>+		return;
>+
>+	subnet_prefix = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_SUBNET_PREFIX]);
>+	memcpy(sp, &subnet_prefix, sizeof(uint64_t));
>+	pr_out("subnet_prefix %04x:%04x:%04x:%04x ", sp[3], sp[2], sp[1], sp[0]);

You have similar pr_out helper in the previous patch. Perhaps you can
re-use it?


>+}
>+
>+static void link_print_lid(struct nlattr **tb)
>+{
>+	if (!tb[RDMA_NLDEV_ATTR_LID])
>+		return;
>+
>+	pr_out("lid %u ",
>+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_LID]));
>+}
>+
>+static void link_print_sm_lid(struct nlattr **tb)
>+{
>+

Avoid the extra empty line.


>+	if (!tb[RDMA_NLDEV_ATTR_SM_LID])
>+		return;
>+
>+	pr_out("sm_lid %u ",
>+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_SM_LID]));
>+}
>+
>+static void link_print_lmc(struct nlattr **tb)
>+{
>+	if (!tb[RDMA_NLDEV_ATTR_LMC])
>+		return;
>+
>+	pr_out("lmc %u ", mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_LMC]));
>+}
>+
>+static void link_print_state(struct nlattr **tb)
>+{
>+	uint8_t state;
>+	/*
>+	 * FIXME: move to index exported by the kernel

Again, can't this be fixed now?


>+	 */
>+	static const char *str[] = {
>+		"NOP",
>+		"DOWN",
>+		"INIT",
>+		"ARMED",
>+		"ACTIVE",
>+		"ACTIVE_DEFER",
>+	};
>+
>+	if (!tb[RDMA_NLDEV_ATTR_PORT_STATE])
>+		return;
>+
>+	state = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_PORT_STATE]);
>+
>+	if (state < 6 )

Magic?


>+		pr_out("state %s ", str[state]);
>+	else
>+		pr_out("state UNKNOWN ");
>+}
>+
>+static void link_print_phys_state(struct nlattr **tb)
>+{
>+	uint8_t phys_state;
>+	/*
>+	 * FIXME: move to index exported by the kernel

Again, can't this be fixed now?


>+	 */
>+	static const char *str[] = {
>+		"UNKNOWN",
>+		"SLEEP",
>+		"POLLING",
>+		"DISABLED",
>+		"PORT_CONFIGURATION_TRAINING",
>+		"LINK_UP",
>+		"LINK_ERROR_RECOVER",
>+		"PHY_TEST",
>+	};
>+
>+	if (!tb[RDMA_NLDEV_ATTR_PORT_PHYS_STATE])
>+		return;
>+
>+	phys_state = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_PORT_PHYS_STATE]);
>+	if (phys_state < 8)

Magic?


>+		pr_out("physical_state %s ", str[phys_state]);
>+	else
>+		pr_out("physical_state UNKNOWN ");
>+}
>+
>+static int link_parse_cb(const struct nlmsghdr *nlh, void *data)
>+{
>+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
>+	struct rdma *rd = data;
>+
>+	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
>+	if (!tb[RDMA_NLDEV_ATTR_DEV_INDEX] || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
>+		return MNL_CB_ERROR;
>+
>+	if (!tb[RDMA_NLDEV_ATTR_PORT_INDEX]) {
>+		pr_err("This tool doesn't support switches yet\n");
>+		return MNL_CB_ERROR;
>+	}
>+
>+	pr_out("%u/%u: %s/%u: ",
>+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]),
>+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]),
>+	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]),
>+	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]));
>+	link_print_subnet_prefix(tb);
>+	link_print_lid(tb);
>+	link_print_sm_lid(tb);
>+	link_print_lmc(tb);
>+	link_print_state(tb);
>+	link_print_phys_state(tb);
>+	if (rd->show_details)
>+		link_print_caps(tb);
>+
>+	pr_out("\n");
>+	return MNL_CB_OK;
>+}
>+
>+static int link_no_args(struct rdma *rd)
>+{
>+	uint32_t seq;
>+	int ret;
>+
>+	rdma_prepare_msg(rd, RDMA_NLDEV_CMD_PORT_GET, &seq, (NLM_F_REQUEST | NLM_F_ACK));
>+	mnl_attr_put_u32(rd->nlh, RDMA_NLDEV_ATTR_DEV_INDEX, rd->dev_idx);
>+	mnl_attr_put_u32(rd->nlh, RDMA_NLDEV_ATTR_PORT_INDEX, rd->port_idx);
>+	if ((ret = rdma_send_msg(rd)))
>+		return ret;
>+
>+	return rdma_recv_msg(rd, link_parse_cb, rd, seq);
>+}
>+
>+static int link_one_show(struct rdma *rd)
>+{
>+	const struct rdma_cmd cmds[] = {
>+		{ NULL,		link_no_args},
>+		{ 0 }
>+	};
>+
>+	return rdma_exec_cmd(rd, cmds, "parameter");
>+

Avoid the extra empty line.


>+}
>+
>+static int link_show(struct rdma *rd)
>+{
>+	struct dev_map *dev_map;
>+	uint32_t port;
>+	int ret = 0;
>+
>+	if (rd_no_arg(rd)) {
>+		list_for_each_entry(dev_map, &rd->dev_map_list, list) {
>+			rd->dev_idx = dev_map->idx;
>+			for (port = 1; port < dev_map->num_ports + 1; port++) {
>+				rd->port_idx = port;
>+				ret = link_one_show(rd);
>+				if (ret)
>+					return ret;
>+			}
>+		}
>+
>+	}
>+	else {
>+		dev_map = dev_map_lookup(rd, true);
>+		port = get_port_from_argv(rd);
>+		if (!dev_map || port > dev_map->num_ports) {
>+			pr_err("Wrong device name\n");
>+			return -ENOENT;
>+		}
>+		rd_arg_inc(rd);
>+		rd->port_idx = port ? :1;

"port ? : 1"

>+		for (; port < dev_map->num_ports + 1; port++, rd->port_idx++) {
>+			ret = link_one_show(rd);
>+			if (ret)
>+				return ret;
>+			if (port)
>+				/*
>+				 * We got request to show link for devname
>+				 * without port index.
>+				 */
>+				break;
>+		}
>+
>+	}
>+	return ret;

	You can do return 0 here and avoid ret initialization.


>+}
>+
>+int cmd_link(struct rdma *rd)
>+{
>+	const struct rdma_cmd cmds[] = {
>+		{ NULL,		link_show },
>+		{ "show",	link_show },
>+		{ "list",	link_show },
>+		{ "help",	link_help },
>+		{ 0 }
>+	};
>+
>+	return rdma_exec_cmd(rd, cmds, "link command");
>+}
>diff --git a/rdma/rdma.c b/rdma/rdma.c
>index dfebd71e..f597f614 100644
>--- a/rdma/rdma.c
>+++ b/rdma/rdma.c
>@@ -18,7 +18,7 @@
> static void help(char *name)
> {
> 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
>-	       "where  OBJECT := { dev | help }\n"
>+	       "where  OBJECT := { dev | link | help }\n"
> 	       "       OPTIONS := { -V[ersion] | -d[etails]}\n", name);
> }
>
>@@ -34,6 +34,7 @@ static int rd_cmd(struct rdma *rd)
> 		{ NULL,		cmd_help },
> 		{ "help",	cmd_help },
> 		{ "dev",	cmd_dev },
>+		{ "link",	cmd_link },
> 		{ 0 }
> 	};
>
>diff --git a/rdma/utils.c b/rdma/utils.c
>index bee490da..ca61ccc1 100644
>--- a/rdma/utils.c
>+++ b/rdma/utils.c
>@@ -104,6 +104,11 @@ static const enum mnl_attr_data_type nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
> 	[RDMA_NLDEV_ATTR_FW_VERSION] = MNL_TYPE_NUL_STRING,
> 	[RDMA_NLDEV_ATTR_NODE_GUID] = MNL_TYPE_U64,
> 	[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID] = MNL_TYPE_U64,
>+	[RDMA_NLDEV_ATTR_LID] = MNL_TYPE_U32,
>+	[RDMA_NLDEV_ATTR_SM_LID] = MNL_TYPE_U32,
>+	[RDMA_NLDEV_ATTR_LMC] = MNL_TYPE_U8,
>+	[RDMA_NLDEV_ATTR_PORT_STATE] = MNL_TYPE_U8,
>+	[RDMA_NLDEV_ATTR_PORT_PHYS_STATE] = MNL_TYPE_U8,
> 	[RDMA_NLDEV_ATTR_DEV_NODE_TYPE] = MNL_TYPE_U8,
> };
>
>--
>2.13.2
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
