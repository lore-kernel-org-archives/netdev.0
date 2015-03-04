From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next v3 6/7] fib: hook IPv4 fib for hardware offload
Date: Tue, 03 Mar 2015 16:01:12 -0800
Message-ID: <54F64B48.8040707@redhat.com>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com> <1425425520-34017-7-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: sfeldma@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
	jiri@resnulli.us, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756234AbbCDABU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 19:01:20 -0500
In-Reply-To: <1425425520-34017-7-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/03/2015 03:31 PM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Call into the switchdev driver any time an IPv4 fib entry is
> added/modified/deleted from the kernel's FIB.  The switchdev driver may or
> may not install the route to the offload device.  In the case where the
> driver tries to install the route and something goes wrong (device's routing
> table is full, etc), then all of the offloaded routes will be flushed from the
> device, and route forwarding falls back to the kernel.
>
> We can refine this fail-over logic in subsequent patches.  For now, use the
> simplist model of offloading routes up to the point of failure, and then on
> failure, undo everything.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>   net/ipv4/fib_trie.c |   36 +++++++++++++++++++++++++++++++++---
>   1 file changed, 33 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
> index 32c0117..668f09b 100644
> --- a/net/ipv4/fib_trie.c
> +++ b/net/ipv4/fib_trie.c
> @@ -79,6 +79,7 @@
>   #include <net/tcp.h>
>   #include <net/sock.h>
>   #include <net/ip_fib.h>
> +#include <net/switchdev.h>
>   #include "fib_lookup.h"
>   
>   #define MAX_STAT_DEPTH 32
> @@ -1161,7 +1162,18 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>   			new_fa->fa_state = state & ~FA_S_ACCESSED;
>   			new_fa->fa_slen = fa->fa_slen;
>   
> +			err = netdev_switch_fib_ipv4_add(key, plen, fi,
> +							 new_fa->fa_tos,
> +							 cfg->fc_type,
> +							 tb->tb_id);
> +			if (err) {
> +				fib_flush_external(fi->fib_net);
> +				kmem_cache_free(fn_alias_kmem, new_fa);
> +				goto out;
> +			}
> +
>   			hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
> +
>   			alias_free_mem_rcu(fa);
>   
>   			fib_release_info(fi_drop);
> @@ -1197,12 +1209,20 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
>   	new_fa->fa_state = 0;
>   	new_fa->fa_slen = slen;
>   
> +	/* (Optionally) offload fib entry to switch hardware. */
> +	err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
> +					 cfg->fc_type, tb->tb_id);
> +	if (err) {
> +		fib_flush_external(fi->fib_net);
> +		goto out_free_new_fa;
> +	}
> +
>   	/* Insert new entry to the list. */
>   	if (!l) {
>   		l = fib_insert_node(t, key, plen);
>   		if (unlikely(!l)) {
>   			err = -ENOMEM;
> -			goto out_free_new_fa;
> +			goto out_sw_fib_del;
>   		}
>   	}
>   

Wouldn't it make more sense to insert the route in the trie first, and 
then notify the hardware of the new route?  It seems like it would be 
much easier to pull the route back out of the trie on failure rather 
than having to delete a route from the hardware on a failure to allocate 
memory to store it.

- Alex
