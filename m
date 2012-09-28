From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 3/3] virtio-net: put virtio net header inline with data
Date: Fri, 28 Sep 2012 11:26:13 +0200
Message-ID: <8d883c48c26385babe6e09f7669e420924cea0b5.1348824232.git.mst@redhat.com>
References: <cover.1348824232.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, avi@redhat.com,
	Sasha Levin <levinsasha928@gmail.com>
To: Thomas Lendacky <tahm@linux.vnet.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1348824232.git.mst@redhat.com>
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
 drivers/net/virtio_net.c   | 44 +++++++++++++++++++++++++++++++++++---------
 include/linux/virtio_net.h |  5 ++++-
 2 files changed, 39 insertions(+), 10 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 316f1be..6e6e53e 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -67,6 +67,9 @@ struct virtnet_info {
 	/* Host will merge rx buffers for big packets (shake it! shake it!) */
 	bool mergeable_rx_bufs;
 
+	/* Host can handle any s/g split between our header and packet data */
+	bool any_header_sg;
+
 	/* enable config space updates */
 	bool config_enable;
 
@@ -576,11 +579,28 @@ static void free_old_xmit_skbs(struct virtnet_info *vi)
 
 static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 {
-	struct skb_vnet_hdr *hdr = skb_vnet_hdr(skb);
+	struct skb_vnet_hdr *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
 	unsigned num_sg;
+	unsigned hdr_len;
+	bool can_push;
+
 
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
@@ -609,15 +629,18 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb)
 		hdr->hdr.gso_size = hdr->hdr.hdr_len = 0;
 	}
 
-	hdr->mhdr.num_buffers = 0;
-
-	/* Encode metadata header at front. */
 	if (vi->mergeable_rx_bufs)
-		sg_set_buf(vi->tx_sg, &hdr->mhdr, sizeof hdr->mhdr);
-	else
-		sg_set_buf(vi->tx_sg, &hdr->hdr, sizeof hdr->hdr);
+		hdr->mhdr.num_buffers = 0;
 
-	num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
+	if (can_push) {
+		__skb_push(skb, hdr_len);
+		num_sg = skb_to_sgvec(skb, vi->tx_sg, 0, skb->len);
+		/* Pull header back to avoid skew in tx bytes calculations. */
+		__skb_pull(skb, hdr_len);
+	} else {
+		sg_set_buf(vi->tx_sg, hdr, hdr_len);
+		num_sg = skb_to_sgvec(skb, vi->tx_sg + 1, 0, skb->len) + 1;
+	}
 	return virtqueue_add_buf(vi->svq, vi->tx_sg, num_sg,
 				 0, skb, GFP_ATOMIC);
 }
@@ -1128,6 +1151,9 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_ANY_HEADER_SG))
+		vi->any_header_sg = true;
+
 	err = init_vqs(vi);
 	if (err)
 		goto free_stats;
@@ -1286,7 +1312,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
-	VIRTIO_NET_F_GUEST_ANNOUNCE,
+	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_ANY_HEADER_SG
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 2470f54..16a577b 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -51,6 +51,7 @@
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
 #define VIRTIO_NET_F_GUEST_ANNOUNCE 21	/* Guest can announce device on the
 					 * network */
+#define VIRTIO_NET_F_ANY_HEADER_SG 22	/* Host can handle any header s/g */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 #define VIRTIO_NET_S_ANNOUNCE	2	/* Announcement is needed */
@@ -62,7 +63,9 @@ struct virtio_net_config {
 	__u16 status;
 } __attribute__((packed));
 
-/* This is the first element of the scatter-gather list.  If you don't
+/* This header comes first in the scatter-gather list.
+ * If VIRTIO_NET_F_ANY_HEADER_SG is not negotiated, it must
+ * be the first element of the scatter-gather list.  If you don't
  * specify GSO or CSUM features, you can simply ignore the header. */
 struct virtio_net_hdr {
 #define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
-- 
MST
