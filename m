From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netfront: set real_num_tx_queues to zreo
 avoid to trigger BUG_ON
Date: Mon, 22 Feb 2016 14:10:02 +0000
Message-ID: <56CB16BA.3020102@citrix.com>
References: <1455931646-5672-1-git-send-email-arei.gonglei@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <peter.huangpeng@huawei.com>,
	"David S . Miller" <davem@davemloft.net>
To: Gonglei <arei.gonglei@huawei.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455931646-5672-1-git-send-email-arei.gonglei@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/02/16 01:27, Gonglei wrote:
> It's possible for a race condition to exist between xennet_open() and
> talk_to_netback(). After invoking netfront_probe() then other
> threads or processes invoke xennet_open (such as NetworkManager)
> immediately may trigger BUG_ON(). Besides, we also should reset
> real_num_tx_queues in xennet_destroy_queues().

I think you want something like the following.  We serialize the backend
changing and the netdev open with the device mutex.

(I've not even tried to compile this so it might not even build.)

David

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d6abf19..7e2791a 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -340,22 +340,28 @@ static int xennet_open(struct net_device *dev)
 	unsigned int i = 0;
 	struct netfront_queue *queue = NULL;

+	device_lock(&np->xbdev->dev);
+
+	if (!netif_carrier_ok(dev))
+		goto unlock;
+
 	for (i = 0; i < num_queues; ++i) {
 		queue = &np->queues[i];
 		napi_enable(&queue->napi);

 		spin_lock_bh(&queue->rx_lock);
-		if (netif_carrier_ok(dev)) {
-			xennet_alloc_rx_buffers(queue);
-			queue->rx.sring->rsp_event = queue->rx.rsp_cons + 1;
-			if (RING_HAS_UNCONSUMED_RESPONSES(&queue->rx))
-				napi_schedule(&queue->napi);
-		}
+		xennet_alloc_rx_buffers(queue);
+		queue->rx.sring->rsp_event = queue->rx.rsp_cons + 1;
+		if (RING_HAS_UNCONSUMED_RESPONSES(&queue->rx))
+			napi_schedule(&queue->napi);
 		spin_unlock_bh(&queue->rx_lock);
 	}

 	netif_tx_start_all_queues(dev);

+  unlock:
+	device_unlock(&np->xbdev->dev);
+
 	return 0;
 }

@@ -1983,8 +1989,8 @@ static int xennet_connect(struct net_device *dev)
 	num_queues = dev->real_num_tx_queues;

 	rtnl_lock();
+
 	netdev_update_features(dev);
-	rtnl_unlock();

 	/*
 	 * All public and private state should now be sane.  Get
@@ -1992,7 +1998,6 @@ static int xennet_connect(struct net_device *dev)
 	 * domain a kick because we've probably just requeued some
 	 * packets.
 	 */
-	netif_carrier_on(np->netdev);
 	for (j = 0; j < num_queues; ++j) {
 		queue = &np->queues[j];

@@ -2006,9 +2011,17 @@ static int xennet_connect(struct net_device *dev)

 		spin_lock_bh(&queue->rx_lock);
 		xennet_alloc_rx_buffers(queue);
+		if (netif_running(dev)) {
+			if (RING_HAS_UNCONSUMED_RESPONSES(&queue->rx))
+				napi_schedule(&queue->napi);
+		}
 		spin_unlock_bh(&queue->rx_lock);
 	}

+	netif_carrier_on(np->netdev);
+
+	rtnl_unlock();
+
 	return 0;
 }

diff --git a/drivers/xen/xenbus/xenbus_probe.c
b/drivers/xen/xenbus/xenbus_probe.c
index 33a31cf..57cd20d 100644
--- a/drivers/xen/xenbus/xenbus_probe.c
+++ b/drivers/xen/xenbus/xenbus_probe.c
@@ -204,8 +204,11 @@ void xenbus_otherend_changed(struct xenbus_watch
*watch,
 		return;
 	}

-	if (drv->otherend_changed)
+	if (drv->otherend_changed) {
+		device_lock(&dev->dev);
 		drv->otherend_changed(dev, state);
+		device_unlock(&dev->dev);
+	}
 }
 EXPORT_SYMBOL_GPL(xenbus_otherend_changed);
