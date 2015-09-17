From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 1/5] vxlan: set needed headroom correctly
Date: Thu, 17 Sep 2015 16:11:10 +0200
Message-ID: <179da48667c8c9e5dbe24672311f84e30e0571b1.1442498316.git.jbenc@redhat.com>
References: <cover.1442498316.git.jbenc@redhat.com>
Cc: Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354AbbIQOLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2015 10:11:24 -0400
In-Reply-To: <cover.1442498316.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan_setup is called when allocating the net_device, i.e. way before
vxlan_newlink (or vxlan_dev_configure) is called. This means
vxlan->default_dst is actually unset in vxlan_setup and the condition that
sets needed_headroom always takes the else branch.

Set the needed_headrom at the point when we have the information about
the address family available.

Fixes: e4c7ed415387c ("vxlan: add ipv6 support")
Fixes: 2853af6a2ea1a ("vxlan: use dev->needed_headroom instead of dev->hard_header_len")
CC: Cong Wang <cwang@twopensource.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index cf8b7f0473b3..6ebe562af04e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2392,10 +2392,6 @@ static void vxlan_setup(struct net_device *dev)
 
 	eth_hw_addr_random(dev);
 	ether_setup(dev);
-	if (vxlan->default_dst.remote_ip.sa.sa_family == AF_INET6)
-		dev->needed_headroom = ETH_HLEN + VXLAN6_HEADROOM;
-	else
-		dev->needed_headroom = ETH_HLEN + VXLAN_HEADROOM;
 
 	dev->netdev_ops = &vxlan_netdev_ops;
 	dev->destructor = free_netdev;
@@ -2670,8 +2666,12 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 
 		dev->needed_headroom = lowerdev->hard_header_len +
 				       (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
-	} else if (use_ipv6)
+	} else if (use_ipv6) {
 		vxlan->flags |= VXLAN_F_IPV6;
+		dev->needed_headroom = ETH_HLEN + VXLAN6_HEADROOM;
+	} else {
+		dev->needed_headroom = ETH_HLEN + VXLAN_HEADROOM;
+	}
 
 	memcpy(&vxlan->cfg, conf, sizeof(*conf));
 	if (!vxlan->cfg.dst_port)
-- 
1.8.3.1
