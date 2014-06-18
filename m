From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 2/2] xen-netfront: recreate queues correctly
	when reconnecting
Date: Wed, 18 Jun 2014 10:47:28 +0100
Message-ID: <1403084848-12872-3-git-send-email-david.vrabel@citrix.com>
References: <1403084848-12872-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1403084848-12872-1-git-send-email-david.vrabel@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

When reconnecting to the backend (after a resume/migration, for example),
a different number of queues may be required (since the guest may have
moved to a different host with different capabilities).  During the
reconnection the old queues are torn down and new ones created.

Introduce xennet_create_queues() and xennet_destroy_queues() that fixes
three bugs during the reconnection.

- The old info->queues was leaked.
- The old queue's napi instances were not deleted.
- The new queue's napi instances were left disabled (which meant no
  packets could be received).

The xennet_destroy_queues() calls is deferred until the reconnection
instead of the disconnection (in xennet_disconnect_backend()) because
napi_disable() might sleep.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |  104 ++++++++++++++++++++++++++++++--------------
 1 file changed, 72 insertions(+), 32 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index daaf1e5..2ccb4a0 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1699,8 +1699,6 @@ static int xennet_init_queue(struct netfront_queue *queue)
 		goto exit_free_tx;
 	}
 
-	netif_napi_add(queue->info->netdev, &queue->napi, xennet_poll, 64);
-
 	return 0;
 
  exit_free_tx:
@@ -1791,6 +1789,70 @@ error:
 	return err;
 }
 
+static void xennet_destroy_queues(struct netfront_info *info)
+{
+	unsigned int i;
+
+	rtnl_lock();
+
+	for (i = 0; i < info->netdev->real_num_tx_queues; i++) {
+		struct netfront_queue *queue = &info->queues[i];
+
+		if (netif_running(info->netdev))
+			napi_disable(&queue->napi);
+		netif_napi_del(&queue->napi);
+	}
+
+	rtnl_unlock();
+
+	kfree(info->queues);
+	info->queues = NULL;
+}
+
+static int xennet_create_queues(struct netfront_info *info,
+				unsigned int num_queues)
+{
+	unsigned int i;
+	int ret;
+
+	info->queues = kcalloc(num_queues, sizeof(struct netfront_queue),
+			       GFP_KERNEL);
+	if (!info->queues)
+		return -ENOMEM;
+
+	rtnl_lock();
+
+	for (i = 0; i < num_queues; i++) {
+		struct netfront_queue *queue = &info->queues[i];
+
+		queue->id = i;
+		queue->info = info;
+
+		ret = xennet_init_queue(queue);
+		if (ret < 0) {
+			dev_warn(&info->netdev->dev, "only created %d queues\n",
+				 num_queues);
+			num_queues = i;
+			break;
+		}
+
+		netif_napi_add(queue->info->netdev, &queue->napi,
+			       xennet_poll, 64);
+		if (netif_running(info->netdev))
+			napi_enable(&queue->napi);
+	}
+
+	netif_set_real_num_tx_queues(info->netdev, num_queues);
+
+	rtnl_unlock();
+
+	if (num_queues == 0) {
+		dev_err(&info->netdev->dev, "no queues\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
 /* Common code used when first setting up, and when resuming. */
 static int talk_to_netback(struct xenbus_device *dev,
 			   struct netfront_info *info)
@@ -1827,42 +1889,20 @@ static int talk_to_netback(struct xenbus_device *dev,
 		goto out;
 	}
 
-	/* Allocate array of queues */
-	info->queues = kcalloc(num_queues, sizeof(struct netfront_queue), GFP_KERNEL);
-	if (!info->queues) {
-		err = -ENOMEM;
-		goto out;
-	}
-	rtnl_lock();
-	netif_set_real_num_tx_queues(info->netdev, num_queues);
-	rtnl_unlock();
+	if (info->queues)
+		xennet_destroy_queues(info);
+
+	err = xennet_create_queues(info, num_queues);
+	if (err < 0)
+		goto destroy_ring;
 
 	/* Create shared ring, alloc event channel -- for each queue */
 	for (i = 0; i < num_queues; ++i) {
 		queue = &info->queues[i];
-		queue->id = i;
-		queue->info = info;
-		err = xennet_init_queue(queue);
-		if (err) {
-			/* xennet_init_queue() cleans up after itself on failure,
-			 * but we still have to clean up any previously initialised
-			 * queues. If i > 0, set num_queues to i, then goto
-			 * destroy_ring, which calls xennet_disconnect_backend()
-			 * to tidy up.
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
 		err = setup_netfront(dev, queue, feature_split_evtchn);
 		if (err) {
-			/* As for xennet_init_queue(), setup_netfront() will tidy
-			 * up the current queue on error, but we need to clean up
+			/* setup_netfront() will tidy up the current
+			 * queue on error, but we need to clean up
 			 * those already allocated.
 			 */
 			if (i > 0) {
-- 
1.7.10.4
