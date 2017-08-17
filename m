From: Leon Romanovsky <leonro@mellanox.com>
Subject: [PATCH REPOST v5 iproute2 7/8] rdma: Add json output to link object
Date: Thu, 17 Aug 2017 09:56:13 +0300
Message-ID: <20170817065614.1393-8-leonro@mellanox.com>
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
Received: from mail.kernel.org ([198.145.29.99]:57392 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752204AbdHQG4l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 02:56:41 -0400
In-Reply-To: <20170817065614.1393-1-leonro@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An example for the JSON output for two devices system.

root@mtr-leonro:~# rdma link -d -p -j
[{
        "ifindex": 1,
        "port": 1,
        "ifname": "mlx5_0/1",
        "subnet_prefix": "fe80:0000:0000:0000",
        "lid": 13399,
        "sm_lid": 49151,
        "lmc": 0,
        "state": "ACTIVE",
        "physical_state": "LINK_UP",
        "caps": ["AUTO_MIG"
        ]
    },{
        "ifindex": 2,
        "port": 1,
        "ifname": "mlx5_1/1",
        "subnet_prefix": "fe80:0000:0000:0000",
        "lid": 13400,
        "sm_lid": 49151,
        "lmc": 0,
        "state": "ACTIVE",
        "physical_state": "LINK_UP",
        "caps": ["AUTO_MIG"
        ]
    }
]

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 rdma/link.c  | 144 +++++++++++++++++++++++++++++++++++++++++++----------------
 rdma/rdma.h  |   1 -
 rdma/utils.c |   8 ----
 3 files changed, 105 insertions(+), 48 deletions(-)

diff --git a/rdma/link.c b/rdma/link.c
index b0e5bee0..eae96cd8 100644
--- a/rdma/link.c
+++ b/rdma/link.c
@@ -56,7 +56,7 @@ static const char *caps_to_str(uint32_t idx)
 	return "UNKNOWN";
 }

-static void link_print_caps(struct nlattr **tb)
+static void link_print_caps(struct rd *rd, struct nlattr **tb)
 {
 	uint64_t caps;
 	uint32_t idx;
@@ -66,54 +66,89 @@ static void link_print_caps(struct nlattr **tb)

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
-			pr_out("%s", caps_to_str(idx));
-			if (caps >> 0x1)
-				pr_out(", ");
+			if (rd->json_output) {
+				jsonw_string(rd->jw, caps_to_str(idx));
+			} else {
+				pr_out("%s", caps_to_str(idx));
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

-static void link_print_subnet_prefix(struct nlattr **tb)
+static void link_print_subnet_prefix(struct rd *rd, struct nlattr **tb)
 {
 	uint64_t subnet_prefix;
+	uint16_t vp[4];
+	char str[32];

 	if (!tb[RDMA_NLDEV_ATTR_SUBNET_PREFIX])
 		return;

 	subnet_prefix = mnl_attr_get_u64(tb[RDMA_NLDEV_ATTR_SUBNET_PREFIX]);
-	rd_print_u64("subnet_prefix", subnet_prefix);
+	memcpy(vp, &subnet_prefix, sizeof(uint64_t));
+	snprintf(str, 32, "%04x:%04x:%04x:%04x", vp[3], vp[2], vp[1], vp[0]);
+	if (rd->json_output)
+		jsonw_string_field(rd->jw, "subnet_prefix", str);
+	else
+		pr_out("subnet_prefix %s ", str);
 }

-static void link_print_lid(struct nlattr **tb)
+static void link_print_lid(struct rd *rd, struct nlattr **tb)
 {
+	uint32_t lid;
+
 	if (!tb[RDMA_NLDEV_ATTR_LID])
 		return;

-	pr_out("lid %u ",
-	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_LID]));
+	lid = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_LID]);
+	if (rd->json_output)
+		jsonw_uint_field(rd->jw, "lid", lid);
+	else
+		pr_out("lid %u ", lid);
 }

-static void link_print_sm_lid(struct nlattr **tb)
+static void link_print_sm_lid(struct rd *rd, struct nlattr **tb)
 {
+	uint32_t sm_lid;
+
 	if (!tb[RDMA_NLDEV_ATTR_SM_LID])
 		return;

-	pr_out("sm_lid %u ",
-	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_SM_LID]));
+	sm_lid = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_SM_LID]);
+	if (rd->json_output)
+		jsonw_uint_field(rd->jw, "sm_lid", sm_lid);
+	else
+		pr_out("sm_lid %u ", sm_lid);
 }

-static void link_print_lmc(struct nlattr **tb)
+static void link_print_lmc(struct rd *rd, struct nlattr **tb)
 {
+	uint8_t lmc;
+
 	if (!tb[RDMA_NLDEV_ATTR_LMC])
 		return;

-	pr_out("lmc %u ", mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_LMC]));
+	lmc = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_LMC]);
+	if (rd->json_output)
+		jsonw_uint_field(rd->jw, "lmc", lmc);
+	else
+		pr_out("lmc %u ", lmc);
 }

 static const char *link_state_to_str(uint8_t link_state)
@@ -127,7 +162,7 @@ static const char *link_state_to_str(uint8_t link_state)
 	return "UNKNOWN";
 }

-static void link_print_state(struct nlattr **tb)
+static void link_print_state(struct rd *rd, struct nlattr **tb)
 {
 	uint8_t state;

@@ -135,7 +170,10 @@ static void link_print_state(struct nlattr **tb)
 		return;

 	state = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_PORT_STATE]);
-	pr_out("state %s ", link_state_to_str(state));
+	if (rd->json_output)
+		jsonw_string_field(rd->jw, "state", link_state_to_str(state));
+	else
+		pr_out("state %s ", link_state_to_str(state));
 }

 static const char *phys_state_to_str(uint8_t phys_state)
@@ -152,7 +190,7 @@ static const char *phys_state_to_str(uint8_t phys_state)
 	return "UNKNOWN";
 };

-static void link_print_phys_state(struct nlattr **tb)
+static void link_print_phys_state(struct rd *rd, struct nlattr **tb)
 {
 	uint8_t phys_state;

@@ -160,13 +198,19 @@ static void link_print_phys_state(struct nlattr **tb)
 		return;

 	phys_state = mnl_attr_get_u8(tb[RDMA_NLDEV_ATTR_PORT_PHYS_STATE]);
-	pr_out("physical_state %s ", phys_state_to_str(phys_state));
+	if (rd->json_output)
+		jsonw_string_field(rd->jw, "physical_state",
+				   phys_state_to_str(phys_state));
+	else
+		pr_out("physical_state %s ", phys_state_to_str(phys_state));
 }

 static int link_parse_cb(const struct nlmsghdr *nlh, void *data)
 {
 	struct nlattr *tb[RDMA_NLDEV_ATTR_MAX] = {};
 	struct rd *rd = data;
+	uint32_t port, idx;
+	char name[32];

 	mnl_attr_parse(nlh, 0, rd_attr_cb, tb);
 	if (!tb[RDMA_NLDEV_ATTR_DEV_INDEX] || !tb[RDMA_NLDEV_ATTR_DEV_NAME])
@@ -177,21 +221,31 @@ static int link_parse_cb(const struct nlmsghdr *nlh, void *data)
 		return MNL_CB_ERROR;
 	}

-	pr_out("%u/%u: %s/%u: ",
-	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]),
-	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]),
-	       mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]),
-	       mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]));
-	link_print_subnet_prefix(tb);
-	link_print_lid(tb);
-	link_print_sm_lid(tb);
-	link_print_lmc(tb);
-	link_print_state(tb);
-	link_print_phys_state(tb);
+	idx = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_DEV_INDEX]);
+	port = mnl_attr_get_u32(tb[RDMA_NLDEV_ATTR_PORT_INDEX]);
+	snprintf(name, 32, "%s/%u",
+		 mnl_attr_get_str(tb[RDMA_NLDEV_ATTR_DEV_NAME]), port);
+
+	if (rd->json_output) {
+		jsonw_uint_field(rd->jw, "ifindex", idx);
+		jsonw_uint_field(rd->jw, "port", port);
+		jsonw_string_field(rd->jw, "ifname", name);
+
+	} else {
+		pr_out("%u/%u: %s: ", idx, port, name);
+	}
+
+	link_print_subnet_prefix(rd, tb);
+	link_print_lid(rd, tb);
+	link_print_sm_lid(rd, tb);
+	link_print_lmc(rd, tb);
+	link_print_state(rd, tb);
+	link_print_phys_state(rd, tb);
 	if (rd->show_details)
-		link_print_caps(tb);
+		link_print_caps(rd, tb);

-	pr_out("\n");
+	if (!rd->json_output)
+		pr_out("\n");
 	return MNL_CB_OK;
 }

@@ -208,7 +262,12 @@ static int link_no_args(struct rd *rd)
 	if (ret)
 		return ret;

-	return rd_recv_msg(rd, link_parse_cb, rd, seq);
+	if (rd->json_output)
+		jsonw_start_object(rd->jw);
+	ret = rd_recv_msg(rd, link_parse_cb, rd, seq);
+	if (rd->json_output)
+		jsonw_end_object(rd->jw);
+	return ret;
 }

 static int link_one_show(struct rd *rd)
@@ -225,8 +284,10 @@ static int link_show(struct rd *rd)
 {
 	struct dev_map *dev_map;
 	uint32_t port;
-	int ret;
+	int ret = 0;

+	if (rd->json_output)
+		jsonw_start_array(rd->jw);
 	if (rd_no_arg(rd)) {
 		list_for_each_entry(dev_map, &rd->dev_map_list, list) {
 			rd->dev_idx = dev_map->idx;
@@ -234,7 +295,7 @@ static int link_show(struct rd *rd)
 				rd->port_idx = port;
 				ret = link_one_show(rd);
 				if (ret)
-					return ret;
+					goto out;
 			}
 		}

@@ -243,7 +304,8 @@ static int link_show(struct rd *rd)
 		port = get_port_from_argv(rd);
 		if (!dev_map || port > dev_map->num_ports) {
 			pr_err("Wrong device name\n");
-			return -ENOENT;
+			ret = -ENOENT;
+			goto out;
 		}
 		rd_arg_inc(rd);
 		rd->dev_idx = dev_map->idx;
@@ -251,7 +313,7 @@ static int link_show(struct rd *rd)
 		for (; rd->port_idx < dev_map->num_ports + 1; rd->port_idx++) {
 			ret = link_one_show(rd);
 			if (ret)
-				return ret;
+				goto out;
 			if (port)
 				/*
 				 * We got request to show link for devname
@@ -260,7 +322,11 @@ static int link_show(struct rd *rd)
 				break;
 		}
 	}
-	return 0;
+
+out:
+	if (rd->json_output)
+		jsonw_end_array(rd->jw);
+	return ret;
 }

 int cmd_link(struct rd *rd)
diff --git a/rdma/rdma.h b/rdma/rdma.h
index 5904f177..d62a0ac8 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -68,7 +68,6 @@ void rd_arg_inc(struct rd *rd);
 char *rd_argv(struct rd *rd);
 uint32_t get_port_from_argv(struct rd *rd);

-void rd_print_u64(char *name, uint64_t val);
 /*
  * Commands interface
  */
diff --git a/rdma/utils.c b/rdma/utils.c
index 91d05271..eb4377cf 100644
--- a/rdma/utils.c
+++ b/rdma/utils.c
@@ -59,14 +59,6 @@ uint32_t get_port_from_argv(struct rd *rd)
 	return slash ? atoi(slash + 1) : 0;
 }

-void rd_print_u64(char *name, uint64_t val)
-{
-	uint16_t vp[4];
-
-	memcpy(vp, &val, sizeof(uint64_t));
-	pr_out("%s %04x:%04x:%04x:%04x ", name, vp[3], vp[2], vp[1], vp[0]);
-}
-
 static struct dev_map *dev_map_alloc(const char *dev_name)
 {
 	struct dev_map *dev_map;
