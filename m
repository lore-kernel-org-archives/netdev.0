From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC 1/4] net: allow large number of rx queues
Date: Mon, 18 Aug 2014 19:07:17 +0530
Message-ID: <1408369040-1216-2-git-send-email-pagupta@redhat.com>
References: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com, wuzhy@linux.vnet.ibm.com,
	xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, Pankaj Gupta <pagupta@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netif_alloc_rx_queues() uses kcalloc() to allocate memory
for "struct netdev_queue *_rx" array.
If we are doing large rx queue allocation kcalloc() might
fail, so this patch does a fallback to vzalloc().
Similar implementation is done for tx queue allocation in
netif_alloc_netdev_queues().

We avoid failure of high order memory allocation
with the help of vzalloc(), this allows us to do large
rx and tx queue allocation which in turn helps us to
increase the number of queues in tun.

As vmalloc() adds overhead on a critical network path,
__GFP_REPEAT flag is used with kzalloc() to do this fallback
only when really needed.

Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
Reviewed-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: David Gibson <dgibson@redhat.com>
---
 net/core/dev.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1c15b18..a455a02 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5942,17 +5942,24 @@ void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 EXPORT_SYMBOL(netif_stacked_transfer_operstate);
 
 #ifdef CONFIG_SYSFS
+static void netif_free_rx_queues(struct net_device *dev)
+{
+	kvfree(dev->_rx);
+}
+
 static int netif_alloc_rx_queues(struct net_device *dev)
 {
 	unsigned int i, count = dev->num_rx_queues;
 	struct netdev_rx_queue *rx;
-
+	size_t sz = count * sizeof(*rx);
 	BUG_ON(count < 1);
 
-	rx = kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
-	if (!rx)
-		return -ENOMEM;
-
+	rx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	if (!rx) {
+		rx = vzalloc(sz);
+		if (!rx)
+			return -ENOMEM;
+	}
 	dev->_rx = rx;
 
 	for (i = 0; i < count; i++)
@@ -6581,9 +6588,8 @@ void free_netdev(struct net_device *dev)
 
 	netif_free_tx_queues(dev);
 #ifdef CONFIG_SYSFS
-	kfree(dev->_rx);
+	netif_free_rx_queues(dev);
 #endif
-
 	kfree(rcu_dereference_protected(dev->ingress_queue, 1));
 
 	/* Flush device addresses */
-- 
1.8.3.1
