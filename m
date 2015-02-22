From: roopa@cumulusnetworks.com
Subject: [PATCH net-next] bridge: add vlan info to bridge setlink and dellink notification messages
Date: Sat, 21 Feb 2015 20:21:51 -0800
Message-ID: <1424578911-6813-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, sfeldma@gmail.com, wkok@cumulusnetworks.com,
	siva.mannem.lnx@gmail.com
To: netdev@vger.kernel.org, stephen@networkplumber.org,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:37986 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbbBVEV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2015 23:21:56 -0500
Received: by pdbfp1 with SMTP id fp1so17245384pdb.5
        for <netdev@vger.kernel.org>; Sat, 21 Feb 2015 20:21:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

vlan add/deletes are not notified to userspace today. This patch adds
vlan info to bridge newlink/dellink notifications generated from the bridge
driver. Notifications use the RTEXT_FILTER_BRVLAN_COMPRESSED flag to compress vlans into ranges whereever applicable.

The size calculations does not take ranges into account for simplicity.
This has the potential for allocating a larger skb than required.

There is an existing inconsistency with bridge NEWLINK and
DELLINK change notifications. Both generate NEWLINK notifications.
Since its always a NEWLINK notification, this patch includes all
vlans the port belongs to in the notification. The NEWLINK and DELLINK
request messages however only include the vlans to be added and
deleted.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_netlink.c |   46 ++++++++++++++++++++++++----------------------
 1 file changed, 24 insertions(+), 22 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 4fbcea0..17e0177 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -22,6 +22,24 @@
 #include "br_private.h"
 #include "br_private_stp.h"
 
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
 static inline size_t br_port_info_size(void)
 {
 	return nla_total_size(1)	/* IFLA_BRPORT_STATE  */
@@ -36,7 +54,7 @@ static inline size_t br_port_info_size(void)
 		+ 0;
 }
 
-static inline size_t br_nlmsg_size(void)
+static inline size_t br_nlmsg_size(struct net_device *dev)
 {
 	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
 		+ nla_total_size(IFNAMSIZ) /* IFLA_IFNAME */
@@ -45,7 +63,8 @@ static inline size_t br_nlmsg_size(void)
 		+ nla_total_size(4) /* IFLA_MTU */
 		+ nla_total_size(4) /* IFLA_LINK */
 		+ nla_total_size(1) /* IFLA_OPERSTATE */
-		+ nla_total_size(br_port_info_size()); /* IFLA_PROTINFO */
+		+ nla_total_size(br_port_info_size()) /* IFLA_PROTINFO */
+		+ nla_total_size(br_get_link_af_size(dev)); /* IFLA_AF_SPEC */
 }
 
 static int br_port_fill_attrs(struct sk_buff *skb,
@@ -288,11 +307,12 @@ void br_ifinfo_notify(int event, struct net_bridge_port *port)
 	br_debug(port->br, "port %u(%s) event %d\n",
 		 (unsigned int)port->port_no, port->dev->name, event);
 
-	skb = nlmsg_new(br_nlmsg_size(), GFP_ATOMIC);
+	skb = nlmsg_new(br_nlmsg_size(port->dev), GFP_ATOMIC);
 	if (skb == NULL)
 		goto errout;
 
-	err = br_fill_ifinfo(skb, port, 0, 0, event, 0, 0, port->dev);
+	err = br_fill_ifinfo(skb, port, 0, 0, event, 0,
+			     RTEXT_FILTER_BRVLAN_COMPRESSED, port->dev);
 	if (err < 0) {
 		/* -EMSGSIZE implies BUG in br_nlmsg_size() */
 		WARN_ON(err == -EMSGSIZE);
@@ -703,24 +723,6 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	return 0;
 }
 
-static size_t br_get_link_af_size(const struct net_device *dev)
-{
-	struct net_port_vlans *pv;
-
-	if (br_port_exists(dev))
-		pv = nbp_get_vlan_info(br_port_get_rtnl(dev));
-	else if (dev->priv_flags & IFF_EBRIDGE)
-		pv = br_get_vlan_info((struct net_bridge *)netdev_priv(dev));
-	else
-		return 0;
-
-	if (!pv)
-		return 0;
-
-	/* Each VLAN is returned in bridge_vlan_info along with flags */
-	return pv->num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
-}
-
 static struct rtnl_af_ops br_af_ops __read_mostly = {
 	.family			= AF_BRIDGE,
 	.get_link_af_size	= br_get_link_af_size,
-- 
1.7.10.4
