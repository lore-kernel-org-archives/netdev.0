From: Dan Streetman <dan.streetman@canonical.com>
Subject: [PATCH 4.4-stable 1/3] vxlan: Relax MTU constraints
Date: Fri,  3 Jun 2016 18:58:13 -0400
Message-ID: <1464994695-25178-2-git-send-email-dan.streetman@canonical.com>
References: <1464994695-25178-1-git-send-email-dan.streetman@canonical.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:56149 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752435AbcFCXDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 19:03:44 -0400
In-Reply-To: <1464994695-25178-1-git-send-email-dan.streetman@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Wragg <david@weave.works>

Allow the MTU of vxlan devices without an underlying device to be set
to larger values (up to a maximum based on IP packet limits and vxlan
overhead).

Previously, their MTUs could not be set to higher than the
conventional ethernet value of 1500.  This is a very arbitrary value
in the context of vxlan, and prevented vxlan devices from being able
to take advantage of jumbo frames etc.

The default MTU remains 1500, for compatibility.

Signed-off-by: David Wragg <david@weave.works>
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/vxlan.c | 36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3c0df70..9a1a4ec 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2370,29 +2370,43 @@ static void vxlan_set_multicast_list(struct net_device *dev)
 {
 }
 
-static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
+static int __vxlan_change_mtu(struct net_device *dev,
+			      struct net_device *lowerdev,
+			      struct vxlan_rdst *dst, int new_mtu, bool strict)
 {
-	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_rdst *dst = &vxlan->default_dst;
-	struct net_device *lowerdev;
-	int max_mtu;
+	int max_mtu = IP_MAX_MTU;
 
-	lowerdev = __dev_get_by_index(vxlan->net, dst->remote_ifindex);
-	if (lowerdev == NULL)
-		return eth_change_mtu(dev, new_mtu);
+	if (lowerdev)
+		max_mtu = lowerdev->mtu;
 
 	if (dst->remote_ip.sa.sa_family == AF_INET6)
-		max_mtu = lowerdev->mtu - VXLAN6_HEADROOM;
+		max_mtu -= VXLAN6_HEADROOM;
 	else
-		max_mtu = lowerdev->mtu - VXLAN_HEADROOM;
+		max_mtu -= VXLAN_HEADROOM;
 
-	if (new_mtu < 68 || new_mtu > max_mtu)
+	if (new_mtu < 68)
 		return -EINVAL;
 
+	if (new_mtu > max_mtu) {
+		if (strict)
+			return -EINVAL;
+
+		new_mtu = max_mtu;
+	}
+
 	dev->mtu = new_mtu;
 	return 0;
 }
 
+static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_rdst *dst = &vxlan->default_dst;
+	struct net_device *lowerdev = __dev_get_by_index(vxlan->net,
+							 dst->remote_ifindex);
+	return __vxlan_change_mtu(dev, lowerdev, dst, new_mtu, true);
+}
+
 static int egress_ipv4_tun_info(struct net_device *dev, struct sk_buff *skb,
 				struct ip_tunnel_info *info,
 				__be16 sport, __be16 dport)
-- 
2.7.4
