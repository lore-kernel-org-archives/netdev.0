From: Jason Wang <jasowang@redhat.com>
Subject: [net-next RFC PATCH 1/5] virtio_net: passing rxhash through vnet_hdr
Date: Mon, 05 Dec 2011 16:58:47 +0800
Message-ID: <20111205085847.6116.45487.stgit@dhcp-8-146.nay.redhat.com>
References: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	virtualization@lists.linux-foundation.org, levinsasha928@gmail.com,
	bhutchings@solarflare.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111205085603.6116.65101.stgit@dhcp-8-146.nay.redhat.com>
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

This patch enables the ability to pass the rxhash value to guest
through vnet_hdr. This is useful for guest when it wants to cooperate
with virtual device to steer a flow to dedicated guest cpu.

This feature is negotiated through VIRTIO_NET_F_GUEST_RXHASH.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c      |   10 ++++++----
 drivers/net/tun.c          |   44 +++++++++++++++++++++++++-------------------
 drivers/net/virtio_net.c   |   26 ++++++++++++++++++++++----
 drivers/vhost/net.c        |   10 +++++++---
 drivers/vhost/vhost.h      |    5 +++--
 include/linux/if_tun.h     |    1 +
 include/linux/virtio_net.h |   10 +++++++++-
 7 files changed, 73 insertions(+), 33 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 7c88d13..504c745 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -760,16 +760,17 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 	int vnet_hdr_len = 0;
 
 	if (q->flags & IFF_VNET_HDR) {
-		struct virtio_net_hdr vnet_hdr;
+		struct virtio_net_hdr_rxhash vnet_hdr;
 		vnet_hdr_len = q->vnet_hdr_sz;
 		if ((len -= vnet_hdr_len) < 0)
 			return -EINVAL;
 
-		ret = macvtap_skb_to_vnet_hdr(skb, &vnet_hdr);
+		ret = macvtap_skb_to_vnet_hdr(skb, &vnet_hdr.hdr.hdr);
 		if (ret)
 			return ret;
 
-		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
+		vnet_hdr.rxhash = skb->rxhash;
+		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, q->vnet_hdr_sz))
 			return -EFAULT;
 	}
 
@@ -890,7 +891,8 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 		return ret;
 
 	case TUNGETFEATURES:
-		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR, up))
+		if (put_user(IFF_TAP | IFF_NO_PI | IFF_VNET_HDR | IFF_RXHASH,
+			     up))
 			return -EFAULT;
 		return 0;
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index afb11d1..7d22b4b 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -869,49 +869,55 @@ static ssize_t tun_put_user(struct tun_file *tfile,
 	}
 
 	if (tfile->flags & TUN_VNET_HDR) {
-		struct virtio_net_hdr gso = { 0 }; /* no info leak */
-		if ((len -= tfile->vnet_hdr_sz) < 0)
+		struct virtio_net_hdr_rxhash hdr;
+		struct virtio_net_hdr *gso = (struct virtio_net_hdr *)&hdr;
+
+		if ((len -= tfile->vnet_hdr_sz) < 0 ||
+		    tfile->vnet_hdr_sz > sizeof(struct virtio_net_hdr_rxhash))
 			return -EINVAL;
 
+		memset(&hdr, 0, sizeof(hdr));
 		if (skb_is_gso(skb)) {
 			struct skb_shared_info *sinfo = skb_shinfo(skb);
 
 			/* This is a hint as to how much should be linear. */
-			gso.hdr_len = skb_headlen(skb);
-			gso.gso_size = sinfo->gso_size;
+			gso->hdr_len = skb_headlen(skb);
+			gso->gso_size = sinfo->gso_size;
 			if (sinfo->gso_type & SKB_GSO_TCPV4)
-				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
+				gso->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 			else if (sinfo->gso_type & SKB_GSO_TCPV6)
-				gso.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
+				gso->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
 			else if (sinfo->gso_type & SKB_GSO_UDP)
-				gso.gso_type = VIRTIO_NET_HDR_GSO_UDP;
+				gso->gso_type = VIRTIO_NET_HDR_GSO_UDP;
 			else {
 				pr_err("unexpected GSO type: "
 				       "0x%x, gso_size %d, hdr_len %d\n",
-				       sinfo->gso_type, gso.gso_size,
-				       gso.hdr_len);
+				       sinfo->gso_type, gso->gso_size,
+				       gso->hdr_len);
 				print_hex_dump(KERN_ERR, "tun: ",
 					       DUMP_PREFIX_NONE,
 					       16, 1, skb->head,
-					       min((int)gso.hdr_len, 64), true);
+					       min((int)gso->hdr_len, 64),
+					       true);
 				WARN_ON_ONCE(1);
 				return -EINVAL;
 			}
 			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
-				gso.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
+				gso->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
 		} else
-			gso.gso_type = VIRTIO_NET_HDR_GSO_NONE;
+			gso->gso_type = VIRTIO_NET_HDR_GSO_NONE;
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			gso.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
-			gso.csum_start = skb_checksum_start_offset(skb);
-			gso.csum_offset = skb->csum_offset;
+			gso->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
+			gso->csum_start = skb_checksum_start_offset(skb);
+			gso->csum_offset = skb->csum_offset;
 		} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-			gso.flags = VIRTIO_NET_HDR_F_DATA_VALID;
+			gso->flags = VIRTIO_NET_HDR_F_DATA_VALID;
 		} /* else everything is zero */
 
-		if (unlikely(memcpy_toiovecend(iv, (void *)&gso, total,
-					       sizeof(gso))))
+		hdr.rxhash = skb_get_rxhash(skb);
+		if (unlikely(memcpy_toiovecend(iv, (void *)&hdr, total,
+					       tfile->vnet_hdr_sz)))
 			return -EFAULT;
 		total += tfile->vnet_hdr_sz;
 	}
@@ -1358,7 +1364,7 @@ static long __tun_chr_ioctl(struct file *file, unsigned int cmd,
 		 * This is needed because we never checked for invalid flags on
 		 * TUNSETIFF. */
 		return put_user(IFF_TUN | IFF_TAP | IFF_NO_PI | IFF_ONE_QUEUE |
-				IFF_VNET_HDR | IFF_MULTI_QUEUE,
+				IFF_VNET_HDR | IFF_MULTI_QUEUE | IFF_RXHASH,
 				(unsigned int __user*)argp);
 	}
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 157ee63..0d871f8 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -107,12 +107,16 @@ struct virtnet_info {
 
 	/* Host will merge rx buffers for big packets (shake it! shake it!) */
 	bool mergeable_rx_bufs;
+
+	/* Host will pass rxhash to us. */
+	bool has_rxhash;
 };
 
 struct skb_vnet_hdr {
 	union {
 		struct virtio_net_hdr hdr;
 		struct virtio_net_hdr_mrg_rxbuf mhdr;
+		struct virtio_net_hdr_rxhash rhdr;
 	};
 	unsigned int num_sg;
 };
@@ -205,7 +209,10 @@ static struct sk_buff *page_to_skb(struct receive_queue *rq,
 	hdr = skb_vnet_hdr(skb);
 
 	if (vi->mergeable_rx_bufs) {
-		hdr_len = sizeof hdr->mhdr;
+		if (vi->has_rxhash)
+			hdr_len = sizeof hdr->rhdr;
+		else
+			hdr_len = sizeof hdr->mhdr;
 		offset = hdr_len;
 	} else {
 		hdr_len = sizeof hdr->hdr;
@@ -376,6 +383,9 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		skb_shinfo(skb)->gso_segs = 0;
 	}
 
+	if (vi->has_rxhash)
+		skb->rxhash = hdr->rhdr.rxhash;
+
 	netif_receive_skb(skb);
 	return;
 
@@ -645,9 +655,12 @@ static int xmit_skb(struct virtnet_info *vi, struct sk_buff *skb,
 	hdr->mhdr.num_buffers = 0;
 
 	/* Encode metadata header at front. */
-	if (vi->mergeable_rx_bufs)
-		sg_set_buf(sg, &hdr->mhdr, sizeof hdr->mhdr);
-	else
+	if (vi->mergeable_rx_bufs) {
+		if (vi->has_rxhash)
+			sg_set_buf(sg, &hdr->rhdr, sizeof hdr->rhdr);
+		else
+			sg_set_buf(sg, &hdr->mhdr, sizeof hdr->mhdr);
+	} else
 		sg_set_buf(sg, &hdr->hdr, sizeof hdr->hdr);
 
 	hdr->num_sg = skb_to_sgvec(skb, sg + 1, 0, skb->len) + 1;
@@ -1338,8 +1351,12 @@ static int virtnet_probe(struct virtio_device *vdev)
 	if (virtio_has_feature(vdev, VIRTIO_NET_F_MRG_RXBUF))
 		vi->mergeable_rx_bufs = true;
 
+	if (virtio_has_feature(vdev, VIRTIO_NET_F_GUEST_RXHASH))
+		vi->has_rxhash = true;
+
 	/* Allocate/initialize the rx/tx queues, and invoke find_vqs */
 	err = virtnet_setup_vqs(vi);
+
 	if (err)
 		goto free_netdev;
 
@@ -1436,6 +1453,7 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ECN, VIRTIO_NET_F_GUEST_UFO,
 	VIRTIO_NET_F_MRG_RXBUF, VIRTIO_NET_F_STATUS, VIRTIO_NET_F_CTRL_VQ,
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN, VIRTIO_NET_F_MULTIQUEUE,
+	VIRTIO_NET_F_GUEST_RXHASH,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 882a51f..b2d6548 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -768,9 +768,13 @@ static int vhost_net_set_features(struct vhost_net *n, u64 features)
 	size_t vhost_hlen, sock_hlen, hdr_len;
 	int i;
 
-	hdr_len = (features & (1 << VIRTIO_NET_F_MRG_RXBUF)) ?
-			sizeof(struct virtio_net_hdr_mrg_rxbuf) :
-			sizeof(struct virtio_net_hdr);
+	if (features & (1 << VIRTIO_NET_F_MRG_RXBUF))
+		hdr_len = (features & (1 << VIRTIO_NET_F_GUEST_RXHASH)) ?
+			sizeof(struct virtio_net_hdr_rxhash) :
+			sizeof(struct virtio_net_hdr_mrg_rxbuf);
+	else
+		hdr_len = sizeof(struct virtio_net_hdr);
+
 	if (features & (1 << VHOST_NET_F_VIRTIO_NET_HDR)) {
 		/* vhost provides vnet_hdr */
 		vhost_hlen = hdr_len;
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index a801e28..4ad2d5f 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -115,7 +115,7 @@ struct vhost_virtqueue {
 	/* hdr is used to store the virtio header.
 	 * Since each iovec has >= 1 byte length, we never need more than
 	 * header length entries to store the header. */
-	struct iovec hdr[sizeof(struct virtio_net_hdr_mrg_rxbuf)];
+	struct iovec hdr[sizeof(struct virtio_net_hdr_rxhash)];
 	struct iovec *indirect;
 	size_t vhost_hlen;
 	size_t sock_hlen;
@@ -203,7 +203,8 @@ enum {
 			 (1ULL << VIRTIO_RING_F_EVENT_IDX) |
 			 (1ULL << VHOST_F_LOG_ALL) |
 			 (1ULL << VHOST_NET_F_VIRTIO_NET_HDR) |
-			 (1ULL << VIRTIO_NET_F_MRG_RXBUF),
+			 (1ULL << VIRTIO_NET_F_MRG_RXBUF) |
+			 (1ULL << VIRTIO_NET_F_GUEST_RXHASH) ,
 };
 
 static inline int vhost_has_feature(struct vhost_dev *dev, int bit)
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index d3f24d8..a1f6f3f 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -66,6 +66,7 @@
 #define IFF_VNET_HDR	0x4000
 #define IFF_TUN_EXCL	0x8000
 #define IFF_MULTI_QUEUE 0x0100
+#define IFF_RXHASH      0x0200
 
 /* Features for GSO (TUNSETOFFLOAD). */
 #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index c92b83f..2291317 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -50,6 +50,7 @@
 #define VIRTIO_NET_F_CTRL_VLAN	19	/* Control channel VLAN filtering */
 #define VIRTIO_NET_F_CTRL_RX_EXTRA 20	/* Extra RX mode control support */
 #define VIRTIO_NET_F_MULTIQUEUE	21	/* Device supports multiple TXQ/RXQ */
+#define VIRTIO_NET_F_GUEST_RXHASH 22    /* Guest can receive rxhash */
 
 #define VIRTIO_NET_S_LINK_UP	1	/* Link is up */
 
@@ -63,7 +64,7 @@ struct virtio_net_config {
 } __attribute__((packed));
 
 /* This is the first element of the scatter-gather list.  If you don't
- * specify GSO or CSUM features, you can simply ignore the header. */
+ * specify GSO, CSUM or HASH features, you can simply ignore the header. */
 struct virtio_net_hdr {
 #define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
 #define VIRTIO_NET_HDR_F_DATA_VALID	2	// Csum is valid
@@ -87,6 +88,13 @@ struct virtio_net_hdr_mrg_rxbuf {
 	__u16 num_buffers;	/* Number of merged rx buffers */
 };
 
+/* This is the version of the header to use when GUEST_RXHASH
+ * feature has been negotiated. */
+struct virtio_net_hdr_rxhash {
+	struct virtio_net_hdr_mrg_rxbuf hdr;
+	__u32 rxhash;
+};
+
 /*
  * Control virtqueue data structures
  *
