From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2] iproute2: bridge: support vlan range
Date: Thu, 22 Jan 2015 22:25:10 -0800
Message-ID: <1421994310-48811-1-git-send-email-roopa@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, sfeldma@gmail.com
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:40230 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753177AbbAWGZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 01:25:24 -0500
Received: by mail-pa0-f54.google.com with SMTP id eu11so6584773pac.13
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 22:25:23 -0800 (PST)
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

v2: fix vid check

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
---
 bridge/vlan.c             |   44 ++++++++++++++++++++++++++++++++++++++++----
 include/linux/if_bridge.h |    2 ++
 2 files changed, 42 insertions(+), 4 deletions(-)

diff --git a/bridge/vlan.c b/bridge/vlan.c
index 3bd7b0d..88992e6 100644
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
+				vid = atoi(*argv);
+				vid_end = atoi(p);
+				vinfo.flags |= BRIDGE_VLAN_INFO_RANGE_BEGIN;
+			} else {
+				vid = atoi(*argv);
+			}
 		} else if (strcmp(*argv, "self") == 0) {
 			flags |= BRIDGE_FLAGS_SELF;
 		} else if (strcmp(*argv, "master") == 0) {
@@ -83,15 +94,40 @@ static int vlan_modify(int cmd, int argc, char **argv)
 		return -1;
 	}
 
-	vinfo.vid = vid;
+	if (vinfo.flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
+		if (vid_end == -1 || vid_end >= 4096 || vid >= vid_end) {
+			fprintf(stderr, "Invalid VLAN range \"%hu-%hu\"\n",
+				vid, vid_end);
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
+	vinfo.vid = vid;
+	if (vid_end != -1) {
+		/* send vlan range start */
+		addattr_l(&req.n, sizeof(req), IFLA_BRIDGE_VLAN_INFO, &vinfo,
+			  sizeof(vinfo));
+		vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN;
+
+		/* Now send the vlan range end */
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
index 19ff22a..efa10b8 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -125,6 +125,8 @@ enum {
 #define BRIDGE_VLAN_INFO_MASTER	(1<<0)	/* Operate on Bridge device as well */
 #define BRIDGE_VLAN_INFO_PVID	(1<<1)	/* VLAN is PVID, ingress untagged */
 #define BRIDGE_VLAN_INFO_UNTAGGED	(1<<2)	/* VLAN egresses untagged */
+#define BRIDGE_VLAN_INFO_RANGE_BEGIN	(1<<3) /* VLAN is start of vlan range */
+#define BRIDGE_VLAN_INFO_RANGE_END	(1<<4)	/* VLAN is end of vlan range */
 
 struct bridge_vlan_info {
 	__u16 flags;
-- 
1.7.10.4
