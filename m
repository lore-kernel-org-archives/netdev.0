From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RESEND nf] netfilter: avoid a race between nf_register_hook() and cleanup_net()
Date: Sat, 30 Jul 2016 08:24:37 -0500
Message-ID: <87shurb6ne.fsf@x220.int.ebiederm.org>
References: <20160729150033.E0250A0BD9@unicorn.suse.cz>
	<20160729161904.4F00BA0BD9@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160729161904.4F00BA0BD9@unicorn.suse.cz> (Michal Kubecek's
	message of "Fri, 29 Jul 2016 18:19:04 +0200 (CEST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Kubecek <mkubecek@suse.cz> writes:

> There is a race condition between nf_{,un}register_hook() and
> cleanup_net() which can either trigger WARN check or cause a memory
> leak. The scenario is like this (2a and 2b are alternatives):
>
> 1.  cleanup_net() removes one or more struct net from net_namespace_list
> 2a. nf_register_hook() adds per-netns hooks to all netns (but not those
>     removed in step 1) and adds the hook to global nf_hook_list
> 2b. nf_unregister_hook() deletes per-netns hooks from all netns (but not
>     those removed in step 1) and removes the hook from nf_hook_list
> 3.  cleanup_net() calls pernet subsystem exit functions for netns being
>     removed; one of them is netfilter_net_exit() which (among others)
>     calls nf_unregister_net_hook() to unregister per-netns hooks for all
>     hooks in nf_hook_list.
>
> In case (a), per-netns hooks are never added as the namespace was
> already invisible to for_each_net() in step 2a but an attempt to remove
> them in step 3 (the hook is already in nf_hook_list) triggers a WARN
> check in nf_unregister_net_hook() (no real harm done, however). In case
> (b), the per-netns hook is removed neither in step 2b (netns is already
> invisible to for_each_net()) nor in step 3 (the hook is already removed
> from nf_hook_list), causing a memory leak.
>
> Prevent the race by protecting the for_each_net() loop in
> nf_{,un}register_hook() (also) by net_mutex. There is already a
> precendens for this in rtnl_link_unregister() which addresses similar
> race.

So this analysis of a problem appears to be spot on.

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>


I really really want there to be a better way to do this, but it is
really not ok for a hook to continue it's life past
nf_unregister_net_hook as after that point the code may be removed
from the kernel (sigh).

Although keeping with the precedent and minimizing net_mutex
we could remove the WARN and keep nf_register_hook as it is.
But that sounds entirely too clever for a fix that will
probably be backported.

But that sounds entirely too clever for a fix that likely needs to be
backported.

Eric

> Fixes: 085db2c04557 ("netfilter: Per network namespace netfilter hooks.")
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>  net/netfilter/core.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index f39276d1c2d7..860978c9f82e 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -193,6 +193,8 @@ int nf_register_hook(struct nf_hook_ops *reg)
>  	struct net *net, *last;
>  	int ret;
>  
> +	/* prevent race with cleanup_net() */
> +	mutex_lock(&net_mutex);
>  	rtnl_lock();
>  	for_each_net(net) {
>  		ret = nf_register_net_hook(net, reg);
> @@ -201,6 +203,7 @@ int nf_register_hook(struct nf_hook_ops *reg)
>  	}
>  	list_add_tail(&reg->list, &nf_hook_list);
>  	rtnl_unlock();
> +	mutex_unlock(&net_mutex);
>  
>  	return 0;
>  rollback:
> @@ -211,6 +214,7 @@ rollback:
>  		nf_unregister_net_hook(net, reg);
>  	}
>  	rtnl_unlock();
> +	mutex_unlock(&net_mutex);
>  	return ret;
>  }
>  EXPORT_SYMBOL(nf_register_hook);
> @@ -219,11 +223,14 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
>  {
>  	struct net *net;
>  
> +	/* prevent race with cleanup_net() */
> +	mutex_lock(&net_mutex);
>  	rtnl_lock();
>  	list_del(&reg->list);
>  	for_each_net(net)
>  		nf_unregister_net_hook(net, reg);
>  	rtnl_unlock();
> +	mutex_unlock(&net_mutex);
>  }
>  EXPORT_SYMBOL(nf_unregister_hook);
