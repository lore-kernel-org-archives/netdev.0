From: roopa@cumulusnetworks.com
Subject: [PATCH 3/6] bridge: modify IFLA_AF_SPEC parser to parse IFLA_BRIDGE_VLAN_RANGE_INFO
Date: Mon, 29 Dec 2014 13:05:29 -0800
Message-ID: <1419887132-7084-4-git-send-email-roopa@cumulusnetworks.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Wilson kok <wkok@cumulusnetworks.com>
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:58165 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606AbaL2VFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 16:05:43 -0500
Received: by mail-pd0-f169.google.com with SMTP id z10so17989108pdj.14
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 13:05:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch modifies br_afspec to parse incoming IFLA_BRIDGE_VLAN_RANGE_INFO

Signed-off-by: Wilson kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |   70 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 49 insertions(+), 21 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e7d1fc0..4c47ba0 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -227,48 +227,76 @@ static const struct nla_policy ifla_br_policy[IFLA_MAX+1] = {
 			 .len = sizeof(struct bridge_vlan_range_info), },
 };
 
+static int br_afspec_vlan_add(struct net_bridge *br,
+			      struct net_bridge_port *p,
+			      u16 vid, u16 flags)
+{
+	int err = 0;
+
+	if (p) {
+		err = nbp_vlan_add(p, vid, flags);
+		if (err)
+			return err;
+
+		if (flags & BRIDGE_VLAN_INFO_MASTER)
+			err = br_vlan_add(p->br, vid, flags);
+	} else {
+		err = br_vlan_add(br, vid, flags);
+	}
+
+	return err;
+}
+
+static void br_afspec_vlan_del(struct net_bridge *br,
+			       struct net_bridge_port *p,
+			       u16 vid, u16 flags)
+{
+	if (p) {
+		nbp_vlan_delete(p, vid);
+		if (flags & BRIDGE_VLAN_INFO_MASTER)
+			br_vlan_delete(p->br, vid);
+	} else {
+		br_vlan_delete(br, vid);
+	}
+}
+
 static int br_afspec(struct net_bridge *br,
 		     struct net_bridge_port *p,
 		     struct nlattr *af_spec,
 		     int cmd)
 {
-	struct bridge_vlan_info *vinfo;
-	int err = 0;
+	struct bridge_vlan_range_info *vinfo;
 	struct nlattr *attr;
 	int err = 0;
 	int rem;
 	u16 vid;
 
 	nla_for_each_nested(attr, af_spec, rem) {
-		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
+		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO &&
+		    nla_type(attr) != IFLA_BRIDGE_VLAN_RANGE_INFO)
 			continue;
-
 		vinfo = nla_data(attr);
-		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
+
+		if (nla_type(attr) == IFLA_BRIDGE_VLAN_INFO)
+			vinfo->vid_end = vinfo->vid;
+
+		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK ||
+		    vinfo->vid_end >= VLAN_VID_MASK ||
+		    vinfo->vid > vinfo->vid_end)
 			return -EINVAL;
 
 		switch (cmd) {
 		case RTM_SETLINK:
-			if (p) {
-				err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
+			for (vid = vinfo->vid; vid <= vinfo->vid_end; vid++) {
+				err = br_afspec_vlan_add(br, p, vid,
+							 vinfo->flags);
 				if (err)
 					break;
-
-				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
-					err = br_vlan_add(p->br, vinfo->vid,
-							  vinfo->flags);
-			} else
-				err = br_vlan_add(br, vinfo->vid, vinfo->flags);
-
+			}
 			break;
-
 		case RTM_DELLINK:
-			if (p) {
-				nbp_vlan_delete(p, vinfo->vid);
-				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
-					br_vlan_delete(p->br, vinfo->vid);
-			} else
-				br_vlan_delete(br, vinfo->vid);
+			for (vid = vinfo->vid; vid <= vinfo->vid_end; vid++)
+				br_afspec_vlan_del(br, p, vid, vinfo->flags);
 			break;
 		}
 	}
-- 
1.7.10.4
