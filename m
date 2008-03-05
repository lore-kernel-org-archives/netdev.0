From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 1/3] slub: fix small HWCACHE_ALIGN alignment
Date: Wed, 5 Mar 2008 01:28:21 +0100
Message-ID: <20080305002821.GD1510@wotan.suse.de>
References: <20080303093449.GA15091@wotan.suse.de> <Pine.LNX.4.64.0803031107130.6917@schroedinger.engr.sgi.com> <20080303200613.GC8974@wotan.suse.de> <Pine.LNX.4.64.0803031209570.16049@schroedinger.engr.sgi.com> <20080303201701.GF8974@wotan.suse.de> <Pine.LNX.4.64.0803031315160.4131@schroedinger.engr.sgi.com> <84144f020803031330i2c0ea1f6kc5b02c8b26145797@mail.gmail.com> <Pine.LNX.4.64.0803031331340.4375@schroedinger.engr.sgi.com> <47CC6F30.50802@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	yanmin_zhang@linux.intel.com, David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:55908 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760125AbYCEA2X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 19:28:23 -0500
Content-Disposition: inline
In-Reply-To: <47CC6F30.50802@cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 03, 2008 at 11:35:44PM +0200, Pekka Enberg wrote:
> Hi,
> 
> Christoph Lameter wrote:
> >Well the guarantee can only be exploited if you would check the cacheline 
> >sizes and the object size from the code that creates the slab cache. 
> >Basically you would have to guestimate what the slab allocator is doing.
> >
> >So the guarantee is basically meaningless. If the object is larger than a 
> >cacheline then this will never work.
> 
> Yes, I know that. That's why I am asking why this matters. If there's 
> some sort of regression because SLUB does HWCACHE_ALIGN bit differently, 
> we need to fix that.

It started out as a SLUB regression that was exposing poor code in the
percpu allocator due to different SLUB kmalloc alignments. That prompted
some further investigation about the alignment handling in the
allocators and showed up this problem with SLUB's HWCACHE_ALIGN. While
I don't know of a regression caused by it as such, it is totally
unreasonable to just change the semantics of it (seemingly for no good
reason). It is used quite a bit in networking for one, and those guys
count every single cache miss in their fastpaths.


> Not that it necessarily means we have to change 
> HWCACHE_ALIGN but I am assuming Nick has some reason why he wants to 
> introduce the SMP alignment flag.

The SMP flag was just an RFC. I think some people (like Christoph) were
being confused about the HWCACHE_ALIGN flag being for avoiding false
sharing on SMP systems. It would actually be also generally useful to
have the SMP flag (eg. see the sites I added it to in patch #3).
