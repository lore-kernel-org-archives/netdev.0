From: roopa@cumulusnetworks.com
Subject: [PATCH 5/6] bridge: new function to pack vlans using both IFLA_BRIDGE_VLAN_INFO and IFLA_BRIDGE_VLAN_RANGE_INFO
Date: Mon, 29 Dec 2014 13:05:31 -0800
Message-ID: <1419887132-7084-6-git-send-email-roopa@cumulusnetworks.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Wilson kok <wkok@cumulusnetworks.com>
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:44627 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbaL2VFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 16:05:44 -0500
Received: by mail-pd0-f181.google.com with SMTP id v10so17983741pde.12
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 13:05:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds new function to compress vlans into ranges.
Vlans are compressed into ranges only if the fill request is called with
RTEXT_FILTER_BRVLAN_COMPRESSED in filtermask.

Old vlan packing code is moved to a new function and continues to be
called when filter_mask is RTEXT_FILTER_BRVLAN

Signed-off-by: Wilson kok <wkok@cumulusnetworks.com>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |  157 +++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 137 insertions(+), 20 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 4c47ba0..16bdd5a 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -67,6 +67,133 @@ static int br_port_fill_attrs(struct sk_buff *skb,
 	return 0;
 }
 
+static int br_fill_ifvlaninfo_bitmap(struct sk_buff *skb,
+				     const unsigned long *vlan_bmp, u16 flags)
+{
+	struct bridge_vlan_range_info vinfo_range;
+	struct bridge_vlan_info vinfo;
+	u16 vid, start = 0, end = 0;
+	u16 pvid;
+
+	/* handle the untagged */
+	for_each_set_bit(vid, vlan_bmp, VLAN_N_VID) {
+		if (start == 0) {
+			start = vid;
+			end = vid;
+		}
+		if ((vid - end) > 1) {
+			memset(&vinfo_range, 0, sizeof(vinfo_range));
+			vinfo_range.flags |= flags;
+			vinfo_range.vid = start;
+			vinfo_range.vid_end = end;
+			if (nla_put(skb, IFLA_BRIDGE_VLAN_RANGE_INFO,
+				    sizeof(vinfo_range), &vinfo_range))
+				goto nla_put_failure;
+			start = vid;
+			end = vid;
+		} else {
+			end = vid;
+		}
+	}
+
+	if (start != 0 && end != 0) {
+		if (start != end) {
+			memset(&vinfo_range, 0, sizeof(vinfo_range));
+			vinfo_range.flags |= flags;
+			vinfo_range.vid = start;
+			vinfo_range.vid_end = end;
+			if (nla_put(skb, IFLA_BRIDGE_VLAN_RANGE_INFO,
+				    sizeof(vinfo_range), &vinfo_range))
+				goto nla_put_failure;
+		} else {
+			memset(&vinfo, 0, sizeof(vinfo));
+			vinfo.flags |= flags;
+			vinfo.vid = start;
+			if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
+				    sizeof(vinfo), &vinfo))
+				goto nla_put_failure;
+		}
+	}
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int br_fill_ifvlaninfo_compressed(struct sk_buff *skb,
+					 const struct net_port_vlans *pv)
+{
+	unsigned long vlan_bmp_copy[BR_VLAN_BITMAP_LEN];
+	unsigned long untagged_bmp_copy[BR_VLAN_BITMAP_LEN];
+	struct bridge_vlan_range_info vinfo_range;
+	struct bridge_vlan_info vinfo;
+	u16 pvid;
+
+	memset(vlan_bmp_copy, 0,
+	       sizeof(unsigned long) * BR_VLAN_BITMAP_LEN);
+	bitmap_copy(vlan_bmp_copy, pv->vlan_bitmap, VLAN_N_VID);
+
+	memset(untagged_bmp_copy, 0,
+	       sizeof(unsigned long) * BR_VLAN_BITMAP_LEN);
+	bitmap_copy(untagged_bmp_copy, pv->untagged_bitmap, VLAN_N_VID);
+
+	/* send the pvid separately first */
+	pvid = br_get_pvid(pv);
+	if (pvid && (pvid != VLAN_N_VID)) {
+		memset(&vinfo, 0, sizeof(vinfo));
+		vinfo.flags |= BRIDGE_VLAN_INFO_PVID;
+		if (test_bit(pvid, untagged_bmp_copy)) {
+			vinfo.flags |= BRIDGE_VLAN_INFO_UNTAGGED;
+			clear_bit(pvid, untagged_bmp_copy);
+		}
+		clear_bit(pvid, vlan_bmp_copy);
+		vinfo.vid = pvid;
+		if (nla_put(skb, IFLA_BRIDGE_VLAN_INFO,
+			    sizeof(vinfo), &vinfo))
+			goto nla_put_failure;
+	}
+
+	/* fill untagged vlans */
+	br_fill_ifvlaninfo_bitmap(skb, untagged_bmp_copy,
+				  BRIDGE_VLAN_INFO_UNTAGGED);
+	for_each_set_bit(vid, untagged_bmp_copy, VLAN_N_VID)
+		clear_bit(vid, vlan_bmp_copy);
+
+	/* fill tagged vlans */
+	br_fill_ifvlaninfo_bitmap(skb, vlan_bmp_copy, 0);
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
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
@@ -121,12 +248,11 @@ static int br_fill_ifinfo(struct sk_buff *skb,
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
@@ -140,21 +266,12 @@ static int br_fill_ifinfo(struct sk_buff *skb,
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
 
-- 
1.7.10.4
