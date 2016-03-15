From: Aaron Conole <aconole@redhat.com>
Subject: [RFC v2 -next 2/2] virtio_net: Read the advised MTU
Date: Tue, 15 Mar 2016 17:04:13 -0400
Message-ID: <1458075853-14789-3-git-send-email-aconole@redhat.com>
References: <1458075853-14789-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1458075853-14789-1-git-send-email-aconole@redhat.com>
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

This patch checks the feature bit for the VIRTIO_NET_F_MTU feature. If it
exists, read the advised MTU and use it.

No proper error handling is provided for the case where a user changes the
negotiated MTU. A future commit will add proper error handling. Instead, a
warning is emitted if the guest changes the device MTU after previously
being given advice.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
v2:
* Whitespace cleanup in the last hunk
* Code style change around the pr_warn
* Additional test for mtu change before printing warning

 drivers/net/virtio_net.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 767ab11..429fe01 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -146,6 +146,7 @@ struct virtnet_info {
 	virtio_net_ctrl_ack ctrl_status;
 	u8 ctrl_promisc;
 	u8 ctrl_allmulti;
+	bool negotiated_mtu;
 };
 
 struct padded_vnet_hdr {
@@ -1390,8 +1391,11 @@ static const struct ethtool_ops virtnet_ethtool_ops = {
 
 static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct virtnet_info *vi = netdev_priv(dev);
 	if (new_mtu < MIN_MTU || new_mtu > MAX_MTU)
 		return -EINVAL;
+	if ((vi->negotiated_mtu) && (dev->mtu != new_mtu))
+		pr_warn("changing mtu while the advised mtu bit exists.");
 	dev->mtu = new_mtu;
 	return 0;
 }
@@ -1836,6 +1840,13 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
 		vi->has_cvq = true;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_MTU)) {
+		vi->negotiated_mtu = true;
+		dev->mtu = virtio_cread16(vdev,
+					  offsetof(struct virtio_net_config,
+						   mtu));
+	}
+
 	if (vi->any_header_sg)
 		dev->needed_headroom = vi->hdr_len;
 
@@ -2019,6 +2030,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
 	VIRTIO_NET_F_CTRL_MAC_ADDR,
 	VIRTIO_F_ANY_LAYOUT,
+	VIRTIO_NET_F_MTU,
 };
 
 static struct virtio_driver virtio_net_driver = {
-- 
2.5.0
