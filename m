From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] virtio-net: fix refill races during restore
Date: Mon, 30 Dec 2013 11:34:40 +0800
Message-ID: <1388374480-3872-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amit Shah <amit.shah@redhat.com>, Eric Dumazet <eric.dumazet@gmail.com>
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

During restoring, try_fill_recv() was called with neither napi lock nor napi
disabled. This can lead two try_fill_recv() was called in the same time. Fix
this by refilling before trying to enable napi.

Fixes 0741bcb5584f9e2390ae6261573c4de8314999f2
(virtio: net: Add freeze, restore handlers to support S4).

Cc: Amit Shah <amit.shah@redhat.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d208f86..5d77644 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1797,16 +1797,17 @@ static int virtnet_restore(struct virtio_device *vdev)
 	if (err)
 		return err;
 
-	if (netif_running(vi->dev))
+	if (netif_running(vi->dev)) {
+		for (i = 0; i < vi->curr_queue_pairs; i++)
+			if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
+				schedule_delayed_work(&vi->refill, 0);
+
 		for (i = 0; i < vi->max_queue_pairs; i++)
 			virtnet_napi_enable(&vi->rq[i]);
+	}
 
 	netif_device_attach(vi->dev);
 
-	for (i = 0; i < vi->curr_queue_pairs; i++)
-		if (!try_fill_recv(&vi->rq[i], GFP_KERNEL))
-			schedule_delayed_work(&vi->refill, 0);
-
 	mutex_lock(&vi->config_lock);
 	vi->config_enable = true;
 	mutex_unlock(&vi->config_lock);
-- 
1.8.3.2
