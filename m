From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net V2 2/2] virtio-net: refill only when device is up during
	setting queues
Date: Tue, 15 Oct 2013 11:18:59 +0800
Message-ID: <1381807139-3450-2-git-send-email-jasowang@redhat.com>
References: <1381807139-3450-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1381807139-3450-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

We used to schedule the refill work unconditionally after changing the
number of queues. This may lead an issue if the device is not
up. Since we only try to cancel the work in ndo_stop(), this may cause
the refill work still work after removing the device. Fix this by only
schedule the work when device is up.

The bug were introduce by commit 9b9cd8024a2882e896c65222aa421d461354e3f2.
(virtio-net: fix the race between channels setting and refill)

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
Changes from v1: add missing rtnl_lock() in virtnet_restore().
The patch were need for 3.10 and above.
---
 drivers/net/virtio_net.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c4bc1cc..9fbdfcd 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -938,7 +938,9 @@ static int virtnet_set_queues(struct virtnet_info *vi, u16 queue_pairs)
 		return -EINVAL;
 	} else {
 		vi->curr_queue_pairs = queue_pairs;
-		schedule_delayed_work(&vi->refill, 0);
+		/* virtnet_open() will refill when device is going to up. */
+		if (dev->flags & IFF_UP)
+			schedule_delayed_work(&vi->refill, 0);
 	}
 
 	return 0;
@@ -1741,7 +1743,9 @@ static int virtnet_restore(struct virtio_device *vdev)
 	vi->config_enable = true;
 	mutex_unlock(&vi->config_lock);
 
+	rtnl_lock();
 	virtnet_set_queues(vi, vi->curr_queue_pairs);
+	rtnl_unlock();
 
 	return 0;
 }
-- 
1.8.1.2
