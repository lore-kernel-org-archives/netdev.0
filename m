From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 16 Jan 2009 18:25:14 +1100
Message-ID: <200901161825.15617.nickpiggin@yahoo.com.au>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com> <200901161746.25205.nickpiggin@yahoo.com.au> <20090115230043.57caae5d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfr@canb.auug.org.au, matthew@wil.cx,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, andi.kleen@intel.com,
	suresh.b.siddha@intel.com, harita.chilukuri@intel.com,
	douglas.w.styner@intel.com, peter.xihong.wang@intel.com,
	hubert.nueckel@intel.com, chris.mason@oracle.com,
	srostedt@redhat.com, linux-scsi@vger.kernel.org,
	andrew.vasquez@qlogic.com, anirban.chakraborty@qlogic.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.mail.mud.yahoo.com ([209.191.84.164]:31480 "HELO
	smtp115.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754137AbZAPHZh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 02:25:37 -0500
In-Reply-To: <20090115230043.57caae5d.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 16 January 2009 18:00:43 Andrew Morton wrote:
> On Fri, 16 Jan 2009 17:46:23 +1100 Nick Piggin <nickpiggin@yahoo.com.au> 
wrote:
> > On Friday 16 January 2009 15:12:10 Andrew Morton wrote:
> > > On Fri, 16 Jan 2009 15:03:12 +1100 Nick Piggin
> > > <nickpiggin@yahoo.com.au>
> >
> > wrote:
> > > > I would like to see SLQB merged in mainline, made default, and wait
> > > > for some number releases. Then we take what we know, and try to make
> > > > an informed decision about the best one to take. I guess that is
> > > > problematic in that the rest of the kernel is moving underneath us.
> > > > Do you have another idea?
> > >
> > > Nope.  If it doesn't work out, we can remove it again I guess.
> >
> > OK, I have these numbers to show I'm not completely off my rocker to
> > suggest we merge SLQB :) Given these results, how about I ask to merge
> > SLQB as default in linux-next, then if nothing catastrophic happens,
> > merge it upstream in the next merge window, then a couple of releases
> > after that, given some time to test and tweak SLQB, then we plan to bite
> > the bullet and emerge with just one main slab allocator (plus SLOB).
>
> That's a plan.
>
> > SLQB tends to be the winner here.
>
> Can you think of anything with which it will be the loser?

Well, that fio test showed it was behind SLAB. I just discovered that
yesterday during running these tests, so I'll take a look at that. The
Intel performance guys I think have one or two cases where it is slower.
They don't seem to be too serious, and tend to be specific to some
machines (eg. the same test with a different CPU architecture turns out
to be faster). So I'll be looking into these things, but I haven't seen
anything too serious yet. I'm mostly interested in macro benchmarks and
more real world workloads.

At a higher level, SLAB has some interesting features. It basically has
"crossbars" of queues, that basically provide queues for allocating and
freeing to and from different CPUs and nodes. This is what bloats up
the kmem_cache data structures to tens or hundreds of gigabytes each
on SGI size systems. But it is also has good properties. On smaller
multiprocessor and NUMA systems, it might be the case that SLAB does
better in workloads that involve objects being allocated on one CPU and
freed on another. I haven't actually observed problems here, but I don't
have a lot of good tests.

SLAB is also fundamentally different from SLUB and SLQB in that it uses
arrays to store pointers to objects in its queues, rather than having
a linked list using pointers embedded in the objects. This might in some
cases make it easier to prefetch objects in parallel with finding the
object itself. I haven't actually been able to attribute a particular
regression to this interesting difference, but it might turn up as an
issue.

These are two big differences between SLAB and SLQB.

The linked lists of objects were used in favour of arrays again because of
the memory overhead, and to have a better ability to tune the size of the
queues, and reduced overhead in copying around arrays of pointers (SLQB can
just copy the head of one the list to the tail of another in order to move
objects around), and eliminated the need to have additional metadata beyond
the struct page for each slab.

The crossbars of queues were removed because of the bloating and memory
overhead issues. The fact that we now have linked lists helps a little bit
with this, because moving lists of objects around gets a bit easier.

