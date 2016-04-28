From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] vxlan: fix initialization with custom link parameters
Date: Thu, 28 Apr 2016 16:36:30 +0200
Message-ID: <7c19200582d6f4272cee914934f428775e405e89.1461854177.git.jbenc@redhat.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46055 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752195AbcD1Ogm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 10:36:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0c867c9bf84c ("vxlan: move Ethernet initialization to a separate
function") changed initialization order and as an unintended result, when the
user specifies additional link parameters (such as IFLA_ADDRESS) while
creating vxlan interface, those are overwritten by vxlan_ether_setup later.

It's necessary to call ether_setup from withing the ->setup callback. That
way, the correct parameters are set by rtnl_create_link later. This is done
also for VXLAN-GPE, as we don't know the interface type yet at that point,
and changed to the correct interface type later.

Fixes: 0c867c9bf84c ("vxlan: move Ethernet initialization to a separate function")
Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 6fb93b57a724..2668e528dee4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2557,6 +2557,9 @@ static void vxlan_setup(struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	unsigned int h;
 
+	eth_hw_addr_random(dev);
+	ether_setup(dev);
+
 	dev->destructor = free_netdev;
 	SET_NETDEV_DEVTYPE(dev, &vxlan_type);
 
@@ -2592,8 +2595,6 @@ static void vxlan_setup(struct net_device *dev)
 
 static void vxlan_ether_setup(struct net_device *dev)
 {
-	eth_hw_addr_random(dev);
-	ether_setup(dev);
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 	dev->netdev_ops = &vxlan_netdev_ether_ops;
@@ -2601,11 +2602,10 @@ static void vxlan_ether_setup(struct net_device *dev)
 
 static void vxlan_raw_setup(struct net_device *dev)
 {
+	dev->header_ops = NULL;
 	dev->type = ARPHRD_NONE;
 	dev->hard_header_len = 0;
 	dev->addr_len = 0;
-	dev->mtu = ETH_DATA_LEN;
-	dev->tx_queue_len = 1000;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
 	dev->netdev_ops = &vxlan_netdev_raw_ops;
 }
-- 
1.8.3.1
