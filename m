From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next v2 3/3] virtio-net: support changing the number of
	queue pairs through ethtool
Date: Wed,  5 Dec 2012 18:37:52 +0800
Message-ID: <1354703872-25677-4-git-send-email-jasowang@redhat.com>
References: <1354703872-25677-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jwhan@filewood.snu.ac.kr, shiyer@redhat.com,
	kvm@vger.kernel.org
To: mst@redhat.com, rusty@rustcorp.com.au, davem@davemloft.net,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1354703872-25677-1-git-send-email-jasowang@redhat.com>
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

This patch implements the ethtool_{set|get}_channels method of virtio-net to
allow user to change the number of queues when the device is running on demand.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c |   43 +++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index def11ce..51c9b75 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1075,10 +1075,53 @@ static void virtnet_get_drvinfo(struct net_device *dev,
 
 }
 
+/* TODO: Eliminate OOO packets during switching */
+static int virtnet_set_channels(struct net_device *dev,
+				struct ethtool_channels *channels)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+	u16 queue_pairs = channels->combined_count;
+	int err;
+
+	/* We don't support separate rx/tx channels.
+	 * We don't allow setting 'other' channels.
+	 */
+	if (channels->rx_count || channels->tx_count || channels->other_count)
+		return -EINVAL;
+
+	if (queue_pairs > vi->max_queue_pairs)
+		return -EINVAL;
+
+	err = virtnet_set_queues(vi, queue_pairs);
+	if (!err) {
+		netif_set_real_num_tx_queues(dev, queue_pairs);
+		netif_set_real_num_rx_queues(dev, queue_pairs);
+
+		virtnet_set_affinity(vi, true);
+	}
+
+	return err;
+}
+
+static void virtnet_get_channels(struct net_device *dev,
+				 struct ethtool_channels *channels)
+{
+	struct virtnet_info *vi = netdev_priv(dev);
+
+	channels->combined_count = vi->curr_queue_pairs;
+	channels->max_combined = vi->max_queue_pairs;
+	channels->max_other = 0;
+	channels->rx_count = 0;
+	channels->tx_count = 0;
+	channels->other_count = 0;
+}
+
 static const struct ethtool_ops virtnet_ethtool_ops = {
 	.get_drvinfo = virtnet_get_drvinfo,
 	.get_link = ethtool_op_get_link,
 	.get_ringparam = virtnet_get_ringparam,
+	.set_channels = virtnet_set_channels,
+	.get_channels = virtnet_get_channels,
 };
 
 #define MIN_MTU 68
-- 
1.7.1
