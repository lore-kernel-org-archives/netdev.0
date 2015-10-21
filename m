From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: Re: [RFC PATCH 5/5] openvswitch: Interface with NAT.
Date: Wed, 21 Oct 2015 14:04:35 -0700
Message-ID: <FB21AAF8-5C91-41C8-96DC-E5EE0C02CFE4@nicira.com>
References: <1445379629-112880-1-git-send-email-jrajahalme@nicira.com> <1445379629-112880-5-git-send-email-jrajahalme@nicira.com> <20151021105916.GB15766@pox.localdomain>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20151021105916.GB15766@pox.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On Oct 21, 2015, at 3:59 AM, Thomas Graf <tgraf@suug.ch> wrote:
>=20
> On 10/20/15 at 03:20pm, Jarno Rajahalme wrote:
>> Extend OVS conntrack interface to cover NAT.  New nested
>> OVS_CT_ATTR_NAT may be used to include NAT with a CT action.  A bare
>> OVS_CT_ATTR_NAT only mangles existing connections.  If
>> OVS_NAT_ATTR_SRC or OVS_NAT_ATTR_DST is included within the nested
>> attributes, new (non-committed/non-confirmed) connections are mangle=
d
>> according to the rest of the nested attributes.
>>=20
>> This work extends on a branch by Thomas Graf at
>> https://github.com/tgraf/ovs/tree/nat.
>>=20
>> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
>=20
> Awesome work. This is a great start.
>=20
> There are some, probably unintended, unrelated style changes. More
> comments below.
>=20

Thanks for the review!

>> +enum ovs_nat_attr {
>> +	OVS_NAT_ATTR_UNSPEC,
>> +	OVS_NAT_ATTR_SRC,
>> +	OVS_NAT_ATTR_DST,
>> +	OVS_NAT_ATTR_IP_MIN,
>> +	OVS_NAT_ATTR_IP_MAX,
>> +	OVS_NAT_ATTR_PROTO_MIN,
>> +	OVS_NAT_ATTR_PROTO_MAX,
>> +	OVS_NAT_ATTR_PERSISTENT,
>> +	OVS_NAT_ATTR_PROTO_HASH,
>> +	OVS_NAT_ATTR_PROTO_RANDOM,
>=20
> Simplify this with an OVS_NAT_ATTR_FLAGS?

The use of separate flag attributes was actually intentional, as it mak=
es the interface easier to understand, and code also easier to read.

>=20
>> @@ -137,11 +159,17 @@ static void __ovs_ct_update_key(struct sw_flow=
_key *key, u8 state,
>> 	ovs_ct_get_label(ct, &key->ct.label);
>> }
>>=20
>> -/* Update 'key' based on skb->nfct. If 'post_ct' is true, then OVS =
has
>> - * previously sent the packet to conntrack via the ct action.
>> +/* Update 'key' based on skb->nfct.  If 'post_ct' is true, then OVS=
 has
>> + * previously sent the packet to conntrack via the ct action.  If
>> + * 'keep_nat_flags' is true, the existing NAT flags retained, else =
they are
>> + * initialized from the connection status.
>>  */
>> static void ovs_ct_update_key(const struct sk_buff *skb,
>> -			      struct sw_flow_key *key, bool post_ct)
>> +			      struct sw_flow_key *key, bool post_ct
>> +#ifdef CONFIG_NF_NAT_NEEDED
>> +			      , bool keep_nat_flags
>> +#endif
>> +			      )
>=20
> I suggest keeping the argument even for !CONFIG_NF_NAT_NEEDED. This
> unclutters the call sites of this function. An ifdef inside the
> keep_nat_flags branch should be enough. The compiler will optimize
> the code away and it's much prettier to read.
>=20

OK.

>> {
>> 	const struct nf_conntrack_zone *zone =3D &nf_ct_zone_dflt;
>> 	enum ip_conntrack_info ctinfo;
>> @@ -151,8 +179,20 @@ static void ovs_ct_update_key(const struct sk_b=
uff *skb,
>> 	ct =3D nf_ct_get(skb, &ctinfo);
>> 	if (ct) {
>> 		state =3D ovs_ct_get_state(ctinfo);
>> +		/* OVS persists the related flag for the duration of the
>> +		 * connection. */
>> 		if (ct->master)
>> 			state |=3D OVS_CS_F_RELATED;
>> +#ifdef CONFIG_NF_NAT_NEEDED
>> +		if (keep_nat_flags)
>> +			state |=3D key->ct.state & OVS_CS_F_NAT_MASK;
>> +		else {
>> +			if (ct->status & IPS_SRC_NAT)
>> +				state |=3D OVS_CS_F_SRC_NAT;
>> +			if (ct->status & IPS_DST_NAT)
>> +				state |=3D OVS_CS_F_DST_NAT;
>> +		}
>> +#endif
>> 		zone =3D nf_ct_zone(ct);
>> 	} else if (post_ct) {
>> 		state =3D OVS_CS_F_TRACKED | OVS_CS_F_INVALID;
>> @@ -291,7 +337,16 @@ static int ovs_ct_helper(struct sk_buff *skb, u=
16 proto)
>> 		return NF_DROP;
>> 	}
>>=20
>> -	return helper->help(skb, protoff, ct, ctinfo);
>> +	if (helper->help(skb, protoff, ct, ctinfo) !=3D NF_ACCEPT)
>> +		return NF_DROP;
>=20
> Return the returned value here instead of hardcoding NF_DROP?
>=20

OK

>> +#ifdef CONFIG_NF_NAT_NEEDED
>> +	/* Adjust seqs after helper. */
>=20
> A comment on why this is needed would be helpful.
>=20

Will add a comment like: /* Needed when a helper adjusts payload size (=
e.g., FTP PORT command). */

>> +	if (test_bit(IPS_SEQ_ADJUST_BIT, &ct->status)
>> +	    && !nf_ct_seq_adjust(skb, ct, ctinfo, protoff))
>> +		return NF_DROP;
>> +#endif
>> +	return NF_ACCEPT;
>=20
>> @@ -377,7 +432,211 @@ static bool skb_nfct_cached(const struct net *=
net, const struct sk_buff *skb,
>> 	return true;
>> }
>>=20
>> -static int __ovs_ct_lookup(struct net *net, const struct sw_flow_ke=
y *key,
>> +#ifdef CONFIG_NF_NAT_NEEDED
>> +/* Modeled after nf_nat_ipv[46]_fn().
>> + * range is only used for new, uninitialized NAT state.
>> + * Returns either NF_ACCEPT or NF_DROP. */
>> +static int ovs_ct_nat_execute(struct sk_buff *skb, struct nf_conn *=
ct,
>> +			      enum ip_conntrack_info ctinfo,
>> +			      const struct nf_nat_range *range,
>> +			      enum nf_nat_manip_type maniptype)
>> +{
>> +	int hooknum, nh_off, err =3D NF_ACCEPT;
>> +
>> +	nh_off =3D skb_network_offset(skb);
>> +	skb_pull(skb, nh_off);
>> +
>> +	/* See HOOK2MANIP(). */
>> +	if (maniptype =3D=3D NF_NAT_MANIP_SRC)
>> +		hooknum =3D NF_INET_LOCAL_IN; /* Source NAT */
>> +	else
>> +		hooknum =3D NF_INET_LOCAL_OUT; /* Destination NAT */
>> +
>> +	switch (ctinfo) {
>> +	case IP_CT_RELATED:
>> +	case IP_CT_RELATED_REPLY:
>> +		if (skb->protocol =3D=3D htons(ETH_P_IP)
>> +		    && ip_hdr(skb)->protocol =3D=3D IPPROTO_ICMP) {
>> +			if (!nf_nat_icmp_reply_translation(skb, ct, ctinfo,
>> +							   hooknum))
>> +				err =3D NF_DROP;
>> +			goto push;
>> +		} else if (skb->protocol =3D=3D htons(ETH_P_IPV6)) {
>> +			__be16 frag_off;
>> +			u8 nexthdr =3D ipv6_hdr(skb)->nexthdr;
>> +			int hdrlen =3D ipv6_skip_exthdr(skb,
>> +						      sizeof(struct ipv6hdr),
>> +						      &nexthdr, &frag_off);
>> +
>> +			if (hdrlen >=3D 0 && nexthdr =3D=3D IPPROTO_ICMPV6) {
>> +				if (!nf_nat_icmpv6_reply_translation(skb, ct,
>> +								     ctinfo,
>> +								     hooknum,
>> +								     hdrlen))
>> +					err =3D NF_DROP;
>> +				goto push;
>> +			}
>> +		}
>> +		/* Non-ICMP, fall thru to initialize if needed. */
>> +	case IP_CT_NEW:
>> +		/* Seen it before?  This can happen for loopback, retrans,
>> +		 * or local packets.
>> +		 */
>> +		if (!nf_nat_initialized(ct, maniptype)) {
>=20
> Explicit unlikely()?
>=20

Normally initialization is needed, but for IP_CT_RELATED the expectatio=
n handling may have already initialized NAT. As such, I do not see a st=
rong case for if (likely(!nf_nat_initialized(ct, maniptype)). I=E2=80=99=
ll see if I can improve the comment, though, as the current one is copi=
ed from nf_nat_ipv[46]_fn().

>> +			/* Initialize according to the NAT action. */
>> +			err =3D (range && range->flags & NF_NAT_RANGE_MAP_IPS)
>> +				/* Action is set up to establish a new
>> +				 * mapping */
>> +				? nf_nat_setup_info(ct, range, maniptype)
>> +				: nf_nat_alloc_null_binding(ct, hooknum);
>> +		}
>> +		break;
>> +
>> +	case IP_CT_ESTABLISHED:
>> +	case IP_CT_ESTABLISHED_REPLY:
>> +		break;
>> +
>> +	default:
>> +		err =3D NF_DROP;
>> +		goto push;
>> +	}
>> +
>> +	if (err =3D=3D NF_ACCEPT)
>> +		err =3D nf_nat_packet(ct, ctinfo, hooknum, skb);
>=20
> If you goto push on init failure (IP_CT_NEW branch), then this
> conditional is no longer needed and a more straight forward exception
> handling is seen.
>=20

OK.

>> +push:
>> +	skb_push(skb, nh_off);
>> +
>> +	return err;
>> +}
>=20
>> +/* Returns NF_DROP if the packet should be dropped, NF_ACCEPT other=
wise.
>> + * This action can be used to both NAT and reverse NAT, however, re=
verse NAT
>> + * can also be done with the conntrack action. */
>> +static int ovs_ct_nat(struct net *net, struct sw_flow_key *key,
>> +		      const struct ovs_conntrack_info *info,
>> +		      struct sk_buff *skb)
>> +{
>> +	enum nf_nat_manip_type maniptype;
>> +	enum ip_conntrack_info ctinfo;
>> +	struct nf_conn *ct;
>> +	int err;
>> +
>> +	/* No NAT action or already NATed? */
>> +	if (!(info->flags & OVS_CT_F_NAT_MASK)
>> +	    || key->ct.state & OVS_CS_F_NAT_MASK)
>> +		return NF_ACCEPT;
>> +
>> +	ct =3D nf_ct_get(skb, &ctinfo);
>> +	/* Check if an existing conntrack entry may be found for this skb.
>> +	 * This happens when we lose the ct entry pointer due to an upcall=
=2E
>> +	 * Don't lookup invalid connections. */
>> +	if (!ct && key->ct.state & OVS_CS_F_TRACKED
>> +	    && !(key->ct.state & OVS_CS_F_INVALID))
>> +		ct =3D ovs_ct_find_existing(net, &info->zone, info->family, skb,
>> +					  &ctinfo);
>> +	if (!ct || nf_ct_is_untracked(ct))
>> +		/* A NAT action may only be performed on tracked packets. */
>> +		return NF_ACCEPT;
>=20
> Braces
>=20

Needed due to the comment?

>> +	/* Add NAT extension if not commited yet. */
>> +	if (!nf_ct_is_confirmed(ct)) {
>> +		if (!nf_ct_nat_ext_add(ct))
>> +			return NF_ACCEPT;   /* Can't NAT. */
>> +	}
>=20
> &&
>=20

Sure.

>> +	/* Determine NAT type.
>> +	 * Check if the NAT type can be deduced from the tracked connectio=
n.
>> +	 * Make sure expected traffic is NATted only when commiting. */
>> +	if (info->flags & OVS_CT_F_NAT && ctinfo !=3D IP_CT_NEW
>> +	    && ct->status & IPS_NAT_MASK
>> +	    && (!(ct->status & IPS_EXPECTED_BIT)
>> +		|| info->flags & OVS_CT_F_COMMIT)) {
>> +		/* NAT an established or related connection like before. */
>> +		if (CTINFO2DIR(ctinfo) =3D=3D IP_CT_DIR_REPLY)
>> +			/* This is the REPLY direction for a connection
>> +			 * for which NAT was applied in the forward
>> +			 * direction.  Do the reverse NAT. */
>> +			maniptype =3D ct->status & IPS_SRC_NAT
>> +				? NF_NAT_MANIP_DST : NF_NAT_MANIP_SRC;
>> +		else
>> +			maniptype =3D ct->status & IPS_SRC_NAT
>> +				? NF_NAT_MANIP_SRC : NF_NAT_MANIP_DST;
>> +	}
>> +	else if (info->flags & OVS_CT_F_SRC_NAT)
>> +		maniptype =3D NF_NAT_MANIP_SRC;
>> +	else if (info->flags & OVS_CT_F_DST_NAT)
>> +		maniptype =3D NF_NAT_MANIP_DST;
>> +	else
>> +		return NF_ACCEPT; /* Connection is not NATed. */
>> +
>> +	err =3D ovs_ct_nat_execute(skb, ct, ctinfo, &info->range, maniptyp=
e);
>> +
>> +	/* Mark NAT done if successful. */
>> +	if (err =3D=3D NF_ACCEPT)
>> +		key->ct.state |=3D (maniptype =3D=3D NF_NAT_MANIP_SRC)
>> +			? OVS_CS_F_SRC_NAT : OVS_CS_F_DST_NAT;
>> +	return err;
>> +}
>> +#endif
>> +
>> +static int __ovs_ct_lookup(struct net *net, struct sw_flow_key *key=
,
>> 			   const struct ovs_conntrack_info *info,
>> 			   struct sk_buff *skb)
>> {
>=20
>=20
>> @@ -538,6 +819,131 @@ static int ovs_ct_add_helper(struct ovs_conntr=
ack_info *info, const char *name,
>> 	return 0;
>> }
>>=20
>> +#ifdef CONFIG_NF_NAT_NEEDED
>> +static int parse_nat(const struct nlattr *attr,
>> +		     struct ovs_conntrack_info *info, bool log)
>> +{
>> +	struct nlattr *a;
>> +	int rem;
>> +	bool have_ip_max =3D false;
>> +	bool have_proto_max =3D false;
>> +	bool ip_vers =3D (info->family =3D=3D NFPROTO_IPV6);
>> +
>> +	nla_for_each_nested(a, attr, rem) {
>> +		static const u16 ovs_nat_attr_lens[OVS_NAT_ATTR_MAX + 1][2] =3D {
>> +			[OVS_NAT_ATTR_SRC] =3D {0, 0},
>> +			[OVS_NAT_ATTR_DST] =3D {0, 0},
>> +			[OVS_NAT_ATTR_IP_MIN] =3D {sizeof(struct in_addr),
>> +						 sizeof(struct in6_addr)},
>> +			[OVS_NAT_ATTR_IP_MAX] =3D {sizeof(struct in_addr),
>> +						 sizeof(struct in6_addr)},
>> +			[OVS_NAT_ATTR_PROTO_MIN] =3D {sizeof(u16),sizeof(u16)},
>> +			[OVS_NAT_ATTR_PROTO_MAX] =3D {sizeof(u16),sizeof(u16)},
>> +			[OVS_NAT_ATTR_PERSISTENT] =3D {0, 0},
>> +			[OVS_NAT_ATTR_PROTO_HASH] =3D {0, 0},
>> +			[OVS_NAT_ATTR_PROTO_RANDOM] =3D {0, 0},
>> +		};
>> +		int type =3D nla_type(a);
>> +
>> +		if (type > OVS_NAT_ATTR_MAX) {
>> +			OVS_NLERR(log, "Unknown nat attribute (type=3D%d, max=3D%d).\n",
>> +			type, OVS_NAT_ATTR_MAX);
>=20
> Formatting

Not readily apparent what you mean here, care to elaborate?

>=20
>> +			return -EINVAL;
>> +		}
>> +
>> +		case OVS_NAT_ATTR_IP_MIN:
>> +			nla_memcpy(&info->range.min_addr, a, nla_len(a));
>=20
> The length attribute should be sizeof of min_addr like for max_addr
> below.
>=20

Right.

>> +			info->range.flags |=3D NF_NAT_RANGE_MAP_IPS;
>> +			break;
>> +
>> +		case OVS_NAT_ATTR_IP_MAX:
>> +			have_ip_max =3D true;
>> +			nla_memcpy(&info->range.max_addr, a,
>> +				   sizeof(info->range.max_addr));
>> +			info->range.flags |=3D NF_NAT_RANGE_MAP_IPS;
>> +			break;
>> +
>> +	}
>=20
>> static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX =
+ 1] =3D {
>> 	[OVS_CT_ATTR_COMMIT]	=3D { .minlen =3D 0,
>> 				    .maxlen =3D 0 },
>> @@ -548,7 +954,11 @@ static const struct ovs_ct_len_tbl ovs_ct_attr_=
lens[OVS_CT_ATTR_MAX + 1] =3D {
>> 	[OVS_CT_ATTR_LABEL]	=3D { .minlen =3D sizeof(struct md_label),
>> 				    .maxlen =3D sizeof(struct md_label) },
>> 	[OVS_CT_ATTR_HELPER]	=3D { .minlen =3D 1,
>> -				    .maxlen =3D NF_CT_HELPER_NAME_LEN }
>> +				    .maxlen =3D NF_CT_HELPER_NAME_LEN },
>> +#ifdef CONFIG_NF_NAT_NEEDED
>> +	[OVS_CT_ATTR_NAT]	=3D { .minlen =3D 0,
>> +				    .maxlen =3D 96 }
>> +#endif
>=20
> Is the 96 a temporary hack here?
>=20

It is not an exact value. It is much better than my temporary hack of 5=
12 was. As trailing garbage is checked for, I=E2=80=99m not sure if thi=
s should be very accurately calculated? Maybe it would be better to dis=
able the length checks for this altogether?

>> @@ -607,6 +1017,14 @@ static int parse_ct(const struct nlattr *attr,=
 struct ovs_conntrack_info *info,
>> 				return -EINVAL;
>> 			}
>> 			break;
>> +#ifdef CONFIG_NF_NAT_NEEDED
>> +		case OVS_CT_ATTR_NAT: {
>> +			int err =3D parse_nat(a, info, log);
>> +			if (err)
>> +				return err;
>> +			break;
>> +		}
>> +#endif
>=20
> We should probably bark if user space provides a OVS_CT_ATTR_NAT but =
the
> kernel is compiled without support for it.
>=20

We do issue -EINVAL and log =E2=80=9CUnknown conntrack attr=E2=80=9D in=
 that case.

>> +#ifdef CONFIG_NF_NAT_NEEDED
>> +static bool ovs_ct_nat_to_attr(const struct ovs_conntrack_info *inf=
o,
>> +			       struct sk_buff *skb)
>> +{
>> +	struct nlattr *start;
>> +
>> +	start =3D nla_nest_start(skb, OVS_CT_ATTR_NAT);
>> +	if (!start)
>> +		return false;
>> +
>> +	if (info->flags & OVS_CT_F_SRC_NAT) {
>> +		if (nla_put_flag(skb, OVS_NAT_ATTR_SRC))
>> +			return false;
>> +	} else if (info->flags & OVS_CT_F_DST_NAT) {
>> +		if (nla_put_flag(skb, OVS_NAT_ATTR_DST))
>> +			return false;
>> +	} else {
>> +		goto out;
>=20
> Is the empty nested attribute intended here?

Yes. On netlink interface empty nested attribute (NAT without any argum=
ents) signifies to NAT packets of previously NATted connections (only).

  Jarno


--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
