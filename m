From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCHv2 8/8] vxlan: fix oops when give unknown ifindex
Date: Tue, 09 Oct 2012 23:35:53 -0700
Message-ID: <20121010063623.935671507@vyatta.com>
References: <20121010063545.453368147@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:52295 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752496Ab2JJGjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 02:39:24 -0400
Content-Disposition: inline; filename=vxlan-baddev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vxlan is created and the ifindex is passed; there are two cases which
are incorrectly handled by the existing code. The ifindex could be zero
(i.e. no device) or there could be no device with that ifindex.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/vxlan.c	2012-10-09 22:07:41.417308505 -0700
+++ b/drivers/net/vxlan.c	2012-10-09 22:09:56.715949703 -0700
@@ -1090,14 +1090,18 @@ static int vxlan_newlink(struct net *net
 	if (data[IFLA_VXLAN_LOCAL])
 		vxlan->saddr = nla_get_be32(data[IFLA_VXLAN_LOCAL]);
 
-	if (data[IFLA_VXLAN_LINK]) {
-		vxlan->link = nla_get_u32(data[IFLA_VXLAN_LINK]);
+	if (data[IFLA_VXLAN_LINK] &&
+	    (vxlan->link = nla_get_u32(data[IFLA_VXLAN_LINK]))) {
+		struct net_device *lowerdev
+			 = __dev_get_by_index(net, vxlan->link);
 
-		if (!tb[IFLA_MTU]) {
-			struct net_device *lowerdev;
-			lowerdev = __dev_get_by_index(net, vxlan->link);
-			dev->mtu = lowerdev->mtu - VXLAN_HEADROOM;
+		if (!lowerdev) {
+			pr_info("ifindex %d does not exist\n", vxlan->link);
+			return -ENODEV;
 		}
+
+		if (!tb[IFLA_MTU])
+			dev->mtu = lowerdev->mtu - VXLAN_HEADROOM;
 	}
 
 	if (data[IFLA_VXLAN_TOS])
