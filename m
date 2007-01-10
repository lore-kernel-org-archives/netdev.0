From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH/RFC 09/10] iptables TPROXY target
Date: Wed, 10 Jan 2007 13:45:12 +0100
Message-ID: <45A4DFD8.3050008@trash.net>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <20070103163828.14635.74153.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33967 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932803AbXAJMpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 07:45:14 -0500
To: KOVACS Krisztian <hidden@balabit.hu>
In-Reply-To: <20070103163828.14635.74153.stgit@nienna.balabit>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KOVACS Krisztian wrote:

> diff --git a/net/ipv4/netfilter/ipt_TPROXY.c b/net/ipv4/netfilter/ipt_TPROXY.c
> new file mode 100644
> index 0000000..6f64717
> --- /dev/null
> +++ b/net/ipv4/netfilter/ipt_TPROXY.c

> +static unsigned int
> +target(struct sk_buff **pskb,
> +       const struct net_device *in,
> +       const struct net_device *out,
> +       unsigned int hooknum,
> +       const struct xt_target *target,
> +       const void *targinfo)
> +{
> +	const struct iphdr *iph = (*pskb)->nh.iph;
> +	unsigned int verdict = NF_ACCEPT;
> +	struct sk_buff *skb = *pskb;
> +	struct udphdr _hdr, *hp;
> +	struct sock *sk;
> +
> +	/* TCP/UDP only */
> +	if ((iph->protocol != IPPROTO_TCP) &&
> +	    (iph->protocol != IPPROTO_UDP))
> +		return NF_ACCEPT;
> +
> +	if (in == NULL)
> +		return NF_ACCEPT;
> +
> +	if ((skb->dst != NULL) || (skb->ip_tproxy == 1))
> +		return NF_ACCEPT;
> +
> +	hp = skb_header_pointer(*pskb, iph->ihl * 4, sizeof(_hdr), &_hdr);
> +	if (hp == NULL)
> +		return NF_DROP;
> +
> +	sk = ip_tproxy_get_sock(iph->protocol,
> +				iph->saddr, iph->daddr,
> +				hp->source, hp->dest, in);
> +	if (sk != NULL) {
> +		if (ip_tproxy_do_divert(skb, sk, 0, in) < 0)
> +			verdict = NF_DROP;
> +		sock_put(sk);

Missing time wait socket handling.

> +	}
> +
> +	return verdict;
> +}
> +
> +static int
> +checkentry(const char *tablename,
> +	   const void *e,
> +	   const struct xt_target *target,
> +           void *targinfo,
> +           unsigned int hook_mask)
> +{
> +	/* checks are now done by the x_tables core based on
> +	 * information specified in the ipt_target structure */
> +	return 1;
> +}

The function is optional, you can simply delete it.

> +
> +static struct ipt_target ipt_tproxy_reg = {
> +	.name		= "TPROXY",
> +	.target		= target,
> +	.targetsize	= sizeof(struct ipt_tproxy_target_info),
> +	.table		= "tproxy",
> +	.checkentry	= checkentry,
> +	.me		= THIS_MODULE,
> +};
> +
> +static int __init init(void)
> +{
> +	if (ipt_register_target(&ipt_tproxy_reg))
> +		return -EINVAL;

This should return the result of ipt_register_target.
