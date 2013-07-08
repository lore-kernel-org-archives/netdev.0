From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] virtio-net: put virtio net header inline with data
Date: Mon, 8 Jul 2013 13:12:59 +0300
Message-ID: <20130708101259.GA16074@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, Dave Jones <davej@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

For small packets we can simplify xmit processing
by linearizing buffers with the header:
most packets seem to have enough head room
we can use for this purpose.
Since existing hypervisors require that header
is the first s/g element, we need a feature bit
for this.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

Note: this needs to be applied on top of patch
defining VIRTIO_F_ANY_LAYOUT - bit to be
selected by Rusty.

The following patch should work for any definition of
VIRTIO_F_ANY_LAYOUT - I used bit 31 for testing.
Rusty, could you please pick a valid bit for VIRTIO_F_ANY_LAYOUT
and squeeze this patch into 3.11?

 drivers/net/virtio_net.c        | 42 +++++++++++++++++++++++++++++++++--------
 include/uapi/linux/virtio_net.h |  4 +++-
 2 files changed, 37 insertions(+), 9 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c9e0038..5305bd1 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -106,6 +106,9 @@ struct virtnet_info {
 	/* Has control virtqueue */
 	bool has_cvq;
 
+	/* Host can handle any s/g split between our header and packet data */
+	bool any_header_sg;
+
 	/* enable config space updates */
 	bool config_enable;
 
@@ -668,12 +671,28 @@ static void free_old_xmit_skbs(struct send_queue *sq)
 
 static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 {
-	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
+	struct skb_vnet_hdr *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
 	struct virtnet_info *vi = sq->vq->vdev->priv;
 	unsigned num_sg;
+	unsigned hdr_len;
+	bool can_push;
 
 	pr_debug("%s: xmit %p %pM\n", vi->dev->name, skb, dest);
+	if (vi->mergeable_rx_bufs)
+		hdr_len = sizeof hdr->mhdr;
+	else
+		hdr_len = sizeof hdr->hdr;
+
+	can_push = vi->any_header_sg &&
+		!((unsigned long)skb->data & (__alignof__(*hdr) - 1)) &&
+		!skb_header_cloned(skb) && skb_headroom(skb) >= hdr_len;
+	/* Even if we can, don't push here yet as this would skew
+	 * csum_start offset below. */
+	if (can_push)
+		hdr = (struct skb_vnet_hdr *)(skb->data - hdr_len);
+	else
+		hdr = skb_vnet_hdr(skb);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		hdr->hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
@@ -702,15 +721,18 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 		hdr->hdr.gso_size = hdr->hdr.hdr_len = 0;
 	}
 
-	hdr->mhdr.num_buffers = 0;
-
-	/* Encode metadata header at front. */
 	if (vi->mergeable_rx_bufs)
-		sg_set_buf(sq->sg, &hdr->mhdr, sizeof hdr->mhdr);
-	else
-		sg_set_buf(sq->sg, &hdr->hdr, sizeof hdr->hdr);
+		hdr->mhdr.num_buffers = 0;
 
-	num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
+	if (can_push) {
+		__skb_push(skb, hdr_len);
+		num_sg = skb_to_sgvec(skb, sq->sg, 0, skb->len);
+		/* Pull header back to avoid skew in tx bytes calculations. */
+		__skb_pull(skb, hdr_len);
+	} else {
+		sg_set_buf(sq->sg, hdr, hdr_len);
+		num_sg = skb_to_sgvec(skb, sq->sg + 1, 0, skb->len) + 1;
+	}
 	return virtqueue_add_outbuf(sq->vq, sq->sg, num_sg, skb, GFP_ATOMIC);
 }
 
@@ -1554,6 +1576,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
+	if (virtio_has_feature(vdev, VIRTIO_F_ANY_LAYOUT))
+		vi->any_header_sg = true;
+
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_CTRL_VQ))
 		vi->has_cvq = true;
 
@@ -1729,6 +1754,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
 	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
 	VIRTIO_NET_F_CTRL_MAC_ADDR,
+	VIRTIO_F_ANY_LAYOUT,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index c520203..bd1993b 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -70,7 +70,9 @@ struct virtio_net_config {
 	__u16 max_virtqueue_pairs;
 } __attribute__((packed));
 
-/* This is the first element of the scatter-gather list.  If you don't
+/* This header comes first in the scatter-gather list.
+ * If VIRTIO_F_ANY_LAYOUT is not negotiated, it must
+ * be the first element of the scatter-gather list.  If you don't
  * specify GSO or CSUM features, you can simply ignore the header. */
 struct virtio_net_hdr {
 #define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
-- 
MST
