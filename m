From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH] gro: Partly revert "net: gro: allow to build full
 sized skb"
Date: Fri, 24 Jun 2016 10:22:17 +0200
Message-ID: <20160624082217.GQ7698@gauss.secunet.com>
References: <20160421074042.GF3347@gauss.secunet.com>
 <CAKgT0Uc-MfZseKauJMW+xh+5LTEww6hcWmuXeCATsDA+Z-POsQ@mail.gmail.com>
 <20160422085107.GJ3347@gauss.secunet.com>
 <CAKgT0UeJLhn5yyK9Ezt=jHsysi4y+fVkRoOyZN2Zbe7Wk0LuHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:54270 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853AbcFXIWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2016 04:22:23 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0UeJLhn5yyK9Ezt=jHsysi4y+fVkRoOyZN2Zbe7Wk0LuHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for replying to old mail, but wanted to keep the context.

On Fri, Apr 22, 2016 at 10:14:22AM -0700, Alexander Duyck wrote:
> On Fri, Apr 22, 2016 at 1:51 AM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > On Thu, Apr 21, 2016 at 09:02:48AM -0700, Alexander Duyck wrote:
> >> On Thu, Apr 21, 2016 at 12:40 AM, Steffen Klassert
> >> <steffen.klassert@secunet.com> wrote:
> >> > This partly reverts the below mentioned patch because on
> >> > forwarding, such skbs can't be offloaded to a NIC.
> >> >
> >> > We need this to get IPsec GRO for forwarding to work properly,
> >> > otherwise the GRO aggregated packets get segmented again by
> >> > the GSO layer. Although discovered when implementing IPsec GRO,
> >> > this is a general problem in the forwarding path.
> >>
> >> I'm confused as to why you would need this to get IPsec GRO forwarding
> >> to work.
> >
> > It works without this, but the performance numbers are not that good
> > if we have to do GSO in software.
> 
> Well really GSO is only meant to preform better than if we didn't do
> any GRO/GSO at all.  If that isn't the case I wouldn't consider it a
> regression since as Eric points out there are other scenerios where
> you end up with a chain of buffers stuck on the fraglist.  Mostly what
> GRO/GSO gets you is fewer runs through the stack.
> 
> >> Are you having to go through a device that doesn't have
> >> NETIF_F_FRAGLIST defined?
> >
> > I don't know of any NIC that can do TSO on a skbuff with fraglist,
> > that's why I try to avoid to have a buffer with fraglist.
> >
> 
> Most of them don't.  There are only one or two NICs out there that
> support transmitting a frame that has a fraglist.
> 
> >> Also what is the issue with having to go
> >> through the GSO layer on segmentation?  It seems like we might be able
> >> to do something like what we did with GSO partial to split frames so
> >> that they are in chunks that wouldn't require NETIF_F_FRAGLIST.  Then
> >> you could get the best of both worlds in that the stack would only
> >> process one super-frame, and the transmitter could TSO a series of
> >> frames that are some fixed MSS in size.
> >
> > This could be interesting. Then we could have a buffer with
> > fraglist, GSO layer splits in skbuffs without fraglist that
> > can be TSO offloaded. Something like this might solve my
> > performance problems.
> 
> Right.  It is something to think about.  I was considering what might
> be involved to make a fraglist based skb a GSO type.  Then we might be
> able to handle it kind of like what we do for the whole
> SKB_GSO_DODGY/NETIF_F_GSO_ROBUST path.  Basically if we just need to
> break the frame at the fraglist level it probably wouldn't be that
> hard to do assuming each skb is MSS aligned in terms of size.

I've tried to implement the idea to split buffers at the frag_list
pointer and ended up with the patch below. With this patch, the
SKB_GSO_PARTIAL case is not the only case where skb_segment() can
return a gso skb. I had to adapt some gso handlers to this, not
sure if I found all places where I have to do this. Works in my
case, but needs review and maybe some more sophisticated tests.

I've could not benchmark this with big packet sizes because my
10G interfaces are the limiting factors then. So I did an iperf
forwarding test with reduced TCP mss to 536 byte.

Result with a recent net-next tree:

net-next 6.67 Gbits/sec

net-next + patch 8.20 Gbits/sec


Subject: [RFC PATCH] gso: Support partial splitting at the frag_list pointer

Since commit 8a29111c7 ("net: gro: allow to build full sized skb")
gro may build buffers with a frag_list. This can hurts forwarding
because most NICs can't offload such packets, they need to be
segmented in software. This patch splits buffers with a frag_list
at the frag_list pointer into buffers that can be TSO offloaded.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/core/skbuff.c      | 90 +++++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/af_inet.c     |  7 ++--
 net/ipv4/gre_offload.c |  7 +++-
 net/ipv4/tcp_offload.c |  3 ++
 net/ipv4/udp_offload.c |  9 +++--
 net/ipv6/ip6_offload.c |  6 +++-
 6 files changed, 115 insertions(+), 7 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e7ec6d3..093c3cd 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3096,6 +3096,93 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	sg = !!(features & NETIF_F_SG);
 	csum = !!can_checksum_protocol(features, proto);
 
+	headroom = skb_headroom(head_skb);
+
+	if (list_skb && net_gso_ok(features, skb_shinfo(head_skb)->gso_type) &&
+	    csum && sg && (mss != GSO_BY_FRAGS) &&
+	    !(features & NETIF_F_GSO_PARTIAL)) {
+		unsigned int lskb_segs;
+		unsigned int delta_segs, delta_len, delta_truesize;
+		struct sk_buff *nskb;
+		delta_segs = delta_len = delta_truesize = 0;
+
+		segs = __alloc_skb(skb_headlen(head_skb) + headroom,
+				   GFP_ATOMIC, skb_alloc_rx_flag(head_skb),
+				   NUMA_NO_NODE);
+		if (unlikely(!segs))
+			return ERR_PTR(-ENOMEM);
+
+		skb_reserve(segs, headroom);
+		skb_put(segs, skb_headlen(head_skb));
+		skb_copy_from_linear_data(head_skb, segs->data, segs->len);
+		copy_skb_header(segs, head_skb);
+
+		if (skb_shinfo(head_skb)->nr_frags) {
+			int i;
+
+			if (skb_orphan_frags(head_skb, GFP_ATOMIC))
+				goto err;
+
+			for (i = 0; i < skb_shinfo(head_skb)->nr_frags; i++) {
+				skb_shinfo(segs)->frags[i] = skb_shinfo(head_skb)->frags[i];
+				skb_frag_ref(head_skb, i);
+			}
+			skb_shinfo(segs)->nr_frags = i;
+		}
+
+		do {
+			nskb = skb_clone(list_skb, GFP_ATOMIC);
+			if (unlikely(!nskb))
+				goto err;
+
+			list_skb = list_skb->next;
+
+			if (!tail)
+				segs->next = nskb;
+			else
+				tail->next = nskb;
+
+			tail = nskb;
+
+			if (skb_cow_head(nskb, doffset + headroom))
+				goto err;
+
+			lskb_segs = nskb->len / mss;
+
+			skb_shinfo(nskb)->gso_size = mss;
+			skb_shinfo(nskb)->gso_type = skb_shinfo(head_skb)->gso_type;
+			skb_shinfo(nskb)->gso_segs = lskb_segs;
+
+
+			delta_segs += lskb_segs;
+			delta_len += nskb->len;
+			delta_truesize += nskb->truesize;
+
+			__skb_push(nskb, doffset);
+
+			skb_release_head_state(nskb);
+			__copy_skb_header(nskb, head_skb);
+
+			skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);
+			skb_reset_mac_len(nskb);
+
+			skb_copy_from_linear_data_offset(head_skb, -tnl_hlen,
+							 nskb->data - tnl_hlen,
+							 doffset + tnl_hlen);
+
+
+		} while (list_skb);
+
+		skb_shinfo(segs)->gso_segs -= delta_segs;
+		segs->len = head_skb->len - delta_len;
+		segs->data_len = head_skb->data_len - delta_len;
+		segs->truesize += head_skb->data_len - delta_truesize;
+
+		segs->prev = tail;
+
+		goto out;
+	}
+
 	/* GSO partial only requires that we trim off any excess that
 	 * doesn't fit into an MSS sized block, so take care of that
 	 * now.
@@ -3108,7 +3195,6 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 			partial_segs = 0;
 	}
 
-	headroom = skb_headroom(head_skb);
 	pos = skb_headlen(head_skb);
 
 	do {
@@ -3325,6 +3411,8 @@ perform_csum_check:
 		swap(tail->destructor, head_skb->destructor);
 		swap(tail->sk, head_skb->sk);
 	}
+
+out:
 	return segs;
 
 err:
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d39e9e4..90ecc22 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1195,7 +1195,7 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
 struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 				 netdev_features_t features)
 {
-	bool udpfrag = false, fixedid = false, encap;
+	bool udpfrag = false, fixedid = false, gso_partial = false, encap;
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	const struct net_offload *ops;
 	unsigned int offset = 0;
@@ -1248,6 +1248,9 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	if (IS_ERR_OR_NULL(segs))
 		goto out;
 
+	if (skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL)
+		gso_partial = true;
+
 	skb = segs;
 	do {
 		iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
@@ -1257,7 +1260,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 				iph->frag_off |= htons(IP_MF);
 			offset += skb->len - nhoff - ihl;
 			tot_len = skb->len - nhoff;
-		} else if (skb_is_gso(skb)) {
+		} else if (skb_is_gso(skb) && gso_partial) {
 			if (!fixedid) {
 				iph->id = htons(id);
 				id += skb_shinfo(skb)->gso_segs;
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index ecd1e09..cf82e28 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -24,7 +24,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	__be16 protocol = skb->protocol;
 	u16 mac_len = skb->mac_len;
 	int gre_offset, outer_hlen;
-	bool need_csum, ufo;
+	bool need_csum, ufo, gso_partial;
 
 	if (!skb->encapsulation)
 		goto out;
@@ -69,6 +69,11 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 		goto out;
 	}
 
+	if (skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL)
+		gso_partial = true;
+	else
+		gso_partial = false;
+
 	outer_hlen = skb_tnl_header_len(skb);
 	gre_offset = outer_hlen - tnl_hlen;
 	skb = segs;
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 5c59649..dddd227 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -107,6 +107,9 @@ struct sk_buff *tcp_gso_segment(struct sk_buff *skb,
 
 	/* Only first segment might have ooo_okay set */
 	segs->ooo_okay = ooo_okay;
+	if (skb_is_gso(segs) && !(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL))
+		mss = (skb_tail_pointer(segs) - skb_transport_header(segs)) +
+		       segs->data_len - thlen;
 
 	delta = htonl(oldlen + (thlen + mss));
 
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 81f253b..dfb6a2c 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -21,7 +21,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	__be16 new_protocol, bool is_ipv6)
 {
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
-	bool remcsum, need_csum, offload_csum, ufo;
+	bool remcsum, need_csum, offload_csum, ufo, gso_partial;
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct udphdr *uh = udp_hdr(skb);
 	u16 mac_offset = skb->mac_header;
@@ -88,6 +88,11 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		goto out;
 	}
 
+	if (skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL)
+		gso_partial = true;
+	else
+		gso_partial = false;
+
 	outer_hlen = skb_tnl_header_len(skb);
 	udp_offset = outer_hlen - tnl_hlen;
 	skb = segs;
@@ -117,7 +122,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		 * will be using a length value equal to only one MSS sized
 		 * segment instead of the entire frame.
 		 */
-		if (skb_is_gso(skb)) {
+		if (skb_is_gso(skb) && gso_partial) {
 			uh->len = htons(skb_shinfo(skb)->gso_size +
 					SKB_GSO_CB(skb)->data_offset +
 					skb->head - (unsigned char *)uh);
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 22e90e5..0ec16ba 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -69,6 +69,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	int offset = 0;
 	bool encap, udpfrag;
 	int nhoff;
+	bool gso_partial = false;
 
 	skb_reset_network_header(skb);
 	nhoff = skb_network_header(skb) - skb_mac_header(skb);
@@ -101,9 +102,12 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	if (IS_ERR(segs))
 		goto out;
 
+	if (skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL)
+		gso_partial = true;
+
 	for (skb = segs; skb; skb = skb->next) {
 		ipv6h = (struct ipv6hdr *)(skb_mac_header(skb) + nhoff);
-		if (skb_is_gso(skb))
+		if (skb_is_gso(skb) && gso_partial)
 			payload_len = skb_shinfo(skb)->gso_size +
 				      SKB_GSO_CB(skb)->data_offset +
 				      skb->head - (unsigned char *)(ipv6h + 1);
-- 
1.9.1
