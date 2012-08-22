From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 01/17] hashtable: introduce a small and
 naive hashtable
Date: Wed, 22 Aug 2012 11:01:38 -0700
Message-ID: <20120822180138.GA19212@google.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
	<1345602432-27673-2-git-send-email-levinsasha928@gmail.com>
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
	mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1345602432-27673-2-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
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

Hello, Sasha.

On Wed, Aug 22, 2012 at 04:26:56AM +0200, Sasha Levin wrote:
> +#define DEFINE_HASHTABLE(name, bits)					\
> +	struct hlist_head name[HASH_SIZE(bits)];

Shouldn't this be something like the following?

#define DEFINE_HASHTABLE(name, bits)					\
	struct hlist_head name[HASH_SIZE(bits)] =			\
		{ [0 ... HASH_SIZE(bits) - 1] = HLIST_HEAD_INIT };

Also, given that the declaration isn't non-trivial, you'll probably
want a matching DECLARE_HASHTABLE() macro too.

> +/* Use hash_32 when possible to allow for fast 32bit hashing in 64bit kernels. */
> +#define hash_min(val, bits) ((sizeof(val)==4) ? hash_32((val), (bits)) : hash_long((val), (bits)))

Why is the branching condition sizeof(val) == 4 instead of <= 4?
Also, no biggie but why isn't this macro in caps?

> +/**
> + * hash_add_size - add an object to a hashtable
> + * @hashtable: hashtable to add to
> + * @bits: bit count used for hashing
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add_size(hashtable, bits, node, key)				\
> +	hlist_add_head(node, &hashtable[hash_min(key, bits)]);
> +
> +/**
> + * hash_add - add an object to a hashtable
> + * @hashtable: hashtable to add to
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add(hashtable, node, key)						\
> +	hash_add_size(hashtable, HASH_BITS(hashtable), node, key)

It would be nice if the comments actually say something which can
differentiate the two.  Ditto for rcu variants.

> +/**
> + * hash_add_rcu_size - add an object to a rcu enabled hashtable
> + * @hashtable: hashtable to add to
> + * @bits: bit count used for hashing
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add_rcu_size(hashtable, bits, node, key)				\
> +	hlist_add_head_rcu(node, &hashtable[hash_min(key, bits)]);
> +
> +/**
> + * hash_add_rcu - add an object to a rcu enabled hashtable
> + * @hashtable: hashtable to add to
> + * @node: the &struct hlist_node of the object to be added
> + * @key: the key of the object to be added
> + */
> +#define hash_add_rcu(hashtable, node, key)					\
> +	hash_add_rcu_size(hashtable, HASH_BITS(hashtable), node, key)

Or maybe we're better off with hash_head_size() and hash_head()?  I'll
expand on it later.  Please bear with me.

> +/**
> + * hash_hashed - check whether an object is in any hashtable
> + * @node: the &struct hlist_node of the object to be checked
> + */
> +#define hash_hashed(node) (!hlist_unhashed(node))

As the 'h' in hlist* stand for hash anyway and I think this type of
thin wrappers tend to obfuscate more than anything else.

> +/**
> + * hash_del - remove an object from a hashtable
> + * @node: &struct hlist_node of the object to remove
> + */
> +static inline void hash_del(struct hlist_node *node)
> +{
> +	hlist_del_init(node);
> +}
> +
> +/**
> + * hash_del_rcu - remove an object from a rcu enabled hashtable
> + * @node: &struct hlist_node of the object to remove
> + */
> +static inline void hash_del_rcu(struct hlist_node *node)
> +{
> +	hlist_del_init_rcu(node);
> +}

If we do that, we can remove all these thin wrappers.

> +#define hash_for_each_size(name, bits, bkt, node, obj, member)			\
> +	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)				\
> +		hlist_for_each_entry(obj, node, &name[bkt], member)
..
> +#define hash_for_each(name, bkt, node, obj, member)				\
> +	hash_for_each_size(name, HASH_BITS(name), bkt, node, obj, member)
...
> +#define hash_for_each_rcu_size(name, bits, bkt, node, obj, member)		\
> +	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)				\
> +		hlist_for_each_entry_rcu(obj, node, &name[bkt], member)
...
> +#define hash_for_each_rcu(name, bkt, node, obj, member)				\
> +	hash_for_each_rcu_size(name, HASH_BITS(name), bkt, node, obj, member)
...
> +#define hash_for_each_safe_size(name, bits, bkt, node, tmp, obj, member)	\
> +	for (bkt = 0; bkt < HASH_SIZE(bits); bkt++)                     	\
> +		hlist_for_each_entry_safe(obj, node, tmp, &name[bkt], member)
...
> +#define hash_for_each_safe(name, bkt, node, tmp, obj, member)			\
> +	hash_for_each_safe_size(name, HASH_BITS(name), bkt, node,		\
> +				tmp, obj, member)
...
> +#define hash_for_each_possible_size(name, obj, bits, node, member, key)		\
> +	hlist_for_each_entry(obj, node,	&name[hash_min(key, bits)], member)
...
> +#define hash_for_each_possible(name, obj, node, member, key)			\
> +	hash_for_each_possible_size(name, obj, HASH_BITS(name), node, member, key)
...
> +#define hash_for_each_possible_rcu_size(name, obj, bits, node, member, key)	\
> +	hlist_for_each_entry_rcu(obj, node, &name[hash_min(key, bits)], member)
...
> +#define hash_for_each_possible_rcu(name, obj, node, member, key)		\
> +	hash_for_each_possible_rcu_size(name, obj, HASH_BITS(name),		\
...
> +#define hash_for_each_possible_safe_size(name, obj, bits, node, tmp, member, key)\
> +	hlist_for_each_entry_safe(obj, node, tmp,				\
> +		&name[hash_min(key, bits)], member)
...
> +#define hash_for_each_possible_safe(name, obj, node, tmp, member, key)		\
> +	hash_for_each_possible_safe_size(name, obj, HASH_BITS(name),		\

And also all these.  We'd only need hash_for_each_head() and
hash_head().  hash_for_each_possible*() could be nice for convenience,
I suppose.

I think the almost trivial nature of hlist hashtables makes this a bit
tricky and I'm not very sure but having this combinatory explosion is
a bit dazzling when the same functionality can be achieved by simply
combining operations which are already defined and named considering
hashtable.  I'm not feeling too strong about this tho.  What do others
think?

Also, can you please audit the comments on top of each macro?  They
have wrong names and don't differentiate the different variants very
well.

Thanks.

-- 
tejun
