From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Fri, 25 Jun 2010 11:45:57 +0200
Message-ID: <1277459157.32034.127.camel@twins>
References: <20100624182123.45264dfe.akpm@linux-foundation.org>
	 <20100624.203006.35035648.davem@davemloft.net>
	 <20100624205059.a28756b0.akpm@linux-foundation.org>
	 <20100624.212713.242141362.davem@davemloft.net>
	 <20100624214204.a85c8ba2.akpm@linux-foundation.org>
	 <1277453336.22715.2154.camel@twins>
	 <20100625014253.698d9ff5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, herbert@gondor.hengli.com.au,
	mst@redhat.com, frzhang@redhat.com, netdev@vger.kernel.org,
	amwang@redhat.com, shemminger@vyatta.com, mpm@selenic.com,
	paulmck@linux.vnet.ibm.com, mingo@elte.hu
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:53538 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab0FYJrN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 05:47:13 -0400
In-Reply-To: <20100625014253.698d9ff5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-06-25 at 01:42 -0700, Andrew Morton wrote:
> On Fri, 25 Jun 2010 10:08:56 +0200 Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Thu, 2010-06-24 at 21:42 -0700, Andrew Morton wrote:
> > > That being said, I wonder why Herbert didn't hit this in his testing. 
> > > I suspect that he'd enabled lockdep, which hid the bug.  I haven't
> > > worked out _why_ lockdep hides the double-mutex_unlock bug, but it's a
> > > pretty bad thing to do. 
> > 
> > Most weird indeed, lockdep is supposed so shout its lungs out when
> > someone wants to unlock a lock that isn't actually owned by him (and it
> > not being locked at all certainly implies you're not the owner).
> > 
> > In fact, the below patch results in the below splat -- its also
> > something that's tested by the locking self-test:
> 
> When I enabled lockdep, the bug actually went away.  Is it possible
> that when lockdep detects this bug, it prevents mutex.count from going
> from 1 to 2?

Not lockdep itself but the DEBUG_MUTEXES code (forced by lockdep).

The difference between the normal and the debug code is that the debug
code disables all fast-path code.

The x86 fast-path code does:

 LOCK incl &lock->count
 jg done:
 call slowpath
done:

Since 1++ is >0 it will complete without calling the slow-path, would
do:

 if (__mutex_slowpath_needs_to_unlock()) /* 1 regardless of DEBUG_MUTEX */
   atomic_set(&lock->count, 1);

The question I guess is, do we want double unlocks to go silently
unnoticed? In that case we need to touch the fastpath asm.

> It could be that lockdep _did_ detect (and correct!) the bug.  But
> because I had no usable console output at the time, I didn't see it.
> 
> I did notice that the taint output was "G W".  So something warned
> about something, but I don't know what.  But that was happening with
> lockdep disabled.

Hrmm,. yeah without console output lockdep isn't going to help much,
should we maybe use the speaker to read out the dmesg :-)

> It'd be interesting to add
> 
> 	printk("%d:%d\n", __LINE__, atomic_read(&foo.count));
> 
> after the mutex_unlock()s.

1352:1


