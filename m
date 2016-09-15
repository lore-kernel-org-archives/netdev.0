From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 2/2] openvswitch: use percpu flow stats
Date: Thu, 15 Sep 2016 16:09:26 -0700
Message-ID: <1473980966.22679.58.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473977513-7617-1-git-send-email-cascardo@redhat.com>
         <1473977513-7617-2-git-send-email-cascardo@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@ovn.org,
        David Miller <davem@davemloft.net>
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35275 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752244AbcIOXJ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 19:09:28 -0400
Received: by mail-pa0-f66.google.com with SMTP id pp5so2669026pac.2
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 16:09:28 -0700 (PDT)
In-Reply-To: <1473977513-7617-2-git-send-email-cascardo@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-15 at 19:11 -0300, Thadeu Lima de Souza Cascardo wrote:
> Instead of using flow stats per NUMA node, use it per CPU. When using
> megaflows, the stats lock can be a bottleneck in scalability.
> 
> On a E5-2690 12-core system, usual throughput went from ~4Mpps to
> ~15Mpps when forwarding between two 40GbE ports with a single flow
> configured on the datapath.
> 
> This has been tested on a system with possible CPUs 0-7,16-23. After
> module removal, there were no corruption on the slab cache.
> 
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
> Cc: pravin shelar <pshelar@ovn.org>
> ---

> +	/* We open code this to make sure cpu 0 is always considered */
> +	for (cpu = 0; cpu < nr_cpu_ids; cpu = cpumask_next(cpu, cpu_possible_mask))
> +		if (flow->stats[cpu])
>  			kmem_cache_free(flow_stats_cache,
> -					(struct flow_stats __force *)flow->stats[node]);
> +					(struct flow_stats __force *)flow->stats[cpu]);
>  	kmem_cache_free(flow_cache, flow);
>  }
>  
> @@ -757,7 +749,7 @@ int ovs_flow_init(void)
>  	BUILD_BUG_ON(sizeof(struct sw_flow_key) % sizeof(long));
>  
>  	flow_cache = kmem_cache_create("sw_flow", sizeof(struct sw_flow)
> -				       + (nr_node_ids
> +				       + (nr_cpu_ids
>  					  * sizeof(struct flow_stats *)),
>  				       0, 0, NULL);
>  	if (flow_cache == NULL)

Well, if you switch to percpu stats, better use normal
alloc_percpu(struct flow_stats)

The code was dealing with per node allocation so could not use existing
helper.

No need to keep this forever.
