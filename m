From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH iproute2 1/3] bridge: fdb: add support to filter by vlan id
Date: Mon, 11 Apr 2016 15:18:28 +0200
Message-ID: <1460380710-29583-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1460380710-29583-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37549 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755147AbcDKNTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 09:19:46 -0400
Received: by mail-wm0-f43.google.com with SMTP id n3so104309599wmn.0
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 06:19:45 -0700 (PDT)
In-Reply-To: <1460380710-29583-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the optional keyword "vlan" to bridge fdb show so the user can request
filtering by a specific vlan id. Currently the filtering is implemented
only in user-space. The argument name has been chosen to match the
add/del one - "vlan".

Example:
$ bridge fdb show vlan 400
52:54:00:bf:57:16 dev eth2 vlan 400 master br0 permanent

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 bridge/fdb.c | 21 +++++++++++++++------
 1 file changed, 15 insertions(+), 6 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index df55e86df83f..be849f980a80 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -27,7 +27,7 @@
 #include "rt_names.h"
 #include "utils.h"
 
-static unsigned int filter_index;
+static unsigned int filter_index, filter_vlan;
 
 static void usage(void)
 {
@@ -35,7 +35,7 @@ static void usage(void)
 			"              [ self ] [ master ] [ use ] [ router ]\n"
 			"              [ local | static | dynamic ] [ dst IPADDR ] [ vlan VID ]\n"
 			"              [ port PORT] [ vni VNI ] [ via DEV ]\n");
-	fprintf(stderr, "       bridge fdb [ show [ br BRDEV ] [ brport DEV ] ]\n");
+	fprintf(stderr, "       bridge fdb [ show [ br BRDEV ] [ brport DEV ] [ vlan VID ] ]\n");
 	exit(-1);
 }
 
@@ -65,6 +65,7 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	struct ndmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[NDA_MAX+1];
+	__u16 vid = 0;
 
 	if (n->nlmsg_type != RTM_NEWNEIGH && n->nlmsg_type != RTM_DELNEIGH) {
 		fprintf(stderr, "Not RTM_NEWNEIGH: %08x %08x %08x\n",
@@ -88,6 +89,12 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	parse_rtattr(tb, NDA_MAX, NDA_RTA(r),
 		     n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
+	if (tb[NDA_VLAN])
+		vid = rta_getattr_u16(tb[NDA_VLAN]);
+
+	if (filter_vlan && filter_vlan != vid)
+		return 0;
+
 	if (n->nlmsg_type == RTM_DELNEIGH)
 		fprintf(fp, "Deleted ");
 
@@ -115,11 +122,8 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				    RTA_DATA(tb[NDA_DST])));
 	}
 
-	if (tb[NDA_VLAN]) {
-		__u16 vid = rta_getattr_u16(tb[NDA_VLAN]);
-
+	if (vid)
 		fprintf(fp, "vlan %hu ", vid);
-	}
 
 	if (tb[NDA_PORT])
 		fprintf(fp, "port %d ", ntohs(rta_getattr_u16(tb[NDA_PORT])));
@@ -190,6 +194,11 @@ static int fdb_show(int argc, char **argv)
 		} else if (strcmp(*argv, "br") == 0) {
 			NEXT_ARG();
 			br = *argv;
+		} else if (strcmp(*argv, "vlan") == 0) {
+			NEXT_ARG();
+			if (filter_vlan)
+				duparg("vlan", *argv);
+			filter_vlan = atoi(*argv);
 		} else {
 			if (matches(*argv, "help") == 0)
 				usage();
-- 
2.4.3
