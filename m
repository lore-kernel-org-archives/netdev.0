From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 20:34:50 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16102.9418.43884.336925@robur.slu.se>
References: <Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
	<20030610.084940.74727904.davem@redhat.com>
	<Pine.LNX.4.51.0306101332300.8755@ns.istop.com>
	<20030610.103234.116374169.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralph+d@istop.com, ralph@istop.com, hadi@shell.cyberus.ca,
   xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.103234.116374169.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Dave!

I ripped out the route hash just to test the slow path. Seems like your 
patch was very good as we see the same performance w/o dst hash ~114 kpps.

So my test system drops from 450 kpps to 114 kpps when every incoming 
interface carries 100% traffic which has 1 dst/pkt which is very unlikely 
senario I would say. It is not that bad....

Conclusions:
* Your patch is good. (I played with some variants)
* We need to focus on slow path if we feel improving the 1 dst/pkt 
  scenario.


Input rate 2*190 kpps clone_skb=1

Iface   MTU Met  RX-OK RX-ERR RX-DRP RX-OVR  TX-OK TX-ERR TX-DRP TX-OVR Flags
eth0   1500   0 3001546 9684614 9684614 6998518     53      0      0      0 BRU
eth1   1500   0     13      0      0      0 3001497      0      0      0 BRU
eth2   1500   0 3001114 9678333 9678333 6998889      3      0      0      0 BRU
eth3   1500   0      2      0      0      0 3001115      0      0      0 BRU

rt_cache_stat
00009146  00000000 005b97ed 00000000 00000000 00000000 00000000 00000000  00000004 00000006 00000000 005b107e 005b1071 00000006 00000000 00000000 00000001 

--- net/ipv4/route.c.030610.2	2003-06-10 18:55:32.000000000 +0200
+++ net/ipv4/route.c	2003-06-10 19:09:23.000000000 +0200
@@ -722,44 +722,10 @@
 
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
-	struct rtable	*rth, **rthp;
-	unsigned long	now = jiffies;
 	int attempts = !in_softirq();
 
 restart:
-	rthp = &rt_hash_table[hash].chain;
-
 	spin_lock_bh(&rt_hash_table[hash].lock);
-	while ((rth = *rthp) != NULL) {
-		if (compare_keys(&rth->fl, &rt->fl)) {
-			/* Put it first */
-			*rthp = rth->u.rt_next;
-			/*
-			 * Since lookup is lockfree, the deletion
-			 * must be visible to another weakly ordered CPU before
-			 * the insertion at the start of the hash chain.
-			 */
-			smp_wmb();
-			rth->u.rt_next = rt_hash_table[hash].chain;
-			/*
-			 * Since lookup is lockfree, the update writes
-			 * must be ordered for consistency on SMP.
-			 */
-			smp_wmb();
-			rt_hash_table[hash].chain = rth;
-
-			rth->u.dst.__use++;
-			dst_hold(&rth->u.dst);
-			rth->u.dst.lastuse = now;
-			spin_unlock_bh(&rt_hash_table[hash].lock);
-
-			rt_drop(rt);
-			*rp = rth;
-			return 0;
-		}
-
-		rthp = &rth->u.rt_next;
-	}
 
 	/* Try to bind route to arp only if it is output
 	   route or unicast forwarding path.
@@ -916,10 +882,7 @@
 
 static inline struct rtable *ip_rt_dst_alloc(unsigned int hash)
 {
-	if (atomic_read(&ipv4_dst_ops.entries) >
-	    ipv4_dst_ops.gc_thresh)
-		__rt_hash_shrink(hash);
-
+	__rt_hash_shrink(hash);
 	return dst_alloc(&ipv4_dst_ops);
 }
 
@@ -1801,37 +1764,6 @@
 int ip_route_input(struct sk_buff *skb, u32 daddr, u32 saddr,
 		   u8 tos, struct net_device *dev)
 {
-	struct rtable * rth;
-	unsigned	hash;
-	int iif = dev->ifindex;
-
-	tos &= IPTOS_RT_MASK;
-	hash = rt_hash_code(daddr, saddr ^ (iif << 5), tos);
-
-	prefetch(&rt_hash_table[hash].chain->fl);
-
-	rcu_read_lock();
-	for (rth = rt_hash_table[hash].chain; rth; rth = rth->u.rt_next) {
-		smp_read_barrier_depends();
-		if (rth->fl.fl4_dst == daddr &&
-		    rth->fl.fl4_src == saddr &&
-		    rth->fl.iif == iif &&
-		    rth->fl.oif == 0 &&
-#ifdef CONFIG_IP_ROUTE_FWMARK
-		    rth->fl.fl4_fwmark == skb->nfmark &&
-#endif
-		    rth->fl.fl4_tos == tos) {
-			rth->u.dst.lastuse = jiffies;
-			dst_hold(&rth->u.dst);
-			rth->u.dst.__use++;
-			RT_CACHE_STAT_INC(in_hit);
-			rcu_read_unlock();
-			skb->dst = (struct dst_entry*)rth;
-			return 0;
-		}
-		RT_CACHE_STAT_INC(in_hlist_search);
-	}
-
 	rcu_read_unlock();
 
 	/* Multicast recognition logic is moved from route cache to here.


Cheers.
						--ro
