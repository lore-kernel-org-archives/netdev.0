From: Leon Romanovsky <leon@kernel.org>
Subject: [RFC iproute2 2/8] rdma: Add dev object
Date: Thu,  4 May 2017 21:02:10 +0300
Message-ID: <20170504180216.7665-3-leon@kernel.org>
References: <20170504180216.7665-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Ram Amrani <ram.amrani@cavium.com>,
        Bart Van Assche <Bart.VanAssche@sandisk.com>,
        Sagi Grimberg <sagi@grimberg.me>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Christoph Hellwig <hch@lst.de>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Linux RDMA <linux-rdma@vger.kernel.org>,
        Linux Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:58452 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756087AbdEDSC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 14:02:26 -0400
In-Reply-To: <20170504180216.7665-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Device (dev) object represents struct ib_device to user space.

The supported commands are show, set and help.

Print all devices:
 # rdma dev
1: mlx5_0: board_id MT_2190110032 fw_pages 261002 fw_ver 12.17.2046 hca_type MT4115 hw_rev 0
	node_desc hpchead HCA-1 node_guid e41d:2d03:0066:dee6 node_type 1: CA reg_pages 0
	sys_image_guid e41d:2d03:0066:dee6
2: mlx5_1: board_id MT_2190110032 fw_pages 250793 fw_ver 12.17.2046 hca_type MT4115 hw_rev 0
	node_desc hpchead HCA-2 node_guid e41d:2d03:0066:dee7 node_type 1: CA reg_pages 0
	sys_image_guid e41d:2d03:0066:dee6
3: mlx5_2: board_id MT_1210110019 fw_pages 68067 fw_ver 10.16.1020 hca_type MT4113 hw_rev 0
	node_desc hpchead HCA-3 node_guid 0002:c903:0016:75b0 node_type 1: CA reg_pages 0
	sys_image_guid 0002:c903:0016:75b0

Print specific device:
 # rdma dev show mlx5_1
2: mlx5_1: board_id MT_2190110032 fw_pages 250793 fw_ver 12.17.2046 hca_type MT4115 hw_rev 0
	node_desc hpchead HCA-2 node_guid e41d:2d03:0066:dee7 node_type 1: CA reg_pages 0
	sys_image_guid e41d:2d03:0066:dee6

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 rdma/Makefile |   2 +-
 rdma/dev.c    | 101 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rdma/rdma.c   |   3 +-
 rdma/rdma.h   |   5 +++
 4 files changed, 109 insertions(+), 2 deletions(-)
 create mode 100644 rdma/dev.c

diff --git a/rdma/Makefile b/rdma/Makefile
index 65248b31..67e349b0 100644
--- a/rdma/Makefile
+++ b/rdma/Makefile
@@ -1,6 +1,6 @@
 include ../Config

-RDMA_OBJ = rdma.o utils.o
+RDMA_OBJ = rdma.o utils.o dev.o
 TARGETS=rdma

 all:	$(TARGETS) $(LIBS)
diff --git a/rdma/dev.c b/rdma/dev.c
new file mode 100644
index 00000000..e6d71035
--- /dev/null
+++ b/rdma/dev.c
@@ -0,0 +1,101 @@
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
+	pr_out("       %s dev set DEV [ node_desc { DESCRIPTION } ]\n", rd->filename);
+	/* Add masking of device capabilities */
+	return 0;
+}
+
+static void dev_one_show(const struct dev_map *dev_map)
+{
+	char *nodes[] = { "board_id",
+			  "fw_pages",
+			  "fw_ver",
+			  "hca_type",
+			  "hw_rev",
+			  "node_desc",
+			  "node_guid",
+			  "node_type",
+			  "reg_pages",
+			  "sys_image_guid",
+			  /* hfi1 specific */
+			  "nctxts",
+			  "nfreectxts",
+			  "serial",
+			  "boardversion",
+			  "tempsense",
+			  NULL };
+
+	char data[4096];
+	int i;
+	pr_out("%u: %s:", dev_map->idx, dev_map->dev_name);
+	for (i = 0 ; nodes[i] ; i++) {
+		if (rdma_sysfs_read_ib(dev_map->dev_name, 0, nodes[i], data))
+			continue;
+
+		/* Split line before "node_desc" */
+		if (!strcmp(nodes[i], "node_desc") ||
+		    !strcmp(nodes[i], "sys_image_guid"))
+			printf("\n\t");
+
+		pr_out(" %s %s", nodes[i], data);
+	}
+	pr_out("\n");
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
+static int dev_set(struct rdma *rd)
+{
+	/* Not implemented yet */
+	return 0;
+}
+
+int obj_dev(struct rdma *rd)
+{
+	const struct rdma_obj objs[] = {
+		{ NULL,		dev_show },
+		{ "show",	dev_show },
+		{ "list",	dev_show },
+		{ "set",	dev_set },
+		{ "help",	dev_help },
+		{ 0 }
+	};
+
+	if (dev_map_init(rd)) {
+		pr_err("There are no RDMA devices\n");
+		return -ENOENT;
+	}
+
+	return rdma_exec_cmd(rd, objs, "dev command");
+}
diff --git a/rdma/rdma.c b/rdma/rdma.c
index bc7d1483..7c537c5e 100644
--- a/rdma/rdma.c
+++ b/rdma/rdma.c
@@ -17,7 +17,7 @@
 static void help(char *name)
 {
 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
-	       "where  OBJECT := { }\n"
+	       "where  OBJECT := { dev }\n"
 	       "       OPTIONS := { -V[ersion] }\n", name);
 }

@@ -31,6 +31,7 @@ static int rd_cmd(struct rdma *rd)
 {
 	const struct rdma_obj objs[] = {
 		{ NULL,		obj_help },
+		{ "dev",	obj_dev },
 		{ "help",	obj_help },
 		{ 0 }
 	};
diff --git a/rdma/rdma.h b/rdma/rdma.h
index 156bb74c..2d81cd92 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -60,6 +60,11 @@ struct rdma_obj {
 };

 /*
+ * Command interfaces
+ */
+int obj_dev(struct rdma *rd);
+
+/*
  * Parser interface
  */
 bool rd_no_arg(struct rdma *rd);
