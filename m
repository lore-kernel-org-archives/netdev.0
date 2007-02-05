From: Simon Lodal <simonl@parknet.dk>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: Mon, 5 Feb 2007 19:21:19 +0100
Message-ID: <200702051921.20146.simonl@parknet.dk>
References: <200702010618.48692.simonl@parknet.dk> <200702010808.20416.simonl@parknet.dk> <p73r6tanmhk.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from duen.parknet.dk ([217.116.235.14]:37069 "EHLO duen.parknet.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932918AbXBESWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 13:22:13 -0500
In-Reply-To: <p73r6tanmhk.fsf@bingen.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 01 February 2007 12:30, Andi Kleen wrote:
> Simon Lodal <simonl@parknet.dk> writes:
> > Memory is generally not an issue, but CPU is, and you can not beat the
> > CPU efficiency of plain array lookup (always faster, and constant time).
>
> Actually that's not true when the array doesn't fit in cache.
>
> The cost of going out to memory over caches is so large (factor 100 and
> more) that often algorithms with smaller cache footprint can easily beat
> algorithms that execute much less instructions if it has less cache misses.
> That is because not all instructions have the same cost; anything
> in core is very fast but going out to memory is very slow.
>
> That said I think I agree with your analysis that a two level
> array is probably the right data structure for this and likely
> not less cache efficient than the hash table.

Good point.

The 2-level lookup generates 3 memory accesses (including getting at the 
htb_class struct). List traversal will generate many more memory accesses, 
unless the lists have 3 or fewer entries (currently that only holds true for 
up to 48 classes, uniformly distributed).

It is difficult to judge if the tables will be in cache or not. The tables are 
clearly extra baggage for the cachelines, compared to only having the 
htb_class structs (they are going to be fetched anyway).

On the other hand, if you have 10k classes, they are usually (real world) 
allocated for individual users, of which at most half are active at any time. 
With hashing, all 10k classes are fetched into cachelines all the time, only 
in order to traverse lists. That is >150k wasted cache (5000 x 32 bytes); 
plenty for 10k pointers in lookup tables.


Regards
Simon
