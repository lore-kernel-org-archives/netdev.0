From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH 3/6] bridge: modify IFLA_AF_SPEC parser to parse
 IFLA_BRIDGE_VLAN_RANGE_INFO
Date: Tue, 30 Dec 2014 08:40:39 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC3505DD146F@ORSMSX101.amr.corp.intel.com>
References: <1419887132-7084-4-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Wilson kok <wkok@cumulusnetworks.com>
To: "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41902 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751683AbaL3IlD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 03:41:03 -0500
In-Reply-To: <1419887132-7084-4-git-send-email-roopa@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of roopa@cumulusnetworks.com
>Sent: Monday, December 29, 2014 11:05 PM
>To: netdev@vger.kernel.org; shemminger@vyatta.com; vyasevic@redhat.com
>Cc: Roopa Prabhu; Wilson kok
>Subject: [PATCH 3/6] bridge: modify IFLA_AF_SPEC parser to parse
>IFLA_BRIDGE_VLAN_RANGE_INFO
>
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>This patch modifies br_afspec to parse incoming IFLA_BRIDGE_VLAN_RANGE_INFO
>
>Signed-off-by: Wilson kok <wkok@cumulusnetworks.com>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>---
> net/bridge/br_netlink.c |   70 +++++++++++++++++++++++++++++++++-------------
>-
> 1 file changed, 49 insertions(+), 21 deletions(-)
>
>diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>index e7d1fc0..4c47ba0 100644
>--- a/net/bridge/br_netlink.c
>+++ b/net/bridge/br_netlink.c
>@@ -227,48 +227,76 @@ static const struct nla_policy
>ifla_br_policy[IFLA_MAX+1] = {
> 			 .len = sizeof(struct bridge_vlan_range_info), },
> };
>
>+static int br_afspec_vlan_add(struct net_bridge *br,
>+			      struct net_bridge_port *p,
>+			      u16 vid, u16 flags)
>+{
>+	int err = 0;
>+
>+	if (p) {
>+		err = nbp_vlan_add(p, vid, flags);
>+		if (err)
>+			return err;
>+
>+		if (flags & BRIDGE_VLAN_INFO_MASTER)
>+			err = br_vlan_add(p->br, vid, flags);
>+	} else {
>+		err = br_vlan_add(br, vid, flags);
>+	}
>+
>+	return err;
>+}
>+
>+static void br_afspec_vlan_del(struct net_bridge *br,
>+			       struct net_bridge_port *p,
>+			       u16 vid, u16 flags)
>+{
>+	if (p) {
>+		nbp_vlan_delete(p, vid);
>+		if (flags & BRIDGE_VLAN_INFO_MASTER)
>+			br_vlan_delete(p->br, vid);
>+	} else {
>+		br_vlan_delete(br, vid);
>+	}
>+}
>+
> static int br_afspec(struct net_bridge *br,
> 		     struct net_bridge_port *p,
> 		     struct nlattr *af_spec,
> 		     int cmd)
> {
>-	struct bridge_vlan_info *vinfo;
>-	int err = 0;
>+	struct bridge_vlan_range_info *vinfo;
> 	struct nlattr *attr;
> 	int err = 0;
> 	int rem;
> 	u16 vid;
>
> 	nla_for_each_nested(attr, af_spec, rem) {
>-		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
>+		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO &&
>+		    nla_type(attr) != IFLA_BRIDGE_VLAN_RANGE_INFO)
> 			continue;
>-
> 		vinfo = nla_data(attr);
>-		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK)
>+
>+		if (nla_type(attr) == IFLA_BRIDGE_VLAN_INFO)
>+			vinfo->vid_end = vinfo->vid;
>+
>+		if (!vinfo->vid || vinfo->vid >= VLAN_VID_MASK ||
>+		    vinfo->vid_end >= VLAN_VID_MASK ||
>+		    vinfo->vid > vinfo->vid_end)
> 			return -EINVAL;
>
> 		switch (cmd) {
> 		case RTM_SETLINK:
>-			if (p) {
>-				err = nbp_vlan_add(p, vinfo->vid, vinfo->flags);
>+			for (vid = vinfo->vid; vid <= vinfo->vid_end; vid++) {
>+				err = br_afspec_vlan_add(br, p, vid,
>+							 vinfo->flags);
vinfo->flags could have BRIDGE_VLAN_INFO_PVID set. It is really a port property and there could only be a single PVID for a port. The loop will make the port pvid set, in turn, to each vid in the range until it finally set to vid_end.
This could be avoided by turning off this flag for all but the last vid in range:

				err = br_afspec_vlan_addr(br, p, vid,
                                                    ((vid == vinfo->vid_end)
                                                     ? vinfo->flags
                                                     : vinfo->flags & ~BRIDGE_VLAN_INFO_PVID));
Another alternative could be to add explicit pvid field to bridge_vlan_range_info and disallow PVID flag.
This allows for setting the port pvid to any vid in the range.

If both alternatives seem somewhat complex we could just disallow PVID flag in IFLA_BRIDGE_VLAN_RANGE_INFO and allow it only in IFLA_BRIDGE_VLAN_INFO.

 
> 				if (err)
> 					break;
>-
>-				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>-					err = br_vlan_add(p->br, vinfo->vid,
>-							  vinfo->flags);
>-			} else
>-				err = br_vlan_add(br, vinfo->vid, vinfo->flags);
>-
>+			}
> 			break;
>-
> 		case RTM_DELLINK:
>-			if (p) {
>-				nbp_vlan_delete(p, vinfo->vid);
>-				if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
>-					br_vlan_delete(p->br, vinfo->vid);
>-			} else
>-				br_vlan_delete(br, vinfo->vid);
>+			for (vid = vinfo->vid; vid <= vinfo->vid_end; vid++)
>+				br_afspec_vlan_del(br, p, vid, vinfo->flags);
> 			break;
> 		}
> 	}
>--
>1.7.10.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
