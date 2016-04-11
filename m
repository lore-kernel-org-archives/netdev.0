From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 v2 3/3] bridge: vlan: add support to filter by vlan id
Date: Mon, 11 Apr 2016 17:45:16 +0200
Message-ID: <1460389516-1643-4-git-send-email-nikolay@cumulusnetworks.com>
References: <570BC2FD.8010201@cumulusnetworks.com>
 <1460389516-1643-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37660 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbcDKPp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 11:45:27 -0400
Received: by mail-wm0-f43.google.com with SMTP id n3so110447452wmn.0
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 08:45:26 -0700 (PDT)
In-Reply-To: <1460389516-1643-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the optional keyword "vid" to bridge vlan show so the user can
request filtering by a specific vlan id. Currently the filtering is
implemented only in user-space. The argument name has been chosen to
match the add/del one - "vid". This filtering can be used also with the
"-compressvlans" option to see in which range is a vlan (if in any).
Also this will be used to show only specific per-vlan statistics later
when support is added to the kernel for it.

Examples:
$ bridge vlan show vid 450
port	vlan ids
eth2	 450

$ bridge -c vlan show vid 450
port	vlan ids
eth2	 400-500

$ bridge vlan show vid 1
port	vlan ids
eth1	 1 PVID Egress Untagged
eth2	 1 PVID
br0	 1 PVID Egress Untagged

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: don't print ports which are not matching the vlan filter
The vcheck_ret == 1 case implicit use is to avoid a nesting level which
breaks a lot of lines and produces uglier result.

 bridge/vlan.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 50 insertions(+), 10 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index ae588323d9b1..717025ae6eec 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -13,13 +13,13 @@
 #include "br_common.h"
 #include "utils.h"
 
-static unsigned int filter_index;
+static unsigned int filter_index, filter_vlan;
 
 static void usage(void)
 {
 	fprintf(stderr, "Usage: bridge vlan { add | del } vid VLAN_ID dev DEV [ pvid] [ untagged ]\n");
 	fprintf(stderr, "                                                     [ self ] [ master ]\n");
-	fprintf(stderr, "       bridge vlan { show } [ dev DEV ]\n");
+	fprintf(stderr, "       bridge vlan { show } [ dev DEV ] [ vid VLAN_ID ]\n");
 	exit(-1);
 }
 
@@ -138,6 +138,26 @@ static int vlan_modify(int cmd, int argc, char **argv)
 	return 0;
 }
 
+/* In order to use this function for both filtering and non-filtering cases
+ * we need to make it a tristate:
+ * return -1 - if filtering we've gone over so don't continue
+ * return  0 - skip entry and continue (applies to range start or to entries
+ *             which are less than filter_vlan)
+ * return  1 - print the entry and continue
+ */
+static int filter_vlan_check(struct bridge_vlan_info *vinfo)
+{
+	/* if we're filtering we should stop on the first greater entry */
+	if (filter_vlan && vinfo->vid > filter_vlan &&
+	    !(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
+		return -1;
+	if ((vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) ||
+	    vinfo->vid < filter_vlan)
+		return 0;
+
+	return 1;
+}
+
 static int print_vlan(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n,
 		      void *arg)
@@ -169,26 +189,40 @@ static int print_vlan(const struct sockaddr_nl *who,
 
 	/* if AF_SPEC isn't there, vlan table is not preset for this port */
 	if (!tb[IFLA_AF_SPEC]) {
-		fprintf(fp, "%s\tNone\n", ll_index_to_name(ifm->ifi_index));
+		if (!filter_vlan)
+			fprintf(fp, "%s\tNone\n",
+				ll_index_to_name(ifm->ifi_index));
 		return 0;
 	} else {
 		struct rtattr *i, *list = tb[IFLA_AF_SPEC];
 		int rem = RTA_PAYLOAD(list);
+		__u16 last_vid_start = 0;
 
-		fprintf(fp, "%s", ll_index_to_name(ifm->ifi_index));
+		if (!filter_vlan)
+			fprintf(fp, "%s", ll_index_to_name(ifm->ifi_index));
 		for (i = RTA_DATA(list); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
 			struct bridge_vlan_info *vinfo;
+			int vcheck_ret;
 
 			if (i->rta_type != IFLA_BRIDGE_VLAN_INFO)
 				continue;
 
 			vinfo = RTA_DATA(i);
-			if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END)
-				fprintf(fp, "-%hu", vinfo->vid);
-			else
-				fprintf(fp, "\t %hu", vinfo->vid);
-			if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN)
+
+			if (!(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
+				last_vid_start = vinfo->vid;
+			vcheck_ret = filter_vlan_check(vinfo);
+			if (vcheck_ret == -1)
+				break;
+			else if (vcheck_ret == 0)
 				continue;
+
+			if (filter_vlan)
+				fprintf(fp, "%s",
+					ll_index_to_name(ifm->ifi_index));
+			fprintf(fp, "\t %hu", last_vid_start);
+			if (last_vid_start != vinfo->vid)
+				fprintf(fp, "-%hu", vinfo->vid);
 			if (vinfo->flags & BRIDGE_VLAN_INFO_PVID)
 				fprintf(fp, " PVID");
 			if (vinfo->flags & BRIDGE_VLAN_INFO_UNTAGGED)
@@ -196,7 +230,8 @@ static int print_vlan(const struct sockaddr_nl *who,
 			fprintf(fp, "\n");
 		}
 	}
-	fprintf(fp, "\n");
+	if (!filter_vlan)
+		fprintf(fp, "\n");
 	fflush(fp);
 	return 0;
 }
@@ -211,6 +246,11 @@ static int vlan_show(int argc, char **argv)
 			if (filter_dev)
 				duparg("dev", *argv);
 			filter_dev = *argv;
+		} else if (strcmp(*argv, "vid") == 0) {
+			NEXT_ARG();
+			if (filter_vlan)
+				duparg("vid", *argv);
+			filter_vlan = atoi(*argv);
 		}
 		argc--; argv++;
 	}
-- 
2.4.3
