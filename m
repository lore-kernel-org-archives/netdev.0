From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] (please ack, don't apply!) virtio: net: Add freeze,
	restore handlers to support S4
Date: Wed, 04 Jan 2012 13:30:27 +1030
Message-ID: <87ipkscgtw.fsf@rustcorp.com.au>
References: <87obukcgzi.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Amit Shah <amit.shah@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	Virtualization List <virtualization@lists.linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <87obukcgzi.fsf@rustcorp.com.au>
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

(This needs PM changes to virtio_pci which are in my tree, so best done
 via that rather than net-next.  Thanks!)
 
From: Amit Shah <amit.shah@redhat.com>

Remove all the vqs, disable napi and detach from the netdev on
hibernation.

Re-create vqs after restoring from a hibernated image, re-enable napi
and re-attach the netdev.  This keeps networking working across
hibernation.

Signed-off-by: Amit Shah <amit.shah@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1159,6 +1159,48 @@ static void __devexit virtnet_remove(str
 	free_netdev(vi->dev);
 }
 
+#ifdef CONFIG_PM
+static int virtnet_freeze(struct virtio_device *vdev)
+{
+	struct virtnet_info *vi = vdev->priv;
+
+	virtqueue_disable_cb(vi->rvq);
+	virtqueue_disable_cb(vi->svq);
+	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ))
+		virtqueue_disable_cb(vi->cvq);
+
+	netif_device_detach(vi->dev);
+	cancel_delayed_work_sync(&vi->refill);
+
+	if (netif_running(vi->dev))
+		napi_disable(&vi->napi);
+
+	remove_vq_common(vi);
+
+	return 0;
+}
+
+static int virtnet_restore(struct virtio_device *vdev)
+{
+	struct virtnet_info *vi = vdev->priv;
+	int err;
+
+	err = init_vqs(vi);
+	if (err)
+		return err;
+
+	if (netif_running(vi->dev))
+		virtnet_napi_enable(vi);
+
+	netif_device_attach(vi->dev);
+
+	if (!try_fill_recv(vi, GFP_KERNEL))
+		queue_delayed_work(system_nrt_wq, &vi->refill, 0);
+
+	return 0;
+}
+#endif
+
 static struct virtio_device_id id_table[] = {
 	{ VIRTIO_ID_NET, VIRTIO_DEV_ANY_ID },
 	{ 0 },
@@ -1183,6 +1225,10 @@ static struct virtio_driver virtio_net_d
 	.probe =	virtnet_probe,
 	.remove =	__devexit_p(virtnet_remove),
 	.config_changed = virtnet_config_changed,
+#ifdef CONFIG_PM
+	.freeze =	virtnet_freeze,
+	.restore =	virtnet_restore,
+#endif
 };
 
 static int __init init(void)
