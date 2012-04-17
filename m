From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 03/12] netfilter: generic proto sysctl support for net
 namespace
Date: Tue, 17 Apr 2012 10:58:13 +0200
Message-ID: <20120417085813.GD2100@1984>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1334631383-12326-4-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52540 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755382Ab2DQI6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 04:58:30 -0400
Content-Disposition: inline
In-Reply-To: <1334631383-12326-4-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 17, 2012 at 10:56:14AM +0800, Gao feng wrote:
> register the generic proto's sysctl in pernet_operations.init.
> and use net->ct.proto.sysctl_generic_timeout replaces nf_ct_generic_timeout.
> 
> in the after patch,the timeout_nlattr_to_obj will be modified too.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/netfilter/nf_conntrack_core.c          |    6 ++
>  net/netfilter/nf_conntrack_proto_generic.c |   93 +++++++++++++++++++++++++---
>  2 files changed, 91 insertions(+), 8 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 729f157..bf11dd6 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1358,6 +1358,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
>  	nf_conntrack_tstamp_fini(net);
>  	nf_conntrack_acct_fini(net);
>  	nf_conntrack_expect_fini(net);
> +	nf_conntrack_proto_generic_net_fini(net);
>  	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
>  	kfree(net->ct.slabname);
>  	free_percpu(net->ct.stat);
> @@ -1573,6 +1574,9 @@ static int nf_conntrack_init_net(struct net *net)
>  		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
>  		goto err_hash;
>  	}
> +	ret = nf_conntrack_proto_generic_net_init(net);
> +	if (ret < 0)
> +		goto err_generic;
>  	ret = nf_conntrack_expect_init(net);
>  	if (ret < 0)
>  		goto err_expect;
> @@ -1600,6 +1604,8 @@ err_tstamp:
>  err_acct:
>  	nf_conntrack_expect_fini(net);
>  err_expect:
> +	nf_conntrack_proto_generic_net_fini(net);
> +err_generic:
>  	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
>  err_hash:
>  	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
> diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
> index 835e24c..0d4545b 100644
> --- a/net/netfilter/nf_conntrack_proto_generic.c
> +++ b/net/netfilter/nf_conntrack_proto_generic.c
> @@ -42,7 +42,7 @@ static int generic_print_tuple(struct seq_file *s,
>  
>  static unsigned int *generic_get_timeouts(struct net *net)
>  {
> -	return &nf_ct_generic_timeout;
> +	return &(net->ct.proto.sysctl_generic_timeout);
>  }
>  
>  /* Returns verdict for packet, or -1 for invalid. */
> @@ -105,11 +105,10 @@ generic_timeout_nla_policy[CTA_TIMEOUT_GENERIC_MAX+1] = {
>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
>  
>  #ifdef CONFIG_SYSCTL
> -static struct ctl_table_header *generic_sysctl_header;
>  static struct ctl_table generic_sysctl_table[] = {
>  	{
>  		.procname	= "nf_conntrack_generic_timeout",
> -		.data		= &nf_ct_generic_timeout,
> +		.data		= &init_net.ct.proto.sysctl_generic_timeout,
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
> @@ -120,7 +119,7 @@ static struct ctl_table generic_sysctl_table[] = {
>  static struct ctl_table generic_compat_sysctl_table[] = {
>  	{
>  		.procname	= "ip_conntrack_generic_timeout",
> -		.data		= &nf_ct_generic_timeout,
> +		.data		= &init_net.ct.proto.sysctl_generic_timeout,
>  		.maxlen		= sizeof(unsigned int),
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec_jiffies,
> @@ -150,11 +149,89 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
>  		.nla_policy	= generic_timeout_nla_policy,
>  	},
>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
> +};
> +
> +int nf_conntrack_proto_generic_net_init(struct net *net)

Please, check int nf_conntrack_ecache_init(struct net *net) for
instance on how we're doing the per-net registration of netfilter
modules.

Basically, we register the module only once for the init_net case.
Then, we register one sysctl per-net.

> +{
> +	struct ctl_table *table;
> +	int ret = 0;
>  #ifdef CONFIG_SYSCTL
> -	.ctl_table_header	= &generic_sysctl_header,
> -	.ctl_table		= generic_sysctl_table,
>  #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> -	.ctl_compat_table	= generic_compat_sysctl_table,
> +	struct ctl_table *compat_table;
>  #endif
>  #endif
> -};
> +	net->ct.proto.sysctl_generic_timeout = nf_ct_generic_timeout;
> +#ifdef CONFIG_SYSCTL
> +	table = kmemdup(generic_sysctl_table,
> +			sizeof(generic_sysctl_table),
> +			GFP_KERNEL);
> +	if (!table)
> +		return -ENOMEM;
> +	
> +	table[0].data = &net->ct.proto.sysctl_generic_timeout;
> +
> +	ret = nf_ct_register_net_sysctl(net,
> +					&net->ct.proto.generic_sysctl_header,
> +					nf_net_netfilter_sysctl_path,
> +					table,
> +					NULL);
> +	if (ret < 0) {
> +		printk(KERN_ERR 
> +			"nf_conntrack_proto_generic:"
> +			" can't register to sysctl.\n");
> +		kfree(table);
> +		return ret;
> +	}
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	compat_table = kmemdup(generic_compat_sysctl_table,
> +			       sizeof(generic_compat_sysctl_table),
> +			       GFP_KERNEL);
> +	if (!compat_table) {
> +		ret = -ENOMEM;
> +		goto out_compat;
> +	}
> +	compat_table[0].data = &net->ct.proto.sysctl_generic_timeout;
> +	ret = nf_ct_register_net_sysctl(net,
> +					&net->ct.proto.generic_compat_header,
> +					nf_net_ipv4_netfilter_sysctl_path,
> +					compat_table,
> +					NULL);
> +	if (ret < 0) {
> +		printk(KERN_ERR 
> +			"nf_conntrack_proto_generic:"
> +			" can't register to compat sysctl.\n");
> +		goto out_compat_register;
> +	}
> +#endif
> +	return 0;
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +out_compat_register:
> +	kfree(compat_table);
> +out_compat:
> +	nf_ct_unregister_net_sysctl(&net->ct.proto.generic_sysctl_header,
> +				    table,
> +				    NULL);
> +#endif
> +#endif
> +	return ret;
> +}
> +
> +void nf_conntrack_proto_generic_net_fini(struct net *net)
> +{
> +#ifdef CONFIG_SYSCTL
> +	struct ctl_table *table;
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	struct ctl_table *compat_table;
> +#endif
> +	table = net->ct.proto.generic_sysctl_header->ctl_table_arg;
> +	nf_ct_unregister_net_sysctl(&net->ct.proto.generic_sysctl_header,
> +				    table,
> +				    NULL);
> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	compat_table = net->ct.proto.generic_compat_header->ctl_table_arg;
> +	nf_ct_unregister_net_sysctl(&net->ct.proto.generic_compat_header,
> +				    compat_table,
> +				    NULL);
> +#endif
> +#endif
> +}
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
