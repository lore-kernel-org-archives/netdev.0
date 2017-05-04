From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [RFC iproute2 8/8] rdma: Add link capability parsing
Date: Thu,  4 May 2017 21:02:16 +0300
Message-ID: <20170504180216.7665-9-leon@kernel.org>
References: <20170504180216.7665-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Ram Amrani <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170504180216.7665-1-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Add parsing interface for the cap_mask

$./rdma/rdma link show mlx5_2/2 cap_mask
3/2: mlx5_2/2: sm off notice off trap on opt_ipd off auto_migr off sl_map on mkey_nvram off
	pkey_nvram off led_info off sm_disabled off sys_image_guid on pkey_sw_ext_port_trap off
	extended_speeds on cm on snmp_tunnel off reinit off device_mgmt off vendor_class on dr_notice off
	cap_mask_notice on boot_mgmt off link_latency off client_reg on ip_based_gids on

Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 rdma/link.c  | 74 +++++++++++++++++++++++++++++++++++++++++++++++++-----------
 rdma/rdma.h  |  4 ++++
 rdma/utils.c |  4 ++--
 3 files changed, 67 insertions(+), 15 deletions(-)

diff --git a/rdma/link.c b/rdma/link.c
index e86ff399..e9880914 100644
--- a/rdma/link.c
+++ b/rdma/link.c
@@ -14,13 +14,48 @@
 static int link_help(struct rdma *rd)
 {
 	pr_out("Usage: %s link show [ DEV | DEV/PORT ]\n", rd->filename);
+	pr_out("       %s link show [ DEV | DEV/PORT ] cap_mask\n", rd->filename);
 	pr_out("       %s link set DEV/PORT { type { eth | ib | auto } |\n", rd->filename);
 	pr_out("                                lb_unicast { on | off } |\n");
 	pr_out("                                lb_multicast { on | off } }\n");
 	return 0;
 }

-static void dev_one_show(const struct dev_map *dev_map, uint32_t port_idx_first, uint32_t port_idx_last)
+static void print_cap_mask(uint32_t cap_mask)
+{
+#define PRINT_PORT_CAP(name, val, offset)		(printf(" %s %s", name, (((val) >> (offset))&0x1)?"on":"off"))
+
+	/* Naive copy/paste from include/rdma/ib_verbs.h */
+ 	PRINT_PORT_CAP("sm", cap_mask, 1);
+ 	PRINT_PORT_CAP("notice", cap_mask, 2);
+ 	PRINT_PORT_CAP("trap", cap_mask, 3);
+ 	PRINT_PORT_CAP("opt_ipd", cap_mask, 4);
+ 	PRINT_PORT_CAP("auto_migr", cap_mask, 5);
+	PRINT_PORT_CAP("sl_map", cap_mask, 6);
+ 	PRINT_PORT_CAP("mkey_nvram", cap_mask, 7);
+	printf("\n\t");
+ 	PRINT_PORT_CAP("pkey_nvram", cap_mask, 8);
+ 	PRINT_PORT_CAP("led_info", cap_mask, 9);
+ 	PRINT_PORT_CAP("sm_disabled", cap_mask, 10);
+ 	PRINT_PORT_CAP("sys_image_guid", cap_mask, 11);
+	PRINT_PORT_CAP("pkey_sw_ext_port_trap", cap_mask, 12);
+	printf("\n\t");
+	PRINT_PORT_CAP("extended_speeds", cap_mask, 14);
+ 	PRINT_PORT_CAP("cm", cap_mask, 16);
+ 	PRINT_PORT_CAP("snmp_tunnel", cap_mask, 17);
+ 	PRINT_PORT_CAP("reinit", cap_mask, 18);
+ 	PRINT_PORT_CAP("device_mgmt", cap_mask, 19);
+ 	PRINT_PORT_CAP("vendor_class", cap_mask, 20);
+ 	PRINT_PORT_CAP("dr_notice", cap_mask, 21);
+	printf("\n\t");
+	PRINT_PORT_CAP("cap_mask_notice", cap_mask, 22);
+ 	PRINT_PORT_CAP("boot_mgmt", cap_mask, 23);
+ 	PRINT_PORT_CAP("link_latency", cap_mask, 24);
+ 	PRINT_PORT_CAP("client_reg", cap_mask, 25);
+ 	PRINT_PORT_CAP("ip_based_gids", cap_mask, 26);
+}
+static void dev_one_show(struct rdma *rd, const struct dev_map *dev_map,
+			 uint32_t port_idx_first, uint32_t port_idx_last)
 {
 	char *nodes[] = { "cap_mask",
 			  "lid",
@@ -35,23 +70,36 @@ static void dev_one_show(const struct dev_map *dev_map, uint32_t port_idx_first,

 	struct port_map *port_map;
 	char data[4096];
+	uint32_t cap_mask;
+	bool cap_mask_r = false;
 	int i, j;

+	rd_arg_inc(rd);
+	if (rd_argv_match(rd, "cap_mask"))
+		cap_mask_r = true;
+
 	for(j = port_idx_first ; j <= port_idx_last; j++) {
 		pr_out("%u/%u: %s/%u:", dev_map->idx, j, dev_map->dev_name, j);
-		list_for_each_entry(port_map, &dev_map->port_map_list, list)
-			if (j == port_map->idx)
-			       printf(" ifname %s", (port_map->ifname)?:"NONE");
+		if (cap_mask_r) {
+			rdma_sysfs_read_ib(dev_map->dev_name, 1, nodes[0], data);
+			cap_mask = strtoul(data, NULL, 16);
+			print_cap_mask(cap_mask);
+		}
+		else {
+			list_for_each_entry(port_map, &dev_map->port_map_list, list)
+				if (j == port_map->idx)
+				       printf(" ifname %s", (port_map->ifname)?:"NONE");

-		for (i = 0 ; nodes[i] ; i++) {
-			if (rdma_sysfs_read_ib(dev_map->dev_name, j, nodes[i], data))
-				continue;
+			for (i = 0 ; nodes[i] ; i++) {
+				if (rdma_sysfs_read_ib(dev_map->dev_name, j, nodes[i], data))
+					continue;

-			/* Split line before "phys_state" */
-			if (!strcmp(nodes[i], "phys_state"))
-				printf("\n\t");
+				/* Split line before "phys_state" */
+				if (!strcmp(nodes[i], "phys_state"))
+					printf("\n\t");

-			pr_out(" %s %s", nodes[i], data);
+				pr_out(" %s %s", nodes[i], data);
+			}
 		}
 		pr_out("\n");
 	}
@@ -63,7 +111,7 @@ static int link_show(struct rdma *rd)

 	if (rd_no_arg(rd)) {
 		list_for_each_entry(dev_map, &rd->dev_map_list, list)
-			dev_one_show(dev_map, 1, dev_map->num_ports);
+			dev_one_show(rd, dev_map, 1, dev_map->num_ports);
 	}
 	else {
 		uint32_t port_idx;
@@ -81,7 +129,7 @@ static int link_show(struct rdma *rd)
 			num_ports = dev_map->num_ports;
 		}

-		dev_one_show(dev_map, port_idx, num_ports);
+		dev_one_show(rd, dev_map, port_idx, num_ports);
 	}
 	return 0;
 }
diff --git a/rdma/rdma.h b/rdma/rdma.h
index 11d940d7..12c87048 100644
--- a/rdma/rdma.h
+++ b/rdma/rdma.h
@@ -76,6 +76,10 @@ int obj_monitor(struct rdma *rd);
  */
 bool rd_no_arg(struct rdma *rd);
 uint32_t get_port_from_argv(struct rdma *rd);
+bool rd_no_arg(struct rdma *rd);
+bool rd_argv_match(struct rdma *rd, const char *pattern);
+void rd_arg_inc(struct rdma *rd);
+uint32_t get_port_from_argv(struct rdma *rd);

 int rdma_exec_cmd(struct rdma *rd, const struct rdma_obj *o, const char *str);
 int rdma_sysfs_read_ib(const char *name, int port, const char *field, char *res);
diff --git a/rdma/utils.c b/rdma/utils.c
index 568d7c0a..fd5fe77f 100644
--- a/rdma/utils.c
+++ b/rdma/utils.c
@@ -40,14 +40,14 @@ static int strcmpx(const char *str1, const char *str2)
 	return strncmp(str1, str2, strlen(str1));
 }

-static bool rd_argv_match(struct rdma *rd, const char *pattern)
+bool rd_argv_match(struct rdma *rd, const char *pattern)
 {
 	if (!rd_argc(rd))
 		return false;
 	return strcmpx(rd_argv(rd), pattern) == 0;
 }

-static void rd_arg_inc(struct rdma *rd)
+void rd_arg_inc(struct rdma *rd)
 {
 	if (!rd_argc(rd))
 		return;
--
2.12.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
