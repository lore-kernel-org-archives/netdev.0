From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next rfc 1/3] net: avoid high order memory allocation for
 queues by using flex array
Date: Wed, 19 Jun 2013 08:58:31 -0700
Message-ID: <1371657511.3252.324.camel@edumazet-glaptop>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
	 <1371620452-49349-2-git-send-email-jasowang@redhat.com>
	 <1371623518.3252.267.camel@edumazet-glaptop>
	 <20130619091132.GA2816@redhat.com>
	 <1371635763.3252.289.camel@edumazet-glaptop>
	 <20130619154059.GA13735@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, davem@davemloft.net,
	edumazet@google.com, hkchu@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130619154059.GA13735@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-06-19 at 18:40 +0300, Michael S. Tsirkin wrote:

> That's a good trick too - vmalloc memory is a bit slower
> on x86 since it's not using a huge page, but that's only
> when we have lots of CPUs/queues...
> 
> Short term - how about switching to vmalloc if > 32 queues?

You do not have to switch "if > 32 queues"

diff --git a/net/core/dev.c b/net/core/dev.c
index fa007db..473cc9e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -130,6 +130,7 @@
 #include <linux/cpu_rmap.h>
 #include <linux/static_key.h>
 #include <linux/hashtable.h>
+#include <linux/vmalloc.h>
 
 #include "net-sysfs.h"
 
@@ -5253,6 +5254,14 @@ static void netdev_init_one_queue(struct net_device *dev,
 #endif
 }
 
+static void netif_free_tx_queues(struct net_device *dev)
+{
+	if (is_vmalloc_addr(dev->_tx))
+		vfree(dev->_tx);
+	else
+		kfree(dev->_tx);
+}
+
 static int netif_alloc_netdev_queues(struct net_device *dev)
 {
 	unsigned int count = dev->num_tx_queues;
@@ -5261,9 +5270,11 @@ static int netif_alloc_netdev_queues(struct net_device *dev)
 	BUG_ON(count < 1);
 
 	tx = kcalloc(count, sizeof(struct netdev_queue), GFP_KERNEL);
-	if (!tx)
-		return -ENOMEM;
-
+	if (!tx) {
+		tx = vzalloc(count * sizeof(struct netdev_queue));
+		if (!tx)
+			return -ENOMEM;
+	}
 	dev->_tx = tx;
 
 	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
@@ -5811,7 +5822,7 @@ free_all:
 
 free_pcpu:
 	free_percpu(dev->pcpu_refcnt);
-	kfree(dev->_tx);
+	netif_free_tx_queues(dev);
 #ifdef CONFIG_RPS
 	kfree(dev->_rx);
 #endif
@@ -5836,7 +5847,7 @@ void free_netdev(struct net_device *dev)
 
 	release_net(dev_net(dev));
 
-	kfree(dev->_tx);
+	netif_free_tx_queues(dev);
 #ifdef CONFIG_RPS
 	kfree(dev->_rx);
 #endif
