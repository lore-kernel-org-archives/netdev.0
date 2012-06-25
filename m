From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 04/13] netfilter: regard users as refcount for
 l4proto's per-net data
Date: Mon, 25 Jun 2012 13:20:29 +0200
Message-ID: <20120625112029.GB4607@1984>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1340289410-17642-4-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1340289410-17642-4-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 21, 2012 at 10:36:41PM +0800, Gao feng wrote:
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
>  net/netfilter/nf_conntrack_proto.c |   76 ++++++++++++++++++++++--------------
>  1 files changed, 46 insertions(+), 30 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
> index 9d6b6ab..63612e6 100644
> --- a/net/netfilter/nf_conntrack_proto.c
> +++ b/net/netfilter/nf_conntrack_proto.c
[...]
> @@ -458,23 +446,32 @@ int nf_conntrack_l4proto_register(struct net *net,
>  				  struct nf_conntrack_l4proto *l4proto)
>  {
>  	int ret = 0;
> +	struct nf_proto_net *pn = NULL;
>  
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

Same thing here, we're leaking memory allocated by l4proto->init_net.

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

Better replace the two lines above by:

goto out_register_net;

and then...

> +		}
>  	}
>  
> +	pn->users++;

out_register_net:
        nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);

> +out:
>  	return ret;

I think that this change is similar to patch 1/1, I think you should
send it as a separated patch.

>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_register);
> @@ -499,10 +496,18 @@ nf_conntrack_l4proto_unregister_net(struct nf_conntrack_l4proto *l4proto)
>  void nf_conntrack_l4proto_unregister(struct net *net,
>  				     struct nf_conntrack_l4proto *l4proto)
>  {
> +	struct nf_proto_net *pn = NULL;
> +
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
> @@ -514,11 +519,15 @@ int nf_conntrack_proto_init(struct net *net)
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
> @@ -528,13 +537,20 @@ int nf_conntrack_proto_init(struct net *net)
>  			rcu_assign_pointer(nf_ct_l3protos[i],
>  					   &nf_conntrack_l3proto_generic);
>  	}
> +
> +	pn->users++;
>  	return 0;
>  }
>  
>  void nf_conntrack_proto_fini(struct net *net)
>  {
>  	unsigned int i;
> +	struct nf_proto_net *pn = nf_ct_l4proto_net(net,
> +					&nf_conntrack_l4proto_generic);
> +
> +	pn->users--;
>  	nf_ct_l4proto_unregister_sysctl(net,
> +					pn,
>  					&nf_conntrack_l4proto_generic);
>  	if (net == &init_net) {
>  		/* free l3proto protocol tables */
> -- 
> 1.7.7.6
> 
