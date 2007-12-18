From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [virtio-net][PATCH] Don't arm tx hrtimer with a constant 500us each transmit
Date: Tue, 18 Dec 2007 11:01:12 +1100
Message-ID: <200712181101.14916.rusty@rustcorp.com.au>
References: <475FD9E8.1060109@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kvm-devel <kvm-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org,
	virtualization <virtualization@lists.linux-foundation.org>
To: dor.laor@qumranet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56678 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753409AbXLRAB2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 19:01:28 -0500
In-Reply-To: <475FD9E8.1060109@qumranet.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 12 December 2007 23:54:00 Dor Laor wrote:
> commit 763769621d271d92204ed27552d75448587c1ac0
> Author: Dor Laor <dor.laor@qumranet.com>
> Date:   Wed Dec 12 14:52:00 2007 +0200
>
>     [virtio-net][PATCH] Don't arm tx hrtimer with a constant 50us each
> transmit
>
>     The current start_xmit sets 500us hrtimer to kick the host.
>     The problem is that if another xmit happens before the timer was
> fired then
>     the first xmit will have to wait additional 500us.
>     This patch does not re-arm the timer if there is existing one.
>     This will shorten the latency for tx.

Hi Dor!

    Yes, I pondered this when I wrote the code.  On the one hand, it's a 
low-probability pathological corner case, on the other, your patch reduces 
the number of timer reprograms in the normal case.

So I've applied it, thanks!
Rusty.





>
>     Signed-off-by: Dor Laor <dor.laor@qumranet.com>
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 7b051d5..8bb17d1
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -406,10 +405,10 @@ again:
>          virtio_debug(vdebug, "%s: before calling kick %d\n",
> __FUNCTION__, __LINE__);
>          vi->svq->vq_ops->kick(vi->svq);
>          vi->out_num = 0;
> -    } else {
> -        vi->stats.hrtimer_starts++;
> -        hrtimer_start(&vi->tx_timer, ktime_set(0,500000),
> -                  HRTIMER_MODE_REL);
> +    } else if (!hrtimer_is_queued(&vi->tx_timer)) {
> +            vi->stats.hrtimer_starts++;
> +            hrtimer_start(&vi->tx_timer, ktime_set(0,500000),
> +                      HRTIMER_MODE_REL);
>      }
>      return 0;
>  }


