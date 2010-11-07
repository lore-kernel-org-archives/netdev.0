From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [Security] [SECURITY] Fix leaking of kernel heap addresses via
 /proc
Date: Mon, 8 Nov 2010 00:14:21 +0100
Message-ID: <20101107231421.GC17592@basil.fritz.box>
References: <87sjzcssx5.fsf@basil.nowhere.org>
 <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, Ted Ts'o <tytso@mit.edu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Dan Rosenberg <drosenberg@vsecurity.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"remi.denis-courmont@nokia.com" <remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>
To: chas3@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35543 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709Ab0KGXOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 18:14:23 -0500
Content-Disposition: inline
In-Reply-To: <201011072248.oA7MmjKg025857@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 07, 2010 at 05:48:45PM -0500, Chas Williams (CONTRACTOR) wrote:
> In message <87sjzcssx5.fsf@basil.nowhere.org>,Andi Kleen writes:
> >Ted Ts'o <tytso@mit.edu> writes:
> >
> >> Are there any userspace programs that might be reasonably expected to
> >> _use_ this information?  If there is, we could just pick a random
> >> number at boot time, and then XOR the heap adddress with that random
> >> number.
> >
> >If any of the addresses can be guessed ever (and that is likely if it's
> >allocated at boot) determining the random value will be trivial
> >for everyone.
> 
> i suppose one could use idr to map the pointers to unique values.  the
> infiniband code uses this technique>

idr requires allocating memory, and it's unclear you can do that
in all the situations where debugging printks are used. And
how would you get the idr table out of a broken kernel? And further
the memory allocations would eventually fill up your memory
if they go on. I don't think idr is a solution.

I don't really have a good solution either. Even if the
the individual pointers were removed from printks (which
probably doesn't make much difference anyways because those
printks usually happen only in unlikely debug situations):

The information about the memory layout early on in dmesg
is probably enough to make a good educated guess about
the locations of standard slab caches on a known kernel
image. For example the first N sockets opened are very likely
easy to guess this way.

I guess one could make dmesg root only, although I personally
use it often as non root.

Or maybe add some more randomization to the buddy allocator.
The drawback of that is that they tend to make
benchmarks unstable due to cache coloring differences.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
