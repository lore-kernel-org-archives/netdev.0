From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 00:54:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16101.4136.328760.955758@robur.slu.se>
References: <20030609082718.GG20613@netnation.com>
	<004f01c32ebe$b4bd88d0$4a00000a@badass>
	<20030609221911.GF11509@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: CIT/Paul <xerox@foonet.net>, "'David S. Miller'" <davem@redhat.com>,
   hadi@shell.cyberus.ca, fw@deneb.enyo.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030609221911.GF11509@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Simon Kirby writes:

 > [sroot@r2:/root]# rtstat -i 1
 >  size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc
 > 870721946     16394    1013     8     4     4     0     0        38      12      0
 > 870722937     16278    1007     8     0    10     0     0        32       6      0

 > ...Hmm, the size is a bit off there.  I'm not sure what that's all about. 

 Seems you have an older version of rtstat. There are stats for the GC process there 
 too.

 You can get recent rtstat from:
 robur.slu.se:/pub/Linux/net-development/rt_cache_stat/rtstat.c

 
 I'm about to propose some stats even for hash spinning.... 

 
--- linux/include/net/route.h.orig      2003-03-24 22:59:53.000000000 +0100
+++ linux/include/net/route.h   2003-05-16 11:04:07.000000000 +0200
@@ -102,6 +102,8 @@
         unsigned int gc_ignored;
         unsigned int gc_goal_miss;
         unsigned int gc_dst_overflow;
+        unsigned int in_hlist_search;
+        unsigned int out_hlist_search;
 };
 
 extern struct rt_cache_stat *rt_cache_stat;
--- linux/net/ipv4/route.c.orig 2003-03-24 23:01:48.000000000 +0100
+++ linux/net/ipv4/route.c      2003-05-16 11:18:54.000000000 +0200
@@ -321,7 +321,7 @@
        for (i = 0; i < NR_CPUS; i++) {
                if (!cpu_possible(i))
                        continue;
-               len += sprintf(buffer+len, "%08x  %08x %08x %08x %08x %08x %08x %08x  %08x %08x %08x %08x %08x %08x %08x \n",
+               len += sprintf(buffer+len, "%08x  %08x %08x %08x %08x %08x %08x %08x  %08x %08x %08x %08x %08x %08x %08x %08x %08x \n",
                               dst_entries,                    
                               per_cpu_ptr(rt_cache_stat, i)->in_hit,
                               per_cpu_ptr(rt_cache_stat, i)->in_slow_tot,
@@ -338,7 +338,9 @@
                               per_cpu_ptr(rt_cache_stat, i)->gc_total,
                               per_cpu_ptr(rt_cache_stat, i)->gc_ignored,
                               per_cpu_ptr(rt_cache_stat, i)->gc_goal_miss,
-                              per_cpu_ptr(rt_cache_stat, i)->gc_dst_overflow
+                              per_cpu_ptr(rt_cache_stat, i)->gc_dst_overflow,
+                              per_cpu_ptr(rt_cache_stat, i)->in_hlist_search,
+                              per_cpu_ptr(rt_cache_stat, i)->out_hlist_search
 
                        );
        }
@@ -1771,6 +1773,7 @@
                        skb->dst = (struct dst_entry*)rth;
                        return 0;
                }
+               RT_CACHE_STAT_INC(in_hlist_search);
        }
        rcu_read_unlock();
 
@@ -2137,6 +2140,7 @@
                        *rp = rth;
                        return 0;
                }
+               RT_CACHE_STAT_INC(out_hlist_search);
        }
        rcu_read_unlock();


Cheers.
						--ro
