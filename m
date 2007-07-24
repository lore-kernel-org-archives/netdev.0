From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] virtio_net.c gso & feature support
Date: Tue, 24 Jul 2007 21:56:02 +1000
Message-ID: <1185278162.1803.339.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Christian Borntraeger <borntraeger@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: virtualization <virtualization@lists.linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46493 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757913AbXGXL4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 07:56:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Feedback welcome, as always!

(There's been talk of a virtualization git tree, in which case there'll
be a decent home for these patches soon).

Cheers,
Rusty.
==
Add feature and GSO support to virtio net driver.

If you don't do GSO, you can simply ignore the first sg element of
every outgoing packet, and tack a dummy one on every incoming.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c   |  130 ++++++++++++++++++++++++++++++++++++++++----
 include/linux/virtio_net.h |   25 +++++++-
 2 files changed, 143 insertions(+), 12 deletions(-)

===================================================================
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -16,12 +16,13 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
-//#define DEBUG
+#define DEBUG
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/module.h>
 #include <linux/virtio.h>
 #include <linux/scatterlist.h>
+#include <linux/virtio_net.h>
 
 /* FIXME: Make dynamic */
 #define MAX_PACKET_LEN (ETH_HLEN+ETH_DATA_LEN)
@@ -40,6 +41,18 @@ struct virtnet_info
 	struct sk_buff_head send;
 };
 
+static inline struct virtio_net_hdr *skb_vnet_hdr(struct sk_buff *skb)
+{
+	return (struct virtio_net_hdr *)skb->cb;
+}
+
+static void vnet_hdr_to_sg(struct scatterlist *sg, struct sk_buff *skb)
+{
+	sg->page = virt_to_page(skb_vnet_hdr(skb));
+	sg->offset = offset_in_page(skb_vnet_hdr(skb));
+	sg->length = sizeof(struct virtio_net_hdr);
+}
+
 static bool skb_xmit_done(struct virtqueue *vq)
 {
 	struct virtnet_info *vi = vq->priv;
@@ -52,12 +65,14 @@ static void receive_skb(struct net_devic
 static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 			unsigned len)
 {
-	if (unlikely(len < ETH_HLEN)) {
+	struct virtio_net_hdr *hdr = skb_vnet_hdr(skb);
+
+	if (unlikely(len < sizeof(struct virtio_net_hdr) + ETH_HLEN)) {
 		pr_debug("%s: short packet %i\n", dev->name, len);
 		dev->stats.rx_length_errors++;
-		dev_kfree_skb(skb);
-		return;
-	}
+		goto drop;
+	}
+	len -= sizeof(struct virtio_net_hdr);
 	BUG_ON(len > MAX_PACKET_LEN);
 
 	skb_trim(skb, len);
@@ -66,13 +81,70 @@ static void receive_skb(struct net_devic
 		 ntohs(skb->protocol), skb->len, skb->pkt_type);
 	dev->stats.rx_bytes += skb->len;
 	dev->stats.rx_packets++;
+
+	if (hdr->flags & VIRTIO_NET_F_NEEDS_CSUM) {
+		pr_debug("Needs csum!\n");
+		skb->ip_summed = CHECKSUM_PARTIAL;
+		skb->csum_start = hdr->csum_start;
+		skb->csum_offset = hdr->csum_offset;
+		if (skb->csum_start > skb->len - 2
+		    || skb->csum_offset > skb->len - 2) {
+			if (net_ratelimit())
+				printk(KERN_WARNING "%s: csum=%u/%u len=%u\n",
+				       dev->name, skb->csum_start,
+				       skb->csum_offset, skb->len);
+			goto frame_err;
+		}
+	}
+
+	if (hdr->gso_type != VIRTIO_NET_GSO_NONE) {
+		pr_debug("GSO!\n");
+		switch (hdr->gso_type) {
+		case VIRTIO_NET_GSO_TCP:
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+			break;
+		case VIRTIO_NET_GSO_TCP_ECN:
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCP_ECN;
+			break;
+		case VIRTIO_NET_GSO_UDP:
+			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+			break;
+		case VIRTIO_NET_GSO_TCPV6:
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+			break;
+		default:
+			if (net_ratelimit())
+				printk(KERN_WARNING "%s: bad gso type %u.\n",
+				       dev->name, hdr->gso_type);
+			goto frame_err;
+		}
+
+		skb_shinfo(skb)->gso_size = hdr->gso_size;
+		if (skb_shinfo(skb)->gso_size == 0) {
+			if (net_ratelimit())
+				printk(KERN_WARNING "%s: zero gso size.\n",
+				       dev->name);
+			goto frame_err;
+		}
+
+		/* Header must be checked, and gso_segs computed. */
+		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
+		skb_shinfo(skb)->gso_segs = 0;
+	}
+
 	netif_receive_skb(skb);
+	return;
+
+frame_err:
+	dev->stats.rx_frame_errors++;
+drop:
+	dev_kfree_skb(skb);
 }
 
 static void try_fill_recv(struct virtnet_info *vi)
 {
 	struct sk_buff *skb;
-	struct scatterlist sg[MAX_SKB_FRAGS];
+	struct scatterlist sg[1+MAX_SKB_FRAGS];
 	int num, err;
 
 	for (;;) {
@@ -81,7 +153,8 @@ static void try_fill_recv(struct virtnet
 			break;
 
 		skb_put(skb, MAX_PACKET_LEN);
-		num = skb_to_sgvec(skb, sg, 0, skb->len);
+		vnet_hdr_to_sg(sg, skb);
+		num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 		skb_queue_head(&vi->recv, skb);
 
 		err = vi->vq_recv->ops->add_buf(vi->vq_recv, sg, 0, num, skb);
@@ -161,7 +234,8 @@ static int start_xmit(struct sk_buff *sk
 {
 	struct virtnet_info *vi = netdev_priv(dev);
 	int num, err;
-	struct scatterlist sg[MAX_SKB_FRAGS];
+	struct scatterlist sg[1+MAX_SKB_FRAGS];
+	struct virtio_net_hdr *hdr;
 	const unsigned char *dest = ((struct ethhdr *)skb->data)->h_dest;
 
 	pr_debug("%s: xmit %p %02x:%02x:%02x:%02x:%02x:%02x\n",
@@ -170,7 +244,41 @@ static int start_xmit(struct sk_buff *sk
 
 	free_old_xmit_skbs(vi);
 
-	num = skb_to_sgvec(skb, sg, 0, skb->len);
+	/* Encode metadata header at front. */
+	hdr = skb_vnet_hdr(skb);
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		hdr->flags = VIRTIO_NET_F_NEEDS_CSUM;
+		hdr->csum_start = skb->csum_start - skb_headroom(skb);
+		hdr->csum_offset = skb->csum_offset;
+	} else {
+		hdr->flags = 0;
+		hdr->csum_offset = hdr->csum_start = 0;
+	}
+
+	if (skb_is_gso(skb)) {
+		printk("xmit: gso size %u len %u (%u/%u/%u)\n",
+		       skb_shinfo(skb)->gso_size, skb->len,
+		       skb_transport_header(skb) - skb->head,
+		       skb_network_header(skb) - skb->head,
+		       skb->data - skb->head);
+		hdr->gso_size = skb_shinfo(skb)->gso_size;
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCP_ECN)
+			hdr->gso_type = VIRTIO_NET_GSO_TCP_ECN;
+		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+			hdr->gso_type = VIRTIO_NET_GSO_TCP;
+		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+			hdr->gso_type = VIRTIO_NET_GSO_TCPV6;
+		else if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
+			hdr->gso_type = VIRTIO_NET_GSO_UDP;
+		else
+			BUG();
+	} else {
+		hdr->gso_type = VIRTIO_NET_GSO_NONE;
+		hdr->gso_size = 0;
+	}
+
+	vnet_hdr_to_sg(sg, skb);
+	num = skb_to_sgvec(skb, sg+1, 0, skb->len) + 1;
 	__skb_queue_head(&vi->send, skb);
 	err = vi->vq_send->ops->add_buf(vi->vq_send, sg, num, 0, skb);
 	if (err) {
@@ -220,7 +328,8 @@ struct net_device *virtnet_probe(struct 
 struct net_device *virtnet_probe(struct virtqueue *vq_recv,
 				 struct virtqueue *vq_send,
 				 struct device *device,
-				 const u8 mac[ETH_ALEN])
+				 const u8 mac[ETH_ALEN],
+				 unsigned long features)
 {
 	int err;
 	struct net_device *dev;
@@ -239,6 +348,7 @@ struct net_device *virtnet_probe(struct 
 	dev->poll = virtnet_poll;
 	dev->hard_start_xmit = start_xmit;
 	dev->weight = 16;
+	dev->features = features;
 	SET_NETDEV_DEV(dev, device);
 
 	vi = netdev_priv(dev);
===================================================================
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -1,6 +1,26 @@
 #ifndef _LINUX_VIRTIO_NET_H
 #define _LINUX_VIRTIO_NET_H
 #include <linux/types.h>
+
+/* This is the first element of the scatter-gather list.
+ * If you don't specify GSO or CSUM features, you can simply ignore the
+ * header. */
+struct virtio_net_hdr
+{
+#define VIRTIO_NET_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
+      __u16 flags;
+#define VIRTIO_NET_GSO_NONE	0	// Not a GSO frame
+#define VIRTIO_NET_GSO_TCP	1	// GSO frame, IPv4 TCP (TSO)
+#define VIRTIO_NET_GSO_TCP_ECN	2	// GSO frame, IPv4 TCP w/ ECN
+#define VIRTIO_NET_GSO_UDP	3	// GSO frame, IPv4 UDP (UFO)
+#define VIRTIO_NET_GSO_TCPV6	4	// GSO frame, IPv6 TCP
+      __u16 gso_type;
+      __u16 gso_size;
+      __u16 csum_start;
+      __u16 csum_offset;
+};
+
+#ifdef __KERNEL__
 #include <linux/etherdevice.h>
 struct device;
 struct net_device;
@@ -9,7 +29,8 @@ struct net_device *virtnet_probe(struct 
 struct net_device *virtnet_probe(struct virtqueue *vq_recv,
 				 struct virtqueue *vq_send,
 				 struct device *dev,
-				 const u8 mac[ETH_ALEN]);
+				 const u8 mac[ETH_ALEN],
+				 unsigned long features);
 void virtnet_remove(struct net_device *dev);
-
+#endif /* __KERNEL__ */
 #endif /* _LINUX_VIRTIO_NET_H */


