From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 08:31:02 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
 <18115.35524.56393.347841@cargo.ozlabs.ibm.com>
 <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com>
 <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
 <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au>
 <18115.45316.702491.681906@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Christoph Lameter <clameter@sgi.com>,
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
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:32779 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755833AbXHPCsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 22:48:37 -0400
In-Reply-To: <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 16 Aug 2007, Satyam Sharma wrote:

> On Thu, 16 Aug 2007, Paul Mackerras wrote:
> > Herbert Xu writes:
> > 
> > > See sk_stream_mem_schedule in net/core/stream.c:
> > > 
> > >         /* Under limit. */
> > >         if (atomic_read(sk->sk_prot->memory_allocated) < sk->sk_prot->sysctl_mem[0]) {
> > >                 if (*sk->sk_prot->memory_pressure)
> > >                         *sk->sk_prot->memory_pressure = 0;
> > >                 return 1;
> > >         }
> > > 
> > >         /* Over hard limit. */
> > >         if (atomic_read(sk->sk_prot->memory_allocated) > sk->sk_prot->sysctl_mem[2]) {
> > >                 sk->sk_prot->enter_memory_pressure();
> > >                 goto suppress_allocation;
> > >         }
> > > 
> > > We don't need to reload sk->sk_prot->memory_allocated here.
> > 
> > Are you sure?  How do you know some other CPU hasn't changed the value
> > in between?
> 
> I can't speak for this particular case, but there could be similar code
> examples elsewhere, where we do the atomic ops on an atomic_t object
> inside a higher-level locking scheme that would take care of the kind of
> problem you're referring to here. It would be useful for such or similar
> code if the compiler kept the value of that atomic object in a register.

We might not be using atomic_t (and ops) if we already have a higher-level
locking scheme, actually. So as Herbert mentioned, such cases might just
not care. [ Too much of this thread, too little sleep, sorry! ]

Anyway, the problem, of course, is that this conversion to a stronger /
safer-by-default behaviour doesn't happen with zero cost to performance.
Converting atomic ops to "volatile" behaviour did add ~2K to kernel text
for archs such as i386 (possibly to important codepaths) that didn't have
those semantics already so it would be constructive to actually look at
those differences and see if there were really any heisenbugs that got
rectified. Or if there were legitimate optimizations that got wrongly
disabled. Onus lies on those proposing the modifications, I'd say ;-)
