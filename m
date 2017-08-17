From: Leon Romanovsky <leonro@mellanox.com>
Subject: [PATCH REPOST v5 iproute2 6/8] rdma: Implement json output for dev object
Date: Thu, 17 Aug 2017 09:56:12 +0300
Message-ID: <20170817065614.1393-7-leonro@mellanox.com>
References: <20170817065614.1393-1-leonro@mellanox.com>
Cc: linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        David Laight <David.Laight@ACULAB.COM>,
        Linux Netdev <netdev@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57358 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752172AbdHQG4i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 02:56:38 -0400
In-Reply-To: <20170817065614.1393-1-leonro@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The example output for machine with two devices

root@mtr-leonro:~# rdma dev -j -p
[{
	"ifindex": 1,
	"ifname": "mlx5_0",
	"node_type": "ca",
	"fw": "2.8.9999",
	"node_guid": "5254:00c0:fe12:3457",
	"sys_image_guid": 5254:00c0:fe12:3457",
	"caps": [ "BAD_PKEY_CNTR", "BAD_QKEY_CNTR", "CHANGE_PHY_POR",
		  "PORT_ACTIVE_EVENT", "SYS_IMAGE_GUID", "RC_RNR_NAK_GEN",
		  "MEM_WINDOW", "UD_IP_CSUM", "UD_TSO", "XRC",
		  "MEM_MGT_EXTENSIONS", "BLOCK_MULTICAST_LOOPBACK",
		  "MEM_WINDOW_TYPE_2B", "RAW_IP_CSUM",
		  "MANAGED_FLOW_STEERING", "RESIZE_MAX_WR" ]
	},{
	"ifindex": 2,
	"ifname": mlx5_1,
	"node_type": "ca",
	"fw": "2.8.9999",
	"node_guid": "5254:00c0:fe12:3458",
	"sys_image_guid": "5254:00c0:fe12:3458",
	"caps": [ "BAD_PKEY_CNTR", "BAD_QKEY_CNTR", "CHANGE_PHY_POR",
		  "PORT_ACTIVE_EVENT", "SYS_IMAGE_GUID", "RC_RNR_NAK_GEN",
		  "MEM_WINDOW", "UD_IP_CSUM", "UD_TSO", "XRC",
		  "MEM_MGT_EXTENSIONS", "BLOCK_MULTICAST_LOOPBACK",
		  "MEM_WINDOW_TYPE_2B", "RAW_IP_CSUM",
		  "MANAGED_FLOW_STEERING", "RESIZE_MAX_WR" ]
	}
]

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 rdma/dev.c | 110 +++++++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 82 insertions(+), 28 deletions(-)

diff --git a/rdma/dev.c b/rdma/dev.c
index f6b55bae..9fadf3ac 100644
--- a/rdma/dev.c
+++ b/rdma/dev.c
@@ -66,7 +66,7 @@ static const char *dev_caps_to_str(uint32_t idx)
 	return "UNKNOWN";
 }

-static void dev_print_caps(struct nlattr **tb)
+static void dev_print_caps(struct rd *rd, struct nlattr **tb)
 {
 	uint64_t caps;
 	uint32_t idx;
@@ -76,48 +76,78 @@ static void dev_print_caps(struct nlattr **tb)

 	caps = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_CAP_FLAGS]);

-	pr_out("\n    caps: <");
+	if (rd->json_output) {
+		jsonw_name(rd->jw, "caps");
+		jsonw_start_array(rd->jw);
+	} else {
+		pr_out("\n    caps: <");
+	}
 	for (idx = 0; caps; idx++) {
 		if (caps & 0x1) {
-			pr_out("%s", dev_caps_to_str(idx));
-			if (caps >> 0x1)
-				pr_out(", ");
+			if (rd->json_output) {
+				jsonw_string(rd->jw, dev_caps_to_str(idx));
+			} else {
+				pr_out("%s", dev_caps_to_str(idx));
+				if (caps >> 0x1)
+					pr_out(", ");
+			}
 		}
 		caps >>= 0x1;
 	}

-	pr_out(">");
+	if (rd->json_output)
+		jsonw_end_array(rd->jw);
+	else
+		pr_out(">");
 }

-static void dev_print_fw(struct nlattr **tb)
+static void dev_print_fw(struct rd *rd, struct nlattr **tb)
 {
+	const char *str;
 	if (!tb[RDMA_NLDEV_ATTR_FW_VERSION])
 		return;

-	pr_out("fw %s ",
-	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_FW_VERSION]));
+	str = mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_FW_VERSION]);
+	if (rd->json_output)
+		jsonw_string_field(rd->jw, "fw", str);
+	else
+		pr_out("fw %s ", str);
 }

-static void dev_print_node_guid(struct nlattr **tb)
+static void dev_print_node_guid(struct rd *rd, struct nlattr **tb)
 {
 	uint64_t node_guid;
+	uint16_t vp[4];
+	char str[32];

 	if (!tb[RDMA_NLDEV_ATTR_NODE_GUID])
 		return;

 	node_guid = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_NODE_GUID]);
-	rd_print_u64("node_guid", node_guid);
+	memcpy(vp, &node_guid, sizeof(uint64_t));
+	snprintf(str, 32, "%04x:%04x:%04x:%04x", vp[3], vp[2], vp[1], vp[0]);
+	if (rd->json_output)
+		jsonw_string_field(rd->jw, "node_guid", str);
+	else
+		pr_out("node_guid %s ", str);
 }

-static void dev_print_sys_image_guid(struct nlattr **tb)
+static void dev_print_sys_image_guid(struct rd *rd, struct nlattr **tb)
 {
 	uint64_t sys_image_guid;
+	uint16_t vp[4];
+	char str[32];

 	if (!tb[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID])
 		return;

 	sys_image_guid = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_SYS_IMAGE_GUID]);
-	rd_print_u64("sys_image_guid", sys_image_guid);
+	memcpy(vp, &sys_image_guid, sizeof(uint64_t));
+	snprintf(str, 32, "%04x:%04x:%04x:%04x", vp[3], vp[2], vp[1], vp[0]);
+	if (rd->json_output)
+		jsonw_string_field(rd->jw, "sys_image_guid", str);
+	else
+		pr_out("sys_image_guid %s ", str);
 }

 static const char *node_type_to_str(uint8_t node_type)
@@ -131,37 +161,51 @@ static const char *node_type_to_str(uint8_t node_type)
 	return "unknown";
 }

-static void dev_print_node_type(struct nlattr **tb)
+static void dev_print_node_type(struct rd *rd, struct nlattr **tb)
 {
+	const char *node_str;
 	uint8_t node_type;

 	if (!tb[RDMA_NLDEV_ATTR_DEV_NODE_TYPE])
 		return;

 	node_type = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_DEV_NODE_TYPE]);
-	pr_out("node_type %s ", node_type_to_str(node_type));
+	node_str = node_type_to_str(node_type);
+	if (rd->json_output)
+		jsonw_string_field(rd->jw, "node_type", node_str);
+	else
+		pr_out("node_type %s ", node_str);
 }

 static int dev_parse_cb(const struct nlmsghdr *nlh, void *data)
 {
 	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
 	struct rd *rd = data;
+	const char *name;
+	uint32_t idx;

 	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
 	if (!tb[RDMA_NLDEV_ATTR_DEV_INDEX] || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
 		return MNL_CB_ERROR;

-	pr_out("%u: %s: ",
-	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]),
-	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]));
-	dev_print_node_type(tb);
-	dev_print_fw(tb);
-	dev_print_node_guid(tb);
-	dev_print_sys_image_guid(tb);
+	idx =  mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
+	name = mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]);
+	if (rd->json_output) {
+		jsonw_uint_field(rd->jw, "ifindex", idx);
+		jsonw_string_field(rd->jw, "ifname", name);
+	} else {
+		pr_out("%u: %s: ", idx, name);
+	}
+
+	dev_print_node_type(rd, tb);
+	dev_print_fw(rd, tb);
+	dev_print_node_guid(rd, tb);
+	dev_print_sys_image_guid(rd, tb);
 	if (rd->show_details)
-		dev_print_caps(tb);
+		dev_print_caps(rd, tb);

-	pr_out("\n");
+	if (!rd->json_output)
+		pr_out("\n");
 	return MNL_CB_OK;
 }

@@ -177,7 +221,12 @@ static int dev_no_args(struct rd *rd)
 	if (ret)
 		return ret;

-	return rd_recv_msg(rd, dev_parse_cb, rd, seq);
+	if (rd->json_output)
+		jsonw_start_object(rd->jw);
+	ret = rd_recv_msg(rd, dev_parse_cb, rd, seq);
+	if (rd->json_output)
+		jsonw_end_object(rd->jw);
+	return ret;
 }

 static int dev_one_show(struct rd *rd)
@@ -195,24 +244,29 @@ static int dev_show(struct rd *rd)
 	struct dev_map *dev_map;
 	int ret = 0;

+	if (rd->json_output)
+		jsonw_start_array(rd->jw);
 	if (rd_no_arg(rd)) {
 		list_for_each_entry(dev_map, &rd->dev_map_list, list) {
 			rd->dev_idx = dev_map->idx;
 			ret = dev_one_show(rd);
 			if (ret)
-				return ret;
+				goto out;
 		}
-
 	} else {
 		dev_map = dev_map_lookup(rd, false);
 		if (!dev_map) {
 			pr_err("Wrong device name\n");
-			return -ENOENT;
+			ret = -ENOENT;
+			goto out;
 		}
 		rd_arg_inc(rd);
 		rd->dev_idx = dev_map->idx;
 		ret = dev_one_show(rd);
 	}
+out:
+	if (rd->json_output)
+		jsonw_end_array(rd->jw);
 	return ret;
 }
