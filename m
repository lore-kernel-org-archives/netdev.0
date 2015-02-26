From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] bridge: fix link notification skb size calculation to include vlan ranges
Date: Wed, 25 Feb 2015 23:55:40 -0800
Message-ID: <1424937340-22115-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	vyasevic@redhat.com, sfeldma@gmail.com, wkok@cumulusnetworks.com,
	siva.mannem.lnx@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35056 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbBZHzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 02:55:46 -0500
Received: by padfa1 with SMTP id fa1so12081298pad.2
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 23:55:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

my previous patch skipped vlan range optimizations during skb size
calculations for simplicity.

This incremental patch considers vlan ranges during
skb size calculations. This leads to a bit of code duplication
in the fill and size calculation functions. But, I could not find a
prettier way to do this. will take any suggestions.

Previously, I had reused the existing br_get_link_af_size size calculation
function to calculate skb size for notifications. Reusing it this time
around creates some change in behaviour issues for the usual
.get_link_af_size callback.

This patch adds a new br_get_link_af_size_filtered() function to
base the size calculation on the incoming filter flag and include
vlan ranges.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |   92 +++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 85 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 17e0177..3de0eef 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -22,9 +22,64 @@
 #include "br_private.h"
 #include "br_private_stp.h"
 
-static size_t br_get_link_af_size(const struct net_device *dev)
+static int br_get_num_vlan_infos(const struct net_port_vlans *pv,
+				 u32 filter_mask)
+{
+	u16 vid_range_start = 0, vid_range_end = 0;
+	u16 vid_range_flags = 0;
+	u16 pvid, vid, flags;
+	int num_vlans = 0;
+
+	if (filter_mask & RTEXT_FILTER_BRVLAN)
+		return pv->num_vlans;
+
+	if (!(filter_mask & RTEXT_FILTER_BRVLAN_COMPRESSED))
+		return 0;
+
+	/* Count number of vlan info's
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
+			if ((vid_range_end - vid_range_start) > 0)
+				num_vlans += 2;
+			else
+				num_vlans += 1;
+		}
+initvars:
+		vid_range_start = vid;
+		vid_range_end = vid;
+		vid_range_flags = flags;
+	}
+
+	if (vid_range_start != 0) {
+		if ((vid_range_end - vid_range_start) > 0)
+			num_vlans += 2;
+		else
+			num_vlans += 1;
+	}
+
+	return num_vlans;
+}
+
+static size_t br_get_link_af_size_filtered(const struct net_device *dev,
+					   u32 filter_mask)
 {
 	struct net_port_vlans *pv;
+	int num_vlan_infos;
 
 	if (br_port_exists(dev))
 		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
@@ -36,8 +91,12 @@ static size_t br_get_link_af_size(const struct net_device *dev)
 	if (!pv)
 		return 0;
 
+	num_vlan_infos = br_get_num_vlan_infos(pv, filter_mask);
+	if (!num_vlan_infos)
+		return 0;
+
 	/* Each VLAN is returned in bridge_vlan_info along with flags */
-	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
+	return num_vlan_infos * nla_total_size(sizeof(struct bridge_vlan_info));
 }
 
 static inline size_t br_port_info_size(void)
@@ -54,7 +113,7 @@ static inline size_t br_port_info_size(void)
 		+ 0;
 }
 
-static inline size_t br_nlmsg_size(struct net_device *dev)
+static inline size_t br_nlmsg_size(struct net_device *dev, u32 filter_mask)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
 		+ nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
@@ -64,7 +123,8 @@ static inline size_t br_nlmsg_size(struct net_device *dev)
 		+ nla_total_size(4) /* IFLA_LINK */
 		+ nla_total_size(1) /* IFLA_OPERSTATE */
 		+ nla_total_size(br_port_info_size()) /* IFLA_PROTINFO */
-		+ nla_total_size(br_get_link_af_size(dev)); /* IFLA_AF_SPEC */
+		+ nla_total_size(br_get_link_af_size_filtered(dev,
+				 filter_mask)); /* IFLA_AF_SPEC */
 }
 
 static int br_port_fill_attrs(struct sk_buff *skb,
@@ -299,6 +359,7 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 	struct net *net;
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
+	u32 filter = RTEXT_FILTER_BRVLAN_COMPRESSED;
 
 	if (!port)
 		return;
@@ -307,12 +368,11 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 	br_debug(port->br, "port %u(%s) event %d\n",
 		 (unsigned int)port->port_no, port->dev->name, event);
 
-	skb = nlmsg_new(br_nlmsg_size(port->dev), GFP_ATOMIC);
+	skb = nlmsg_new(br_nlmsg_size(port->dev, filter), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 
-	err = br_fill_ifinfo(skb, port, 0, 0, event, 0,
-			     RTEXT_FILTER_BRVLAN_COMPRESSED, port->dev);
+	err = br_fill_ifinfo(skb, port, 0, 0, event, 0, filter, port->dev);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in br_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -723,6 +783,24 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	return 0;
 }
 
+static size_t br_get_link_af_size(const struct net_device *dev)
+{
+	struct net_port_vlans *pv;
+
+	if (br_port_exists(dev))
+		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
+	else if (dev->priv_flags & IFF_EBRIDGE)
+		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
+	else
+		return 0;
+
+	if (!pv)
+		return 0;
+
+	/* Each VLAN is returned in bridge_vlan_info along with flags */
+	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
+}
+
 static struct rtnl_af_ops br_af_ops __read_mostly = {
 	.family			= AF_BRIDGE,
 	.get_link_af_size	= br_get_link_af_size,
-- 
1.7.10.4
