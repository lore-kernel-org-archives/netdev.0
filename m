From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 1/3] bridge: support for multiple vlans and vlan ranges in setlink and dellink requests
Date: Sat, 10 Jan 2015 07:31:12 -0800
Message-ID: <1420903874-25528-2-git-send-email-roopa@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f47.google.com ([209.85.213.47]:40992 "EHLO
	mail-yh0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070AbbAJPbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 10:31:22 -0500
Received: by mail-yh0-f47.google.com with SMTP id f73so6518516yha.6
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2015 07:31:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch changes bridge IFLA_AF_SPEC netlink attribute parser to
look for more than one IFLA_BRIDGE_VLAN_INFO attribute. This allows
userspace to pack more than one vlan in the setlink msg.

The dumps were already sending more than one vlan info in the getlink msg.

This patch also adds bridge_vlan_info flags BRIDGE_VLAN_INFO_RANGE_BEGIN and
BRIDGE_VLAN_INFO_RANGE_END to indicate start and end of vlan range

This patch also deletes unused ifla_br_policy.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/uapi/linux/if_bridge.h |    2 +
 net/bridge/br_netlink.c        |  104 ++++++++++++++++++++++++++--------------
 2 files changed, 70 insertions(+), 36 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index b03ee8f..eaaea62 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -125,6 +125,8 @@ enum {
 #define BRIDGE_VLAN_INFO_MASTER	(1<<0)	/* Operate on Bridge device as well */
 #define BRIDGE_VLAN_INFO_PVID	(1<<1)	/* VLAN is PVID, ingress untagged */
 #define BRIDGE_VLAN_INFO_UNTAGGED	(1<<2)	/* VLAN egresses untagged */
+#define BRIDGE_VLAN_INFO_RANGE_BEGIN	(1<<3) /* VLAN is start of vlan range */
+#define BRIDGE_VLAN_INFO_RANGE_END	(1<<4) /* VLAN is end of vlan range */
 
 struct bridge_vlan_info {
 	__u16 flags;
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 9f5eb55..6f616a2 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -218,57 +218,89 @@ out:
 	return err;
 }
 
-static const struct nla_policy ifla_br_policy[IFLA_MAX+1] = {
-	[IFLA_BRIDGE_FLAGS]	= { .type = NLA_U16 },
-	[IFLA_BRIDGE_MODE]	= { .type = NLA_U16 },
-	[IFLA_BRIDGE_VLAN_INFO]	= { .type = NLA_BINARY,
-				    .len = sizeof(struct bridge_vlan_info), },
-};
+static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
+			int cmd, struct bridge_vlan_info *vinfo)
+{
+	int err = 0;
+
+	switch (cmd) {
+	case RTM_SETLINK:
+		if (p) {
+			err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
+			if (err)
+				break;
+
+			if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
+				err = br_vlan_add(p->br, vinfo->vid,
+						  vinfo->flags);
+		} else {
+			err = br_vlan_add(br, vinfo->vid, vinfo->flags);
+		}
+		break;
+
+	case RTM_DELLINK:
+		if (p) {
+			nbp_vlan_delete(p, vinfo->vid);
+			if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
+				br_vlan_delete(p->br, vinfo->vid);
+		} else {
+			br_vlan_delete(br, vinfo->vid);
+		}
+		break;
+	}
+
+	return err;
+}
 
 static int br_afspec(struct net_bridge *br,
 		     struct net_bridge_port *p,
 		     struct nlattr *af_spec,
 		     int cmd)
 {
-	struct nlattr *tb[IFLA_BRIDGE_MAX+1];
+	struct bridge_vlan_info *vinfo_start = NULL;
+	struct bridge_vlan_info *vinfo = NULL;
+	struct nlattr *attr;
 	int err = 0;
+	int rem;
 
-	err = nla_parse_nested(tb, IFLA_BRIDGE_MAX, af_spec, ifla_br_policy);
-	if (err)
-		return err;
+	nla_for_each_nested(attr, af_spec, rem) {
+		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
+			continue;
+		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
+			return -EINVAL;
+		vinfo = nla_data(attr);
+		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
+			if (vinfo_start)
+				return -EINVAL;
+			vinfo_start = vinfo;
+			continue;
+		}
+
+		if (vinfo_start) {
+			struct bridge_vlan_info tmp_vinfo;
+			int v;
 
-	if (tb[IFLA_BRIDGE_VLAN_INFO]) {
-		struct bridge_vlan_info *vinfo;
+			if (!(vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END))
+				return -EINVAL;
 
-		vinfo = nla_data(tb[IFLA_BRIDGE_VLAN_INFO]);
+			if (vinfo->vid <= vinfo_start->vid)
+				return -EINVAL;
 
-		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
-			return -EINVAL;
+			memcpy(&tmp_vinfo, vinfo_start,
+			       sizeof(struct bridge_vlan_info));
 
-		switch (cmd) {
-		case RTM_SETLINK:
-			if (p) {
-				err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
+			for (v = vinfo_start->vid; v <= vinfo->vid; v++) {
+				tmp_vinfo.vid = v;
+				err = br_vlan_info(br, p, cmd, &tmp_vinfo);
 				if (err)
 					break;
-
-				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
-					err = br_vlan_add(p->br, vinfo->vid,
-							  vinfo->flags);
-			} else
-				err = br_vlan_add(br, vinfo->vid, vinfo->flags);
-
-			break;
-
-		case RTM_DELLINK:
-			if (p) {
-				nbp_vlan_delete(p, vinfo->vid);
-				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
-					br_vlan_delete(p->br, vinfo->vid);
-			} else
-				br_vlan_delete(br, vinfo->vid);
-			break;
+			}
+			vinfo_start = NULL;
+		} else {
+			err = br_vlan_info(br, p, cmd, vinfo);
 		}
+		if (err)
+			break;
 	}
 
 	return err;
-- 
1.7.10.4
