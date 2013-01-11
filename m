From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: [PATCH V4 2/2] virtio-net: reset virtqueue affinity when doing cpu
	hotplug
Date: Fri, 11 Jan 2013 13:56:33 +0800
Message-ID: <1357883793-15199-2-git-send-email-gaowanlong@cn.fujitsu.com>
References: <1357883793-15199-1-git-send-email-gaowanlong@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Eric Dumazet <erdnetdev@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1357883793-15199-1-git-send-email-gaowanlong@cn.fujitsu.com>
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

Add a cpu notifier to virtio-net, so that we can reset the
virtqueue affinity if the cpu hotplug happens. It improve
the performance through enabling or disabling the virtqueue
affinity after doing cpu hotplug.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Eric Dumazet <erdnetdev@gmail.com>
Cc: virtualization@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
---
 drivers/net/virtio_net.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index ca17a58..e0b1f25 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -26,6 +26,7 @@
 #include <linux/scatterlist.h>
 #include <linux/if_vlan.h>
 #include <linux/slab.h>
+#include <linux/cpu.h>
 
 static int napi_weight = 128;
 module_param(napi_weight, int, 0444);
@@ -126,6 +127,9 @@ struct virtnet_info {
 
 	/* Per-cpu variable to show the mapping from CPU to virtqueue */
 	int __percpu *vq_index;
+
+	/* CPU hot plug notifier */
+	struct notifier_block nb;
 };
 
 struct skb_vnet_hdr {
@@ -1058,6 +1062,23 @@ static void virtnet_set_affinity(struct virtnet_info *vi, bool set)
 	}
 }
 
+static int virtnet_cpu_callback(struct notifier_block *nfb,
+			        unsigned long action, void *hcpu)
+{
+	struct virtnet_info *vi = container_of(nfb, struct virtnet_info, nb);
+	switch(action) {
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+		virtnet_set_affinity(vi, true);
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
 static void virtnet_get_ringparam(struct net_device *dev,
 				struct ethtool_ringparam *ring)
 {
@@ -1527,6 +1548,13 @@ static int virtnet_probe(struct virtio_device *vdev)
 		}
 	}
 
+	vi->nb.notifier_call = &virtnet_cpu_callback;
+	err = register_hotcpu_notifier(&vi->nb);
+	if (err) {
+		pr_debug("virtio_net: registering cpu notifier failed\n");
+		goto free_recv_bufs;
+	}
+
 	/* Assume link up if device can't report link status,
 	   otherwise get link status from config. */
 	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_STATUS)) {
@@ -1573,6 +1601,8 @@ static void virtnet_remove(struct virtio_device *vdev)
 {
 	struct virtnet_info *vi = vdev->priv;
 
+	unregister_hotcpu_notifier(&vi->nb);
+
 	/* Prevent config work handler from accessing the device. */
 	mutex_lock(&vi->config_lock);
 	vi->config_enable = false;
-- 
1.8.1
