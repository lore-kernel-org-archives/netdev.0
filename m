From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH next RFC] net: sched: mirred: move xmit to tasklet
Date: Tue, 18 Apr 2017 09:18:09 -0700
Message-ID: <1492532289.10587.128.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170418130331.14268-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34620 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751783AbdDRQSL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 12:18:11 -0400
Received: by mail-pf0-f193.google.com with SMTP id g23so16682716pfj.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 09:18:10 -0700 (PDT)
In-Reply-To: <20170418130331.14268-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-18 at 15:03 +0200, Florian Westphal wrote:
> mirred is prone to deadlocks as it invokes dev_queue_xmit while
> holding one or more qdisc locks.
> 
> Avoid lock recursions by moving tx context to a tasklet.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  This a stab at removing the lock recursions discussed during netconf.
> 
>  Taking the cost of the tasklet appears to be the only solution;
>  i tried to use a percpu 'history' instead but its not clear to
>  me that this avoids all corner cases.
> 
>  While this patch doesn't avoid loops we don't hang the kernel
>  anymore and removing the 'looping' filter makes things calm
>  down again (there are also other ways to create such loops anyway,
>  including use of a cable... )
> 
> diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
> index 1b5549ababd4..3dd61eba4741 100644
> --- a/net/sched/act_mirred.c
> +++ b/net/sched/act_mirred.c
> @@ -17,6 +17,7 @@
>  #include <linux/string.h>
>  #include <linux/errno.h>
>  #include <linux/skbuff.h>
> +#include <linux/skb_array.h>
>  #include <linux/rtnetlink.h>
>  #include <linux/module.h>
>  #include <linux/init.h>
> @@ -25,10 +26,19 @@
>  #include <net/net_namespace.h>
>  #include <net/netlink.h>
>  #include <net/pkt_sched.h>
> +#include <net/dst.h>
>  #include <linux/tc_act/tc_mirred.h>
>  #include <net/tc_act/tc_mirred.h>
>  
> +#define MIRRED_TXLEN	  512

Using an skb array looks overkill to me, especially if using per cpu
queue. A standard skb list should be good enough ?


> +static void mirred_cleanup_pcpu(void)
> +{
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		struct mirred_tx_data *data;
> +
> +		data = per_cpu_ptr(&mirred_tx_data, cpu);
> +
> +		skb_array_cleanup(&data->skb_array);

This wont do the dev_put() on skb->dev

> +		tasklet_kill(&data->mirred_tasklet);

You might need to kill the tasklet _before_ doing the cleanup ?

> +	}
> +}
> +
