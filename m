From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 3/3] bridge: new function to pack vlans into ranges during gets
Date: Sat, 10 Jan 2015 07:31:14 -0800
Message-ID: <1420903874-25528-4-git-send-email-roopa@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f49.google.com ([209.85.213.49]:52347 "EHLO
	mail-yh0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141AbbAJPbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 10:31:25 -0500
Received: by mail-yh0-f49.google.com with SMTP id f10so6520153yha.8
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2015 07:31:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds new function to pack vlans into ranges
whereever applicable using the flags BRIDGE_VLAN_INFO_RANGE_BEGIN
and BRIDGE VLAN_INFO_RANGE_END

Old vlan packing code is moved to a new function and continues to be
called when filter_mask is RTEXT_FILTER_BRVLAN.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |  145 ++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 124 insertions(+), 21 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 6f616a2..0b03879 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -67,6 +67,118 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	return 0;
 }
 
+static int br_fill_ifvlaninfo_range(struct sk_buff *skb, u16 vid_start,
+				    u16 vid_end, u16 flags)
+{
+	struct  bridge_vlan_info vinfo;
+
+	if ((vid_end - vid_start) > 0) {
+		/* add range to skb */
+		vinfo.vid = vid_start;
+		vinfo.flags = flags | BRIDGE_VLAN_INFO_RANGE_BEGIN;
+		if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
+			    sizeof(vinfo), &vinfo))
+			goto nla_put_failure;
+
+		vinfo.flags &= ~BRIDGE_VLAN_INFO_RANGE_BEGIN;
+
+		vinfo.vid = vid_end;
+		vinfo.flags = flags | BRIDGE_VLAN_INFO_RANGE_END;
+		if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
+			    sizeof(vinfo), &vinfo))
+			goto nla_put_failure;
+	} else {
+		vinfo.vid = vid_start;
+		vinfo.flags = flags;
+		if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
+			    sizeof(vinfo), &vinfo))
+			goto nla_put_failure;
+	}
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
+					 const struct net_port_vlans *pv)
+{
+	u16 vid_range_start = 0, vid_range_end = 0;
+	u16 vid_range_flags;
+	u16 pvid, vid, flags;
+	int err = 0;
+
+	/* Pack IFLA_BRIDGE_VLAN_INFO's for every vlan
+	 * and mark vlan info with begin and end flags
+	 * if vlaninfo represents a range
+	 */
+	pvid = br_get_pvid(pv);
+	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
+		flags = 0;
+		if (vid == pvid)
+			flags |= BRIDGE_VLAN_INFO_PVID;
+
+		if (test_bit(vid, pv->untagged_bitmap))
+			flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+
+		if (vid_range_start == 0) {
+			goto initvars;
+		} else if ((vid - vid_range_end) == 1 &&
+			flags == vid_range_flags) {
+			vid_range_end = vid;
+			continue;
+		} else {
+			err = br_fill_ifvlaninfo_range(skb, vid_range_start,
+						       vid_range_end,
+						       vid_range_flags);
+			if (err)
+				return err;
+		}
+
+initvars:
+		vid_range_start = vid;
+		vid_range_end = vid;
+		vid_range_flags = flags;
+	}
+
+	/* Call it once more to send any left over vlans */
+	err = br_fill_ifvlaninfo_range(skb, vid_range_start,
+				       vid_range_end,
+				       vid_range_flags);
+	if (err)
+		return err;
+
+	return 0;
+}
+
+static int br_fill_ifvlaninfo(struct sk_buff *skb,
+			      const struct net_port_vlans *pv)
+{
+	struct bridge_vlan_info vinfo;
+	u16 pvid, vid;
+
+	pvid = br_get_pvid(pv);
+	for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
+		vinfo.vid = vid;
+		vinfo.flags = 0;
+		if (vid == pvid)
+			vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
+
+		if (test_bit(vid, pv->untagged_bitmap))
+			vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+
+		if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
+			    sizeof(vinfo), &vinfo))
+			goto nla_put_failure;
+	}
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 /*
  * Create one netlink message for one interface
  * Contains port and master info as well as carrier and bridge state.
@@ -121,12 +233,11 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 	}
 
 	/* Check if  the VID information is requested */
-	if (filter_mask & RTEXT_FILTER_BRVLAN) {
-		struct nlattr *af;
+	if ((filter_mask & RTEXT_FILTER_BRVLAN) ||
+	    (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)) {
 		const struct net_port_vlans *pv;
-		struct bridge_vlan_info vinfo;
-		u16 vid;
-		u16 pvid;
+		struct nlattr *af;
+		int err;
 
 		if (port)
 			pv = nbp_get_vlan_info(port);
@@ -140,21 +251,12 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 		if (!af)
 			goto nla_put_failure;
 
-		pvid = br_get_pvid(pv);
-		for_each_set_bit(vid, pv->vlan_bitmap, VLAN_N_VID) {
-			vinfo.vid = vid;
-			vinfo.flags = 0;
-			if (vid == pvid)
-				vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
-
-			if (test_bit(vid, pv->untagged_bitmap))
-				vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
-
-			if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
-				    sizeof(vinfo), &vinfo))
-				goto nla_put_failure;
-		}
-
+		if (filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED)
+			err = br_fill_ifvlaninfo_compressed(skb, pv);
+		else
+			err = br_fill_ifvlaninfo(skb, pv);
+		if (err)
+			goto nla_put_failure;
 		nla_nest_end(skb, af);
 	}
 
@@ -209,7 +311,8 @@ int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	int err = 0;
 	struct net_bridge_port *port = br_port_get_rtnl(dev);
 
-	if (!port && !(filter_mask & RTEXT_FILTER_BRVLAN))
+	if (!port && !(filter_mask & RTEXT_FILTER_BRVLAN) &&
+	    !(filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED))
 		goto out;
 
 	err = br_fill_ifinfo(skb, port, pid, seq, RTM_NEWLINK, NLM_F_MULTI,
-- 
1.7.10.4
