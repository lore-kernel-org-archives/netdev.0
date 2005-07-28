From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] Add prefetches in net/ipv4/route.c
Date: Thu, 28 Jul 2005 17:52:04 +0200
Message-ID: <42E8FF24.9070009@cosmosbay.com>
References: <20050704.154712.63128211.davem@davemloft.net>	<42C9BE69.2070008@cosmosbay.com>	<42C9BEF6.4080402@cosmosbay.com> <20050704.160140.21591849.davem@davemloft.net> <42CA390C.9000801@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060607040500090607010609"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <42CA390C.9000801@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060607040500090607010609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

[NET] : Adds prefetches in route hash list traversals.

The actual code doesnt use a prefetch enabled macro like list_for_each_rcu(), so manually
add prefetch() hints.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------060607040500090607010609
Content-Type: text/plain;
 name="route.prefetches"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="route.prefetches"

diff -Nru linux-2.6.13-rc3/net/ipv4/route.c linux-2.6.13-rc3-ed/net/ipv4/route.c
--- linux-2.6.13-rc3/net/ipv4/route.c	2005-07-13 06:46:46.000000000 +0200
+++ linux-2.6.13-rc3-ed/net/ipv4/route.c	2005-07-28 17:20:21.000000000 +0200
@@ -1148,6 +1148,7 @@
 			while ((rth = rcu_dereference(*rthp)) != NULL) {
 				struct rtable *rt;
 
+				prefetch(rth->u.rt_next);
 				if (rth->fl.fl4_dst != daddr ||
 				    rth->fl.fl4_src != skeys[i] ||
 				    rth->fl.fl4_tos != tos ||
@@ -1401,6 +1402,7 @@
 		rcu_read_lock();
 		for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
 		     rth = rcu_dereference(rth->u.rt_next)) {
+			prefetch(rth->u.rt_next);
 			if (rth->fl.fl4_dst == daddr &&
 			    rth->fl.fl4_src == skeys[i] &&
 			    rth->rt_dst  == daddr &&
@@ -2094,6 +2096,7 @@
 	rcu_read_lock();
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
 	     rth = rcu_dereference(rth->u.rt_next)) {
+		prefetch(rth->u.rt_next);
 		if (rth->fl.fl4_dst == daddr &&
 		    rth->fl.fl4_src == saddr &&
 		    rth->fl.iif == iif &&
@@ -2565,6 +2568,7 @@
 	rcu_read_lock_bh();
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
 		rth = rcu_dereference(rth->u.rt_next)) {
+		prefetch(rth->u.rt_next);
 		if (rth->fl.fl4_dst == flp->fl4_dst &&
 		    rth->fl.fl4_src == flp->fl4_src &&
 		    rth->fl.iif == 0 &&
@@ -2819,6 +2823,7 @@
 		rcu_read_lock_bh();
 		for (rt = rcu_dereference(rt_hash_table[h].chain), idx = 0; rt;
 		     rt = rcu_dereference(rt->u.rt_next), idx++) {
+			prefetch(rt->u.rt_next);
 			if (idx < s_idx)
 				continue;
 			skb->dst = dst_clone(&rt->u.dst);

--------------060607040500090607010609--
