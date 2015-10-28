From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 28 Oct 2015 14:44:28 -0700
Message-ID: <1446068668.7476.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028123543.GB22011@ZenIV.linux.org.uk>
	 <1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028211347.GC22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34789 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752498AbbJ1Vob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 17:44:31 -0400
In-Reply-To: <20151028211347.GC22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-28 at 21:13 +0000, Al Viro wrote:
> On Wed, Oct 28, 2015 at 07:47:57AM -0700, Eric Dumazet wrote:
> > On Wed, 2015-10-28 at 06:24 -0700, Eric Dumazet wrote:
> > 
> > > Before I take a deep look at your suggestion, are you sure plain use of
> > > include/linux/percpu-refcount.h infra is not possible for struct cred ?
> > 
> > BTW, I am not convinced we need to spend so much energy and per-cpu
> > memory for struct cred refcount.
> > 
> > The big problem is fd array spinlock of course and bitmap search for
> > POSIX compliance.
> > 
> > The cache line trashing in struct cred is a minor one ;)
> 
> percpu-refcount isn't convenient - the only such candidate for ref_kill in
> there is "all other references are gone", and that can happen in
> interesting locking environments.  I doubt that it would be a good fit, TBH...

OK then ...

> Cacheline pingpong on the descriptors bitmap is probably inevitable, but
> it's not the only problem in the existing implementation - close a small
> descriptor when you've got a lot of them and look for the second open
> after that.  _That_ can lead to thousands of cachelines being read through,
> all under the table spinlock.  It's literally orders of magnitude worse.
> And if the first open after that close happens to be for a short-living
> descriptor, you'll get the same situation back in your face as soon as you
> close it.
> 
> I think we can seriously improve that without screwing the fast path by
> adding "summary" bitmaps once the primary grows past the cacheline worth
> of bits.  With bits in the summary bitmap corresponding to cacheline-sized
> chunks of the primary, being set iff all bits in the corresponding chunk
> are set.  If the summary map grows larger than one cacheline, add the
> second-order one (that happens at quarter million descriptors and serves
> until 128 million; adding the third-order map is probably worthless).
> 
> I want to maintain the same kind of "everything below this is known to be
> in use" thing as we do now.  Allocation would start with looking into the
> same place in primary bitmap where we'd looked now and similar search
> forward for zero bit.  _However_, it would stop at cacheline boundary.
> If nothing had been found, we look in the corresponding place in the
> summary bitmap and search for zero bit there.  Again, no more than up
> to the cacheline boundary.  If something is found, we've got a chunk in
> the primary known to contain a zero bit; if not - go to the second-level
> and search there, etc.
> 
> When a zero bit in the primary had been found, check if it's within the
> rlimit (passed to __alloc_fd() explicitly) and either bugger off or set
> that bit.  If there are zero bits left in the same word - we are done,
> otherwise check the still unread words in the cacheline and see if all
> of them are ~0UL.  If all of them are, set the bit in summary bitmap, etc.
> 
> Normal case is exactly the same as now - one cacheline accessed and modified.
> We might end up touching more than that, but it's going to be rare and
> the cases when it happens are very likely to lead to much worse amount of
> memory traffic with the current code.
> 
> Freeing is done by zeroing the bit in primary, checking for other zero bits
> nearby and buggering off if there are such.  If the entire cacheline used
> to be all-bits-set, clear the bit in summary and, if there's a second-order
> summary, get the bit in there clear as well - it's probably not worth
> bothering with checking that all the cacheline in summary bitmap had been
> all-bits-set.  Again, the normal case is the same as now.
> 
> It'll need profiling and tuning, but AFAICS it's doable without making the
> things worse than they are now, and it should get rid of those O(N) fetches
> under spinlock cases.  And yes, those are triggerable and visible in
> profiles.  IMO it's worth trying to fix...
> 

Well, all this complexity goes away with a O_FD_FASTALLOC /
SOCK_FD_FASTALLOC bit in various fd allocations, which specifically
tells the kernel we do not care getting the lowest possible fd as POSIX
mandates.

With this bit set, the bitmap search can start at a random point, and we
find a lot in O(1) : one cache line miss, if you have at least one free
bit/slot per 512 bits (64 bytes cache line).

#ifndef O_FD_FASTALLOC
#define O_FD_FASTALLOC 0x40000000
#endif

#ifndef SOCK_FD_FASTALLOC
#define SOCK_FD_FASTALLOC O_FD_FASTALLOC
#endif

... // active sockets
socket(AF_INET, SOCK_STREAM | SOCK_FD_FASTALLOC, 0);
... // passive sockets
accept4(sockfd, ..., SOCK_FD_FASTALLOC);
...

Except for legacy stuff and stdin/stdout/stderr games, I really doubt
lot of applications absolutely rely on the POSIX thing...
