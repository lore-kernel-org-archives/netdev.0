From: Pankaj Gupta <pagupta@redhat.com>
Subject: [PATCH v5 net-next 1/2] net: allow large number of rx queues
Date: Mon, 12 Jan 2015 11:41:28 +0530
Message-ID: <1421043089-30103-2-git-send-email-pagupta@redhat.com>
References: <1421043089-30103-1-git-send-email-pagupta@redhat.com>
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com, wuzhy@linux.vnet.ibm.com,
	xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei.shtylyov@cogentembedded.com,
	Pankaj Gupta <pagupta@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421043089-30103-1-git-send-email-pagupta@redhat.com>
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
 net/core/dev.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1ab168e..954591a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6145,13 +6145,16 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 {
 	unsigned int i, count = dev->num_rx_queues;
 	struct netdev_rx_queue *rx;
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
@@ -6781,7 +6784,7 @@ void free_netdev(struct net_device *dev)
 
 	netif_free_tx_queues(dev);
 #ifdef CONFIG_SYSFS
-	kfree(dev->_rx);
+	kvfree(dev->_rx);
 #endif
 
 	kfree(rcu_dereference_protected(dev->ingress_queue, 1));
-- 
1.8.3.1
