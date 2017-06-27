From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH iproute2 V1 5/6] rdma: Add FW version to the device output
Date: Tue, 27 Jun 2017 17:39:19 +0300
Message-ID: <20170627143920.28020-6-leon@kernel.org>
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

$ rdma dev show mlx5_4
5: mlx5_4: fw 2.8.9999
    caps: <BAD_PKEY_CNTR, BAD_QKEY_CNTR, CHANGE_PHY_PORT, PORT_ACTIVE_EVENT, SYS_IMAGE_GUID, RC_RNR_NAK_GEN, MEM_WINDOW, UD_IP_CSUM, UD_TSO, XRC, MEM_MGT_EXTENSIONS, BLOCK_MULTICAST_LOOPBACK, MEM_WINDOW_TYPE_2B, RAW_IP_CSUM, SIGNATURE_HANDOVER, VIRTUAL_FUNCTION>

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 rdma/dev.c   | 9 ++++++++-
 rdma/rdma.h  | 1 +
 rdma/utils.c | 4 ++++
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/rdma/dev.c b/rdma/dev.c
index 76f4af88..45dc0b3f 100644
--- a/rdma/dev.c
+++ b/rdma/dev.c
@@ -83,7 +83,14 @@ static int dev_no_args(struct rdma *rd)
 {
 	struct dev_map *dev_map = rd->dev_map_curr;
 
-	pr_out("%u: %s: \n", dev_map->idx, dev_map->dev_name);
+	pr_out("%u: %s: ", dev_map->idx, dev_map->dev_name);
+	if (strlen(dev_map->fw_version) < 1)
+		/*
+		 * if no FW, the return string from RDMA netlink is "\0"
+		 */
+		pr_out("fw NONE\n");
+	else
+		pr_out("fw %s\n", dev_map->fw_version);
 	return dev_print_caps(rd);
 }
 
diff --git a/rdma/rdma.h b/rdma/rdma.h
index 553a4fc2..f221575e 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -36,6 +36,7 @@ struct dev_map {
 	struct list_head port_map_list;
 	uint32_t idx;
 	uint64_t caps;
+	char *fw_version;
 };
 
 struct rdma {
diff --git a/rdma/utils.c b/rdma/utils.c
index 68ae3d3e..47a6ab11 100644
--- a/rdma/utils.c
+++ b/rdma/utils.c
@@ -104,6 +104,7 @@ static void dev_map_free(struct dev_map *dev_map)
 		port_map_free(port_map);
 	}
 
+	free(dev_map->fw_version);
 	free(dev_map->dev_name);
 	free(dev_map);
 }
@@ -141,6 +142,7 @@ static const enum mnl_attr_data_type nldev_policy[RDMA_NLDEV_ATTR_MAX] = {
 	[RDMA_NLDEV_ATTR_DEV_NAME] = MNL_TYPE_NUL_STRING,
 	[RDMA_NLDEV_ATTR_PORT_INDEX] = MNL_TYPE_U32,
 	[RDMA_NLDEV_ATTR_CAP_FLAGS] = MNL_TYPE_U64,
+	[RDMA_NLDEV_ATTR_FW_VERSION] = MNL_TYPE_NUL_STRING,
 };
 
 int rd_attr_cb(const struct nlattr *attr, void *data)
@@ -190,6 +192,8 @@ int rd_dev_init_cb(const struct nlmsghdr *nlh, void *data)
 	dev_map->idx = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
 	dev_map->caps = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_CAP_FLAGS]);
 
+	dev_map->fw_version = strdup(mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_FW_VERSION]));
+
 	return MNL_CB_OK;
 }
 
-- 
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
