From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance tests
Date: Mon, 16 Jun 2003 15:44:01 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.154401.132900800.davem@redhat.com>
References: <20030610075732.GD23009@netnation.com>
	<20030612.232002.41633789.davem@redhat.com>
	<20030616223714.GB18484@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralph+d@istop.com, hadi@shell.cyberus.ca, xerox@foonet.net,
   fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: sim@netnation.com
In-Reply-To: <20030616223714.GB18484@netnation.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Mon, 16 Jun 2003 15:37:14 -0700

   So, which kernels shall I try?  When I set the thing up I was using
   2.5.70-bk14, but I am compiling 2.5.71, and I will try with your patch
   above and with Alexey's.

Thanks for your profiles.

I pushed all of our current work to Linus's tree.
But for your convenience here are the routing diffs
against plain 2.5.71

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1318.1.15 -> 1.1318.1.16
#	    net/ipv4/route.c	1.63    -> 1.64   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/16	kuznet@ms2.inr.ac.ru	1.1318.1.16
# [IPV4]: More sane rtcache behavior.
# 1) More reasonable ip_rt_gc_min_interval default
# 2) Trim less valuable entries in hash chain during
#    rt_intern_hash when such chains grow too long.
# --------------------------------------------
#
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Mon Jun 16 15:45:20 2003
+++ b/net/ipv4/route.c	Mon Jun 16 15:45:20 2003
@@ -111,7 +111,7 @@
 int ip_rt_max_size;
 int ip_rt_gc_timeout		= RT_GC_TIMEOUT;
 int ip_rt_gc_interval		= 60 * HZ;
-int ip_rt_gc_min_interval	= 5 * HZ;
+int ip_rt_gc_min_interval	= HZ / 2;
 int ip_rt_redirect_number	= 9;
 int ip_rt_redirect_load		= HZ / 50;
 int ip_rt_redirect_silence	= ((HZ / 50) << (9 + 1));
@@ -456,6 +456,25 @@
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
+	if (!rt->fl.iif ||
+	    !(rt->rt_flags & (RTCF_BROADCAST|RTCF_MULTICAST|RTCF_LOCAL)))
+		score |= (1<<30);
+
+	return score;
+}
+
 /* This runs via a timer and thus is always in BH context. */
 static void rt_check_expire(unsigned long dummy)
 {
@@ -721,6 +740,9 @@
 {
 	struct rtable	*rth, **rthp;
 	unsigned long	now = jiffies;
+	struct rtable *cand = NULL, **candp = NULL;
+	u32 		min_score = ~(u32)0;
+	int		chain_length = 0;
 	int attempts = !in_softirq();
 
 restart:
@@ -755,7 +777,33 @@
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
+	}
+
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
 	}
 
 	/* Try to bind route to arp only if it is output
# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1320.1.1 -> 1.1320.1.2
#	    net/ipv4/route.c	1.64    -> 1.65   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/06/16	robert.olsson@data.slu.se	1.1320.1.2
# [IPV4]: In rt_intern_hash, reinit all state vars on branch to "restart".
# --------------------------------------------
#
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Mon Jun 16 15:46:05 2003
+++ b/net/ipv4/route.c	Mon Jun 16 15:46:05 2003
@@ -739,13 +739,19 @@
 static int rt_intern_hash(unsigned hash, struct rtable *rt, struct rtable **rp)
 {
 	struct rtable	*rth, **rthp;
-	unsigned long	now = jiffies;
-	struct rtable *cand = NULL, **candp = NULL;
-	u32 		min_score = ~(u32)0;
-	int		chain_length = 0;
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
 
 	spin_lock_bh(&rt_hash_table[hash].lock);
