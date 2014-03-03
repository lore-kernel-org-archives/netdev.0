From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net] macvlan: Add support for 'always_on' offload features
Date: Mon,  3 Mar 2014 15:33:53 -0500
Message-ID: <1393878833-17667-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6841 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754848AbaCCUeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2014 15:34:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macvlan currently inherits all of its features from the lower
device.  When lower device disables offload support, this causes
macvlan to disable offload support as well.  This causes
performance regression when using macvlan/macvtap in bridge
mode.

It can be easily demonstrated by creating 2 namespaces using
macvlan in bridge mode and running netperf between them:

MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    20.00    1204.61

To restore the performance, we add software offload features
to the list of "always_on" features for macvlan.  This way
when a namespace or a guest using macvtap initially sends a
packet, this packet will not be segmented at macvlan level.
It will only be segmented when macvlan sends the packet
to the lower device.

MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.1 () port 0 AF_INET
Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    20.00    5507.35

Fixes: 6acf54f1cf0a6747bac9fea26f34cfc5a9029523 (macvtap: Add support of packet capture on macvtap device.)
Fixes: 797f87f83b60685ff8a13fa0572d2f10393c50d3 (macvlan: fix netdev feature propagation from lower device)
CC: Florian Westphal <fw@strlen.de>
CC: Christian Borntraeger <borntraeger@de.ibm.com>
CC: Jason Wang <jasowang@redhat.com>
CC: Michael S. Tsirkin <mst@redhat.com>
Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
v1-v2: Fixed dumb spelling error introduced while moving patches around.

 drivers/net/macvlan.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index a5d2189..2625d2a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -506,6 +506,9 @@ static int macvlan_change_mtu(struct net_device *dev, int new_mtu)
 static struct lock_class_key macvlan_netdev_xmit_lock_key;
 static struct lock_class_key macvlan_netdev_addr_lock_key;
 
+#define ALWAYS_ON_FEATURES \
+	(NETIF_F_SG | NETIF_F_GEN_CSUM | NETIF_F_GSO_SOFTWARE | NETIF_F_LLTX)
+
 #define MACVLAN_FEATURES \
 	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
@@ -539,7 +542,7 @@ static int macvlan_init(struct net_device *dev)
 	dev->state		= (dev->state & ~MACVLAN_STATE_MASK) |
 				  (lowerdev->state & MACVLAN_STATE_MASK);
 	dev->features 		= lowerdev->features & MACVLAN_FEATURES;
-	dev->features		|= NETIF_F_LLTX;
+	dev->features		|= ALWAYS_ON_FEATURES;
 	dev->gso_max_size	= lowerdev->gso_max_size;
 	dev->iflink		= lowerdev->ifindex;
 	dev->hard_header_len	= lowerdev->hard_header_len;
@@ -699,7 +702,7 @@ static netdev_features_t macvlan_fix_features(struct net_device *dev,
 	features = netdev_increment_features(vlan->lowerdev->features,
 					     features,
 					     mask);
-	features |= NETIF_F_LLTX;
+	features |= ALWAYS_ON_FEATURES;
 
 	return features;
 }
-- 
1.8.5.3
