From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/3] virtio: Net header needs gso_hdr_len
Date: Tue, 15 Jan 2008 21:43:37 +1100
Message-ID: <200801152143.37112.rusty@rustcorp.com.au>
References: <200801152141.56172.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54920 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400AbYAOKoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jan 2008 05:44:11 -0500
In-Reply-To: <200801152141.56172.rusty@rustcorp.com.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's far easier to deal with GSO if we don't have to parse the packet
to figure out the header length.  Add the field to the virtio_net_hdr
struct (and fix the spaces that somehow crept in there).

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c   |    4 +++-
 include/linux/virtio_net.h |   11 ++++++-----
 2 files changed, 9 insertions(+), 6 deletions(-)

diff -r 24ef33a4ab14 drivers/net/virtio_net.c
--- a/drivers/net/virtio_net.c	Tue Jan 15 16:59:58 2008 +1100
+++ b/drivers/net/virtio_net.c	Tue Jan 15 21:21:40 2008 +1100
@@ -126,6 +126,7 @@ static void receive_skb(struct net_devic
 		/* Header must be checked, and gso_segs computed. */
 		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
 		skb_shinfo(skb)->gso_segs = 0;
+		skb_set_transport_header(skb, hdr->gso_hdr_len);
 	}
 
 	netif_receive_skb(skb);
@@ -247,6 +248,7 @@ static int start_xmit(struct sk_buff *sk
 	}
 
 	if (skb_is_gso(skb)) {
+		hdr->gso_hdr_len = skb_transport_header(skb) - skb->data;
 		hdr->gso_size = skb_shinfo(skb)->gso_size;
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCP_ECN)
 			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4_ECN;
@@ -260,7 +262,7 @@ static int start_xmit(struct sk_buff *sk
 			BUG();
 	} else {
 		hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
-		hdr->gso_size = 0;
+		hdr->gso_size = hdr->gso_hdr_len = 0;
 	}
 
 	vnet_hdr_to_sg(sg, skb);
diff -r 24ef33a4ab14 include/linux/virtio_net.h
--- a/include/linux/virtio_net.h	Tue Jan 15 16:59:58 2008 +1100
+++ b/include/linux/virtio_net.h	Tue Jan 15 21:21:40 2008 +1100
@@ -24,16 +24,17 @@ struct virtio_net_hdr
 struct virtio_net_hdr
 {
 #define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
-      __u8 flags;
+	__u8 flags;
 #define VIRTIO_NET_HDR_GSO_NONE		0	// Not a GSO frame
 #define VIRTIO_NET_HDR_GSO_TCPV4	1	// GSO frame, IPv4 TCP (TSO)
 /* FIXME: Do we need this?  If they said they can handle ECN, do they care? */
 #define VIRTIO_NET_HDR_GSO_TCPV4_ECN	2	// GSO frame, IPv4 TCP w/ ECN
 #define VIRTIO_NET_HDR_GSO_UDP		3	// GSO frame, IPv4 UDP (UFO)
 #define VIRTIO_NET_HDR_GSO_TCPV6	4	// GSO frame, IPv6 TCP
-      __u8 gso_type;
-      __u16 gso_size;
-      __u16 csum_start;
-      __u16 csum_offset;
+	__u8 gso_type;
+	__u16 gso_hdr_len;	/* Ethernet + IP + tcp/udp hdrs */
+	__u16 gso_size;		/* Bytes to append to gso_hdr_len per frame */
+	__u16 csum_start;	/* Position to start checksumming from */
+	__u16 csum_offset;	/* Offset after that to place checksum */
 };
 #endif /* _LINUX_VIRTIO_NET_H */
