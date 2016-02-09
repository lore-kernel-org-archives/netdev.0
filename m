From: David Wragg <david@weave.works>
Subject: [PATCH net v2 1/3] vxlan: Relax the MTU constraints
Date: Tue,  9 Feb 2016 16:47:02 +0000
Message-ID: <1455036424-6403-2-git-send-email-david@weave.works>
References: <1455036424-6403-1-git-send-email-david@weave.works>
Cc: Jesse Gross <jesse@kernel.org>, David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	David Wragg <david@weave.works>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38306 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755812AbcBIQrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 11:47:10 -0500
Received: by mail-wm0-f53.google.com with SMTP id p63so31228251wmp.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 08:47:09 -0800 (PST)
In-Reply-To: <1455036424-6403-1-git-send-email-david@weave.works>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 drivers/net/vxlan.c | 36 +++++++++++++++++++++++++-----------
 1 file changed, 25 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6543918..e992c6a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2367,29 +2367,43 @@ static void vxlan_set_multicast_list(struct net_device *dev)
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
2.5.0
