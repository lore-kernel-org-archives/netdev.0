From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] rps: make distributing packets fairly among all the online
 CPUs default
Date: Tue, 23 Mar 2010 14:24:34 +0800
Message-ID: <4BA85EA2.1090304@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, xiaosuo <xiaosuo@gmail.com>,
	netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:45078 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330Ab0CWGYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 02:24:49 -0400
Received: by gwaa18 with SMTP id a18so1355735gwa.19
        for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 23:24:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

make distributing packets fairly among all the online CPUs default.

Make distributing packets fairly among all the online CPUs default, then
users don't need any explicit configuration to get the benefit of RPS.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
net/core/dev.c | 34 ++++++++++++++++++++++++++++++++--
1 file changed, 32 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c0e2608..a4246f1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5234,6 +5234,24 @@ void netif_stacked_transfer_operstate(const struct net_device *rootdev,
 }
 EXPORT_SYMBOL(netif_stacked_transfer_operstate);
 
+static struct rps_map* alloc_rps_map(void)
+{
+	struct rps_map *map;
+	int i, cpu;
+
+	map = kzalloc(max_t(unsigned,
+			    RPS_MAP_SIZE(cpumask_weight(cpu_online_mask)),
+			    L1_CACHE_BYTES), GFP_KERNEL);
+	if (map == NULL)
+		return NULL;
+	i = 0;
+	for_each_online_cpu(cpu)
+		map->cpus[i++] = cpu;
+	map->len = i;
+
+	return map;
+}
+
 /**
  *	register_netdevice	- register a network device
  *	@dev: device to register
@@ -5282,7 +5300,13 @@ int register_netdevice(struct net_device *dev)
 			ret = -ENOMEM;
 			goto out;
 		}
-
+		dev->_rx->rps_map = alloc_rps_map();
+		if (dev->_rx->rps_map == NULL) {
+			kfree(dev->_rx);
+			dev->_rx = NULL;
+			ret = -ENOMEM;
+			goto out;
+		}
 		dev->_rx->first = dev->_rx;
 		atomic_set(&dev->_rx->count, 1);
 		dev->num_rx_queues = 1;
@@ -5688,8 +5712,12 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	 * Set a pointer to first element in the array which holds the
 	 * reference count.
 	 */
-	for (i = 0; i < queue_count; i++)
+	for (i = 0; i < queue_count; i++) {
 		rx[i].first = rx;
+		rx[i].rps_map = alloc_rps_map();
+		if (rx[i].rps_map == NULL)
+			goto free_rx;
+	}
 
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
@@ -5723,6 +5751,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	return dev;
 
 free_rx:
+	for (i = 0; i < queue_count; i++)
+		kfree(rx[i].rps_map);
 	kfree(rx);
 free_tx:
 	kfree(tx);


