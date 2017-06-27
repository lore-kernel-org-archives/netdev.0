From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH iproute2 V1 3/6] rdma: Add device capability parsing
Date: Tue, 27 Jun 2017 17:39:17 +0300
Message-ID: <20170627143920.28020-4-leon@kernel.org>
References: <20170627143920.28020-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170627143920.28020-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add parsing interface for the device capability flags

$ rdma dev show
1: mlx5_0:
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
2: mlx5_1:
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
3: mlx5_2:
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
4: mlx5_3:
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
5: mlx5_4:
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>
root@mtr-leonro:~#

$ rdma dev show mlx5_4
5: mlx5_4:
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 rdma/dev.c   | 99 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 rdma/rdma.h  |  3 ++
 rdma/utils.c |  2 +-
 3 files changed, 95 insertions(+), 9 deletions(-)

diff --git a/rdma/dev.c b/rdma/dev.c
index d4809d63..76f4af88 100644
--- a/rdma/dev.c
+++ b/rdma/dev.c
@@ -17,28 +17,111 @@ static int dev_help(struct rdma *rd)
 	return 0;
 }
 
-static void dev_one_show(const struct dev_map *dev_map)
+static const char *dev_caps[64] = {
+	"RESIZE_MAX_WR",
+	"BAD_PKEY_CNTR",
+	"BAD_QKEY_CNTR",
+	"RAW_MULTI",
+	"AUTO_PATH_MIG",
+	"CHANGE_PHY_PORT",
+	"UD_AV_PORT_ENFORCE",
+	"CURR_QP_STATE_MOD",
+	"SHUTDOWN_PORT",
+	"INIT_TYPE",
+	"PORT_ACTIVE_EVENT",
+	"SYS_IMAGE_GUID",
+	"RC_RNR_NAK_GEN",
+	"SRQ_RESIZE",
+	"N_NOTIFY_CQ",
+	"LOCAL_DMA_LKEY",
+	"RESERVED",
+	"MEM_WINDOW",
+	"UD_IP_CSUM",
+	"UD_TSO",
+	"XRC",
+	"MEM_MGT_EXTENSIONS",
+	"BLOCK_MULTICAST_LOOPBACK",
+	"MEM_WINDOW_TYPE_2A",
+	"MEM_WINDOW_TYPE_2B",
+	"RC_IP_CSUM",
+	"RAW_IP_CSUM",
+	"CROSS_CHANNEL",
+	"MANAGED_FLOW_STEERING",
+	"SIGNATURE_HANDOVER",
+	"ON_DEMAND_PAGING",
+	"SG_GAPS_REG",
+	"VIRTUAL_FUNCTION",
+	"RAW_SCATTER_FCS",
+	"RDMA_NETDEV_OPA_VNIC",
+};
+
+static int dev_print_caps(struct rdma *rd)
 {
-	pr_out("%u: %s:\n", dev_map->idx, dev_map->dev_name);
+	struct dev_map *dev_map = rd->dev_map_curr;
+	uint64_t caps = dev_map->caps;
+	bool found = false;
+	uint32_t idx;
+
+	pr_out("    caps: <");
+	for (idx = 0; idx < 64; idx++) {
+		if (caps & 0x1) {
+			pr_out("%s", dev_caps[idx]?dev_caps[idx]:"UNKNONW");
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
+static int dev_no_args(struct rdma *rd)
+{
+	struct dev_map *dev_map = rd->dev_map_curr;
+
+	pr_out("%u: %s: \n", dev_map->idx, dev_map->dev_name);
+	return dev_print_caps(rd);
+}
+
+static int dev_one_show(struct rdma *rd)
+{
+	const struct rdma_cmd cmds[] = {
+		{ NULL,		dev_no_args},
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
index 4d29eced..94737c5c 100644
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
-- 
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
