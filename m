From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] arp_queue: serializing unlink + kfree_skb
Date: Thu, 3 Feb 2005 16:34:58 -0800
Message-ID: <20050203163458.6282c3fe.davem@davemloft.net>
References: <20050131102920.GC4170@suse.de>
	<E1CvZo6-0001Bz-00@gondolin.me.apana.org.au>
	<20050202162023.075015d4.davem@davemloft.net>
	<20050203111224.GA3267@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: okir@suse.de, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, anton@samba.org,
        anton@au.ibm.com
In-Reply-To: <20050203111224.GA3267@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Feb 2005 22:12:24 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This paradigm is repeated throughout the kernel.  I bet the
> same race can be found in a lot of those places.  So we really
> need to sit down and audit them one by one or else come up with
> a magical solution apart from disabling SMP :) 

Ok.  I'm commenting now considering Anton's atomic_t rules.
Anton, please read down below, I think there is a hole in the
PPC memory barriers used for atomic ops on SMP.

I don't see what changes are needed anywhere given those
rules.  Olaf says the problem shows up on PPC SMP system,
and since Anton knows the proper rules we hopefully can
safely assume he implemented them correctly on PPC :-)

I thought for a moment that the atomic_read() might be
an issue, and I'd really hate to kill that optimization.
But I can't see how it is.  Let us restate Olaf's original
guess as to the problematic sequence of events:

	cpu 0			cpu 1
	skb_get(skb)
	unlock(neigh)
				lock(neigh)
				__skb_unlink(skb)
				kfree_skb(sb)
	kfree_skb(skb)

First, __skb_unlink(skb) does an unlocked queue unlink, and
these memory operations may have their visibility freely reordered
by the processor.

However, cpu 1 will see the refcount at 2, so it will execute:

	atomic_dec_and_test(&skb->users)

which has the implicit memory barriers, as Anton stated.  This
means that the cpu will make the __skb_unlink(skb) results visible
globally before the decrement.

Now the kfree_skb() on cpu 0 executes, the atomic_read() sees it
at 1, we do the __kfree_skb() and since the __skb_unlink() has been
made visible before the decrement on the count to "1" the BUG()
should not trigger in __kfree_skb().

This all assumes, again, that PPC implements these things properly.

Let's take a look (Anton, start reading here).  My understanding of PPC
memory barriers, wrt. the physical memory coherency domain, is as follows:

	sync	! All previous read/write execute before all subsequent read/write
	lwsync	! All previous reads execute before all subsequent read/write
	eieio	! All previous writes execute before all subsequent read/write
	isync	! All previous memory operations and instructions execute and
		! reach global visibility before any subsequent instructions execute

What guarentees does isync really make about "read" reordering around
the atomic increment?  Any descrepencies here would account for the
case Olaf observed.

All the atomic ops returning values on PPC do this on SMP:

	eieio
	atomic_op()
	isync

At a minimum, it seems that the eieio is not strong enough a
memory barrier.  It is defined to order previous writes against
future memory operations, but we also need to strictly order
previous reads as well don't we?

Also, if my understanding of isync is not correct, that could
have implications as well.

I guess for performance reasons, ppc doesn't use "sync" both
before and after the atomic ops requiring ordering.  But I
suspect that might be what is actually needed for proper conformity
to the atomic_t memory ordering rules.

Anton?
