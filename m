From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 3/6] macvtap: use common code for virtio_net_hdr and skb GSO
	conversion
Date: Wed,  8 Jun 2016 16:09:19 +0300
Message-ID: <1465391362-18437-4-git-send-email-rppt@linux.vnet.ibm.com>
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
 drivers/net/macvtap.c | 95 ++++-----------------------------------------------
 1 file changed, 6 insertions(+), 89 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index bd67209..95a1332 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -627,93 +627,6 @@ static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
 	return skb;
 }
 
-/*
- * macvtap_skb_from_vnet_hdr and macvtap_skb_to_vnet_hdr should
- * be shared with the tun/tap driver.
- */
-static int macvtap_skb_from_vnet_hdr(struct macvtap_queue *q,
-				     struct sk_buff *skb,
-				     struct virtio_net_hdr *vnet_hdr)
-{
-	unsigned short gso_type = 0;
-	if (vnet_hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		switch (vnet_hdr->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
-		case VIRTIO_NET_HDR_GSO_TCPV4:
-			gso_type = SKB_GSO_TCPV4;
-			break;
-		case VIRTIO_NET_HDR_GSO_TCPV6:
-			gso_type = SKB_GSO_TCPV6;
-			break;
-		case VIRTIO_NET_HDR_GSO_UDP:
-			gso_type = SKB_GSO_UDP;
-			break;
-		default:
-			return -EINVAL;
-		}
-
-		if (vnet_hdr->gso_type & VIRTIO_NET_HDR_GSO_ECN)
-			gso_type |= SKB_GSO_TCP_ECN;
-
-		if (vnet_hdr->gso_size == 0)
-			return -EINVAL;
-	}
-
-	if (vnet_hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
-		if (!skb_partial_csum_set(skb, macvtap16_to_cpu(q, vnet_hdr->csum_start),
-					  macvtap16_to_cpu(q, vnet_hdr->csum_offset)))
-			return -EINVAL;
-	}
-
-	if (vnet_hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		skb_shinfo(skb)->gso_size = macvtap16_to_cpu(q, vnet_hdr->gso_size);
-		skb_shinfo(skb)->gso_type = gso_type;
-
-		/* Header must be checked, and gso_segs computed. */
-		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
-		skb_shinfo(skb)->gso_segs = 0;
-	}
-	return 0;
-}
-
-static void macvtap_skb_to_vnet_hdr(struct macvtap_queue *q,
-				    const struct sk_buff *skb,
-				    struct virtio_net_hdr *vnet_hdr)
-{
-	memset(vnet_hdr, 0, sizeof(*vnet_hdr));
-
-	if (skb_is_gso(skb)) {
-		struct skb_shared_info *sinfo = skb_shinfo(skb);
-
-		/* This is a hint as to how much should be linear. */
-		vnet_hdr->hdr_len = cpu_to_macvtap16(q, skb_headlen(skb));
-		vnet_hdr->gso_size = cpu_to_macvtap16(q, sinfo->gso_size);
-		if (sinfo->gso_type & SKB_GSO_TCPV4)
-			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
-		else if (sinfo->gso_type & SKB_GSO_TCPV6)
-			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
-		else if (sinfo->gso_type & SKB_GSO_UDP)
-			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
-		else
-			BUG();
-		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
-			vnet_hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
-	} else
-		vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		vnet_hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
-		if (skb_vlan_tag_present(skb))
-			vnet_hdr->csum_start = cpu_to_macvtap16(q,
-				skb_checksum_start_offset(skb) + VLAN_HLEN);
-		else
-			vnet_hdr->csum_start = cpu_to_macvtap16(q,
-				skb_checksum_start_offset(skb));
-		vnet_hdr->csum_offset = cpu_to_macvtap16(q, skb->csum_offset);
-	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-		vnet_hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
-	} /* else everything is zero */
-}
-
 /* Neighbour code has some assumptions on HH_DATA_MOD alignment */
 #define MACVTAP_RESERVE HH_DATA_OFF(ETH_HLEN)
 
@@ -812,7 +725,8 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	skb->protocol = eth_hdr(skb)->h_proto;
 
 	if (vnet_hdr_len) {
-		err = macvtap_skb_from_vnet_hdr(q, skb, &vnet_hdr);
+		err = virtio_net_hdr_to_skb(skb, &vnet_hdr,
+					    macvtap_is_little_endian(q));
 		if (err)
 			goto err_kfree;
 	}
@@ -880,7 +794,10 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		if (iov_iter_count(iter) < vnet_hdr_len)
 			return -EINVAL;
 
-		macvtap_skb_to_vnet_hdr(q, skb, &vnet_hdr);
+		ret = virtio_net_hdr_from_skb(skb, &vnet_hdr,
+					      macvtap_is_little_endian(q));
+		if (ret)
+			BUG();
 
 		if (copy_to_iter(&vnet_hdr, sizeof(vnet_hdr), iter) !=
 		    sizeof(vnet_hdr))
-- 
1.9.1
