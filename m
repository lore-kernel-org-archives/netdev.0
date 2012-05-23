From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 03/17] netfilter: add namespace support for l3proto
Date: Wed, 23 May 2012 12:29:10 +0200
Message-ID: <20120523102910.GC2836@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-4-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37759 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747Ab2EWK3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2012 06:29:16 -0400
Content-Disposition: inline
In-Reply-To: <1336985547-31960-4-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 14, 2012 at 04:52:13PM +0800, Gao feng wrote:
> -Add the struct net as param of nf_conntrack_l3proto_(un)register.
>  register or unregister the l3proto only when the net is init_net.
> 
> -The new struct nf_ip_net is used to store the sysctl header and data
>  of l3proto_ipv4,l4proto_tcp(6),l4proto_udp(6),l4proto_icmp(v6).
>  because the protos such tcp and tcp6 use the same data,so making
>  nf_ip_net as a field of netns_ct is the easiest way to manager it.
> 
> -nf_ct_l3proto_register_sysctl call init_net to initial the pernet data
>  of l3proto.
> 
> -nf_ct_l3proto_net is used to get the pernet data of l3proto.
> 
> -export nf_conntrack_l3proto_(un)register
> 
> -use init_net as param of nf_conntrack_l3proto_(un)register.
> 
> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  include/net/netfilter/nf_conntrack_l3proto.h   |    6 +-
>  include/net/netns/conntrack.h                  |    8 ++
>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    6 +-
>  net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    6 +-
>  net/netfilter/nf_conntrack_proto.c             |  127 +++++++++++++++---------
>  5 files changed, 97 insertions(+), 56 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
> index 9766005..d6df8c7 100644
> --- a/include/net/netfilter/nf_conntrack_l3proto.h
> +++ b/include/net/netfilter/nf_conntrack_l3proto.h
> @@ -79,8 +79,10 @@ struct nf_conntrack_l3proto {
>  extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[AF_MAX];
>  
>  /* Protocol registration. */
> -extern int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto);
> -extern void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto);
> +extern int nf_conntrack_l3proto_register(struct net *net,
> +					 struct nf_conntrack_l3proto *proto);
> +extern void nf_conntrack_l3proto_unregister(struct net *net,
> +					    struct nf_conntrack_l3proto *proto);
>  extern struct nf_conntrack_l3proto *nf_ct_l3proto_find_get(u_int16_t l3proto);
>  extern void nf_ct_l3proto_put(struct nf_conntrack_l3proto *p);
>  
> diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
> index 1f53038..94992e9 100644
> --- a/include/net/netns/conntrack.h
> +++ b/include/net/netns/conntrack.h
> @@ -20,6 +20,13 @@ struct nf_proto_net {
>  	unsigned int		users;
>  };
>  
> +struct nf_ip_net {
> +#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
> +	struct ctl_table_header *ctl_table_header;
> +	struct ctl_table	*ctl_table;
> +#endif
> +};
> +
>  struct netns_ct {
>  	atomic_t		count;
>  	unsigned int		expect_count;
> @@ -40,6 +47,7 @@ struct netns_ct {
>  	unsigned int		sysctl_log_invalid; /* Log invalid packets */
>  	int			sysctl_auto_assign_helper;
>  	bool			auto_assign_helper_warned;
> +	struct nf_ip_net	proto;
                                ^^^^^
please, rename this to something like nf_ct_proto.

>  #ifdef CONFIG_SYSCTL
>  	struct ctl_table_header	*sysctl_header;
>  	struct ctl_table_header	*acct_sysctl_header;
> diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
> index 46ec515..0c0fb90 100644
> --- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
> +++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
> @@ -409,7 +409,7 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
>  		goto cleanup_udp;
>  	}
>  
> -	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv4);
> +	ret = nf_conntrack_l3proto_register(&init_net, &nf_conntrack_l3proto_ipv4);
>  	if (ret < 0) {
>  		pr_err("nf_conntrack_ipv4: can't register ipv4\n");
>  		goto cleanup_icmp;
> @@ -432,7 +432,7 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
>  	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
>  #endif
>   cleanup_ipv4:
> -	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
> +	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv4);
>   cleanup_icmp:
>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmp);
>   cleanup_udp:
> @@ -451,7 +451,7 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
>  	nf_conntrack_ipv4_compat_fini();
>  #endif
>  	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
> -	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
> +	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv4);
>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmp);
>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp4);
>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp4);
> diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> index 55f379f..6cfbe7b 100644
> --- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> +++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> @@ -359,7 +359,7 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
>  		goto cleanup_udp;
>  	}
>  
> -	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv6);
> +	ret = nf_conntrack_l3proto_register(&init_net, &nf_conntrack_l3proto_ipv6);
>  	if (ret < 0) {
>  		pr_err("nf_conntrack_ipv6: can't register ipv6\n");
>  		goto cleanup_icmpv6;
> @@ -375,7 +375,7 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
>  	return ret;
>  
>   cleanup_ipv6:
> -	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
> +	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv6);
>   cleanup_icmpv6:
>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmpv6);
>   cleanup_udp:
> @@ -389,7 +389,7 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
>  {
>  	synchronize_net();
>  	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
> -	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
> +	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv6);
>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmpv6);
>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp6);
>  	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp6);
> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
> index 6d68727..7ee6653 100644
> --- a/net/netfilter/nf_conntrack_proto.c
> +++ b/net/netfilter/nf_conntrack_proto.c
> @@ -170,85 +170,116 @@ static int kill_l4proto(struct nf_conn *i, void *data)
>  	       nf_ct_l3num(i) == l4proto->l3proto;
>  }
>  
> -static int nf_ct_l3proto_register_sysctl(struct nf_conntrack_l3proto *l3proto)
> +static struct nf_ip_net *nf_ct_l3proto_net(struct net *net,
> +					   struct nf_conntrack_l3proto *l3proto)
> +{
> +	if (l3proto->l3proto == PF_INET)
> +		return &net->ct.proto;
> +	else
> +		return NULL;
> +}
> +
> +static int nf_ct_l3proto_register_sysctl(struct net *net,
> +					 struct nf_conntrack_l3proto *l3proto)
>  {
>  	int err = 0;
> +	struct nf_ip_net *in = nf_ct_l3proto_net(net, l3proto);
>  
> -#ifdef CONFIG_SYSCTL
> -	if (l3proto->ctl_table != NULL) {
> -		err = nf_ct_register_sysctl(&init_net,
> -					    &l3proto->ctl_table_header,
> +	if (in == NULL)
> +		return 0;

Under what circunstances that in be NULL?

> +
> +#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
> +	if (in->ctl_table != NULL) {
> +		err = nf_ct_register_sysctl(net,
> +					    &in->ctl_table_header,
>  					    l3proto->ctl_table_path,
> -					    l3proto->ctl_table, NULL);
> +					    in->ctl_table,
> +					    NULL);
> +		if (err < 0) {
> +			kfree(in->ctl_table);
> +			in->ctl_table = NULL;

do we need this extra NULL assignment?

> +		}
>  	}
>  #endif
>  	return err;
>  }
>  
> -static void nf_ct_l3proto_unregister_sysctl(struct nf_conntrack_l3proto *l3proto)
> +static void nf_ct_l3proto_unregister_sysctl(struct net *net,
> +					    struct nf_conntrack_l3proto *l3proto)
>  {
> -#ifdef CONFIG_SYSCTL
> -	if (l3proto->ctl_table_header != NULL)
> -		nf_ct_unregister_sysctl(&l3proto->ctl_table_header,
> -					&l3proto->ctl_table, NULL);
> +	struct nf_ip_net *in = nf_ct_l3proto_net(net, l3proto);
> +
> +	if (in == NULL)
> +		return;
> +#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
> +	if (in->ctl_table_header != NULL)
> +		nf_ct_unregister_sysctl(&in->ctl_table_header,
> +					&in->ctl_table,
> +					NULL);
>  #endif
>  }
>  
> -int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto)
> +int nf_conntrack_l3proto_register(struct net *net,
> +				  struct nf_conntrack_l3proto *proto)
>  {
>  	int ret = 0;
> -	struct nf_conntrack_l3proto *old;
> -
> -	if (proto->l3proto >= AF_MAX)
> -		return -EBUSY;
>  
> -	if (proto->tuple_to_nlattr && !proto->nlattr_tuple_size)
> -		return -EINVAL;
> +	if (net == &init_net) {

Same things as in previous patch. Move...

if (net == &init_net) {
     ... this code ...
}

into some static int nf_conntrack_l3proto_register_net function.

> +		struct nf_conntrack_l3proto *old;
>  
> -	mutex_lock(&nf_ct_proto_mutex);
> -	old = rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
> -					lockdep_is_held(&nf_ct_proto_mutex));
> -	if (old != &nf_conntrack_l3proto_generic) {
> -		ret = -EBUSY;
> -		goto out_unlock;
> -	}
> +		if (proto->l3proto >= AF_MAX)
> +			return -EBUSY;
>  
> -	ret = nf_ct_l3proto_register_sysctl(proto);
> -	if (ret < 0)
> -		goto out_unlock;
> +		if (proto->tuple_to_nlattr && !proto->nlattr_tuple_size)
> +			return -EINVAL;
>  
> -	if (proto->nlattr_tuple_size)
> -		proto->nla_size = 3 * proto->nlattr_tuple_size();
> +		mutex_lock(&nf_ct_proto_mutex);
> +		old = rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
> +						lockdep_is_held(&nf_ct_proto_mutex));
> +		if (old != &nf_conntrack_l3proto_generic) {
> +			ret = -EBUSY;
> +			goto out_unlock;
> +		}
>  
> -	rcu_assign_pointer(nf_ct_l3protos[proto->l3proto], proto);
> +		if (proto->nlattr_tuple_size)
> +			proto->nla_size = 3 * proto->nlattr_tuple_size();
>  
> +		rcu_assign_pointer(nf_ct_l3protos[proto->l3proto], proto);
>  out_unlock:
> -	mutex_unlock(&nf_ct_proto_mutex);
> -	return ret;
> +		mutex_unlock(&nf_ct_proto_mutex);
> +		if (ret < 0)
> +			return ret;
> +	}
> +	if (proto->init_net) {
> +		ret = proto->init_net(net);
> +		if (ret < 0)
> +			return ret;
> +	}
> +	return nf_ct_l3proto_register_sysctl(net, proto);
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
>  
> -void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
> +void nf_conntrack_l3proto_unregister(struct net *net,
> +				     struct nf_conntrack_l3proto *proto)
>  {
> -	struct net *net;
> -
> -	BUG_ON(proto->l3proto >= AF_MAX);
> +	if (net == &init_net) {
> +		BUG_ON(proto->l3proto >= AF_MAX);

Same thing as above.

>  
> -	mutex_lock(&nf_ct_proto_mutex);
> -	BUG_ON(rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
> -					 lockdep_is_held(&nf_ct_proto_mutex)
> -					 ) != proto);
> -	rcu_assign_pointer(nf_ct_l3protos[proto->l3proto],
> -			   &nf_conntrack_l3proto_generic);
> -	nf_ct_l3proto_unregister_sysctl(proto);
> -	mutex_unlock(&nf_ct_proto_mutex);
> +		mutex_lock(&nf_ct_proto_mutex);
> +		BUG_ON(rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
> +						 lockdep_is_held(&nf_ct_proto_mutex)
> +						 ) != proto);
> +		rcu_assign_pointer(nf_ct_l3protos[proto->l3proto],
> +				   &nf_conntrack_l3proto_generic);
> +		mutex_unlock(&nf_ct_proto_mutex);
>  
> -	synchronize_rcu();
> +		synchronize_rcu();
> +	}
> +	nf_ct_l3proto_unregister_sysctl(net, proto);
>  
>  	/* Remove all contrack entries for this protocol */
>  	rtnl_lock();
> -	for_each_net(net)
> -		nf_ct_iterate_cleanup(net, kill_l3proto, proto);
> +	nf_ct_iterate_cleanup(net, kill_l3proto, proto);
>  	rtnl_unlock();
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
> -- 
> 1.7.7.6
> 
