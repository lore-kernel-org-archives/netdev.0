From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v7 41/46] macvtap: TUN_VNET_LE support
Date: Sun, 30 Nov 2014 17:12:42 +0200
Message-ID: <1417359787-10138-42-git-send-email-mst@redhat.com>
References: <1417359787-10138-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	Jason Wang <jasowang@redhat.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417359787-10138-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Reviewed-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c | 68 ++++++++++++++++++++++++++++++++-------------------
 1 file changed, 43 insertions(+), 25 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 880cc09..af90ab5 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -45,6 +45,18 @@ struct macvtap_queue {
 	struct list_head next;
 };
 
+#define MACVTAP_FEATURES (IFF_VNET_HDR | IFF_VNET_LE | IFF_MULTI_QUEUE)
+
+static inline u16 macvtap16_to_cpu(struct macvtap_queue *q, __virtio16 val)
+{
+	return __virtio16_to_cpu(q->flags & IFF_VNET_LE, val);
+}
+
+static inline __virtio16 cpu_to_macvtap16(struct macvtap_queue *q, u16 val)
+{
+	return __cpu_to_virtio16(q->flags & IFF_VNET_LE, val);
+}
+
 static struct proto macvtap_proto = {
 	.name = "macvtap",
 	.owner = THIS_MODULE,
@@ -557,7 +569,8 @@ static inline struct sk_buff *macvtap_alloc_skb(struct sock *sk, size_t prepad,
  * macvtap_skb_from_vnet_hdr and macvtap_skb_to_vnet_hdr should
  * be shared with the tun/tap driver.
  */
-static int macvtap_skb_from_vnet_hdr(struct sk_buff *skb,
+static int macvtap_skb_from_vnet_hdr(struct macvtap_queue *q,
+				     struct sk_buff *skb,
 				     struct virtio_net_hdr *vnet_hdr)
 {
 	unsigned short gso_type = 0;
@@ -588,13 +601,13 @@ static int macvtap_skb_from_vnet_hdr(struct sk_buff *skb,
 	}
 
 	if (vnet_hdr->flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
-		if (!skb_partial_csum_set(skb, vnet_hdr->csum_start,
-					  vnet_hdr->csum_offset))
+		if (!skb_partial_csum_set(skb, macvtap16_to_cpu(q, vnet_hdr->csum_start),
+					  macvtap16_to_cpu(q, vnet_hdr->csum_offset)))
 			return -EINVAL;
 	}
 
 	if (vnet_hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		skb_shinfo(skb)->gso_size = vnet_hdr->gso_size;
+		skb_shinfo(skb)->gso_size = macvtap16_to_cpu(q, vnet_hdr->gso_size);
 		skb_shinfo(skb)->gso_type = gso_type;
 
 		/* Header must be checked, and gso_segs computed. */
@@ -604,8 +617,9 @@ static int macvtap_skb_from_vnet_hdr(struct sk_buff *skb,
 	return 0;
 }
 
-static void macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
-				   struct virtio_net_hdr *vnet_hdr)
+static void macvtap_skb_to_vnet_hdr(struct macvtap_queue *q,
+				    const struct sk_buff *skb,
+				    struct virtio_net_hdr *vnet_hdr)
 {
 	memset(vnet_hdr, 0, sizeof(*vnet_hdr));
 
@@ -613,8 +627,8 @@ static void macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
 		struct skb_shared_info *sinfo = skb_shinfo(skb);
 
 		/* This is a hint as to how much should be linear. */
-		vnet_hdr->hdr_len = skb_headlen(skb);
-		vnet_hdr->gso_size = sinfo->gso_size;
+		vnet_hdr->hdr_len = cpu_to_macvtap16(q, skb_headlen(skb));
+		vnet_hdr->gso_size = cpu_to_macvtap16(q, sinfo->gso_size);
 		if (sinfo->gso_type & SKB_GSO_TCPV4)
 			vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 		else if (sinfo->gso_type & SKB_GSO_TCPV6)
@@ -628,10 +642,13 @@ static void macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		vnet_hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
-		vnet_hdr->csum_start = skb_checksum_start_offset(skb);
 		if (vlan_tx_tag_present(skb))
-			vnet_hdr->csum_start += VLAN_HLEN;
-		vnet_hdr->csum_offset = skb->csum_offset;
+			vnet_hdr->csum_start = cpu_to_macvtap16(q,
+				skb_checksum_start_offset(skb) + VLAN_HLEN);
+		else
+			vnet_hdr->csum_start = cpu_to_macvtap16(q,
+				skb_checksum_start_offset(skb));
+		vnet_hdr->csum_offset = cpu_to_macvtap16(q, skb->csum_offset);
 	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		vnet_hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;
 	} /* else everything is zero */
@@ -666,12 +683,14 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 		if (err < 0)
 			goto err;
 		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
-		     vnet_hdr.csum_start + vnet_hdr.csum_offset + 2 >
-							vnet_hdr.hdr_len)
-			vnet_hdr.hdr_len = vnet_hdr.csum_start +
-						vnet_hdr.csum_offset + 2;
+		     macvtap16_to_cpu(q, vnet_hdr.csum_start) +
+		     macvtap16_to_cpu(q, vnet_hdr.csum_offset) + 2 >
+			     macvtap16_to_cpu(q, vnet_hdr.hdr_len))
+			vnet_hdr.hdr_len = cpu_to_macvtap16(q,
+				 macvtap16_to_cpu(q, vnet_hdr.csum_start) +
+				 macvtap16_to_cpu(q, vnet_hdr.csum_offset) + 2);
 		err = -EINVAL;
-		if (vnet_hdr.hdr_len > len)
+		if (macvtap16_to_cpu(q, vnet_hdr.hdr_len) > len)
 			goto err;
 	}
 
@@ -684,7 +703,8 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 		goto err;
 
 	if (m && m->msg_control && sock_flag(&q->sk, SOCK_ZEROCOPY)) {
-		copylen = vnet_hdr.hdr_len ? vnet_hdr.hdr_len : GOODCOPY_LEN;
+		copylen = vnet_hdr.hdr_len ?
+			macvtap16_to_cpu(q, vnet_hdr.hdr_len) : GOODCOPY_LEN;
 		if (copylen > good_linear)
 			copylen = good_linear;
 		linear = copylen;
@@ -695,10 +715,10 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 
 	if (!zerocopy) {
 		copylen = len;
-		if (vnet_hdr.hdr_len > good_linear)
+		if (macvtap16_to_cpu(q, vnet_hdr.hdr_len) > good_linear)
 			linear = good_linear;
 		else
-			linear = vnet_hdr.hdr_len;
+			linear = macvtap16_to_cpu(q, vnet_hdr.hdr_len);
 	}
 
 	skb = macvtap_alloc_skb(&q->sk, NET_IP_ALIGN, copylen,
@@ -725,7 +745,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	skb->protocol = eth_hdr(skb)->h_proto;
 
 	if (vnet_hdr_len) {
-		err = macvtap_skb_from_vnet_hdr(skb, &vnet_hdr);
+		err = macvtap_skb_from_vnet_hdr(q, skb, &vnet_hdr);
 		if (err)
 			goto err_kfree;
 	}
@@ -791,7 +811,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		if ((len -= vnet_hdr_len) < 0)
 			return -EINVAL;
 
-		macvtap_skb_to_vnet_hdr(skb, &vnet_hdr);
+		macvtap_skb_to_vnet_hdr(q, skb, &vnet_hdr);
 
 		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
 			return -EFAULT;
@@ -1003,8 +1023,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 			return -EFAULT;
 
 		ret = 0;
-		if ((u & ~(IFF_VNET_HDR | IFF_MULTI_QUEUE)) !=
-		    (IFF_NO_PI | IFF_TAP))
+		if ((u & ~MACVTAP_FEATURES) != (IFF_NO_PI | IFF_TAP))
 			ret = -EINVAL;
 		else
 			q->flags = u;
@@ -1036,8 +1055,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		return ret;
 
 	case TUNGETFEATURES:
-		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR |
-			     IFF_MULTI_QUEUE, up))
+		if (put_user(IFF_TAP | IFF_NO_PI | MACVTAP_FEATURES, up))
 			return -EFAULT;
 		return 0;
 
-- 
MST
