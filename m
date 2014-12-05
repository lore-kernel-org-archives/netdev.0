From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix the flow limitation computation
Date: Fri, 05 Dec 2014 06:49:18 -0800
Message-ID: <1417790958.15618.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417772919-17744-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com, Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:35049 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbaLEOtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 09:49:20 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so775957iec.24
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 06:49:20 -0800 (PST)
In-Reply-To: <1417772919-17744-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 17:48 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> Once RPS is enabled, the skb maybe enqueue to different CPU, so the
> flow limitation computation should use the enqueued CPU, not the local
> CPU
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---

CC Willem de Bruijn <willemb@google.com>, author of this mechanism, for
comments.

>  net/core/dev.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 945bbd0..e70507d 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3250,7 +3250,7 @@ static int rps_ipi_queued(struct softnet_data *sd)
>  int netdev_flow_limit_table_len __read_mostly = (1 << 12);
>  #endif
>  
> -static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen)
> +static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen, int cpu)



>  {
>  #ifdef CONFIG_NET_FLOW_LIMIT
>  	struct sd_flow_limit *fl;
> @@ -3260,7 +3260,7 @@ static bool skb_flow_limit(struct sk_buff *skb, unsigned int qlen)
>  	if (qlen < (netdev_max_backlog >> 1))
>  		return false;
>  
> -	sd = this_cpu_ptr(&softnet_data);
> +	sd = &per_cpu(softnet_data, cpu);

What about passing sd instead of cpu, so that we do not have to compute
this again ?
