From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next: NULL pointer dereference on adding a net namespace
 and a system freeze
Date: Tue, 11 Mar 2014 05:40:26 -0700
Message-ID: <1394541626.21721.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310014452.144b0491@north>
	 <1394424146.3607.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394424557.3607.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140310131909.33a3042c@north>
	 <1394460276.3607.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140311014649.1716bde1@north> <20140311120059.GB32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jakub =?UTF-8?Q?Kici=C5=84ski?= <moorray3@wp.pl>,
	netdev@vger.kernel.org, Fan Du <fan.du@windriver.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:62763 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381AbaCKMk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 08:40:28 -0400
Received: by mail-pb0-f50.google.com with SMTP id md12so8732790pbc.37
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 05:40:27 -0700 (PDT)
In-Reply-To: <20140311120059.GB32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-11 at 13:00 +0100, Steffen Klassert wrote:

> I was unable to reproduce this here, but it looks like the flowcache
> namespace changes are still not complete. We leak an active timer
> and all the allocated resources when we exit a namespace.
> 
> Could you please try the patch below?
> 
> Also, please send your config if the patch does not fix your problem.
> 
> Thanks!
> 
> ---
>  include/net/flow.h     |    1 +
>  net/core/flow.c        |   18 ++++++++++++++++++
>  net/xfrm/xfrm_policy.c |    7 ++++++-
>  3 files changed, 25 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/flow.h b/include/net/flow.h
> index bee3741..64fd248 100644
> --- a/include/net/flow.h
> +++ b/include/net/flow.h
> @@ -219,6 +219,7 @@ struct flow_cache_object *flow_cache_lookup(struct net *net,
>  					    u8 dir, flow_resolve_t resolver,
>  					    void *ctx);
>  int flow_cache_init(struct net *net);
> +void flow_cache_fini(struct net *net);
>  
>  void flow_cache_flush(struct net *net);
>  void flow_cache_flush_deferred(struct net *net);
> diff --git a/net/core/flow.c b/net/core/flow.c
> index 102f8ea..d31c3c4 100644
> --- a/net/core/flow.c
> +++ b/net/core/flow.c
> @@ -484,3 +484,21 @@ err:
>  	return -ENOMEM;
>  }
>  EXPORT_SYMBOL(flow_cache_init);
> +
> +void flow_cache_fini(struct net *net)
> +{
> +	int i;
> +	struct flow_cache *fc = &net->xfrm.flow_cache_global;
> +
> +	del_timer(&fc->rnd_timer);


del_timer_sync() I guess is better.

> +
> +	for_each_possible_cpu(i) {
> +		struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, i);
> +		kfree(fcp->hash_table);
> +		fcp->hash_table = NULL;
> +	}
> +
> +	free_percpu(fc->percpu);
> +	fc->percpu = NULL;
> +}
> +EXPORT_SYMBOL(flow_cache_fini);
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index a75fae4..f02f511 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -2913,15 +2913,19 @@ static int __net_init xfrm_net_init(struct net *net)
>  	rv = xfrm_sysctl_init(net);
>  	if (rv < 0)
>  		goto out_sysctl;
> +	rv = flow_cache_init(net);
> +	if (rv < 0)
> +		goto out;
>  
>  	/* Initialize the per-net locks here */
>  	spin_lock_init(&net->xfrm.xfrm_state_lock);
>  	rwlock_init(&net->xfrm.xfrm_policy_lock);
>  	mutex_init(&net->xfrm.xfrm_cfg_mutex);
>  
> -	flow_cache_init(net);
>  	return 0;
>  
> +out:
> +	xfrm_sysctl_fini(net);
>  out_sysctl:
>  	xfrm_policy_fini(net);
>  out_policy:
> @@ -2934,6 +2938,7 @@ out_statistics:
>  
>  static void __net_exit xfrm_net_exit(struct net *net)
>  {
> +	flow_cache_fini(net);
>  	xfrm_sysctl_fini(net);
>  	xfrm_policy_fini(net);
>  	xfrm_state_fini(net);
