From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 14:34:25 +1000
Message-ID: <18115.54225.644905.463771@cargo.ozlabs.ibm.com>
References: <20070816005348.GA9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151757400.11196@schroedinger.engr.sgi.com>
	<20070816011414.GC9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com>
	<alpine.LFD.0.999.0708160730590.24380@enigma.security.iitk.ac.in>
	<20070816020851.GA30809@gondor.apana.org.au>
	<Pine.LNX.4.64.0708151917210.11736@schroedinger.engr.sgi.com>
	<18115.49946.522011.832468@cargo.ozlabs.ibm.com>
	<20070816033343.GA31844@gondor.apana.org.au>
	<18115.51472.408193.332905@cargo.ozlabs.ibm.com>
	<20070816040308.GA32133@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	Satyam Sharma <satyam@infradead.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56028 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbXHPEef (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 00:34:35 -0400
In-Reply-To: <20070816040308.GA32133@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu writes:

> > You mean it's intended that *sk->sk_prot->memory_pressure can end up
> > as 1 when sk->sk_prot->memory_allocated is small (less than
> > ->sysctl_mem[0]), or as 0 when ->memory_allocated is large (greater
> > than ->sysctl_mem[2])?  Because that's the effect of the current code.
> > If so I wonder why you bother computing it.
> 
> You need to remember that there are three different limits:
> minimum, pressure, and maximum.  By default we should never
> be in a situation where what you say can occur.
> 
> If you set all three limits to the same thing, then yes it
> won't work as intended but it's still well-behaved.

I'm not talking about setting all three limits to the same thing.

I'm talking about this situation:

CPU 0 comes into __sk_stream_mem_reclaim, reads memory_allocated, but
then before it can do the store to *memory_pressure, CPUs 1-1023 all
go through sk_stream_mem_schedule, collectively increase
memory_allocated to more than sysctl_mem[2] and set *memory_pressure.
Finally CPU 0 gets to do its store and it sets *memory_pressure back
to 0, but by this stage memory_allocated is way larger than
sysctl_mem[2].

Yes, it's unlikely, but that is the nature of race conditions - they
are unlikely, and only show up at inconvenient times, never when
someone who could fix the bug is watching. :)

Similarly it would be possible for other CPUs to decrease
memory_allocated from greater than sysctl_mem[2] to less than
sysctl_mem[0] in the interval between when we read memory_allocated
and set *memory_pressure to 1.  And it's quite possible for their
setting of *memory_pressure to 0 to happen before our setting of it to
1, so that it ends up at 1 when it should be 0.

Now, maybe it's the case that it doesn't really matter whether
*->memory_pressure is 0 or 1.  But if so, why bother computing it at
all?

People seem to think that using atomic_t means they don't need to use
a spinlock.  That's fine if there is only one variable involved, but
as soon as there's more than one, there's the possibility of a race,
whether or not you use atomic_t, and whether or not atomic_read has
"volatile" behaviour.

Paul.
