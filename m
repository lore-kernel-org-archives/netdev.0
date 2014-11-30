From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v7 46/46] af_packet: virtio 1.0 stubs
Date: Sun, 30 Nov 2014 17:13:08 +0200
Message-ID: <1417359787-10138-47-git-send-email-mst@redhat.com>
References: <1417359787-10138-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	Daniel Borkmann <dborkman@redhat.com>,
	Atzm Watanabe <atzm@stratosphere.co.jp>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417359787-10138-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This merely fixes sparse warnings, without actually
adding support for the new APIs.

Still working out the best way to enable the new
functionality.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/packet/af_packet.c | 35 ++++++++++++++++++++++-------------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 87d20f4..d4a877e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2444,13 +2444,15 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 			goto out_unlock;
 
 		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
-		    (vnet_hdr.csum_start + vnet_hdr.csum_offset + 2 >
-		      vnet_hdr.hdr_len))
-			vnet_hdr.hdr_len = vnet_hdr.csum_start +
-						 vnet_hdr.csum_offset + 2;
+		    (__virtio16_to_cpu(false, vnet_hdr.csum_start) +
+		     __virtio16_to_cpu(false, vnet_hdr.csum_offset) + 2 >
+		      __virtio16_to_cpu(false, vnet_hdr.hdr_len)))
+			vnet_hdr.hdr_len = __cpu_to_virtio16(false,
+				 __virtio16_to_cpu(false, vnet_hdr.csum_start) +
+				__virtio16_to_cpu(false, vnet_hdr.csum_offset) + 2);
 
 		err = -EINVAL;
-		if (vnet_hdr.hdr_len > len)
+		if (__virtio16_to_cpu(false, vnet_hdr.hdr_len) > len)
 			goto out_unlock;
 
 		if (vnet_hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
@@ -2492,7 +2494,8 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 	err = -ENOBUFS;
 	hlen = LL_RESERVED_SPACE(dev);
 	tlen = dev->needed_tailroom;
-	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len, vnet_hdr.hdr_len,
+	skb = packet_alloc_skb(sk, hlen + tlen, hlen, len,
+			       __virtio16_to_cpu(false, vnet_hdr.hdr_len),
 			       msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto out_unlock;
@@ -2534,14 +2537,16 @@ static int packet_snd(struct socket *sock, struct msghdr *msg, size_t len)
 
 	if (po->has_vnet_hdr) {
 		if (vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) {
-			if (!skb_partial_csum_set(skb, vnet_hdr.csum_start,
-						  vnet_hdr.csum_offset)) {
+			u16 s = __virtio16_to_cpu(false, vnet_hdr.csum_start);
+			u16 o = __virtio16_to_cpu(false, vnet_hdr.csum_offset);
+			if (!skb_partial_csum_set(skb, s, o)) {
 				err = -EINVAL;
 				goto out_free;
 			}
 		}
 
-		skb_shinfo(skb)->gso_size = vnet_hdr.gso_size;
+		skb_shinfo(skb)->gso_size =
+			__virtio16_to_cpu(false, vnet_hdr.gso_size);
 		skb_shinfo(skb)->gso_type = gso_type;
 
 		/* Header must be checked, and gso_segs computed. */
@@ -2912,8 +2917,10 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 			struct skb_shared_info *sinfo = skb_shinfo(skb);
 
 			/* This is a hint as to how much should be linear. */
-			vnet_hdr.hdr_len = skb_headlen(skb);
-			vnet_hdr.gso_size = sinfo->gso_size;
+			vnet_hdr.hdr_len =
+				__cpu_to_virtio16(false, skb_headlen(skb));
+			vnet_hdr.gso_size =
+				__cpu_to_virtio16(false, sinfo->gso_size);
 			if (sinfo->gso_type & SKB_GSO_TCPV4)
 				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 			else if (sinfo->gso_type & SKB_GSO_TCPV6)
@@ -2931,8 +2938,10 @@ static int packet_recvmsg(struct kiocb *iocb, struct socket *sock,
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			vnet_hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
-			vnet_hdr.csum_start = skb_checksum_start_offset(skb);
-			vnet_hdr.csum_offset = skb->csum_offset;
+			vnet_hdr.csum_start = __cpu_to_virtio16(false,
+					  skb_checksum_start_offset(skb));
+			vnet_hdr.csum_offset = __cpu_to_virtio16(false,
+							 skb->csum_offset);
 		} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 			vnet_hdr.flags = VIRTIO_NET_HDR_F_DATA_VALID;
 		} /* else everything is zero */
-- 
MST
