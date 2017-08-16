From: Eric Garver <e@erig.me>
Subject: Re: [PATCH v3] openvswitch: enable NSH support
Date: Wed, 16 Aug 2017 11:15:28 -0400
Message-ID: <20170816151528.GG27729@dev-rhel7>
References: <1502861730-76203-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1502861730-76203-1-git-send-email-yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

On Wed, Aug 16, 2017 at 01:35:30PM +0800, Yi Yang wrote:
> v2->v3
>  - Change OVS_KEY_ATTR_NSH to nested key to handle
>    length-fixed attributes and length-variable
>    attriubte more flexibly.
>  - Remove struct ovs_action_push_nsh completely
>  - Add code to handle nested attribute for SET_MASKED
>  - Change PUSH_NSH to use the nested OVS_KEY_ATTR_NSH
>    to transfer NSH header data.
>  - Fix comments and coding style issues by Jiri and Eric

Thanks for the updates Yi. Some feedback below.

> 
> v1->v2
>  - Change encap_nsh and decap_nsh to push_nsh and pop_nsh
>  - Dynamically allocate struct ovs_action_push_nsh for
>    length-variable metadata.
> 
> OVS master and 2.8 branch has merged NSH userspace
> patch series, this patch is to enable NSH support
> in kernel data path in order that OVS can support
> NSH in 2.8 release in compat mode by porting this.
> 
> Signed-off-by: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/vxlan.c              |   7 +
>  include/net/nsh.h                | 150 +++++++++++++++++++
>  include/uapi/linux/openvswitch.h |  30 ++++
>  net/openvswitch/actions.c        | 175 ++++++++++++++++++++++
>  net/openvswitch/flow.c           |  39 +++++
>  net/openvswitch/flow.h           |  11 ++
>  net/openvswitch/flow_netlink.c   | 304 ++++++++++++++++++++++++++++++++++++++-
>  net/openvswitch/flow_netlink.h   |   4 +
>  8 files changed, 719 insertions(+), 1 deletion(-)
>  create mode 100644 include/net/nsh.h
> 
[..]
> diff --git a/include/net/nsh.h b/include/net/nsh.h
> new file mode 100644
> index 0000000..54f44f6
> --- /dev/null
> +++ b/include/net/nsh.h
> @@ -0,0 +1,150 @@
[..]
> +#define NSH_VER_MASK       0xc000
> +#define NSH_VER_SHIFT      14
> +#define NSH_FLAGS_MASK     0x3fc0
> +#define NSH_FLAGS_SHIFT    6
> +#define NSH_LEN_MASK       0x003f
> +#define NSH_LEN_SHIFT      0
> +
> +#define NSH_SPI_MASK       0xffffff00
> +#define NSH_SPI_SHIFT      8
> +#define NSH_SI_MASK        0x000000ff
> +#define NSH_SI_SHIFT       0
> +
> +#define NSH_DST_PORT    4790     /* UDP Port for NSH on VXLAN. */
> +#define ETH_P_NSH       0x894F   /* Ethertype for NSH. */

ETH_P_NSH probably belongs in include/uapi/linux/if_ether.h with all the
other ETH_P_* defines.

> +
> +/* NSH Base Header Next Protocol. */
> +#define NSH_P_IPV4        0x01
> +#define NSH_P_IPV6        0x02
> +#define NSH_P_ETHERNET    0x03
> +#define NSH_P_NSH         0x04
> +#define NSH_P_MPLS        0x05
> +
> +/* MD Type Registry. */
> +#define NSH_M_TYPE1     0x01
> +#define NSH_M_TYPE2     0x02
> +#define NSH_M_EXP1      0xFE
> +#define NSH_M_EXP2      0xFF
> +
> +/* NSH Metadata Length. */
> +#define NSH_M_TYPE1_MDLEN 16
> +
> +/* NSH Base Header Length */
> +#define NSH_BASE_HDR_LEN  8
> +
> +/* NSH MD Type 1 header Length. */
> +#define NSH_M_TYPE1_LEN   24
> +
[..]
> diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
> index 1875bba..6c738d0 100644
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
> +	__u8 flags;
> +	__u8 mdtype;
> +	__u8 np;
> +	__u8 pad;
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

Are you intentionally not reserving space in the flow key for
OVS_NSH_KEY_ATTR_MD2? I know it's not supported yet, but much of the
code is stubbed out for it - just making sure this wasn't an oversight.

>  	struct {
>  		/* Connection tracking fields not packed above. */
>  		struct {
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index f07d10a..79059db 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -78,9 +78,11 @@ static bool actions_may_change_flow(const struct nlattr *actions)
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
> @@ -322,12 +324,22 @@ size_t ovs_tun_key_attr_size(void)
>  		+ nla_total_size(2);   /* OVS_TUNNEL_KEY_ATTR_TP_DST */
>  }
>  
> +size_t ovs_nsh_key_attr_size(void)
> +{
> +	/* Whenever adding new OVS_NSH_KEY_ FIELDS, we should consider
> +	 * updating this function.
> +	 */
> +	return  nla_total_size(8)      /* OVS_NSH_KEY_ATTR_BASE */
> +		+ nla_total_size(16)   /* OVS_NSH_KEY_ATTR_MD1 */
> +		+ nla_total_size(248); /* OVS_NSH_KEY_ATTR_MD2 */

_MD1 and _MD2 are mutually exclusive. You only need the larger of the
two.

Maybe use OVS_PUSH_NSH_MAX_MD_LEN instead of 248.

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
> @@ -341,6 +353,8 @@ size_t ovs_key_attr_size(void)
>  		+ nla_total_size(4)   /* OVS_KEY_ATTR_CT_MARK */
>  		+ nla_total_size(16)  /* OVS_KEY_ATTR_CT_LABELS */
>  		+ nla_total_size(40)  /* OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6 */
> +		+ nla_total_size(0)   /* OVS_KEY_ATTR_NSH */
> +		  + ovs_nsh_key_attr_size()
>  		+ nla_total_size(12)  /* OVS_KEY_ATTR_ETHERNET */
>  		+ nla_total_size(2)   /* OVS_KEY_ATTR_ETHERTYPE */
>  		+ nla_total_size(4)   /* OVS_KEY_ATTR_VLAN */
> @@ -373,6 +387,13 @@ static const struct ovs_len_tbl ovs_tunnel_key_lens[OVS_TUNNEL_KEY_ATTR_MAX + 1]
>  	[OVS_TUNNEL_KEY_ATTR_IPV6_DST]      = { .len = sizeof(struct in6_addr) },
>  };
>  
> +static const struct ovs_len_tbl
> +ovs_nsh_key_attr_lens[OVS_NSH_KEY_ATTR_MAX + 1] = {
> +	[OVS_NSH_KEY_ATTR_BASE]     = { .len = 8 },
> +	[OVS_NSH_KEY_ATTR_MD1]      = { .len = 16 },
> +	[OVS_NSH_KEY_ATTR_MD2]      = { .len = OVS_ATTR_VARIABLE },
> +};
> +
>  /* The size of the argument for each %OVS_KEY_ATTR_* Netlink attribute.  */
>  static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
>  	[OVS_KEY_ATTR_ENCAP]	 = { .len = OVS_ATTR_NESTED },
> @@ -405,6 +426,8 @@ static const struct ovs_len_tbl ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
>  		.len = sizeof(struct ovs_key_ct_tuple_ipv4) },
>  	[OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6] = {
>  		.len = sizeof(struct ovs_key_ct_tuple_ipv6) },
> +	[OVS_KEY_ATTR_NSH]       = { .len = OVS_ATTR_NESTED,
> +				     .next = ovs_nsh_key_attr_lens, },
>  };
>  
>  static bool check_attr_len(unsigned int attr_len, unsigned int expected_len)
> @@ -1179,6 +1202,209 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
>  	return 0;
>  }
>  
> +int push_nsh_para_from_nlattr(const struct nlattr *attr,
> +			      struct push_nsh_para *pnp)
> +{
> +	struct nlattr *a;
> +	int rem;
> +	u8 flags = 0;
> +	size_t mdlen = 0;
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
> +
> +		switch (type) {
> +		case OVS_NSH_KEY_ATTR_BASE: {
> +			const struct ovs_nsh_key_base *base =
> +				(struct ovs_nsh_key_base *)nla_data(a);
> +			flags = base->flags;
> +			pnp->next_proto = base->np;
> +			pnp->md_type = base->mdtype;
> +			pnp->path_hdr = base->path_hdr;
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD1: {
> +			const struct ovs_nsh_key_md1 *md1 =
> +				(struct ovs_nsh_key_md1 *)nla_data(a);
> +
> +			mdlen = nla_len(a);
> +			memcpy(pnp->metadata, md1, mdlen);
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD2: {
> +			const struct u8 *md2 = nla_data(a);
> +
> +			mdlen = nla_len(a);
> +			memcpy(pnp->metadata, md2, mdlen);
> +			break;
> +		}
> +		default:
> +			OVS_NLERR(1, "Unknown nsh attribute %d",
> +				  type);
> +			return -EINVAL;
> +		}
> +	}
> +
> +	if (rem > 0) {
> +		OVS_NLERR(1, "nsh attribute has %d unknown bytes.", rem);
> +		return -EINVAL;
> +	}
> +
> +	/* nsh header length  = NSH_BASE_HDR_LEN + mdlen */
> +	pnp->ver_flags_len = htons(flags << NSH_FLAGS_SHIFT |
> +				   (NSH_BASE_HDR_LEN + mdlen) >> 2);
> +
> +	return 0;
> +}
> +
> +int nsh_key_from_nlattr(const struct nlattr *attr,
> +			struct ovs_key_nsh *nsh)
> +{
> +	struct nlattr *a;
> +	int rem;
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
> +
> +		switch (type) {
> +		case OVS_NSH_KEY_ATTR_BASE: {
> +			const struct ovs_nsh_key_base *base =
> +				(struct ovs_nsh_key_base *)nla_data(a);
> +			nsh->flags = base->flags;
> +			nsh->mdtype = base->mdtype;
> +			nsh->np = base->np;
> +			nsh->path_hdr = base->path_hdr;
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD1: {
> +			const struct ovs_nsh_key_md1 *md1 =
> +				(struct ovs_nsh_key_md1 *)nla_data(a);
> +			memcpy(nsh->context, md1->context, sizeof(*md1));
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD2:
> +			/* Not supported yet */
> +			break;

When we encounter these metadata attributes do we need to verify that
nsh->mdtype is set correctly? Keep in mind we may parse ATTR_MD{1,2}
before ATTR_BASE.

> +		default:
> +			OVS_NLERR(1, "Unknown nsh attribute %d",
> +				  type);
> +			return -EINVAL;
> +		}
> +	}
> +
> +	if (rem > 0) {
> +		OVS_NLERR(1, "nsh attribute has %d unknown bytes.", rem);
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
> +static int nsh_key_put_from_nlattr(const struct nlattr *attr,
> +				   struct sw_flow_match *match, bool is_mask,
> +				   bool log)
> +{
> +	struct nlattr *a;
> +	int rem;
> +
> +	nla_for_each_nested(a, attr, rem) {
> +		int type = nla_type(a);
> +		int i;
> +
> +		if (type > OVS_NSH_KEY_ATTR_MAX) {
> +			OVS_NLERR(log, "nsh attr %d is out of range max %d",
> +				  type, OVS_NSH_KEY_ATTR_MAX);
> +			return -EINVAL;
> +		}
> +
> +		if (!check_attr_len(nla_len(a),
> +				    ovs_nsh_key_attr_lens[type].len)) {
> +			OVS_NLERR(
> +			    log,
> +			    "nsh attr %d has unexpected len %d expected %d",
> +			    type,
> +			    nla_len(a),
> +			    ovs_nsh_key_attr_lens[type].len
> +			);
> +			return -EINVAL;
> +		}
> +
> +		switch (type) {
> +		case OVS_NSH_KEY_ATTR_BASE: {
> +			const struct ovs_nsh_key_base *base =
> +				(struct ovs_nsh_key_base *)nla_data(a);
> +			SW_FLOW_KEY_PUT(match, nsh.flags,
> +					base->flags, is_mask);
> +			SW_FLOW_KEY_PUT(match, nsh.mdtype,
> +					base->mdtype, is_mask);
> +			SW_FLOW_KEY_PUT(match, nsh.np,
> +					base->np, is_mask);
> +			SW_FLOW_KEY_PUT(match, nsh.path_hdr,
> +					base->path_hdr, is_mask);
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD1: {
> +			const struct ovs_nsh_key_md1 *md1 =
> +				(struct ovs_nsh_key_md1 *)nla_data(a);
> +			for (i = 0; i < 4; i++)
> +				SW_FLOW_KEY_PUT(match, nsh.context[i],
> +						md1->context[i], is_mask);
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD2:
> +			/* Not supported yet */
> +			break;
> +		default:
> +			OVS_NLERR(log, "Unknown nsh attribute %d",
> +				  type);
> +			return -EINVAL;
> +		}
> +	}
> +
> +	if (rem > 0) {
> +		OVS_NLERR(log, "nsh attribute has %d unknown bytes.", rem);
> +		return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
>  static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
>  				u64 attrs, const struct nlattr **a,
>  				bool is_mask, bool log)
[..]
