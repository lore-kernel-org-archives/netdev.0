From: Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next v7] openvswitch: enable NSH support
Date: Thu, 31 Aug 2017 12:45:16 +0200
Message-ID: <20170831124516.0c5db686@griffin>
References: <1504096752-102003-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e@erig.me, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1504096752-102003-1-git-send-email-yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2017 20:39:12 +0800, Yi Yang wrote:
> --- a/net/nsh/nsh.c
> +++ b/net/nsh/nsh.c
> @@ -14,6 +14,47 @@
>  #include <net/nsh.h>
>  #include <net/tun_proto.h>
>  
> +int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *nsh_src, bool is_eth)
> +{
> +	struct nshhdr *nsh;
> +	size_t length = nsh_hdr_len(nsh_src);
> +	u8 next_proto;
> +
> +	if (is_eth) {
> +		next_proto = TUN_P_ETHERNET;

I don't like the is_eth parameter. It should be clear from the skb being
passed to the function, specifically from skb->mac_len.

> +	} else {
> +		next_proto = tun_p_from_eth_p(skb->protocol);
> +		if (!next_proto)
> +			return -ENOTSUPP;

EAFNOSUPPORT is more suitable here.

> +	}
> +
> +	/* Add the NSH header */
> +	if (skb_cow_head(skb, length) < 0)
> +		return -ENOMEM;
> +
> +	/* Add the NSH header */
> +	if (skb_cow_head(skb, length) < 0)
> +		return -ENOMEM;

Duplicate statement.

> +
> +	if (!skb->inner_protocol) {
> +		skb_set_inner_network_header(skb, skb->mac_len);
> +		skb_set_inner_protocol(skb, skb->protocol);

It doesn't make sense to set either of those. Nothing uses the fields for
NSH.

> +	}
> +
> +	skb_push(skb, length);
> +	nsh = (struct nshhdr *)(skb->data);

Use nsh_hdr.

> +	memcpy(nsh, nsh_src, length);
> +	nsh->np = next_proto;
> +	nsh->mdtype &= NSH_MDTYPE_MASK;

The "& NSH_MDTYPE_MASK" operation does not make sense. Just trust the caller
to provide a meaningful value. It's its job to verify the parameters.

> +	skb->protocol = htons(ETH_P_NSH);
> +	skb_reset_mac_header(skb);
> +	skb_reset_mac_len(skb);

You have to reset also the network header.

> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(skb_push_nsh);
> +
>  static struct sk_buff *nsh_gso_segment(struct sk_buff *skb,
>  				       netdev_features_t features)
>  {
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index a54a556..e969fad 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -38,11 +38,13 @@
>  #include <net/dsfield.h>
>  #include <net/mpls.h>
>  #include <net/sctp/checksum.h>
> +#include <net/tun_proto.h>
>  
>  #include "datapath.h"
>  #include "flow.h"
>  #include "conntrack.h"
>  #include "vport.h"
> +#include "flow_netlink.h"
>  
>  struct deferred_action {
>  	struct sk_buff *skb;
> @@ -380,6 +382,57 @@ static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
>  	return 0;
>  }
>  
> +static int push_nsh(struct sk_buff *skb, struct sw_flow_key *key,
> +		    const struct nshhdr *nsh_src)
> +{
> +	bool is_eth = false;
> +	int ret;
> +
> +	if (key->mac_proto == MAC_PROTO_ETHERNET)
> +		is_eth = true;
> +
> +	ret = skb_push_nsh(skb, nsh_src, is_eth);
> +	if (ret != 0)

The usual idiom is "if (ret)". And for consistency with the rest of the
file, the name of the variable should be "err".

> +		return ret;
> +
> +	key->eth.type = htons(ETH_P_NSH);
> +
> +	/* safe right before invalidate_flow_key */
> +	key->mac_proto = MAC_PROTO_NONE;
> +	invalidate_flow_key(key);
> +	return 0;
> +}
> +
> +static int pop_nsh(struct sk_buff *skb, struct sw_flow_key *key)
> +{
> +	struct nshhdr *nsh = (struct nshhdr *)(skb->data);
> +	size_t length;
> +	u16 inner_proto;
> +
> +	if (ovs_key_mac_proto(key) != MAC_PROTO_NONE ||
> +	    skb->protocol != htons(ETH_P_NSH)) {
> +		return -EINVAL;
> +	}
> +
> +	inner_proto = tun_p_to_eth_p(nsh->np);
> +	if (!inner_proto)
> +		return -ENOTSUPP;
> +
> +	length = nsh_hdr_len(nsh);
> +	skb_pull(skb, length);
> +	skb_reset_mac_header(skb);
> +	skb_reset_mac_len(skb);
> +	skb->protocol = inner_proto;

Please factor this out to skb_pop_nsh, similarly to what you did with
skb_push_nsh.

> +
> +	/* safe right before invalidate_flow_key */
> +	if (inner_proto == htons(ETH_P_TEB))
> +		key->mac_proto = MAC_PROTO_ETHERNET;
> +	else
> +		key->mac_proto = MAC_PROTO_NONE;
> +	invalidate_flow_key(key);
> +	return 0;
> +}
> +
>  static void update_ip_l4_checksum(struct sk_buff *skb, struct iphdr *nh,
>  				  __be32 addr, __be32 new_addr)
>  {
> @@ -602,6 +655,53 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
>  	return 0;
>  }
>  
> +static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
> +		   const struct ovs_key_nsh *key,
> +		   const struct ovs_key_nsh *mask)
> +{
> +	struct nshhdr *nsh;
> +	int err;
> +	u8 flags;
> +	u8 ttl;
> +	int i;
> +
> +	err = skb_ensure_writable(skb, skb_network_offset(skb) +
> +				  sizeof(struct nshhdr));
> +	if (unlikely(err))
> +		return err;
> +
> +	nsh = (struct nshhdr *)skb_network_header(skb);

nsh_hdr

> +
> +	flags = nsh_get_flags(nsh);
> +	flags = OVS_MASKED(flags, key->flags, mask->flags);
> +	flow_key->nsh.flags = flags;
> +	ttl = nsh_get_ttl(nsh);
> +	ttl = OVS_MASKED(ttl, key->ttl, mask->ttl);
> +	flow_key->nsh.ttl = ttl;
> +	nsh_set_flags_and_ttl(nsh, flags, ttl);
> +	nsh->path_hdr = OVS_MASKED(nsh->path_hdr, key->path_hdr,
> +				   mask->path_hdr);
> +	flow_key->nsh.path_hdr = nsh->path_hdr;
> +	switch (nsh->mdtype) {
> +	case NSH_M_TYPE1:
> +		for (i = 0; i < NSH_MD1_CONTEXT_SIZE; i++) {
> +			nsh->md1.context[i] =
> +			    OVS_MASKED(nsh->md1.context[i], key->context[i],
> +				       mask->context[i]);
> +		}
> +		memcpy(flow_key->nsh.context, nsh->md1.context,
> +		       sizeof(nsh->md1.context));

Do you follow the discussion that Hannes Sowa started on the ovs list
regarding matching on the context fields? It would be better to hold on this
until there's a conclusion reached.

> +		break;
> +	case NSH_M_TYPE2:
> +		memset(flow_key->nsh.context, 0,
> +		       sizeof(flow_key->nsh.context));
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +	return 0;
> +}
> +
>  /* Must follow skb_ensure_writable() since that can move the skb data. */
>  static void set_tp_port(struct sk_buff *skb, __be16 *port,
>  			__be16 new_port, __sum16 *check)
> @@ -1024,6 +1124,32 @@ static int execute_masked_set_action(struct sk_buff *skb,
>  				   get_mask(a, struct ovs_key_ethernet *));
>  		break;
>  
> +	case OVS_KEY_ATTR_NSH: {
> +		struct ovs_key_nsh nsh;
> +		struct ovs_key_nsh nsh_mask;
> +		size_t size = nla_len(a) / 2;
> +		struct {
> +			struct nlattr nla;
> +			u8 data[size];
> +		} attr, mask;
> +
> +		attr.nla.nla_type = nla_type(a);
> +		attr.nla.nla_len = NLA_HDRLEN + size;
> +		memcpy(attr.data, (char *)(a + 1), size);
> +
> +		mask.nla = attr.nla;
> +		memcpy(mask.data, (char *)(a + 1) + size, size);

This is much cleaner than before. Thank you for doing the change. It now
allows me to understand what's actually going on here.

> +		err = nsh_key_from_nlattr(&attr.nla, &nsh);
> +		if (err)
> +			break;
> +		err = nsh_key_from_nlattr(&mask.nla, &nsh_mask);
> +		if (err)
> +			break;

This is a lot of copying to just be able to use nla_for_each_nested. While
I'm not a fan of how ovs uses the attributes to store both value and mask,
it's not completely irrational. However, I don't think that the intent was
to store a copy of the whole nested group. It's quite obvious that it does
not fit the pattern from the gymnastics you need to do.

Instead, store the mask in each of the nested attributes individually. There
will be no need for the copying above and the code will get cleaner and
faster. It's not that the nsh_key_from_nlattr function needs to be able to
work separately for the key and mask. Nothing else than the line above uses
this function. Just move the logic inside.

Actually, it seems it can be moved directly to set_nsh.

> +		err = set_nsh(skb, flow_key, &nsh, &nsh_mask);
> +		break;
> +	}
> +
>  	case OVS_KEY_ATTR_IPV4:
>  		err = set_ipv4(skb, flow_key, nla_data(a),
>  			       get_mask(a, struct ovs_key_ipv4 *));
> @@ -1210,6 +1336,21 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>  		case OVS_ACTION_ATTR_POP_ETH:
>  			err = pop_eth(skb, key);
>  			break;
> +
> +		case OVS_ACTION_ATTR_PUSH_NSH: {
> +			u8 buffer[NSH_HDR_MAX_LEN];
> +			struct nshhdr *nsh_hdr = (struct nshhdr *)buffer;
> +			const struct nshhdr *nsh_src = nsh_hdr;
> +
> +			nsh_hdr_from_nlattr(nla_data(a), nsh_hdr,
> +					    NSH_HDR_MAX_LEN);

This is costly. This is called for every packet in the fast path. We should
precompute and store the header instead.

I know I had comments to this part before and it would be ideal if I raised
this earlier but since you had trivial bugs like not taking the buffer size
into account, it was hard to focus on the design side of things. You can
prevent this churn by paying more attention to details before submission.
It's really hard to focus on high level picture when the first thing one
encounters is a trivial bug.

> +			err = push_nsh(skb, key, nsh_src);
> +			break;
> +		}
> +
> +		case OVS_ACTION_ATTR_POP_NSH:
> +			err = pop_nsh(skb, key);
> +			break;
>  		}
>  
>  		if (unlikely(err)) {
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 8c94cef..7a178d1 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -46,6 +46,7 @@
>  #include <net/ipv6.h>
>  #include <net/mpls.h>
>  #include <net/ndisc.h>
> +#include <net/nsh.h>
>  
>  #include "conntrack.h"
>  #include "datapath.h"
> @@ -490,6 +491,56 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
>  	return 0;
>  }
>  
> +static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
> +{
> +	struct nshhdr *nsh;
> +	unsigned int nh_ofs = skb_network_offset(skb);
> +	u8 version, length;
> +	int err;
> +
> +	err = check_header(skb, nh_ofs + NSH_BASE_HDR_LEN);
> +	if (unlikely(err))
> +		return err;
> +
> +	nsh = (struct nshhdr *)skb_network_header(skb);

nsh_hdr

> +	version = nsh_get_ver(nsh);
> +	length = nsh_hdr_len(nsh);
> +
> +	if (version != 0)
> +		return -EINVAL;
> +
> +	err = check_header(skb, nh_ofs + length);
> +	if (unlikely(err))
> +		return err;
> +
> +	nsh = (struct nshhdr *)skb_network_header(skb);

nsh_hdr

> +	key->nsh.flags = nsh_get_flags(nsh);
> +	key->nsh.ttl = nsh_get_ttl(nsh);
> +	key->nsh.mdtype = nsh->mdtype;
> +	key->nsh.np = nsh->np;
> +	key->nsh.path_hdr = nsh->path_hdr;
> +	switch (key->nsh.mdtype) {
> +	case NSH_M_TYPE1:
> +		if (length != NSH_M_TYPE1_LEN)
> +			return -EINVAL;
> +		memcpy(key->nsh.context, nsh->md1.context,
> +		       sizeof(nsh->md1));
> +		break;
> +	case NSH_M_TYPE2:
> +		/* Don't support MD type 2 metedata parsing yet */
> +		if (length < NSH_BASE_HDR_LEN)
> +			return -EINVAL;

Shouldn't we reject the packet, then? Pretending that something was parsed
correctly while in fact it was not, does not look correct.

> +
> +		memset(key->nsh.context, 0,
> +		       sizeof(nsh->md1));
> +		break;
> +	default:
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
>  /**
>   * key_extract - extracts a flow key from an Ethernet frame.
>   * @skb: sk_buff that contains the frame, with skb->data pointing to the
> @@ -735,6 +786,10 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
>  				memset(&key->tp, 0, sizeof(key->tp));
>  			}
>  		}
> +	} else if (key->eth.type == htons(ETH_P_NSH)) {
> +		error = parse_nsh(skb, key);
> +		if (error)
> +			return error;
>  	}
>  	return 0;
>  }
> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index 1875bba..6a3cd9c 100644
> --- a/net/openvswitch/flow.h
> +++ b/net/openvswitch/flow.h
> @@ -35,6 +35,7 @@
>  #include <net/inet_ecn.h>
>  #include <net/ip_tunnels.h>
>  #include <net/dst_metadata.h>
> +#include <net/nsh.h>
>  
>  struct sk_buff;
>  
> @@ -66,6 +67,15 @@ struct vlan_head {
>  	(offsetof(struct sw_flow_key, recirc_id) +	\
>  	FIELD_SIZEOF(struct sw_flow_key, recirc_id))
>  
> +struct ovs_key_nsh {
> +	u8 flags;
> +	u8 ttl;
> +	u8 mdtype;
> +	u8 np;
> +	__be32 path_hdr;
> +	__be32 context[NSH_MD1_CONTEXT_SIZE];
> +};
> +
>  struct sw_flow_key {
>  	u8 tun_opts[IP_TUNNEL_OPTS_MAX];
>  	u8 tun_opts_len;
> @@ -144,6 +154,7 @@ struct sw_flow_key {
>  			};
>  		} ipv6;
>  	};
> +	struct ovs_key_nsh nsh;         /* network service header */
>  	struct {
>  		/* Connection tracking fields not packed above. */
>  		struct {
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index e8eb427..17df00a 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -48,6 +48,7 @@
>  #include <net/ndisc.h>
>  #include <net/mpls.h>
>  #include <net/vxlan.h>
> +#include <net/tun_proto.h>
>  
>  #include "flow_netlink.h"
>  
> @@ -78,9 +79,11 @@ static bool actions_may_change_flow(const struct nlattr *actions)
>  		case OVS_ACTION_ATTR_HASH:
>  		case OVS_ACTION_ATTR_POP_ETH:
>  		case OVS_ACTION_ATTR_POP_MPLS:
> +		case OVS_ACTION_ATTR_POP_NSH:
>  		case OVS_ACTION_ATTR_POP_VLAN:
>  		case OVS_ACTION_ATTR_PUSH_ETH:
>  		case OVS_ACTION_ATTR_PUSH_MPLS:
> +		case OVS_ACTION_ATTR_PUSH_NSH:
>  		case OVS_ACTION_ATTR_PUSH_VLAN:
>  		case OVS_ACTION_ATTR_SAMPLE:
>  		case OVS_ACTION_ATTR_SET:
> @@ -322,12 +325,27 @@ size_t ovs_tun_key_attr_size(void)
>  		+ nla_total_size(2);   /* OVS_TUNNEL_KEY_ATTR_TP_DST */
>  }
>  
> +size_t ovs_nsh_key_attr_size(void)
> +{
> +	/* Whenever adding new OVS_NSH_KEY_ FIELDS, we should consider
> +	 * updating this function.
> +	 */
> +	return  nla_total_size(NSH_BASE_HDR_LEN) /* OVS_NSH_KEY_ATTR_BASE */
> +		/* OVS_NSH_KEY_ATTR_MD1 and OVS_NSH_KEY_ATTR_MD2 are
> +		 * mutually exclusive, so the bigger one can cover
> +		 * the small one.
> +		 *
> +		 * OVS_NSH_KEY_ATTR_MD2
> +		 */
> +		+ nla_total_size(NSH_CTX_HDRS_MAX_LEN);
> +}
> +
>  size_t ovs_key_attr_size(void)
>  {
>  	/* Whenever adding new OVS_KEY_ FIELDS, we should consider
>  	 * updating this function.
>  	 */
> -	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 28);
> +	BUILD_BUG_ON(OVS_KEY_ATTR_TUNNEL_INFO != 29);
>  
>  	return    nla_total_size(4)   /* OVS_KEY_ATTR_PRIORITY */
>  		+ nla_total_size(0)   /* OVS_KEY_ATTR_TUNNEL */
> @@ -341,6 +359,8 @@ size_t ovs_key_attr_size(void)
>  		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
>  		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABELS */
>  		+ nla_total_size(40)  /* OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6 */
> +		+ nla_total_size(0)   /* OVS_KEY_ATTR_NSH */
> +		  + ovs_nsh_key_attr_size()
>  		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
>  		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
>  		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
> @@ -373,6 +393,13 @@ static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1]
>  	[OVS_TUNNEL_KEY_ATTR_IPV6_DST]      = { .len = sizeof(struct in6_addr) },
>  };
>  
> +static const struct ovs_len_tbl
> +ovs_nsh_key_attr_lens[OVS_NSH_KEY_ATTR_MAX + 1] = {
> +	[OVS_NSH_KEY_ATTR_BASE]     = { .len = 8 },

sizeof(struct ovs_nsh_key_base)

> +	[OVS_NSH_KEY_ATTR_MD1]      = { .len = 16 },

sizeof(struct ovs_nsh_key_md1)

> +	[OVS_NSH_KEY_ATTR_MD2]      = { .len = OVS_ATTR_VARIABLE },
> +};
> +
>  /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
>  static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
>  	[OVS_KEY_ATTR_ENCAP]	 = { .len = OVS_ATTR_NESTED },
> @@ -405,6 +432,8 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
>  		.len = sizeof(struct ovs_key_ct_tuple_ipv4) },
>  	[OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6] = {
>  		.len = sizeof(struct ovs_key_ct_tuple_ipv6) },
> +	[OVS_KEY_ATTR_NSH]       = { .len = OVS_ATTR_NESTED,
> +				     .next = ovs_nsh_key_attr_lens, },
>  };
>  
>  static bool check_attr_len(unsigned int attr_len, unsigned int expected_len)
> @@ -1179,6 +1208,304 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
>  	return 0;
>  }
>  
> +int nsh_hdr_from_nlattr(const struct nlattr *attr,
> +			struct nshhdr *nsh, size_t size)
> +{
> +	struct nlattr *a;
> +	int rem;
> +	u8 flags = 0;
> +	u8 ttl = 0;
> +	int mdlen = 0;
> +	bool has_md1 = false;
> +	bool has_md2 = false;
> +	u8 len;
> +
> +	nla_for_each_nested(a, attr, rem) {
> +		int type = nla_type(a);
> +
> +		if (type > OVS_NSH_KEY_ATTR_MAX) {
> +			OVS_NLERR(1, "nsh attr %d is out of range max %d",
> +				  type, OVS_NSH_KEY_ATTR_MAX);
> +			return -EINVAL;
> +		}
> +
> +		if (!check_attr_len(nla_len(a),
> +				    ovs_nsh_key_attr_lens[type].len)) {
> +			OVS_NLERR(
> +			    1,
> +			    "nsh attr %d has unexpected len %d expected %d",
> +			    type,
> +			    nla_len(a),
> +			    ovs_nsh_key_attr_lens[type].len
> +			);
> +			return -EINVAL;
> +		}

These checks should be done only once when the action is configured, not for
each packet.

> +
> +		switch (type) {
> +		case OVS_NSH_KEY_ATTR_BASE: {
> +			const struct ovs_nsh_key_base *base =
> +				(struct ovs_nsh_key_base *)nla_data(a);
> +			flags = base->flags;
> +			ttl = base->ttl;
> +			nsh->np = base->np;
> +			nsh->mdtype = base->mdtype;
> +			nsh->path_hdr = base->path_hdr;
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD1: {
> +			const struct ovs_nsh_key_md1 *md1 =
> +				(struct ovs_nsh_key_md1 *)nla_data(a);
> +			struct nsh_md1_ctx *md1_dst = &nsh->md1;
> +
> +			has_md1 = true;
> +			mdlen = nla_len(a);
> +			if (((mdlen + NSH_BASE_HDR_LEN) != NSH_M_TYPE1_LEN) ||
> +			    ((mdlen + NSH_BASE_HDR_LEN) > size) ||
> +			    (mdlen <= 0)) {
> +				OVS_NLERR(
> +				    1,
> +				    "length %d of nsh attr %d is invalid",
> +				    mdlen,
> +				    type
> +				);
> +				return -EINVAL;
> +			}

Ditto for most parts of the check. Plus the maximum size should be validated
elsewhere. In this function, there should be a WARN_ON_ONCE if the computed
length > size.

> +			memcpy(md1_dst, md1, mdlen);
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD2: {
> +			const struct u8 *md2 = nla_data(a);
> +			struct nsh_md2_tlv *md2_dst = &nsh->md2;
> +
> +			has_md2 = true;
> +			mdlen = nla_len(a);
> +			if (((mdlen + NSH_BASE_HDR_LEN) > size) ||
> +			    (mdlen <= 0)) {
> +				OVS_NLERR(
> +				    1,
> +				    "length %d of nsh attr %d is invalid",
> +				    mdlen,
> +				    type
> +				);
> +				return -EINVAL;
> +			}

Ditto.

> +			memcpy(md2_dst, md2, mdlen);
> +			break;
> +		}
> +		default:
> +			OVS_NLERR(1, "Unknown nsh attribute %d",
> +				  type);
> +			return -EINVAL;

Ditto.

> +		}
> +	}
> +
> +	if (rem > 0) {
> +		OVS_NLERR(1, "nsh attribute has %d unknown bytes.", rem);
> +		return -EINVAL;
> +	}
> +
> +	if ((has_md1 && nsh->mdtype != NSH_M_TYPE1) ||
> +	    (has_md2 && nsh->mdtype != NSH_M_TYPE2)) {
> +		OVS_NLERR(1,
> +			  "nsh attribute has unmatched MD type %d.",
> +			  nsh->mdtype);
> +		return -EINVAL;
> +	}
> +
> +	if (unlikely(has_md1 && has_md2)) {
> +		OVS_NLERR(1, "both nsh md1 and md2 attribute are there");
> +		return -EINVAL;
> +	}
> +
> +	if (unlikely(!has_md1 && !has_md2)) {
> +		OVS_NLERR(1, "neither nsh md1 nor md2 attribute is there");
> +		return -EINVAL;
> +	}

Ditto. Plus I don't see a check that the OVS_NSH_KEY_ATTR_BASE attribute is
present. Seems that the compiler warned you about possibly unitialized flags
and ttl variables and you just silenced the warning without considering
whether it's not actually justified.

> +
> +	/* nsh header length  = NSH_BASE_HDR_LEN + mdlen */
> +	nsh->ver_flags_ttl_len = 0;
> +	len = NSH_BASE_HDR_LEN + mdlen;

In the whole function you open code NSH_BASE_HDR_LEN + mdlen and suddenly,
at the very end, you store it to a variable to be used just once? Call me
confused.

> +	nsh_set_flags_ttl_len(nsh, flags, ttl, len);
> +
> +	return 0;
> +}

So, this whole function does a lot of processing and copying. Why don't we
just parse the attributes once, cache the resulting header and just memcpy
it in the hot path?

> +
> +int nsh_key_from_nlattr(const struct nlattr *attr,
> +			struct ovs_key_nsh *nsh)

See above plus what I wrote for the previous function, it applies here as
well.

I stop here. I suspect there are similar things in the rest of the patch.
Please think about what I wrote and apply it to all similar situations. Not
as you do with nsh_push where you apparenly ignored nsh_pop just because
I mentioned nsh_push only.

 Jiri
