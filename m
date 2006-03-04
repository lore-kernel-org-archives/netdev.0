From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 8/8] [I/OAT] TCP recv offload to I/OAT
Date: Sat, 4 Mar 2006 16:39:44 +0000
Message-ID: <20060304163943.GA2724@ucw.cz>
References: <20060303214036.11908.10499.stgit@gitlost.site> <20060303214236.11908.98881.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752259AbWCEMAW@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
Content-Disposition: inline
In-Reply-To: <20060303214236.11908.98881.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -262,6 +262,9 @@
>  #include <net/tcp.h>
>  #include <net/xfrm.h>
>  #include <net/ip.h>
> +#ifdef CONFIG_NET_DMA
> +#include <net/netdma.h>
> +#endif
>  

Remove the ifdefs, move them inside .h if needed.

> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 7625eaf..9b6290d 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -71,6 +71,9 @@
>  #include <net/inet_common.h>
>  #include <linux/ipsec.h>
>  #include <asm/unaligned.h>
> +#ifdef CONFIG_NET_DMA
> +#include <net/netdma.h>
> +#endif

Here, too.

> +#ifdef CONFIG_NET_DMA
> +			if (copied_early)
> +				__skb_queue_tail(&sk->sk_async_wait_queue, skb);
> +			else
> +#endif
>  			if (eaten)
>  				__kfree_skb(skb);
>  			else

Could you #define copied_early to 0 and avoid ifdefs?

> @@ -1091,8 +1094,18 @@ process:
>  	bh_lock_sock(sk);
>  	ret = 0;
>  	if (!sock_owned_by_user(sk)) {
> -		if (!tcp_prequeue(sk, skb))
> +#ifdef CONFIG_NET_DMA
> +		struct tcp_sock *tp = tcp_sk(sk);
> +		if (!tp->ucopy.dma_chan && tp->ucopy.locked_list)
> +			tp->ucopy.dma_chan = get_softnet_dma();
> +		if (tp->ucopy.dma_chan)
> +			ret = tcp_v4_do_rcv(sk, skb);
> +		else
> +#endif
> +		{
> +			if (!tcp_prequeue(sk, skb))
>  			ret = tcp_v4_do_rcv(sk, skb);
> +		}
>  	} else

Wrong indentation...
								Pavel
-- 
Thanks, Sharp!
