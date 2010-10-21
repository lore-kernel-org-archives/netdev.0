From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 1/9] tproxy: split off ipv6 defragmentation to a separate
 module
Date: Thu, 21 Oct 2010 13:30:30 +0200
Message-ID: <4CC02456.4050301@trash.net>
References: <20101021104709.5192.31249.stgit@este.odu> <20101021104709.5192.64336.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101021104709.5192.64336.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 21.10.2010 12:47, schrieb KOVACS Krisztian:
> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
> index 138a8b3..bb669b4 100644
> --- a/net/ipv6/netfilter/nf_conntrack_reasm.c
> +++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
> @@ -73,7 +73,7 @@ static struct inet_frags nf_frags;
>  static struct netns_frags nf_init_frags;
>  
>  #ifdef CONFIG_SYSCTL
> -struct ctl_table nf_ct_ipv6_sysctl_table[] = {
> +struct ctl_table nf_ct_frag6_sysctl_table[] = {
>  	{
>  		.procname	= "nf_conntrack_frag6_timeout",
>  		.data		= &nf_init_frags.timeout,
> @@ -97,6 +97,8 @@ struct ctl_table nf_ct_ipv6_sysctl_table[] = {
>  	},
>  	{ }
>  };
> +
> +static struct ctl_table_header *nf_ct_frag6_sysctl_header;
>  #endif
>  
>  static unsigned int nf_hashfn(struct inet_frag_queue *q)
> @@ -623,11 +625,19 @@ int nf_ct_frag6_init(void)
>  	inet_frags_init_net(&nf_init_frags);
>  	inet_frags_init(&nf_frags);
>  
> +	nf_ct_frag6_sysctl_header = register_sysctl_paths(nf_net_netfilter_sysctl_path,
> +							  nf_ct_frag6_sysctl_table);
> +	if (!nf_ct_frag6_sysctl_header)
> +		return -ENOMEM;


This needs to call inet_frags_fini() on errors since inet_frags_init()
starts a timer to recalculate the secret.


> +
>  	return 0;
>  }
>  
>  void nf_ct_frag6_cleanup(void)
>  {
> +	unregister_sysctl_table(nf_ct_frag6_sysctl_header);
> +	nf_ct_frag6_sysctl_header = NULL;
> +
>  	inet_frags_fini(&nf_frags);
>  
>  	nf_init_frags.low_thresh = 0;
> diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
> new file mode 100644
> index 0000000..99abfb5
> --- /dev/null
> +++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
> @@ -0,0 +1,131 @@
> +/* (C) 1999-2001 Paul `Rusty' Russell
> + * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +
> +#include <linux/types.h>
> +#include <linux/ipv6.h>
> +#include <linux/in6.h>
> +#include <linux/netfilter.h>
> +#include <linux/module.h>
> +#include <linux/skbuff.h>
> +#include <linux/icmp.h>
> +#include <linux/sysctl.h>
> +#include <net/ipv6.h>
> +#include <net/inet_frag.h>
> +
> +#include <linux/netfilter_ipv6.h>
> +#include <linux/netfilter_bridge.h>
> +#include <net/netfilter/nf_conntrack.h>
> +#include <net/netfilter/nf_conntrack_helper.h>
> +#include <net/netfilter/nf_conntrack_l4proto.h>
> +#include <net/netfilter/nf_conntrack_l3proto.h>
> +#include <net/netfilter/nf_conntrack_core.h>
> +#include <net/netfilter/nf_conntrack_zones.h>
> +#include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
> +#include <net/netfilter/ipv6/nf_defrag_ipv6.h>
> +
> +static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
> +						struct sk_buff *skb)
> +{
> +	u16 zone = NF_CT_DEFAULT_ZONE;
> +
> +	if (skb->nfct)
> +		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
> +
> +#ifdef CONFIG_BRIDGE_NETFILTER
> +	if (skb->nf_bridge &&
> +	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
> +		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
> +#endif
> +	if (hooknum == NF_INET_PRE_ROUTING)
> +		return IP6_DEFRAG_CONNTRACK_IN + zone;
> +	else
> +		return IP6_DEFRAG_CONNTRACK_OUT + zone;
> +
> +}
> +
> +static unsigned int ipv6_defrag(unsigned int hooknum,
> +				struct sk_buff *skb,
> +				const struct net_device *in,
> +				const struct net_device *out,
> +				int (*okfn)(struct sk_buff *))
> +{
> +	struct sk_buff *reasm;
> +
> +	/* Previously seen (loopback)?	*/
> +	if (skb->nfct && !nf_ct_is_template((struct nf_conn *)skb->nfct))
> +		return NF_ACCEPT;
> +
> +	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(hooknum, skb));
> +	/* queued */
> +	if (reasm == NULL)
> +		return NF_STOLEN;
> +
> +	/* error occured or not fragmented */
> +	if (reasm == skb)
> +		return NF_ACCEPT;
> +
> +	nf_ct_frag6_output(hooknum, reasm, (struct net_device *)in,
> +			   (struct net_device *)out, okfn);
> +
> +	return NF_STOLEN;
> +}
> +
> +static struct nf_hook_ops ipv6_defrag_ops[] = {
> +	{
> +		.hook		= ipv6_defrag,
> +		.owner		= THIS_MODULE,
> +		.pf		= NFPROTO_IPV6,
> +		.hooknum	= NF_INET_PRE_ROUTING,
> +		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
> +	},
> +	{
> +		.hook		= ipv6_defrag,
> +		.owner		= THIS_MODULE,
> +		.pf		= NFPROTO_IPV6,
> +		.hooknum	= NF_INET_LOCAL_OUT,
> +		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
> +	},
> +};
> +
> +static int __init nf_defrag_init(void)
> +{
> +	int ret = 0;
> +
> +	ret = nf_ct_frag6_init();
> +	if (ret < 0) {
> +		pr_err("nf_defrag_ipv6: can't initialize frag6.\n");
> +		return ret;
> +	}
> +	ret = nf_register_hooks(ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
> +	if (ret < 0) {
> +		pr_err("nf_defrag_ipv6: can't register hooks\n");
> +		goto cleanup_frag6;
> +	}
> +	return ret;
> +
> +cleanup_frag6:
> +	nf_ct_frag6_cleanup();
> +	return ret;
> +
> +}
> +
> +static void __exit nf_defrag_fini(void)
> +{
> +	nf_unregister_hooks(ipv6_defrag_ops, ARRAY_SIZE(ipv6_defrag_ops));
> +	nf_ct_frag6_cleanup();
> +}
> +
> +void nf_defrag_ipv6_enable(void)
> +{
> +}
> +EXPORT_SYMBOL_GPL(nf_defrag_ipv6_enable);
> +
> +module_init(nf_defrag_init);
> +module_exit(nf_defrag_fini);
> +
> +MODULE_LICENSE("GPL");
> 
> 

