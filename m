From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v4 2/5] bridge: add json support for bridge vlan show
Date: Wed, 22 Jun 2016 06:45:52 -0700
Message-ID: <1466603155-53768-3-git-send-email-roopa@cumulusnetworks.com>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34908 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880AbcFVNqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 09:46:02 -0400
Received: by mail-pa0-f45.google.com with SMTP id hl6so17159159pac.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 06:46:02 -0700 (PDT)
In-Reply-To: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

$bridge -c vlan show
port	vlan ids
swp1	 1 PVID Egress Untagged
	 10-13

swp2	 1 PVID Egress Untagged
	 10-13

br0	 1 PVID Egress Untagged

$bridge  -json vlan show
{
    "swp1": [{
            "vlan": 1,
            "flags": ["PVID","Egress Untagged"
            ]
        },{
            "vlan": 10
        },{
            "vlan": 11
        },{
            "vlan": 12
        },{
            "vlan": 13
        }
    ],
    "swp2": [{
            "vlan": 1,
            "flags": ["PVID","Egress Untagged"
            ]
        },{
            "vlan": 10
        },{
            "vlan": 11
        },{
            "vlan": 12
        },{
            "vlan": 13
        }
    ],
    "br0": [{
            "vlan": 1,
            "flags": ["PVID","Egress Untagged"
            ]
        }
    ]
}

$bridge -c -json vlan show
{
    "swp1": [{
            "vlan": 1,
            "flags": ["PVID","Egress Untagged"
            ]
        },{
            "vlan": 10,
            "vlanEnd": 13
        }
    ],
    "swp2": [{
            "vlan": 1,
            "flags": ["PVID","Egress Untagged"
            ]
        },{
            "vlan": 10,
            "vlanEnd": 13
        }
    ],
    "br0": [{
            "vlan": 1,
            "flags": ["PVID","Egress Untagged"
            ]
        }
    ]
}

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/br_common.h |   1 +
 bridge/bridge.c    |   5 ++-
 bridge/vlan.c      | 109 ++++++++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 100 insertions(+), 15 deletions(-)

diff --git a/bridge/br_common.h b/bridge/br_common.h
index 5ea45c9..c649e7d 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -23,4 +23,5 @@ extern int show_stats;
 extern int show_details;
 extern int timestamp;
 extern int compress_vlans;
+extern int json_output;
 extern struct rtnl_handle rth;
diff --git a/bridge/bridge.c b/bridge/bridge.c
index 72f153f..5ff038d 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -23,6 +23,7 @@ int oneline;
 int show_stats;
 int show_details;
 int compress_vlans;
+int json_output;
 int timestamp;
 char *batch_file;
 int force;
@@ -38,7 +39,7 @@ static void usage(void)
 "where	OBJECT := { link | fdb | mdb | vlan | monitor }\n"
 "	OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] |\n"
 "		     -o[neline] | -t[imestamp] | -n[etns] name |\n"
-"		     -c[ompressvlans] }\n");
+"		     -c[ompressvlans] -j{son} }\n");
 	exit(-1);
 }
 
@@ -173,6 +174,8 @@ main(int argc, char **argv)
 			++compress_vlans;
 		} else if (matches(opt, "-force") == 0) {
 			++force;
+		} else if (matches(opt, "-json") == 0) {
+			++json_output;
 		} else if (matches(opt, "-batch") == 0) {
 			argc--;
 			argv++;
diff --git a/bridge/vlan.c b/bridge/vlan.c
index 717025a..ba4dfbc 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -7,6 +7,7 @@
 #include <netinet/in.h>
 #include <linux/if_bridge.h>
 #include <linux/if_ether.h>
+#include <json_writer.h>
 #include <string.h>
 
 #include "libnetlink.h"
@@ -15,6 +16,8 @@
 
 static unsigned int filter_index, filter_vlan;
 
+json_writer_t *jw_global = NULL;
+
 static void usage(void)
 {
 	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid] [ untagged ]\n");
@@ -158,6 +161,28 @@ static int filter_vlan_check(struct bridge_vlan_info *vinfo)
 	return 1;
 }
 
+static void print_vlan_port(FILE *fp, int ifi_index)
+{
+	if (jw_global) {
+		jsonw_pretty(jw_global, 1);
+		jsonw_name(jw_global,
+			   ll_index_to_name(ifi_index));
+		jsonw_start_array(jw_global);
+	} else {
+		fprintf(fp, "%s",
+			ll_index_to_name(ifi_index));
+	}
+}
+
+static void start_json_vlan_flags_array(bool *vlan_flags)
+{
+	if (*vlan_flags)
+		return;
+	jsonw_name(jw_global, "flags");
+	jsonw_start_array(jw_global);
+	*vlan_flags = true;
+}
+
 static int print_vlan(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n,
 		      void *arg)
@@ -166,6 +191,8 @@ static int print_vlan(const struct sockaddr_nl *who,
 	struct ifinfomsg *ifm = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[IFLA_MAX+1];
+	bool vlan_flags;
+	char flags[80];
 
 	if (n->nlmsg_type != RTM_NEWLINK) {
 		fprintf(stderr, "Not RTM_NEWLINK: %08x %08x %08x\n",
@@ -199,7 +226,8 @@ static int print_vlan(const struct sockaddr_nl *who,
 		__u16 last_vid_start = 0;
 
 		if (!filter_vlan)
-			fprintf(fp, "%s", ll_index_to_name(ifm->ifi_index));
+			print_vlan_port(fp, ifm->ifi_index);
+
 		for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
 			struct bridge_vlan_info *vinfo;
 			int vcheck_ret;
@@ -218,20 +246,58 @@ static int print_vlan(const struct sockaddr_nl *who,
 				continue;
 
 			if (filter_vlan)
-				fprintf(fp, "%s",
-					ll_index_to_name(ifm->ifi_index));
-			fprintf(fp, "\t %hu", last_vid_start);
-			if (last_vid_start != vinfo->vid)
-				fprintf(fp, "-%hu", vinfo->vid);
-			if (vinfo->flags & BRIDGE_VLAN_INFO_PVID)
-				fprintf(fp, " PVID");
-			if (vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED)
-				fprintf(fp, " Egress Untagged");
-			fprintf(fp, "\n");
+				print_vlan_port(fp, ifm->ifi_index);
+			if (jw_global) {
+				jsonw_start_object(jw_global);
+				jsonw_uint_field(jw_global, "vlan",
+						 last_vid_start);
+				if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN)
+					continue;
+			} else {
+				fprintf(fp, "\t %hu", last_vid_start);
+			}
+			if (last_vid_start != vinfo->vid) {
+				if (jw_global)
+					jsonw_uint_field(jw_global, "vlanEnd",
+							 vinfo->vid);
+				else
+					fprintf(fp, "-%hu", vinfo->vid);
+			}
+			if (vinfo->flags & BRIDGE_VLAN_INFO_PVID) {
+				if (jw_global) {
+					start_json_vlan_flags_array(&vlan_flags);
+					jsonw_string(jw_global, "PVID");
+				} else {
+					fprintf(fp, " PVID");
+				}
+			}
+			if (vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED) {
+				if (jw_global) {
+					start_json_vlan_flags_array(&vlan_flags);
+					jsonw_string(jw_global,
+						     "Egress Untagged");
+				} else {
+					fprintf(fp, " Egress Untagged");
+				}
+			}
+			if (vlan_flags) {
+				jsonw_end_array(jw_global);
+				vlan_flags = false;
+			}
+
+			if (jw_global)
+				jsonw_end_object(jw_global);
+			else
+				fprintf(fp, "\n");
 		}
 	}
-	if (!filter_vlan)
-		fprintf(fp, "\n");
+	if (!filter_vlan) {
+		if (jw_global)
+			jsonw_end_array(jw_global);
+		else
+			fprintf(fp, "\n");
+
+	}
 	fflush(fp);
 	return 0;
 }
@@ -271,12 +337,27 @@ static int vlan_show(int argc, char **argv)
 		exit(1);
 	}
 
-	printf("port\tvlan ids\n");
+	if (json_output) {
+		jw_global = jsonw_new(stdout);
+		if (!jw_global) {
+			fprintf(stderr, "Error allocation json object\n");
+			exit(1);
+		}
+		jsonw_start_object(jw_global);
+	} else {
+		printf("port\tvlan ids\n");
+	}
+
 	if (rtnl_dump_filter(&rth, print_vlan, stdout) < 0) {
 		fprintf(stderr, "Dump ternminated\n");
 		exit(1);
 	}
 
+	if (jw_global) {
+		jsonw_end_object(jw_global);
+		jsonw_destroy(&jw_global);
+	}
+
 	return 0;
 }
 
-- 
1.9.1
