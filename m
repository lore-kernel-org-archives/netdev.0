From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next v4 3/5] bridge: add json support for bridge fdb show
Date: Wed, 22 Jun 2016 06:45:53 -0700
Message-ID: <1466603155-53768-4-git-send-email-roopa@cumulusnetworks.com>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Cc: anuradhak@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	julien@cumulusnetworks.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36051 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768AbcFVPcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 11:32:19 -0400
Received: by mail-pa0-f52.google.com with SMTP id wo6so17904521pac.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 08:32:18 -0700 (PDT)
In-Reply-To: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>

Sample output:
$bridge -j fdb show
[{
        "mac": "44:38:39:00:69:88",
        "dev": "swp2s0",
        "vlan": 2,
        "master": "br0",
        "state": "permanent"
    },{
        "mac": "00:02:00:00:00:01",
        "dev": "swp2s0",
        "vlan": 2,
        "master": "br0"
    },{
        "mac": "00:02:00:00:00:02",
        "dev": "swp2s1",
        "vlan": 2,
        "master": "br0"
    },{
        "mac": "44:38:39:00:69:89",
        "dev": "swp2s1",
        "master": "br0",
        "state": "permanent"
    },{
        "mac": "44:38:39:00:69:89",
        "dev": "swp2s1",
        "vlan": 2,
        "master": "br0",
        "state": "permanent"
    },{
        "mac": "44:38:39:00:69:88",
        "dev": "br0",
        "master": "br0",
        "state": "permanent"
    }
]

Signed-off-by: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 bridge/fdb.c | 210 +++++++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 167 insertions(+), 43 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index be849f9..3d1ef6c 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -21,6 +21,8 @@
 #include <linux/neighbour.h>
 #include <string.h>
 #include <limits.h>
+#include <json_writer.h>
+#include <stdbool.h>
 
 #include "libnetlink.h"
 #include "br_common.h"
@@ -29,6 +31,8 @@
 
 static unsigned int filter_index, filter_vlan;
 
+json_writer_t *jw_global;
+
 static void usage(void)
 {
 	fprintf(stderr, "Usage: bridge fdb { add | append | del | replace } ADDR dev DEV\n"
@@ -59,6 +63,15 @@ static const char *state_n2a(unsigned int s)
 	return buf;
 }
 
+static void start_json_fdb_flags_array(bool *fdb_flags)
+{
+	if (*fdb_flags)
+		return;
+	jsonw_name(jw_global, "flags");
+	jsonw_start_array(jw_global);
+	*fdb_flags = true;
+}
+
 int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
 	FILE *fp = arg;
@@ -66,11 +79,12 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	int len = n->nlmsg_len;
 	struct rtattr *tb[NDA_MAX+1];
 	__u16 vid = 0;
+	bool fdb_flags = false;
+	const char *state_s;
 
 	if (n->nlmsg_type != RTM_NEWNEIGH && n->nlmsg_type != RTM_DELNEIGH) {
 		fprintf(stderr, "Not RTM_NEWNEIGH: %08x %08x %08x\n",
 			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
-
 		return 0;
 	}
 
@@ -86,6 +100,11 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (filter_index && filter_index != r->ndm_ifindex)
 		return 0;
 
+	if (jw_global) {
+		jsonw_pretty(jw_global, 1);
+		jsonw_start_object(jw_global);
+	}
+
 	parse_rtattr(tb, NDA_MAX, NDA_RTA(r),
 		     n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
@@ -95,40 +114,75 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (filter_vlan && filter_vlan != vid)
 		return 0;
 
-	if (n->nlmsg_type == RTM_DELNEIGH)
-		fprintf(fp, "Deleted ");
+	if (n->nlmsg_type == RTM_DELNEIGH) {
+		if (jw_global)
+			jsonw_string_field(jw_global, "opCode", "deleted");
+		else
+			fprintf(fp, "Deleted ");
+	}
 
 	if (tb[NDA_LLADDR]) {
 		SPRINT_BUF(b1);
-		fprintf(fp, "%s ",
-			ll_addr_n2a(RTA_DATA(tb[NDA_LLADDR]),
-				    RTA_PAYLOAD(tb[NDA_LLADDR]),
-				    ll_index_to_type(r->ndm_ifindex),
-				    b1, sizeof(b1)));
+		ll_addr_n2a(RTA_DATA(tb[NDA_LLADDR]),
+			    RTA_PAYLOAD(tb[NDA_LLADDR]),
+			    ll_index_to_type(r->ndm_ifindex),
+			    b1, sizeof(b1));
+		if (jw_global)
+			jsonw_string_field(jw_global, "mac", b1);
+		else
+			fprintf(fp, "%s ", b1);
 	}
 
-	if (!filter_index && r->ndm_ifindex)
-		fprintf(fp, "dev %s ", ll_index_to_name(r->ndm_ifindex));
+	if (!filter_index && r->ndm_ifindex) {
+		if (jw_global)
+			jsonw_string_field(jw_global, "dev",
+					   ll_index_to_name(r->ndm_ifindex));
+		else
+			fprintf(fp, "dev %s ",
+				ll_index_to_name(r->ndm_ifindex));
+	}
 
 	if (tb[NDA_DST]) {
 		int family = AF_INET;
+		const char *abuf_s;
 
 		if (RTA_PAYLOAD(tb[NDA_DST]) == sizeof(struct in6_addr))
 			family = AF_INET6;
 
-		fprintf(fp, "dst %s ",
-			format_host(family,
-				    RTA_PAYLOAD(tb[NDA_DST]),
-				    RTA_DATA(tb[NDA_DST])));
+		abuf_s = format_host(family,
+				     RTA_PAYLOAD(tb[NDA_DST]),
+				     RTA_DATA(tb[NDA_DST]));
+		if (jw_global)
+			jsonw_string_field(jw_global, "dst", abuf_s);
+		else
+			fprintf(fp, "dst %s ", abuf_s);
+	}
+
+	if (vid) {
+		if (jw_global)
+			jsonw_uint_field(jw_global, "vlan", vid);
+		else
+			fprintf(fp, "vlan %hu ", vid);
+	}
+
+	if (tb[NDA_PORT]) {
+		if (jw_global)
+			jsonw_uint_field(jw_global, "port",
+					 ntohs(rta_getattr_u16(tb[NDA_PORT])));
+		else
+			fprintf(fp, "port %d ",
+				ntohs(rta_getattr_u16(tb[NDA_PORT])));
 	}
 
-	if (vid)
-		fprintf(fp, "vlan %hu ", vid);
+	if (tb[NDA_VNI]) {
+		if (jw_global)
+			jsonw_uint_field(jw_global, "vni",
+					 rta_getattr_u32(tb[NDA_VNI]));
+		else
+			fprintf(fp, "vni %d ",
+				rta_getattr_u32(tb[NDA_VNI]));
+	}
 
-	if (tb[NDA_PORT])
-		fprintf(fp, "port %d ", ntohs(rta_getattr_u16(tb[NDA_PORT])));
-	if (tb[NDA_VNI])
-		fprintf(fp, "vni %d ", rta_getattr_u32(tb[NDA_VNI]));
 	if (tb[NDA_IFINDEX]) {
 		unsigned int ifindex = rta_getattr_u32(tb[NDA_IFINDEX]);
 
@@ -136,37 +190,95 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			char ifname[IF_NAMESIZE];
 
 			if (!tb[NDA_LINK_NETNSID] &&
-			    if_indextoname(ifindex, ifname))
-				fprintf(fp, "via %s ", ifname);
-			else
-				fprintf(fp, "via ifindex %u ", ifindex);
+			    if_indextoname(ifindex, ifname)) {
+				if (jw_global)
+					jsonw_string_field(jw_global, "viaIf",
+							   ifname);
+				else
+					fprintf(fp, "via %s ", ifname);
+			} else {
+				if (jw_global)
+					jsonw_uint_field(jw_global, "viaIfIndex",
+							 ifindex);
+				else
+					fprintf(fp, "via ifindex %u ", ifindex);
+			}
 		}
 	}
-	if (tb[NDA_LINK_NETNSID])
-		fprintf(fp, "link-netnsid %d ",
-			rta_getattr_u32(tb[NDA_LINK_NETNSID]));
+
+	if (tb[NDA_LINK_NETNSID]) {
+		if (jw_global)
+			jsonw_uint_field(jw_global, "linkNetNsId",
+					 rta_getattr_u32(tb[NDA_LINK_NETNSID]));
+		else
+			fprintf(fp, "link-netnsid %d ",
+				rta_getattr_u32(tb[NDA_LINK_NETNSID]));
+	}
 
 	if (show_stats && tb[NDA_CACHEINFO]) {
 		struct nda_cacheinfo *ci = RTA_DATA(tb[NDA_CACHEINFO]);
 		int hz = get_user_hz();
 
-		fprintf(fp, "used %d/%d ", ci->ndm_used/hz,
-		       ci->ndm_updated/hz);
+		if (jw_global) {
+			jsonw_uint_field(jw_global, "used",
+				ci->ndm_used/hz);
+			jsonw_uint_field(jw_global, "updated",
+				ci->ndm_updated/hz);
+		} else {
+			fprintf(fp, "used %d/%d ", ci->ndm_used/hz,
+					ci->ndm_updated/hz);
+		}
+	}
+
+	if (jw_global) {
+		if (r->ndm_flags & NTF_SELF) {
+			start_json_fdb_flags_array(&fdb_flags);
+			jsonw_string(jw_global, "self");
+		}
+		if (r->ndm_flags & NTF_ROUTER) {
+			start_json_fdb_flags_array(&fdb_flags);
+			jsonw_string(jw_global, "router");
+		}
+		if (r->ndm_flags & NTF_EXT_LEARNED) {
+			start_json_fdb_flags_array(&fdb_flags);
+			jsonw_string(jw_global, "offload");
+		}
+		if (r->ndm_flags & NTF_MASTER)
+			jsonw_string(jw_global, "master");
+		if (fdb_flags)
+			jsonw_end_array(jw_global);
+
+		if (tb[NDA_MASTER])
+			jsonw_string_field(jw_global,
+					   "master",
+					   ll_index_to_name(rta_getattr_u32(tb[NDA_MASTER])));
+
+	} else {
+		if (r->ndm_flags & NTF_SELF)
+			fprintf(fp, "self ");
+		if (r->ndm_flags & NTF_ROUTER)
+			fprintf(fp, "router ");
+		if (r->ndm_flags & NTF_EXT_LEARNED)
+			fprintf(fp, "offload ");
+		if (tb[NDA_MASTER]) {
+			fprintf(fp, "master %s ",
+				ll_index_to_name(rta_getattr_u32(tb[NDA_MASTER])));
+		} else if (r->ndm_flags & NTF_MASTER) {
+			fprintf(fp, "master ");
+		}
+	}
+
+	state_s = state_n2a(r->ndm_state);
+	if (jw_global) {
+		if (state_s[0])
+			jsonw_string_field(jw_global, "state", state_s);
+
+		jsonw_end_object(jw_global);
+	} else {
+		fprintf(fp, "%s\n", state_s);
+
+		fflush(fp);
 	}
-	if (r->ndm_flags & NTF_SELF)
-		fprintf(fp, "self ");
-	if (tb[NDA_MASTER])
-		fprintf(fp, "master %s ",
-			ll_index_to_name(rta_getattr_u32(tb[NDA_MASTER])));
-	else if (r->ndm_flags & NTF_MASTER)
-		fprintf(fp, "master ");
-	if (r->ndm_flags & NTF_ROUTER)
-		fprintf(fp, "router ");
-	if (r->ndm_flags & NTF_EXT_LEARNED)
-		fprintf(fp, "offload ");
-
-	fprintf(fp, "%s\n", state_n2a(r->ndm_state));
-	fflush(fp);
 
 	return 0;
 }
@@ -233,10 +345,22 @@ static int fdb_show(int argc, char **argv)
 		exit(1);
 	}
 
+	if (json_output) {
+		jw_global = jsonw_new(stdout);
+		if (!jw_global) {
+			fprintf(stderr, "Error allocation json object\n");
+			exit(1);
+		}
+		jsonw_start_array(jw_global);
+	}
 	if (rtnl_dump_filter(&rth, print_fdb, stdout) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		exit(1);
 	}
+	if (jw_global) {
+		jsonw_end_array(jw_global);
+		jsonw_destroy(&jw_global);
+	}
 
 	return 0;
 }
-- 
1.9.1
