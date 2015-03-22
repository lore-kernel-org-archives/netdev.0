From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v2 5/5] mpls: Allow payload type to be associated with label routes
Date: Sun, 22 Mar 2015 15:56:53 -0500
Message-ID: <87sicw4up6.fsf@x220.int.ebiederm.org>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
	<1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1426866170-28739-6-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37143 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbbCVVAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 17:00:43 -0400
In-Reply-To: <1426866170-28739-6-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Fri, 20 Mar 2015 15:42:50 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> RFC 4182 s2 states that if an IPv4 Explicit NULL label is the only
> label on the stack, then after popping the resulting packet must be
> treated as a IPv4 packet and forwarded based on the IPv4 header. The
> same is true for IPv6 Explicit NULL with an IPv6 packet following.
>
> Therefore, when installing the IPv4/IPv6 Explicit NULL label routes,
> add an attribute that specifies the expected payload type for use at
> forwarding time for determining the type of the encapsulated packet
> instead of inspecting the first nibble of the packet.

So this patch is not wrong.  And it at a practical level it is a good
idea to enforce ipv4 when the ipv4 explicit null label is present
and similarly with ipv6.

I do have some quibbles.

First I want to point out that in RFC3032 section 2.2 talks about using
a label in combination of with the packets contents to figure out the
type of packet that is being transmitted.  IPv4 and IPv6 do count as a
set of network layer protocols that can be distinguished by inspection
of the network layer header.

Changing mpls_egress to mpls_bos_egress bothers me a little, because it
seems redundant.  But I can see an argument for that name change.

I think it would be cleaner if we set MPT_IPV4 = 4 and MPT_IPV6 = 6.
which would remove a switch statement mpls_pkt_determine_af.

You delete my big fat comment referring people to how packets are
encoded in mpls.  That seems unfortunate, because it can be easy to get
lost in the MPLS rfcs, and I am certain someone will want to do more
than support IPv4 and IPv6.

Given the number of pseudo wire types I do believe that 3 bits is going
to be too small to encode everything going forward. 

> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  net/mpls/af_mpls.c | 87 ++++++++++++++++++++++++++++++++++--------------------
>  1 file changed, 55 insertions(+), 32 deletions(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 14c7e76..653bae1 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -23,13 +23,20 @@
>  /* This maximum ha length copied from the definition of struct neighbour */
>  #define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
>  
> +enum mpls_payload_type {
> +	MPT_UNSPEC, /* IPv4 or IPv6 */
> +	MPT_IPV4,
> +	MPT_IPV6,
> +};
> +
>  struct mpls_route { /* next hop label forwarding entry */
>  	struct net_device __rcu *rt_dev;
>  	struct rcu_head		rt_rcu;
>  	u32			rt_label[MAX_NEW_LABELS];
>  	u8			rt_protocol; /* routing protocol that set this entry */
>  	u8                      rt_unlabeled : 1;
> -	u8			rt_labels : 7;
> +	u8                      rt_payload_type : 3;
> +	u8			rt_labels : 4;
>  	u8			rt_via_alen;
>  	u8			rt_via_table;
>  	u8			rt_via[0];
> @@ -87,19 +94,24 @@ static bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
>  	return true;
>  }
>  
> -static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
> -			struct mpls_entry_decoded dec)
> +static enum mpls_payload_type mpls_pkt_determine_af(struct sk_buff *skb)
>  {
> -	/* RFC4385 and RFC5586 encode other packets in mpls such that
> -	 * they don't conflict with the ip version number, making
> -	 * decoding by examining the ip version correct in everything
> -	 * except for the strangest cases.
> -	 *
> -	 * The strange cases if we choose to support them will require
> -	 * manual configuration.
> -	 */
> -	struct iphdr *hdr4;
> -	bool success = true;
> +	struct iphdr *hdr4 = ip_hdr(skb);
> +
> +	switch (hdr4->version) {
> +	case 4:
> +		return MPT_IPV4;
> +	case 6:
> +		return MPT_IPV6;
> +	}
> +
> +	return MPT_UNSPEC;
> +}
> +
> +static bool mpls_bos_egress(struct mpls_route *rt, struct sk_buff *skb,
> +			    struct mpls_entry_decoded dec)
> +{
> +	enum mpls_payload_type payload_type;
>  
>  	/* The IPv4 code below accesses through the IPv4 header
>  	 * checksum, which is 12 bytes into the packet.
> @@ -114,24 +126,31 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>  	if (!pskb_may_pull(skb, 12))
>  		return false;
>  
> -	/* Use ip_hdr to find the ip protocol version */
> -	hdr4 = ip_hdr(skb);
> -	if (hdr4->version == 4) {
> +	payload_type = rt->rt_payload_type;
> +	if (payload_type == MPT_UNSPEC)
> +		payload_type = mpls_pkt_determine_af(skb);
> +
> +	switch (payload_type) {
> +	case MPT_IPV4: {
> +		struct iphdr *hdr4 = ip_hdr(skb);
>  		skb->protocol = htons(ETH_P_IP);
>  		csum_replace2(&hdr4->check,
>  			      htons(hdr4->ttl << 8),
>  			      htons(dec.ttl << 8));
>  		hdr4->ttl = dec.ttl;
> +		return true;
>  	}
> -	else if (hdr4->version == 6) {
> +	case MPT_IPV6: {
>  		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
>  		skb->protocol = htons(ETH_P_IPV6);
>  		hdr6->hop_limit = dec.ttl;
> +		return true;
>  	}
> -	else
> -		/* version 0 and version 1 are used by pseudo wires */
> -		success = false;
> -	return success;
> +	case MPT_UNSPEC:
> +		break;
> +	}
> +
> +	return false;
>  }
>  
>  static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
> @@ -210,7 +229,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
>  	skb->protocol = htons(ETH_P_MPLS_UC);
>  
>  	if (unlikely(!new_header_size && dec.bos)) {
> -		if (!mpls_egress(rt, skb, dec))
> +		if (!mpls_bos_egress(rt, skb, dec))
>  			goto drop;
>  	} else if (rt->rt_unlabeled) {
>  		/* Labeled traffic destined to unlabeled peer should
> @@ -253,16 +272,17 @@ static const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
>  };
>  
>  struct mpls_route_config {
> -	u32		rc_protocol;
> -	u32		rc_ifindex;
> -	u16		rc_via_table;
> -	u16		rc_via_alen;
> -	u8		rc_via[MAX_VIA_ALEN];
> -	u32		rc_label;
> -	u32		rc_output_labels;
> -	u32		rc_output_label[MAX_NEW_LABELS];
> -	u32		rc_nlflags;
> -	struct nl_info	rc_nlinfo;
> +	u32			rc_protocol;
> +	u32			rc_ifindex;
> +	u16			rc_via_table;
> +	u16			rc_via_alen;
> +	u8			rc_via[MAX_VIA_ALEN];
> +	u32			rc_label;
> +	u32			rc_output_labels;
> +	u32			rc_output_label[MAX_NEW_LABELS];
> +	u32			rc_nlflags;
> +	enum mpls_payload_type	rc_payload_type;
> +	struct nl_info		rc_nlinfo;
>  };
>  
>  static struct mpls_route *mpls_rt_alloc(size_t alen)
> @@ -413,6 +433,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
>  	}
>  	rt->rt_protocol = cfg->rc_protocol;
>  	RCU_INIT_POINTER(rt->rt_dev, dev);
> +	rt->rt_payload_type = cfg->rc_payload_type;
>  	rt->rt_via_table = cfg->rc_via_table;
>  	memcpy(rt->rt_via, cfg->rc_via, cfg->rc_via_alen);
>  
> @@ -948,6 +969,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
>  			goto nort0;
>  		RCU_INIT_POINTER(rt0->rt_dev, lo);
>  		rt0->rt_protocol = RTPROT_KERNEL;
> +		rt0->rt_payload_type = MPT_IPV4;
>  		rt0->rt_via_table = NEIGH_LINK_TABLE;
>  		memcpy(rt0->rt_via, lo->dev_addr, lo->addr_len);
>  	}
> @@ -958,6 +980,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
>  			goto nort2;
>  		RCU_INIT_POINTER(rt2->rt_dev, lo);
>  		rt2->rt_protocol = RTPROT_KERNEL;
> +		rt2->rt_payload_type = MPT_IPV6;
>  		rt2->rt_via_table = NEIGH_LINK_TABLE;
>  		memcpy(rt2->rt_via, lo->dev_addr, lo->addr_len);
>  	}
