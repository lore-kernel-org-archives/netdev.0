From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/24] make atomic_read() behave consistently on alpha
Date: Thu, 9 Aug 2007 08:04:45 -0700
Message-ID: <20070809150445.GB8424@linux.vnet.ibm.com>
References: <20070809132442.GA13042@shell.boston.redhat.com> <20070809143255.GA8424@linux.vnet.ibm.com> <46BB2A5A.5090006@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, ak@suse.de, heiko.carstens@de.ibm.com,
	davem@davemloft.net, schwidefsky@de.ibm.com, wensong@linux-vs.org,
	horms@verge.net.au, wjiang@resilience.com, cfriesen@nortel.com,
	zlynx@acm.org, rpjday@mindspring.com, jesper.juhl@gmail.com
To: Chris Snook <csnook@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S966168AbXHIPFQ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <46BB2A5A.5090006@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 10:53:14AM -0400, Chris Snook wrote:
> Paul E. McKenney wrote:
> >Why not the same access-once semantics for atomic_set() as
> >for atomic_read()?  As this patch stands, it might introduce
> >architecture-specific compiler-induced bugs due to the fact that
> >atomic_set() used to imply volatile behavior but no longer does.
> 
> When we make the volatile cast in atomic_read(), we're casting an rvalue to 
> volatile.  This unambiguously tells the compiler that we want to re-load 
> that register from memory.  What's "volatile behavior" for an lvalue?

I was absolutely -not- suggesting volatile behavior for lvalues.

Instead, I am asking for volatile behavior from an -rvalue-.  In the
case of atomic_read(), it is the atomic_t being read from.  In the case
of atomic_set(), it is the atomic_t being written to.  As suggested in
my previous email:

#define atomic_set(v,i)		((*(volatile int *)&(v)->counter) = (i))
#define atomic64_set(v,i)	((*(volatile long *)&(v)->counter) = (i))

Again, the architectures that used to have their "counter" declared
as volatile will lose volatile semantics on atomic_set() with your
patch, which might result in bugs due to overly imaginative compiler
optimizations.  The above would prevent any such bugs from appearing.

>                                                                       A 
> write to an lvalue already implies an eventual write to memory, so this 
> would be a no-op. Maybe you'll write to the register a few times before 
> flushing it to memory, but it will happen eventually.  With an rvalue, 
> there's no guarantee that it will *ever* load from memory, which is what 
> volatile fixes.
> 
> I think what you have in mind is LOCK_PREFIX behavior, which is not the 
> purpose of atomic_set.  We use LOCK_PREFIX in the inline assembly for the 
> atomic_* operations that read, modify, and write a value, only because it 
> is necessary to perform that entire transaction atomically.

No LOCK_PREFIX, thank you!!!  I just want to make sure that the compiler
doesn't push the store down out of a loop, split the store, allow the
store to happen twice (e.g., to allow different code paths to be merged),
and all the other tricks that the C standard permits compilers to pull.

						Thanx, Paul
