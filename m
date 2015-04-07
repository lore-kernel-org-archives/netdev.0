From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v3 4/4] mpls: Allow payload type to be associated with label routes
Date: Tue, 07 Apr 2015 12:19:54 -0500
Message-ID: <87y4m3j1ol.fsf@x220.int.ebiederm.org>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-5-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:47261 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752914AbbDGRX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 13:23:57 -0400
In-Reply-To: <1427739356-28113-5-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Mon, 30 Mar 2015 19:15:56 +0100")
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

This looks pretty reasonable.

I suspect the multiple returns instead of using a single variable
might generate slightly worse machine but whatever.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>


> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  net/mpls/af_mpls.c | 72 ++++++++++++++++++++++++++++++++----------------------
>  1 file changed, 43 insertions(+), 29 deletions(-)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 0b0420bf110d..e9ce5799449d 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -23,13 +23,25 @@
>  /* This maximum ha length copied from the definition of struct neighbour */
>  #define MAX_VIA_ALEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
>  
> +enum mpls_payload_type {
> +	MPT_UNSPEC, /* IPv4 or IPv6 */
> +	MPT_IPV4 = 4,
> +	MPT_IPV6 = 6,
> +
> +	/* Other types not implemented:
> +	 *  - Pseudo-wire with or without control word (RFC4385)
> +	 *  - GAL (RFC5586)
> +	 */
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
> @@ -90,16 +102,7 @@ static bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
>  static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>  			struct mpls_entry_decoded dec)
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
> +	enum mpls_payload_type payload_type;
>  
>  	/* The IPv4 code below accesses through the IPv4 header
>  	 * checksum, which is 12 bytes into the packet.
> @@ -114,24 +117,31 @@ static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
>  	if (!pskb_may_pull(skb, 12))
>  		return false;
>  
> -	/* Use ip_hdr to find the ip protocol version */
> -	hdr4 = ip_hdr(skb);
> -	if (hdr4->version == 4) {
> +	payload_type = rt->rt_payload_type;
> +	if (payload_type == MPT_UNSPEC)
> +		payload_type = ip_hdr(skb)->version;
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
> +	}
> +	case MPT_UNSPEC:
> +		break;
>  	}
> -	else
> -		/* version 0 and version 1 are used by pseudo wires */
> -		success = false;
> -	return success;
> +
> +	return false;
>  }
>  
>  static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
> @@ -254,16 +264,17 @@ static const struct nla_policy rtm_mpls_policy[RTA_MAX+1] = {
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
> @@ -414,6 +425,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
>  	}
>  	rt->rt_protocol = cfg->rc_protocol;
>  	RCU_INIT_POINTER(rt->rt_dev, dev);
> +	rt->rt_payload_type = cfg->rc_payload_type;
>  	rt->rt_via_table = cfg->rc_via_table;
>  	memcpy(rt->rt_via, cfg->rc_via, cfg->rc_via_alen);
>  
> @@ -949,6 +961,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
>  			goto nort0;
>  		RCU_INIT_POINTER(rt0->rt_dev, lo);
>  		rt0->rt_protocol = RTPROT_KERNEL;
> +		rt0->rt_payload_type = MPT_IPV4;
>  		rt0->rt_via_table = NEIGH_LINK_TABLE;
>  		memcpy(rt0->rt_via, lo->dev_addr, lo->addr_len);
>  	}
> @@ -959,6 +972,7 @@ static int resize_platform_label_table(struct net *net, size_t limit)
>  			goto nort2;
>  		RCU_INIT_POINTER(rt2->rt_dev, lo);
>  		rt2->rt_protocol = RTPROT_KERNEL;
> +		rt2->rt_payload_type = MPT_IPV6;
>  		rt2->rt_via_table = NEIGH_LINK_TABLE;
>  		memcpy(rt2->rt_via, lo->dev_addr, lo->addr_len);
>  	}
