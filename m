From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH stable 3.4 1/2] ipv4: move route garbage collector to
 work queue
Date: Tue, 12 Aug 2014 23:41:32 +0200
Message-ID: <1407879692.16087.5.camel@localhost>
References: <fc0168a71c064457c18f2563371176380d0012c7.1407796232.git.mleitner@redhat.com>
	 <1407869404.27163.5.camel@localhost>
	 <1407875003.6804.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Marcelo Ricardo Leitner <mleitner@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753036AbaHLVlh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 17:41:37 -0400
In-Reply-To: <1407875003.6804.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Di, 2014-08-12 at 13:23 -0700, Eric Dumazet wrote:
> On Tue, 2014-08-12 at 20:50 +0200, Hannes Frederic Sowa wrote:
> > On Mo, 2014-08-11 at 19:41 -0300, Marcelo Ricardo Leitner wrote:
> > > Currently the route garbage collector gets called by dst_alloc() if it
> > > have more entries than the threshold. But it's an expensive call, that
> > > don't really need to be done by then.
> > > 
> > > Another issue with current way is that it allows running the garbage
> > > collector with the same start parameters on multiple CPUs at once, which
> > > is not optimal. A system may even soft lockup if the cache is big enough
> > > as the garbage collectors will be fighting over the hash lock entries.
> > > 
> > > This patch thus moves the garbage collector to run asynchronously on a
> > > work queue, much similar to how rt_expire_check runs.
> > > 
> > > There is one condition left that allows multiple executions, which is
> > > handled by the next patch.
> > > 
> > > Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
> > > Cc: Hannes Frederic Sowa <hannes@redhat.com>
> > 
> > Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> 
> 
> This does not look as stable material.

We hesitated at first, too, to send those out.

We had a machine being brought down by production traffic while using
TPROXY. The routing cache, while still having a relatively good hit
ratio, was filled with combinations of source and destination addresses.
Multiple GCs running and trying to grab the same per-chain spin_lock
caused a complete lockdown of the machine. That's why we submitted those
patches for review in the end.

> One can always disable route cache in 3.4 kernels

Sure, but we didn't like the fact that it is possible to bring down the
machine in the first place.

Thanks,
Hannes
