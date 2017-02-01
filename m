From: Ross Lagerwall <ross.lagerwall@citrix.com>
Subject: [PATCH] xen-netfront: Improve error handling during initialization
Date: Wed, 1 Feb 2017 15:50:22 +0000
Message-ID: <1485964222-1501-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        Juergen Gross <jgross@suse.com>,
        <linux-kernel@vger.kernel.org>, <wei.liu2@citrix.com>,
        Ross Lagerwall <ross.lagerwall@citrix.com>
To: <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Improve error handling during initialization. This fixes a crash when
running out of grant refs when creating many queues across many netdevs.

* Delay timer creation so that if initializing a queue fails, the timer
has not been setup yet.
* If creating queues fails (i.e. there are no grant refs available),
call xenbus_dev_fatal() to ensure that the xenbus device is set to the
closed state.
* If no queues are created, don't call xennet_disconnect_backend as
netdev->real_num_tx_queues will not have been set correctly.
* If setup_netfront() fails, ensure that all the queues created are
cleaned up, not just those that have been set up.
* If any queues were set up and an error occurs, call
xennet_destroy_queues() to stop the timer and clean up the napi context.
* If any fatal error occurs, unregister and destroy the netdev to avoid
leaving around a half setup network device.

Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
---
 drivers/net/xen-netfront.c | 39 ++++++++++++++++++---------------------
 1 file changed, 18 insertions(+), 21 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 8315fe7..8ca85af 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1596,9 +1596,6 @@ static int xennet_init_queue(struct netfront_queue *queue)
 	spin_lock_init(&queue->tx_lock);
 	spin_lock_init(&queue->rx_lock);
 
-	setup_timer(&queue->rx_refill_timer, rx_refill_timeout,
-		    (unsigned long)queue);
-
 	snprintf(queue->name, sizeof(queue->name), "%s-q%u",
 		 queue->info->netdev->name, queue->id);
 
@@ -1632,6 +1629,9 @@ static int xennet_init_queue(struct netfront_queue *queue)
 		goto exit_free_tx;
 	}
 
+	setup_timer(&queue->rx_refill_timer, rx_refill_timeout,
+		    (unsigned long)queue);
+
 	return 0;
 
  exit_free_tx:
@@ -1822,27 +1822,23 @@ static int talk_to_netback(struct xenbus_device *dev,
 		xennet_destroy_queues(info);
 
 	err = xennet_create_queues(info, &num_queues);
-	if (err < 0)
-		goto destroy_ring;
+	if (err < 0) {
+		xenbus_dev_fatal(dev, err, "creating queues");
+		if (num_queues > 0) {
+			goto destroy_ring;
+		} else {
+			kfree(info->queues);
+			info->queues = NULL;
+			goto out;
+		}
+	}
 
 	/* Create shared ring, alloc event channel -- for each queue */
 	for (i = 0; i < num_queues; ++i) {
 		queue = &info->queues[i];
 		err = setup_netfront(dev, queue, feature_split_evtchn);
-		if (err) {
-			/* setup_netfront() will tidy up the current
-			 * queue on error, but we need to clean up
-			 * those already allocated.
-			 */
-			if (i > 0) {
-				rtnl_lock();
-				netif_set_real_num_tx_queues(info->netdev, i);
-				rtnl_unlock();
-				goto destroy_ring;
-			} else {
-				goto out;
-			}
-		}
+		if (err)
+			goto destroy_ring;
 	}
 
 again:
@@ -1932,9 +1928,10 @@ static int talk_to_netback(struct xenbus_device *dev,
 	xenbus_transaction_end(xbt, 1);
  destroy_ring:
 	xennet_disconnect_backend(info);
-	kfree(info->queues);
-	info->queues = NULL;
+	xennet_destroy_queues(info);
  out:
+	unregister_netdev(info->netdev);
+	xennet_free_netdev(info->netdev);
 	return err;
 }
 
-- 
2.7.4
