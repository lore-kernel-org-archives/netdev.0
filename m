From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] alloc_percpu() fails to allocate percpu data
Date: Mon, 3 Mar 2008 20:41:46 +1100
Message-ID: <200803032041.47778.nickpiggin@yahoo.com.au>
References: <47BDBC23.10605@cosmosbay.com> <200803031414.43076.nickpiggin@yahoo.com.au> <47CBAD4E.7080901@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <clameter@sgi.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760763AbYCCJm4@vger.kernel.org>
In-Reply-To: <47CBAD4E.7080901@cosmosbay.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 03 March 2008 18:48, Eric Dumazet wrote:
> Nick Piggin a =E9crit :
> > On Thursday 28 February 2008 06:44, Christoph Lameter wrote:
> >> On Sat, 23 Feb 2008, Nick Piggin wrote:
> >>> What I don't understand is why the slab allocators have something=
 like
> >>> this in it:
> >>>
> >>>         if ((flags & SLAB_HWCACHE_ALIGN) &&
> >>>                         size > cache_line_size() / 2)
> >>>                 return max_t(unsigned long, align, cache_line_siz=
e());
> >>>
> >>> If you ask for HWCACHE_ALIGN, then you should get it. I don't
> >>> understand, why do they think they knows better than the caller?
> >>
> >> Tradition.... Its irks me as well.
> >>
> >>> Things like this are just going to lead to very difficult to trac=
k
> >>> performance problems. Possibly correctness problems in rare cases=
=2E
> >>>
> >>> There could be another flag for "maybe align".
> >>
> >> SLAB_HWCACHE_ALIGN *is* effectively a maybe align flag given the a=
bove
> >> code.
> >>
> >> If we all agree then we could change this to have must have semant=
ics?
> >> It has the potential of enlarging objects for small caches.
> >>
> >> SLAB_HWCACHE_ALIGN has an effect that varies according to the alig=
nment
> >> requirements of the architecture that the kernel is build on. We m=
ay be
> >> in for some surprises if we change this.
> >
> > I think so. If we ask for HWCACHE_ALIGN, it must be for a good reas=
on.
> > If some structures get too bloated for no good reason, then the pro=
blem
> > is not with the slab allocator but with the caller asking for
> > HWCACHE_ALIGN.
>
> HWCACHE_ALIGN is commonly used, even for large structures, because th=
e
> processor cache line on x86 is not known at compile time (can go from=
 32
> bytes to 128 bytes).

Sure.


> The problem that above code is trying to address is about small objec=
ts.
>
> Because at the time code using HWCACHE_ALIGN was written, cache line =
size
> was 32 bytes. Now we have CPU with 128 bytes cache lines, we would wa=
ste
> space if SLAB_HWCACHE_ALIGN was honored for small objects.

I understand that, but I don't think it is a good reason.
SLAB_HWCACHE_ALIGN should only be specified if it is really needed.
If it is not really needed, it should not be specified. And if it
is, then the allocator should not disregard it.

But let's see. There is a valid case where we want to align to a
power of 2 >=3D objsize and <=3D hw cache size. That is if we carefully
pack objects so that we know where cacheline boundaries are and only
take the minimum number of cache misses to access them, but are not
concerned about false sharing. That appears to be what HWCACHE_ALIGN
is for, but SLUB does not really get that right either, because it
drops that alignment restriction completely if the object is <=3D the
cache line size. It should use the same calculation that SLAB uses.
I would have preferred it to be called something else...

=46or the case where we want to avoid false sharing, we need a new
SLAB_SMP_ALIGN, which always pads out to cacheline size, but only
for num_possible_cpus() > 1.

That still leaves the problem of how to align kmalloc(). SLAB gives
it HWCACHE_ALIGN by default. Why not do the same for SLUB (which
could be changed if CONFIG_SMALL is set)? That would give a more
consistent allocation pattern, at least (eg. you wouldn't get your
structures suddenly straddling cachelines if you reduce it from 100
bytes to 96 bytes...).

And for kmalloc that requires SMP_ALIGN, I guess it is impossible.
Maybe the percpu allocator could just have its own kmem_cache of
size cache_line_size() and use that for all allocations <=3D that size.
Then just let the scalemp guys worry about using that wasted padding
for same-CPU allocations ;)

And I guess if there is some other situation where alignment is
required, it could be specified explicitly.

> Some occurences of SLAB_HWCACHE_ALIGN are certainly not usefull, we s=
hould
> zap them. Last one I removed was the one for "struct flow_cache_entry=
"=20
> (commit dd5a1843d566911dbb077c4022c4936697495af6 : [IPSEC] flow: reor=
der
> "struct flow_cache_entry" and remove SLAB_HWCACHE_ALIGN)

Sure.

But in general it isn't always easy to tell what should be aligned
and what should not. If you have a set of smallish objects where you
are likely to do basically random lookups to them and they are not
likely to be in cache, then SLAB_HWCACHE_ALIGN can be a good idea so
that you hit as few cachelines as possible when doing the lookup.
