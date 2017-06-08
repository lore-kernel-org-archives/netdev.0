From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] Fix an intermittent pr_emerg warning about lo
 becoming free.
Date: Thu, 08 Jun 2017 14:06:02 -0700
Message-ID: <1496955962.736.88.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170608201238.GC2553@templeofstupid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Wei Wang <weiwan@google.com>
To: Krister Johansen <kjlx@templeofstupid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33090 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751413AbdFHVGE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 17:06:04 -0400
Received: by mail-pf0-f196.google.com with SMTP id f27so6400915pfe.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 14:06:04 -0700 (PDT)
In-Reply-To: <20170608201238.GC2553@templeofstupid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-08 at 13:12 -0700, Krister Johansen wrote:

...

> Looking at the gc_task intervals, they started at 663ms when we invoked
> __dst_free().  After that, they increased to 1663, 3136, 5567, 8191,
> 10751, and 14848.  The release that set the refcnt to 0 on our dst entry
> occurred after the gc_task was enqueued for 14 second interval so we had
> to wait longer than the warning time in wait_allrefs in order for the
> dst entry to get free'd and the hold on 'lo' to be released.
> 
> A simple solution to this problem is to have dst_dev_event() reset the
> gc timer, which causes us to process this list shortly after the
> gc_mutex is relased when dst_dev_event() completes.
> 
> Signed-off-by: Krister Johansen <kjlx@templeofstupid.com>
> ---
>  net/core/dst.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 6192f11..13ba4a0 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -469,6 +469,20 @@ static int dst_dev_event(struct notifier_block *this, unsigned long event,
>  		spin_lock_bh(&dst_garbage.lock);
>  		dst = dst_garbage.list;
>  		dst_garbage.list = NULL;
> +		/* The code in dst_ifdown places a hold on the loopback device.
> +		 * If the gc entry processing is set to expire after a lengthy
> +		 * interval, this hold can cause netdev_wait_allrefs() to hang
> +		 * out and wait for a long time -- until the the loopback
> +		 * interface is released.  If we're really unlucky, it'll emit
> +		 * pr_emerg messages to console too.  Reset the interval here,
> +		 * so dst cleanups occur in a more timely fashion.
> +		 */
> +		if (dst_garbage.timer_inc > DST_GC_INC) {
> +			dst_garbage.timer_inc = DST_GC_INC;
> +			dst_garbage.timer_expires = DST_GC_MIN;
> +			mod_delayed_work(system_wq, &dst_gc_work,
> +					 dst_garbage.timer_expires);
> +		}
>  		spin_unlock_bh(&dst_garbage.lock);
>  
>  		if (last)

Looks very nice to me !

Acked-by: Eric Dumazet <edumazet@google.com>

Wei Wan is actually working on a patch series removing all this
dst_garbage list stuff.
