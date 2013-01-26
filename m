From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: fix possible wrong checksum generation
Date: Fri, 25 Jan 2013 22:34:37 -0800
Message-ID: <1359182077.5222.132.camel@edumazet-glaptop>
References: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
	 <1359070199.12374.2557.camel@edumazet-glaptop>
	 <CALnjE+rbqCgRwxr1TtFH92vKSJoTRhBP50f+jQmgWB9LanQhYw@mail.gmail.com>
	 <1359077664.12374.2887.camel@edumazet-glaptop>
	 <CALnjE+p0m7E7vH20M9mXuNiFG4iUpAsoyjW7ugez3ch=RdkVcw@mail.gmail.com>
	 <1359143538.12374.3379.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:50009 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945Ab3AZGel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2013 01:34:41 -0500
Received: by mail-pb0-f42.google.com with SMTP id rp2so606272pbb.29
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 22:34:40 -0800 (PST)
In-Reply-To: <1359143538.12374.3379.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Pravin Shelar mentioned that GSO could potentially generate
wrong TX checksum if skb has fragments that are overwritten
by the user between the checksum computation and transmit.

He suggested to linearize skbs but this extra copy can be
avoided for normal tcp skbs cooked by tcp_sendmsg().

This patch introduces a new SKB_GSO_SHARED_FRAG flag, set
in skb_shinfo(skb)->gso_type if at least one frag can be
modified by the user.

Typical sources of such possible overwrites are {vm}splice(),
sendfile(), and macvtap/tun/virtio_net drivers.

Tested:

$ netperf -H 7.7.8.84
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
7.7.8.84 () port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    3959.52   

$ netperf -H 7.7.8.84 -t TCP_SENDFILE
TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.8.84 ()
port 0 AF_INET
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

 87380  16384  16384    10.00    3216.80   

Performance of the SENDFILE is impacted by the extra allocation and
copy, and because we use order-0 pages, while the TCP_STREAM uses
bigger pages.

Reported-by: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/macvtap.c    |    3 ++-
 drivers/net/tun.c        |   12 ++++++++----
 drivers/net/virtio_net.c |   12 ++++++++----
 include/linux/skbuff.h   |   19 +++++++++++++++++++
 net/core/dev.c           |    9 +++++++++
 net/core/skbuff.c        |    4 ++++
 net/ipv4/af_inet.c       |    1 +
 net/ipv4/ip_gre.c        |    4 +++-
 net/ipv4/ipip.c          |    4 +++-
 net/ipv4/tcp.c           |    3 +++
 net/ipv4/tcp_input.c     |    4 ++--
 net/ipv4/tcp_output.c    |    4 ++--
 net/ipv6/ip6_offload.c   |    1 +
 13 files changed, 65 insertions(+), 15 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 0f0f9ce..b181dfb 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -543,6 +543,7 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		skb->data_len += len;
 		skb->len += len;
 		skb->truesize += truesize;
+		skb_shinfo(skb)->gso_type |= SKB_GSO_SHARED_FRAG;
 		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
 		while (len) {
 			int off = base & ~PAGE_MASK;
@@ -598,7 +599,7 @@ static int macvtap_skb_from_vnet_hdr(struct sk_buff *skb,
 
 	if (vnet_hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
 		skb_shinfo(skb)->gso_size = vnet_hdr->gso_size;
-		skb_shinfo(skb)->gso_type = gso_type;
+		skb_shinfo(skb)->gso_type |= gso_type;
 
 		/* Header must be checked, and gso_segs computed. */
 		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index c81680d..293ce8d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1005,6 +1005,7 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		skb->data_len += len;
 		skb->len += len;
 		skb->truesize += truesize;
+		skb_shinfo(skb)->gso_type |= SKB_GSO_SHARED_FRAG;
 		atomic_add(truesize, &skb->sk->sk_wmem_alloc);
 		while (len) {
 			int off = base & ~PAGE_MASK;
@@ -1150,16 +1151,18 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	if (gso.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+		unsigned short gso_type = 0;
+
 		pr_debug("GSO!\n");
 		switch (gso.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
 		case VIRTIO_NET_HDR_GSO_TCPV4:
-			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+			gso_type = SKB_GSO_TCPV4;
 			break;
 		case VIRTIO_NET_HDR_GSO_TCPV6:
-			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+			gso_type = SKB_GSO_TCPV6;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
-			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+			gso_type = SKB_GSO_UDP;
 			break;
 		default:
 			tun->dev->stats.rx_frame_errors++;
@@ -1168,9 +1171,10 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		}
 
 		if (gso.gso_type & VIRTIO_NET_HDR_GSO_ECN)
-			skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
+			gso_type |= SKB_GSO_TCP_ECN;
 
 		skb_shinfo(skb)->gso_size = gso.gso_size;
+		skb_shinfo(skb)->gso_type |= gso_type;
 		if (skb_shinfo(skb)->gso_size == 0) {
 			tun->dev->stats.rx_frame_errors++;
 			kfree_skb(skb);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 701408a..58914c8 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -220,6 +220,7 @@ static void set_skb_frag(struct sk_buff *skb, struct page *page,
 	skb->len += size;
 	skb->truesize += PAGE_SIZE;
 	skb_shinfo(skb)->nr_frags++;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_SHARED_FRAG;
 	*len -= size;
 }
 
@@ -379,16 +380,18 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		 ntohs(skb->protocol), skb->len, skb->pkt_type);
 
 	if (hdr->hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
+		unsigned short gso_type = 0;
+
 		pr_debug("GSO!\n");
 		switch (hdr->hdr.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
 		case VIRTIO_NET_HDR_GSO_TCPV4:
-			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+			gso_type = SKB_GSO_TCPV4;
 			break;
 		case VIRTIO_NET_HDR_GSO_UDP:
-			skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+			gso_type = SKB_GSO_UDP;
 			break;
 		case VIRTIO_NET_HDR_GSO_TCPV6:
-			skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+			gso_type = SKB_GSO_TCPV6;
 			break;
 		default:
 			net_warn_ratelimited("%s: bad gso type %u.\n",
@@ -397,7 +400,7 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 		}
 
 		if (hdr->hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
-			skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
+			gso_type |= SKB_GSO_TCP_ECN;
 
 		skb_shinfo(skb)->gso_size = hdr->hdr.gso_size;
 		if (skb_shinfo(skb)->gso_size == 0) {
@@ -405,6 +408,7 @@ static void receive_buf(struct receive_queue *rq, void *buf, unsigned int len)
 			goto frame_err;
 		}
 
+		skb_shinfo(skb)->gso_type |= gso_type;
 		/* Header must be checked, and gso_segs computed. */
 		skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
 		skb_shinfo(skb)->gso_segs = 0;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8b2256e..0259b71 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -307,6 +307,13 @@ enum {
 	SKB_GSO_TCPV6 = 1 << 4,
 
 	SKB_GSO_FCOE = 1 << 5,
+
+	/* This indicates at least one fragment might be overwritten
+	 * (as in vmsplice(), sendfile() ...)
+	 * If we need to compute a TX checksum, we'll need to copy
+	 * all frags to avoid possible bad checksum
+	 */
+	SKB_GSO_SHARED_FRAG = 1 << 6,
 };
 
 #if BITS_PER_LONG > 32
@@ -2201,6 +2208,18 @@ static inline int skb_linearize(struct sk_buff *skb)
 }
 
 /**
+ * skb_has_shared_frag - can any frag be overwritten
+ * @skb: buffer to test
+ *
+ * Return true if the skb has at least one frag that might be modified
+ * by an external entity (as in vmsplice()/sendfile())
+ */
+static inline bool skb_has_shared_frag(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->gso_type & SKB_GSO_SHARED_FRAG;
+}
+
+/**
  *	skb_linearize_cow - make sure skb is linear and writable
  *	@skb: buffer to process
  *
diff --git a/net/core/dev.c b/net/core/dev.c
index c69cd87..a83375d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2271,6 +2271,15 @@ int skb_checksum_help(struct sk_buff *skb)
 		return -EINVAL;
 	}
 
+	/* Before computing a checksum, we should make sure no frag could
+	 * be modified by an external entity : checksum could be wrong.
+	 */
+	if (skb_has_shared_frag(skb)) {
+		ret = __skb_linearize(skb);
+		if (ret)
+			goto out;
+	}
+
 	offset = skb_checksum_start_offset(skb);
 	BUG_ON(offset >= skb_headlen(skb));
 	csum = skb_checksum(skb, offset, skb->len - offset, 0);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2568c44..bddc1dd 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2340,6 +2340,8 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
 {
 	int pos = skb_headlen(skb);
 
+	skb_shinfo(skb1)->gso_type = skb_shinfo(skb)->gso_type;
+
 	if (len < pos)	/* Split line is inside header. */
 		skb_split_inside_header(skb, skb1, len, pos);
 	else		/* Second chunk has no header, nothing to copy. */
@@ -2845,6 +2847,8 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		skb_copy_from_linear_data_offset(skb, offset,
 						 skb_put(nskb, hsize), hsize);
 
+		skb_shinfo(nskb)->gso_type = skb_shinfo(skb)->gso_type;
+
 		while (pos < offset + len && i < nfrags) {
 			*frag = skb_shinfo(skb)->frags[i];
 			__skb_frag_ref(frag);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 4b70539..49ddca3 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1306,6 +1306,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_SHARED_FRAG |
 		       0)))
 		goto out;
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 303012a..af6be70 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -738,7 +738,7 @@ drop:
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	const struct iphdr  *old_iph = ip_hdr(skb);
+	const struct iphdr  *old_iph;
 	const struct iphdr  *tiph;
 	struct flowi4 fl4;
 	u8     tos;
@@ -756,6 +756,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	    skb_checksum_help(skb))
 		goto tx_error;
 
+	old_iph = ip_hdr(skb);
+
 	if (dev->type == ARPHRD_ETHER)
 		IPCB(skb)->flags = 0;
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 191fc24..8f024d4 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -472,7 +472,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	__be16 df = tiph->frag_off;
 	struct rtable *rt;     			/* Route to the other host */
 	struct net_device *tdev;		/* Device to other host */
-	const struct iphdr  *old_iph = ip_hdr(skb);
+	const struct iphdr  *old_iph;
 	struct iphdr  *iph;			/* Our new IP header */
 	unsigned int max_headroom;		/* The extra header space needed */
 	__be32 dst = tiph->daddr;
@@ -486,6 +486,8 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	    skb_checksum_help(skb))
 		goto tx_error;
 
+	old_iph = ip_hdr(skb);
+
 	if (tos & 1)
 		tos = old_iph->tos;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5227194..3ec1f69 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -896,6 +896,8 @@ new_segment:
 			skb_fill_page_desc(skb, i, page, offset, copy);
 		}
 
+		skb_shinfo(skb)->gso_type |= SKB_GSO_SHARED_FRAG;
+
 		skb->len += copy;
 		skb->data_len += copy;
 		skb->truesize += copy;
@@ -3032,6 +3034,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 			       SKB_GSO_DODGY |
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
+			       SKB_GSO_SHARED_FRAG |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
 			goto out;
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0905997..492c7cf 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1240,13 +1240,13 @@ static bool tcp_shifted_skb(struct sock *sk, struct sk_buff *skb,
 	 */
 	if (!skb_shinfo(prev)->gso_size) {
 		skb_shinfo(prev)->gso_size = mss;
-		skb_shinfo(prev)->gso_type = sk->sk_gso_type;
+		skb_shinfo(prev)->gso_type |= sk->sk_gso_type;
 	}
 
 	/* CHECKME: To clear or not to clear? Mimics normal skb currently */
 	if (skb_shinfo(skb)->gso_segs <= 1) {
 		skb_shinfo(skb)->gso_size = 0;
-		skb_shinfo(skb)->gso_type = 0;
+		skb_shinfo(skb)->gso_type &= SKB_GSO_SHARED_FRAG;
 	}
 
 	/* Difference in this won't matter, both ACKed by the same cumul. ACK */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 667a6ad..367e2ec 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1133,6 +1133,7 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 				 unsigned int mss_now)
 {
+	skb_shinfo(skb)->gso_type &= SKB_GSO_SHARED_FRAG;
 	if (skb->len <= mss_now || !sk_can_gso(sk) ||
 	    skb->ip_summed == CHECKSUM_NONE) {
 		/* Avoid the costly divide in the normal
@@ -1140,11 +1141,10 @@ static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
 		 */
 		skb_shinfo(skb)->gso_segs = 1;
 		skb_shinfo(skb)->gso_size = 0;
-		skb_shinfo(skb)->gso_type = 0;
 	} else {
 		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss_now);
 		skb_shinfo(skb)->gso_size = mss_now;
-		skb_shinfo(skb)->gso_type = sk->sk_gso_type;
+		skb_shinfo(skb)->gso_type |= sk->sk_gso_type;
 	}
 }
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index f26f0da..d141fc3 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -100,6 +100,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
 		       SKB_GSO_TCPV6 |
+		       SKB_GSO_SHARED_FRAG |
 		       0)))
 		goto out;
 
