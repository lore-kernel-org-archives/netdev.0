From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net-next v2] openvswitch: enable NSH support
Date: Mon, 14 Aug 2017 12:09:14 -0400
Message-ID: <20170814160914.GC27729@dev-rhel7>
References: <1502371275-52446-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1502371275-52446-1-git-send-email-yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

On Thu, Aug 10, 2017 at 09:21:15PM +0800, Yi Yang wrote:
> OVS master and 2.8 branch has merged NSH userspace
> patch series, this patch is to enable NSH support
> in kernel data path in order that OVS can support
> NSH in 2.8 release in compat mode by porting this.
> 
> Signed-off-by: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/vxlan.c              |   7 ++
>  include/net/nsh.h                | 126 ++++++++++++++++++++++++++++++
>  include/uapi/linux/openvswitch.h |  33 ++++++++
>  net/openvswitch/actions.c        | 165 +++++++++++++++++++++++++++++++++++++++
>  net/openvswitch/flow.c           |  41 ++++++++++
>  net/openvswitch/flow.h           |   1 +
>  net/openvswitch/flow_netlink.c   |  54 ++++++++++++-
>  7 files changed, 426 insertions(+), 1 deletion(-)
>  create mode 100644 include/net/nsh.h

Hi Yi,

In general I'd like to echo Jiri's comments on the netlink attributes.
I'd like to see the metadata separate.

I have a few other comments below.

Thanks.
Eric.

[..]
> diff --git a/include/net/nsh.h b/include/net/nsh.h
> new file mode 100644
> index 0000000..96477a1
> --- /dev/null
> +++ b/include/net/nsh.h
> @@ -0,0 +1,126 @@
> +#ifndef __NET_NSH_H
> +#define __NET_NSH_H 1
> +
> +
> +/*
> + * Network Service Header:
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * |Ver|O|C|R|R|R|R|R|R|    Length   |   MD Type   |  Next Proto   |
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * |                Service Path ID                | Service Index |
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * |                                                               |
> + * ~               Mandatory/Optional Context Header               ~
> + * |                                                               |
> + * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> + * Ver = The version field is used to ensure backward compatibility
> + *       going forward with future NSH updates.  It MUST be set to 0x0
> + *       by the sender, in this first revision of NSH.
> + *
> + * O = OAM. when set to 0x1 indicates that this packet is an operations
> + *     and management (OAM) packet.  The receiving SFF and SFs nodes
> + *     MUST examine the payload and take appropriate action.
> + *
> + * C = context. Indicates that a critical metadata TLV is present.
> + *
> + * Length : total length, in 4-byte words, of NSH including the Base
> + *          Header, the Service Path Header and the optional variable
> + *          TLVs.
> + * MD Type: indicates the format of NSH beyond the mandatory Base Header
> + *          and the Service Path Header.
> + *
> + * Next Protocol: indicates the protocol type of the original packet. A
> + *          new IANA registry will be created for protocol type.
> + *
> + * Service Path Identifier (SPI): identifies a service path.
> + *          Participating nodes MUST use this identifier for Service
> + *          Function Path selection.
> + *
> + * Service Index (SI): provides location within the SFP.
> + *
> + * [0] https://tools.ietf.org/html/draft-ietf-sfc-nsh-13
> + */
> +
> +/**
> + * struct nsh_md1_ctx - Keeps track of NSH context data
> + * @nshc<1-4>: NSH Contexts.
> + */
> +struct nsh_md1_ctx {
> +	__be32 c[4];
> +};
> +
> +struct nsh_md2_tlv {
> +	__be16 md_class;
> +	u8 type;
> +	u8 length;
> +	u8 md_value[];
> +};
> +
> +struct nsh_hdr {
> +	__be16 ver_flags_len;
> +	u8 md_type;
> +	u8 next_proto;
> +	__be32 path_hdr;
> +	union {
> +	    struct nsh_md1_ctx md1;
> +	    struct nsh_md2_tlv md2[0];
> +	};
> +};
> +
> +/* Masking NSH header fields. */
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
> +static inline u16
> +nsh_hdr_len(const struct nsh_hdr *nsh)
> +{
> +	return 4 * (ntohs(nsh->ver_flags_len) & NSH_LEN_MASK) >> NSH_LEN_SHIFT;

This is doing the multiplication before the shift. It works only because
the shift is 0.

> +}
> +
> +static inline struct nsh_md1_ctx *
> +nsh_md1_ctx(struct nsh_hdr *nsh)
> +{
> +	return &nsh->md1;
> +}
> +
> +static inline struct nsh_md2_tlv *
> +nsh_md2_ctx(struct nsh_hdr *nsh)
> +{
> +	return nsh->md2;
> +}
> +
> +#endif /* __NET_NSH_H */
> diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
> index 156ee4c..5a1c94b 100644
> --- a/include/uapi/linux/openvswitch.h
> +++ b/include/uapi/linux/openvswitch.h
> @@ -333,6 +333,7 @@ enum ovs_key_attr {
>  	OVS_KEY_ATTR_CT_LABELS,	/* 16-octet connection tracking label */
>  	OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV4,   /* struct ovs_key_ct_tuple_ipv4 */
>  	OVS_KEY_ATTR_CT_ORIG_TUPLE_IPV6,   /* struct ovs_key_ct_tuple_ipv6 */
> +	OVS_KEY_ATTR_NSH,                  /* struct ovs_key_nsh */
>  
>  #ifdef __KERNEL__
>  	OVS_KEY_ATTR_TUNNEL_INFO,  /* struct ip_tunnel_info */
> @@ -491,6 +492,15 @@ struct ovs_key_ct_tuple_ipv6 {
>  	__u8   ipv6_proto;
>  };
>  
> +struct ovs_key_nsh {
> +	__u8 flags;
> +	__u8 mdtype;
> +	__u8 np;
> +	__u8 pad;
> +	__be32 path_hdr;
> +	__be32 c[4];
> +};
> +
>  /**
>   * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
>   * @OVS_FLOW_ATTR_KEY: Nested %OVS_KEY_ATTR_* attributes specifying the flow
> @@ -769,6 +779,25 @@ struct ovs_action_push_eth {
>  	struct ovs_key_ethernet addresses;
>  };
>  
> +#define OVS_PUSH_NSH_MAX_MD_LEN 248
> +/*
> + * struct ovs_action_push_nsh - %OVS_ACTION_ATTR_PUSH_NSH
> + * @flags: NSH header flags.
> + * @mdtype: NSH metadata type.
> + * @mdlen: Length of NSH metadata in bytes.
> + * @np: NSH next_protocol: Inner packet type.
> + * @path_hdr: NSH service path id and service index.
> + * @metadata: NSH metadata for MD type 1 or 2
> + */
> +struct ovs_action_push_nsh {
> +	__u8 flags;
> +	__u8 mdtype;
> +	__u8 mdlen;
> +	__u8 np;
> +	__be32 path_hdr;
> +	__u8 metadata[];
> +};
> +
>  /**
>   * enum ovs_action_attr - Action types.
>   *
> @@ -806,6 +835,8 @@ struct ovs_action_push_eth {
>   * packet.
>   * @OVS_ACTION_ATTR_POP_ETH: Pop the outermost Ethernet header off the
>   * packet.
> + * @OVS_ACTION_ATTR_PUSH_NSH: push NSH header to the packet.
> + * @OVS_ACTION_ATTR_POP_NSH: pop the outermost NSH header off the packet.
>   *
>   * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
>   * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
> @@ -835,6 +866,8 @@ enum ovs_action_attr {
>  	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
>  	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
>  	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
> +	OVS_ACTION_ATTR_PUSH_NSH,     /* struct ovs_action_push_nsh. */
> +	OVS_ACTION_ATTR_POP_NSH,      /* No argument. */
>  
>  	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
>  				       * from userspace. */
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index e461067..50f80bc 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -38,6 +38,7 @@
>  #include <net/dsfield.h>
>  #include <net/mpls.h>
>  #include <net/sctp/checksum.h>
> +#include <net/nsh.h>
>  
>  #include "datapath.h"
>  #include "flow.h"
> @@ -380,6 +381,114 @@ static int push_eth(struct sk_buff *skb, struct sw_flow_key *key,
>  	return 0;
>  }
>  
> +static int push_nsh(struct sk_buff *skb, struct sw_flow_key *key,
> +		    const struct ovs_action_push_nsh *oapn)
> +{
> +	struct nsh_hdr *nsh;
> +	size_t length = NSH_BASE_HDR_LEN + oapn->mdlen;
> +	u8 next_proto;
> +
> +	if (key->mac_proto == MAC_PROTO_ETHERNET) {
> +		next_proto = NSH_P_ETHERNET;
> +	} else {
> +		switch (ntohs(skb->protocol)) {
> +		case ETH_P_IP:
> +			next_proto = NSH_P_IPV4;
> +			break;
> +		case ETH_P_IPV6:
> +			next_proto = NSH_P_IPV6;
> +			break;
> +		case ETH_P_NSH:
> +			next_proto = NSH_P_NSH;
> +			break;
> +		default:
> +			return -ENOTSUPP;
> +		}
> +	}
> +
>

I believe you need to validate that oapn->mdlen is a multiple of 4.

> +	/* Add the NSH header */
> +	if (skb_cow_head(skb, length) < 0)
> +		return -ENOMEM;
> +
> +	skb_push(skb, length);
> +	nsh = (struct nsh_hdr *)(skb->data);
> +	nsh->ver_flags_len = htons((oapn->flags << NSH_FLAGS_SHIFT) |
> +				 (length >> 2));
> +	nsh->next_proto = next_proto;
> +	nsh->path_hdr = oapn->path_hdr;
> +	nsh->md_type = oapn->mdtype;
> +	switch (nsh->md_type) {
> +	case NSH_M_TYPE1:
> +		nsh->md1 = *(struct nsh_md1_ctx *)oapn->metadata;
> +		break;
> +	case NSH_M_TYPE2: {
> +		/* The MD2 metadata in oapn is already padded to 4 bytes. */
> +		size_t len = DIV_ROUND_UP(oapn->mdlen, 4) * 4;
> +
> +		memcpy(nsh->md2, oapn->metadata, len);

I don't see any validation of oapn->mdlen. Normally this happens in
__ovs_nla_copy_actions(). It will be made easier if you add a separate
MD attribute as Jiri has suggested.

> +		break;
> +	}
> +	default:
> +		return -ENOTSUPP;
> +	}
> +
> +	if (!skb->inner_protocol)
> +		skb_set_inner_protocol(skb, skb->protocol);
> +
> +	skb->protocol = htons(ETH_P_NSH);
> +	key->eth.type = htons(ETH_P_NSH);
> +	skb_reset_mac_header(skb);
> +	skb_reset_mac_len(skb);
> +
> +	/* safe right before invalidate_flow_key */
> +	key->mac_proto = MAC_PROTO_NONE;
> +	invalidate_flow_key(key);
> +	return 0;
> +}
> +
[..]
