From: Leon Romanovsky <leon@kernel.org>
Subject: [RFC iproute2 3/8] rdma: Add link object
Date: Thu,  4 May 2017 21:02:11 +0300
Message-ID: <20170504180216.7665-4-leon@kernel.org>
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
Received: from mail.kernel.org ([198.145.29.136]:58546 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755564AbdEDSCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 14:02:25 -0400
In-Reply-To: <20170504180216.7665-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

Link object represents port of struct ib_device.

Supported commands are show, set and help.

Print all links for all devices:
 # rdma link
1/1: mlx5_0/1: ifname ib0 cap_mask 0x2651e848 lid 0x13 lid_mask_count 0 link_layer InfiniBand
	phys_state 5: LinkUp rate 100 Gb/sec (4X EDR) sm_lid 0x2 sm_sl 0 state 4: ACTIVE
2/1: mlx5_1/1: ifname ib1 cap_mask 0x2651e848 lid 0xffff lid_mask_count 0 link_layer InfiniBand
	phys_state 3: Disabled rate 10 Gb/sec (4X) sm_lid 0x0 sm_sl 0 state 1: DOWN
3/1: mlx5_2/1: ifname ib2 cap_mask 0x26516848 lid 0x1a lid_mask_count 0 link_layer InfiniBand
	phys_state 5: LinkUp rate 56 Gb/sec (4X FDR) sm_lid 0x2 sm_sl 0 state 4: ACTIVE
3/2: mlx5_2/2: ifname ib3 cap_mask 0x26516848 lid 0xffff lid_mask_count 0 link_layer InfiniBand
	phys_state 3: Disabled rate 10 Gb/sec (4X) sm_lid 0x0 sm_sl 0 state 1: DOWN

Print all links for specific device:
 # rdma link show mlx5_2
3/1: mlx5_2/1: ifname ib2 cap_mask 0x26516848 lid 0x1a lid_mask_count 0 link_layer InfiniBand
	phys_state 5: LinkUp rate 56 Gb/sec (4X FDR) sm_lid 0x2 sm_sl 0 state 4: ACTIVE
3/2: mlx5_2/2: ifname ib3 cap_mask 0x26516848 lid 0xffff lid_mask_count 0 link_layer InfiniBand
	phys_state 3: Disabled rate 10 Gb/sec (4X) sm_lid 0x0 sm_sl 0 state 1: DOWN

Print specific link:
 # rdma link show mlx5_2/2
3/2: mlx5_2/2: ifname ib3 cap_mask 0x26516848 lid 0xffff lid_mask_count 0 link_layer InfiniBand
	phys_state 3: Disabled rate 10 Gb/sec (4X) sm_lid 0x0 sm_sl 0 state 1: DOWN

Set parameter;
 # rdma link set mlx5_2/2 type auto lb_unicast off

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 rdma/Makefile |   2 +-
 rdma/link.c   | 112 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 rdma/rdma.c   |   3 +-
 rdma/rdma.h   |   1 +
 4 files changed, 116 insertions(+), 2 deletions(-)
 create mode 100644 rdma/link.c

diff --git a/rdma/Makefile b/rdma/Makefile
index 67e349b0..cf54ed36 100644
--- a/rdma/Makefile
+++ b/rdma/Makefile
@@ -1,6 +1,6 @@
 include ../Config

-RDMA_OBJ = rdma.o utils.o dev.o
+RDMA_OBJ = rdma.o utils.o dev.o link.o
 TARGETS=rdma

 all:	$(TARGETS) $(LIBS)
diff --git a/rdma/link.c b/rdma/link.c
new file mode 100644
index 00000000..e86ff399
--- /dev/null
+++ b/rdma/link.c
@@ -0,0 +1,112 @@
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
+	pr_out("Usage: %s link show [ DEV | DEV/PORT ]\n", rd->filename);
+	pr_out("       %s link set DEV/PORT { type { eth | ib | auto } |\n", rd->filename);
+	pr_out("                                lb_unicast { on | off } |\n");
+	pr_out("                                lb_multicast { on | off } }\n");
+	return 0;
+}
+
+static void dev_one_show(const struct dev_map *dev_map, uint32_t port_idx_first, uint32_t port_idx_last)
+{
+	char *nodes[] = { "cap_mask",
+			  "lid",
+			  "lid_mask_count",
+			  "link_layer",
+			  "phys_state",
+			  "rate",
+			  "sm_lid",
+			  "sm_sl",
+			  "state",
+       			  NULL };
+
+	struct port_map *port_map;
+	char data[4096];
+	int i, j;
+
+	for(j = port_idx_first ; j <= port_idx_last; j++) {
+		pr_out("%u/%u: %s/%u:", dev_map->idx, j, dev_map->dev_name, j);
+		list_for_each_entry(port_map, &dev_map->port_map_list, list)
+			if (j == port_map->idx)
+			       printf(" ifname %s", (port_map->ifname)?:"NONE");
+
+		for (i = 0 ; nodes[i] ; i++) {
+			if (rdma_sysfs_read_ib(dev_map->dev_name, j, nodes[i], data))
+				continue;
+
+			/* Split line before "phys_state" */
+			if (!strcmp(nodes[i], "phys_state"))
+				printf("\n\t");
+
+			pr_out(" %s %s", nodes[i], data);
+		}
+		pr_out("\n");
+	}
+}
+
+static int link_show(struct rdma *rd)
+{
+	struct dev_map *dev_map;
+
+	if (rd_no_arg(rd)) {
+		list_for_each_entry(dev_map, &rd->dev_map_list, list)
+			dev_one_show(dev_map, 1, dev_map->num_ports);
+	}
+	else {
+		uint32_t port_idx;
+		uint32_t num_ports;
+		dev_map = dev_map_lookup(rd, true);
+		port_idx = get_port_from_argv(rd);
+		if (!dev_map || port_idx > dev_map->num_ports) {
+			pr_err("Wrong device name\n");
+			return -EINVAL;
+		}
+		if (port_idx)
+			num_ports = port_idx;
+		else {
+			port_idx = 1;
+			num_ports = dev_map->num_ports;
+		}
+
+		dev_one_show(dev_map, port_idx, num_ports);
+	}
+	return 0;
+}
+
+static int link_set(struct rdma *rd)
+{
+	/* Not supported yet */
+	return 0;
+}
+
+int obj_link(struct rdma *rd)
+{
+	const struct rdma_obj objs[] = {
+		{ NULL, 	link_show },
+		{ "show",	link_show },
+		{ "list",	link_show },
+		{ "set",	link_set },
+		{ "help",	link_help },
+		{ 0 }
+	};
+
+	if (dev_map_init(rd)) {
+		pr_err("There are no RDMA devices\n");
+		return -ENOENT;
+	}
+
+	return rdma_exec_cmd(rd, objs, "link command");
+}
diff --git a/rdma/rdma.c b/rdma/rdma.c
index 7c537c5e..55cbf0e3 100644
--- a/rdma/rdma.c
+++ b/rdma/rdma.c
@@ -17,7 +17,7 @@
 static void help(char *name)
 {
 	pr_out("Usage: %s [ OPTIONS ] OBJECT { COMMAND | help }\n"
-	       "where  OBJECT := { dev }\n"
+	       "where  OBJECT := { dev | link }\n"
 	       "       OPTIONS := { -V[ersion] }\n", name);
 }

@@ -32,6 +32,7 @@ static int rd_cmd(struct rdma *rd)
 	const struct rdma_obj objs[] = {
 		{ NULL,		obj_help },
 		{ "dev",	obj_dev },
+		{ "link",	obj_link },
 		{ "help",	obj_help },
 		{ 0 }
 	};
diff --git a/rdma/rdma.h b/rdma/rdma.h
index 2d81cd92..bdb77b5e 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -63,6 +63,7 @@ struct rdma_obj {
  * Command interfaces
  */
 int obj_dev(struct rdma *rd);
+int obj_link(struct rdma *rd);

 /*
  * Parser interface
