From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 0/3] Faster than SLAB caching of SKBs with qmempool
 (backed by alf_queue)
Date: Wed, 10 Dec 2014 13:51:32 -0600 (CST)
Message-ID: <alpine.DEB.2.11.1412101339480.22982@gentwo.org>
References: <20141210033902.2114.68658.stgit@ahduyck-vm-fedora20> <20141210141332.31779.56391.stgit@dragon>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
    linux-api@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
    "David S. Miller" <davem@davemloft.net>,
    Hannes Frederic Sowa <hannes@stressinduktion.org>,
    Alexander Duyck <alexander.duyck@gmail.com>,
    Alexei Starovoitov <ast@plumgrid.com>,
    "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
    Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
    Steven Rostedt <rostedt@goodmis.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20141210141332.31779.56391.stgit@dragon>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Dec 2014, Jesper Dangaard Brouer wrote:

> One of the building blocks for achieving this speedup is a cmpxchg
> based Lock-Free queue that supports bulking, named alf_queue for
> Array-based Lock-Free queue.  By bulking elements (pointers) from the
> queue, the cost of the cmpxchg (approx 8 ns) is amortized over several
> elements.

This is a bit of an issue since the design of the SLUB allocator is such
that you should pick up an object, apply some processing and then take the
next one. The fetching of an object warms up the first cacheline and this
is tied into the way free objects are linked in SLUB.

So a bulk fetch from SLUB will not that effective and cause the touching
of many cachelines if we are dealing with just a few objects. If we are
looking at whole slab pages with all objects then SLUB can be effective
since we do not have to build up the linked pointer structure in each
page. SLAB has a different architecture there and a bulk fetch there is
possible without touching objects even for small sets since the freelist
management is separate from the objects.

If you do this bulking then you will later access cache cold objects?
Doesnt that negate the benefit that you gain? Or are these objects written
to by hardware and therefore by necessity cache cold?

We could provide a faster bulk alloc/free function.

	int kmem_cache_alloc_array(struct kmem_cache *s, gfp_t flags,
		size_t objects, void **array)

and this could be optimized by each slab allocator to provide fast
population of objects in that array. We then assume that the number of
objects is in the hundreds or so right?

The corresponding free function

	void kmem_cache_free_array(struct kmem_cache *s,
		size_t objects, void **array)


I think the queue management of the array can be improved by using a
similar technique as used the SLUB allocator using the cmpxchg_local.
cmpxchg_local is much faster than a full cmpxchg and we are operating on
per cpu structures anyways. So the overhead could still be reduced.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
