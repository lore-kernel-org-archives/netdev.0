From: Andi Kleen <andi@firstfloor.org>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Fri, 16 Apr 2010 15:37:07 +0200
Message-ID: <20100416133707.GZ18855@one.firstfloor.org>
References: <1271271222.4567.51.camel@bigi> <20100415.014857.168270765.davem@davemloft.net> <1271332528.4567.150.camel@bigi> <4BC741AE.3000108@hp.com> <1271362581.23780.12.camel@bigi> <n2p412e6f7f1004151656q5f3f2cbeh324a859b88688398@mail.gmail.com> <1271395106.16881.3645.camel@edumazet-laptop> <o2v412e6f7f1004152302j1aca5edam9d53d01781ddbe9d@mail.gmail.com> <20100416071522.GY18855@one.firstfloor.org> <1271424455.4606.39.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Changli Gao <xiaosuo@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:43060 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195Ab0DPNhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 09:37:12 -0400
Content-Disposition: inline
In-Reply-To: <1271424455.4606.39.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 09:27:35AM -0400, jamal wrote:
> On Fri, 2010-04-16 at 09:15 +0200, Andi Kleen wrote:
> 
> > > resched IPI, apparently. But it is async absolutely. and its IRQ
> > > handler is lighter.
> > 
> > It shouldn't be a lot lighter than the new fancy "queued smp_call_function"
> > that's in the tree for a few releases. So it would surprise me if it made
> > much difference. In the old days when there was only a single lock for
> > s_c_f() perhaps...
> 
> So you are saying that the old implementation of IPI (likely what i
> tried pre-napi and as recent as 2-3 years ago) was bad because of a
> single lock?

Yes.

The old implementation of smp_call_function. Also in the really old
days there was no smp_call_function_single() so you tended to broadcast.

Jens did a lot of work on this for his block device work IPI implementation.

> On IPIs:
> Is anyone familiar with what is going on with Nehalem? Why is it this
> good? I expect things will get a lot nastier with other hardware like
> xeon based or even Nehalem with rps going across QPI.

Nehalem is just fast. I don't know why it's fast in your specific
case. It might be simply because it has lots of bandwidth everywhere.
Atomic operations are also faster than on previous Intel CPUs.


> Here's why i think IPIs are bad, please correct me if i am wrong:
> - they are synchronous. i.e an IPI issuer has to wait for an ACK (which
> is in the form of an IPI).

In the hardware there's no ack, but in the Linux implementation there
is usually (because need to know when to free the stack state used
to pass information)

However there's also now support for queued IPI
with a special API (I believe Tom is using that)

> - data cache has to be synced to main memory
> - the instruction pipeline is flushed

At least on Nehalem data transfer can be often through the cache.

IPIs involve APIC accesses which are not very fast (so overall
it's far more than a pipeline worth of work), but it's still
not a incredible expensive operation.

There's also X2APIC now which should be slightly faster, but it's 
likely not in your Nehalem (this is only in the highend Xeon versions)

> Do you know any specs i could read up which will tell me a little more?

If you're just interested in IPI and cache line transfer performance it's
probably best to just measure it.

Some general information is always in the Intel optimization guide.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
