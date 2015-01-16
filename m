From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] iproute2: bridge: support vlan range
Date: Thu, 15 Jan 2015 22:52:27 -0800
Message-ID: <1421391147-35021-1-git-send-email-roopa@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:44725 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbbAPGwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 01:52:31 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so22489285pad.3
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 22:52:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds vlan range support to bridge command 
using the newly added vinfo flags BRIDGE_VLAN_INFO_RANGE_BEGIN and
BRIDGE_VLAN_INFO_RANGE_END.

$bridge vlan show
port    vlan ids
br0      1 PVID Egress Untagged

dummy0   1 PVID Egress Untagged

$bridge vlan add vid 10-15 dev dummy0
port    vlan ids
br0      1 PVID Egress Untagged

dummy0   1 PVID Egress Untagged
         10
         11
         12
         13
         14
         15

$bridge vlan del vid 14 dev dummy0

$bridge vlan show
port    vlan ids
br0      1 PVID Egress Untagged

dummy0   1 PVID Egress Untagged
         10
         11
         12
         13
         15

$bridge vlan del vid 10-15 dev dummy0

$bridge vlan show
port    vlan ids
br0      1 PVID Egress Untagged

dummy0   1 PVID Egress Untagged

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 bridge/vlan.c             |   46 ++++++++++++++++++++++++++++++++++++++-------
 include/linux/if_bridge.h |    2 ++
 2 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index 3bd7b0d..90b3b6b 100644
--- a/bridge/vlan.c
+++ b/bridge/vlan.c
@@ -32,6 +32,7 @@ static int vlan_modify(int cmd, int argc, char **argv)
 	} req;
 	char *d = NULL;
 	short vid = -1;
+	short vid_end = -1;
 	struct rtattr *afspec;
 	struct bridge_vlan_info vinfo;
 	unsigned short flags = 0;
@@ -49,8 +50,18 @@ static int vlan_modify(int cmd, int argc, char **argv)
 			NEXT_ARG();
 			d = *argv;
 		} else if (strcmp(*argv, "vid") == 0) {
+			char *p;
 			NEXT_ARG();
-			vid = atoi(*argv);
+			p = strchr(*argv, '-');
+			if (p) {
+				*p = '\0';
+				p++;
+				vinfo.vid = atoi(*argv);
+				vid_end = atoi(p);
+				vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_BEGIN;
+			} else {
+				vinfo.vid = atoi(*argv);
+			}
 		} else if (strcmp(*argv, "self") == 0) {
 			flags |= BRIDGE_FLAGS_SELF;
 		} else if (strcmp(*argv, "master") == 0) {
@@ -67,7 +78,7 @@ static int vlan_modify(int cmd, int argc, char **argv)
 		argc--; argv++;
 	}
 
-	if (d == NULL || vid == -1) {
+	if (d == NULL || vinfo.vid == -1) {
 		fprintf(stderr, "Device and VLAN ID are required arguments.\n");
 		exit(-1);
 	}
@@ -78,20 +89,41 @@ static int vlan_modify(int cmd, int argc, char **argv)
 		return -1;
 	}
 
-	if (vid >= 4096) {
-		fprintf(stderr, "Invalid VLAN ID \"%hu\"\n", vid);
+	if (vinfo.vid >= 4096) {
+		fprintf(stderr, "Invalid VLAN ID \"%hu\"\n", vinfo.vid);
 		return -1;
 	}
 
-	vinfo.vid = vid;
+	if (vinfo.flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
+		if (vid_end == -1 || vid_end >= 4096 || vinfo.vid >= vid_end) {
+			fprintf(stderr, "Invalid VLAN range \"%hu-%hu\"\n",
+				vinfo.vid, vid_end);
+			return -1;
+		}
+		if (vinfo.flags & BRIDGE_VLAN_INFO_PVID) {
+			fprintf(stderr,
+				"pvid cannot be configured for a vlan range\n");
+			return -1;
+		}
+	}
 
 	afspec = addattr_nest(&req.n, sizeof(req), IFLA_AF_SPEC);
 
 	if (flags)
 		addattr16(&req.n, sizeof(req), IFLA_BRIDGE_FLAGS, flags);
 
-	addattr_l(&req.n, sizeof(req), IFLA_BRIDGE_VLAN_INFO, &vinfo,
-		  sizeof(vinfo));
+	if (vid_end != -1) {
+		addattr_l(&req.n, sizeof(req), IFLA_BRIDGE_VLAN_INFO, &vinfo,
+			  sizeof(vinfo));
+		vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN;
+		vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_END;
+		vinfo.vid = vid_end;
+		addattr_l(&req.n, sizeof(req), IFLA_BRIDGE_VLAN_INFO, &vinfo,
+			  sizeof(vinfo));
+	} else {
+		addattr_l(&req.n, sizeof(req), IFLA_BRIDGE_VLAN_INFO, &vinfo,
+			  sizeof(vinfo));
+	}
 
 	addattr_nest_end(&req.n, afspec);
 
diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index ed6868e..e21a649 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -124,6 +124,8 @@ enum {
 #define BRIDGE_VLAN_INFO_MASTER	(1<<0)	/* Operate on Bridge device as well */
 #define BRIDGE_VLAN_INFO_PVID	(1<<1)	/* VLAN is PVID, ingress untagged */
 #define BRIDGE_VLAN_INFO_UNTAGGED	(1<<2)	/* VLAN egresses untagged */
+#define BRIDGE_VLAN_INFO_RANGE_BEGIN	(1<<3) /* VLAN is start of vlan range */
+#define BRIDGE_VLAN_INFO_RANGE_END	(1<<4)	/* VLAN is end of vlan range */
 
 struct bridge_vlan_info {
 	__u16 flags;
-- 
1.7.10.4
