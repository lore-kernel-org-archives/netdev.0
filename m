From: Mateusz Guzik <mguzik@redhat.com>
Subject: Re: [PATCH] net: ipv4: current group_info should be put after using.
Date: Fri, 11 Apr 2014 10:35:34 +0200
Message-ID: <20140411083533.GA15546@mguzik.redhat.com>
References: <1397237828.12958.3.camel@wxm-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	dongxing.zhang@intel.com, pmatouse@redhat.com
To: "Wang, Xiaoming" <xiaoming.wang@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1397237828.12958.3.camel@wxm-ubuntu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 11, 2014 at 01:37:08PM -0400, Wang, Xiaoming wrote:
> There is a memory leak in ping. Current group_info had been got in 
> ping_init_sock and group_info->usage increased. 
> But the usage hasn't decreased anywhere in ping.
> This will make this group_info never freed and cause memory leak.
> 

Memory leak is only one of possible side-effects, thus I believe commit
message should be adjusted.

This is a typical refcount leak exploitable by unprivileged users, so
side effects can range from nothing through memory leaks and crashes to
possibly privilege escalation.

That said losing ' and cause memory leak' from your commit message
would be fine in my opinion.

See also a nit below.

> ---
>  net/ipv4/ping.c |   11 ++++++++---
>  1 files changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
> index f4b19e5..2af7b1f 100644
> --- a/net/ipv4/ping.c
> +++ b/net/ipv4/ping.c
> @@ -255,23 +255,28 @@ int ping_init_sock(struct sock *sk)
>  	struct group_info *group_info = get_current_groups();
>  	int i, j, count = group_info->ngroups;
>  	kgid_t low, high;
> +	int ret = 0;
>  
>  	inet_get_ping_group_range_net(net, &low, &high);
>  	if (gid_lte(low, group) && gid_lte(group, high))
> -		return 0;
> +		goto out_release_group;
>  

Since group_info is not even used here maybe it would be better to leave
return 0 as it is and call get_current_groups before the loop?

>  	for (i = 0; i < group_info->nblocks; i++) {
>  		int cp_count = min_t(int, NGROUPS_PER_BLOCK, count);
>  		for (j = 0; j < cp_count; j++) {
>  			kgid_t gid = group_info->blocks[i][j];
>  			if (gid_lte(low, gid) && gid_lte(gid, high))
> -				return 0;
> +				goto out_release_group;
>  		}
>  
>  		count -= cp_count;
>  	}
>  
> -	return -EACCES;
> +	ret = -EACCES;
> +
> +out_release_group:
> +	put_group_info(group_info);
> +	return ret;
>  }
>  EXPORT_SYMBOL_GPL(ping_init_sock);
>  

-- 
Mateusz Guzik
