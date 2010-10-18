From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next 3/5] tipc: Optimizations to bearer enabling logic
Date: Mon, 18 Oct 2010 19:59:44 -0400
Message-ID: <20101018235944.GB5703@hmsreliant.think-freely.org>
References: <1286929558-2954-1-git-send-email-paul.gortmaker@windriver.com>
 <1286929558-2954-3-git-send-email-paul.gortmaker@windriver.com>
 <20101013145843.GD31379@hmsreliant.think-freely.org>
 <20101015011139.GB5048@windriver.com>
 <20101015110033.GC22294@hmsreliant.think-freely.org>
 <4CB8C824.7090800@windriver.com>
 <20101018105017.GA16326@hmsreliant.think-freely.org>
 <20101018214356.GA27204@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	allan.stephens@windriver.com
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44110 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933468Ab0JRX7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 19:59:53 -0400
Content-Disposition: inline
In-Reply-To: <20101018214356.GA27204@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 18, 2010 at 05:43:56PM -0400, Paul Gortmaker wrote:
> [Re: [PATCH net-next 3/5] tipc: Optimizations to bearer enabling logic] On 18/10/2010 (Mon 06:50) Neil Horman wrote:
> 
> > On Fri, Oct 15, 2010 at 05:31:16PM -0400, Paul Gortmaker wrote:
> > > On 10-10-15 07:00 AM, Neil Horman wrote:
> > > 
> > > [...]
> > > 
> > > > This definately looks more concise, but I don't see why its necessecary to drop
> > > > the tipc_net_lock around the call to enable_bearer.  The only caler of
> > > > tipc_register_media sets the enable_bearer pointer to the enable_bearer
> > > > function, and  I' don't see any path through that function which would
> > > > potentially retake that lock.  In fact it seems dropping it might be dangerous,
> > > > if other paths (like from cfg_named_msg_event), tried to enable a bearer in
> > > > parallel with a user space directive from the netlink socket).  With out the
> > > > protection of tipc_net_lock, you could use the same eth_bearer twice, and
> > > > corrupt that array.
> > > 
> > > I think it would be protected by config_lock. but in the end if it is
> > > just an academic optimization that really isn't in a hot code path
> > > anyway, and if it just adds more confusion than real world value, then
> > > I'm fine with just dropping this on the floor (and deleting the extra
> > > memset in a cleanup patch) -- it won't be the 1st time doing this with
> > > these carry forward patches, and I'm sure it won't be the last.
> > > 
> > 
> > Copy that.
> 
> And here is all that is left once I drop all the above.  Not much. :)
> 
> Thanks again,
> Paul.
> 
> From 35b078621c4ca6e6f5a5aed80c34594e00f08c8e Mon Sep 17 00:00:00 2001
> From: Allan Stephens <allan.stephens@windriver.com>
> Date: Thu, 14 Oct 2010 16:09:23 -0400
> Subject: [PATCH] tipc: delete needless memset from bearer enabling.
> 
> Eliminates zeroing out of the new bearer structure at the start of
> activation, since it is already in that state.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> ---
>  net/tipc/bearer.c |    2 --
>  1 files changed, 0 insertions(+), 2 deletions(-)
> 
> diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
> index fd9c06c..9927d1d 100644
> --- a/net/tipc/bearer.c
> +++ b/net/tipc/bearer.c
> @@ -556,8 +556,6 @@ restart:
>  	}
>  
>  	b_ptr = &tipc_bearers[bearer_id];
> -	memset(b_ptr, 0, sizeof(struct bearer));
> -
>  	strcpy(b_ptr->publ.name, name);
>  	res = m_ptr->enable_bearer(&b_ptr->publ);
>  	if (res) {
> -- 
> 1.7.2.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>

