From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : convert IP route cache garbage colleciton from
 softirq processing to a workqueue
Date: Wed, 12 Sep 2007 12:18:30 +0200
Message-ID: <20070912121830.4d2e3940.dada1@cosmosbay.com>
References: <20070911145613.4762c534.dada1@cosmosbay.com>
	<20070912100054.GA3649@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:47510 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933119AbXILKSb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 06:18:31 -0400
In-Reply-To: <20070912100054.GA3649@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007 11:00:54 +0100
Christoph Hellwig <hch@infradead.org> wrote:

> This looks nice in general, getting things out of softirq context is
> always good.

I am preparing a patch to net/ipv4/route.c to migrate rt_check_expire()
as well.

> 
> On Tue, Sep 11, 2007 at 02:56:13PM +0200, Eric Dumazet wrote:
> >  #if RT_CACHE_DEBUG >= 2
> >  static atomic_t			 dst_total = ATOMIC_INIT(0);
> >  #endif
> > -static unsigned long dst_gc_timer_expires;
> > -static unsigned long dst_gc_timer_inc = DST_GC_MAX;
> > -static void dst_run_gc(unsigned long);
> > +static struct {
> > +	spinlock_t		lock;
> > +	struct dst_entry 	*list;
> > +	unsigned long		timer_inc;
> > +	unsigned long		timer_expires;
> > +} dst_garbage = {
> > +	.lock = __SPIN_LOCK_UNLOCKED(dst_garbage.lock),
> > +	.timer_inc = DST_GC_MAX,
> > +};
> 
> Can you please et rid of this useless struct?  It just complicates
> the code and means we can't use the proper DEFINE_SPINLOCK initializer.

When using the standard DEFINE_SPINLOCK initializer, the lock is in the 
data section, while list is in bss section.

This 'useless struct' makes lock/list being on the same cache line, so 
reduces latency of __dst_free(). I wish more structures in kernel be used
instead of relying on random placement of the linker...

> 
> > +DECLARE_DELAYED_WORK(dst_gc_work, dst_gc_task);
> 
> This should be static.

Yes I agree

