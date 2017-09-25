From: Eric Garver <e@erig.me>
Subject: Re: [ovs-dev] [PATCH net-next v9] openvswitch: enable NSH support
Date: Mon, 25 Sep 2017 15:28:42 -0400
Message-ID: <20170925192842.GD1786@dev-rhel7>
References: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jbenc@redhat.com,
        davem@davemloft.net
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52450 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934880AbdIYT2h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 25 Sep 2017 15:28:37 -0400
Content-Disposition: inline
In-Reply-To: <1506348969-6233-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 10:16:09PM +0800, Yi Yang wrote:
> v8->v9
>  - Fix build error reported by daily intel build
>    because nsh module isn't selected by openvswitch
> 
> v7->v8
>  - Rework nested value and mask for OVS_KEY_ATTR_NSH
>  - Change pop_nsh to adapt to nsh kernel module
>  - Fix many issues per comments from Jiri Benc
> 
> v6->v7
>  - Remove NSH GSO patches in v6 because Jiri Benc
>    reworked it as another patch series and they have
>    been merged.
>  - Change it to adapt to nsh kernel module added by NSH
>    GSO patch series
> 
> v5->v6
>  - Fix the rest comments for v4.
>  - Add NSH GSO support for VxLAN-gpe + NSH and
>    Eth + NSH.
> 
> v4->v5
>  - Fix many comments by Jiri Benc and Eric Garver
>    for v4.
> 
> v3->v4
>  - Add new NSH match field ttl
>  - Update NSH header to the latest format
>    which will be final format and won't change
>    per its author's confirmation.
>  - Fix comments for v3.
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
> NSH in compat mode by porting this.
> 
> Signed-off-by: Yi Yang <yi.y.yang@intel.com>
> ---
>  include/net/nsh.h                |   3 +
>  include/uapi/linux/openvswitch.h |  29 ++++
>  net/nsh/nsh.c                    |  53 +++++++
>  net/openvswitch/Kconfig          |   1 +
>  net/openvswitch/actions.c        | 112 ++++++++++++++
>  net/openvswitch/flow.c           |  51 ++++++
>  net/openvswitch/flow.h           |  11 ++
>  net/openvswitch/flow_netlink.c   | 324 ++++++++++++++++++++++++++++++++++++++-
>  net/openvswitch/flow_netlink.h   |   5 +
>  9 files changed, 588 insertions(+), 1 deletion(-)
> 
[...]
> diff --git a/net/nsh/nsh.c b/net/nsh/nsh.c
> index 58fb827..54334ca 100644
> --- a/net/nsh/nsh.c
> +++ b/net/nsh/nsh.c
> @@ -14,6 +14,59 @@
>  #include <net/nsh.h>
>  #include <net/tun_proto.h>
>  
> +int skb_push_nsh(struct sk_buff *skb, const struct nshhdr *src_nsh_hdr)
> +{
> +	struct nshhdr *nsh_hdr;
> +	size_t length = nsh_hdr_len(src_nsh_hdr);
> +	u8 next_proto;
> +
> +	if (skb->mac_len) {
> +		next_proto = TUN_P_ETHERNET;
> +	} else {
> +		next_proto = tun_p_from_eth_p(skb->protocol);
> +		if (!next_proto)
> +			return -EAFNOSUPPORT;
> +	}
> +
> +	/* Add the NSH header */
> +	if (skb_cow_head(skb, length) < 0)
> +		return -ENOMEM;
> +
> +	skb_push(skb, length);
> +	nsh_hdr = (struct nshhdr *)(skb->data);
> +	memcpy(nsh_hdr, src_nsh_hdr, length);
> +	nsh_hdr->np = next_proto;
> +
> +	skb->protocol = htons(ETH_P_NSH);
> +	skb_reset_mac_header(skb);
> +	skb_reset_mac_len(skb);
> +	skb_reset_network_header(skb);

I think you mean to reset network_header before mac_len.

> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(skb_push_nsh);
> +
> +int skb_pop_nsh(struct sk_buff *skb)
> +{
> +	struct nshhdr *nsh_hdr = (struct nshhdr *)(skb->data);
> +	size_t length;
> +	u16 inner_proto;
> +
> +	inner_proto = tun_p_to_eth_p(nsh_hdr->np);
> +	if (!inner_proto)
> +		return -EAFNOSUPPORT;
> +
> +	length = nsh_hdr_len(nsh_hdr);
> +	skb_pull(skb, length);

Do you need to verify you can actually pull length bytes? I don't see
any guarantee.

> +	skb_reset_mac_header(skb);
> +	skb_reset_mac_len(skb);
> +	skb_reset_network_header(skb);

Reset network before mac_len.

> +	skb->protocol = inner_proto;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(skb_pop_nsh);
> +
>  static struct sk_buff *nsh_gso_segment(struct sk_buff *skb,
>  				       netdev_features_t features)
>  {
[...]
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index a54a556..d026b85 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
[...]
> @@ -602,6 +642,59 @@ static int set_ipv6(struct sk_buff *skb, struct sw_flow_key *flow_key,
>  	return 0;
>  }
>  
> +static int set_nsh(struct sk_buff *skb, struct sw_flow_key *flow_key,
> +		   const struct nlattr *a)
> +{
> +	struct nshhdr *nsh_hdr;
> +	int err;
> +	u8 flags;
> +	u8 ttl;
> +	int i;
> +
> +	struct ovs_key_nsh key;
> +	struct ovs_key_nsh mask;
> +
> +	err = nsh_key_from_nlattr(a, &key, &mask);
> +	if (err)
> +		return err;
> +
> +	err = skb_ensure_writable(skb, skb_network_offset(skb) +
> +				  sizeof(struct nshhdr));

This calls pskb_may_pull(), but you're not pulling any data here.

> +	if (unlikely(err))
> +		return err;
> +
> +	nsh_hdr = (struct nshhdr *)skb_network_header(skb);
> +
> +	flags = nsh_get_flags(nsh_hdr);
> +	flags = OVS_MASKED(flags, key.flags, mask.flags);
> +	flow_key->nsh.flags = flags;
> +	ttl = nsh_get_ttl(nsh_hdr);
> +	ttl = OVS_MASKED(ttl, key.ttl, mask.ttl);
> +	flow_key->nsh.ttl = ttl;
> +	nsh_set_flags_and_ttl(nsh_hdr, flags, ttl);
> +	nsh_hdr->path_hdr = OVS_MASKED(nsh_hdr->path_hdr, key.path_hdr,
> +				       mask.path_hdr);
> +	flow_key->nsh.path_hdr = nsh_hdr->path_hdr;
> +	switch (nsh_hdr->mdtype) {
> +	case NSH_M_TYPE1:
> +		for (i = 0; i < NSH_MD1_CONTEXT_SIZE; i++) {
> +			nsh_hdr->md1.context[i] =
> +			    OVS_MASKED(nsh_hdr->md1.context[i], key.context[i],
> +				       mask.context[i]);
> +		}
> +		memcpy(flow_key->nsh.context, nsh_hdr->md1.context,
> +		       sizeof(nsh_hdr->md1.context));
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
[...]
