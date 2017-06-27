From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH iproute2 V1 4/6] rdma: Add link option and parsing
Date: Tue, 27 Jun 2017 17:39:18 +0300
Message-ID: <20170627143920.28020-5-leon@kernel.org>
References: <20170627143920.28020-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:39868 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752682AbdF0Ojk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Jun 2017 10:39:40 -0400
In-Reply-To: <20170627143920.28020-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Add link object interface together with port capability parsing command

$ rdma link
1/1: mlx5_0/1:
    caps: <AUTO_MIGR>
2/1: mlx5_1/1:
    caps: <AUTO_MIGR>
3/1: mlx5_2/1:
    caps: <AUTO_MIGR>
4/1: mlx5_3/1:
    caps: <CM, IP_BASED_GIDS>
5/1: mlx5_4/1:
    caps: <AUTO_MIGR>

$ rdma link show mlx5_4
5/1: mlx5_4/1:
    caps: <AUTO_MIGR>

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 rdma/Makefile |   2 +-
 rdma/link.c   | 202 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rdma/rdma.c   |   1 +
 rdma/rdma.h   |   4 ++
 rdma/utils.c  |   9 +++
 5 files changed, 217 insertions(+), 1 deletion(-)
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
index 00000000..1ffc83d4
--- /dev/null
+++ b/rdma/link.c
@@ -0,0 +1,202 @@
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
+static int link_help(struct rdma *rd)
+{
+	pr_out("Usage: %s link show [DEV/PORT_INDEX]\n", rd->filename);
+	return 0;
+}
+
+static const char *link_caps[64] = {
+	"UNKNOWN",
+	"SM",
+	"NOTICE",
+	"TRAP",
+	"OPT_IPD",
+	"AUTO_MIGR",
+	"SL_MAP",
+	"MKEY_NVRAM",
+	"PKEY_NVRAM",
+	"LED_INFO",
+	"SM_DISABLED",
+	"SYS_IMAGE_GUID",
+	"PKEY_SW_EXT_PORT_TRAP",
+	"UNKNOWN",
+	"EXTENDED_SPEEDS",
+	"UNKNOWN",
+	"CM",
+	"SNMP_TUNNEL",
+	"REINIT",
+	"DEVICE_MGMT",
+	"VENDOR_CLASS",
+	"DR_NOTICE",
+	"CAP_MASK_NOTICE",
+	"BOOT_MGMT",
+	"LINK_LATENCY",
+	"CLIENT_REG",
+	"IP_BASED_GIDS",
+};
+
+static int link_print_caps(struct rdma *rd)
+{
+	uint64_t caps = rd->port_map_curr->caps;
+	bool found = false;
+	uint32_t idx;
+
+	pr_out("    caps: <");
+	for (idx = 0; idx < 64; idx++) {
+		if (caps & 0x1) {
+			pr_out("%s", link_caps[idx]?link_caps[idx]:"UNKNONW");
+			if (caps >> 0x1)
+				pr_out(", ");
+			found = true;
+		}
+		caps >>= 0x1;
+	}
+	if(!found)
+		pr_out("NONE");
+
+	pr_out(">\n");
+	return 0;
+}
+
+static int link_no_args(struct rdma *rd)
+{
+	struct port_map *port_map = rd->port_map_curr;
+	struct dev_map *dev_map = rd->dev_map_curr;
+
+	pr_out("%u/%u: %s/%u: \n", dev_map->idx, port_map->idx, dev_map->dev_name, port_map->idx);
+	return link_print_caps(rd);
+}
+
+static int link_one_show(struct rdma *rd)
+{
+	const struct rdma_cmd cmds[] = {
+		{ NULL,		link_no_args},
+		{ 0 }
+	};
+
+	return rdma_exec_cmd(rd, cmds, "parameter");
+
+}
+
+static int port_init_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
+	struct port_map *port_map;
+	struct dev_map *dev_map;
+	struct rdma *rd = data;
+	uint32_t port_idx;
+	uint32_t caps;
+
+	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
+	if (!tb[RDMA_NLDEV_ATTR_DEV_INDEX] || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
+		return MNL_CB_ERROR;
+	if (!tb[RDMA_NLDEV_ATTR_PORT_INDEX]) {
+		pr_err("This tool doesn't support switches yet\n");
+		return MNL_CB_ERROR;
+	}
+
+	dev_map = rd->dev_map_curr;
+
+	port_idx = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
+	caps = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_CAP_FLAGS]);
+
+	list_for_each_entry(port_map, &dev_map->port_map_list, list) {
+		if (port_map->idx != port_idx)
+			continue;
+
+		port_map->caps = caps;
+	}
+
+	return MNL_CB_OK;
+}
+
+
+static int fill_port_map(struct rdma *rd)
+{
+	uint32_t seq;
+	int ret;
+
+	rdma_prepare_msg(rd, RDMA_NLDEV_CMD_PORT_GET, &seq, (NLM_F_REQUEST | NLM_F_ACK | NLM_F_DUMP));
+	mnl_attr_put_u32(rd->nlh, RDMA_NLDEV_ATTR_DEV_INDEX, rd->dev_map_curr->idx);
+	if ((ret = rdma_send_msg(rd)))
+		return ret;
+
+	return rdma_recv_msg(rd, port_init_cb, rd, seq);
+}
+
+static int link_show(struct rdma *rd)
+{
+	struct port_map *port_map;
+	struct dev_map *dev_map;
+	int ret = 0;
+
+	if (rd_no_arg(rd)) {
+		list_for_each_entry(dev_map, &rd->dev_map_list, list) {
+			rd->dev_map_curr = dev_map;
+			ret = fill_port_map(rd);
+			if (ret)
+				return ret;
+
+			list_for_each_entry(port_map, &dev_map->port_map_list, list) {
+				rd->port_map_curr = port_map;
+				ret = link_one_show(rd);
+				if (ret)
+					return ret;
+			}
+		}
+
+	}
+	else {
+		uint32_t port;
+		rd->dev_map_curr = dev_map_lookup(rd, true);
+		port = get_port_from_argv(rd);
+		if (!rd->dev_map_curr || port > rd->dev_map_curr->num_ports) {
+			pr_err("Wrong device name\n");
+			return -ENOENT;
+		}
+		rd_arg_inc(rd);
+
+		ret = fill_port_map(rd);
+		if (ret)
+			return ret;
+
+		list_for_each_entry(port_map, &rd->dev_map_curr->port_map_list, list) {
+			rd->port_map_curr = port_map;
+			if (port && port_map->idx != port)
+				continue;
+
+			if (!port || port_map->idx == port) {
+				ret = link_one_show(rd);
+				if (ret)
+					return ret;
+			}
+		}
+
+	}
+	return ret;
+}
+
+int cmd_link(struct rdma *rd)
+{
+	const struct rdma_cmd cmds[] = {
+		{ NULL,		link_show },
+		{ "show",	link_show },
+		{ "list",	link_show },
+		{ "help",	link_help },
+		{ 0 }
+	};
+
+	return rdma_exec_cmd(rd, cmds, "link command");
+}
diff --git a/rdma/rdma.c b/rdma/rdma.c
index f904532c..ec6c2edb 100644
--- a/rdma/rdma.c
+++ b/rdma/rdma.c
@@ -34,6 +34,7 @@ static int rd_cmd(struct rdma *rd)
 		{ NULL,		cmd_help },
 		{ "help",	cmd_help },
 		{ "dev",	cmd_dev },
+		{ "link",	cmd_link },
 		{ 0 }
 	};
 
diff --git a/rdma/rdma.h b/rdma/rdma.h
index 8cca0f28..553a4fc2 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -26,6 +26,7 @@
 struct port_map {
 	struct list_head list;
 	uint32_t idx;
+	uint64_t caps;
 };
 
 struct dev_map {
@@ -43,6 +44,7 @@ struct rdma {
 	char *filename;
 	struct list_head dev_map_list;
 	struct dev_map *dev_map_curr;
+	struct port_map *port_map_curr;
 	struct mnl_socket *nl;
 	struct nlmsghdr *nlh;
 	char *buff;
@@ -60,11 +62,13 @@ bool rd_no_arg(struct rdma *rd);
 bool rd_argv_match(struct rdma *rd, const char *pattern);
 void rd_arg_inc(struct rdma *rd);
 char *rd_argv(struct rdma *rd);
+uint32_t get_port_from_argv(struct rdma *rd);
 
 /*
  * Commands interface
  */
 int cmd_dev(struct rdma *rd);
+int cmd_link(struct rdma *rd);
 int rdma_exec_cmd(struct rdma *rd, const struct rdma_cmd *c, const char *str);
 
 /*
diff --git a/rdma/utils.c b/rdma/utils.c
index 94737c5c..68ae3d3e 100644
--- a/rdma/utils.c
+++ b/rdma/utils.c
@@ -62,6 +62,15 @@ bool rd_no_arg(struct rdma *rd)
 	return rd_argc(rd) == 0;
 }
 
+uint32_t get_port_from_argv(struct rdma *rd)
+{
+        char *slash;
+
+        slash = strchr(rd_argv(rd), '/');
+        /* if no port found, return 0 */
+        return (slash) ? (atoi(slash + 1)):0;
+}
+
 static struct dev_map *dev_map_alloc(const char *dev_name)
 {
 	struct dev_map *dev_map;
-- 
2.13.1
