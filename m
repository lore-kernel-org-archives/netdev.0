From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/6] netfilter: use sequence number synchronization for counters
Date: Thu, 29 Jan 2009 11:12:44 -0800
Message-ID: <20090129191520.531815152@vyatta.com>
References: <20090129191239.483204605@vyatta.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=counters-seqcount.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change how synchronization is done on the iptables counters. Use seqcount
wrapper instead of depending on reader/writer lock.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/netfilter/x_tables.h |   14 +++-----------
 net/ipv4/netfilter/arp_tables.c    |    4 ++--
 net/ipv4/netfilter/ip_tables.c     |    4 ++--
 net/ipv6/netfilter/ip6_tables.c    |    4 ++--
 net/netfilter/x_tables.c           |   28 ++++++++++++++++++++++++++++
 5 files changed, 37 insertions(+), 17 deletions(-)
4
--- a/net/ipv4/netfilter/arp_tables.c	2009-01-29 11:08:38.735069921 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-01-29 11:09:20.720069979 -0800
@@ -736,9 +736,9 @@ static inline struct xt_counters *alloc_
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
--- a/net/ipv4/netfilter/ip_tables.c	2009-01-29 11:08:38.723069778 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-01-29 11:09:20.720069979 -0800
@@ -947,9 +947,9 @@ static struct xt_counters * alloc_counte
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
--- a/net/ipv6/netfilter/ip6_tables.c	2009-01-29 11:08:38.763071181 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-01-29 11:09:20.724069866 -0800
@@ -976,9 +976,9 @@ static struct xt_counters *alloc_counter
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
--- a/net/netfilter/x_tables.c	2009-01-29 11:08:38.747070716 -0800
+++ b/net/netfilter/x_tables.c	2009-01-29 11:10:03.595571234 -0800
@@ -577,6 +577,34 @@ int xt_compat_target_to_user(struct xt_e
 EXPORT_SYMBOL_GPL(xt_compat_target_to_user);
 #endif
 
+static DEFINE_PER_CPU(seqcount_t, xt_counter_sequence);
+
+void xt_fetch_counter(struct xt_counters *v, int cpu,
+		      const struct xt_counters *c)
+{
+	seqcount_t *seq = &per_cpu(xt_counter_sequence, cpu);
+	unsigned start;
+
+	do {
+		start = read_seqcount_begin(seq);
+		*v = *c;
+	} while (read_seqcount_retry(seq, start));
+}
+EXPORT_SYMBOL_GPL(xt_fetch_counter);
+
+void xt_incr_counter(struct xt_counters *c, unsigned b, unsigned p)
+{
+	seqcount_t *seq = &__get_cpu_var(xt_counter_sequence);
+
+	write_seqcount_begin(seq);
+	c->pcnt += p;
+	c->bcnt += b;
+	write_seqcount_end(seq);
+
+}
+EXPORT_SYMBOL_GPL(xt_incr_counter);
+
+
 struct xt_table_info *xt_alloc_table_info(unsigned int size)
 {
 	struct xt_table_info *newinfo;
--- a/include/linux/netfilter/x_tables.h	2009-01-29 11:08:38.779071484 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-01-29 11:09:20.724069866 -0800
@@ -112,17 +112,9 @@ struct xt_counters
 	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
 };
 
-static inline void xt_fetch_counter(struct xt_counters *v, int cpu,
-				    const struct xt_counters *c)
-{
-	*v = *c;
-}
-
-static inline void xt_incr_counter(struct xt_counters *c, unsigned b, unsigned p)
-{
-	c->pcnt += p;
-	c->bcnt += b;
-}
+extern void xt_fetch_counter(struct xt_counters *v, int cpu,
+			     const struct xt_counters *c);
+extern void xt_incr_counter(struct xt_counters *c, unsigned b, unsigned p);
 
 
 /* The argument to IPT_SO_ADD_COUNTERS. */

-- 

