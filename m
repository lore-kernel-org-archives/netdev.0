From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: [PATCH resend] zero rt_cache_stat statistics at init
Date: 18 Feb 2003 16:17:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1045581465.18515.139.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm running 2.5.58-mm1 with slab-debugging enabled and noticed this in
/proc/net/rt_cache_stat (long line):

000000ae  5b61f6cf 5ab13072 5a5a5a5a 5a5a5a5a 5a5d0c9a 5a5a5a7f 5a5a5aa6  5a61e025 5a5a961a 5a5a5aea 5a5a5a5a 5a5a5a5a 5a5a5a5a 5a5a5a5a

Here's a patch against 2.5.58(-mm1) to memset() it at init, I believe
this was missed when it was converted to percpu.
It also includes a whitespace change to conform to the other sizeof's in
ip_rt_init():

--- linux-2.5.58/net/ipv4/route.c.orig	2003-02-14 16:07:46.000000000 +0100
+++ linux-2.5.58/net/ipv4/route.c	2003-02-14 16:43:11.000000000 +0100
@@ -2652,11 +2652,18 @@
 	ipv4_dst_ops.gc_thresh = (rt_hash_mask + 1);
 	ip_rt_max_size = (rt_hash_mask + 1) * 16;
 
-	rt_cache_stat = kmalloc_percpu(sizeof (struct rt_cache_stat),
+	rt_cache_stat = kmalloc_percpu(sizeof(struct rt_cache_stat),
 					GFP_KERNEL);
 	if (!rt_cache_stat) 
 		goto out_enomem1;
 
+	for (i = 0; i < NR_CPUS; i++) {
+		if (!cpu_possible(i))
+			continue;
+		memset(per_cpu_ptr(rt_cache_stat, i), 0,
+		       sizeof(struct rt_cache_stat));
+	}
+
 	devinet_init();
 	ip_fib_init();
 

-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat you with experience.
