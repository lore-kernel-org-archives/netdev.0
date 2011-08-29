From: Joe Perches <joe@perches.com>
Subject: [PATCH 24/24] net: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:43 -0700
Message-ID: <a8245be589796a675c1ac70ee7bc5e3fffa20f24.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59697 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755241Ab1H2VWc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 17:22:32 -0400
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/dev.c    |   25 +++++++------------------
 net/core/flow.c   |    4 +---
 net/core/pktgen.c |    5 +----
 net/socket.c      |    5 +----
 4 files changed, 10 insertions(+), 29 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b2e262e..67018d8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5424,10 +5424,9 @@ static int netif_alloc_rx_queues(struct net_device *dev)
 	BUG_ON(count < 1);
 
 	rx = kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
-	if (!rx) {
-		pr_err("netdev: Unable to allocate %u rx queues.\n", count);
+	if (!rx)
 		return -ENOMEM;
-	}
+
 	dev->_rx = rx;
 
 	for (i = 0; i < count; i++)
@@ -5455,11 +5454,9 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	BUG_ON(count < 1);
 
 	tx = kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
-	if (!tx) {
-		pr_err("netdev: Unable to allocate %u tx queues.\n",
-		       count);
+	if (!tx)
 		return -ENOMEM;
-	}
+
 	dev->_tx = tx;
 
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
@@ -5878,18 +5875,12 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
-	if (txqs < 1) {
-		pr_err("alloc_netdev: Unable to allocate device "
-		       "with zero queues.\n");
+	if (txqs < 1)
 		return NULL;
-	}
 
 #ifdef CONFIG_RPS
-	if (rxqs < 1) {
-		pr_err("alloc_netdev: Unable to allocate device "
-		       "with zero RX queues.\n");
+	if (rxqs < 1)
 		return NULL;
-	}
 #endif
 
 	alloc_size = sizeof(struct net_device);
@@ -5902,10 +5893,8 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	alloc_size += NETDEV_ALIGN - 1;
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
-	if (!p) {
-		printk(KERN_ERR "alloc_netdev: Unable to allocate device.\n");
+	if (!p)
 		return NULL;
-	}
 
 	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
diff --git a/net/core/flow.c b/net/core/flow.c
index bf32c33..7e33612 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -359,10 +359,8 @@ static int __cpuinit flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
 
 	if (!fcp->hash_table) {
 		fcp->hash_table = kzalloc_node(sz, GFP_KERNEL, cpu_to_node(cpu));
-		if (!fcp->hash_table) {
-			pr_err("NET: failed to allocate flow cache sz %zu\n", sz);
+		if (!fcp->hash_table)
 			return -ENOMEM;
-		}
 		fcp->hash_rnd_recalc = 1;
 		fcp->hash_count = 0;
 		tasklet_init(&fcp->flush_tasklet, flow_cache_flush_tasklet, 0);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 796044a..3769f16 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3323,7 +3323,6 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 		pkt_dev->skb = fill_packet(odev, pkt_dev);
 		if (pkt_dev->skb == NULL) {
-			pr_err("ERROR: couldn't allocate skb in fill_packet\n");
 			schedule();
 			pkt_dev->clone_count--;	/* back out increment, OOM */
 			return;
@@ -3610,10 +3609,8 @@ static int __init pktgen_create_thread(int cpu)
 
 	t = kzalloc_node(sizeof(struct pktgen_thread), GFP_KERNEL,
 			 cpu_to_node(cpu));
-	if (!t) {
-		pr_err("ERROR: out of memory, can't create new thread\n");
+	if (!t)
 		return -ENOMEM;
-	}
 
 	spin_lock_init(&t->if_lock);
 	t->cpu = cpu;
diff --git a/net/socket.c b/net/socket.c
index 2517e11..51fa300 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1213,12 +1213,9 @@ int __sock_create(struct net *net, int family, int type, int protocol,
 	 *	default.
 	 */
 	sock = sock_alloc();
-	if (!sock) {
-		if (net_ratelimit())
-			printk(KERN_WARNING "socket: no more sockets\n");
+	if (!sock)
 		return -ENFILE;	/* Not exactly a match, but its the
 				   closest posix thing */
-	}
 
 	sock->type = type;
 
-- 
1.7.6.405.gc1be0
