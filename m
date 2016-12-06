From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH] virtio-net: Fix DMA-from-the-stack in
	virtnet_set_mac_address()
Date: Mon,  5 Dec 2016 18:10:58 -0800
Message-ID: <fe889e578d5dffa9ae0834b449a35fcfd1e10694.1480990173.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Michael S . Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Andy Lutomirski <luto@kernel.org>, Laura Abbott <labbott@redhat.com>
To: netdev@vger.kernel.org
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

With CONFIG_VMAP_STACK=y, virtnet_set_mac_address() can be passed a
pointer to the stack and it will OOPS.  Copy the address to the heap
to prevent the crash.

Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>
Reported-by: zbyszek@in.waw.pl
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---

Very lightly tested.

 drivers/net/virtio_net.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7276d5a95bd0..cbf1c613c67a 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -969,12 +969,17 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 	struct virtnet_info *vi = netdev_priv(dev);
 	struct virtio_device *vdev = vi->vdev;
 	int ret;
-	struct sockaddr *addr = p;
+	struct sockaddr *addr;
 	struct scatterlist sg;
 
-	ret = eth_prepare_mac_addr_change(dev, p);
+	addr = kmalloc(sizeof(*addr), GFP_KERNEL);
+	if (!addr)
+		return -ENOMEM;
+	memcpy(addr, p, sizeof(*addr));
+
+	ret = eth_prepare_mac_addr_change(dev, addr);
 	if (ret)
-		return ret;
+		goto out;
 
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_MAC_ADDR)) {
 		sg_init_one(&sg, addr->sa_data, dev->addr_len);
@@ -982,7 +987,8 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 					  VIRTIO_NET_CTRL_MAC_ADDR_SET, &sg)) {
 			dev_warn(&vdev->dev,
 				 "Failed to set mac address by vq command.\n");
-			return -EINVAL;
+			ret = -EINVAL;
+			goto out;
 		}
 	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC) &&
 		   !virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
@@ -996,8 +1002,11 @@ static int virtnet_set_mac_address(struct net_device *dev, void *p)
 	}
 
 	eth_commit_mac_addr_change(dev, p);
+	ret = 0;
 
-	return 0;
+out:
+	kfree(addr);
+	return ret;
 }
 
 static struct rtnl_link_stats64 *virtnet_stats(struct net_device *dev,
-- 
2.9.3
