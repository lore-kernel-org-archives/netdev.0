From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 6/6] packet: use common code for virtio_net_hdr and skb GSO
	conversion
Date: Wed,  8 Jun 2016 16:09:22 +0300
Message-ID: <1465391362-18437-7-git-send-email-rppt@linux.vnet.ibm.com>
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
virtio_net_hdr_from_skb

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 net/packet/af_packet.c | 36 ++----------------------------------
 1 file changed, 2 insertions(+), 34 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4040eb9..ec35aa9 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1978,40 +1978,8 @@ static int __packet_rcv_vnet(const struct sk_buff *skb,
 {
 	*vnet_hdr = (const struct virtio_net_hdr) { 0 };
 
-	if (skb_is_gso(skb)) {
-		struct skb_shared_info *sinfo = skb_shinfo(skb);
-
-		/* This is a hint as to how much should be linear. */
-		vnet_hdr->hdr_len =
-			__cpu_to_virtio16(vio_le(), skb_headlen(skb));
-		vnet_hdr->gso_size =
-			__cpu_to_virtio16(vio_le(), sinfo->gso_size);
-
-		if (sinfo->gso_type & SKB_GSO_TCPV4)
-			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
-		else if (sinfo->gso_type & SKB_GSO_TCPV6)
-			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
-		else if (sinfo->gso_type & SKB_GSO_UDP)
-			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
-		else if (sinfo->gso_type & SKB_GSO_FCOE)
-			return -EINVAL;
-		else
-			BUG();
-
-		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
-			vnet_hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
-	} else
-		vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		vnet_hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
-		vnet_hdr->csum_start = __cpu_to_virtio16(vio_le(),
-				  skb_checksum_start_offset(skb));
-		vnet_hdr->csum_offset = __cpu_to_virtio16(vio_le(),
-						 skb->csum_offset);
-	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-		vnet_hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
-	} /* else everything is zero */
+	if (virtio_net_hdr_from_skb(skb, vnet_hdr, vio_le()))
+		BUG();
 
 	return 0;
 }
-- 
1.9.1
