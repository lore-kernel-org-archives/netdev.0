From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 01/13] tipc: eliminate case of writing to freed
 memory
Date: Thu, 26 Jun 2014 06:56:57 -0400
Message-ID: <20140626105656.GA16025@hmsreliant.think-freely.org>
References: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
 <1403746902-20408-2-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36048 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661AbaFZK5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 06:57:10 -0400
Content-Disposition: inline
In-Reply-To: <1403746902-20408-2-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 08:41:30PM -0500, Jon Maloy wrote:
> In the function tipc_nodesub_notify() we call a function pointer
> aggregated into the object to be notified, whereafter we set
> the function pointer to NULL. However, in some cases the function
> pointed to will free the struct containing the function pointer,
> resulting in a write to already freed memory.
> 
> This bug seems to always have been there, without causing any
> notable harm.
> 
> In this commit we fix the problem by inverting the order of the
> zeroing and the function call.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> ---
>  net/tipc/node_subscr.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/net/tipc/node_subscr.c b/net/tipc/node_subscr.c
> index 7c59ab1..2d13eea 100644
> --- a/net/tipc/node_subscr.c
> +++ b/net/tipc/node_subscr.c
> @@ -84,11 +84,13 @@ void tipc_nodesub_unsubscribe(struct tipc_node_subscr *node_sub)
>  void tipc_nodesub_notify(struct list_head *nsub_list)
>  {
>  	struct tipc_node_subscr *ns, *safe;
> +	net_ev_handler handle_node_down;
>  
>  	list_for_each_entry_safe(ns, safe, nsub_list, nodesub_list) {
> -		if (ns->handle_node_down) {
> -			ns->handle_node_down(ns->usr_handle);
> +		handle_node_down = ns->handle_node_down;
> +		if (handle_node_down) {
>  			ns->handle_node_down = NULL;
> +			handle_node_down(ns->usr_handle);
>  		}
>  	}
>  }

If its true that some functions pointed to by handle_node_down free the struct
pointing to the function pointer, than this change isn't sufficient.  The only
caller to tipc_nodesub_notify is node_lost_contact, which dereferences the same
structure right after the call to tipc_nodesub_notify.

Neil

> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
