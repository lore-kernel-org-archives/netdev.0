From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH] tipc: fix regression bug where node events are not being
 generated
Date: Thu, 3 Apr 2014 14:37:18 +0800
Message-ID: <533D019E.20608@windriver.com>
References: <1396506481-17362-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <paul.gortmaker@windriver.com>, <richard.alpe@ericsson.com>,
	Netdev <netdev@vger.kernel.org>
To: <erik.hugne@ericsson.com>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64897 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162301AbaDCGhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 02:37:37 -0400
In-Reply-To: <1396506481-17362-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2014 02:28 PM, erik.hugne@ericsson.com wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> Commit 5902385a2440a55f005b266c93e0bb9398e5a62b ("tipc: obsolete
> the remote management feature")

I believe the commit is not merged into "net" tree yet, so currently the
regression problem _only_ exists in "net-next" tree. Therefore, it seems
unreasonable for us to deliver the patch to "net" tree now.

Regards,
Ying

 introduces a regression where node
> topology events are not being generated because the publication
> that triggers this: {0, <z.c.n>, <z.c.n>} is no longer available.
> This will break applications that rely on node events to discover
> when nodes join/leave a cluster.
> 
> We fix this by advertising the node publication when TIPC enters
> networking mode, and withdraws it upon shutdown.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Reviewed-by: Ying Xue <ying.xue@windriver.com>
> ---
> Patch is based on net-next, as the commit that introduces the
> regression, 5902385 was only recently applied to that tree.
> Sorry for the inconvenience.
> 
>  net/tipc/net.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/tipc/net.c b/net/tipc/net.c
> index 0374a81..4c564eb 100644
> --- a/net/tipc/net.c
> +++ b/net/tipc/net.c
> @@ -182,6 +182,8 @@ void tipc_net_start(u32 addr)
>  	tipc_bclink_init();
>  	write_unlock_bh(&tipc_net_lock);
>  
> +	tipc_nametbl_publish(TIPC_CFG_SRV, tipc_own_addr, tipc_own_addr,
> +			     TIPC_ZONE_SCOPE, 0, tipc_own_addr);
>  	pr_info("Started in network mode\n");
>  	pr_info("Own node address %s, network identity %u\n",
>  		tipc_addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
> @@ -192,6 +194,7 @@ void tipc_net_stop(void)
>  	if (!tipc_own_addr)
>  		return;
>  
> +	tipc_nametbl_withdraw(TIPC_CFG_SRV, tipc_own_addr, 0, tipc_own_addr);
>  	write_lock_bh(&tipc_net_lock);
>  	tipc_bearer_stop();
>  	tipc_bclink_stop();
> 
