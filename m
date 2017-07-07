From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next] bridge: this patch adds json support for bridge mdb show
Date: Fri,  7 Jul 2017 15:24:16 -0700
Message-ID: <1499466256-13808-1-git-send-email-roopa@cumulusnetworks.com>
Cc: nikhil@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34523 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752620AbdGGWYX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2017 18:24:23 -0400
Received: by mail-pf0-f169.google.com with SMTP id q85so23116867pfq.1
        for <netdev@vger.kernel.org>; Fri, 07 Jul 2017 15:24:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikhil Gajendrakumar <nikhil@cumulusnetworks.com>

This patch adds json output to bridge mdb show

Normal Output:
$ bridge -d -s mdb show
dev br0 port swp3 grp 239.0.0.1 temp  vid 128 172.26
dev br0 port swp3 grp 239.0.0.1 temp  vid 64 172.26
dev br0 port swp2 grp 239.0.0.2 temp  vid 1024 172.26
dev br0 port swp2 grp 239.0.0.2 temp  vid 256 172.26
dev br0 port swp2 grp 239.0.0.2 temp  vid 1 172.26
dev br0 port swp3 grp 239.0.0.1 temp  vid 1 172.26
router ports on br0: swp4    0.00 permanent
router ports on br0: swp5    0.00 permanent

Json Output:
$ bridge -d -s -j mdb show
{
    "mdb": [{
            "dev": "br0",
            "port": "swp3",
            "grp": "239.0.0.1",
            "state": "temp",
            "vid": 128,
            "timer": " 166.74"
        },{
            "dev": "br0",
            "port": "swp3",
            "grp": "239.0.0.1",
            "state": "temp",
            "vid": 64,
            "timer": " 166.74"
        },{
            "dev": "br0",
            "port": "swp2",
            "grp": "239.0.0.2",
            "state": "temp",
            "vid": 1024,
            "timer": " 166.74"
        },{
            "dev": "br0",
            "port": "swp2",
            "grp": "239.0.0.2",
            "state": "temp",
            "vid": 256,
            "timer": " 166.74"
        },{
            "dev": "br0",
            "port": "swp2",
            "grp": "239.0.0.2",
            "state": "temp",
            "vid": 1,
            "timer": " 166.74"
        },{
            "dev": "br0",
            "port": "swp3",
            "grp": "239.0.0.1",
            "state": "temp",
            "vid": 1,
            "timer": " 166.74"
        }
    ],
    "router": {
        "br0": [{
                "port": "swp4",
                "timer": "   0.00",
                "type": "permanent"
            },{
                "port": "swp5",
                "timer": "   0.00",
                "type": "permanent"
            }
        ]
    }
}

Signed-off-by: Nikhil Gajendrakumar <nikhil@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/mdb.c | 218 ++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 180 insertions(+), 38 deletions(-)

diff --git a/bridge/mdb.c b/bridge/mdb.c
index e60ff3e..748091b 100644
--- a/bridge/mdb.c
+++ b/bridge/mdb.c
@@ -13,6 +13,7 @@
 #include <linux/if_ether.h>
 #include <string.h>
 #include <arpa/inet.h>
+#include <json_writer.h>
 
 #include "libnetlink.h"
 #include "br_common.h"
@@ -25,6 +26,9 @@
 #endif
 
 static unsigned int filter_index, filter_vlan;
+json_writer_t *jw_global;
+static bool print_mdb_entries = true;
+static bool print_mdb_router = true;
 
 static void usage(void)
 {
@@ -49,13 +53,26 @@ static void __print_router_port_stats(FILE *f, struct rtattr *pattr)
 	if (tb[MDBA_ROUTER_PATTR_TIMER]) {
 		__jiffies_to_tv(&tv,
 				rta_getattr_u32(tb[MDBA_ROUTER_PATTR_TIMER]));
-		fprintf(f, " %4i.%.2i",
-			(int)tv.tv_sec, (int)tv.tv_usec/10000);
+		if (jw_global) {
+			char formatted_time[9];
+
+			snprintf(formatted_time, sizeof(formatted_time),
+				 "%4i.%.2i", (int)tv.tv_sec,
+				 (int)tv.tv_usec/10000);
+			jsonw_string_field(jw_global, "timer", formatted_time);
+		} else {
+			fprintf(f, " %4i.%.2i",
+				(int)tv.tv_sec, (int)tv.tv_usec/10000);
+		}
 	}
 	if (tb[MDBA_ROUTER_PATTR_TYPE]) {
 		type = rta_getattr_u8(tb[MDBA_ROUTER_PATTR_TYPE]);
-		fprintf(f, " %s",
-			is_temp_mcast_rtr(type) ? "temp" : "permanent");
+		if (jw_global)
+			jsonw_string_field(jw_global, "type",
+				is_temp_mcast_rtr(type) ? "temp" : "permanent");
+		else
+			fprintf(f, " %s",
+				is_temp_mcast_rtr(type) ? "temp" : "permanent");
 	}
 }
 
@@ -65,24 +82,50 @@ static void br_print_router_ports(FILE *f, struct rtattr *attr, __u32 brifidx)
 	struct rtattr *i;
 	int rem;
 
-	if (!show_stats)
-		fprintf(f, "router ports on %s: ", ll_index_to_name(brifidx));
-
 	rem = RTA_PAYLOAD(attr);
-	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
-		port_ifindex = RTA_DATA(i);
-		if (show_stats) {
-			fprintf(f, "router ports on %s: %s",
-				ll_index_to_name(brifidx),
-				ll_index_to_name(*port_ifindex));
-			__print_router_port_stats(f, i);
-			fprintf(f, "\n");
-		} else {
-			fprintf(f, "%s ", ll_index_to_name(*port_ifindex));
+	if (jw_global) {
+		jsonw_name(jw_global, ll_index_to_name(brifidx));
+		jsonw_start_array(jw_global);
+		for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+			port_ifindex = RTA_DATA(i);
+			jsonw_start_object(jw_global);
+			jsonw_string_field(jw_global,
+					   "port",
+					   ll_index_to_name(*port_ifindex));
+			if (show_stats)
+				__print_router_port_stats(f, i);
+			jsonw_end_object(jw_global);
+		}
+		jsonw_end_array(jw_global);
+	} else {
+		if (!show_stats)
+			fprintf(f, "router ports on %s: ",
+				ll_index_to_name(brifidx));
+		for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+			port_ifindex = RTA_DATA(i);
+			if (show_stats) {
+				fprintf(f, "router ports on %s: %s",
+					ll_index_to_name(brifidx),
+					ll_index_to_name(*port_ifindex));
+				__print_router_port_stats(f, i);
+				fprintf(f, "\n");
+			} else{
+				fprintf(f, "%s ",
+					ll_index_to_name(*port_ifindex));
+			}
 		}
+		if (!show_stats)
+			fprintf(f, "\n");
 	}
-	if (!show_stats)
-		fprintf(f, "\n");
+}
+
+static void start_json_mdb_flags_array(bool *mdb_flags)
+{
+	if (*mdb_flags)
+		return;
+	jsonw_name(jw_global, "flags");
+	jsonw_start_array(jw_global);
+	*mdb_flags = true;
 }
 
 static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e,
@@ -91,28 +134,70 @@ static void print_mdb_entry(FILE *f, int ifindex, struct br_mdb_entry *e,
 	SPRINT_BUF(abuf);
 	const void *src;
 	int af;
+	bool mdb_flags = false;
 
 	if (filter_vlan && e->vid != filter_vlan)
 		return;
 	af = e->addr.proto == htons(ETH_P_IP) ? AF_INET : AF_INET6;
 	src = af == AF_INET ? (const void *)&e->addr.u.ip4 :
 			      (const void *)&e->addr.u.ip6;
-	if (n->nlmsg_type == RTM_DELMDB)
-		fprintf(f, "Deleted ");
-	fprintf(f, "dev %s port %s grp %s %s %s", ll_index_to_name(ifindex),
-		ll_index_to_name(e->ifindex),
-		inet_ntop(af, src, abuf, sizeof(abuf)),
-		(e->state & MDB_PERMANENT) ? "permanent" : "temp",
-		(e->flags & MDB_FLAGS_OFFLOAD) ? "offload" : "");
-	if (e->vid)
-		fprintf(f, " vid %hu", e->vid);
+	if (jw_global)
+		jsonw_start_object(jw_global);
+	if (n->nlmsg_type == RTM_DELMDB) {
+		if (jw_global)
+			jsonw_string_field(jw_global, "opCode", "deleted");
+		else
+			fprintf(f, "Deleted ");
+	}
+	if (jw_global) {
+		jsonw_string_field(jw_global, "dev", ll_index_to_name(ifindex));
+		jsonw_string_field(jw_global,
+				   "port",
+				   ll_index_to_name(e->ifindex));
+		jsonw_string_field(jw_global, "grp", inet_ntop(af, src,
+			abuf, sizeof(abuf)));
+		jsonw_string_field(jw_global, "state",
+			(e->state & MDB_PERMANENT) ? "permanent" : "temp");
+		if (e->flags & MDB_FLAGS_OFFLOAD) {
+			start_json_mdb_flags_array(&mdb_flags);
+			jsonw_string(jw_global, "offload");
+		}
+		if (mdb_flags)
+			jsonw_end_array(jw_global);
+	} else{
+		fprintf(f, "dev %s port %s grp %s %s %s",
+			ll_index_to_name(ifindex),
+			ll_index_to_name(e->ifindex),
+			inet_ntop(af, src, abuf, sizeof(abuf)),
+			(e->state & MDB_PERMANENT) ? "permanent" : "temp",
+			(e->flags & MDB_FLAGS_OFFLOAD) ? "offload" : "");
+	}
+	if (e->vid) {
+		if (jw_global)
+			jsonw_uint_field(jw_global, "vid", e->vid);
+		else
+			fprintf(f, " vid %hu", e->vid);
+	}
 	if (show_stats && tb && tb[MDBA_MDB_EATTR_TIMER]) {
 		struct timeval tv;
 
 		__jiffies_to_tv(&tv, rta_getattr_u32(tb[MDBA_MDB_EATTR_TIMER]));
-		fprintf(f, "%4i.%.2i", (int)tv.tv_sec, (int)tv.tv_usec/10000);
+		if (jw_global) {
+			char formatted_time[9];
+
+			snprintf(formatted_time, sizeof(formatted_time),
+				 "%4i.%.2i", (int)tv.tv_sec,
+				 (int)tv.tv_usec/10000);
+			jsonw_string_field(jw_global, "timer", formatted_time);
+		} else {
+			fprintf(f, "%4i.%.2i", (int)tv.tv_sec,
+				(int)tv.tv_usec/10000);
+		}
 	}
-	fprintf(f, "\n");
+	if (jw_global)
+		jsonw_end_object(jw_global);
+	else
+		fprintf(f, "\n");
 }
 
 static void br_print_mdb_entry(FILE *f, int ifindex, struct rtattr *attr,
@@ -157,14 +242,14 @@ int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	parse_rtattr(tb, MDBA_MAX, MDBA_RTA(r), n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
-	if (tb[MDBA_MDB]) {
+	if (tb[MDBA_MDB] && print_mdb_entries) {
 		int rem = RTA_PAYLOAD(tb[MDBA_MDB]);
 
 		for (i = RTA_DATA(tb[MDBA_MDB]); RTA_OK(i, rem); i = RTA_NEXT(i, rem))
 			br_print_mdb_entry(fp, r->ifindex, i, n);
 	}
 
-	if (tb[MDBA_ROUTER]) {
+	if (tb[MDBA_ROUTER] && print_mdb_router) {
 		if (n->nlmsg_type == RTM_GETMDB) {
 			if (show_details)
 				br_print_router_ports(fp, tb[MDBA_ROUTER],
@@ -174,15 +259,33 @@ int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 			i = RTA_DATA(tb[MDBA_ROUTER]);
 			port_ifindex = RTA_DATA(i);
-			if (n->nlmsg_type == RTM_DELMDB)
-				fprintf(fp, "Deleted ");
-			fprintf(fp, "router port dev %s master %s\n",
-				ll_index_to_name(*port_ifindex),
-				ll_index_to_name(r->ifindex));
+			if (n->nlmsg_type == RTM_DELMDB) {
+				if (jw_global)
+					jsonw_string_field(jw_global,
+							   "opCode",
+							   "deleted");
+				else
+					fprintf(fp, "Deleted ");
+			}
+			if (jw_global) {
+				jsonw_name(jw_global,
+					   ll_index_to_name(r->ifindex));
+				jsonw_start_array(jw_global);
+				jsonw_start_object(jw_global);
+				jsonw_string_field(jw_global, "port",
+					ll_index_to_name(*port_ifindex));
+				jsonw_end_object(jw_global);
+				jsonw_end_array(jw_global);
+			} else {
+				fprintf(fp, "router port dev %s master %s\n",
+					ll_index_to_name(*port_ifindex),
+					ll_index_to_name(r->ifindex));
+			}
 		}
 	}
 
-	fflush(fp);
+	if (!jw_global)
+		fflush(fp);
 
 	return 0;
 }
@@ -215,15 +318,54 @@ static int mdb_show(int argc, char **argv)
 		}
 	}
 
+	/* get mdb entries*/
+	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETMDB) < 0) {
+		perror("Cannot send dump request");
+		return -1;
+	}
+
+	if (!json_output) {
+		/* Normal output */
+		if (rtnl_dump_filter(&rth, print_mdb, stdout) < 0) {
+			fprintf(stderr, "Dump terminated\n");
+			return -1;
+		}
+		return 0;
+	}
+	/* Json output */
+	jw_global = jsonw_new(stdout);
+	jsonw_pretty(jw_global, 1);
+	jsonw_start_object(jw_global);
+	jsonw_name(jw_global, "mdb");
+	jsonw_start_array(jw_global);
+
+	/* print mdb entries */
+	print_mdb_entries = true;
+	print_mdb_router = false;
+	if (rtnl_dump_filter(&rth, print_mdb, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		return -1;
+	}
+	jsonw_end_array(jw_global);
+
+	/* get router ports */
 	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETMDB) < 0) {
 		perror("Cannot send dump request");
 		return -1;
 	}
+	jsonw_name(jw_global, "router");
+	jsonw_start_object(jw_global);
 
+	/* print router ports */
+	print_mdb_entries = false;
+	print_mdb_router = true;
 	if (rtnl_dump_filter(&rth, print_mdb, stdout) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		return -1;
 	}
+	jsonw_end_object(jw_global);
+	jsonw_end_object(jw_global);
+	jsonw_destroy(&jw_global);
 
 	return 0;
 }
-- 
1.9.1
