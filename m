From: Mathieu Desnoyers <mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 02/16] user_ns: use new hashtable
	implementation
Date: Thu, 16 Aug 2012 10:28:22 -0400
Message-ID: <20120816142821.GC29703@Krystal>
References: <502AFCD5.6070104@gmail.com> <87obmchmpu.fsf@xmission.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B6FB5@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6FB5-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

* David Laight (David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org) wrote:
> > Yes hash_32 seems reasonable for the uid hash.   With those long hash
> > chains I wouldn't like to be on a machine with 10,000 processes with
> > each with a different uid, and a processes calling setuid in the fast
> > path.
> > 
> > The uid hash that we are playing with is one that I sort of wish that
> > the hash table could grow in size, so that we could scale up better.
> 
> Since uids are likely to be allocated in dense blocks, maybe an
> unhashed multi-level lookup scheme might be appropriate.
> 
> Index an array with the low 8 (say) bits of the uid.
> Each item can be either:  
>   1) NULL => free entry.
>   2) a pointer to a uid structure (check uid value).
>   3) a pointer to an array to index with the next 8 bits.
> (2) and (3) can be differentiated by the low address bit.

I'm currently experimenting with "Judy arrays", which would likely be a
good fit for this kind of use-case.

It's basically a 256-ary trie, with fixed depth that depends on the key
size, that uses various encoding (compaction) schemes to compress
internal nodes depending on their density. The original implementation
made by HP has been criticised as somewhat too complex (20k lines of
code), but I'm currently working (in my spare time) on a more elegant
solution, that supports RCU lookups and distributed locking, and uses
much simpler node compaction schemes, and focus on having good cache
locality (and minimal number of cache line hits) for lookups.

I'll be presenting my ongoing work at Plumbers, if you are interested.

Best regards,

Mathieu

> I think that is updateable with cmpxchg.
> 
> Clearly this is a bad algorithm if uids are all multiples of 2^24
> but that is true or any hash function.
> 
> 	David
> 
> 
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
