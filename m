From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Subject: [PATCH 2.6.0-test4][IPv6] ip6_flowlabel.c: timer cleanups
Date: 26 Aug 2003 19:54:41 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061907882.1108.28.camel@lima.royalchallenge.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Compiles fine though untested. A similar patch should be applicable to
2.4 also.

net/ipv6/ip6_flowlabel.c:
This patch does the following modifications to timer management:
1. use static timer initializer
2. replace del_timer/add_timer with mod_timer

--- linux-2.6.0-test4/net/ipv6/ip6_flowlabel.c	2003-07-15 17:23:45.000000000 +0530
+++ linux-2.6.0-test4-nvk/net/ipv6/ip6_flowlabel.c	2003-08-26 19:49:34.000000000 +0530
@@ -49,7 +49,8 @@
 static atomic_t fl_size = ATOMIC_INIT(0);
 static struct ip6_flowlabel *fl_ht[FL_HASH_MASK+1];
 
-static struct timer_list ip6_fl_gc_timer;
+static void ip6_fl_gc(unsigned long dummy);
+static struct timer_list ip6_fl_gc_timer = TIMER_INITIALIZER(ip6_fl_gc, 0, 0);
 
 /* FL hash table lock: it protects only of GC */
 
@@ -104,10 +105,9 @@
 			fl->opt = NULL;
 			kfree(opt);
 		}
-		if (!del_timer(&ip6_fl_gc_timer) ||
-		    (long)(ip6_fl_gc_timer.expires - ttd) > 0)
-			ip6_fl_gc_timer.expires = ttd;
-		add_timer(&ip6_fl_gc_timer);
+		if (!timer_pending(&ip6_fl_gc_timer) ||
+		    time_after(ip6_fl_gc_timer.expires, ttd))
+			mod_timer(&ip6_fl_gc_timer, ttd);
 	}
 }
 
@@ -692,10 +692,6 @@
 {
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *p;
-#endif
-	init_timer(&ip6_fl_gc_timer);
-	ip6_fl_gc_timer.function = ip6_fl_gc;
-#ifdef CONFIG_PROC_FS
 	p = create_proc_entry("ip6_flowlabel", S_IRUGO, proc_net);
 	if (p)
 		p->proc_fops = &ip6fl_seq_fops;
