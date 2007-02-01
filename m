From: Simon Lodal <simonl@parknet.dk>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: Thu, 1 Feb 2007 08:08:20 +0100
Message-ID: <200702010808.20416.simonl@parknet.dk>
References: <200702010618.48692.simonl@parknet.dk> <45C183EF.2040701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from duen.parknet.dk ([217.116.235.14]:36103 "EHLO duen.parknet.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161177AbXBAHIV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Feb 2007 02:08:21 -0500
In-Reply-To: <45C183EF.2040701@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 01 February 2007 07:08, Patrick McHardy wrote:
> Simon Lodal wrote:
> > This patch changes HTB's class storage from hash+lists to a two-level
> > linear array, so it can do constant time (O(1)) class lookup by classid.
> > It improves scalability for large number of classes.
> >
> > Without the patch, ~14k htb classes can starve a Xeon-3.2 at only 15kpps,
> > using most of it's cycles traversing lists in htb_find(). The patch
> > eliminates this problem, and has a measurable impact even with a few
> > hundred classes.
> >
> > Previously, scalability could be improved by increasing HTB_HSIZE, modify
> > the hash function, and recompile, but this patch works for everyone
> > without recompile and scales better too.
>
> I agree that the current fixed sized hashes (additionally quite
> small by default) are a big problem with many classes, for all of
> HTB/HFSC/CBQ. But I think your approach is a bit wasteful, with
> unfortunately chosen classids 128 classes are enough to reach the
> maximum memory usage of ~512kb (with 4k pages and 8 byte pointers).

I think it is a non-issue since it does not happen in practice.

Generally there are two ways to assign classids:

1) Manually, used when you have few classes. People usually use 100, 101, 102, 
200, 201 etc (probably unaware that they are hex). With 4k pages and 32bit 
pointers, everything below classid 400 is within the first page, which covers 
most "few classes" examples you can find lying around.

2) Script generated, in practice this is required if you have many classes. 
The classid's will then usually be forthrunning, at least in large chunks, 
which means minimal memory waste, and an optimal case for plain linear 
lookup; hashing them can only be wasteful.


> I have a patch for HFSC which introduces dynamic resizing of the
> class hash. I have planned to generalize it (similar to tcf_hashinfo)
> and convert HTB and CBQ as well, which as a nice side effect will
> allow to get rid of some duplicated code, like hash walking.

I have not been looking into HFSC and CBQ, was not aware that they have 
similar issues.


> If you give me a few days I'll try to finish and post it.

Memory is generally not an issue, but CPU is, and you can not beat the CPU 
efficiency of plain array lookup (always faster, and constant time).

If anything, I would find it more relevant to use array lookup with dynamic 
adjustment of the array size (HTB_CLS_ARRAY_SIZE in my patch); start out 
small to waste less memory, increase up to PAGE_SIZE as needed.

But then, it is probably too much effort for the gain (a few kb's in machines 
that should have plenty of RAM anyway), and requires more code => more 
complexity, bugs, maintenance.


Regards
Simon
