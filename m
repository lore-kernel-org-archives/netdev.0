From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Thu, 16 Aug 2007 01:10:15 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708160102550.16414@enigma.security.iitk.ac.in>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
 <9350e9fab505c92af8d5e1f3441d6ad2@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, ak@suse.de, cfriesen@nortel.com,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:59816 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456AbXHOT1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 15:27:52 -0400
In-Reply-To: <9350e9fab505c92af8d5e1f3441d6ad2@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 15 Aug 2007, Segher Boessenkool wrote:

> > "Volatile behaviour" itself isn't consistently defined (at least
> > definitely not consistently implemented in various gcc versions across
> > platforms),
> 
> It should be consistent across platforms; if not, file a bug please.
> 
> > but it is /expected/ to mean something like: "ensure that
> > every such access actually goes all the way to memory, and is not
> > re-ordered w.r.t. to other accesses, as far as the compiler can take
                              ^
                              (volatile)

(or, alternatively, "other accesses to the same volatile object" ...)

> > care of these". The last "as far as compiler can take care" disclaimer
> > comes about due to CPUs doing their own re-ordering nowadays.
> 
> You can *expect* whatever you want, but this isn't in line with
> reality at all.
> 
> volatile _does not_ prevent reordering wrt other accesses.
> [...]
> What volatile does are a) never optimise away a read (or write)
> to the object, since the data can change in ways the compiler
> cannot see; and b) never move stores to the object across a
> sequence point.  This does not mean other accesses cannot be
> reordered wrt the volatile access.
> 
> If the abstract machine would do an access to a volatile-
> qualified object, the generated machine code will do that
> access too.  But, for example, it can still be optimised
> away by the compiler, if it can prove it is allowed to.

As (now) indicated above, I had meant multiple volatile accesses to
the same object, obviously.

BTW:

#define atomic_read(a)	(*(volatile int *)&(a))
#define atomic_set(a,i)	(*(volatile int *)&(a) = (i))

int a;

void func(void)
{
	int b;

	b = atomic_read(a);
	atomic_set(a, 20);
	b = atomic_read(a);
}

gives:

func:
	pushl	%ebp
	movl	a, %eax
	movl	%esp, %ebp
	movl	$20, a
	movl	a, %eax
	popl	%ebp
	ret

so the first atomic_read() wasn't optimized away.


> volatile _does not_ make accesses go all the way to memory.
> [...]
> If you want stuff to go all the way to memory, you need some
> architecture-specific flush sequence; to make a store globally
> visible before another store, you need mb(); before some following
> read, you need mb(); to prevent reordering you need a barrier.

Sure, which explains the "as far as the compiler can take care" bit.
Poor phrase / choice of words, probably.
