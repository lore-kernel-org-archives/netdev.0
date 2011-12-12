From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: vmxnet3 driver broken since 3.0?
Date: Mon, 12 Dec 2011 09:05:00 -0800
Message-ID: <20111212090500.22571f03@nehalam.linuxnetplumber.net>
References: <CAJeBh4sXMVnZcLcjiMyvpPPoG3708CeaQ3hDj_g2s72Hv09N6g@mail.gmail.com>
	<loom.20111211T232956-373@post.gmane.org>
	<CAJeBh4uCzUTFpQxf-rcXWkCUy9UEryiaz8akiDovLqU2C8WQEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Zbigniew Luszpinski <zbiggy@o2.pl>, netdev@vger.kernel.org
To: sandr8@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46841 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752736Ab1LLRFD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Dec 2011 12:05:03 -0500
In-Reply-To: <CAJeBh4uCzUTFpQxf-rcXWkCUy9UEryiaz8akiDovLqU2C8WQEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 11 Dec 2011 23:54:50 -0800
Alessandro Salvatori <sandr8@gmail.com> wrote:

> I guess this is the change that was introduced in 3.0 and that breaks vmxnet3:
> 
> commit 55513fb4281464e97aa1ff2b9c906ca5aed917c5
> Author: Tom Herbert <therbert@google.com>
> Date:   Mon Oct 18 17:55:58 2010 +0000
> 
>     net: fail alloc_netdev_mq if queue count < 1
> 
>     In alloc_netdev_mq fail if requested queue_count < 1.
> 
>     Signed-off-by: Tom Herbert <therbert@google.com>
>     Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 04972a4..f44d29a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5511,6 +5511,12 @@ struct net_device *alloc_netdev_mq(int
> sizeof_priv, const char *name,
> 
>         BUG_ON(strlen(name) >= sizeof(dev->name));
> 
> +       if (queue_count < 1) {
> +               pr_err("alloc_netdev: Unable to allocate device "
> +                      "with zero queues.\n");
> +               return NULL;
> +       }
> +
>         alloc_size = sizeof(struct net_device);
>         if (sizeof_priv) {
>                 /* ensure 32-byte alignment of private area */

Looks like the problem is not in networking core but either in the logic
that computes number of queues.

By default it computes number of queues based on number of cpus.

	num_rx_queues = min(VMXNET3_DEVICE_MAX_RX_QUEUES,
				    (int)num_online_cpus());
	
	num_rx_queues = rounddown_pow_of_two(num_rx_queues);

I suspect something is wrong in the cpu management if it reports
num_online_cpus == 0.
