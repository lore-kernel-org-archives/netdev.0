From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] drop_monitor: allow more events per second
Date: Thu, 19 Apr 2012 13:28:44 -0400
Message-ID: <20120419172844.GC18339@neilslaptop.think-freely.org>
References: <1334855781.2395.203.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55316 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345Ab2DSR3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 13:29:00 -0400
Content-Disposition: inline
In-Reply-To: <1334855781.2395.203.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 19, 2012 at 07:16:21PM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> It seems there is a logic error in trace_drop_common(), since we store
> only 64 drops, even if they are from same location.
> 
> This fix is a one liner, but we probably need more work to avoid useless
> atomic dec/inc
> 
> Now I can watch 1 Mpps drops through dropwatch...
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> ---
> Neil, it seems this code is not SMP/preempt safe. Worker can free our
> data under us, and genlmsg_new() can return NULL under stress.
> 
>  net/core/drop_monitor.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> index 7f36b38..5c3c81a 100644
> --- a/net/core/drop_monitor.c
> +++ b/net/core/drop_monitor.c
> @@ -150,6 +150,7 @@ static void trace_drop_common(struct sk_buff *skb, void *location)
>  	for (i = 0; i < msg->entries; i++) {
>  		if (!memcmp(&location, msg->points[i].pc, sizeof(void *))) {
>  			msg->points[i].count++;
> +			atomic_inc(&data->dm_hit_count);
>  			goto out;
>  		}
>  	}
> 
> 
> 

I spent a good deal of time going through it to make sure it was preempt safe,
but its certainly possible that I missed something.  I'll look at it shortly.
Thanks for this update though

Acked-by: Neil Horman <nhorman@tuxdriver.com>
