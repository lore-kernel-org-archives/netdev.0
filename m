From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Fri, 18 Aug 2017 15:09:47 -0400
Message-ID: <20170818190947.GA1479@dev-rhel7>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org, blp@ovn.org,
        jbenc@redhat.com, jan.scheurich@ericsson.com
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751850AbdHRTJp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 15:09:45 -0400
Content-Disposition: inline
In-Reply-To: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 18, 2017 at 03:24:31PM +0800, Yi Yang wrote:
> v3->v4
>  - Add new NSH match field ttl
>  - Update NSH header to the latest format
>    which will be final format and won't change
>    per its author's confirmation.
>  - Fix comments for v3.

Hi Yi,
Only a few comments below since Jiri already supplied lots of feedback.

> 
> v2->v3
>  - Change OVS_KEY_ATTR_NSH to nested key to handle
>    length-fixed attributes and length-variable
>    attriubte more flexibly.
>  - Remove struct ovs_action_push_nsh completely
>  - Add code to handle nested attribute for SET_MASKED
>  - Change PUSH_NSH to use the nested OVS_KEY_ATTR_NSH
>    to transfer NSH header data.
>  - Fix comments and coding style issues by Jiri and Eric
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
> Signed-off-by: Yi Yang <yi.y.yang@intel.com>
> ---
[..]
> @@ -1210,6 +1373,20 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>  		case OVS_ACTION_ATTR_POP_ETH:
>  			err = pop_eth(skb, key);
>  			break;
> +
> +		case OVS_ACTION_ATTR_PUSH_NSH: {
> +			u8 buffer[256];

Use NSH_M_TYPE2_MAX_LEN

> +			struct nsh_hdr *nsh_hdr = (struct nsh_hdr *)buffer;
> +			const struct nsh_hdr *nsh_src = nsh_hdr;
> +
> +			nsh_hdr_from_nlattr(nla_data(a), nsh_hdr);
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
[..]
> +int nsh_key_from_nlattr(const struct nlattr *attr,
> +			struct ovs_key_nsh *nsh)
> +{
> +	struct nlattr *a;
> +	int rem;
> +	bool has_md1 = false;
> +	bool has_md2 = false;
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
> +
> +			memcpy(nsh, base, sizeof(*base));
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD1: {
> +			const struct ovs_nsh_key_md1 *md1 =
> +				(struct ovs_nsh_key_md1 *)nla_data(a);
> +
> +			has_md1 = true;
> +			memcpy(nsh->context, md1->context, sizeof(*md1));
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD2:
> +			/* Not supported yet */

return -ENOTPSUPP if it's not supported.

> +			has_md2 = true;
> +			break;
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
> +	if ((has_md1 && nsh->mdtype != NSH_M_TYPE1) ||
> +	    (has_md2 && nsh->mdtype != NSH_M_TYPE2)) {
> +		OVS_NLERR(1, "nsh attribute has unmatched MD type %d.",
> +			  nsh->mdtype);
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
> +	bool has_md1 = false;
> +	bool has_md2 = false;
> +	u8 mdtype = 0;
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
> +
> +			mdtype = base->mdtype;
> +			SW_FLOW_KEY_PUT(match, nsh.flags,
> +					base->flags, is_mask);
> +			SW_FLOW_KEY_PUT(match, nsh.ttl,
> +					base->ttl, is_mask);
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
> +
> +			has_md1 = true;
> +			for (i = 0; i < NSH_MD1_CONTEXT_SIZE; i++)
> +				SW_FLOW_KEY_PUT(match, nsh.context[i],
> +						md1->context[i], is_mask);
> +			break;
> +		}
> +		case OVS_NSH_KEY_ATTR_MD2:
> +			/* Not supported yet */

return -ENOTPSUPP if it's not supported.

> +			has_md2 = true;
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
> +	if (!is_mask) {
> +		if ((has_md1 && mdtype != NSH_M_TYPE1) ||
> +		    (has_md2 && mdtype != NSH_M_TYPE2)) {
> +			OVS_NLERR(1, "nsh attribute has unmatched MD type %d.",
> +				  mdtype);
> +			return -EINVAL;
> +		}
> +	}
> +
> +	return 0;
> +}
> +
[..]
> @@ -2636,6 +2984,17 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
>  			mac_proto = MAC_PROTO_ETHERNET;
>  			break;
>  
> +		case OVS_ACTION_ATTR_PUSH_NSH:

You need to some validation here, especially the metadata lengths.
Relying on action_lens is not enough because it's variable.

> +			mac_proto = MAC_PROTO_NONE;
> +			break;
> +
> +		case OVS_ACTION_ATTR_POP_NSH:
> +			if (key->nsh.np == NSH_P_ETHERNET)
> +				mac_proto = MAC_PROTO_ETHERNET;
> +			else
> +				mac_proto = MAC_PROTO_NONE;
> +			break;
> +
>  		default:
>  			OVS_NLERR(log, "Unknown Action type %d", type);
>  			return -EINVAL;
[..]
