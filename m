From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 16:07:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.160721.50340210.davem@redhat.com>
References: <20030617200721.GA25773@netnation.com>
	<20030617210700.GE25773@netnation.com>
	<20030617225036.GG25773@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, ralph+d@istop.com, hadi@shell.cyberus.ca,
   xerox@foonet.net, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030617225036.GG25773@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Tue, 17 Jun 2003 15:50:36 -0700
   
   so the problems in 2.4 are probably the result of me hacking in the
   2.5 patch.

I have them in my pending 2.4.x tree, try this:

diff -Nru a/include/net/route.h b/include/net/route.h
--- a/include/net/route.h	Tue Jun 17 16:08:06 2003
+++ b/include/net/route.h	Tue Jun 17 16:08:06 2003
@@ -114,6 +114,8 @@
         unsigned int gc_ignored;
         unsigned int gc_goal_miss;
         unsigned int gc_dst_overflow;
+	unsigned int in_hlist_search;
+	unsigned int out_hlist_search;
 } ____cacheline_aligned_in_smp;
 
 extern struct ip_rt_acct *ip_rt_acct;
diff -Nru a/net/ipv4/Config.in b/net/ipv4/Config.in
--- a/net/ipv4/Config.in	Tue Jun 17 16:08:06 2003
+++ b/net/ipv4/Config.in	Tue Jun 17 16:08:06 2003
@@ -14,7 +14,6 @@
    bool '    IP: equal cost multipath' CONFIG_IP_ROUTE_MULTIPATH
    bool '    IP: use TOS value as routing key' CONFIG_IP_ROUTE_TOS
    bool '    IP: verbose route monitoring' CONFIG_IP_ROUTE_VERBOSE
-   bool '    IP: large routing tables' CONFIG_IP_ROUTE_LARGE_TABLES
 fi
 bool '  IP: kernel level autoconfiguration' CONFIG_IP_PNP
 if [ "$CONFIG_IP_PNP" = "y" ]; then
diff -Nru a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
--- a/net/ipv4/fib_hash.c	Tue Jun 17 16:08:07 2003
+++ b/net/ipv4/fib_hash.c	Tue Jun 17 16:08:07 2003
@@ -89,7 +89,7 @@
 	int		fz_nent;	/* Number of entries	*/
 
 	int		fz_divisor;	/* Hash divisor		*/
-	u32		fz_hashmask;	/* (1<<fz_divisor) - 1	*/
+	u32		fz_hashmask;	/* (fz_divisor - 1)	*/
 #define FZ_HASHMASK(fz)	((fz)->fz_hashmask)
 
 	int		fz_order;	/* Zone order		*/
@@ -149,9 +149,19 @@
 
 static rwlock_t fib_hash_lock = RW_LOCK_UNLOCKED;
 
-#define FZ_MAX_DIVISOR 1024
+#define FZ_MAX_DIVISOR ((PAGE_SIZE<<MAX_ORDER) / sizeof(struct fib_node *))
 
-#ifdef CONFIG_IP_ROUTE_LARGE_TABLES
+static struct fib_node **fz_hash_alloc(int divisor)
+{
+	unsigned long size = divisor * sizeof(struct fib_node *);
+
+	if (divisor <= 1024) {
+		return kmalloc(size, GFP_KERNEL);
+	} else {
+		return (struct fib_node **)
+			__get_free_pages(GFP_KERNEL, get_order(size));
+	}
+}
 
 /* The fib hash lock must be held when this is called. */
 static __inline__ void fn_rebuild_zone(struct fn_zone *fz,
@@ -174,6 +184,15 @@
 	}
 }
 
+static void fz_hash_free(struct fib_node **hash, int divisor)
+{
+	if (divisor <= 1024)
+		kfree(hash);
+	else
+		free_pages((unsigned long) hash,
+			   get_order(divisor * sizeof(struct fib_node *)));
+}
+
 static void fn_rehash_zone(struct fn_zone *fz)
 {
 	struct fib_node **ht, **old_ht;
@@ -185,24 +204,30 @@
 	switch (old_divisor) {
 	case 16:
 		new_divisor = 256;
-		new_hashmask = 0xFF;
 		break;
 	case 256:
 		new_divisor = 1024;
-		new_hashmask = 0x3FF;
 		break;
 	default:
-		printk(KERN_CRIT "route.c: bad divisor %d!\n", old_divisor);
-		return;
+		if ((old_divisor << 1) > FZ_MAX_DIVISOR) {
+			printk(KERN_CRIT "route.c: bad divisor %d!\n", old_divisor);
+			return;
+		}
+		new_divisor = (old_divisor << 1);
+		break;
 	}
+
+	new_hashmask = (new_divisor - 1);
+
 #if RT_CACHE_DEBUG >= 2
 	printk("fn_rehash_zone: hash for zone %d grows from %d\n", fz->fz_order, old_divisor);
 #endif
 
-	ht = kmalloc(new_divisor*sizeof(struct fib_node*), GFP_KERNEL);
+	ht = fz_hash_alloc(new_divisor);
 
 	if (ht)	{
 		memset(ht, 0, new_divisor*sizeof(struct fib_node*));
+
 		write_lock_bh(&fib_hash_lock);
 		old_ht = fz->fz_hash;
 		fz->fz_hash = ht;
@@ -210,10 +235,10 @@
 		fz->fz_divisor = new_divisor;
 		fn_rebuild_zone(fz, old_ht, old_divisor);
 		write_unlock_bh(&fib_hash_lock);
-		kfree(old_ht);
+
+		fz_hash_free(old_ht, old_divisor);
 	}
 }
-#endif /* CONFIG_IP_ROUTE_LARGE_TABLES */
 
 static void fn_free_node(struct fib_node * f)
 {
@@ -233,12 +258,11 @@
 	memset(fz, 0, sizeof(struct fn_zone));
 	if (z) {
 		fz->fz_divisor = 16;
-		fz->fz_hashmask = 0xF;
 	} else {
 		fz->fz_divisor = 1;
-		fz->fz_hashmask = 0;
 	}
-	fz->fz_hash = kmalloc(fz->fz_divisor*sizeof(struct fib_node*), GFP_KERNEL);
+	fz->fz_hashmask = (fz->fz_divisor - 1);
+	fz->fz_hash = fz_hash_alloc(fz->fz_divisor);
 	if (!fz->fz_hash) {
 		kfree(fz);
 		return NULL;
@@ -467,12 +491,10 @@
 	if  ((fi = fib_create_info(r, rta, n, &err)) == NULL)
 		return err;
 
-#ifdef CONFIG_IP_ROUTE_LARGE_TABLES
-	if (fz->fz_nent > (fz->fz_divisor<<2) &&
+	if (fz->fz_nent > (fz->fz_divisor<<1) &&
 	    fz->fz_divisor < FZ_MAX_DIVISOR &&
 	    (z==32 || (1<<z) > fz->fz_divisor))
 		fn_rehash_zone(fz);
-#endif
 
 	fp = fz_chain_p(key, fz);
 
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Tue Jun 17 16:08:07 2003
+++ b/net/ipv4/route.c	Tue Jun 17 16:08:07 2003
@@ -108,7 +108,7 @@
 int ip_rt_max_size;
 int ip_rt_gc_timeout		= RT_GC_TIMEOUT;
 int ip_rt_gc_interval		= 60 * HZ;
-int ip_rt_gc_min_interval	= 5 * HZ;
+int ip_rt_gc_min_interval	= HZ / 2;
 int ip_rt_redirect_number	= 9;
 int ip_rt_redirect_load		= HZ / 50;
 int ip_rt_redirect_silence	= ((HZ / 50) << (9 + 1));
@@ -287,7 +287,7 @@
         for (lcpu = 0; lcpu < smp_num_cpus; lcpu++) {
                 i = cpu_logical_map(lcpu);
 
-		len += sprintf(buffer+len, "%08x  %08x %08x %08x %08x %08x %08x %08x  %08x %08x %08x %08x %08x %08x %08x \n",
+		len += sprintf(buffer+len, "%08x  %08x %08x %08x %08x %08x %08x %08x  %08x %08x %08x %08x %08x %08x %08x %08x %08x \n",
 			       dst_entries,		       
 			       rt_cache_stat[i].in_hit,
 			       rt_cache_stat[i].in_slow_tot,
@@ -304,7 +304,9 @@
 			       rt_cache_stat[i].gc_total,
 			       rt_cache_stat[i].gc_ignored,
 			       rt_cache_stat[i].gc_goal_miss,
-			       rt_cache_stat[i].gc_dst_overflow
+			       rt_cache_stat[i].gc_dst_overflow,
+			       rt_cache_stat[i].in_hlist_search,
+			       rt_cache_stat[i].out_hlist_search
 
 			);
 	}
@@ -344,16 +346,17 @@
 		rth->u.dst.expires;
 }
 
-static __inline__ int rt_may_expire(struct rtable *rth, int tmo1, int tmo2)
+static __inline__ int rt_may_expire(struct rtable *rth, unsigned long tmo1, unsigned long tmo2)
 {
-	int age;
+	unsigned long age;
 	int ret = 0;
 
 	if (atomic_read(&rth->u.dst.__refcnt))
 		goto out;
 
 	ret = 1;
-	if (rth->u.dst.expires && (long)(rth->u.dst.expires - jiffies) <= 0)
+	if (rth->u.dst.expires &&
+	    time_after_eq(jiffies, rth->u.dst.expires))
 		goto out;
 
 	age = jiffies - rth->u.dst.lastuse;
@@ -365,6 +368,25 @@
 out:	return ret;
 }
 
+/* Bits of score are:
+ * 31: very valuable
+ * 30: not quite useless
+ * 29..0: usage counter
+ */
+static inline u32 rt_score(struct rtable *rt)
+{
+	u32 score = rt->u.dst.__use;
+
+	if (rt_valuable(rt))
+		score |= (1<<31);
+
+	if (!rt->key.iif ||
+	    !(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL)))
+		score |= (1<<30);
+
+	return score;
+}
+
 /* This runs via a timer and thus is always in BH context. */
 static void SMP_TIMER_NAME(rt_check_expire)(unsigned long dummy)
 {
@@ -375,7 +397,7 @@
 
 	for (t = ip_rt_gc_interval << rt_hash_log; t >= 0;
 	     t -= ip_rt_gc_timeout) {
-		unsigned tmo = ip_rt_gc_timeout;
+		unsigned long tmo = ip_rt_gc_timeout;
 
 		i = (i + 1) & rt_hash_mask;
 		rthp = &rt_hash_table[i].chain;
@@ -384,7 +406,7 @@
 		while ((rth = *rthp) != NULL) {
 			if (rth->u.dst.expires) {
 				/* Entry is expired even if it is in use */
-				if ((long)(now - rth->u.dst.expires) <= 0) {
+				if (time_before_eq(now, rth->u.dst.expires)) {
 					tmo >>= 1;
 					rthp = &rth->u.rt_next;
 					continue;
@@ -402,7 +424,7 @@
 		write_unlock(&rt_hash_table[i].lock);
 
 		/* Fallback loop breaker. */
-		if ((jiffies - now) > 0)
+		if (time_after(jiffies, now))
 			break;
 	}
 	rover = i;
@@ -504,7 +526,7 @@
 
 static int rt_garbage_collect(void)
 {
-	static unsigned expire = RT_GC_TIMEOUT;
+	static unsigned long expire = RT_GC_TIMEOUT;
 	static unsigned long last_gc;
 	static int rover;
 	static int equilibrium;
@@ -556,7 +578,7 @@
 		int i, k;
 
 		for (i = rt_hash_mask, k = rover; i >= 0; i--) {
-			unsigned tmo = expire;
+			unsigned long tmo = expire;
 
 			k = (k + 1) & rt_hash_mask;
 			rthp = &rt_hash_table[k].chain;
@@ -602,7 +624,7 @@
 
 		if (atomic_read(&ipv4_dst_ops.entries) < ip_rt_max_size)
 			goto out;
-	} while (!in_softirq() && jiffies - now < 1);
+	} while (!in_softirq() && time_before_eq(jiffies, now));
 
 	if (atomic_read(&ipv4_dst_ops.entries) < ip_rt_max_size)
 		goto out;
@@ -626,10 +648,19 @@
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
 	struct rtable	*rth, **rthp;
-	unsigned long	now = jiffies;
+	unsigned long	now;
+	struct rtable *cand, **candp;
+	u32 		min_score;
+	int		chain_length;
 	int attempts = !in_softirq();
 
 restart:
+	chain_length = 0;
+	min_score = ~(u32)0;
+	cand = NULL;
+	candp = NULL;
+	now = jiffies;
+
 	rthp = &rt_hash_table[hash].chain;
 
 	write_lock_bh(&rt_hash_table[hash].lock);
@@ -650,9 +681,35 @@
 			return 0;
 		}
 
+		if (!atomic_read(&rth->u.dst.__refcnt)) {
+			u32 score = rt_score(rth);
+
+			if (score <= min_score) {
+				cand = rth;
+				candp = rthp;
+				min_score = score;
+			}
+		}
+
+		chain_length++;
+
 		rthp = &rth->u.rt_next;
 	}
 
+	if (cand) {
+		/* ip_rt_gc_elasticity used to be average length of chain
+		 * length, when exceeded gc becomes really aggressive.
+		 *
+		 * The second limit is less certain. At the moment it allows
+		 * only 2 entries per bucket. We will see.
+		 */
+		if (chain_length > ip_rt_gc_elasticity ||
+		    (chain_length > 1 && !(min_score & (1<<31)))) {
+			*candp = cand->u.rt_next;
+			rt_free(cand);
+		}
+	}
+
 	/* Try to bind route to arp only if it is output
 	   route or unicast forwarding path.
 	 */
@@ -960,7 +1017,7 @@
 	/* No redirected packets during ip_rt_redirect_silence;
 	 * reset the algorithm.
 	 */
-	if (jiffies - rt->u.dst.rate_last > ip_rt_redirect_silence)
+	if (time_after(jiffies, rt->u.dst.rate_last + ip_rt_redirect_silence))
 		rt->u.dst.rate_tokens = 0;
 
 	/* Too many ignored redirects; do not send anything
@@ -974,8 +1031,9 @@
 	/* Check for load limit; set rate_last to the latest sent
 	 * redirect.
 	 */
-	if (jiffies - rt->u.dst.rate_last >
-	    (ip_rt_redirect_load << rt->u.dst.rate_tokens)) {
+	if (time_after(jiffies,
+		       (rt->u.dst.rate_last +
+			(ip_rt_redirect_load << rt->u.dst.rate_tokens)))) {
 		icmp_send(skb, ICMP_REDIRECT, ICMP_REDIR_HOST, rt->rt_gateway);
 		rt->u.dst.rate_last = jiffies;
 		++rt->u.dst.rate_tokens;
@@ -1672,6 +1730,7 @@
 			skb->dst = (struct dst_entry*)rth;
 			return 0;
 		}
+		rt_cache_stat[smp_processor_id()].in_hlist_search++;
 	}
 	read_unlock(&rt_hash_table[hash].lock);
 
@@ -2032,6 +2091,7 @@
 			*rp = rth;
 			return 0;
 		}
+		rt_cache_stat[smp_processor_id()].out_hlist_search++;
 	}
 	read_unlock_bh(&rt_hash_table[hash].lock);
 
