From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] repairing rtcache killer
Date: Wed, 6 Aug 2003 19:23:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16177.14760.612648.582063@robur.slu.se>
References: <200308051340.RAA28267@dub.inr.ac.ru>
	<16175.58503.134543.310459@robur.slu.se>
	<20030806005224.4798f744.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030806005224.4798f744.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


David S. Miller writes:


 > To make algorithm cheaper, we can even use only the current
 > cpu's rt_cache_stat in order to make our decisions about whether
 > to enter agressive mode or not.

 We get into complex senarios... we risk that not all CPU see "attacks" 
 so they still contribute to the hash chain and spinning. We can run the
 chain length calculation at interval as alternative.

 One starts dreaming of having a route hash per cpu to avoid cache bouncing 
 in the hash lookup. :-) Well not all cache bouncing well dissapear  
 (read DoS) but as nowadays there is "more" affinity on input due to NAPI  
 and scheduler etc. 

 Somewhat reworked code:

--- include/net/route.h.orig	2003-07-14 05:28:54.000000000 +0200
+++ include/net/route.h	2003-08-06 18:27:52.000000000 +0200
@@ -89,7 +89,9 @@
 struct rt_cache_stat 
 {
         unsigned int in_hit;
+        unsigned int in_hit_last;
         unsigned int in_slow_tot;
+        unsigned int in_slow_tot_last;
         unsigned int in_slow_mc;
         unsigned int in_no_route;
         unsigned int in_brd;
--- net/ipv4/route.c.ank-repair-hash	2003-08-06 16:27:19.000000000 +0200
+++ net/ipv4/route.c	2003-08-06 17:53:43.000000000 +0200
@@ -118,6 +118,8 @@
 int ip_rt_error_cost		= HZ;
 int ip_rt_error_burst		= 5 * HZ;
 int ip_rt_gc_elasticity		= 8;
+int ip_rt_gc_elasticity2	= 2 * 8;
+int ip_rt_gc_elasticity2_recalc = 0;
 int ip_rt_mtu_expires		= 10 * 60 * HZ;
 int ip_rt_min_pmtu		= 512 + 20 + 20;
 int ip_rt_min_advmss		= 256;
@@ -747,6 +749,40 @@
 	int		chain_length;
 	int attempts = !in_softirq();
 
+
+	if (! (ip_rt_gc_elasticity2_recalc++ % 200 )) {
+		unsigned in_hit = 0, in_slow_tot = 0;
+		int i;
+
+		for (i = 0; i < NR_CPUS; i++) {
+			if (!cpu_possible(i))
+				continue;
+			
+			in_hit += per_cpu_ptr(rt_cache_stat, i)->in_hit -
+				per_cpu_ptr(rt_cache_stat, i)->in_hit_last;
+
+			per_cpu_ptr(rt_cache_stat, i)->in_hit_last = 
+				per_cpu_ptr(rt_cache_stat, i)->in_hit;
+			
+			in_slow_tot += per_cpu_ptr(rt_cache_stat, i)->in_slow_tot -
+				per_cpu_ptr(rt_cache_stat, i)->in_slow_tot_last;
+
+			per_cpu_ptr(rt_cache_stat, i)->in_slow_tot_last = 
+				per_cpu_ptr(rt_cache_stat, i)->in_slow_tot;
+			
+		}
+
+		if (in_hit < in_slow_tot) {
+			/* Aggressive  */
+			if(ip_rt_gc_elasticity2 > 1) 
+				ip_rt_gc_elasticity2 >>= 1;
+		}
+		else 
+			if(ip_rt_gc_elasticity2 < 2*ip_rt_gc_elasticity) {
+				ip_rt_gc_elasticity2 <<= 1;
+			}
+	}
+					
 restart:
 	chain_length = 0;
 	min_score = ~(u32)0;
@@ -801,13 +837,10 @@
 	}
 
 	if (cand) {
-		/* ip_rt_gc_elasticity used to be average length of chain
-		 * length, when exceeded gc becomes really aggressive.
-		 *
-		 * The second limit is less certain. At the moment it allows
-		 * only 2 entries per bucket. We will see.
+		/* ip_rt_gc_elasticity2 used to limit length of chain
+		 * when exceeded gc becomes really aggressive.
 		 */
-		if (chain_length > 2*ip_rt_gc_elasticity) {
+		if (chain_length > ip_rt_gc_elasticity2) {
 			*candp = cand->u.rt_next;
 			rt_free(cand);
 		}


Cheers.
						--ro
