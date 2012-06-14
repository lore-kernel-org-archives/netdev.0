From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 04/10] netfilter: regard users as refcount for
 l4proto's per-net data
Date: Thu, 14 Jun 2012 20:03:26 +0200
Message-ID: <20120614180326.GC10633@1984>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1339668445-23848-4-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34818 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751899Ab2FNSDb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 14:03:31 -0400
Content-Disposition: inline
In-Reply-To: <1339668445-23848-4-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 14, 2012 at 06:07:19PM +0800, Gao feng wrote:
> Now, nf_proto_net's users is confusing.
> we should regard it as the refcount for l4proto's per-net data,
> because maybe there are two l4protos use the same per-net data.
> 
> so increment pn->users when nf_conntrack_l4proto_register
> success, and decrement it for nf_conntrack_l4_unregister case.
> 
> because nf_conntrack_l3proto_ipv[4|6] don't use the same per-net
> data,so we don't need to add a refcnt for their per-net data.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/netfilter/nf_conntrack_proto.c |   70 ++++++++++++++++++++++-------------
>  1 files changed, 44 insertions(+), 26 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
> index c9df1b4..63f9430 100644
> --- a/net/netfilter/nf_conntrack_proto.c
> +++ b/net/netfilter/nf_conntrack_proto.c
> @@ -39,16 +39,13 @@ static int
>  nf_ct_register_sysctl(struct net *net,
>  		      struct ctl_table_header **header,
>  		      const char *path,
> -		      struct ctl_table *table,
> -		      unsigned int *users)
> +		      struct ctl_table *table)
>  {
>  	if (*header == NULL) {
>  		*header = register_net_sysctl(net, path, table);
>  		if (*header == NULL)
>  			return -ENOMEM;
>  	}
> -	if (users != NULL)
> -		(*users)++;
>  
>  	return 0;
>  }
> @@ -58,7 +55,7 @@ nf_ct_unregister_sysctl(struct ctl_table_header **header,
>  			struct ctl_table **table,
>  			unsigned int *users)
>  {
> -	if (users != NULL && --*users > 0)
> +	if (users != NULL && *users > 0)
>  		return;
>  
>  	unregister_net_sysctl_table(*header);
> @@ -191,8 +188,7 @@ static int nf_ct_l3proto_register_sysctl(struct net *net,
>  		err = nf_ct_register_sysctl(net,
>  					    &in->ctl_table_header,
>  					    l3proto->ctl_table_path,
> -					    in->ctl_table,
> -					    NULL);
> +					    in->ctl_table);
>  
>  		if (err < 0) {
>  			kfree(in->ctl_table);
> @@ -330,20 +326,17 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
>  
>  static
>  int nf_ct_l4proto_register_sysctl(struct net *net,
> +				  struct nf_proto_net *pn,
>  				  struct nf_conntrack_l4proto *l4proto)
>  {
>  	int err = 0;
> -	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
> -	if (pn == NULL)
> -		return 0;
>  
>  #ifdef CONFIG_SYSCTL
>  	if (pn->ctl_table != NULL) {
>  		err = nf_ct_register_sysctl(net,
>  					    &pn->ctl_table_header,
>  					    "net/netfilter",
> -					    pn->ctl_table,
> -					    &pn->users);
> +					    pn->ctl_table);
>  		if (err < 0) {
>  			if (!pn->users) {
>  				kfree(pn->ctl_table);
> @@ -357,8 +350,7 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
>  		err = nf_ct_register_sysctl(net,
>  					    &pn->ctl_compat_header,
>  					    "net/ipv4/netfilter",
> -					    pn->ctl_compat_table,
> -					    NULL);
> +					    pn->ctl_compat_table);
>  		if (err == 0)
>  			goto out;
>  		nf_ct_kfree_compat_sysctl_table(pn);
> @@ -374,11 +366,9 @@ out:
>  
>  static
>  void nf_ct_l4proto_unregister_sysctl(struct net *net,
> +				     struct nf_proto_net *pn,
>  				     struct nf_conntrack_l4proto *l4proto)
>  {
> -	struct nf_proto_net *pn = nf_ct_l4proto_net(net, l4proto);
> -	if (pn == NULL)
> -		return;
>  #ifdef CONFIG_SYSCTL
>  	if (pn->ctl_table_header != NULL)
>  		nf_ct_unregister_sysctl(&pn->ctl_table_header,
> @@ -391,8 +381,6 @@ void nf_ct_l4proto_unregister_sysctl(struct net *net,
>  					&pn->ctl_compat_table,
>  					NULL);
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
> -#else
> -	pn->users--;
>  #endif /* CONFIG_SYSCTL */
>  }
>  
> @@ -458,22 +446,33 @@ int nf_conntrack_l4proto_register(struct net *net,
>  				  struct nf_conntrack_l4proto *l4proto)
>  {
>  	int ret = 0;
> +
> +	struct nf_proto_net *pn = NULL;
> +
>  	if (l4proto->init_net) {
>  		ret = l4proto->init_net(net, l4proto->l3proto);
>  		if (ret < 0)
> -			return ret;
> +			goto out;
>  	}
>  
> -	ret = nf_ct_l4proto_register_sysctl(net, l4proto);
> +	pn = nf_ct_l4proto_net(net, l4proto);
> +	if (pn == NULL)
> +		goto out;
> +
> +	ret = nf_ct_l4proto_register_sysctl(net, pn, l4proto);
>  	if (ret < 0)
> -		return ret;
> +		goto out;
>  
>  	if (net == &init_net) {
>  		ret = nf_conntrack_l4proto_register_net(l4proto);
> -		if (ret < 0)
> -			nf_ct_l4proto_unregister_sysctl(net, l4proto);
> +		if (ret < 0) {
> +			nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
> +			goto out;
> +		}
>  	}
> -
> +	/* increase the nf_proto_net's refcnt */

this comment is superfluous, please remove it.

> +	pn->users++;
> +out:
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
> @@ -498,10 +497,18 @@ nf_conntrack_l4proto_unregister_net(struct nf_conntrack_l4proto *l4proto)
>  void nf_conntrack_l4proto_unregister(struct net *net,
>  				     struct nf_conntrack_l4proto *l4proto)
>  {
> +	struct nf_proto_net *pn = NULL;
>  	if (net == &init_net)
>  		nf_conntrack_l4proto_unregister_net(l4proto);
>  
> -	nf_ct_l4proto_unregister_sysctl(net, l4proto);
> +	pn = nf_ct_l4proto_net(net, l4proto);
> +	if (pn == NULL)
> +		return;
> +
> +	/* decrease the nf_proto_net's refcnt */

same thing.

> +	pn->users--;
> +	nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
> +
>  	/* Remove all contrack entries for this protocol */
>  	rtnl_lock();
>  	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
> @@ -513,11 +520,14 @@ int nf_conntrack_proto_init(struct net *net)
>  {
>  	unsigned int i;
>  	int err;
> +	struct nf_proto_net *pn = nf_ct_l4proto_net(net,
> +						    &nf_conntrack_l4proto_generic);

break lines at 80 chars per column.

>  	err = nf_conntrack_l4proto_generic.init_net(net,
>  						    nf_conntrack_l4proto_generic.l3proto);
>  	if (err < 0)
>  		return err;
>  	err = nf_ct_l4proto_register_sysctl(net,
> +					    pn,
>  					    &nf_conntrack_l4proto_generic);
>  	if (err < 0)
>  		return err;
> @@ -527,13 +537,21 @@ int nf_conntrack_proto_init(struct net *net)
>  			rcu_assign_pointer(nf_ct_l3protos[i],
>  					   &nf_conntrack_l3proto_generic);
>  	}
> +	/* increase generic proto's nf_proto_net refcnt */
> +	pn->users++;
> +
>  	return 0;
>  }
>  
>  void nf_conntrack_proto_fini(struct net *net)
>  {
>  	unsigned int i;
> +	struct nf_proto_net *pn = nf_ct_l4proto_net(net,
> +						    &nf_conntrack_l4proto_generic);
> +	/* decrease generic proto's nf_proto_net refcnt */
> +	pn->users--;
>  	nf_ct_l4proto_unregister_sysctl(net,
> +					pn,
>  					&nf_conntrack_l4proto_generic);
>  	if (net == &init_net) {
>  		/* free l3proto protocol tables */
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
