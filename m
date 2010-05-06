From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer
Date: Thu, 6 May 2010 16:25:11 -0400
Message-ID: <20100506202511.GD5063@hmsreliant.think-freely.org>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
 <1273167155.2853.49.camel@edumazet-laptop>
 <20100506180233.GB5063@hmsreliant.think-freely.org>
 <1273170813.2222.10.camel@edumazet-laptop>
 <20100506195442.GC5063@hmsreliant.think-freely.org>
 <1273176614.2222.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53506 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756035Ab0EFUZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 16:25:16 -0400
Content-Disposition: inline
In-Reply-To: <1273176614.2222.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 06, 2010 at 10:10:14PM +0200, Eric Dumazet wrote:
> 
> > Doing that doesn't solve my aim however, which is to avoid performing rt_genid
> > updates when no one is attacking you at all.  I completely agree that we can
> > start the gen_id at some random value (by forcing an initial invalidation),
> > however.  Beyond that however, if someone is managing to guess our secret value,
> > then we need to make our secret value more complex to determine.  Perhaps given
> > the reduction in the number of times we need to iterate our gen_id with the
> > timer gone, we can use something more heavyweight to determine the the hash
> > secret (the cprng perhaps?).
> 
> Secrets that dont change are known to be honey pots for hackers.
> 
> I just dont see why we want to risk security regressions for something
> that proved to work well.
> 
Because we have two ways of doing the same thing now, and I don't see why we
should maintain code for both.  I get that a timer based invalidation works
well.  So does the statistical analysis.

> Cache invalidation is just a genid change nowadays, and dont have side
> effects.
> 
I disagree with this, changing a genid in and of itself is fast, yes, but it
creates a need for the cache to get repopulated, sending packets through the
slow routing path.  On high volume systems this causes a performance
degradation.  The timer approach makes that a periodic degradation, one that I
would like to avoid if possible.

I get that hackers like secrets to stay unchanged so that they can figure out
what they are.  Its not like we're leaving ourselves vulnerable here, we're just
rebuilding only when we need it, not every X seconds.  And if someone is
_really_ in need of a periodic rebuild, and can cope with the performance hit,
then they can still do that from user space, as I've pointed out.  We just don't
need to keep the code in the kernel any more.

> Considering we do cache invalidation when routes are changed anyway, I
> dont get why we should avoid the invalidation once every xxx seconds...
> 
Who says routes are going to change that often?  I know you dont believe that a
former is a substitute for the latter.  As for why we should avoid periodic
invalidation, I've said it several times now.

> If you believe this cache invalidation has problems, maybe we should
> address them and not hide them ?
> 
Now you're just being intentionally obtuse.  Eric, you know perfectly good and
well what my reasons are for wanting to remove the rt_secret timer.  Its why we
did the statistical analysis code in the first place.  There just not a large
need for it.  If you want to do periodic invalidation, fine, do it.  Just do it
in user space.  We have an on-demand strategy in the kernel that has been
working well for quite some time, and is superior in performance for 99% of the
use cases out there.  So lets lighten the maintenence workload for the code
thats not strictly needed anymore by getting rid of it.

