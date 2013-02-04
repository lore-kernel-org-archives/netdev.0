From: Pravin B Shelar <pshelar@nicira.com>
Subject: [RFC PATCH net-next] net: Fix possible wrong checksum generation.
Date: Mon,  4 Feb 2013 15:24:10 -0800
Message-ID: <1360020250-1770-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	bhutchings@solarflare.com, Pravin B Shelar <pshelar@nicira.com>
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:33886 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754629Ab3BDXXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 18:23:10 -0500
Received: by mail-ve0-f197.google.com with SMTP id 15so4691405vea.0
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 15:23:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses same logic that Eric Dumazet used in commit
cef401de7be8c4e (net: fix possible wrong checksum generation).
Patch introduces new flag SKBTX_SHARED_FRAG if at least one frag
can be modified by the user. but SKBTX_SHARED_FRAG flag is kept
in skb shared info tx_flags rather than gso_type.

tx_flags is better compared to gso_type since we can have skb with
shared frag without gso packet. It does not link SHARED_FRAG to
GSO, So there is no need to define netdev feature for this.
As a result of this change TSO is fixed.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/macvtap.c    |    4 ++--
 drivers/net/tun.c        |   13 +++++--------
 drivers/net/virtio_net.c |   13 +++++--------
 include/linux/skbuff.h   |   17 +++++++++--------
 net/core/skbuff.c        |    5 ++---
 net/ipv4/af_inet.c       |    1 -
 net/ipv4/ip_output.c     |    1 +
 net/ipv4/tcp.c           |    4 +---
 net/ipv4/tcp_input.c     |    4 ++--
 net/ipv4/tcp_output.c    |    4 ++--
 net/ipv6/ip6_offload.c   |    1 -
 11 files changed, 29 insertions(+), 38 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index b181dfb..9724301 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -543,7 +543,6 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		skb->data_len += len;
 		skb->len += len;
 		skb->truesize += truesize;
-		skb_shinfo(skb)->gso_type |= SKB_GSO_SHARED_FRAG;
 		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
 		while (len) {
 			int off = base & ~PAGE_MASK;
@@ -599,7 +598,7 @@ static int macvtap_skb_from_vnet_hdr(struct sk_buff *skb,
 
 	if (vnet_hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
 		skb_shinfo(skb)->gso_size = vnet_hdr->gso_size;
-		skb_shinfo(skb)->gso_type |= gso_type;
+		skb_shinfo(skb)->gso_type = gso_type;
 
 		/* Header must be checked, and gso_segs computed. */
 		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
@@ -743,6 +742,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	if (zerocopy) {
 		skb_shinfo(skb)->destructor_arg = m->msg_control;
 		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
 	}
 	if (vlan)
 		macvlan_start_xmit(skb, vlan->dev);
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8d208dd..0a0b850 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1009,7 +1009,6 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		skb->data_len += len;
 		skb->len += len;
 		skb->truesize += truesize;
-		skb_shinfo(skb)->gso_type |= SKB_GSO_SHARED_FRAG;
 		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
 		while (len) {
 			int off = base & ~PAGE_MASK;
@@ -1155,18 +1154,16 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	if (gso.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		unsigned short gso_type = 0;
-
 		pr_debug("GSO!\n");
 		switch (gso.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
 		case VIRTIO_NET_HDR_GSO_TCPV4:
-			gso_type = SKB_GSO_TCPV4;
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
 			break;
 		case VIRTIO_NET_HDR_GSO_TCPV6:
-			gso_type = SKB_GSO_TCPV6;
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
-			gso_type = SKB_GSO_UDP;
+			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 			break;
 		default:
 			tun->dev->stats.rx_frame_errors++;
@@ -1175,10 +1172,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		}
 
 		if (gso.gso_type & VIRTIO_NET_HDR_GSO_ECN)
-			gso_type |= SKB_GSO_TCP_ECN;
+			skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
 
 		skb_shinfo(skb)->gso_size = gso.gso_size;
-		skb_shinfo(skb)->gso_type |= gso_type;
 		if (skb_shinfo(skb)->gso_size == 0) {
 			tun->dev->stats.rx_frame_errors++;
 			kfree_skb(skb);
@@ -1194,6 +1190,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	if (zerocopy) {
 		skb_shinfo(skb)->destructor_arg = msg_control;
 		skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
+		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
 	}
 
 	skb_reset_network_header(skb);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 381a2d8..192c91c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -227,7 +227,7 @@ static void set_skb_frag(struct sk_buff *skb, struct page *page,
 	skb->len += size;
 	skb->truesize += PAGE_SIZE;
 	skb_shinfo(skb)->nr_frags++;
-	skb_shinfo(skb)->gso_type |= SKB_GSO_SHARED_FRAG;
+	skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
 	*len -= size;
 }
 
@@ -387,18 +387,16 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		 ntohs(skb->protocol), skb->len, skb->pkt_type);
 
 	if (hdr->hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
-		unsigned short gso_type = 0;
-
 		pr_debug("GSO!\n");
 		switch (hdr->hdr.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
 		case VIRTIO_NET_HDR_GSO_TCPV4:
-			gso_type = SKB_GSO_TCPV4;
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
-			gso_type = SKB_GSO_UDP;
+			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 			break;
 		case VIRTIO_NET_HDR_GSO_TCPV6:
-			gso_type = SKB_GSO_TCPV6;
+			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
 			break;
 		default:
 			net_warn_ratelimited("%s: bad gso type %u.\n",
@@ -407,7 +405,7 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		}
 
 		if (hdr->hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
-			gso_type |= SKB_GSO_TCP_ECN;
+			skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
 
 		skb_shinfo(skb)->gso_size = hdr->hdr.gso_size;
 		if (skb_shinfo(skb)->gso_size == 0) {
@@ -415,7 +413,6 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 			goto frame_err;
 		}
 
-		skb_shinfo(skb)->gso_type |= gso_type;
 		/* Header must be checked, and gso_segs computed. */
 		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
 		skb_shinfo(skb)->gso_segs = 0;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0259b71..fd28469 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -230,6 +230,13 @@ enum {
 
 	/* generate wifi status information (where possible) */
 	SKBTX_WIFI_STATUS = 1 << 4,
+
+	/* This indicates at least one fragment might be overwritten
+	 * (as in vmsplice(), sendfile() ...)
+	 * If we need to compute a TX checksum, we'll need to copy
+	 * all frags to avoid possible bad checksum
+	 */
+	SKBTX_SHARED_FRAG = 1 << 5,
 };
 
 /*
@@ -307,13 +314,6 @@ enum {
 	SKB_GSO_TCPV6 = 1 << 4,
 
 	SKB_GSO_FCOE = 1 << 5,
-
-	/* This indicates at least one fragment might be overwritten
-	 * (as in vmsplice(), sendfile() ...)
-	 * If we need to compute a TX checksum, we'll need to copy
-	 * all frags to avoid possible bad checksum
-	 */
-	SKB_GSO_SHARED_FRAG = 1 << 6,
 };
 
 #if BITS_PER_LONG > 32
@@ -2216,7 +2216,8 @@ static inline int skb_linearize(struct sk_buff *skb)
  */
 static inline bool skb_has_shared_frag(const struct sk_buff *skb)
 {
-	return skb_shinfo(skb)->gso_type & SKB_GSO_SHARED_FRAG;
+	return (skb_is_nonlinear(skb) &&
+		skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG);
 }
 
 /**
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bddc1dd..cbab8d8 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2340,8 +2340,7 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
 {
 	int pos = skb_headlen(skb);
 
-	skb_shinfo(skb1)->gso_type = skb_shinfo(skb)->gso_type;
-
+	skb_shinfo(skb)->tx_flags = skb_shinfo(skb1)->tx_flags & SKBTX_SHARED_FRAG;
 	if (len < pos)	/* Split line is inside header. */
 		skb_split_inside_header(skb, skb1, len, pos);
 	else		/* Second chunk has no header, nothing to copy. */
@@ -2847,7 +2846,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		skb_copy_from_linear_data_offset(skb, offset,
 						 skb_put(nskb, hsize), hsize);
 
-		skb_shinfo(nskb)->gso_type = skb_shinfo(skb)->gso_type;
+		skb_shinfo(nskb)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
 
 		while (pos < offset + len && i < nfrags) {
 			*frag = skb_shinfo(skb)->frags[i];
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 49ddca3..4b70539 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1306,7 +1306,6 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
-		       SKB_GSO_SHARED_FRAG |
 		       0)))
 		goto out;
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 3e98ed2..5e12dca 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -598,6 +598,7 @@ slow_path:
 	/* for offloaded checksums cleanup checksum before fragmentation */
 	if ((skb->ip_summed == CHECKSUM_PARTIAL) && skb_checksum_help(skb))
 		goto fail;
+	iph = ip_hdr(skb);
 
 	left = skb->len - hlen;		/* Space per frame */
 	ptr = hlen;		/* Where to start from */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3ec1f69..aab6e73 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -895,8 +895,7 @@ new_segment:
 			get_page(page);
 			skb_fill_page_desc(skb, i, page, offset, copy);
 		}
-
-		skb_shinfo(skb)->gso_type |= SKB_GSO_SHARED_FRAG;
+		skb_shinfo(skb)->tx_flags |= SKBTX_SHARED_FRAG;
 
 		skb->len += copy;
 		skb->data_len += copy;
@@ -3034,7 +3033,6 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 			       SKB_GSO_DODGY |
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
-			       SKB_GSO_SHARED_FRAG |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
 			goto out;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 492c7cf..0905997 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1240,13 +1240,13 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	 */
 	if (!skb_shinfo(prev)->gso_size) {
 		skb_shinfo(prev)->gso_size = mss;
-		skb_shinfo(prev)->gso_type |= sk->sk_gso_type;
+		skb_shinfo(prev)->gso_type = sk->sk_gso_type;
 	}
 
 	/* CHECKME: To clear or not to clear? Mimics normal skb currently */
 	if (skb_shinfo(skb)->gso_segs <= 1) {
 		skb_shinfo(skb)->gso_size = 0;
-		skb_shinfo(skb)->gso_type &= SKB_GSO_SHARED_FRAG;
+		skb_shinfo(skb)->gso_type = 0;
 	}
 
 	/* Difference in this won't matter, both ACKed by the same cumul. ACK */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 367e2ec..667a6ad 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1133,7 +1133,6 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 				 unsigned int mss_now)
 {
-	skb_shinfo(skb)->gso_type &= SKB_GSO_SHARED_FRAG;
 	if (skb->len <= mss_now || !sk_can_gso(sk) ||
 	    skb->ip_summed == CHECKSUM_NONE) {
 		/* Avoid the costly divide in the normal
@@ -1141,10 +1140,11 @@ static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 		 */
 		skb_shinfo(skb)->gso_segs = 1;
 		skb_shinfo(skb)->gso_size = 0;
+		skb_shinfo(skb)->gso_type = 0;
 	} else {
 		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss_now);
 		skb_shinfo(skb)->gso_size = mss_now;
-		skb_shinfo(skb)->gso_type |= sk->sk_gso_type;
+		skb_shinfo(skb)->gso_type = sk->sk_gso_type;
 	}
 }
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index d141fc3..f26f0da 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -100,7 +100,6 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_TCPV6 |
-		       SKB_GSO_SHARED_FRAG |
 		       0)))
 		goto out;
 
-- 
1.7.10
