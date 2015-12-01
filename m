From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC] Defer xfrm to be done post-GSO
Date: Tue, 1 Dec 2015 13:03:56 -0500
Message-ID: <20151201180356.GD21252@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sowmini.varadhan@oracle.com
To: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Experimental patch as promised in
 http://marc.info/?l=linux-netdev&m=144899280626165&w=2

Disclaimer: this patch is only an experiment to see if xfrm can be done
post-GSO to leverage from GSO benefits. I'm sharing to get some feedback
on the general direction being pursued here.

At the moment, for single-stream iperf using esp-null and a 10G link,
results in 3-3.5 Gbps vs the baseline of 1.8-2 Gbps.
While the 1.8 -> 3 Gbps is a step in the right direction, it still far
away from the 6-9 Gbps that one can get with just GSO (6 Gbps if GRO
is disabled), so input on other ways to improve this is invited.

Major things done in this patch:
- don't disable TSO in sk_setup_caps() if a dst->header_len is found
- in xfrm4_output, if GSO is applicable, bail out without esp header
  addition - that will get done after skb_segment()
- at the end of tcp_gso_segment() (when tcp segment is available),
  set things up for xfrm_output_one and trigger the esp_output
A 1-bit hole in sk_buff is used to track an skb that needs xfrm (might
not need to burn that bit, but using it for now)

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 include/linux/skbuff.h          |    6 +++-
 include/net/xfrm.h              |    1 +
 net/core/dev.c                  |    8 +++--
 net/core/sock.c                 |    4 +++
 net/ipv4/af_inet.c              |   11 +++++++-
 net/ipv4/ip_output.c            |    4 +++
 net/ipv4/tcp_offload.c          |   56 +++++++++++++++++++++++++++++++++++++++
 net/ipv4/tcp_output.c           |    1 +
 net/ipv4/xfrm4_mode_transport.c |   51 +++++++++++++++++++++++++++++++++++
 net/ipv4/xfrm4_output.c         |    9 ++++++
 net/xfrm/xfrm_output.c          |    3 +-
 11 files changed, 147 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 24f4dfd..242c32b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -593,8 +593,8 @@ struct sk_buff {
 				fclone:2,
 				peeked:1,
 				head_frag:1,
-				xmit_more:1;
-	/* one bit hole */
+				xmit_more:1,
+				recirc:1; /* uses one bit hole */
 	kmemcheck_bitfield_end(flags1);
 
 	/* fields enclosed in headers_start/headers_end are copied
@@ -3577,5 +3577,7 @@ static inline unsigned int skb_gso_network_seglen(const struct sk_buff *skb)
 	return hdr_len + skb_gso_transport_seglen(skb);
 }
 
+#define XFRM_GSO 1 /* use this for now to quickly toggle back to baseline */
+
 #endif	/* __KERNEL__ */
 #endif	/* _LINUX_SKBUFF_H */
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 4a9c21f..c17dc79 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1508,6 +1508,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type);
 int xfrm_input_resume(struct sk_buff *skb, int nexthdr);
 int xfrm_output_resume(struct sk_buff *skb, int err);
 int xfrm_output(struct sock *sk, struct sk_buff *skb);
+int xfrm_output_one(struct sk_buff *skb, int err);
 int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 void xfrm_local_error(struct sk_buff *skb, int mtu);
 int xfrm4_extract_header(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 8ce3f74..6b9f20f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2804,7 +2804,7 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device 
 
 struct sk_buff *validate_xmit_skb_list(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sk_buff *next, *head = NULL, *tail;
+	struct sk_buff *next, *head = NULL, *tail = NULL;
 
 	for (; skb != NULL; skb = next) {
 		next = skb->next;
@@ -3086,10 +3086,12 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
 	/* If device/qdisc don't need skb->dst, release it right now while
 	 * its hot in this cpu cache.
 	 */
-	if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
+	if ((dev->priv_flags & IFF_XMIT_DST_RELEASE) &&
+	    !skb->recirc) {
 		skb_dst_drop(skb);
-	else
+	} else {
 		skb_dst_force(skb);
+	}
 
 #ifdef CONFIG_NET_SWITCHDEV
 	/* Don't forward if offload device already forwarded */
diff --git a/net/core/sock.c b/net/core/sock.c
index 7529eb9..05c902b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1613,7 +1613,11 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 		sk->sk_route_caps |= NETIF_F_GSO_SOFTWARE;
 	sk->sk_route_caps &= ~sk->sk_route_nocaps;
 	if (sk_can_gso(sk)) {
+#ifndef XFRM_GSO
 		if (dst->header_len) {
+#else
+		if (0) {
+#endif
 			sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
 		} else {
 			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 11c4ca1..2c04a98 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1203,6 +1203,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	int nhoff;
 	int ihl;
 	int id;
+	bool need_xfrm = skb->recirc;
 
 	if (unlikely(skb_shinfo(skb)->gso_type &
 		     ~(SKB_GSO_TCPV4 |
@@ -1254,14 +1255,22 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		udpfrag = proto == IPPROTO_UDP && !skb->encapsulation;
 
 	ops = rcu_dereference(inet_offloads[proto]);
-	if (likely(ops && ops->callbacks.gso_segment))
+	if (likely(ops && ops->callbacks.gso_segment)) {
+		/* tcp_gso_segment gets called here. It will add the
+		 * XFRM by calling xfrm_output_one->esp_output.
+		 * We will move things around to make space for the	
+		 * esp header in xfrm4_mode_transport.c (for transport
+		 * mode- this is in xfrm4_transport_output_gso() 
+		 */
 		segs = ops->callbacks.gso_segment(skb, features);
+	}
 
 	if (IS_ERR_OR_NULL(segs))
 		goto out;
 
 	skb = segs;
 	do {
+		nhoff = skb_network_header(skb) - skb_mac_header(skb);
 		iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
 		if (udpfrag) {
 			iph->id = htons(id);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4233cbe..8f3f111 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -270,10 +270,14 @@ static int ip_finish_output(struct net *net, struct sock *sk, struct sk_buff *sk
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
 	if (skb_dst(skb)->xfrm) {
+		if (sk_can_gso(sk) && skb_is_gso(skb) &&
+		    sk->sk_gso_type == SKB_GSO_TCPV4)
+			goto xfrm_gso;
 		IPCB(skb)->flags |= IPSKB_REROUTED;
 		return dst_output(net, sk, skb);
 	}
 #endif
+xfrm_gso:
 	mtu = ip_skb_dst_mtu(skb);
 	if (skb_is_gso(skb))
 		return ip_finish_output_gso(net, sk, skb, mtu);
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 9864a2d..1c0f669 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -13,6 +13,7 @@
 #include <linux/skbuff.h>
 #include <net/tcp.h>
 #include <net/protocol.h>
+#include <net/xfrm.h>
 
 static void tcp_gso_tstamp(struct sk_buff *skb, unsigned int ts_seq,
 			   unsigned int seq, unsigned int mss)
@@ -51,6 +52,49 @@ static struct sk_buff *tcp4_gso_segment(struct sk_buff *skb,
 	return tcp_gso_segment(skb, features);
 }
 
+#ifdef XFRM_GSO
+static int add_xfrm_post_gso(struct sk_buff *skb)
+{
+	struct xfrm_state *x = skb_dst(skb)->xfrm;
+	int err;
+
+	if (!x)	 {
+		skb->recirc = 0;
+		return 0;
+	}
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
+
+	/* XXX sub-optimal stuff.
+	 * at this point ip_summed is CHECKSUM_PARTIAL. This bit
+	 * should be optimized- we should not be doing this again.
+	 * For now, just use ethool to set tx off rx off, and let
+	 * the rest of the GSO logic compute the checksum efficiently
+	 */
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		err = skb_checksum_help(skb);
+		/* at this point ip_summed is 0 */
+
+		if (err) {
+			kfree_skb(skb);
+			return err;
+		}
+        }
+	err = 1;
+	skb->recirc = 1;
+	err = xfrm_output_one(skb, err);
+	WARN_ON(err != 0);
+
+	/* reset all the abuse */
+	skb->recirc = 0;
+	skb->mac_header = skb->network_header - 14;
+	skb->transport_header += x->props.header_len;
+	__skb_push(skb, 14); 
+
+	skb_dst_drop(skb);
+	return err;
+}
+#endif /* XFRM_GSO */
+
 struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 				netdev_features_t features)
 {
@@ -65,6 +109,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	struct sk_buff *gso_skb = skb;
 	__sum16 newcheck;
 	bool ooo_okay, copy_destructor;
+#ifdef XFRM_GSO
+	bool need_xfrm = (skb->recirc == 1);
+#endif
 
 	th = tcp_hdr(skb);
 	thlen = th->doff * 4;
@@ -113,6 +160,7 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	skb->ooo_okay = 0;
 
 	segs = skb_segment(skb, features);
+	skb->recirc = 0;
 	if (IS_ERR(segs))
 		goto out;
 
@@ -172,6 +220,14 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		th->check = gso_make_checksum(skb, ~th->check);
 out:
+#ifdef XFRM_GSO
+	if (need_xfrm) {
+		struct sk_buff *nskb;
+
+		for (nskb = segs; nskb; nskb = nskb->next)
+			add_xfrm_post_gso(nskb);
+	}
+#endif
 	return segs;
 }
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index cb7ca56..6168834 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -951,6 +951,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	skb_reset_transport_header(skb);
 
 	skb_orphan(skb);
+	skb->recirc = 0;
 	skb->sk = sk;
 	skb->destructor = skb_is_tcp_pure_ack(skb) ? sock_wfree : tcp_wfree;
 	skb_set_hash_from_sk(skb, sk);
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index fd840c7..154c580 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -13,6 +13,41 @@
 #include <net/ip.h>
 #include <net/xfrm.h>
 
+#ifdef XFRM_GSO
+/* 
+ * when we come here, we have
+ * mac_header pointing to start of ether addr. This is also skb->data
+ * ip_hdr/network_header pointing to start of IP header (14 bytes after
+ *                       mac header. 
+ * transport header points at ip_hdr + ihl.
+ * Unfortunately, esp_output overloads mac_header to use it as a pointer
+ * to the ip_proto field (which will get over-written by IPPROTO_ESP
+ * in esp_output).
+ * We should really pullup mac and ip header fields and leave some room
+ * for the esp header. Actually we should not be doing any move at all.
+ * This is a mess.
+ */
+static int xfrm4_transport_output_gso(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct iphdr *iph = ip_hdr(skb);
+	int ihl = iph->ihl * 4;
+	int iph_off = (unsigned char *)iph - (unsigned char *)skb->data;
+	unsigned char *data = skb_mac_header(skb);
+
+	skb->network_header -= x->props.header_len;
+	skb->transport_header = skb->network_header + ihl;
+	skb->mac_header -= x->props.header_len;
+
+	__skb_pull(skb, ihl + iph_off);
+	memmove(skb_mac_header(skb), data, ihl + iph_off);
+
+	/* This is a mess */
+	skb->mac_header = skb->network_header +
+			  offsetof(struct iphdr, protocol);
+	return 0;
+}
+#endif /* XFRM_GSO */
+
 /* Add encapsulation header.
  *
  * The IP header will be moved forward to make space for the encapsulation
@@ -22,12 +57,28 @@ static int xfrm4_transport_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
 	int ihl = iph->ihl * 4;
+	int iph_off = (unsigned char *)iph - (unsigned char *)skb->data;
+
+#ifdef XFRM_GSO
+	if (skb->recirc)
+		return xfrm4_transport_output_gso(x, skb);
+#endif /* XFRM_GSO */
 
+	/* move network/ip_hdr back by esp hdr size */
 	skb_set_network_header(skb, -x->props.header_len);
+	/* make mac_header point to ip_proto field in the
+	 * new location of ip_hdr
+	 */
 	skb->mac_header = skb->network_header +
 			  offsetof(struct iphdr, protocol);
+	/* make transport_hdr point to tcp payload
+	 * in the new location. This is where the esp hdr will go
+	 */
 	skb->transport_header = skb->network_header + ihl;
+	/* move up the skb->data to go past ip hdr to tcp hdr.
+	 * This reduces the len by the ip header len */
 	__skb_pull(skb, ihl);
+	/* copy the ip hdr over to new location */
 	memmove(skb_network_header(skb), iph, ihl);
 	return 0;
 }
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 7ee6518..d0c8a9a 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -98,6 +98,15 @@ static int __xfrm4_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 int xfrm4_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
+#ifdef XFRM_GSO
+	if (sk_can_gso(sk) && sk->sk_gso_type == SKB_GSO_TCPV4 &&
+	     skb_is_gso(skb)) {
+		BUG_ON(IPCB(skb)->flags & IPSKB_REROUTED);
+		skb->recirc = 1;
+		return (ip_output(net, sk, skb));
+	}
+#endif /* XFRM_GSO */
+
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
 			    net, sk, skb, NULL, skb_dst(skb)->dev,
 			    __xfrm4_output,
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index cc3676e..39f7d76 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -50,7 +50,7 @@ static struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 	return child;
 }
 
-static int xfrm_output_one(struct sk_buff *skb, int err)
+int xfrm_output_one(struct sk_buff *skb, int err)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_state *x = dst->xfrm;
@@ -128,6 +128,7 @@ static int xfrm_output_one(struct sk_buff *skb, int err)
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(xfrm_output_one);
 
 int xfrm_output_resume(struct sk_buff *skb, int err)
 {
-- 
1.7.1
