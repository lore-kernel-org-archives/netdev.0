From: Anton Blanchard <anton@samba.org>
Subject: Re: ARP does not scale
Date: Sun, 14 Mar 2004 10:32:22 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040313233222.GB19737@krispykreme>
References: <200403131129.51083.timg@tpi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tim Gardner <timg@tpi.com>
Content-Disposition: inline
In-Reply-To: <200403131129.51083.timg@tpi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[moving this to netdev]

> ARP has hash table and garbage collection scalability limitations.
> 
> Please find attached a patch for 2.4.24 (also works for 2.4.25) that allows
> you to choose the size of your ARP hash table. Simply choosing the ARP hash
> table size that suits your network can cut the ARP list search time by an
> order of magnitude. For example, the default hash table size is 32. My
> network has over 1000 nodes. If you assume the hash function spreads those
> evenly, then there are approximately 31 hash collisions per bucket.
> Increasing the hash table size to 512 cuts down the collisions to
> approximately 2 per bucket.

It would be nice to fix this properly in 2.6, a CONFIG option for this sort 
of thing is painful for distros.

Check out net/ipv4/tcp.c and how it makes an effort to scale tcp_ehash and 
tcp_bhash with memory and also allows an override with a cmdline option 
thash_entries.

Anton

> Related to scalability is the ARP entry garbage collector. It is currently
> coded such that it runs at periodic intervals and processes all ARP entries
> in all hash table buckets all within one invocation. As the number of ARP
> entries becomes large, the amount of time spent processing all of the ARP
> entries also becomes large. At a certain point I think it will begin to cause
> significant jitter in packet delivery times. In an effort to smooth out the
> garbage collector impact I've recoded it to only process one hash bucket per
> invocation. The garbage collector resets its timer so that it processes all
> buckets at least once every 60 seconds.
> 
> rtg
> 
> <--SNIP-->
> 
> diff -r -u --new-file linux-2.4.24/Documentation/Configure.help 
> linux-2.4.24.arp/Documentation/Configure.help
> --- linux-2.4.24/Documentation/Configure.help	2004-03-12 07:34:37.000000000 
> -0700
> +++ linux-2.4.24.arp/Documentation/Configure.help	2004-03-12 
> 09:07:01.000000000 -0700
> @@ -6921,6 +6921,13 @@
>  
>    If unsure, say N.
>  
> +ARP hash table size power of 2
> +CONFIG_NEIGH_NUM_HASHBITS
> +  This option defines the size of the ARP hash table for each protocol. The 
> default size of 5
> +  bits (32) is adequate for small LANs. Larger LANs may have enough ARP 
> entries that there are
> +  multiple hash table collisions. In that case, increasing the number of hash 
> table entries
> +  improves ARP entry access performance at the expense of some RAM.
> +
>  Packet socket
>  CONFIG_PACKET
>    The Packet protocol is used by applications which communicate
> diff -r -u --new-file linux-2.4.24/include/net/neighbour.h 
> linux-2.4.24.arp/include/net/neighbour.h
> --- linux-2.4.24/include/net/neighbour.h	2004-03-12 07:34:44.000000000 -0700
> +++ linux-2.4.24.arp/include/net/neighbour.h	2004-03-12 09:35:07.000000000 
> -0700
> @@ -128,7 +128,7 @@
>  	u8			key[0];
>  };
>  
> -#define NEIGH_HASHMASK		0x1F
> +#define NEIGH_HASHMASK		((1<<CONFIG_NEIGH_NUM_HASHBITS)-1)
>  #define PNEIGH_HASHMASK		0xF
>  
>  /*
> @@ -166,6 +166,7 @@
>  	struct tasklet_struct	gc_task;
>  	struct neigh_statistics	stats;
>  	struct neighbour	*hash_buckets[NEIGH_HASHMASK+1];
> +	int					curr_hash_bucket;
>  	struct pneigh_entry	*phash_buckets[PNEIGH_HASHMASK+1];
>  };
>  
> diff -r -u --new-file linux-2.4.24/net/Config.in 
> linux-2.4.24.arp/net/Config.in
> --- linux-2.4.24/net/Config.in	2004-03-12 07:33:30.000000000 -0700
> +++ linux-2.4.24.arp/net/Config.in	2004-03-12 09:05:10.000000000 -0700
> @@ -8,6 +8,8 @@
>     bool '  Packet socket: mmapped IO' CONFIG_PACKET_MMAP
>  fi
>  
> +int 'ARP hash table size power of 2' CONFIG_NEIGH_NUM_HASHBITS 5
> +
>  tristate 'Netlink device emulation' CONFIG_NETLINK_DEV
>  
>  bool 'Network packet filtering (replaces ipchains)' CONFIG_NETFILTER
> diff -r -u --new-file linux-2.4.24/net/core/neighbour.c 
> linux-2.4.24.arp/net/core/neighbour.c
> --- linux-2.4.24/net/core/neighbour.c	2004-03-12 07:33:13.000000000 -0700
> +++ linux-2.4.24.arp/net/core/neighbour.c	2004-03-12 09:36:35.000000000 -0700
> @@ -566,9 +566,8 @@
>  static void SMP_TIMER_NAME(neigh_periodic_timer)(unsigned long arg)
>  {
>  	struct neigh_table *tbl = (struct neigh_table*)arg;
> +	struct neighbour *n, **np;
>  	unsigned long now = jiffies;
> -	int i;
> -
>  
>  	write_lock(&tbl->lock);
>  
> @@ -583,46 +582,48 @@
>  			p->reachable_time = neigh_rand_reach_time(p->base_reachable_time);
>  	}
>  
> -	for (i=0; i <= NEIGH_HASHMASK; i++) {
> -		struct neighbour *n, **np;
> +	tbl->curr_hash_bucket &= NEIGH_HASHMASK;
> +	np = &tbl->hash_buckets[tbl->curr_hash_bucket++];
>  
> -		np = &tbl->hash_buckets[i];
> -		while ((n = *np) != NULL) {
> -			unsigned state;
> -
> -			write_lock(&n->lock);
> -
> -			state = n->nud_state;
> -			if (state&(NUD_PERMANENT|NUD_IN_TIMER)) {
> -				write_unlock(&n->lock);
> -				goto next_elt;
> -			}
> +	while ((n = *np) != NULL) {
> +		unsigned state;
>  
> -			if ((long)(n->used - n->confirmed) < 0)
> -				n->used = n->confirmed;
> +		write_lock(&n->lock);
>  
> -			if (atomic_read(&n->refcnt) == 1 &&
> -			    (state == NUD_FAILED || now - n->used > n->parms->gc_staletime)) {
> -				*np = n->next;
> -				n->dead = 1;
> -				write_unlock(&n->lock);
> -				neigh_release(n);
> -				continue;
> -			}
> +		state = n->nud_state;
> +		if (state&(NUD_PERMANENT|NUD_IN_TIMER)) {
> +			write_unlock(&n->lock);
> +			goto next_elt;
> +		}
>  
> -			if (n->nud_state&NUD_REACHABLE &&
> -			    now - n->confirmed > n->parms->reachable_time) {
> -				n->nud_state = NUD_STALE;
> -				neigh_suspect(n);
> -			}
> +		if ((long)(n->used - n->confirmed) < 0)
> +			n->used = n->confirmed;
> +
> +		if (atomic_read(&n->refcnt) == 1 &&
> +		    (state == NUD_FAILED || now - n->used > n->parms->gc_staletime)) {
> +			*np = n->next;
> +			n->dead = 1;
>  			write_unlock(&n->lock);
> +			neigh_release(n);
> +			continue;
> +		}
>  
> -next_elt:
> -			np = &n->next;
> +		if (n->nud_state&NUD_REACHABLE &&
> +		    now - n->confirmed > n->parms->reachable_time) {
> +			n->nud_state = NUD_STALE;
> +			neigh_suspect(n);
>  		}
> +		write_unlock(&n->lock);
> +
> +next_elt:
> +		np = &n->next;
>  	}
>  
> -	mod_timer(&tbl->gc_timer, now + tbl->gc_interval);
> +	/*
> +	 * Cycle through all hash buckets every 60 seconds.
> +	 */
> +	mod_timer(&tbl->gc_timer, now+((HZ*60)/(NEIGH_HASHMASK+1)));
> +
>  	write_unlock(&tbl->lock);
>  }
>  
> 
> --
> Tim Gardner - timg@tpi.com
> www.tpi.com 406-443-5357
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
