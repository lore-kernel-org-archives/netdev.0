From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 5/5] openvswitch: Interface with NAT.
Date: Wed, 21 Oct 2015 12:59:16 +0200
Message-ID: <20151021105916.GB15766@pox.localdomain>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com>
 <1445379629-112880-5-git-send-email-jrajahalme@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	netfilter-devel@vger.kernel.org
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445379629-112880-5-git-send-email-jrajahalme@nicira.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/15 at 03:20pm, Jarno Rajahalme wrote:
> Extend OVS conntrack interface to cover NAT.  New nested
> OVS_CT_ATTR_NAT may be used to include NAT with a CT action.  A bare
> OVS_CT_ATTR_NAT only mangles existing connections.  If
> OVS_NAT_ATTR_SRC or OVS_NAT_ATTR_DST is included within the nested
> attributes, new (non-committed/non-confirmed) connections are mangled
> according to the rest of the nested attributes.
> 
> This work extends on a branch by Thomas Graf at
> https://github.com/tgraf/ovs/tree/nat.
> 
> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>

Awesome work. This is a great start.

There are some, probably unintended, unrelated style changes. More
comments below.

> +enum ovs_nat_attr {
> +	OVS_NAT_ATTR_UNSPEC,
> +	OVS_NAT_ATTR_SRC,
> +	OVS_NAT_ATTR_DST,
> +	OVS_NAT_ATTR_IP_MIN,
> +	OVS_NAT_ATTR_IP_MAX,
> +	OVS_NAT_ATTR_PROTO_MIN,
> +	OVS_NAT_ATTR_PROTO_MAX,
> +	OVS_NAT_ATTR_PERSISTENT,
> +	OVS_NAT_ATTR_PROTO_HASH,
> +	OVS_NAT_ATTR_PROTO_RANDOM,

Simplify this with an OVS_NAT_ATTR_FLAGS?

> @@ -137,11 +159,17 @@ static void __ovs_ct_update_key(struct sw_flow_key *key, u8 state,
>  	ovs_ct_get_label(ct, &key->ct.label);
>  }
>  
> -/* Update 'key' based on skb->nfct. If 'post_ct' is true, then OVS has
> - * previously sent the packet to conntrack via the ct action.
> +/* Update 'key' based on skb->nfct.  If 'post_ct' is true, then OVS has
> + * previously sent the packet to conntrack via the ct action.  If
> + * 'keep_nat_flags' is true, the existing NAT flags retained, else they are
> + * initialized from the connection status.
>   */
>  static void ovs_ct_update_key(const struct sk_buff *skb,
> -			      struct sw_flow_key *key, bool post_ct)
> +			      struct sw_flow_key *key, bool post_ct
> +#ifdef CONFIG_NF_NAT_NEEDED
> +			      , bool keep_nat_flags
> +#endif
> +			      )

I suggest keeping the argument even for !CONFIG_NF_NAT_NEEDED. This
unclutters the call sites of this function. An ifdef inside the
keep_nat_flags branch should be enough. The compiler will optimize
the code away and it's much prettier to read.

>  {
>  	const struct nf_conntrack_zone *zone = &nf_ct_zone_dflt;
>  	enum ip_conntrack_info ctinfo;
> @@ -151,8 +179,20 @@ static void ovs_ct_update_key(const struct sk_buff *skb,
>  	ct = nf_ct_get(skb, &ctinfo);
>  	if (ct) {
>  		state = ovs_ct_get_state(ctinfo);
> +		/* OVS persists the related flag for the duration of the
> +		 * connection. */
>  		if (ct->master)
>  			state |= OVS_CS_F_RELATED;
> +#ifdef CONFIG_NF_NAT_NEEDED
> +		if (keep_nat_flags)
> +			state |= key->ct.state & OVS_CS_F_NAT_MASK;
> +		else {
> +			if (ct->status & IPS_SRC_NAT)
> +				state |= OVS_CS_F_SRC_NAT;
> +			if (ct->status & IPS_DST_NAT)
> +				state |= OVS_CS_F_DST_NAT;
> +		}
> +#endif
>  		zone = nf_ct_zone(ct);
>  	} else if (post_ct) {
>  		state = OVS_CS_F_TRACKED | OVS_CS_F_INVALID;
> @@ -291,7 +337,16 @@ static int ovs_ct_helper(struct sk_buff *skb, u16 proto)
>  		return NF_DROP;
>  	}
>  
> -	return helper->help(skb, protoff, ct, ctinfo);
> +	if (helper->help(skb, protoff, ct, ctinfo) != NF_ACCEPT)
> +		return NF_DROP;

Return the returned value here instead of hardcoding NF_DROP?

> +#ifdef CONFIG_NF_NAT_NEEDED
> +	/* Adjust seqs after helper. */

A comment on why this is needed would be helpful.

> +	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status)
> +	    && !nf_ct_seq_adjust(skb, ct, ctinfo, protoff))
> +		return NF_DROP;
> +#endif
> +	return NF_ACCEPT;

> @@ -377,7 +432,211 @@ static bool skb_nfct_cached(const struct net *net, const struct sk_buff *skb,
>  	return true;
>  }
>  
> -static int __ovs_ct_lookup(struct net *net, const struct sw_flow_key *key,
> +#ifdef CONFIG_NF_NAT_NEEDED
> +/* Modeled after nf_nat_ipv[46]_fn().
> + * range is only used for new, uninitialized NAT state.
> + * Returns either NF_ACCEPT or NF_DROP. */
> +static int ovs_ct_nat_execute(struct sk_buff *skb, struct nf_conn *ct,
> +			      enum ip_conntrack_info ctinfo,
> +			      const struct nf_nat_range *range,
> +			      enum nf_nat_manip_type maniptype)
> +{
> +	int hooknum, nh_off, err = NF_ACCEPT;
> +
> +	nh_off = skb_network_offset(skb);
> +	skb_pull(skb, nh_off);
> +
> +	/* See HOOK2MANIP(). */
> +	if (maniptype == NF_NAT_MANIP_SRC)
> +		hooknum = NF_INET_LOCAL_IN; /* Source NAT */
> +	else
> +		hooknum = NF_INET_LOCAL_OUT; /* Destination NAT */
> +
> +	switch (ctinfo) {
> +	case IP_CT_RELATED:
> +	case IP_CT_RELATED_REPLY:
> +		if (skb->protocol == htons(ETH_P_IP)
> +		    && ip_hdr(skb)->protocol == IPPROTO_ICMP) {
> +			if (!nf_nat_icmp_reply_translation(skb, ct, ctinfo,
> +							   hooknum))
> +				err = NF_DROP;
> +			goto push;
> +		} else if (skb->protocol == htons(ETH_P_IPV6)) {
> +			__be16 frag_off;
> +			u8 nexthdr = ipv6_hdr(skb)->nexthdr;
> +			int hdrlen = ipv6_skip_exthdr(skb,
> +						      sizeof(struct ipv6hdr),
> +						      &nexthdr, &frag_off);
> +
> +			if (hdrlen >= 0 && nexthdr == IPPROTO_ICMPV6) {
> +				if (!nf_nat_icmpv6_reply_translation(skb, ct,
> +								     ctinfo,
> +								     hooknum,
> +								     hdrlen))
> +					err = NF_DROP;
> +				goto push;
> +			}
> +		}
> +		/* Non-ICMP, fall thru to initialize if needed. */
> +	case IP_CT_NEW:
> +		/* Seen it before?  This can happen for loopback, retrans,
> +		 * or local packets.
> +		 */
> +		if (!nf_nat_initialized(ct, maniptype)) {

Explicit unlikely()?

> +			/* Initialize according to the NAT action. */
> +			err = (range && range->flags & NF_NAT_RANGE_MAP_IPS)
> +				/* Action is set up to establish a new
> +				 * mapping */
> +				? nf_nat_setup_info(ct, range, maniptype)
> +				: nf_nat_alloc_null_binding(ct, hooknum);
> +		}
> +		break;
> +
> +	case IP_CT_ESTABLISHED:
> +	case IP_CT_ESTABLISHED_REPLY:
> +		break;
> +
> +	default:
> +		err = NF_DROP;
> +		goto push;
> +	}
> +
> +	if (err == NF_ACCEPT)
> +		err = nf_nat_packet(ct, ctinfo, hooknum, skb);

If you goto push on init failure (IP_CT_NEW branch), then this
conditional is no longer needed and a more straight forward exception
handling is seen.

> +push:
> +	skb_push(skb, nh_off);
> +
> +	return err;
> +}

> +/* Returns NF_DROP if the packet should be dropped, NF_ACCEPT otherwise.
> + * This action can be used to both NAT and reverse NAT, however, reverse NAT
> + * can also be done with the conntrack action. */
> +static int ovs_ct_nat(struct net *net, struct sw_flow_key *key,
> +		      const struct ovs_conntrack_info *info,
> +		      struct sk_buff *skb)
> +{
> +	enum nf_nat_manip_type maniptype;
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct;
> +	int err;
> +
> +	/* No NAT action or already NATed? */
> +	if (!(info->flags & OVS_CT_F_NAT_MASK)
> +	    || key->ct.state & OVS_CS_F_NAT_MASK)
> +		return NF_ACCEPT;
> +
> +	ct = nf_ct_get(skb, &ctinfo);
> +	/* Check if an existing conntrack entry may be found for this skb.
> +	 * This happens when we lose the ct entry pointer due to an upcall.
> +	 * Don't lookup invalid connections. */
> +	if (!ct && key->ct.state & OVS_CS_F_TRACKED
> +	    && !(key->ct.state & OVS_CS_F_INVALID))
> +		ct = ovs_ct_find_existing(net, &info->zone, info->family, skb,
> +					  &ctinfo);
> +	if (!ct || nf_ct_is_untracked(ct))
> +		/* A NAT action may only be performed on tracked packets. */
> +		return NF_ACCEPT;

Braces

> +	/* Add NAT extension if not commited yet. */
> +	if (!nf_ct_is_confirmed(ct)) {
> +		if (!nf_ct_nat_ext_add(ct))
> +			return NF_ACCEPT;   /* Can't NAT. */
> +	}

&&

> +	/* Determine NAT type.
> +	 * Check if the NAT type can be deduced from the tracked connection.
> +	 * Make sure expected traffic is NATted only when commiting. */
> +	if (info->flags & OVS_CT_F_NAT && ctinfo != IP_CT_NEW
> +	    && ct->status & IPS_NAT_MASK
> +	    && (!(ct->status & IPS_EXPECTED_BIT)
> +		|| info->flags & OVS_CT_F_COMMIT)) {
> +		/* NAT an established or related connection like before. */
> +		if (CTINFO2DIR(ctinfo) == IP_CT_DIR_REPLY)
> +			/* This is the REPLY direction for a connection
> +			 * for which NAT was applied in the forward
> +			 * direction.  Do the reverse NAT. */
> +			maniptype = ct->status & IPS_SRC_NAT
> +				? NF_NAT_MANIP_DST : NF_NAT_MANIP_SRC;
> +		else
> +			maniptype = ct->status & IPS_SRC_NAT
> +				? NF_NAT_MANIP_SRC : NF_NAT_MANIP_DST;
> +	}
> +	else if (info->flags & OVS_CT_F_SRC_NAT)
> +		maniptype = NF_NAT_MANIP_SRC;
> +	else if (info->flags & OVS_CT_F_DST_NAT)
> +		maniptype = NF_NAT_MANIP_DST;
> +	else
> +		return NF_ACCEPT; /* Connection is not NATed. */
> +
> +	err = ovs_ct_nat_execute(skb, ct, ctinfo, &info->range, maniptype);
> +
> +	/* Mark NAT done if successful. */
> +	if (err == NF_ACCEPT)
> +		key->ct.state |= (maniptype == NF_NAT_MANIP_SRC)
> +			? OVS_CS_F_SRC_NAT : OVS_CS_F_DST_NAT;
> +	return err;
> +}
> +#endif
> +
> +static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
>  			   const struct ovs_conntrack_info *info,
>  			   struct sk_buff *skb)
>  {


> @@ -538,6 +819,131 @@ static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
>  	return 0;
>  }
>  
> +#ifdef CONFIG_NF_NAT_NEEDED
> +static int parse_nat(const struct nlattr *attr,
> +		     struct ovs_conntrack_info *info, bool log)
> +{
> +	struct nlattr *a;
> +	int rem;
> +	bool have_ip_max = false;
> +	bool have_proto_max = false;
> +	bool ip_vers = (info->family == NFPROTO_IPV6);
> +
> +	nla_for_each_nested(a, attr, rem) {
> +		static const u16 ovs_nat_attr_lens[OVS_NAT_ATTR_MAX + 1][2] = {
> +			[OVS_NAT_ATTR_SRC] = {0, 0},
> +			[OVS_NAT_ATTR_DST] = {0, 0},
> +			[OVS_NAT_ATTR_IP_MIN] = {sizeof(struct in_addr),
> +						 sizeof(struct in6_addr)},
> +			[OVS_NAT_ATTR_IP_MAX] = {sizeof(struct in_addr),
> +						 sizeof(struct in6_addr)},
> +			[OVS_NAT_ATTR_PROTO_MIN] = {sizeof(u16),sizeof(u16)},
> +			[OVS_NAT_ATTR_PROTO_MAX] = {sizeof(u16),sizeof(u16)},
> +			[OVS_NAT_ATTR_PERSISTENT] = {0, 0},
> +			[OVS_NAT_ATTR_PROTO_HASH] = {0, 0},
> +			[OVS_NAT_ATTR_PROTO_RANDOM] = {0, 0},
> +		};
> +		int type = nla_type(a);
> +
> +		if (type > OVS_NAT_ATTR_MAX) {
> +			OVS_NLERR(log, "Unknown nat attribute (type=%d, max=%d).\n",
> +			type, OVS_NAT_ATTR_MAX);

Formatting

> +			return -EINVAL;
> +		}
> +
> +		case OVS_NAT_ATTR_IP_MIN:
> +			nla_memcpy(&info->range.min_addr, a, nla_len(a));

The length attribute should be sizeof of min_addr like for max_addr
below.

> +			info->range.flags |= NF_NAT_RANGE_MAP_IPS;
> +			break;
> +
> +		case OVS_NAT_ATTR_IP_MAX:
> +			have_ip_max = true;
> +			nla_memcpy(&info->range.max_addr, a,
> +				   sizeof(info->range.max_addr));
> +			info->range.flags |= NF_NAT_RANGE_MAP_IPS;
> +			break;
> +
> +	}

>  static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
>  	[OVS_CT_ATTR_COMMIT]	= { .minlen = 0,
>  				    .maxlen = 0 },
> @@ -548,7 +954,11 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
>  	[OVS_CT_ATTR_LABEL]	= { .minlen = sizeof(struct md_label),
>  				    .maxlen = sizeof(struct md_label) },
>  	[OVS_CT_ATTR_HELPER]	= { .minlen = 1,
> -				    .maxlen = NF_CT_HELPER_NAME_LEN }
> +				    .maxlen = NF_CT_HELPER_NAME_LEN },
> +#ifdef CONFIG_NF_NAT_NEEDED
> +	[OVS_CT_ATTR_NAT]	= { .minlen = 0,
> +				    .maxlen = 96 }
> +#endif

Is the 96 a temporary hack here?

> @@ -607,6 +1017,14 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
>  				return -EINVAL;
>  			}
>  			break;
> +#ifdef CONFIG_NF_NAT_NEEDED
> +		case OVS_CT_ATTR_NAT: {
> +			int err = parse_nat(a, info, log);
> +			if (err)
> +				return err;
> +			break;
> +		}
> +#endif

We should probably bark if user space provides a OVS_CT_ATTR_NAT but the
kernel is compiled without support for it.

> +#ifdef CONFIG_NF_NAT_NEEDED
> +static bool ovs_ct_nat_to_attr(const struct ovs_conntrack_info *info,
> +			       struct sk_buff *skb)
> +{
> +	struct nlattr *start;
> +
> +	start = nla_nest_start(skb, OVS_CT_ATTR_NAT);
> +	if (!start)
> +		return false;
> +
> +	if (info->flags & OVS_CT_F_SRC_NAT) {
> +		if (nla_put_flag(skb, OVS_NAT_ATTR_SRC))
> +			return false;
> +	} else if (info->flags & OVS_CT_F_DST_NAT) {
> +		if (nla_put_flag(skb, OVS_NAT_ATTR_DST))
> +			return false;
> +	} else {
> +		goto out;

Is the empty nested attribute intended here?
