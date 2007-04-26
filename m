From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][XFRM] export SAD info
Date: Thu, 26 Apr 2007 14:18:47 -0700 (PDT)
Message-ID: <20070426.141847.10298516.davem@davemloft.net>
References: <1177516490.9923.7.camel@localhost>
	<20070426.001850.55508944.davem@davemloft.net>
	<1177593010.4077.18.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52621
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755127AbXDZVSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 17:18:40 -0400
In-Reply-To: <1177593010.4077.18.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 26 Apr 2007 09:10:10 -0400

> I would have liked to just do a read_lock_bh when retrieving the table
> metadata; however, the state table lock is defined as DEFINE_SPINLOCK
> unlike the policy table which is defined as DEFINE_RWLOCK.
> Any objection to change the state lock to be RW?

I wouldn't mind if it actually helped anything.

The SMP cache line transactions are more expensive than the
execution of the code blocks they are protecting.  rwlock's
rarely help, and when they do (the execution path is more
expensive than the SMP atomic operations) then you're holding
the lock too long :-)

> One other angle is start rejecting additions to the table after some
> point. To test, I wrote a little DOS tool that just kept adding entries
> until an OOM hit. It is a lot of fun to watch when you hit a point that
> swap is guzzling 2G or more. The add latency starts going up
> exponentially.

I would prefer a dynamic algorithm that reacts to system memory
pressure and yet-another-knob that people will get wrong and
there is no sane default for.

I plan to do away with all the GC threshold madness in the
routing cache, for example, and just let the MM layer call
back into us when there is memory pressure to trigger GC.

See set_shrinker() and friends.  The MM calls into these
handlers in response to memory pressure.  There is no
reason the networking can't hook into this and do things
properly instead of the ad-hoc manner we currently use.
