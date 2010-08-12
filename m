From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH net-next-2.6] bridge: 64bit rx/tx counters
Date: Thu, 12 Aug 2010 15:11:45 -0700
Message-ID: <20100812151145.f5fa259b.akpm@linux-foundation.org>
References: <1276531162.2478.121.camel@edumazet-laptop>
	<20100614.231412.39191304.davem@davemloft.net>
	<1276596856.2541.84.camel@edumazet-laptop>
	<1276598376.2541.93.camel@edumazet-laptop>
	<20100809214740.c5d186d2.akpm@linux-foundation.org>
	<1281615375.2494.20.camel@edumazet-laptop>
	<20100812080731.c9456ef9.akpm@linux-foundation.org>
	<1281649657.2305.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	Nick Piggin <npiggin@suse.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55091 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753342Ab0HLWLz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 18:11:55 -0400
In-Reply-To: <1281649657.2305.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Aug 2010 23:47:37 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 12 ao__t 2010 __ 08:07 -0700, Andrew Morton a __crit : 
> > On Thu, 12 Aug 2010 14:16:15 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > 
> > > > And all this open-coded per-cpu counter stuff added all over the place.
> > > > Were percpu_counters tested or reviewed and found inadequate and unfixable?
> > > > If so, please do tell.
> > > > 
> > > 
> > > percpu_counters tries hard to maintain a view of the current value of
> > > the (global) counter. This adds a cost because of a shared cache line
> > > and locking. (__percpu_counter_sum() is not very scalable on big hosts,
> > > it locks the percpu_counter lock for a possibly long iteration)
> > 
> > Could be.  Is percpu_counter_read_positive() unsuitable?
> > 
> 
> I bet most people want precise counters when doing 'ifconfig lo'
> 
> SNMP applications would be very surprised to get non increasing values
> between two samples, or inexact values.

percpu_counter_read_positive() should be returning monotonically
increasing numbers - if it ever went backward that would be bad.  But
yes, the value will increase in a lumpy fashion.  Probably one would
need to make informed choices between percpu_counter_read_positive()
and percpu_counter_sum(), depending on the type of stat.

But that's all a bit academic.

>
> > > And this folding has zero effect on
> > > concurrent writers (counter updates)
> > 
> > The fastpath looks a little expensive in the code you've added.  The
> > write_seqlock() does an rmw and a wmb() and the stats inc is a 64-bit
> > rmw whereas percpu_counters do a simple 32-bit add.  So I'd expect that
> > at some suitable batch value, percpu-counters are faster on 32-bit. 
> > 
> 
> Hmm... 6 instructions (16 bytes of text) are a "little expensive" versus
> 120 instructions if we use percpu_counter ?
> 
> Following code from drivers/net/loopback.c
> 
> 	u64_stats_update_begin(&lb_stats->syncp);
> 	lb_stats->bytes += len;
> 	lb_stats->packets++;
> 	u64_stats_update_end(&lb_stats->syncp);
> 
> maps on i386 to :
> 
> 	ff 46 10             	incl   0x10(%esi)  // u64_stats_update_begin(&lb_stats->syncp);
> 	89 f8                	mov    %edi,%eax
> 	99                   	cltd   
> 	01 7e 08             	add    %edi,0x8(%esi)
> 	11 56 0c             	adc    %edx,0xc(%esi)
> 	83 06 01             	addl   $0x1,(%esi)
> 	83 56 04 00          	adcl   $0x0,0x4(%esi)
> 	ff 46 10             	incl   0x10(%esi) // u64_stats_update_end(&lb_stats->syncp);
> 
> 
> Exactly 6 added instructions compared to previous kernel (32bit
> counters), only on 32bit hosts. These instructions are not expensive (no
> conditional branches, no extra register pressure) and access private cpu
> data.
> 
> While two calls to __percpu_counter_add() add about 120 instructions,
> even on 64bit hosts, wasting precious cpu cycles.

Oy.  You omitted the per_cpu_ptr() evaluation and, I bet, included all
the executed-1/batch-times instructions.

> 
> > They'll usually be slower on 64-bit, until that num_possible_cpus walk
> > bites you.
> > 
> 
> But are you aware we already fold SNMP values using for_each_possible()
> macros, before adding 64bit counters ? Not related to 64bit stuff
> really...


> > percpu_counters might need some work to make them irq-friendly.  That
> > bare spin_lock().
> > 
> > btw, I worry a bit about seqlocks in the presence of interrupts:
> > 
> 
> Please note that nothing is assumed about interrupts and seqcounts
> 
> Both readers and writers must mask them if necessary.
> 
> In most situations, masking softirq is enough for networking cases
> (updates are performed from softirq handler, reads from process context)

Yup, write_seqcount_begin/end() are pretty dangerous-looking.  The
caller needs to protect the lock against other CPUs, against interrupts
and even against preemption.


