From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH iproute2 3/5] rdma: Add device capability parsing
Date: Mon, 26 Jun 2017 21:21:26 +0300
Message-ID: <20170626182128.24964-4-leon@kernel.org>
References: <20170626182128.24964-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170626182128.24964-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add parsing interface for the device capability flags

$ rdma dev show
1: mlx5_0: caps 0x1257e1c26
2: mlx5_1: caps 0x1257e1c26
3: mlx5_2: caps 0x1257e1c26
4: mlx5_3: caps 0x1257e1c26
5: mlx5_4: caps 0x1257e1c26

$ rdma dev show mlx5_4
5: mlx5_4: caps 0x1257e1c26

$ rdma dev show mlx5_4 caps
5: mlx5_4: caps 0x1257e1c26
Bit	Description
------------------------------------------
 01	DEVICE_BAD_PKEY_CNTR
 02	DEVICE_BAD_QKEY_CNTR
 05	DEVICE_CHANGE_PHY_PORT
 10	DEVICE_PORT_ACTIVE_EVENT
 11	DEVICE_SYS_IMAGE_GUID
 12	DEVICE_RC_RNR_NAK_GEN
 17	DEVICE_MEM_WINDOW
 18	DEVICE_UD_IP_CSUM
 19	DEVICE_UD_TSO
 20	DEVICE_XRC
 21	DEVICE_MEM_MGT_EXTENSIONS
 22	DEVICE_BLOCK_MULTICAST_LOOPBACK
 24	DEVICE_MEM_WINDOW_TYPE_2B
 26	DEVICE_RAW_IP_CSUM
 29	DEVICE_SIGNATURE_HANDOVER
 32	DEVICE_VIRTUAL_FUNCTION

$ rdma dev show mlx5_4 cap_flags
Unknown parameter 'caps_flags'.

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 rdma/dev.c   | 96 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 rdma/rdma.h  |  3 ++
 rdma/utils.c |  3 +-
 3 files changed, 93 insertions(+), 9 deletions(-)

diff --git a/rdma/dev.c b/rdma/dev.c
index 5a3ee126..31c235e8 100644
--- a/rdma/dev.c
+++ b/rdma/dev.c
@@ -14,6 +14,7 @@
 static int dev_help(struct rdma *rd)
 {
 	pr_out("Usage: %s dev show [DEV]\n", rd->filename);
+	pr_out("       %s dev show DEV caps\n", rd->filename);

 	/*
 	 * Example of set command:
@@ -22,28 +23,107 @@ static int dev_help(struct rdma *rd)
 	return 0;
 }

-static void dev_one_show(const struct dev_map *dev_map)
+static const char *dev_caps[64] = {
+	"DEVICE_RESIZE_MAX_WR",
+	"DEVICE_BAD_PKEY_CNTR",
+	"DEVICE_BAD_QKEY_CNTR",
+	"DEVICE_RAW_MULTI",
+	"DEVICE_AUTO_PATH_MIG",
+	"DEVICE_CHANGE_PHY_PORT",
+	"DEVICE_UD_AV_PORT_ENFORCE",
+	"DEVICE_CURR_QP_STATE_MOD",
+	"DEVICE_SHUTDOWN_PORT",
+	"DEVICE_INIT_TYPE",
+	"DEVICE_PORT_ACTIVE_EVENT",
+	"DEVICE_SYS_IMAGE_GUID",
+	"DEVICE_RC_RNR_NAK_GEN",
+	"DEVICE_SRQ_RESIZE",
+	"DEVICE_N_NOTIFY_CQ",
+	"DEVICE_LOCAL_DMA_LKEY",
+	"DEVICE_RESERVED",
+	"DEVICE_MEM_WINDOW",
+	"DEVICE_UD_IP_CSUM",
+	"DEVICE_UD_TSO",
+	"DEVICE_XRC",
+	"DEVICE_MEM_MGT_EXTENSIONS",
+	"DEVICE_BLOCK_MULTICAST_LOOPBACK",
+	"DEVICE_MEM_WINDOW_TYPE_2A",
+	"DEVICE_MEM_WINDOW_TYPE_2B",
+	"DEVICE_RC_IP_CSUM",
+	"DEVICE_RAW_IP_CSUM",
+	"DEVICE_CROSS_CHANNEL",
+	"DEVICE_MANAGED_FLOW_STEERING",
+	"DEVICE_SIGNATURE_HANDOVER",
+	"DEVICE_ON_DEMAND_PAGING",
+	"DEVICE_SG_GAPS_REG",
+	"DEVICE_VIRTUAL_FUNCTION",
+	"DEVICE_RAW_SCATTER_FCS",
+	"DEVICE_RDMA_NETDEV_OPA_VNIC",
+};
+
+static int dev_print_caps(struct rdma *rd)
+{
+	struct dev_map *dev_map = rd->dev_map_curr;
+	uint64_t caps = dev_map->caps;
+	uint32_t idx;
+
+	pr_out("%u: %s: ", dev_map->idx, dev_map->dev_name);
+	pr_out("caps 0x%" PRIx64 "\n", dev_map->caps);
+	pr_out("Bit\tDescription\n");
+	pr_out("------------------------------------------\n");
+	for (idx = 0; idx < 64; idx++) {
+		if (caps & 0x1)
+			pr_out(" %02u\t%s\n", idx, dev_caps[idx]?dev_caps[idx]:"UNKNONW");
+		caps >>= 0x1;
+	}
+	return 0;
+}
+
+static int dev_no_args(struct rdma *rd)
+{
+	struct dev_map *dev_map = rd->dev_map_curr;
+
+	pr_out("%u: %s: ", dev_map->idx, dev_map->dev_name);
+	pr_out("caps 0x%" PRIx64 "\n", dev_map->caps);
+	return 0;
+}
+
+static int dev_one_show(struct rdma *rd)
 {
-	pr_out("%u: %s:\n", dev_map->idx, dev_map->dev_name);
+	const struct rdma_cmd cmds[] = {
+		{ NULL,		dev_no_args},
+		{ "caps",	dev_print_caps},
+		{ 0 }
+	};
+
+	return rdma_exec_cmd(rd, cmds, "parameter");
+
 }

 static int dev_show(struct rdma *rd)
 {
 	struct dev_map *dev_map;
+	int ret = 0;

 	if (rd_no_arg(rd)) {
-		list_for_each_entry(dev_map, &rd->dev_map_list, list)
-			dev_one_show(dev_map);
+		list_for_each_entry(dev_map, &rd->dev_map_list, list) {
+			rd->dev_map_curr = dev_map;
+			ret = dev_one_show(rd);
+			if (ret)
+				return ret;
+		}
+
 	}
 	else {
-		dev_map = dev_map_lookup(rd, false);
-		if (!dev_map) {
+		rd->dev_map_curr = dev_map_lookup(rd, false);
+		if (!rd->dev_map_curr) {
 			pr_err("Wrong device name\n");
 			return -ENOENT;
 		}
-		dev_one_show(dev_map);
+		rd_arg_inc(rd);
+		ret = dev_one_show(rd);
 	}
-	return 0;
+	return ret;
 }

 int cmd_dev(struct rdma *rd)
diff --git a/rdma/rdma.h b/rdma/rdma.h
index f5e104ec..8cca0f28 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -34,6 +34,7 @@ struct dev_map {
 	uint32_t num_ports;
 	struct list_head port_map_list;
 	uint32_t idx;
+	uint64_t caps;
 };

 struct rdma {
@@ -41,6 +42,7 @@ struct rdma {
 	char **argv;
 	char *filename;
 	struct list_head dev_map_list;
+	struct dev_map *dev_map_curr;
 	struct mnl_socket *nl;
 	struct nlmsghdr *nlh;
 	char *buff;
@@ -57,6 +59,7 @@ struct rdma_cmd {
 bool rd_no_arg(struct rdma *rd);
 bool rd_argv_match(struct rdma *rd, const char *pattern);
 void rd_arg_inc(struct rdma *rd);
+char *rd_argv(struct rdma *rd);

 /*
  * Commands interface
diff --git a/rdma/utils.c b/rdma/utils.c
index e5c3dd6c..e7f257e3 100644
--- a/rdma/utils.c
+++ b/rdma/utils.c
@@ -28,7 +28,7 @@ static int rd_argc(struct rdma *rd)
 	return rd->argc;
 }

-static char *rd_argv(struct rdma *rd)
+char *rd_argv(struct rdma *rd)
 {
 	if (!rd_argc(rd))
 		return NULL;
@@ -128,6 +128,7 @@ static int port_map_alloc(struct dev_map *dev_map, uint32_t num_ports)
 }

 static const enum mnl_attr_data_type nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
+	[RDMA_NLDEV_ATTR_DEV_INDEX] = MNL_TYPE_U32,
 	[RDMA_NLDEV_ATTR_DEV_NAME] = MNL_TYPE_NUL_STRING,
 	[RDMA_NLDEV_ATTR_PORT_INDEX] = MNL_TYPE_U32,
 };
--
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
