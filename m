From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] virtio-net: serialize tx routine during reset
Date: Wed, 28 Jun 2017 09:51:03 +0800
Message-ID: <1498614663-7711-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, jpmenil@gmail.com
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
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

We don't hold any tx lock when trying to disable TX during reset, this
would lead a use after free since ndo_start_xmit() tries to access
the virtqueue which has already been freed. Fix this by using
netif_tx_disable() before freeing the vqs, this could make sure no tx
after vq freeing.

Reported-by: Jean-Philippe Menil <jpmenil@gmail.com>
Tested-by: Jean-Philippe Menil <jpmenil@gmail.com>
Fixes commit f600b6905015 ("virtio_net: Add XDP support")
Cc: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a871f45..143d8a9 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1797,6 +1797,7 @@ static void virtnet_freeze_down(struct virtio_device *vdev)
 	flush_work(&vi->config_work);
 
 	netif_device_detach(vi->dev);
+	netif_tx_disable(vi->dev);
 	cancel_delayed_work_sync(&vi->refill);
 
 	if (netif_running(vi->dev)) {
-- 
2.7.4
