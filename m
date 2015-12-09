From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net : To avoid execution of extra instructions in NET
 RX path when rps_map is not set but rps_needed is true.
Date: Wed, 09 Dec 2015 05:09:51 -0800
Message-ID: <1449666591.6639.23.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1449657321-3797-1-git-send-email-rahul.jain@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, ast@plumgrid.com,
	jiri@mellanox.com, daniel@iogearbox.net,
	makita.toshiaki@lab.ntt.co.jp, noureddine@arista.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, k.ashutosh@samsung.com
To: Rahul Jain <rahul.jain@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449657321-3797-1-git-send-email-rahul.jain@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-12-09 at 16:05 +0530, Rahul Jain wrote:
> From: Ashutosh Kaushik <k.ashutosh@samsung.com>
> 
> The patch fixes the issues with check of global flag "rps_needed" 

Hi Rahul

I have no issue here. What is the issue exactly ?

You provide no perf numbers, so it is hard to guess what 'problem' you
intend to fix.

> The patch adds a check to these two RX functions which will check RPS availability locally for device specific.
>  
> Signed-off-by: Ashutosh Kaushik <k.ashutosh@samsung.com>
> ---
>  net/core/dev.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5df6cbc..1aa4402 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3531,12 +3531,14 @@ drop:
>  static int netif_rx_internal(struct sk_buff *skb)
>  {
>  	int ret;
> +	struct netdev_rx_queue *dev_rxqueue = skb->dev->_rx;
>  
>  	net_timestamp_check(netdev_tstamp_prequeue, skb);
>  

But dev_rxqueue points at this point to first RX queue on the device.

This code breaks on multiqueue device.

It also adds unnecessary overhead on configs where CONFIG_RPS is
disabled.

>  	trace_netif_rx(skb);
>  #ifdef CONFIG_RPS
> -	if (static_key_false(&rps_needed)) {
> +	if (static_key_false(&rps_needed) &&
> +	    dev_rxqueue->rps_map && dev_rxqueue->rps_map->len) {
>  		struct rps_dev_flow voidflow, *rflow = &voidflow;
>  		int cpu;


Well, you violate basic RCU requirements here. Your patch adds a
critical bug.
If we accept such patch, it will be very easy to crash the kernel. 

Hint : rps_map can be set to NULL at anytime from another CPU.

Adding code duplicating what is done later is adding kernel bloat.
It might give you some performance improvement (how much ?), but will
add few cycles per packets to others.

Its like inlining a function : It might give you some gains, but also
increase icache occupancy and might hurt others.

If really you can demonstrate more than 2-3 % performance improvement, I
would advise you to send a patch against net/Kconfig allowing to make
CONFIG_RPS independent on SMP so that you can decide to build your
kernels without RPS.

But we need a real good analysis : Maybe the issue is caused by some
false sharing and reordering fields in a structure would help.
