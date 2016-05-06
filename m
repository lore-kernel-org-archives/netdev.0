From: Eli Cohen <eli@mellanox.com>
Subject: [PATCH] Add support for configuring Infiniband GUIDs
Date: Fri,  6 May 2016 10:43:25 -0500
Message-ID: <1462549405-16003-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51412 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758083AbcEFPn6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2016 11:43:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add two NLA's that allow configuration of Infiniband node or port GUIDs
by referencing the IPoIB net device set over then physical function. The
format to be used is as follows:

ip link set dev ib0 vf 0 node_guid 00:02:c9:03:00:21:6e:70
ip link set dev ib0 vf 0 port_guid 00:02:c9:03:00:21:6e:78

Issue: 702759
Change-Id: I5ffb54d6de7bfa8650bf5818f484279914991d6e
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 ip/iplink.c           | 40 ++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-link.8.in | 12 +++++++++++-
 2 files changed, 51 insertions(+), 1 deletion(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index d2e586b6d133..3f885defdfeb 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -237,6 +237,30 @@ struct iplink_req {
 	char			buf[1024];
 };
 
+static int extract_guid(__u64 *guid, char *arg)
+{
+	__u64 ret;
+	int g[8];
+	int err;
+
+	err = sscanf(arg, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
+		     g, g + 1, g + 2, g + 3, g + 4, g + 5, g + 6, g + 7);
+	if (err != 8)
+		return -1;
+
+	ret = ((__u64)(g[0]) << 56) |
+	      ((__u64)(g[1]) << 48) |
+	      ((__u64)(g[2]) << 40) |
+	      ((__u64)(g[3]) << 32) |
+	      ((__u64)(g[4]) << 24) |
+	      ((__u64)(g[5]) << 16) |
+	      ((__u64)(g[6]) << 8) |
+	      ((__u64)(g[7]));
+	*guid = ret;
+
+	return 0;
+}
+
 static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			   struct iplink_req *req, int dev_index)
 {
@@ -383,6 +407,22 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 				invarg("Invalid \"state\" value\n", *argv);
 			ivl.vf = vf;
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_LINK_STATE, &ivl, sizeof(ivl));
+		} else if (matches(*argv, "node_guid") == 0) {
+			struct ifla_vf_guid ivg;
+
+			NEXT_ARG();
+			ivg.vf = vf;
+			if (extract_guid(&ivg.guid, *argv))
+				return -1;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_IB_NODE_GUID, &ivg, sizeof(ivg));
+		} else if (matches(*argv, "port_guid") == 0) {
+			struct ifla_vf_guid ivg;
+
+			NEXT_ARG();
+			ivg.vf = vf;
+			if (extract_guid(&ivg.guid, *argv))
+				return -1;
+			addattr_l(&req->n, sizeof(*req), IFLA_VF_IB_PORT_GUID, &ivg, sizeof(ivg));
 		} else {
 			/* rewind arg */
 			PREV_ARG();
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 805511423ef2..e143a5ec8a9a 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -143,7 +143,11 @@ ip-link \- network device configuration
 .br
 .RB "[ " state " { " auto " | " enable " | " disable " } ]"
 .br
-.RB "[ " trust " { " on " | " off " } ] ]"
+.RB "[ " trust " { " on " | " off " } ]"
+.br
+.RB "[ " node_guid " eui64 ]"
+.br
+.RB "[ " port_guid " eui64 ] ]"
 .br
 .in -9
 .RB "[ " master
@@ -1033,6 +1037,12 @@ sent by the VF.
 .BI trust " on|off"
 - trust the specified VF user. This enables that VF user can set a specific feature
 which may impact security and/or performance. (e.g. VF multicast promiscuous mode)
+.sp
+.BI node_guid " eui64"
+- configure node GUID for the VF.
+.sp
+.BI port_guid " eui64"
+- configure port GUID for the VF.
 .in -8
 
 .TP
-- 
2.8.1
