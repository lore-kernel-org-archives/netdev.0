From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 2/5] tipc: Simplify bearer shutdown logic
Date: Wed, 13 Oct 2010 10:39:22 -0400
Message-ID: <20101013143922.GC31379@hmsreliant.think-freely.org>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
 <1286929558-2954-2-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57705 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752858Ab0JMOjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 10:39:31 -0400
Content-Disposition: inline
In-Reply-To: <1286929558-2954-2-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 12, 2010 at 08:25:55PM -0400, Paul Gortmaker wrote:
> From: Allan Stephens <allan.stephens@windriver.com>
> 
> Disable all active bearers when TIPC is shut down without having to do
> a name-based search to locate each bearer object.
> 
It seems like you're doing a good deal more in this patch than just disabling
all active bearers without doing a name search.  The description is implemented
in the for loop of tipc_bearer_stop.  Whats the rest of it for?

> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/tipc/bearer.c |   61 ++++++++++++++++++++--------------------------------
>  1 files changed, 24 insertions(+), 37 deletions(-)
> 
> diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
> index 9c10c6b..9969ec6 100644
> --- a/net/tipc/bearer.c
> +++ b/net/tipc/bearer.c
> @@ -280,39 +280,39 @@ static int bearer_name_validate(const char *name,
>  }
>  
>  /**
> - * bearer_find - locates bearer object with matching bearer name
> + * tipc_bearer_find_interface - locates bearer object with matching interface name
>   */
>  
> -static struct bearer *bearer_find(const char *name)
> +struct bearer *tipc_bearer_find_interface(const char *if_name)
>  {
>  	struct bearer *b_ptr;
> +	char *b_if_name;
>  	u32 i;
>  
> -	if (tipc_mode != TIPC_NET_MODE)
> -		return NULL;
> -
>  	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
> -		if (b_ptr->active && (!strcmp(b_ptr->publ.name, name)))
> +		if (!b_ptr->active)
> +			continue;
> +		b_if_name = strchr(b_ptr->publ.name, ':') + 1;
> +		if (!strcmp(b_if_name, if_name))
>  			return b_ptr;
>  	}
>  	return NULL;
>  }
>  
>  /**
> - * tipc_bearer_find_interface - locates bearer object with matching interface name
> + * bearer_find - locates bearer object with matching bearer name
>   */
>  
> -struct bearer *tipc_bearer_find_interface(const char *if_name)
> +static struct bearer *bearer_find(const char *name)
>  {
>  	struct bearer *b_ptr;
> -	char *b_if_name;
>  	u32 i;
>  
> +	if (tipc_mode != TIPC_NET_MODE)
> +		return NULL;
> +
I get why you're removing the tipc_mode check above, but why are you adding it
here?  commit d0021b252eaf65ca07ed14f0d66425dd9ccab9a6 modified tipc_bearers so
that calling this function should be tipc_mode safe (i.e. looking for a bearer
prior to entering TIPC_NET_MODE will return a NULL result).  Did you find a
subsequent problem?

>  	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
> -		if (!b_ptr->active)
> -			continue;
> -		b_if_name = strchr(b_ptr->publ.name, ':') + 1;
> -		if (!strcmp(b_if_name, if_name))
> +		if (b_ptr->active && (!strcmp(b_ptr->publ.name, name)))
>  			return b_ptr;
>  	}
>  	return NULL;
> @@ -630,30 +630,17 @@ int tipc_block_bearer(const char *name)
>   * Note: This routine assumes caller holds tipc_net_lock.
>   */
>  
> -static int bearer_disable(const char *name)
> +static int bearer_disable(struct bearer *b_ptr)
>  {
> -	struct bearer *b_ptr;
>  	struct link *l_ptr;
>  	struct link *temp_l_ptr;
>  
> -	b_ptr = bearer_find(name);
> -	if (!b_ptr) {
> -		warn("Attempt to disable unknown bearer <%s>\n", name);
> -		return -EINVAL;
> -	}
> -
> -	info("Disabling bearer <%s>\n", name);
> +	info("Disabling bearer <%s>\n", b_ptr->publ.name);
>  	tipc_disc_stop_link_req(b_ptr->link_req);
>  	spin_lock_bh(&b_ptr->publ.lock);
>  	b_ptr->link_req = NULL;
>  	b_ptr->publ.blocked = 1;
> -	if (b_ptr->media->disable_bearer) {
> -		spin_unlock_bh(&b_ptr->publ.lock);
> -		write_unlock_bh(&tipc_net_lock);
> -		b_ptr->media->disable_bearer(&b_ptr->publ);
> -		write_lock_bh(&tipc_net_lock);
> -		spin_lock_bh(&b_ptr->publ.lock);
> -	}
> +	b_ptr->media->disable_bearer(&b_ptr->publ);
>  	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
>  		tipc_link_delete(l_ptr);
>  	}
> @@ -664,10 +651,16 @@ static int bearer_disable(const char *name)
>  
>  int tipc_disable_bearer(const char *name)
>  {
> +	struct bearer *b_ptr;
>  	int res;
>  
>  	write_lock_bh(&tipc_net_lock);
> -	res = bearer_disable(name);
> +	b_ptr = bearer_find(name);
> +	if (b_ptr == NULL) {
> +		warn("Attempt to disable unknown bearer <%s>\n", name);
> +		res = -EINVAL;
> +	} else
> +		res = bearer_disable(b_ptr);
>  	write_unlock_bh(&tipc_net_lock);
>  	return res;
>  }
> @@ -680,13 +673,7 @@ void tipc_bearer_stop(void)
>  
>  	for (i = 0; i < MAX_BEARERS; i++) {
>  		if (tipc_bearers[i].active)
> -			tipc_bearers[i].publ.blocked = 1;
> -	}
> -	for (i = 0; i < MAX_BEARERS; i++) {
> -		if (tipc_bearers[i].active)
> -			bearer_disable(tipc_bearers[i].publ.name);
> +			bearer_disable(&tipc_bearers[i]);
>  	}
>  	media_count = 0;
>  }
> -
> -
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
