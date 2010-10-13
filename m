From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 3/5] tipc: Optimizations to bearer enabling logic
Date: Wed, 13 Oct 2010 10:58:43 -0400
Message-ID: <20101013145843.GD31379@hmsreliant.think-freely.org>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
 <1286929558-2954-3-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48116 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493Ab0JMO6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 10:58:51 -0400
Content-Disposition: inline
In-Reply-To: <1286929558-2954-3-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 12, 2010 at 08:25:56PM -0400, Paul Gortmaker wrote:
> From: Allan Stephens <allan.stephens@windriver.com>
> 
> Introduces "enabling" state during activation of a new TIPC bearer,
> which supplements the existing "disabled" and "enabled" states.
> This change allows the new bearer to be added without having to
> temporarily block the processing of incoming packets on existing
> bearers during the binding of the new bearer to its associated
> interface. It also makes it unnecessary to zero out the entire
> bearer structure at the start of activation.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/tipc/bcast.c  |    2 +-
>  net/tipc/bearer.c |   27 +++++++++++++++++----------
>  net/tipc/bearer.h |    8 ++++++--
>  net/tipc/link.c   |    2 +-
>  4 files changed, 25 insertions(+), 14 deletions(-)
> 
> diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
> index ecfaac1..ba6dcb2 100644
> --- a/net/tipc/bcast.c
> +++ b/net/tipc/bcast.c
> @@ -645,7 +645,7 @@ void tipc_bcbearer_sort(void)
>  	for (b_index = 0; b_index < MAX_BEARERS; b_index++) {
>  		struct bearer *b = &tipc_bearers[b_index];
>  
> -		if (!b->active || !b->nodes.count)
> +		if ((b->state != BEARER_ENABLED) || !b->nodes.count)
>  			continue;
>  
>  		if (!bp_temp[b->priority].primary)
> diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
> index 9969ec6..379338f 100644
> --- a/net/tipc/bearer.c
> +++ b/net/tipc/bearer.c
> @@ -290,7 +290,7 @@ struct bearer *tipc_bearer_find_interface(const char *if_name)
>  	u32 i;
>  
>  	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
> -		if (!b_ptr->active)
> +		if (b_ptr->state != BEARER_ENABLED)
>  			continue;
>  		b_if_name = strchr(b_ptr->publ.name, ':') + 1;
>  		if (!strcmp(b_if_name, if_name))
> @@ -312,7 +312,8 @@ static struct bearer *bearer_find(const char *name)
>  		return NULL;
>  
>  	for (i = 0, b_ptr = tipc_bearers; i < MAX_BEARERS; i++, b_ptr++) {
> -		if (b_ptr->active && (!strcmp(b_ptr->publ.name, name)))
> +		if ((b_ptr->state == BEARER_ENABLED) &&
> +		    (!strcmp(b_ptr->publ.name, name)))
>  			return b_ptr;
>  	}
>  	return NULL;
> @@ -337,7 +338,8 @@ struct sk_buff *tipc_bearer_get_names(void)
>  	for (i = 0, m_ptr = media_list; i < media_count; i++, m_ptr++) {
>  		for (j = 0; j < MAX_BEARERS; j++) {
>  			b_ptr = &tipc_bearers[j];
> -			if (b_ptr->active && (b_ptr->media == m_ptr)) {
> +			if ((b_ptr->state == BEARER_ENABLED) &&
> +			    (b_ptr->media == m_ptr)) {
>  				tipc_cfg_append_tlv(buf, TIPC_TLV_BEARER_NAME,
>  						    b_ptr->publ.name,
>  						    strlen(b_ptr->publ.name) + 1);
> @@ -532,7 +534,7 @@ restart:
>  	bearer_id = MAX_BEARERS;
>  	with_this_prio = 1;
>  	for (i = MAX_BEARERS; i-- != 0; ) {
> -		if (!tipc_bearers[i].active) {
> +		if (tipc_bearers[i].state != BEARER_ENABLED) {
>  			bearer_id = i;
>  			continue;
>  		}
> @@ -559,21 +561,23 @@ restart:
>  	}
>  
>  	b_ptr = &tipc_bearers[bearer_id];
> -	memset(b_ptr, 0, sizeof(struct bearer));
> -
> +	b_ptr->state = BEARER_ENABLING;
>  	strcpy(b_ptr->publ.name, name);
> +	b_ptr->priority = priority;
> +
> +	write_unlock_bh(&tipc_net_lock);
Why the 3rd state?  Doesn't seem needed. 
