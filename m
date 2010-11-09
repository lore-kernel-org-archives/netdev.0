From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/2] net: Move TX queue allocation to alloc_netdev_mq
Date: Tue, 9 Nov 2010 12:47:30 -0800 (PST)
Message-ID: <alpine.DEB.1.00.1011091242260.18713@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:38053 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754326Ab0KIUrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 15:47:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TX queues are now allocated in alloc_netdev_mq and freed in
free_netdev.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0dd54a6..8f9c76e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5114,10 +5114,6 @@ int register_netdevice(struct net_device *dev)
 	if (ret)
 		goto out;
 
-	ret = netif_alloc_netdev_queues(dev);
-	if (ret)
-		goto out;
-
 	netdev_init_queues(dev);
 
 	/* Init, if this function is available */
@@ -5577,6 +5573,8 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev->num_tx_queues = queue_count;
 	dev->real_num_tx_queues = queue_count;
+	if (netif_alloc_netdev_queues(dev))
+		goto free_pcpu;
 
 #ifdef CONFIG_RPS
 	dev->num_rx_queues = queue_count;
@@ -5597,6 +5595,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 free_pcpu:
 	free_percpu(dev->pcpu_refcnt);
+	kfree(dev->_tx);
 free_p:
 	kfree(p);
 	return NULL;
-- 
1.7.3.1

