From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next] net: check retval of dev_addr_init()
Date: Sat, 9 May 2009 01:30:17 +0200
Message-ID: <20090508233016.GC4881@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58898 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764413AbZEHXaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 19:30:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missed checking of dev_addr_init return value in alloc_netdev_mq.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

 net/core/dev.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 637ea71..14dd725 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5007,13 +5007,16 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	if (!tx) {
 		printk(KERN_ERR "alloc_netdev: Unable to allocate "
 		       "tx qdiscs.\n");
-		kfree(p);
-		return NULL;
+		goto free_p;
 	}
 
 	dev = (struct net_device *)
 		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
 	dev->padded = (char *)dev - (char *)p;
+
+	if (dev_addr_init(dev))
+		goto free_tx;
+
 	dev_net_set(dev, &init_net);
 
 	dev->_tx = tx;
@@ -5022,13 +5025,19 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 
-	dev_addr_init(dev);
 	netdev_init_queues(dev);
 
 	INIT_LIST_HEAD(&dev->napi_list);
 	setup(dev);
 	strcpy(dev->name, name);
 	return dev;
+
+free_tx:
+	kfree(tx);
+
+free_p:
+	kfree(p);
+	return NULL;
 }
 EXPORT_SYMBOL(alloc_netdev_mq);
 
