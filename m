From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net-next v1] gso: Support partial splitting at the
 frag_list pointer
Date: Thu, 25 Aug 2016 09:38:56 -0300
Message-ID: <20160825123856.GB13235@localhost.localdomain>
References: <20160823052030.GI3735@gauss.secunet.com>
 <CAKgT0UdATK8LUiTQ3sn0nrJTtk9oo29k7CrNdZavsPie_Pte0w@mail.gmail.com>
 <20160824093226.GN3735@gauss.secunet.com>
 <CAKgT0Ucp_M-oCDjvi2Aay=aNBTH=-sGEVxUgq0b=5KrX8j3O9Q@mail.gmail.com>
 <20160825110019.GR3735@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58618 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759007AbcHYMj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 08:39:56 -0400
Content-Disposition: inline
In-Reply-To: <20160825110019.GR3735@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 01:00:19PM +0200, Steffen Klassert wrote:
> On Wed, Aug 24, 2016 at 09:27:54AM -0700, Alexander Duyck wrote:
> > 
> > In you case though we maybe be able to make this easier.  If I am not
> > mistaken I believe we should have the main skb, and any in the chain
> > excluding the last containing the same amount of data. 
> 
> Yes, it seems to be like that. With this observation we can spmplify
> things. 
> 
> > That being the
> > case we should be able to determine the size that you would need to
> > segment at by taking skb->len, and removing the length of all the
> > skbuffs hanging off of frag_list.  At that point you just use that as
> > your MSS for segmentation and it should break things up so that you
> > have a series of equal sized segments split as the frag_list buffer
> > boundaries.
> > 
> > After that all that is left is to update the gso info for the buffers.
> > For GSO_PARTIAL I was handling that on the first segment only.  For
> > this change you would need to update that code to address the fact
> > that you would have to determine the number of segments on the first
> > frame and the last since the last could be less than the first, but
> > all of the others in-between should have the same number of segments.
> 
> I tried to do this and ended up with the patch below.
> Seems to work, but sill needs some tests. So it is
> not an official patch submission.
> 
> Subject: [PATCH net-next RFC] gso: Support partial splitting at the frag_list pointer
> 
> Since commit 8a29111c7 ("net: gro: allow to build full sized skb")
> gro may build buffers with a frag_list. This can hurt forwarding
> because most NICs can't offload such packets, they need to be
> segmented in software. This patch splits buffers with a frag_list
> at the frag_list pointer into buffers that can be TSO offloaded.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  net/core/skbuff.c      | 46 ++++++++++++++++++++++++++++++++++++----------
>  net/ipv4/af_inet.c     |  6 ++++--
>  net/ipv4/gre_offload.c |  4 +++-
>  net/ipv4/tcp_offload.c |  3 +++
>  net/ipv4/udp_offload.c |  6 ++++--
>  net/ipv6/ip6_offload.c |  5 ++++-
>  6 files changed, 54 insertions(+), 16 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 3864b4b6..cb326e5 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3060,6 +3060,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  	unsigned int offset = doffset;
>  	unsigned int tnl_hlen = skb_tnl_header_len(head_skb);
>  	unsigned int partial_segs = 0;
> +	unsigned int fraglist_segs = 0;
>  	unsigned int headroom;
>  	unsigned int len = head_skb->len;
>  	__be16 proto;
> @@ -3078,16 +3079,27 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
>  	sg = !!(features & NETIF_F_SG);
>  	csum = !!can_checksum_protocol(features, proto);
>  
> -	/* GSO partial only requires that we trim off any excess that
> -	 * doesn't fit into an MSS sized block, so take care of that
> -	 * now.
> -	 */
> -	if (sg && csum && (features & NETIF_F_GSO_PARTIAL)) {
> -		partial_segs = len / mss;
> -		if (partial_segs > 1)
> -			mss *= partial_segs;
> -		else
> -			partial_segs = 0;
> +	if (sg && csum) {
> +		/* GSO partial only requires that we trim off any excess that
> +		 * doesn't fit into an MSS sized block, so take care of that
> +		 * now.
> +		 */
> +		if ((features & NETIF_F_GSO_PARTIAL)) {
> +			partial_segs = len / mss;
> +			if (partial_segs > 1)
> +				mss *= partial_segs;
> +			else
> +				partial_segs = 0;
> +		} else if (list_skb && (mss != GSO_BY_FRAGS) &&
> +			   net_gso_ok(features, skb_shinfo(head_skb)->gso_type)) {
> +
> +			skb_walk_frags(head_skb, segs) {
> +				len -= segs->len;
> +			}
> +			fraglist_segs = len / mss;
> +			mss = len;
> +			segs = NULL;
> +		}
>  	}
>  
>  	headroom = skb_headroom(head_skb);
> @@ -3298,6 +3310,20 @@ perform_csum_check:
>  		SKB_GSO_CB(segs)->data_offset = skb_headroom(segs) + doffset;
>  	}
>  
> +	if (fraglist_segs) {
> +		struct sk_buff *iter;
> +
> +		for (iter = segs; iter; iter = iter->next) {
> +			if (iter->next) {
> +				skb_shinfo(iter)->gso_size = skb_shinfo(head_skb)->gso_size;
> +				skb_shinfo(iter)->gso_segs = fraglist_segs;
> +			} else {
> +				skb_shinfo(iter)->gso_size = skb_shinfo(head_skb)->gso_size;
> +				skb_shinfo(iter)->gso_segs = iter->len / skb_shinfo(head_skb)->gso_size;
> +			}
> +		}
> +	}
> +
>  	/* Following permits correct backpressure, for protocols
>  	 * using skb_set_owner_w().
>  	 * Idea is to tranfert ownership from head_skb to last segment.
> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 989a362..ac46233 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1190,7 +1190,7 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
>  struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>  				 netdev_features_t features)
>  {
> -	bool udpfrag = false, fixedid = false, encap;
> +	bool udpfrag = false, fixedid = false, gso_partial, encap;
>  	struct sk_buff *segs = ERR_PTR(-EINVAL);
>  	const struct net_offload *ops;
>  	unsigned int offset = 0;
> @@ -1243,6 +1243,8 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>  	if (IS_ERR_OR_NULL(segs))
>  		goto out;
>  
> +	gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> +
>  	skb = segs;
>  	do {
>  		iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
> @@ -1252,7 +1254,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
>  				iph->frag_off |= htons(IP_MF);
>  			offset += skb->len - nhoff - ihl;
>  			tot_len = skb->len - nhoff;
> -		} else if (skb_is_gso(skb)) {
> +		} else if (skb_is_gso(skb) && gso_partial) {
>  			if (!fixedid) {
>  				iph->id = htons(id);
>  				id += skb_shinfo(skb)->gso_segs;
> diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
> index ecd1e09..7c56785 100644
> --- a/net/ipv4/gre_offload.c
> +++ b/net/ipv4/gre_offload.c
> @@ -24,7 +24,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>  	__be16 protocol = skb->protocol;
>  	u16 mac_len = skb->mac_len;
>  	int gre_offset, outer_hlen;
> -	bool need_csum, ufo;
> +	bool need_csum, ufo, gso_partial;
>  
>  	if (!skb->encapsulation)
>  		goto out;
> @@ -69,6 +69,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
>  		goto out;
>  	}
>  
> +	gso_partial = !!(skb_shinfo(segs)->gso_type & SKB_GSO_PARTIAL);
> +

This is set but not used here in GRE code, probably just missed a
chunk in this version..

You probably want to wrap this into a helper, like:

static inline bool skb_is_gso_partial(struct sk_buff *skb)
{
	return !!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL);
}

It would save you from defining a local var for this.
Maybe even make it also consider the skb_is_gso() check too, as you
seem to always have (skb_is_gso() && skb_is_gso_partial()) and if it's
gso_partial, it should also be gso anyway.

(I didn't check skb_segment part of the patch)

  Marcelo
