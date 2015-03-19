From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: rps: fix data stall after hotplug
Date: Thu, 19 Mar 2015 14:50:39 -0700
Message-ID: <1426801839.25985.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36200 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbCSVui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 17:50:38 -0400
Received: by igbud6 with SMTP id ud6so37601064igb.1
        for <netdev@vger.kernel.org>; Thu, 19 Mar 2015 14:50:37 -0700 (PDT)
In-Reply-To: <b3ecb218932daa656a796cfa6e9e62b9.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-19 at 19:54 +0000, subashab@codeaurora.org wrote:
> When RPS is enabled, IPI is triggered to enqueue the
> backlog NAPI to the poll list. If the CPU is hotplugged
> after the NAPI_STATE_SCHED bit is set on
> enqueue_to_backlog but before the IPI is delivered
> successfully, the poll list does not have the backlog
> NAPI queued. As a consequence of this, dev_cpu_callback
> does not clear the NAPI_STATE_SCHED bit on hotplug.
> Since NAPI_STATE_SCHED is set even after the cpu comes
> back up, packets get enqueued onto the input packet queue
> but are never processed since the IPI will not be triggered.
> 
> This patch handles this race by unconditionally resetting
> the NAPI state for the backlog NAPI on the offline CPU.
> 
> Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> ---
>  net/core/dev.c | 5 ++---
>  1 file changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 6f561de..61d9579 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -7119,12 +7119,11 @@ static int dev_cpu_callback(struct notifier_block
> *nfb,
>  							    poll_list);
> 
>  		list_del_init(&napi->poll_list);
> -		if (napi->poll == process_backlog)
> -			napi->state = 0;
> -		else
> +		if (napi->poll != process_backlog)
>  			____napi_schedule(sd, napi);
>  	}
> 
> +	oldsd->backlog.state = 0;
>  	raise_softirq_irqoff(NET_TX_SOFTIRQ);
>  	local_irq_enable();

Are you seeing this race on x86 ?

If IPI are not reliable on your arch, I am guessing you should fix them.

Otherwise, even without hotplug you'll have hangs.
