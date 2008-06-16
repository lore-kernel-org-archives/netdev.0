From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 3/3] netdevice: order of synchronization of IFF_PROMISC and
 IFF_ALLMULTI
Date: Mon, 16 Jun 2008 17:17:14 +0800
Message-ID: <48562F9A.5030509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50655 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756704AbYFPJU4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:20:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IFF_PROMISC should be set before IFF_ALLMULTI.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/8021q/vlan_dev.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5d055c2..14742e3 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -547,10 +547,14 @@ static int vlan_dev_open(struct net_device *dev)
 	}
 	memcpy(vlan->real_dev_addr, real_dev->dev_addr, ETH_ALEN);
 
-	if (dev->flags & IFF_ALLMULTI)
-		dev_set_allmulti(real_dev, 1);
+	/* NOTE: order of synchronization of IFF_PROMISC and IFF_ALLMULTI
+	   is important. Some (broken) drivers set IFF_PROMISC, when
+	   IFF_ALLMULTI is requested not asking us and not reporting.
+	 */
 	if (dev->flags & IFF_PROMISC)
 		dev_set_promiscuity(real_dev, 1);
+	if (dev->flags & IFF_ALLMULTI)
+		dev_set_allmulti(real_dev, 1);
 
 	return 0;
 }
@@ -561,10 +565,14 @@ static int vlan_dev_stop(struct net_device *dev)
 
 	dev_mc_unsync(real_dev, dev);
 	dev_unicast_unsync(real_dev, dev);
-	if (dev->flags & IFF_ALLMULTI)
-		dev_set_allmulti(real_dev, -1);
+	/* NOTE: order of synchronization of IFF_PROMISC and IFF_ALLMULTI
+	   is important. Some (broken) drivers set IFF_PROMISC, when
+	   IFF_ALLMULTI is requested not asking us and not reporting.
+	 */
 	if (dev->flags & IFF_PROMISC)
 		dev_set_promiscuity(real_dev, -1);
+	if (dev->flags & IFF_ALLMULTI)
+		dev_set_allmulti(real_dev, -1);
 
 	if (compare_ether_addr(dev->dev_addr, real_dev->dev_addr))
 		dev_unicast_delete(real_dev, dev->dev_addr, dev->addr_len);
@@ -626,10 +634,15 @@ static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 {
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 
+	/* NOTE: order of synchronization of IFF_PROMISC and IFF_ALLMULTI
+	   is important. Some (broken) drivers set IFF_PROMISC, when
+	   IFF_ALLMULTI is requested not asking us and not reporting.
+	 */
+	if (change & IFF_PROMISC)
+		dev_set_promiscuity(real_dev,
+				      dev->flags & IFF_PROMISC ? 1 : -1);
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(real_dev, dev->flags & IFF_ALLMULTI ? 1 : -1);
-	if (change & IFF_PROMISC)
-		dev_set_promiscuity(real_dev, dev->flags & IFF_PROMISC ? 1 : -1);
 }
 
 static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
-- 
1.5.3.4


