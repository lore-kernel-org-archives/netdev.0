From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NET : convert IP route cache garbage colleciton from softirq processing to a workqueue
Date: Wed, 12 Sep 2007 11:00:54 +0100
Message-ID: <20070912100054.GA3649@infradead.org>
References: <20070911145613.4762c534.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46680 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932597AbXILKBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:01:47 -0400
Content-Disposition: inline
In-Reply-To: <20070911145613.4762c534.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This looks nice in general, getting things out of softirq context is
always good.

On Tue, Sep 11, 2007 at 02:56:13PM +0200, Eric Dumazet wrote:
>  #if RT_CACHE_DEBUG >= 2
>  static atomic_t			 dst_total = ATOMIC_INIT(0);
>  #endif
> -static unsigned long dst_gc_timer_expires;
> -static unsigned long dst_gc_timer_inc = DST_GC_MAX;
> -static void dst_run_gc(unsigned long);
> +static struct {
> +	spinlock_t		lock;
> +	struct dst_entry 	*list;
> +	unsigned long		timer_inc;
> +	unsigned long		timer_expires;
> +} dst_garbage = {
> +	.lock = __SPIN_LOCK_UNLOCKED(dst_garbage.lock),
> +	.timer_inc = DST_GC_MAX,
> +};

Can you please et rid of this useless struct?  It just complicates
the code and means we can't use the proper DEFINE_SPINLOCK initializer.

> +DECLARE_DELAYED_WORK(dst_gc_work, dst_gc_task);

This should be static.

