From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : convert IP route cache garbage colleciton from
 softirq processing to a workqueue
Date: Wed, 12 Sep 2007 12:08:45 +0200
Message-ID: <20070912120845.1b2d77dc.dada1@cosmosbay.com>
References: <20070911145613.4762c534.dada1@cosmosbay.com>
	<20070912.020525.39165997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:47428 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932648AbXILKKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 06:10:52 -0400
In-Reply-To: <20070912.020525.39165997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 12 Sep 2007 02:05:25 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 11 Sep 2007 14:56:13 +0200
> 
> > When the periodic IP route cache flush is done (every 600 seconds on 
> > default configuration), some hosts suffer a lot and eventually trigger
> > the "soft lockup" message.
> > 
> > dst_run_gc() is doing a scan of a possibly huge list of dst_entries,
> > eventually freeing some (less than 1%) of them, while holding the 
> > dst_lock spinlock for the whole scan.
> > 
> > Then it rearms a timer to redo the full thing 1/10 s later...
> > The slowdown can last one minute or so, depending on how active are
> > the tcp sessions.
> > 
> > This second version of the patch converts the processing from a softirq
> > based one to a workqueue.
> > 
> > Even if the list of entries in garbage_list is huge, host is still
> > responsive to softirqs and can make progress.
> > 
> > Instead of reseting gc timer to 0.1 second if one entry was freed in a
> > gc run, we do this if more than 10% of entries were freed.
> 
> I like this patch a lot, some minor fix is needed though:

Thank you

I also spoted a missing static before 
DECLARE_DELAYED_WORK(dst_gc_work, dst_gc_task);
 no need to stress Adrian on this :)

> 
> > +		__builtin_prefetch(&next->next, 1, 0);
> 
> Please use prefetch() instead of a direct explicit
> call to a gcc-specific routine :-)

Unfortunatly, there is no equivalent for this one. 
This gives on my Opterons a nice "prefetchnta"

prefetch(addr) is more like __builtin_prefetch(addr, 0, 3)

I would like to avoid to zap L2 cache with useless data.

__builtin_prefetch() is included from gcc 3.1 (2002), so every 
platform should support it, as linux-2.6 requires gcc 3.2 at least.

I guess you are going to tell me to first publish a patch to lkml :)

Thank you

Eric
