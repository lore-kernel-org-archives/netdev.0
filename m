From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 01:56:48 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030609.015648.55736734.davem@redhat.com>
References: <20030608.225837.115923841.davem@redhat.com>
	<001801c32e50$57ef0750$4a00000a@badass>
	<20030609071330.GD20613@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xerox@foonet.net, hadi@shell.cyberus.ca, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org,
	Robert.Olsson@data.slu.se, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: sim@netnation.com
In-Reply-To: <20030609071330.GD20613@netnation.com>
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Mon, 9 Jun 2003 00:13:30 -0700

   On Mon, Jun 09, 2003 at 02:28:30AM -0400, CIT/Paul wrote:
   
   > I am willing to test out any code/patches and settings that you can
   > think of and post some results..
   
   I'll see if I can set up a test bed this week.  I think we should already
   be able to do close to this, but I'll let the numbers will do the
   talking. :)

BTW, ignoring juno, Robert Olsson has some pktgen hacks that allow
that to generate new-dst-per-packet DoS like traffic.  It's much
more effective than Juno-z

Robert could you should these guys your hacks to do that?

Next, here is an interesting first pass patch to try.  Once we hit
gc_thresh, at every new DST allocation we try to shrink the destination
hash chain.  It ought to be very effective in the presence of poorly
behaved traffic such as random-src-address DoS.

The patch is against 2.5.x current...

The next task is to try and handle rt_cache_flush more cheaply, given
Simon's mention that he gets from 10 to 20 BGP updates per minute.
Another idea to this dilemma is maybe to see if Zebra can batch things
a little bit... but that kind of solution might not be possible since I
don't know how that stuff works.

--- net/ipv4/route.c.~1~	Sun Jun  8 23:28:00 2003
+++ net/ipv4/route.c	Mon Jun  9 01:09:45 2003
@@ -882,6 +882,42 @@ static void rt_del(unsigned hash, struct
 	spin_unlock_bh(&rt_hash_table[hash].lock);
 }
 
+static void __rt_hash_shrink(unsigned int hash)
+{
+	struct rtable *rth, **rthp;
+	struct rtable *cand, **candp;
+	unsigned int min_use = ~(unsigned int) 0;
+
+	spin_lock_bh(&rt_hash_table[hash].lock);
+	cand = NULL;
+	candp = NULL;
+	rthp = &rt_hash_table[hash].chain;
+	while ((rth = *rthp) != NULL) {
+		if (!atomic_read(&rth->u.dst.__refcnt) &&
+		    ((unsigned int) rth->u.dst.__use) < min_use) {
+			cand = rth;
+			candp = rthp;
+			min_use = rth->u.dst.__use;
+		}
+		rthp = &rth->u.rt_next;
+	}
+	if (cand) {
+		*candp = cand->u.rt_next;
+		rt_free(cand);
+	}
+
+	spin_unlock_bh(&rt_hash_table[hash].lock);
+}
+
+static inline struct rtable *ip_rt_dst_alloc(unsigned int hash)
+{
+	if (atomic_read(&ipv4_dst_ops.entries) >
+	    ipv4_dst_ops.gc_thresh)
+		__rt_hash_shrink(hash);
+
+	return dst_alloc(&ipv4_dst_ops);
+}
+
 void ip_rt_redirect(u32 old_gw, u32 daddr, u32 new_gw,
 		    u32 saddr, u8 tos, struct net_device *dev)
 {
@@ -912,9 +948,10 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 
 	for (i = 0; i < 2; i++) {
 		for (k = 0; k < 2; k++) {
-			unsigned hash = rt_hash_code(daddr,
-						     skeys[i] ^ (ikeys[k] << 5),
-						     tos);
+			unsigned int hash = rt_hash_code(daddr,
+							 skeys[i] ^
+							 (ikeys[k] << 5),
+							 tos);
 
 			rthp=&rt_hash_table[hash].chain;
 
@@ -942,7 +979,7 @@ void ip_rt_redirect(u32 old_gw, u32 dadd
 				dst_hold(&rth->u.dst);
 				rcu_read_unlock();
 
-				rt = dst_alloc(&ipv4_dst_ops);
+				rt = ip_rt_dst_alloc(hash);
 				if (rt == NULL) {
 					ip_rt_put(rth);
 					in_dev_put(in_dev);
@@ -1352,7 +1389,7 @@ static void rt_set_nexthop(struct rtable
 static int ip_route_input_mc(struct sk_buff *skb, u32 daddr, u32 saddr,
 				u8 tos, struct net_device *dev, int our)
 {
-	unsigned hash;
+	unsigned int hash;
 	struct rtable *rth;
 	u32 spec_dst;
 	struct in_device *in_dev = in_dev_get(dev);
@@ -1375,7 +1412,9 @@ static int ip_route_input_mc(struct sk_b
 					dev, &spec_dst, &itag) < 0)
 		goto e_inval;
 
-	rth = dst_alloc(&ipv4_dst_ops);
+	hash = rt_hash_code(daddr, saddr ^ (dev->ifindex << 5), tos);
+
+	rth = ip_rt_dst_alloc(hash);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1421,7 +1460,6 @@ static int ip_route_input_mc(struct sk_b
 	RT_CACHE_STAT_INC(in_slow_mc);
 
 	in_dev_put(in_dev);
-	hash = rt_hash_code(daddr, saddr ^ (dev->ifindex << 5), tos);
 	return rt_intern_hash(hash, rth, (struct rtable**) &skb->dst);
 
 e_nobufs:
@@ -1584,7 +1622,7 @@ int ip_route_input_slow(struct sk_buff *
 			goto e_inval;
 	}
 
-	rth = dst_alloc(&ipv4_dst_ops);
+	rth = ip_rt_dst_alloc(hash);
 	if (!rth)
 		goto e_nobufs;
 
@@ -1663,7 +1701,7 @@ brd_input:
 	RT_CACHE_STAT_INC(in_brd);
 
 local_input:
-	rth = dst_alloc(&ipv4_dst_ops);
+	rth = ip_rt_dst_alloc(hash);
 	if (!rth)
 		goto e_nobufs;
 
@@ -2048,7 +2086,10 @@ make_route:
 		}
 	}
 
-	rth = dst_alloc(&ipv4_dst_ops);
+	hash = rt_hash_code(oldflp->fl4_dst,
+			    oldflp->fl4_src ^ (oldflp->oif << 5), tos);
+
+	rth = ip_rt_dst_alloc(hash);
 	if (!rth)
 		goto e_nobufs;
 
@@ -2107,7 +2148,6 @@ make_route:
 
 	rth->rt_flags = flags;
 
-	hash = rt_hash_code(oldflp->fl4_dst, oldflp->fl4_src ^ (oldflp->oif << 5), tos);
 	err = rt_intern_hash(hash, rth, rp);
 done:
 	if (free_res)

