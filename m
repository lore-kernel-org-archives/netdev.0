From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] virtio-net: mark PM functions as __maybe_unused
Date: Tue, 25 Jul 2017 17:35:50 +0200
Message-ID: <20170725153600.211694-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        John Fastabend <john.fastabend@gmail.com>,
        Willem de Bruijn <willemb@google.com>,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
        Eric Dumazet <edumazet@google.com>,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After removing the reset function, the freeze and restore functions
are now unused when CONFIG_PM_SLEEP is disabled:

drivers/net/virtio_net.c:1881:12: error: 'virtnet_restore_up' defined but not used [-Werror=unused-function]
 static int virtnet_restore_up(struct virtio_device *vdev)
drivers/net/virtio_net.c:1859:13: error: 'virtnet_freeze_down' defined but not used [-Werror=unused-function]
 static void virtnet_freeze_down(struct virtio_device *vdev)

A more robust way to do this is to remove the #ifdef around the callers
and instead mark them as __maybe_unused. The compiler will now just
silently drop the unused code.

Fixes: 4941d472bf95 ("virtio-net: do not reset during XDP set")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/virtio_net.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index d4751ce23b4f..1902701e15a9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2702,8 +2702,7 @@ static void virtnet_remove(struct virtio_device *vdev)
 	free_netdev(vi->dev);
 }
 
-#ifdef CONFIG_PM_SLEEP
-static int virtnet_freeze(struct virtio_device *vdev)
+static __maybe_unused int virtnet_freeze(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
 
@@ -2714,7 +2713,7 @@ static int virtnet_freeze(struct virtio_device *vdev)
 	return 0;
 }
 
-static int virtnet_restore(struct virtio_device *vdev)
+static __maybe_unused int virtnet_restore(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
 	int err;
@@ -2730,7 +2729,6 @@ static int virtnet_restore(struct virtio_device *vdev)
 
 	return 0;
 }
-#endif
 
 static struct virtio_device_id id_table[] = {
 	{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
-- 
2.9.0
