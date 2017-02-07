From: Ross Lagerwall <ross.lagerwall@citrix.com>
Subject: [PATCH v2] xen-netfront: Improve error handling during initialization
Date: Tue, 7 Feb 2017 14:55:12 +0000
Message-ID: <1486479312-18424-1-git-send-email-ross.lagerwall@citrix.com>
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

This fixes a crash when running out of grant refs when creating many
queues across many netdevs.

* If creating queues fails (i.e. there are no grant refs available),
call xenbus_dev_fatal() to ensure that the xenbus device is set to the
closed state.
* If no queues are created, don't call xennet_disconnect_backend as
netdev->real_num_tx_queues will not have been set correctly.
* If setup_netfront() fails, ensure that all the queues created are
cleaned up, not just those that have been set up.
* If any queues were set up and an error occurs, call
xennet_destroy_queues() to clean up the napi context.
* If any fatal error occurs, unregister and destroy the netdev to avoid
leaving around a half setup network device.

Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
---

Changed in V2:
* Retested on top of v4.10-rc7 + "xen-netfront: Delete rx_refill_timer
  in xennet_disconnect_backend()".
* Don't move setup_timer as it is not necessary.

 drivers/net/xen-netfront.c | 33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 722fe9f..5399a86 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1823,27 +1823,23 @@ static int talk_to_netback(struct xenbus_device *dev,
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
@@ -1933,9 +1929,10 @@ static int talk_to_netback(struct xenbus_device *dev,
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
