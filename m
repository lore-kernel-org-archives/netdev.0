From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/3] Cleanup and simplify virtnet header
Date: Thu, 24 Jan 2008 01:07:38 +1100
Message-ID: <200801240107.38929.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60214 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097AbYAWOXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 09:23:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Turn GSO on virtio net into an all-or-nothing (keep checksumming
   separate).  Having multiple bits is a pain: if you can't support something
   you should handle it in software, which is still a performance win.

2) Make VIRTIO_NET_HDR_GSO_ECN a flag in the header, so it can apply to
   IPv6 or v4.

3) Rename VIRTIO_NET_F_NO_CSUM to VIRTIO_NET_F_CSUM (ie. means we do
   checksumming).

4) Add csum and gso params to virtio_net to allow more testing.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c   |   32 ++++++++++++++++----------------
 include/linux/virtio_net.h |   12 ++++--------
 2 files changed, 20 insertions(+), 24 deletions(-)

diff -r 4fb788b18cf8 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Wed Jan 23 13:07:59 2008 +1100
+++ b/drivers/net/virtio_net.c	Wed Jan 23 18:46:05 2008 +1100
@@ -26,6 +26,10 @@
 
 static int napi_weight = 128;
 module_param(napi_weight, int, 0444);
+
+static int csum = 1, gso = 1;
+module_param(csum, int, 0444);
+module_param(gso, int, 0444);
 
 MODULE_LICENSE("GPL");
 
@@ -95,12 +99,9 @@ static void receive_skb(struct net_devic
 
 	if (hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
 		pr_debug("GSO!\n");
-		switch (hdr->gso_type) {
+		switch (hdr->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
 		case VIRTIO_NET_HDR_GSO_TCPV4:
 			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
-			break;
-		case VIRTIO_NET_HDR_GSO_TCPV4_ECN:
-			skb_shinfo(skb)->gso_type = SKB_GSO_TCP_ECN;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
 			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
@@ -114,6 +115,9 @@ static void receive_skb(struct net_devic
 				       dev->name, hdr->gso_type);
 			goto frame_err;
 		}
+
+		if (hdr->gso_type & VIRTIO_NET_HDR_GSO_ECN)
+			skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
 
 		skb_shinfo(skb)->gso_size = hdr->gso_size;
 		if (skb_shinfo(skb)->gso_size == 0) {
@@ -249,9 +253,7 @@ static int start_xmit(struct sk_buff *sk
 	if (skb_is_gso(skb)) {
 		hdr->hdr_len = skb_transport_header(skb) - skb->data;
 		hdr->gso_size = skb_shinfo(skb)->gso_size;
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCP_ECN)
-			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4_ECN;
-		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
 			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
 			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
@@ -259,6 +261,8 @@ static int start_xmit(struct sk_buff *sk
 			hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
 		else
 			BUG();
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCP_ECN)
+			hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
 	} else {
 		hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
 		hdr->gso_size = hdr->hdr_len = 0;
@@ -354,17 +358,13 @@ static int virtnet_probe(struct virtio_d
 	SET_NETDEV_DEV(dev, &vdev->dev);
 
 	/* Do we support "hardware" checksums? */
-	if (vdev->config->feature(vdev, VIRTIO_NET_F_NO_CSUM)) {
+	if (csum && vdev->config->feature(vdev, VIRTIO_NET_F_CSUM)) {
 		/* This opens up the world of extra features. */
 		dev->features |= NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
-		if (vdev->config->feature(vdev, VIRTIO_NET_F_TSO4))
-			dev->features |= NETIF_F_TSO;
-		if (vdev->config->feature(vdev, VIRTIO_NET_F_UFO))
-			dev->features |= NETIF_F_UFO;
-		if (vdev->config->feature(vdev, VIRTIO_NET_F_TSO4_ECN))
-			dev->features |= NETIF_F_TSO_ECN;
-		if (vdev->config->feature(vdev, VIRTIO_NET_F_TSO6))
-			dev->features |= NETIF_F_TSO6;
+		if (gso && vdev->config->feature(vdev, VIRTIO_NET_F_GSO)) {
+			dev->features |= NETIF_F_TSO | NETIF_F_UFO
+				| NETIF_F_TSO_ECN | NETIF_F_TSO6;
+		}
 	}
 
 	/* Configuration may specify what MAC to use.  Otherwise random. */
diff -r 4fb788b18cf8 include/linux/virtio_net.h
--- a/include/linux/virtio_net.h	Wed Jan 23 13:07:59 2008 +1100
+++ b/include/linux/virtio_net.h	Wed Jan 23 18:46:05 2008 +1100
@@ -6,12 +6,9 @@
 #define VIRTIO_ID_NET	1
 
 /* The feature bitmap for virtio net */
-#define VIRTIO_NET_F_NO_CSUM	0
-#define VIRTIO_NET_F_TSO4	1
-#define VIRTIO_NET_F_UFO	2
-#define VIRTIO_NET_F_TSO4_ECN	3
-#define VIRTIO_NET_F_TSO6	4
-#define VIRTIO_NET_F_MAC	5
+#define VIRTIO_NET_F_CSUM	0	/* Can handle pkts w/ partial csum */
+#define VIRTIO_NET_F_MAC	5	/* Host has given MAC address. */
+#define VIRTIO_NET_F_GSO	6	/* Can handle pkts w/ any GSO type */
 
 struct virtio_net_config
 {
@@ -27,10 +24,9 @@ struct virtio_net_hdr
 	__u8 flags;
 #define VIRTIO_NET_HDR_GSO_NONE		0	// Not a GSO frame
 #define VIRTIO_NET_HDR_GSO_TCPV4	1	// GSO frame, IPv4 TCP (TSO)
-/* FIXME: Do we need this?  If they said they can handle ECN, do they care? */
-#define VIRTIO_NET_HDR_GSO_TCPV4_ECN	2	// GSO frame, IPv4 TCP w/ ECN
 #define VIRTIO_NET_HDR_GSO_UDP		3	// GSO frame, IPv4 UDP (UFO)
 #define VIRTIO_NET_HDR_GSO_TCPV6	4	// GSO frame, IPv6 TCP
+#define VIRTIO_NET_HDR_GSO_ECN		0x80	// TCP has ECN set
 	__u8 gso_type;
 	__u16 hdr_len;		/* Ethernet + IP + tcp/udp hdrs */
 	__u16 gso_size;		/* Bytes to append to gso_hdr_len per frame */
