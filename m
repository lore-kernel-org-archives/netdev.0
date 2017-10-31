From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net-next v14] openvswitch: enable NSH support
Date: Tue, 31 Oct 2017 15:57:41 -0400
Message-ID: <20171031195741.GR22092@dev-rhel7>
References: <1509326974-3750-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org, jbenc@redhat.com,
        pshelar@ovn.org, davem@davemloft.net
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33268 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751366AbdJaT5o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 15:57:44 -0400
Content-Disposition: inline
In-Reply-To: <1509326974-3750-1-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 30, 2017 at 09:29:34AM +0800, Yi Yang wrote:
[...]
> +int nsh_pop(struct sk_buff *skb)
> +{
> +	struct nshhdr *nh;
> +	size_t length;
> +	__be16 inner_proto;
> +
> +	if (!pskb_may_pull(skb, NSH_BASE_HDR_LEN))
> +		return -ENOMEM;
> +	nh = (struct nshhdr *)(skb->data);
> +	length = nsh_hdr_len(nh);
> +	if (!pskb_may_pull(skb, length))
> +		return -ENOMEM;
> +
> +	nh = (struct nshhdr *)(skb->data);
> +	inner_proto = tun_p_to_eth_p(nh->np);

If you fetch inner_proto before the second pskb_may_pull then there is
no need to reload the nh pointer as you won't use it later.

> +	if (!inner_proto)
> +		return -EAFNOSUPPORT;
> +
> +	length = nsh_hdr_len(nh);

You already have the length from above. No need to get it again.

> +	skb_pull(skb, length);
> +	skb_reset_mac_header(skb);
> +	skb_reset_network_header(skb);
> +	skb_reset_mac_len(skb);
> +	skb->protocol = inner_proto;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(nsh_pop);
[...]
> +static int nsh_key_put_from_nlattr(const struct nlattr *attr,
> +				   struct sw_flow_match *match, bool is_mask,
> +				   bool is_push_nsh, bool log)
> +{
> +	struct nlattr *a;
> +	int rem;
> +	bool has_base = false;
> +	bool has_md1 = false;
> +	bool has_md2 = false;
> +	u8 mdtype = 0;
> +	int mdlen = 0;
> +
> +	if (WARN_ON(is_push_nsh && is_mask))
> +		return -EINVAL;

OVS_NLERR() is probably more appropriate.

> +
> +	nla_for_each_nested(a, attr, rem) {
> +		int type = nla_type(a);
> +		int i;
> +
[...]
