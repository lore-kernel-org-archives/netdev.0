From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 04/12] netfilter: regard users as refcount
 for l4proto's per-net data
Date: Sat, 16 Jun 2012 12:54:48 +0200
Message-ID: <20120616105448.GB18251@1984>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1339818083-31356-4-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1339818083-31356-4-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 16, 2012 at 11:41:15AM +0800, Gao feng wrote:
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
>  net/netfilter/nf_conntrack_proto.c |   71 +++++++++++++++++++++++-------------
>  1 files changed, 46 insertions(+), 25 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
> index 1033ee6..86dbf9d 100644
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

We're not decrementing users anymore. Use unsigned int users instead.
Pass 0 for the layer 3 case to emulate the users refcnt.

>  		return;
>  
>  	unregister_net_sysctl_table(*header);
> @@ -191,8 +188,8 @@ static int nf_ct_l3proto_register_sysctl(struct net *net,
>  		err = nf_ct_register_sysctl(net,
>  					    &in->ctl_table_header,
>  					    l3proto->ctl_table_path,
> -					    in->ctl_table,
> -					    NULL);
> +					    in->ctl_table);
> +
>  		if (err < 0) {
>  			kfree(in->ctl_table);
>  			in->ctl_table = NULL;
> @@ -338,20 +335,17 @@ EXPORT_SYMBOL_GPL(nf_ct_kfree_compat_sysctl_table);
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
> @@ -365,8 +359,7 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
>  		err = nf_ct_register_sysctl(net,
>  					    &pn->ctl_compat_header,
>  					    "net/ipv4/netfilter",
> -					    pn->ctl_compat_table,
> -					    NULL);
> +					    pn->ctl_compat_table);
>  		if (err == 0)
>  			goto out;
>  
> @@ -383,11 +376,9 @@ out:
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
> @@ -400,8 +391,6 @@ void nf_ct_l4proto_unregister_sysctl(struct net *net,
>  					&pn->ctl_compat_table,
>  					NULL);
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
> -#else
> -	pn->users--;
>  #endif /* CONFIG_SYSCTL */
>  }
>  
> @@ -467,22 +456,33 @@ int nf_conntrack_l4proto_register(struct net *net,
>  				  struct nf_conntrack_l4proto *l4proto)
>  {
>  	int ret = 0;
> +

why this extra line above?

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
>  
> +	pn->users++;
> +out:
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
> @@ -507,10 +507,17 @@ nf_conntrack_l4proto_unregister_net(struct nf_conntrack_l4proto *l4proto)
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
> +	pn->users--;
> +	nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
> +
>  	/* Remove all contrack entries for this protocol */
>  	rtnl_lock();
>  	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
> @@ -522,11 +529,15 @@ int nf_conntrack_proto_init(struct net *net)
>  {
>  	unsigned int i;
>  	int err;
> +	struct nf_proto_net *pn = nf_ct_l4proto_net(net,
> +					&nf_conntrack_l4proto_generic);
> +
>  	err = nf_conntrack_l4proto_generic.init_net(net,
>  					nf_conntrack_l4proto_generic.l3proto);
>  	if (err < 0)
>  		return err;
>  	err = nf_ct_l4proto_register_sysctl(net,
> +					    pn,
>  					    &nf_conntrack_l4proto_generic);
>  	if (err < 0)
>  		return err;
> @@ -536,13 +547,23 @@ int nf_conntrack_proto_init(struct net *net)
>  			rcu_assign_pointer(nf_ct_l3protos[i],
>  					   &nf_conntrack_l3proto_generic);
>  	}
> +
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
> +					&nf_conntrack_l4proto_generic);
> +
> +	/* decrease generic proto's nf_proto_net refcnt */

I asked you to remove this comment, it's superfluous.

> +	pn->users--;
>  	nf_ct_l4proto_unregister_sysctl(net,
> +					pn,
>  					&nf_conntrack_l4proto_generic);
>  	if (net == &init_net) {
>  		/* free l3proto protocol tables */
> -- 
> 1.7.7.6
> 
