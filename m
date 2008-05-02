From: akpm@linux-foundation.org
Subject: [patch 1/2] net: remove NR_CPUS arrays in net/core/dev.c
Date: Fri, 02 May 2008 13:39:26 -0700
Message-ID: <200805022039.m42KdQA3013598@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, travis@sgi.com,
	jmorris@namei.org, kaber@trash.net, kuznet@ms2.inr.ac.ru
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48634 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S936564AbYEBUks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 16:40:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Travis <travis@sgi.com>

Remove the fixed size channels[NR_CPUS] array in net/core/dev.c and
dynamically allocate array based on nr_cpu_ids.

Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Mike Travis <travis@sgi.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/core/dev.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff -puN net/core/dev.c~net-remove-nr_cpus-arrays-in-net-core-devc-v2 net/core/dev.c
--- a/net/core/dev.c~net-remove-nr_cpus-arrays-in-net-core-devc-v2
+++ a/net/core/dev.c
@@ -162,7 +162,7 @@ struct net_dma {
 	struct dma_client client;
 	spinlock_t lock;
 	cpumask_t channel_mask;
-	struct dma_chan *channels[NR_CPUS];
+	struct dma_chan **channels;
 };
 
 static enum dma_state_client
@@ -2444,7 +2444,7 @@ static struct netif_rx_stats *softnet_ge
 {
 	struct netif_rx_stats *rc = NULL;
 
-	while (*pos < NR_CPUS)
+	while (*pos < nr_cpu_ids)
 		if (cpu_online(*pos)) {
 			rc = &per_cpu(netdev_rx_stat, *pos);
 			break;
@@ -4324,7 +4324,7 @@ netdev_dma_event(struct dma_client *clie
 	spin_lock(&net_dma->lock);
 	switch (state) {
 	case DMA_RESOURCE_AVAILABLE:
-		for (i = 0; i < NR_CPUS; i++)
+		for (i = 0; i < nr_cpu_ids; i++)
 			if (net_dma->channels[i] == chan) {
 				found = 1;
 				break;
@@ -4339,7 +4339,7 @@ netdev_dma_event(struct dma_client *clie
 		}
 		break;
 	case DMA_RESOURCE_REMOVED:
-		for (i = 0; i < NR_CPUS; i++)
+		for (i = 0; i < nr_cpu_ids; i++)
 			if (net_dma->channels[i] == chan) {
 				found = 1;
 				pos = i;
@@ -4366,6 +4366,13 @@ netdev_dma_event(struct dma_client *clie
  */
 static int __init netdev_dma_register(void)
 {
+	net_dma.channels = kzalloc(nr_cpu_ids * sizeof(struct net_dma),
+								GFP_KERNEL);
+	if (unlikely(!net_dma.channels)) {
+		printk(KERN_NOTICE
+				"netdev_dma: no memory for net_dma.channels\n");
+		return -ENOMEM;
+	}
 	spin_lock_init(&net_dma.lock);
 	dma_cap_set(DMA_MEMCPY, net_dma.client.cap_mask);
 	dma_async_client_register(&net_dma.client);
_
