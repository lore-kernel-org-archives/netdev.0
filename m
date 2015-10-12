From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [4.1.3-rt8] [report][cpuhotplug] BUG: spinlock bad magic on
 CPU#0, sh/137
Date: Mon, 12 Oct 2015 10:16:17 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1510120952560.6097@nanos>
References: <5617CE6D.9060800@ti.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-rt-users@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5617CE6D.9060800@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 9 Oct 2015, Grygorii Strashko wrote:
> I can constantly see below error report with 4.1 RT-kernel on TI ARM dra7-evm 
> if I'm trying to unplug cpu1:
> 
> [   57.737589] CPU1: shutdown
> [   57.767537] BUG: spinlock bad magic on CPU#0, sh/137
> [   57.767546]  lock: 0xee994730, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0

> It looks like this backtrace was introduces by 
> 
> commit 91df05da13a6c6c358e71182e80f19f3c48d1615
> net: Use skbufhead with raw lock
>
> I see the potential fix for this issue as below: 
> 
> index 4969c0d..f8c23de 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -7217,7 +7217,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
>                 netif_rx_ni(skb);
>                 input_queue_head_incr(oldsd);
>         }
> -       while ((skb = skb_dequeue(&oldsd->input_pkt_queue))) {
> +       while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {

Your patch is white space damaged ....

>                 netif_rx_ni(skb);
>                 input_queue_head_incr(oldsd);
>         }
> 
> input_pkt_queue is per-cpu queue and at this moment cpu is dead already,
> so no one should touch it. But I'm not sure if my assumption is correct.

It is. Picking it up for the next release

Thanks,

	tglx
