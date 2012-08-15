From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 01/16] hashtable: introduce a small and naive
	hashtable
Date: Wed, 15 Aug 2012 02:24:49 +0200
Message-ID: <502AEC51.2010305@gmail.com>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
	<1344961490-4068-2-git-send-email-levinsasha928@gmail.com>
	<20120815092523.00a909ef@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org,
	dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org,
	mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20120815092523.00a909ef-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
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

On 08/15/2012 01:25 AM, NeilBrown wrote:
> On Tue, 14 Aug 2012 18:24:35 +0200 Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> wrote:
> 
> 
>> +static inline void hash_init_size(struct hlist_head *hashtable, int bits)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < HASH_SIZE(bits); i++)
>> +		INIT_HLIST_HEAD(hashtable + i);
>> +}
> 
> This seems like an inefficient way to do "memset(hashtable, 0, ...);".
> And in many cases it isn't needed as the hash table is static and initialised
> to zero.
> I note that in the SUNRPC/cache patch you call hash_init(), but in the lockd
> patch you don't.  You don't actually need to in either case.

Agreed that the code will run just fine if we wouldn't use hash_init().

> I realise that any optimisation here is for code that is only executed once
> per boot, so no big deal, and even the presence of extra code making the
> kernel bigger is unlikely to be an issue.  But I'd at least like to see
> consistency: Either use hash_init everywhere, even when not needed, or only
> use it where absolutely needed which might be no-where because static tables
> are already initialised, and dynamic tables can use GFP_ZERO.

This is a consistency problem. I didn't want to add a module_init() to modules that didn't have it just to get hash_init() in there.

I'll get it fixed.

> And if you keep hash_init_size I would rather see a memset(0)....

My concern with using a memset(0) is that I'm going to break layering.

The hashtable uses hlist. hlist provides us with an entire family of init functions which I'm supposed to use to initialize hlist heads.

So while a memset(0) will work perfectly here, I consider that cheating - it results in an uglier code that assumes to know about hlist internals, and will probably break as soon as someone tries to do something to hlist.

I can think of several alternatives here, and all of them involve changes to hlist instead of the hashtable:

 - Remove INIT_HLIST_HEAD()/HLIST_HEAD()/HLIST_HEAD_INIT() and introduce a CLEAR_HLIST instead, documenting that it's enough to memset(0) the hlist to initialize it properly.
 - Add a block initializer INIT_HLIST_HEADS() or something similar that would initialize an array of heads.
