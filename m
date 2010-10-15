From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 3/5] tipc: Optimizations to bearer enabling logic
Date: Fri, 15 Oct 2010 07:00:33 -0400
Message-ID: <20101015110033.GC22294@hmsreliant.think-freely.org>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
 <1286929558-2954-3-git-send-email-paul.gortmaker@windriver.com>
 <20101013145843.GD31379@hmsreliant.think-freely.org>
 <20101015011139.GB5048@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48745 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198Ab0JOLAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 07:00:39 -0400
Content-Disposition: inline
In-Reply-To: <20101015011139.GB5048@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 14, 2010 at 09:11:51PM -0400, Paul Gortmaker wrote:
> [Re: [PATCH net-next 3/5] tipc: Optimizations to bearer enabling logic] On 13/10/2010 (Wed 10:58) Neil Horman wrote:
> 
> > On Tue, Oct 12, 2010 at 08:25:56PM -0400, Paul Gortmaker wrote:
> > > From: Allan Stephens <allan.stephens@windriver.com>
> > > 
> > > Introduces "enabling" state during activation of a new TIPC bearer,
> > > which supplements the existing "disabled" and "enabled" states.
> > > This change allows the new bearer to be added without having to
> > > temporarily block the processing of incoming packets on existing
> > > bearers during the binding of the new bearer to its associated
> > > interface. It also makes it unnecessary to zero out the entire
> > > bearer structure at the start of activation.
> > > 
> 
> [...]
> 
> > > +	b_ptr->state = BEARER_ENABLING;
> > >  	strcpy(b_ptr->publ.name, name);
> > > +	b_ptr->priority = priority;
> > > +
> > > +	write_unlock_bh(&tipc_net_lock);
> > Why the 3rd state?  Doesn't seem needed. 
> 
> I'm a bit disappointed in myself for also not noticing that it
> was set but never tested for.  The following should give the
> same end result but without the obfuscation of an extra state.
> 
> This one also doesn't explicitly depend on any other changes,
> so if it is now OK, the option is there for it to be applied
> independently of the others that haven't been reworked yet.
> 
> Thanks,
> Paul.
> 
> 
> From 86d0d5c92439d0a3f5a0f165aa8bd842d377dae9 Mon Sep 17 00:00:00 2001
> From: Allan Stephens <allan.stephens@windriver.com>
> Date: Thu, 14 Oct 2010 16:09:23 -0400
> Subject: [PATCH] tipc: Optimizations to bearer enabling logic
> 
> Allow new bearers to be added without having to temporarily block
> the processing of incoming packets on existing bearers during the
> binding of the new bearer to its associated interface. Eliminates
> zeroing out of the new bearer structure at the start of activation,
> since it is already in that state.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/tipc/bearer.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
> index fd9c06c..2ff8181 100644
> --- a/net/tipc/bearer.c
> +++ b/net/tipc/bearer.c
> @@ -556,14 +556,15 @@ restart:
>  	}
>  
>  	b_ptr = &tipc_bearers[bearer_id];
> -	memset(b_ptr, 0, sizeof(struct bearer));
> -
>  	strcpy(b_ptr->publ.name, name);
> +
> +	write_unlock_bh(&tipc_net_lock);
>  	res = m_ptr->enable_bearer(&b_ptr->publ);
>  	if (res) {
>  		warn("Bearer <%s> rejected, enable failure (%d)\n", name, -res);
> -		goto failed;
> +		return res;
>  	}
> +	write_lock_bh(&tipc_net_lock);
>  
This definately looks more concise, but I don't see why its necessecary to drop
the tipc_net_lock around the call to enable_bearer.  The only caler of
tipc_register_media sets the enable_bearer pointer to the enable_bearer
function, and  I' don't see any path through that function which would
potentially retake that lock.  In fact it seems dropping it might be dangerous,
if other paths (like from cfg_named_msg_event), tried to enable a bearer in
parallel with a user space directive from the netlink socket).  With out the
protection of tipc_net_lock, you could use the same eth_bearer twice, and
corrupt that array.

Neil

>  	b_ptr->identity = bearer_id;
>  	b_ptr->media = m_ptr;
> -- 
> 1.7.2.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
