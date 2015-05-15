From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] mpls: modify RTA_NEWDST netlink attribute to include family
Date: Fri, 15 May 2015 01:35:10 -0500
Message-ID: <877fsa2vs1.fsf@x220.int.ebiederm.org>
References: <1431664722-59539-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36682 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766AbbEOGkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 02:40:01 -0400
In-Reply-To: <1431664722-59539-1-git-send-email-roopa@cumulusnetworks.com>
	(roopa@cumulusnetworks.com's message of "Thu, 14 May 2015 21:38:42
	-0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

roopa@cumulusnetworks.com writes:

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> RTA_NEWDST netlink attribute today is used to carry mpls
> labels. This patch encodes family in RTA_NEWDST.
>
> RTA_NEWDST by its name and its use in iproute2 can be
> used as a generic new dst. But it is currently used only for
> mpls labels ie with family AF_MPLS. Encoding family in the
> attribute will help its reuse in the future.
>
> One usecase where family with RTA_NEWDST becomes necessary
> is when we implement mpls label edge router function.

I don't think this makes any sense.

How do you change the destination address on a packet to a value in
another protocol?  None of IPv4, IPv6, and MPLS support that.

Aka this attribute represents DNAT.


> This is a uapi change but RTA_NEWDST has not made
> into any release yet. so, trying to rush this change into
> 4.1 if acceptable.
>
> (iproute2 patch will follow)
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
> eric, if you had already thought about other ways to represent
> labels for LER function, pls let me know. I am looking for suggestions.

I have to some extent, nothing I am completely pleased with yet but
enough that I can narrow things down to some extent.

I believe you are referring to the case where we have an ipv4 packet
or an ipv6 packet and we are inserting it into an mpls tunnel for the
next step of it's travel.  Egress from mpls appears to already be
convered.

The bounding set of challenges looks something like this:
- We might be placing a full routing table into mpls with
  a different mpls tunnel for each different route.
  A full routing table today runs about 1 million routes
  so we need to support inserting into the ballpark of 1 million
  different mpls tunnels.
  As it happens 1 million is also 2^20 or the number of mpls labels.

At 1 million tunnels that rules out using network devices.

Network devices have two basic things that cause scalability problems.
- struct netdevice and all of sysfs and sysctl overheads fixable
  but they run at about 32K today.
- The accounting of ingress and egress packets.
  It takes a lot of percpu counters to make accounting fast
  so I think fundamentally we want something without counters.

Which lead me to look at the kernel xfrm subsystem.  xfrm is a close
match in requirements.  But having to do a second inefficient lookup and
lookup on more than what we normally used to route a packet seems
wrong. Not hooking into the routing tables seems wrong.  The xfrm data
structures themselves seem heavy weight for simple low cost
encapsulation.


So I think we need to build yet another infrastructure for dealing with
light weight tunnels (not just mpls).

What I would propose would be a new infrastructure for dealing with
simple stateless tunnels.  (AKA tunneling over IP or UDP or MPLS is fine
but tunneling over TCP or otherwise needing smarts to insert a packet
into a tunnel is a no-go).

To support entering these tunnels and egressing from these tunnels we
need a number that would represent the tunnel type that is linux
specific.  This tunnel type would be a superset of the ipv4/ipv6
protocol number that is stored in /etc/protocol and
http://www.iana.org/assignments/protocol-numbers As well as being a
superset the pseudo wire types
http://www.iana.org/assignments/pwe3-parameters
There are mpls tunnels that are not pseudo wires and there are
tunnels over ip that are encoded in udp are something else as well.

I believe I would represent this in rtnetlink with a new attribute
RTA_ENCAP.  The current idea in my mind is that RTA_ENCAP would include
the encapsulation type, a set of fixed headers and possibly some nested
attributes (like output device), probably RTA_ENCAP and possibly
RTA_DST.

At an implementation level I would hook these to the ipv4 and ipv6
routing tables at the same place as the destination network device,
possibly sharing storage with where we put the destination network
device today.

We should be able to use dst->output to do all of the work and thus be
able to use many if not all of the same hooks as the fast path of xfrm.

We definitely need an ecapsulation method because we need to deal with
things like the ttl, mtu and fragmentation and so we need to propogate
bits algorithmically between the different layers.

There is also the complication that ip over mpls natively vs ip over an
mpls pseudo wire while in practice have the same encoding of the mpls
labels they appear propogate the ttl differently.  In one case the ttl
from the inner packet propogates to the outer packet during
encapsulation and propogates to the inner packet when deccapsulating,
and in the other case the mpls tunnel is treated as a single hop
by the ip layer.


So I think the right solution is to do the leg work and come up with
an RTA_ENCAP netlink option, and the associated


The cheap hack version of this is to use RTA_FLOW and encode a 32bit
number in the routing table and use a magic device to look up that 32bit
number in the mpls routing table (or possibly an mpls flow table)
and use that to generate the mpls labels.

I don't think we want add the cheap hack.  I think we want a good
version that can work for all simple well defined tunnel types like
mpls, gre, ipip, vxlan?, etc.


I think we also will want a small layer of indirection in the
implementation of RTA_ENCAP such that we can define a simple
encapsulation separately from defining the route.  For IPv4 with in some
cases 8 different prefixes for a single destination address, in the
general case, and internal to a companies network I suspect the
aggregation level can be much higher.

What such an encapsulation would be is that we would have a tunnel
table with simple integer index, and RTA_ENCAP would just hold
that index to that tunnel.  The routing table would hold a reference
counted pointer to the tunnel (so no extra lookups required in the fast
path), and some other bits of netwlink would create and destroy the
light-weight encapsulations.

Anyway that is my brainstorm on how things should look, and I really
don't think extending RTA_NEWDST makes much if any sense at all.
RTA_NEWDST is just DNAT.

Eric


>  include/uapi/linux/rtnetlink.h |    7 ++-
>  net/mpls/af_mpls.c             |  118 +++++++++++++++++++++++++++++++---------
>  net/mpls/internal.h            |    5 +-
>  3 files changed, 100 insertions(+), 30 deletions(-)
>
> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> index 974db03..79879cb 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -356,8 +356,13 @@ struct rtvia {
>  	__u8			rtvia_addr[0];
>  };
>  
> -/* RTM_CACHEINFO */
> +/* RTA_NEWDST */
> +struct rtnewdst {
> +	__kernel_sa_family_t	family;
> +	__u8	dst[0];
> +};
>  
> +/* RTM_CACHEINFO */
>  struct rta_cacheinfo {
>  	__u32	rta_clntref;
>  	__u32	rta_lastuse;
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 91ed656..6c31108 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -599,18 +599,13 @@ static int nla_put_via(struct sk_buff *skb,
>  	return 0;
>  }
>  
> -int nla_put_labels(struct sk_buff *skb, int attrtype,
> +int nla_put_labels(struct sk_buff *skb, void *addr,
>  		   u8 labels, const u32 label[])
>  {
> -	struct nlattr *nla;
> -	struct mpls_shim_hdr *nla_label;
> +	struct mpls_shim_hdr *nla_label = addr;
>  	bool bos;
>  	int i;
> -	nla = nla_reserve(skb, attrtype, labels*4);
> -	if (!nla)
> -		return -EMSGSIZE;
>  
> -	nla_label = nla_data(nla);
>  	bos = true;
>  	for (i = labels - 1; i >= 0; i--) {
>  		nla_label[i] = mpls_entry_encode(label[i], 0, 0, bos);
> @@ -620,25 +615,45 @@ int nla_put_labels(struct sk_buff *skb, int attrtype,
>  	return 0;
>  }
>  
> -int nla_get_labels(const struct nlattr *nla,
> -		   u32 max_labels, u32 *labels, u32 label[])
> +int nla_put_newdst(struct sk_buff *skb, int attrtype, int family,
> +		   u8 labels, const u32 label[])
>  {
> -	unsigned len = nla_len(nla);
> -	unsigned nla_labels;
> -	struct mpls_shim_hdr *nla_label;
> -	bool bos;
> -	int i;
> +	struct nlattr *nla;
> +	struct rtnewdst *newdst;
>  
> -	/* len needs to be an even multiple of 4 (the label size) */
> -	if (len & 3)
> -		return -EINVAL;
> +	nla = nla_reserve(skb, attrtype, 2 + (labels * 4));
> +	if (!nla)
> +		return -EMSGSIZE;
>  
> -	/* Limit the number of new labels allowed */
> -	nla_labels = len/4;
> -	if (nla_labels > max_labels)
> -		return -EINVAL;
> +	newdst = nla_data(nla);
> +	newdst->family = family;
> +
> +	nla_put_labels(skb, &newdst->dst, labels, label);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(nla_put_newdst);
> +
> +int nla_put_dst(struct sk_buff *skb, int attrtype, u8 labels,
> +		const u32 label[])
> +{
> +	struct nlattr *nla;
> +
> +	nla = nla_reserve(skb, attrtype, labels * 4);
> +	if (!nla)
> +		return -EMSGSIZE;
> +
> +	nla_put_labels(skb, nla_data(nla), labels, label);
> +
> +	return 0;
> +}
> +
> +int nla_get_labels(void *addr, u32 nla_labels, u32 *labels, u32 label[])
> +{
> +	struct mpls_shim_hdr *nla_label = addr;
> +	bool bos;
> +	int i;
>  
> -	nla_label = nla_data(nla);
>  	bos = true;
>  	for (i = nla_labels - 1; i >= 0; i--, bos = false) {
>  		struct mpls_entry_decoded dec;
> @@ -665,6 +680,54 @@ int nla_get_labels(const struct nlattr *nla,
>  	return 0;
>  }
>  
> +int nla_get_newdst(const struct nlattr *nla, u32 max_labels,
> +		   u32 *labels, u32 label[])
> +{
> +	struct rtnewdst *newdst = nla_data(nla);
> +	unsigned nla_labels;
> +	unsigned len;
> +
> +	if (nla_len(nla) < offsetof(struct rtnewdst, dst))
> +		return -EINVAL;
> +
> +	len = nla_len(nla) - sizeof(struct rtnewdst);
> +
> +	/* len needs to be an even multiple of 4 (the label size) */
> +	if (len & 3)
> +		return -EINVAL;
> +
> +	/* Limit the number of new labels allowed */
> +	nla_labels = len / 4;
> +	if (nla_labels > max_labels)
> +		return -EINVAL;
> +
> +	nla_get_labels(&newdst->dst, nla_labels, labels, label);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(nla_get_newdst);
> +
> +int nla_get_dst(const struct nlattr *nla,
> +		u32 max_labels, u32 *labels, u32 label[])
> +{
> +	unsigned len = nla_len(nla);
> +	unsigned nla_labels;
> +
> +	/* len needs to be an even multiple of 4 (the label size) */
> +	if (len & 3)
> +		return -EINVAL;
> +
> +	/* Limit the number of new labels allowed */
> +	nla_labels = len / 4;
> +	if (nla_labels > max_labels)
> +		return -EINVAL;
> +
> +	nla_get_labels(nla_data(nla), nla_labels, labels, label);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(nla_get_dst);
> +
>  static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>  			       struct mpls_route_config *cfg)
>  {
> @@ -721,7 +784,7 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>  			cfg->rc_ifindex = nla_get_u32(nla);
>  			break;
>  		case RTA_NEWDST:
> -			if (nla_get_labels(nla, MAX_NEW_LABELS,
> +			if (nla_get_newdst(nla, MAX_NEW_LABELS,
>  					   &cfg->rc_output_labels,
>  					   cfg->rc_output_label))
>  				goto errout;
> @@ -729,8 +792,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
>  		case RTA_DST:
>  		{
>  			u32 label_count;
> -			if (nla_get_labels(nla, 1, &label_count,
> -					   &cfg->rc_label))
> +			if (nla_get_dst(nla, 1, &label_count,
> +					&cfg->rc_label))
>  				goto errout;
>  
>  			/* The first 16 labels are reserved, and may not be set */
> @@ -831,14 +894,15 @@ static int mpls_dump_route(struct sk_buff *skb, u32 portid, u32 seq, int event,
>  	rtm->rtm_flags = 0;
>  
>  	if (rt->rt_labels &&
> -	    nla_put_labels(skb, RTA_NEWDST, rt->rt_labels, rt->rt_label))
> +	    nla_put_newdst(skb, RTA_NEWDST, AF_MPLS, rt->rt_labels,
> +			   rt->rt_label))
>  		goto nla_put_failure;
>  	if (nla_put_via(skb, rt->rt_via_table, rt->rt_via, rt->rt_via_alen))
>  		goto nla_put_failure;
>  	dev = rtnl_dereference(rt->rt_dev);
>  	if (dev && nla_put_u32(skb, RTA_OIF, dev->ifindex))
>  		goto nla_put_failure;
> -	if (nla_put_labels(skb, RTA_DST, 1, &label))
> +	if (nla_put_dst(skb, RTA_DST, 1, &label))
>  		goto nla_put_failure;
>  
>  	nlmsg_end(skb, nlh);
> diff --git a/net/mpls/internal.h b/net/mpls/internal.h
> index b064c34..99d7a79 100644
> --- a/net/mpls/internal.h
> +++ b/net/mpls/internal.h
> @@ -49,7 +49,8 @@ static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *
>  	return result;
>  }
>  
> -int nla_put_labels(struct sk_buff *skb, int attrtype,  u8 labels, const u32 label[]);
> -int nla_get_labels(const struct nlattr *nla, u32 max_labels, u32 *labels, u32 label[]);
> +int nla_put_labels(struct sk_buff *skb, void *addr,  u8 labels,
> +		   const u32 label[]);
> +int nla_get_labels(void *addr, u32 nla_labels, u32 *labels, u32 label[]);
>  
>  #endif /* MPLS_INTERNAL_H */
