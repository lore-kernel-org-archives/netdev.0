From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 02/17] netfilter: add namespace support for l4proto
Date: Wed, 23 May 2012 12:25:57 +0200
Message-ID: <20120523102557.GB2836@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-3-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1336985547-31960-3-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 04:52:12PM +0800, Gao feng wrote:
> From: Gao feng <gaofeng@cn.fujitus.com>
> 
> -nf_ct_(un)register_sysctl are changed to support net namespace,
>  use (un)register_net_sysctl_table replaces (un)register_sysctl_paths.
>  and in nf_ct_unregister_sysctl,kfree table only when users is 0.
> 
> -Add the struct net as param of nf_conntrack_l4proto_(un)register.
>  register or unregister the l4proto only when the net is init_net.
> 
> -nf_conntrack_l4proto_register call init_net to initial the pernet
>  data of l4proto.
> 
> -nf_ct_l4proto_net is used to get the pernet data of l4proto.
> 
> -use init_net as a param of nf_conntrack_l4proto_(un)register.
> 
> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitus.com>
> ---
>  include/net/netfilter/nf_conntrack_l4proto.h   |   13 +-
>  net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |   18 +-
>  net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |   18 +-
>  net/netfilter/nf_conntrack_proto.c             |  245 ++++++++++++++----------
>  net/netfilter/nf_conntrack_proto_dccp.c        |   10 +-
>  net/netfilter/nf_conntrack_proto_gre.c         |    6 +-
>  net/netfilter/nf_conntrack_proto_sctp.c        |   10 +-
>  net/netfilter/nf_conntrack_proto_udplite.c     |   10 +-
>  8 files changed, 191 insertions(+), 139 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
> index a90eab5..a93dcd5 100644
> --- a/include/net/netfilter/nf_conntrack_l4proto.h
> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
> @@ -12,7 +12,7 @@
>  #include <linux/netlink.h>
>  #include <net/netlink.h>
>  #include <net/netfilter/nf_conntrack.h>
> -
> +#include <net/netns/generic.h>

Minor nitpick: make sure there's still one line between this structure
below and the include headers.

>  struct seq_file;
>  
>  struct nf_conntrack_l4proto {
> @@ -129,8 +129,15 @@ nf_ct_l4proto_find_get(u_int16_t l3proto, u_int8_t l4proto);
>  extern void nf_ct_l4proto_put(struct nf_conntrack_l4proto *p);
>  
>  /* Protocol registration. */
> -extern int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *proto);
> -extern void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *proto);
> +extern int nf_conntrack_l4proto_register(struct net *net,
> +					 struct nf_conntrack_l4proto *proto);
> +extern void nf_conntrack_l4proto_unregister(struct net *net,
> +					    struct nf_conntrack_l4proto *proto);
> +
> +extern int nf_ct_l4proto_register_sysctl(struct net *net,
> +					 struct nf_conntrack_l4proto *l4proto);
> +extern void nf_ct_l4proto_unregister_sysctl(struct net *net,
> +					    struct nf_conntrack_l4proto *l4proto);
>  
>  /* Generic netlink helpers */
>  extern int nf_ct_port_tuple_to_nlattr(struct sk_buff *skb,
> diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
> index 91747d4..46ec515 100644
> --- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
> +++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
> @@ -391,19 +391,19 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
>  		return ret;
>  	}
>  
> -	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp4);
> +	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_tcp4);
>  	if (ret < 0) {
>  		pr_err("nf_conntrack_ipv4: can't register tcp.\n");
>  		goto cleanup_sockopt;
>  	}
>  
> -	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp4);
> +	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udp4);
>  	if (ret < 0) {
>  		pr_err("nf_conntrack_ipv4: can't register udp.\n");
>  		goto cleanup_tcp;
>  	}
>  
> -	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmp);
> +	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_icmp);
>  	if (ret < 0) {
>  		pr_err("nf_conntrack_ipv4: can't register icmp.\n");
>  		goto cleanup_udp;
> @@ -434,11 +434,11 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
>   cleanup_ipv4:
>  	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
>   cleanup_icmp:
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmp);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmp);
>   cleanup_udp:
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp4);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp4);
>   cleanup_tcp:
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp4);
>   cleanup_sockopt:
>  	nf_unregister_sockopt(&so_getorigdst);
>  	return ret;
> @@ -452,9 +452,9 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
>  #endif
>  	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
>  	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmp);
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp4);
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp4);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmp);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp4);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp4);
>  	nf_unregister_sockopt(&so_getorigdst);
>  }
>  
> diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> index fe925e4..55f379f 100644
> --- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> +++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
> @@ -341,19 +341,19 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
>  	need_conntrack();
>  	nf_defrag_ipv6_enable();
>  
> -	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_tcp6);
> +	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_tcp6);
>  	if (ret < 0) {
>  		pr_err("nf_conntrack_ipv6: can't register tcp.\n");
>  		return ret;
>  	}
>  
> -	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udp6);
> +	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udp6);
>  	if (ret < 0) {
>  		pr_err("nf_conntrack_ipv6: can't register udp.\n");
>  		goto cleanup_tcp;
>  	}
>  
> -	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_icmpv6);
> +	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_icmpv6);
>  	if (ret < 0) {
>  		pr_err("nf_conntrack_ipv6: can't register icmpv6.\n");
>  		goto cleanup_udp;
> @@ -377,11 +377,11 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
>   cleanup_ipv6:
>  	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
>   cleanup_icmpv6:
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmpv6);
>   cleanup_udp:
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp6);
>   cleanup_tcp:
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp6);
>  	return ret;
>  }
>  
> @@ -390,9 +390,9 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
>  	synchronize_net();
>  	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
>  	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_icmpv6);
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udp6);
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_tcp6);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmpv6);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp6);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp6);
>  }
>  
>  module_init(nf_conntrack_l3proto_ipv6_init);
> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
> index 8b631b0..6d68727 100644
> --- a/net/netfilter/nf_conntrack_proto.c
> +++ b/net/netfilter/nf_conntrack_proto.c
> @@ -35,30 +35,39 @@ EXPORT_SYMBOL_GPL(nf_ct_l3protos);
>  static DEFINE_MUTEX(nf_ct_proto_mutex);
>  
>  #ifdef CONFIG_SYSCTL
> -static int
> -nf_ct_register_sysctl(struct ctl_table_header **header, const char *path,
> -		      struct ctl_table *table, unsigned int *users)
> +int
> +nf_ct_register_sysctl(struct net *net,
> +		      struct ctl_table_header **header,
> +		      const char *path,
> +		      struct ctl_table *table,
> +		      unsigned int *users)
>  {
>  	if (*header == NULL) {
> -		*header = register_net_sysctl(&init_net, path, table);
> +		*header = register_net_sysctl(net, path, table);
>  		if (*header == NULL)
>  			return -ENOMEM;
>  	}
>  	if (users != NULL)
>  		(*users)++;
> +
>  	return 0;
>  }
> +EXPORT_SYMBOL_GPL(nf_ct_register_sysctl);

I don't see why we need to export nf_ct_register_sysctl. I think this
is a left-over from the previous patchset.

> -static void
> +void
>  nf_ct_unregister_sysctl(struct ctl_table_header **header,
> -			struct ctl_table *table, unsigned int *users)
> +			struct ctl_table **table,
> +			unsigned int *users)
>  {
>  	if (users != NULL && --*users > 0)
>  		return;
>  
>  	unregister_net_sysctl_table(*header);
> +	kfree(*table);
>  	*header = NULL;
> +	*table = NULL;
>  }
> +EXPORT_SYMBOL_GPL(nf_ct_unregister_sysctl);

Same thing. I don't find any external user of this new exported
function in your entire patchset.

You have to fix this.

>  #endif
>  
>  struct nf_conntrack_l4proto *
> @@ -167,7 +176,8 @@ static int nf_ct_l3proto_register_sysctl(struct nf_conntrack_l3proto *l3proto)
>  
>  #ifdef CONFIG_SYSCTL
>  	if (l3proto->ctl_table != NULL) {
> -		err = nf_ct_register_sysctl(&l3proto->ctl_table_header,
> +		err = nf_ct_register_sysctl(&init_net,
> +					    &l3proto->ctl_table_header,
>  					    l3proto->ctl_table_path,
>  					    l3proto->ctl_table, NULL);
>  	}
> @@ -180,7 +190,7 @@ static void nf_ct_l3proto_unregister_sysctl(struct nf_conntrack_l3proto *l3proto
>  #ifdef CONFIG_SYSCTL
>  	if (l3proto->ctl_table_header != NULL)
>  		nf_ct_unregister_sysctl(&l3proto->ctl_table_header,
> -					l3proto->ctl_table, NULL);
> +					&l3proto->ctl_table, NULL);
>  #endif
>  }
>  
> @@ -243,137 +253,172 @@ void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
>  
> -static int nf_ct_l4proto_register_sysctl(struct nf_conntrack_l4proto *l4proto)
> +static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
> +					      struct nf_conntrack_l4proto *l4proto)
>  {
> -	int err = 0;
> +	if (l4proto->net_id)
> +		return net_generic(net, *l4proto->net_id);
> +	else
> +		return NULL;
> +}
>  
> +int nf_ct_l4proto_register_sysctl(struct net *net,
> +				  struct nf_conntrack_l4proto *l4proto)
> +{
> +	int err = 0;
> +	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
> +	if (pn == NULL)
> +		return 0;
>  #ifdef CONFIG_SYSCTL
> -	if (l4proto->ctl_table != NULL) {
> -		err = nf_ct_register_sysctl(l4proto->ctl_table_header,
> +	if (pn->ctl_table != NULL) {
> +		err = nf_ct_register_sysctl(net,
> +					    &pn->ctl_table_header,
>  					    "net/netfilter",
> -					    l4proto->ctl_table,
> -					    l4proto->ctl_table_users);
> -		if (err < 0)
> +					    pn->ctl_table,
> +					    &pn->users);
> +		if (err < 0) {
> +			kfree(pn->ctl_table);
> +			pn->ctl_table = NULL;
                               ^^^^^^^^^^^
Do you really need to set this above to NULL? Is there any existing
bug trap? If not, it's superfluous, please, remove it.

>  			goto out;
> +		}
>  	}
>  #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> -	if (l4proto->ctl_compat_table != NULL) {
> -		err = nf_ct_register_sysctl(&l4proto->ctl_compat_table_header,
> +	if (l4proto->compat && pn->ctl_compat_table != NULL) {
> +		err = nf_ct_register_sysctl(net,
> +					    &pn->ctl_compat_header,
>  					    "net/ipv4/netfilter",
> -					    l4proto->ctl_compat_table, NULL);
> +					    pn->ctl_compat_table,
> +					    NULL);
>  		if (err == 0)
>  			goto out;
> -		nf_ct_unregister_sysctl(l4proto->ctl_table_header,
> -					l4proto->ctl_table,
> -					l4proto->ctl_table_users);
> +
> +		kfree(pn->ctl_compat_table);
> +		pn->ctl_compat_table = NULL;
> +		nf_ct_unregister_sysctl(&pn->ctl_table_header,
> +					&pn->ctl_table,
> +					&pn->users);
>  	}
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>  out:
>  #endif /* CONFIG_SYSCTL */
>  	return err;
>  }
> +EXPORT_SYMBOL_GPL(nf_ct_l4proto_register_sysctl);
>  
> -static void nf_ct_l4proto_unregister_sysctl(struct nf_conntrack_l4proto *l4proto)
> +void nf_ct_l4proto_unregister_sysctl(struct net *net,
> +				     struct nf_conntrack_l4proto *l4proto)
>  {
> +	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
> +	if (pn == NULL)
> +		return;
>  #ifdef CONFIG_SYSCTL
> -	if (l4proto->ctl_table_header != NULL &&
> -	    *l4proto->ctl_table_header != NULL)
> -		nf_ct_unregister_sysctl(l4proto->ctl_table_header,
> -					l4proto->ctl_table,
> -					l4proto->ctl_table_users);
> +	if (pn->ctl_table_header != NULL)
> +		nf_ct_unregister_sysctl(&pn->ctl_table_header,
> +					&pn->ctl_table,
> +					&pn->users);
> +
>  #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> -	if (l4proto->ctl_compat_table_header != NULL)
> -		nf_ct_unregister_sysctl(&l4proto->ctl_compat_table_header,
> -					l4proto->ctl_compat_table, NULL);
> +	if (l4proto->compat && pn->ctl_compat_header != NULL)
> +		nf_ct_unregister_sysctl(&pn->ctl_compat_header,
> +					&pn->ctl_compat_table,
> +					NULL);
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
> +#else
> +	pn->users--;
>  #endif /* CONFIG_SYSCTL */
>  }
> +EXPORT_SYMBOL_GPL(nf_ct_l4proto_unregister_sysctl);
>  
>  /* FIXME: Allow NULL functions and sub in pointers to generic for
>     them. --RR */
> -int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4proto)
> +int nf_conntrack_l4proto_register(struct net *net,
> +				  struct nf_conntrack_l4proto *l4proto)
>  {
>  	int ret = 0;

Minor nitpick: you save this amount of edits in this function that
result from the extra tabbing by moving all ...

if (net == &init_net) {
    ... this code ...
}

into some new static int nf_conntrack_l4proto_register_net(...) that
will be called by nf_conntrack_l4proto_register.

It will result more maintainable code. We still stick to 80-chars
columns, saving that extra tabbing makes the code more readable.

>  
> -	if (l4proto->l3proto >= PF_MAX)
> -		return -EBUSY;
> -
> -	if ((l4proto->to_nlattr && !l4proto->nlattr_size)
> -		|| (l4proto->tuple_to_nlattr && !l4proto->nlattr_tuple_size))
> -		return -EINVAL;
> -
> -	mutex_lock(&nf_ct_proto_mutex);
> -	if (!nf_ct_protos[l4proto->l3proto]) {
> -		/* l3proto may be loaded latter. */
> -		struct nf_conntrack_l4proto __rcu **proto_array;
> -		int i;
> -
> -		proto_array = kmalloc(MAX_NF_CT_PROTO *
> -				      sizeof(struct nf_conntrack_l4proto *),
> -				      GFP_KERNEL);
> -		if (proto_array == NULL) {
> -			ret = -ENOMEM;
> +	if (net == &init_net) {
> +		if (l4proto->l3proto >= PF_MAX)
> +			return -EBUSY;
> +
> +		if ((l4proto->to_nlattr && !l4proto->nlattr_size)
> +			|| (l4proto->tuple_to_nlattr && !l4proto->nlattr_tuple_size))
> +			return -EINVAL;
> +
> +		mutex_lock(&nf_ct_proto_mutex);
> +		if (!nf_ct_protos[l4proto->l3proto]) {
> +			/* l3proto may be loaded latter. */
> +			struct nf_conntrack_l4proto __rcu **proto_array;
> +			int i;
> +
> +			proto_array = kmalloc(MAX_NF_CT_PROTO *
> +					      sizeof(struct nf_conntrack_l4proto *),
> +					      GFP_KERNEL);
> +			if (proto_array == NULL) {
> +				ret = -ENOMEM;
> +				goto out_unlock;
> +			}
> +
> +			for (i = 0; i < MAX_NF_CT_PROTO; i++)
> +				RCU_INIT_POINTER(proto_array[i], &nf_conntrack_l4proto_generic);
> +
> +			/* Before making proto_array visible to lockless readers,
> +			 * we must make sure its content is committed to memory.
> +			 */
> +			smp_wmb();
> +
> +			nf_ct_protos[l4proto->l3proto] = proto_array;
> +		} else if (rcu_dereference_protected(
> +				nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
> +				lockdep_is_held(&nf_ct_proto_mutex)
> +				) != &nf_conntrack_l4proto_generic) {
> +			ret = -EBUSY;
>  			goto out_unlock;
>  		}
>  
> -		for (i = 0; i < MAX_NF_CT_PROTO; i++)
> -			RCU_INIT_POINTER(proto_array[i], &nf_conntrack_l4proto_generic);
> -
> -		/* Before making proto_array visible to lockless readers,
> -		 * we must make sure its content is committed to memory.
> -		 */
> -		smp_wmb();
> -
> -		nf_ct_protos[l4proto->l3proto] = proto_array;
> -	} else if (rcu_dereference_protected(
> -			nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
> -			lockdep_is_held(&nf_ct_proto_mutex)
> -			) != &nf_conntrack_l4proto_generic) {
> -		ret = -EBUSY;
> -		goto out_unlock;
> -	}
> -
> -	ret = nf_ct_l4proto_register_sysctl(l4proto);
> -	if (ret < 0)
> -		goto out_unlock;
> -
> -	l4proto->nla_size = 0;
> -	if (l4proto->nlattr_size)
> -		l4proto->nla_size += l4proto->nlattr_size();
> -	if (l4proto->nlattr_tuple_size)
> -		l4proto->nla_size += 3 * l4proto->nlattr_tuple_size();
> -
> -	rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
> -			   l4proto);
> +		l4proto->nla_size = 0;
> +		if (l4proto->nlattr_size)
> +			l4proto->nla_size += l4proto->nlattr_size();
> +		if (l4proto->nlattr_tuple_size)
> +			l4proto->nla_size += 3 * l4proto->nlattr_tuple_size();
>  
> +		rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
> +				   l4proto);
>  out_unlock:
> -	mutex_unlock(&nf_ct_proto_mutex);
> -	return ret;
> +		mutex_unlock(&nf_ct_proto_mutex);
> +		if (ret < 0)
> +			return ret;
> +	}
> +	if (l4proto->init_net) {
> +		ret = l4proto->init_net(net, l4proto->compat);
> +		if (ret < 0)
> +			return ret;
> +	}
> +	return nf_ct_l4proto_register_sysctl(net, l4proto);
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
>  
> -void nf_conntrack_l4proto_unregister(struct nf_conntrack_l4proto *l4proto)
> +void nf_conntrack_l4proto_unregister(struct net *net,
> +				     struct nf_conntrack_l4proto *l4proto)
>  {
> -	struct net *net;
> -
> -	BUG_ON(l4proto->l3proto >= PF_MAX);
> -
> -	mutex_lock(&nf_ct_proto_mutex);
> -	BUG_ON(rcu_dereference_protected(
> -			nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
> -			lockdep_is_held(&nf_ct_proto_mutex)
> -			) != l4proto);
> -	rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
> -			   &nf_conntrack_l4proto_generic);
> -	nf_ct_l4proto_unregister_sysctl(l4proto);
> -	mutex_unlock(&nf_ct_proto_mutex);
> -
> -	synchronize_rcu();
> +	if (net == &init_net) {

Same thing as above here.

> +		BUG_ON(l4proto->l3proto >= PF_MAX);
> +		mutex_lock(&nf_ct_proto_mutex);
> +
> +		BUG_ON(rcu_dereference_protected(
> +				nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
> +				lockdep_is_held(&nf_ct_proto_mutex)
> +				) != l4proto);
> +		rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
> +				   &nf_conntrack_l4proto_generic);
> +		mutex_unlock(&nf_ct_proto_mutex);
> +
> +		synchronize_rcu();
> +	}
> +	nf_ct_l4proto_unregister_sysctl(net, l4proto);
>  
>  	/* Remove all contrack entries for this protocol */
>  	rtnl_lock();
> -	for_each_net(net)
> -		nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
> +	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
>  	rtnl_unlock();
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
> @@ -383,7 +428,7 @@ int nf_conntrack_proto_init(void)
>  	unsigned int i;
>  	int err;
>  
> -	err = nf_ct_l4proto_register_sysctl(&nf_conntrack_l4proto_generic);
> +	err = nf_ct_l4proto_register_sysctl(&init_net, &nf_conntrack_l4proto_generic);
>  	if (err < 0)
>  		return err;
>  
> @@ -397,7 +442,7 @@ void nf_conntrack_proto_fini(void)
>  {
>  	unsigned int i;
>  
> -	nf_ct_l4proto_unregister_sysctl(&nf_conntrack_l4proto_generic);
> +	nf_ct_l4proto_unregister_sysctl(&init_net, &nf_conntrack_l4proto_generic);
>  
>  	/* free l3proto protocol tables */
>  	for (i = 0; i < PF_MAX; i++)
> diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
> index ef706a4..5a8e037 100644
> --- a/net/netfilter/nf_conntrack_proto_dccp.c
> +++ b/net/netfilter/nf_conntrack_proto_dccp.c
> @@ -945,17 +945,17 @@ static int __init nf_conntrack_proto_dccp_init(void)
>  	if (err < 0)
>  		goto err1;
>  
> -	err = nf_conntrack_l4proto_register(&dccp_proto4);
> +	err = nf_conntrack_l4proto_register(&init_net, &dccp_proto4);
>  	if (err < 0)
>  		goto err2;
>  
> -	err = nf_conntrack_l4proto_register(&dccp_proto6);
> +	err = nf_conntrack_l4proto_register(&init_net, &dccp_proto6);
>  	if (err < 0)
>  		goto err3;
>  	return 0;
>  
>  err3:
> -	nf_conntrack_l4proto_unregister(&dccp_proto4);
> +	nf_conntrack_l4proto_unregister(&init_net, &dccp_proto4);
>  err2:
>  	unregister_pernet_subsys(&dccp_net_ops);
>  err1:
> @@ -965,8 +965,8 @@ err1:
>  static void __exit nf_conntrack_proto_dccp_fini(void)
>  {
>  	unregister_pernet_subsys(&dccp_net_ops);
> -	nf_conntrack_l4proto_unregister(&dccp_proto6);
> -	nf_conntrack_l4proto_unregister(&dccp_proto4);
> +	nf_conntrack_l4proto_unregister(&init_net, &dccp_proto6);
> +	nf_conntrack_l4proto_unregister(&init_net, &dccp_proto4);
>  }
>  
>  module_init(nf_conntrack_proto_dccp_init);
> diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
> index 4bf6b4e..132f0d2 100644
> --- a/net/netfilter/nf_conntrack_proto_gre.c
> +++ b/net/netfilter/nf_conntrack_proto_gre.c
> @@ -396,18 +396,18 @@ static int __init nf_ct_proto_gre_init(void)
>  {
>  	int rv;
>  
> -	rv = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_gre4);
> +	rv = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_gre4);
>  	if (rv < 0)
>  		return rv;
>  	rv = register_pernet_subsys(&proto_gre_net_ops);
>  	if (rv < 0)
> -		nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
> +		nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_gre4);
>  	return rv;
>  }
>  
>  static void __exit nf_ct_proto_gre_fini(void)
>  {
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_gre4);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_gre4);
>  	unregister_pernet_subsys(&proto_gre_net_ops);
>  }
>  
> diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
> index 996db2f..97bbc20 100644
> --- a/net/netfilter/nf_conntrack_proto_sctp.c
> +++ b/net/netfilter/nf_conntrack_proto_sctp.c
> @@ -791,12 +791,12 @@ static int __init nf_conntrack_proto_sctp_init(void)
>  {
>  	int ret;
>  
> -	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp4);
> +	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_sctp4);
>  	if (ret) {
>  		pr_err("nf_conntrack_l4proto_sctp4: protocol register failed\n");
>  		goto out;
>  	}
> -	ret = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_sctp6);
> +	ret = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_sctp6);
>  	if (ret) {
>  		pr_err("nf_conntrack_l4proto_sctp6: protocol register failed\n");
>  		goto cleanup_sctp4;
> @@ -805,15 +805,15 @@ static int __init nf_conntrack_proto_sctp_init(void)
>  	return ret;
>  
>   cleanup_sctp4:
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_sctp4);
>   out:
>  	return ret;
>  }
>  
>  static void __exit nf_conntrack_proto_sctp_fini(void)
>  {
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp6);
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_sctp4);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_sctp6);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_sctp4);
>  }
>  
>  module_init(nf_conntrack_proto_sctp_init);
> diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
> index 4d60a53..fa142a8 100644
> --- a/net/netfilter/nf_conntrack_proto_udplite.c
> +++ b/net/netfilter/nf_conntrack_proto_udplite.c
> @@ -299,23 +299,23 @@ static int __init nf_conntrack_proto_udplite_init(void)
>  {
>  	int err;
>  
> -	err = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udplite4);
> +	err = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udplite4);
>  	if (err < 0)
>  		goto err1;
> -	err = nf_conntrack_l4proto_register(&nf_conntrack_l4proto_udplite6);
> +	err = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udplite6);
>  	if (err < 0)
>  		goto err2;
>  	return 0;
>  err2:
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udplite4);
>  err1:
>  	return err;
>  }
>  
>  static void __exit nf_conntrack_proto_udplite_exit(void)
>  {
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite6);
> -	nf_conntrack_l4proto_unregister(&nf_conntrack_l4proto_udplite4);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udplite6);
> +	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udplite4);
>  }
>  
>  module_init(nf_conntrack_proto_udplite_init);
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
