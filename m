From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] netfilter: ipset: Convert timers to use timer_setup()
Date: Thu, 5 Oct 2017 15:58:11 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1710051551460.11178@blackhole.kfki.hu>
References: <20171005005221.GA23584@beast>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        simran singhal <singhalsimran0@gmail.com>,
        Muhammad Falak R Wani <falakreyaz@gmail.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005005221.GA23584@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, 4 Oct 2017, Kees Cook wrote:

> In preparation for unconditionally passing the struct timer_list pointer 
> to all timer callbacks, switch to using the new timer_setup() and 
> from_timer() to pass the timer pointer explicitly. This introduces a 
> pointer back to the struct ip_set, which is used instead of the struct 
> timer_list .data field.

Please add the same changes to net/netfilter/ipset/ip_set_list.c too, in 
order to handle all ipset modules in a single patch. I don't see a way 
either to avoid the introduction of the new pointer.

Acked-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Best regards,
Jozsef
 
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Cc: Florian Westphal <fw@strlen.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: simran singhal <singhalsimran0@gmail.com>
> Cc: Muhammad Falak R Wani <falakreyaz@gmail.com>
> Cc: netfilter-devel@vger.kernel.org
> Cc: coreteam@netfilter.org
> Cc: netdev@vger.kernel.org
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> This requires commit 686fef928bba ("timer: Prepare to change timer
> callback argument type") in v4.14-rc3, but should be otherwise
> stand-alone.
> ---
>  net/netfilter/ipset/ip_set_bitmap_gen.h   | 10 +++++-----
>  net/netfilter/ipset/ip_set_bitmap_ip.c    |  2 ++
>  net/netfilter/ipset/ip_set_bitmap_ipmac.c |  2 ++
>  net/netfilter/ipset/ip_set_bitmap_port.c  |  2 ++
>  net/netfilter/ipset/ip_set_hash_gen.h     | 12 +++++++-----
>  5 files changed, 18 insertions(+), 10 deletions(-)
> 
> diff --git a/net/netfilter/ipset/ip_set_bitmap_gen.h b/net/netfilter/ipset/ip_set_bitmap_gen.h
> index 8ad2b52a0b32..5ca18f07683b 100644
> --- a/net/netfilter/ipset/ip_set_bitmap_gen.h
> +++ b/net/netfilter/ipset/ip_set_bitmap_gen.h
> @@ -37,11 +37,11 @@
>  #define get_ext(set, map, id)	((map)->extensions + ((set)->dsize * (id)))
>  
>  static void
> -mtype_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
> +mtype_gc_init(struct ip_set *set, void (*gc)(struct timer_list *t))
>  {
>  	struct mtype *map = set->data;
>  
> -	setup_timer(&map->gc, gc, (unsigned long)set);
> +	timer_setup(&map->gc, gc, 0);
>  	mod_timer(&map->gc, jiffies + IPSET_GC_PERIOD(set->timeout) * HZ);
>  }
>  
> @@ -272,10 +272,10 @@ mtype_list(const struct ip_set *set,
>  }
>  
>  static void
> -mtype_gc(unsigned long ul_set)
> +mtype_gc(struct timer_list *t)
>  {
> -	struct ip_set *set = (struct ip_set *)ul_set;
> -	struct mtype *map = set->data;
> +	struct mtype *map = from_timer(map, t, gc);
> +	struct ip_set *set = map->set;
>  	void *x;
>  	u32 id;
>  
> diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
> index 4783efff0bde..d8975a0b4282 100644
> --- a/net/netfilter/ipset/ip_set_bitmap_ip.c
> +++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
> @@ -48,6 +48,7 @@ struct bitmap_ip {
>  	size_t memsize;		/* members size */
>  	u8 netmask;		/* subnet netmask */
>  	struct timer_list gc;	/* garbage collection */
> +	struct ip_set *set;	/* attached to this ip_set */
>  	unsigned char extensions[0]	/* data extensions */
>  		__aligned(__alignof__(u64));
>  };
> @@ -232,6 +233,7 @@ init_map_ip(struct ip_set *set, struct bitmap_ip *map,
>  	map->netmask = netmask;
>  	set->timeout = IPSET_NO_TIMEOUT;
>  
> +	map->set = set;
>  	set->data = map;
>  	set->family = NFPROTO_IPV4;
>  
> diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
> index 9a065f672d3a..4c279fbd2d5d 100644
> --- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
> +++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
> @@ -52,6 +52,7 @@ struct bitmap_ipmac {
>  	u32 elements;		/* number of max elements in the set */
>  	size_t memsize;		/* members size */
>  	struct timer_list gc;	/* garbage collector */
> +	struct ip_set *set;	/* attached to this ip_set */
>  	unsigned char extensions[0]	/* MAC + data extensions */
>  		__aligned(__alignof__(u64));
>  };
> @@ -307,6 +308,7 @@ init_map_ipmac(struct ip_set *set, struct bitmap_ipmac *map,
>  	map->elements = elements;
>  	set->timeout = IPSET_NO_TIMEOUT;
>  
> +	map->set = set;
>  	set->data = map;
>  	set->family = NFPROTO_IPV4;
>  
> diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
> index 7f0c733358a4..7f9bbd7c98b5 100644
> --- a/net/netfilter/ipset/ip_set_bitmap_port.c
> +++ b/net/netfilter/ipset/ip_set_bitmap_port.c
> @@ -40,6 +40,7 @@ struct bitmap_port {
>  	u32 elements;		/* number of max elements in the set */
>  	size_t memsize;		/* members size */
>  	struct timer_list gc;	/* garbage collection */
> +	struct ip_set *set;	/* attached to this ip_set */
>  	unsigned char extensions[0]	/* data extensions */
>  		__aligned(__alignof__(u64));
>  };
> @@ -214,6 +215,7 @@ init_map_port(struct ip_set *set, struct bitmap_port *map,
>  	map->last_port = last_port;
>  	set->timeout = IPSET_NO_TIMEOUT;
>  
> +	map->set = set;
>  	set->data = map;
>  	set->family = NFPROTO_UNSPEC;
>  
> diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
> index 51063d9ed0f7..efffc8eabafe 100644
> --- a/net/netfilter/ipset/ip_set_hash_gen.h
> +++ b/net/netfilter/ipset/ip_set_hash_gen.h
> @@ -280,6 +280,7 @@ htable_bits(u32 hashsize)
>  struct htype {
>  	struct htable __rcu *table; /* the hash table */
>  	struct timer_list gc;	/* garbage collection when timeout enabled */
> +	struct ip_set *set;	/* attached to this ip_set */
>  	u32 maxelem;		/* max elements in the hash */
>  	u32 initval;		/* random jhash init value */
>  #ifdef IP_SET_HASH_WITH_MARKMASK
> @@ -429,11 +430,11 @@ mtype_destroy(struct ip_set *set)
>  }
>  
>  static void
> -mtype_gc_init(struct ip_set *set, void (*gc)(unsigned long ul_set))
> +mtype_gc_init(struct ip_set *set, void (*gc)(struct timer_list *t))
>  {
>  	struct htype *h = set->data;
>  
> -	setup_timer(&h->gc, gc, (unsigned long)set);
> +	timer_setup(&h->gc, gc, 0);
>  	mod_timer(&h->gc, jiffies + IPSET_GC_PERIOD(set->timeout) * HZ);
>  	pr_debug("gc initialized, run in every %u\n",
>  		 IPSET_GC_PERIOD(set->timeout));
> @@ -526,10 +527,10 @@ mtype_expire(struct ip_set *set, struct htype *h)
>  }
>  
>  static void
> -mtype_gc(unsigned long ul_set)
> +mtype_gc(struct timer_list *t)
>  {
> -	struct ip_set *set = (struct ip_set *)ul_set;
> -	struct htype *h = set->data;
> +	struct htype *h = from_timer(h, t, gc);
> +	struct ip_set *set = h->set;
>  
>  	pr_debug("called\n");
>  	spin_lock_bh(&set->lock);
> @@ -1314,6 +1315,7 @@ IPSET_TOKEN(HTYPE, _create)(struct net *net, struct ip_set *set,
>  	t->htable_bits = hbits;
>  	RCU_INIT_POINTER(h->table, t);
>  
> +	h->set = set;
>  	set->data = h;
>  #ifndef IP_SET_PROTO_UNDEF
>  	if (set->family == NFPROTO_IPV4) {
> -- 
> 2.7.4
> 
> 
> -- 
> Kees Cook
> Pixel Security
> 

-
E-mail  : kadlec@blackhole.kfki.hu, kadlecsik.jozsef@wigner.mta.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : Wigner Research Centre for Physics, Hungarian Academy of Sciences
          H-1525 Budapest 114, POB. 49, Hungary
