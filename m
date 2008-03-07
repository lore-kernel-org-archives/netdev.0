From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Fri, 7 Mar 2008 03:23:55 +0100
Message-ID: <20080307022355.GB21185@wotan.suse.de>
References: <20080303201701.GF8974@wotan.suse.de> <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com> <20080305000637.GA1510@wotan.suse.de> <20080304.161003.129716254.davem@davemloft.net> <Pine.LNX.4.64.0803051257030.30742@schroedinger.engr.sgi.com> <20080306025758.GB27150@wotan.suse.de> <Pine.LNX.4.64.0803061453360.16212@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yanmin_zhang@linux.intel.com,
	dada1@cosmosbay.com
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:51937 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757418AbYCGCX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 21:23:56 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803061453360.16212@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2008 at 02:56:42PM -0800, Christoph Lameter wrote:
> On Thu, 6 Mar 2008, Nick Piggin wrote:
> 
> > There looks like definitely some networking slabs that pass the flag
> > and can be non-power-of-2. And don't forget cachelines can be anywhere
> > up to 256 bytes in size. So yeah it definitely makes sense to merge
> > the patch and then examine the callers if you feel strongly about it.
> 
> Just do not like to add fluff that has basically no effect. I just tried 
> to improve things by not doing anything special if we cannot cacheline 
> align object. Least surprise (at least for me). It is bad enough that we 
> just decide to ignore the request for alignment for small caches.

That's just because you (apparently still) have a misconception about what
the flag is supposed to be for. It is not for aligning things to the start
of a cacheline boundary. It is not for avoiding false sharing on SMP. It
is for ensuring that a given object will span the fewest number of
cachelines. This can actually be important if you do anything like random
lookups or tree walks where the object contains the tree node.

Consider a 64 byte cacheline, and a 24 byte object:
cacheline  |-------|-------|-------
object     |--|--|--|--|--|--|--|--

So if you touch 8 random objects, it is statistically likely to cost you
10 cache misses (so long as the working set is sufficiently cold / larger
than cache that cacheline sharing is insignificant).

If you actually honour HWCACHE_ALIGN, then the same object will be 32
bytes:
cacheline  |-------|
object     |---|---|

Now 8 will cost 8. A 20% saving. Maybe almost a 20% performance improvement.

Before we go around in circles again, do you accept this? If yes, then
what is your argument that SLUB knows better than the caller; if no, then
why not?

