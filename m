From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gso: Handle new frag_list of frags GRO packets
Date: Thu, 14 Nov 2013 16:11:17 +0800
Message-ID: <20131114081117.GA12708@gondor.apana.org.au>
References: <20131107070647.GB31638@gondor.apana.org.au>
 <20131111185207.GA12277@gondor.apana.org.au>
 <1384305223.28458.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131113012920.GA27897@gondor.apana.org.au>
 <1384309034.28458.69.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131113022243.GA28204@gondor.apana.org.au>
 <20131113022525.GA28236@gondor.apana.org.au>
 <1384310704.28458.79.camel@edumazet-glaptop2.roam.corp.google.com>
 <20131113142615.GA1851@gondor.apana.org.au>
 <1384355185.28458.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:52714 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751232Ab3KNIL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 03:11:28 -0500
Content-Disposition: inline
In-Reply-To: <1384355185.28458.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 07:06:25AM -0800, Eric Dumazet wrote:
>
> Well, I wont try this patch, as it can not possibly work :(

You're right.  It sort of worked for me because I had the GSO
features test reversed meaning it never enabled my new code.

This new patch is still incomplete in that it only does TCPv4 but
it does actually seem to work.

Please let me know what the performance numbers look like.

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 557e1a5..e45a2ad 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2786,6 +2786,8 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	__be16 proto;
 	bool csum;
 	int sg = !!(features & NETIF_F_SG);
+	int gso_type = 0;
+	int gso_size = 0;
 	int nfrags = skb_shinfo(skb)->nr_frags;
 	int err = -ENOMEM;
 	int i = 0;
@@ -2795,6 +2797,11 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	if (unlikely(!proto))
 		return ERR_PTR(-EINVAL);
 
+	if (net_gso_ok(features, gso_type)) {
+		gso_type = skb_shinfo(skb)->gso_type & ~SKB_GSO_DODGY;
+		gso_size = mss;
+	}
+
 	csum = !!can_checksum_protocol(features, proto);
 	__skb_push(skb, doffset);
 	headroom = skb_headroom(skb);
@@ -2805,9 +2812,10 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		skb_frag_t *frag;
 		int hsize;
 		int size;
+		int gso_segs = 1;
 
 		len = skb->len - offset;
-		if (len > mss)
+		if (!gso_size && len > mss)
 			len = mss;
 
 		hsize = skb_headlen(skb) - offset;
@@ -2819,6 +2827,22 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		if (!hsize && i >= nfrags && skb_headlen(fskb) &&
 		    (skb_headlen(fskb) == len || sg)) {
 			BUG_ON(skb_headlen(fskb) > len);
+			SKB_FRAG_ASSERT(fskb);
+
+			if (gso_size) {
+				len = fskb->len;
+				pos += len;
+
+				gso_segs = len / mss;
+
+				/*
+				 * Original GRO packet boundaries must
+				 * have been preserved.
+				 */
+				BUG_ON(fskb->next && len % mss);
+
+				goto clone_fskb;
+			}
 
 			i = 0;
 			nfrags = skb_shinfo(fskb)->nr_frags;
@@ -2837,6 +2861,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 				skb_frag++;
 			}
 
+clone_fskb:
 			nskb = skb_clone(fskb, GFP_ATOMIC);
 			fskb = fskb->next;
 
@@ -2880,6 +2905,10 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 		skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);
 
+		skb_shinfo(nskb)->gso_size = gso_size;
+		skb_shinfo(nskb)->gso_type = gso_type;
+		skb_shinfo(nskb)->gso_segs = gso_segs;
+
 		skb_copy_from_linear_data_offset(skb, -tnl_hlen,
 						 nskb->data - tnl_hlen,
 						 doffset + tnl_hlen);
@@ -2902,6 +2931,39 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 		skb_shinfo(nskb)->tx_flags = skb_shinfo(skb)->tx_flags & SKBTX_SHARED_FRAG;
 
+		/* Do a trial run for hardware GSO to get the proper length. */
+		if (pos < offset + len && gso_size) {
+			int j;
+
+			len = hsize;
+			if (pos < offset)
+				len -= offset - pos;
+
+			for (j = i; j < nfrags; j++)
+				len += skb_frag_size(skb_frag + j);
+
+			if (fskb && !skb_headlen(fskb)) {
+				j = min_t(int,
+					  skb_shinfo(fskb)->nr_frags,
+					  MAX_SKB_FRAGS - nfrags + i);
+
+				while (--j >= 0)
+					len += skb_frag_size(
+						skb_shinfo(fskb)->frags + j);
+			}
+
+			if (len < mss && offset + len < skb->len)
+				goto too_many_frags;
+
+			skb_shinfo(nskb)->gso_segs = len / mss;
+			if (len % mss) {
+				if (offset + len >= skb->len)
+					skb_shinfo(nskb)->gso_segs++;
+				else
+					len -= len % mss;
+			}
+		}
+
 		while (pos < offset + len) {
 			if (i >= nfrags) {
 				BUG_ON(skb_headlen(fskb));
@@ -2917,6 +2979,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 
 			if (unlikely(skb_shinfo(nskb)->nr_frags >=
 				     MAX_SKB_FRAGS)) {
+too_many_frags:
 				net_warn_ratelimited(
 					"skb_segment: too many frags: %u %u\n",
 					pos, mss);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 09d78d4..fba07ba 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1317,7 +1317,8 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 				iph->frag_off |= htons(IP_MF);
 			offset += skb->len - nhoff - ihl;
 		} else {
-			iph->id = htons(id++);
+			id += skb_shinfo(skb)->gso_segs;
+			iph->id = htons(id);
 		}
 		iph->tot_len = htons(skb->len - nhoff);
 		ip_send_check(iph);
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index a2b68a1..62f9334 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -22,11 +22,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	struct tcphdr *th;
 	unsigned int thlen;
 	unsigned int seq;
-	__be32 delta;
 	unsigned int oldlen;
 	unsigned int mss;
 	struct sk_buff *gso_skb = skb;
-	__sum16 newcheck;
 	bool ooo_okay, copy_destructor;
 
 	if (!pskb_may_pull(skb, sizeof(*th)))
@@ -83,25 +81,24 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 	/* Only first segment might have ooo_okay set */
 	segs->ooo_okay = ooo_okay;
 
-	delta = htonl(oldlen + (thlen + mss));
-
 	skb = segs;
 	th = tcp_hdr(skb);
 	seq = ntohl(th->seq);
 
-	newcheck = ~csum_fold((__force __wsum)((__force u32)th->check +
-					       (__force u32)delta));
-
 	do {
 		th->fin = th->psh = 0;
-		th->check = newcheck;
+
+		th->check = ~csum_fold((__force __wsum)(
+			(__force u32)th->check +
+			(__force u32)htonl(oldlen + skb->len -
+					   skb_transport_offset(skb))));
 
 		if (skb->ip_summed != CHECKSUM_PARTIAL)
 			th->check =
 			     csum_fold(csum_partial(skb_transport_header(skb),
 						    thlen, skb->csum));
 
-		seq += mss;
+		seq += skb->len - skb_transport_offset(skb) - thlen;
 		if (copy_destructor) {
 			skb->destructor = gso_skb->destructor;
 			skb->sk = gso_skb->sk;
@@ -127,11 +124,10 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 			   &skb->sk->sk_wmem_alloc);
 	}
 
-	delta = htonl(oldlen + (skb_tail_pointer(skb) -
-				skb_transport_header(skb)) +
-		      skb->data_len);
-	th->check = ~csum_fold((__force __wsum)((__force u32)th->check +
-				(__force u32)delta));
+	th->check = ~csum_fold((__force __wsum)(
+		(__force u32)th->check +
+		(__force u32)htonl(oldlen + skb->len -
+				   skb_transport_offset(skb))));
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		th->check = csum_fold(csum_partial(skb_transport_header(skb),
 						   thlen, skb->csum));

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
