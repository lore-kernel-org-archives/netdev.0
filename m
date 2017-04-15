From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH RFC (resend) net-next 1/6] virtio-net: Remove the use the
	padded vnet_header structure
Date: Sat, 15 Apr 2017 12:38:13 -0400
Message-ID: <1492274298-17362-2-git-send-email-vyasevic@redhat.com>
References: <1492274298-17362-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, mst@redhat.com,
	virtualization@lists.linux-foundation.org, maxime.coquelin@redhat.com
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1492274298-17362-1-git-send-email-vyasevic@redhat.com>
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

We can replace the structure with a properly aligned size instead.
The current structure attempts to align on a 16 byte boundary, so
preserve it.

Signed-off-by: Vlad Yaseivch <vyasevic@redhat.com>
---
 drivers/net/virtio_net.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index b0d241d..2937a98 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -174,15 +174,20 @@ struct virtnet_info {
 	u32 speed;
 };
 
-struct padded_vnet_hdr {
-	struct virtio_net_hdr_mrg_rxbuf hdr;
+static inline u8 padded_vnet_hdr(struct virtnet_info *vi)
+{
+	u8 hdr_len = vi->hdr_len;
+
 	/*
 	 * hdr is in a separate sg buffer, and data sg buffer shares same page
 	 * with this header sg. This padding makes next sg 16 byte aligned
 	 * after the header.
 	 */
-	char padding[4];
-};
+	if (!vi->mergeable_rx_bufs)
+		hdr_len = __ALIGN_KERNEL_MASK(hdr_len, 15);
+
+	return hdr_len;
+}
 
 /* Converting between virtqueue no. and kernel tx/rx queue no.
  * 0:rx0 1:tx0 2:rx1 3:tx1 ... 2N:rxN 2N+1:txN 2N+2:cvq
@@ -289,10 +294,7 @@ static struct sk_buff *page_to_skb(struct virtnet_info *vi,
 	hdr = skb_vnet_hdr(skb);
 
 	hdr_len = vi->hdr_len;
-	if (vi->mergeable_rx_bufs)
-		hdr_padded_len = sizeof *hdr;
-	else
-		hdr_padded_len = sizeof(struct padded_vnet_hdr);
+	hdr_padded_len = padded_vnet_hdr(vi);
 
 	memcpy(hdr, p, hdr_len);
 
@@ -840,7 +842,7 @@ static int add_recvbuf_big(struct virtnet_info *vi, struct receive_queue *rq,
 	sg_set_buf(&rq->sg[0], p, vi->hdr_len);
 
 	/* rq->sg[1] for data packet, from offset */
-	offset = sizeof(struct padded_vnet_hdr);
+	offset = padded_vnet_hdr(vi);
 	sg_set_buf(&rq->sg[1], p + offset, PAGE_SIZE - offset);
 
 	/* chain first in list head */
@@ -1790,8 +1792,8 @@ static int virtnet_reset(struct virtnet_info *vi, int curr_qp, int xdp_qp)
 
 static int virtnet_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 {
-	unsigned long int max_sz = PAGE_SIZE - sizeof(struct padded_vnet_hdr);
 	struct virtnet_info *vi = netdev_priv(dev);
+	unsigned long int max_sz = PAGE_SIZE - padded_vnet_hdr(vi);
 	struct bpf_prog *old_prog;
 	u16 xdp_qp = 0, curr_qp;
 	int i, err;
-- 
2.7.4
