From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] macvtap/macvlan: use IFF_NO_QUEUE
Date: Mon, 24 Aug 2015 16:33:12 +0800
Message-ID: <1440405192-25926-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	Patrick McHardy <kaber@trash.net>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475AbbHXIdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2015 04:33:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For macvlan, switch to use IFF_NO_QUEUE instead of tx_queue_len = 0.

For macvtap, after commit 6acf54f1cf0a6747bac9fea26f34cfc5a9029523
("macvtap: Add support of packet capture on macvtap
device."). Multiqueue macvtap suffers from single qdisc lock
contention. This is because macvtap claims a non zero tx_queue_len and
it reuses this value as it socket receive queue size.Thanks to
IFF_NO_QUEUE, we can remove the lock contention without breaking
existing socket receive queue length logic.

Cc: Patrick McHardy <kaber@trash.net>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvlan.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 47da435..09d8718 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -1056,7 +1056,7 @@ void macvlan_common_setup(struct net_device *dev)
 
 	dev->priv_flags	       &= ~IFF_TX_SKB_SHARING;
 	netif_keep_dst(dev);
-	dev->priv_flags	       |= IFF_UNICAST_FLT;
+	dev->priv_flags	       |= IFF_UNICAST_FLT | IFF_NO_QUEUE;
 	dev->netdev_ops		= &macvlan_netdev_ops;
 	dev->destructor		= free_netdev;
 	dev->header_ops		= &macvlan_hard_header_ops;
@@ -1067,7 +1067,6 @@ EXPORT_SYMBOL_GPL(macvlan_common_setup);
 static void macvlan_setup(struct net_device *dev)
 {
 	macvlan_common_setup(dev);
-	dev->tx_queue_len	= 0;
 }
 
 static int macvlan_port_create(struct net_device *dev)
-- 
2.1.4
