From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH iproute2 2/5] rdma: Add dev object
Date: Mon, 26 Jun 2017 21:21:25 +0300
Message-ID: <20170626182128.24964-3-leon@kernel.org>
References: <20170626182128.24964-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:43996 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751739AbdFZSVm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 26 Jun 2017 14:21:42 -0400
In-Reply-To: <20170626182128.24964-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Device (dev) object represents struct ib_device to user space.

The supported commands are show, set and help, but it doesn't print
anything except device name at this stage. The downstream patches will
fill this object with subcommands.

Print all devices:
 # rdma dev
1: mlx5_0:
2: mlx5_1:
3: mlx5_2:

Print specific device:
 # rdma dev show mlx5_1
2: mlx5_1:

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 rdma/Makefile |  2 +-
 rdma/dev.c    | 60 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rdma/rdma.c   |  3 ++-
 rdma/rdma.h   |  6 ++++++
 rdma/utils.c  | 37 +++++++++++++++++++++++++++++++-----
 5 files changed, 101 insertions(+), 7 deletions(-)
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
index 00000000..5a3ee126
--- /dev/null
+++ b/rdma/dev.c
@@ -0,0 +1,60 @@
+/*
+ * dev.c	RDMA tool
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
+static int dev_help(struct rdma *rd)
+{
+	pr_out("Usage: %s dev show [DEV]\n", rd->filename);
+
+	/*
+	 * Example of set command:
+	 * pr_out("       %s dev set DEV [ node_desc { DESCRIPTION } ]\n", rd->filename);
+	 */
+	return 0;
+}
+
+static void dev_one_show(const struct dev_map *dev_map)
+{
+	pr_out("%u: %s:\n", dev_map->idx, dev_map->dev_name);
+}
+
+static int dev_show(struct rdma *rd)
+{
+	struct dev_map *dev_map;
+
+	if (rd_no_arg(rd)) {
+		list_for_each_entry(dev_map, &rd->dev_map_list, list)
+			dev_one_show(dev_map);
+	}
+	else {
+		dev_map = dev_map_lookup(rd, false);
+		if (!dev_map) {
+			pr_err("Wrong device name\n");
+			return -ENOENT;
+		}
+		dev_one_show(dev_map);
+	}
+	return 0;
+}
+
+int cmd_dev(struct rdma *rd)
+{
+	const struct rdma_cmd cmds[] = {
+		{ NULL,		dev_show },
+		{ "show",	dev_show },
+		{ "list",	dev_show },
+		{ "help",	dev_help },
+		{ 0 }
+	};
+
+	return rdma_exec_cmd(rd, cmds, "dev command");
+}
diff --git a/rdma/rdma.c b/rdma/rdma.c
index 9c754da3..f904532c 100644
--- a/rdma/rdma.c
+++ b/rdma/rdma.c
@@ -18,7 +18,7 @@
 static void help(char *name)
 {
 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
-	       "where  OBJECT := { help }\n"
+	       "where  OBJECT := { dev | help }\n"
 	       "       OPTIONS := { -V[ersion] }\n", name);
 }

@@ -33,6 +33,7 @@ static int rd_cmd(struct rdma *rd)
 	const struct rdma_cmd cmds[] = {
 		{ NULL,		cmd_help },
 		{ "help",	cmd_help },
+		{ "dev",	cmd_dev },
 		{ 0 }
 	};

diff --git a/rdma/rdma.h b/rdma/rdma.h
index 9841aebf..f5e104ec 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -58,12 +58,18 @@ bool rd_no_arg(struct rdma *rd);
 bool rd_argv_match(struct rdma *rd, const char *pattern);
 void rd_arg_inc(struct rdma *rd);

+/*
+ * Commands interface
+ */
+int cmd_dev(struct rdma *rd);
 int rdma_exec_cmd(struct rdma *rd, const struct rdma_cmd *c, const char *str);

 /*
  * Device manipulation
  */
 void rdma_free_devmap(struct rdma *rd);
+struct dev_map *dev_map_lookup(struct rdma *rd, bool allow_port_index);
+struct dev_map *_dev_map_lookup(struct rdma *rd, const char *dev_name);

 /*
  * Netlink
diff --git a/rdma/utils.c b/rdma/utils.c
index 96278a4c..e5c3dd6c 100644
--- a/rdma/utils.c
+++ b/rdma/utils.c
@@ -156,10 +156,9 @@ int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data)
 	struct rdma *rd = data;
 	const char *dev_name;
 	uint32_t num_ports;
-	static int i = 1;

 	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
-	if (!tb[RDMA_NLDEV_ATTR_DEV_NAME])
+	if (!tb[RDMA_NLDEV_ATTR_DEV_INDEX] || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
 		return MNL_CB_ERROR;
 	if (!tb[RDMA_NLDEV_ATTR_PORT_INDEX]) {
 		pr_err("This tool doesn't support switches yet\n");
@@ -167,18 +166,18 @@ int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data)
 	}

 	dev_name = mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]);
-	num_ports = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
-
 	dev_map = dev_map_alloc(dev_name);
 	if (!dev_map)
 		/* The main function will cleanup the allocations */
 		return MNL_CB_ERROR;
 	list_add_tail(&dev_map->list, &rd->dev_map_list);
-	dev_map->idx = i++;

+	num_ports = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
 	if (port_map_alloc(dev_map, num_ports))
 		return MNL_CB_ERROR;
 	dev_map->num_ports = num_ports;
+	dev_map->idx = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
+	dev_map->caps = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_CAP_FLAGS]);

 	return MNL_CB_OK;
 }
@@ -268,3 +267,31 @@ int rdma_recv_msg(struct rdma *rd, mnl_cb_t callback, void *data, unsigned int s
 	mnl_socket_close(rd->nl);
 	return ret;
 }
+
+struct dev_map *_dev_map_lookup(struct rdma *rd, const char *dev_name)
+{
+	struct dev_map *dev_map;
+
+	list_for_each_entry(dev_map, &rd->dev_map_list, list)
+		if (strcmp(dev_name, dev_map->dev_name) == 0)
+			return dev_map;
+
+	return NULL;
+}
+struct dev_map *dev_map_lookup(struct rdma *rd, bool allow_port_index)
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
