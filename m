From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 5/6] virtio_net: use common code for virtio_net_hdr and skb
	GSO conversion
Date: Wed,  8 Jun 2016 16:09:21 +0300
Message-ID: <1465391362-18437-6-git-send-email-rppt@linux.vnet.ibm.com>
References: <1465391362-18437-1-git-send-email-rppt@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1465391362-18437-1-git-send-email-rppt@linux.vnet.ibm.com>
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

Replace open coded conversion between virtio_net_hdr to skb GSO info with
virtio_net_hdr_{from,to}_skb

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 drivers/net/virtio_net.c | 78 +++++++-----------------------------------------
 1 file changed, 10 insertions(+), 68 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e0638e5..9af0a98 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -479,51 +479,19 @@ static void receive_buf(struct virtnet_info *vi, struct receive_queue *rq,
 	stats->rx_packets++;
 	u64_stats_update_end(&stats->rx_syncp);
 
-	if (hdr->hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
-		pr_debug("Needs csum!\n");
-		if (!skb_partial_csum_set(skb,
-			  virtio16_to_cpu(vi->vdev, hdr->hdr.csum_start),
-			  virtio16_to_cpu(vi->vdev, hdr->hdr.csum_offset)))
-			goto frame_err;
-	} else if (hdr->hdr.flags & VIRTIO_NET_HDR_F_DATA_VALID) {
+	if (hdr->hdr.flags & VIRTIO_NET_HDR_F_DATA_VALID)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	}
 
 	skb->protocol = eth_type_trans(skb, dev);
 	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
 		 ntohs(skb->protocol), skb->len, skb->pkt_type);
 
-	if (hdr->hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		pr_debug("GSO!\n");
-		switch (hdr->hdr.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
-		case VIRTIO_NET_HDR_GSO_TCPV4:
-			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
-			break;
-		case VIRTIO_NET_HDR_GSO_UDP:
-			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
-			break;
-		case VIRTIO_NET_HDR_GSO_TCPV6:
-			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
-			break;
-		default:
-			net_warn_ratelimited("%s: bad gso type %u.\n",
-					     dev->name, hdr->hdr.gso_type);
-			goto frame_err;
-		}
-
-		if (hdr->hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
-			skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
-
-		skb_shinfo(skb)->gso_size = virtio16_to_cpu(vi->vdev,
-							    hdr->hdr.gso_size);
-		if (skb_shinfo(skb)->gso_size == 0) {
-			net_warn_ratelimited("%s: zero gso size.\n", dev->name);
-			goto frame_err;
-		}
-
-		/* Header must be checked, and gso_segs computed. */
-		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
-		skb_shinfo(skb)->gso_segs = 0;
+	if (virtio_net_hdr_to_skb(skb, &hdr->hdr,
+				  virtio_is_little_endian(vi->vdev))) {
+		net_warn_ratelimited("%s: bad gso: type: %u, size: %u\n",
+				     dev->name, hdr->hdr.gso_type,
+				     hdr->hdr.gso_size);
+		goto frame_err;
 	}
 
 	napi_gro_receive(&rq->napi, skb);
@@ -868,35 +836,9 @@ static int xmit_skb(struct send_queue *sq, struct sk_buff *skb)
 	else
 		hdr = skb_vnet_hdr(skb);
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		hdr->hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
-		hdr->hdr.csum_start = cpu_to_virtio16(vi->vdev,
-						skb_checksum_start_offset(skb));
-		hdr->hdr.csum_offset = cpu_to_virtio16(vi->vdev,
-							 skb->csum_offset);
-	} else {
-		hdr->hdr.flags = 0;
-		hdr->hdr.csum_offset = hdr->hdr.csum_start = 0;
-	}
-
-	if (skb_is_gso(skb)) {
-		hdr->hdr.hdr_len = cpu_to_virtio16(vi->vdev, skb_headlen(skb));
-		hdr->hdr.gso_size = cpu_to_virtio16(vi->vdev,
-						    skb_shinfo(skb)->gso_size);
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-			hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
-		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
-			hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
-		else if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
-			hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_UDP;
-		else
-			BUG();
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCP_ECN)
-			hdr->hdr.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
-	} else {
-		hdr->hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE;
-		hdr->hdr.gso_size = hdr->hdr.hdr_len = 0;
-	}
+	if (virtio_net_hdr_from_skb(skb, &hdr->hdr,
+				    virtio_is_little_endian(vi->vdev)))
+		BUG();
 
 	if (vi->mergeable_rx_bufs)
 		hdr->num_buffers = 0;
-- 
1.9.1
