From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/5] [NET]: Add software TSOv4
Date: Tue, 20 Jun 2006 19:29:57 +1000
Message-ID: <20060620092957.GC31854@gondor.apana.org.au>
References: <20060620090919.GA31613@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="S1BNGpv0yoYahz37"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33546 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965225AbWFTJ37
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 05:29:59 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060620090919.GA31613@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--S1BNGpv0yoYahz37
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

[NET]: Add software TSOv4

This patch adds the GSO implementation for IPv4 TCP.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--S1BNGpv0yoYahz37
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p3.patch"

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1299,6 +1299,7 @@ extern void	       skb_split(struct sk_b
 				 struct sk_buff *skb1, const u32 len);
 
 extern void	       skb_release_data(struct sk_buff *skb);
+extern struct sk_buff *skb_segment(struct sk_buff *skb, int sg);
 
 static inline void *skb_header_pointer(const struct sk_buff *skb, int offset,
 				       int len, void *buffer)
diff --git a/include/net/protocol.h b/include/net/protocol.h
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -37,6 +37,7 @@
 struct net_protocol {
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
+	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb, int sg);
 	int			no_policy;
 };
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1087,6 +1087,8 @@ extern struct request_sock_ops tcp_reque
 
 extern int tcp_v4_destroy_sock(struct sock *sk);
 
+extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int sg);
+
 #ifdef CONFIG_PROC_FS
 extern int  tcp4_proc_init(void);
 extern void tcp4_proc_exit(void);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1826,6 +1826,132 @@ unsigned char *skb_pull_rcsum(struct sk_
 
 EXPORT_SYMBOL_GPL(skb_pull_rcsum);
 
+/**
+ *	skb_segment - Perform protocol segmentation on skb.
+ *	@skb: buffer to segment
+ *	@sg: whether scatter-gather can be used for generated segments
+ *
+ *	This function performs segmentation on the given skb.  It returns
+ *	the segment at the given position.  It returns NULL if there are
+ *	no more segments to generate, or when an error is encountered.
+ */
+struct sk_buff *skb_segment(struct sk_buff *skb, int sg)
+{
+	struct sk_buff *segs = NULL;
+	struct sk_buff *tail = NULL;
+	unsigned int mss = skb_shinfo(skb)->gso_size;
+	unsigned int doffset = skb->data - skb->mac.raw;
+	unsigned int offset = doffset;
+	unsigned int headroom;
+	unsigned int len;
+	int nfrags = skb_shinfo(skb)->nr_frags;
+	int err = -ENOMEM;
+	int i = 0;
+	int pos;
+
+	__skb_push(skb, doffset);
+	headroom = skb_headroom(skb);
+	pos = skb_headlen(skb);
+
+	do {
+		struct sk_buff *nskb;
+		skb_frag_t *frag;
+		int hsize, nsize;
+		int k;
+		int size;
+
+		len = skb->len - offset;
+		if (len > mss)
+			len = mss;
+
+		hsize = skb_headlen(skb) - offset;
+		if (hsize < 0)
+			hsize = 0;
+		nsize = hsize + doffset;
+		if (nsize > len + doffset || !sg)
+			nsize = len + doffset;
+
+		nskb = alloc_skb(nsize + headroom, GFP_ATOMIC);
+		if (unlikely(!nskb))
+			goto err;
+
+		if (segs)
+			tail->next = nskb;
+		else
+			segs = nskb;
+		tail = nskb;
+
+		nskb->dev = skb->dev;
+		nskb->priority = skb->priority;
+		nskb->protocol = skb->protocol;
+		nskb->dst = dst_clone(skb->dst);
+		memcpy(nskb->cb, skb->cb, sizeof(skb->cb));
+		nskb->pkt_type = skb->pkt_type;
+		nskb->mac_len = skb->mac_len;
+
+		skb_reserve(nskb, headroom);
+		nskb->mac.raw = nskb->data;
+		nskb->nh.raw = nskb->data + skb->mac_len;
+		nskb->h.raw = nskb->nh.raw + (skb->h.raw - skb->nh.raw);
+		memcpy(skb_put(nskb, doffset), skb->data, doffset);
+
+		if (!sg) {
+			nskb->csum = skb_copy_and_csum_bits(skb, offset,
+							    skb_put(nskb, len),
+							    len, 0);
+			continue;
+		}
+
+		frag = skb_shinfo(nskb)->frags;
+		k = 0;
+
+		nskb->ip_summed = CHECKSUM_HW;
+		nskb->csum = skb->csum;
+		memcpy(skb_put(nskb, hsize), skb->data + offset, hsize);
+
+		while (pos < offset + len) {
+			BUG_ON(i >= nfrags);
+
+			*frag = skb_shinfo(skb)->frags[i];
+			get_page(frag->page);
+			size = frag->size;
+
+			if (pos < offset) {
+				frag->page_offset += offset - pos;
+				frag->size -= offset - pos;
+			}
+
+			k++;
+
+			if (pos + size <= offset + len) {
+				i++;
+				pos += size;
+			} else {
+				frag->size -= pos + size - (offset + len);
+				break;
+			}
+
+			frag++;
+		}
+
+		skb_shinfo(nskb)->nr_frags = k;
+		nskb->data_len = len - hsize;
+		nskb->len += nskb->data_len;
+		nskb->truesize += nskb->data_len;
+	} while ((offset += len) < skb->len);
+
+	return segs;
+
+err:
+	while ((skb = segs)) {
+		segs = skb->next;
+		kfree(skb);
+	}
+	return ERR_PTR(err);
+}
+
+EXPORT_SYMBOL_GPL(skb_segment);
+
 void __init skb_init(void)
 {
 	skbuff_head_cache = kmem_cache_create("skbuff_head_cache",
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -68,6 +68,7 @@
  */
 
 #include <linux/config.h>
+#include <linux/err.h>
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/socket.h>
@@ -1096,6 +1097,54 @@ int inet_sk_rebuild_header(struct sock *
 
 EXPORT_SYMBOL(inet_sk_rebuild_header);
 
+static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int sg)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct iphdr *iph;
+	struct net_protocol *ops;
+	int proto;
+	int ihl;
+	int id;
+
+	if (!pskb_may_pull(skb, sizeof(*iph)))
+		goto out;
+
+	iph = skb->nh.iph;
+	ihl = iph->ihl * 4;
+	if (ihl < sizeof(*iph))
+		goto out;
+
+	if (!pskb_may_pull(skb, ihl))
+		goto out;
+
+	skb->h.raw = __skb_pull(skb, ihl);
+	iph = skb->nh.iph;
+	id = ntohs(iph->id);
+	proto = iph->protocol & (MAX_INET_PROTOS - 1);
+	segs = ERR_PTR(-EPROTONOSUPPORT);
+
+	rcu_read_lock();
+	ops = rcu_dereference(inet_protos[proto]);
+	if (ops && ops->gso_segment)
+		segs = ops->gso_segment(skb, sg);
+	rcu_read_unlock();
+
+	if (IS_ERR(segs))
+		goto out;
+
+	skb = segs;
+	do {
+		iph = skb->nh.iph;
+		iph->id = htons(id++);
+		iph->tot_len = htons(skb->len - skb->mac_len);
+		iph->check = 0;
+		iph->check = ip_fast_csum(skb->nh.raw, iph->ihl);
+	} while ((skb = skb->next));
+
+out:
+	return segs;
+}
+
 #ifdef CONFIG_IP_MULTICAST
 static struct net_protocol igmp_protocol = {
 	.handler =	igmp_rcv,
@@ -1105,6 +1154,7 @@ static struct net_protocol igmp_protocol
 static struct net_protocol tcp_protocol = {
 	.handler =	tcp_v4_rcv,
 	.err_handler =	tcp_v4_err,
+	.gso_segment =	tcp_tso_segment,
 	.no_policy =	1,
 };
 
@@ -1150,6 +1200,7 @@ static int ipv4_proc_init(void);
 static struct packet_type ip_packet_type = {
 	.type = __constant_htons(ETH_P_IP),
 	.func = ip_rcv,
+	.gso_segment = inet_gso_segment,
 };
 
 static int __init inet_init(void)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -258,6 +258,7 @@
 #include <linux/random.h>
 #include <linux/bootmem.h>
 #include <linux/cache.h>
+#include <linux/err.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -2144,6 +2145,67 @@ int compat_tcp_getsockopt(struct sock *s
 EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
 
+struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int sg)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct tcphdr *th;
+	unsigned thlen;
+	unsigned int seq;
+	unsigned int delta;
+	unsigned int oldlen;
+	unsigned int len;
+
+	if (!pskb_may_pull(skb, sizeof(*th)))
+		goto out;
+
+	th = skb->h.th;
+	thlen = th->doff * 4;
+	if (thlen < sizeof(*th))
+		goto out;
+
+	if (!pskb_may_pull(skb, thlen))
+		goto out;
+
+	oldlen = ~htonl(skb->len);
+	__skb_pull(skb, thlen);
+
+	segs = skb_segment(skb, sg);
+	if (IS_ERR(segs))
+		goto out;
+
+	len = skb_shinfo(skb)->gso_size;
+	delta = csum_add(oldlen, htonl(thlen + len));
+
+	skb = segs;
+	th = skb->h.th;
+	seq = ntohl(th->seq);
+
+	do {
+		th->fin = th->psh = 0;
+
+		if (skb->ip_summed == CHECKSUM_NONE) {
+			th->check = csum_fold(csum_partial(
+				skb->h.raw, thlen, csum_add(skb->csum, delta)));
+		}
+
+		seq += len;
+		skb = skb->next;
+		th = skb->h.th;
+
+		th->seq = htonl(seq);
+		th->cwr = 0;
+	} while (skb->next);
+
+	if (skb->ip_summed == CHECKSUM_NONE) {
+		delta = csum_add(oldlen, htonl(skb->tail - skb->h.raw));
+		th->check = csum_fold(csum_partial(
+			skb->h.raw, thlen, csum_add(skb->csum, delta)));
+	}
+
+out:
+	return segs;
+}
+
 extern void __skb_cb_too_small_for_tcp(int, int);
 extern struct tcp_congestion_ops tcp_reno;
 

--S1BNGpv0yoYahz37--
