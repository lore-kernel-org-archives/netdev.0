From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] net: cgroup: null ptr dereference in netprio cgroup
 during init
Date: Wed, 18 Jul 2012 08:45:39 -0400
Message-ID: <20120718124539.GC25563@hmsreliant.think-freely.org>
References: <20120718003316.2979.49278.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gaofeng@cn.fujitsu.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50344 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753526Ab2GRMp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 08:45:58 -0400
Content-Disposition: inline
In-Reply-To: <20120718003316.2979.49278.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 17, 2012 at 05:33:16PM -0700, John Fastabend wrote:
> When the netprio cgroup is built in the kernel cgroup_init will call
> cgrp_create which eventually calls update_netdev_tables. This is
> being called before do_initcalls() so a null ptr dereference occurs
> on init_net.
> 
> This patch adds a check on init_net.count to verify the structure
> has been initialized. The failure was introduced here,
> 
> commit ef209f15980360f6945873df3cd710c5f62f2a3e
> Author: Gao feng <gaofeng@cn.fujitsu.com>
> Date:   Wed Jul 11 21:50:15 2012 +0000
> 
>     net: cgroup: fix access the unallocated memory in netprio cgroup
> 
> Tested with ping with netprio_cgroup as a module and built in.
> 
> Marked RFC for now I think DaveM might have a reason why this needs
> some improvement.
> 
> Reported-by: Mark Rustad <mark.d.rustad@intel.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 
>  net/core/netprio_cgroup.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
> index b2e9caa..e9fd7fd 100644
> --- a/net/core/netprio_cgroup.c
> +++ b/net/core/netprio_cgroup.c
> @@ -116,6 +116,9 @@ static int update_netdev_tables(void)
>  	u32 max_len;
>  	struct netprio_map *map;
>  
> +	if (!atomic_read(&init_net.count))
> +		return ret;
> +
>  	rtnl_lock();
>  	max_len = atomic_read(&max_prioidx) + 1;
>  	for_each_netdev(&init_net, dev) {
> 
> 

John, do you have a stack trace of this.  I'm having a hard time seeing how we
get into this path prior to the network stack being initalized.

It also brings up another point.  If this is happening, and we're creating the
root cgroup from start_kernel, Then we're actually initalizing some cgroups
twice, because a few cgroups register themselves via cgroup_load_subsys in
module_init specified routines.  So if you're building netprio_cgroup or
net_cls_cgroup as part of the monolithic kernel, you'll get cgroup_create called
prior to your module_init() call.  Thats not good.

In fact, the cgroup_subsys struct has an early_init flag that cgroup_init
appears to use to skip the initialization of subsystems that don't need to be
initialized that early in boot (assuming thats the path we're going down to get
to this oops).  

If you can post the call stack, I'd appreciate it, I'd like to dig a bit deeper
into this.
Neil
