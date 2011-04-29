From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH 2/2 net-next] net: drivers: set TSO/UFO offload option explicitly
Date: Fri, 29 Apr 2011 13:34:45 +0800
Message-ID: <4DBA4DF5.5020101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, rusty@rustcorp.com.au,
	mst@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
	mirq-linux@rere.qmqm.pl, mirqus@gmai
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57587 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751524Ab1D2Fiq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Apr 2011 01:38:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device drivers should not use NETIF_F_ALL_TSO mask to set hw_features(or features),
but have to explicitly set offload option. Because, This would make drivers automatically
clain to support any new TSO feature an the moment of NETIF_F_ALL_TSO is expanded.

Some code style tuning. Just compile test. 

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 drivers/net/loopback.c   |   18 ++++++++----------
 drivers/net/virtio_net.c |    9 ++++++---
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index d70fb76..bfb6a4a 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -152,6 +152,9 @@ static const struct net_device_ops loopback_ops = {
 	.ndo_get_stats64 = loopback_get_stats64,
 };
 
+#define LOOPBACK_USER_FEATURES (NETIF_F_TSO | NETIF_F_TSO_ECN | \
+				NETIF_F_TSO6 | NETIF_F_UFO)
+
 /*
  * The loopback device is special. There is only one instance
  * per network namespace.
@@ -165,16 +168,11 @@ static void loopback_setup(struct net_device *dev)
 	dev->type		= ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		= IFF_LOOPBACK;
 	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
-	dev->hw_features	= NETIF_F_ALL_TSO | NETIF_F_UFO;
-	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
-		| NETIF_F_ALL_TSO
-		| NETIF_F_UFO
-		| NETIF_F_NO_CSUM
-		| NETIF_F_RXCSUM
-		| NETIF_F_HIGHDMA
-		| NETIF_F_LLTX
-		| NETIF_F_NETNS_LOCAL
-		| NETIF_F_VLAN_CHALLENGED;
+	dev->hw_features	= LOOPBACK_USER_FEATURES;
+	dev->features		= NETIF_F_SG | NETIF_F_FRAGLIST
+		| LOOPBACK_USER_FEATURES | NETIF_F_NO_CSUM | NETIF_F_RXCSUM
+		| NETIF_F_HIGHDMA | NETIF_F_LLTX
+		| NETIF_F_NETNS_LOCAL | NETIF_F_VLAN_CHALLENGED;
 	dev->ethtool_ops	= &loopback_ethtool_ops;
 	dev->header_ops		= &eth_header_ops;
 	dev->netdev_ops		= &loopback_ops;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 0cb0b06..addde86 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -875,6 +875,9 @@ static void virtnet_config_changed(struct virtio_device *vdev)
 	virtnet_update_status(vi);
 }
 
+#define VIRTNET_USER_FEATURES (NETIF_F_TSO | NETIF_F_TSO_ECN | \
+			       NETIF_F_TSO6 | NETIF_F_UFO)
+
 static int virtnet_probe(struct virtio_device *vdev)
 {
 	int err;
@@ -904,8 +907,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
 
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_GSO)) {
-			dev->hw_features |= NETIF_F_TSO | NETIF_F_UFO
-				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
+			dev->hw_features |= VIRTNET_USER_FEATURES;
 		}
 		/* Individual feature bits: what can host handle? */
 		if (virtio_has_feature(vdev, VIRTIO_NET_F_HOST_TSO4))
@@ -918,7 +920,8 @@ static int virtnet_probe(struct virtio_device *vdev)
 			dev->hw_features |= NETIF_F_UFO;
 
 		if (gso)
-			dev->features |= dev->hw_features & (NETIF_F_ALL_TSO|NETIF_F_UFO);
+			dev->features |= dev->hw_features &
+					 VIRTNET_USER_FEATURES;
 		/* (!csum && gso) case will be fixed by register_netdev() */
 	}
 
-- 
1.7.3.1
