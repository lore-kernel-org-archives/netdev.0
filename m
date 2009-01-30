From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/6] netfilter: abstract xt_counters
Date: Fri, 30 Jan 2009 13:57:04 -0800
Message-ID: <20090130215729.416851870@vyatta.com>
References: <20090130215700.965611970@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49659 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756970AbZA3V6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 16:58:00 -0500
Content-Disposition: inline; filename=xtables-counter.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Break out the parts of the x_tables code that manipulates counters so
changes to locking are easier.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/netfilter/x_tables.h |    6 +++++-
 net/ipv4/netfilter/arp_tables.c    |    9 +++++----
 net/ipv4/netfilter/ip_tables.c     |    9 +++++----
 net/ipv6/netfilter/ip6_tables.c    |   21 +++++++++++----------
 net/netfilter/x_tables.c           |   15 +++++++++++++++
 5 files changed, 41 insertions(+), 19 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-01-30 08:31:48.630454493 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-01-30 09:14:01.294680339 -0800
@@ -105,13 +105,17 @@ struct _xt_align
 #define XT_ERROR_TARGET "ERROR"
 
 #define SET_COUNTER(c,b,p) do { (c).bcnt = (b); (c).pcnt = (p); } while(0)
-#define ADD_COUNTER(c,b,p) do { (c).bcnt += (b); (c).pcnt += (p); } while(0)
 
 struct xt_counters
 {
 	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
 };
 
+extern void xt_add_counter(struct xt_counters *c, unsigned b, unsigned p);
+extern void xt_sum_counter(struct xt_counters *t,
+			   int cpu, const struct xt_counters *c);
+
+
 /* The argument to IPT_SO_ADD_COUNTERS. */
 struct xt_counters_info
 {
--- a/net/ipv4/netfilter/arp_tables.c	2009-01-30 08:31:48.569479503 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-01-30 09:12:40.181542286 -0800
@@ -256,7 +256,7 @@ unsigned int arpt_do_table(struct sk_buf
 
 			hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
 				(2 * skb->dev->addr_len);
-			ADD_COUNTER(e->counters, hdr_len, 1);
+			xt_add_counter(&e->counters, hdr_len, 1);
 
 			t = arpt_get_target(e);
 
@@ -662,10 +662,11 @@ static int translate_table(const char *n
 
 /* Gets counters. */
 static inline int add_entry_to_counter(const struct arpt_entry *e,
+				       int cpu,
 				       struct xt_counters total[],
 				       unsigned int *i)
 {
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+	xt_sum_counter(total, cpu, &e->counters);
 
 	(*i)++;
 	return 0;
@@ -709,6 +710,7 @@ static void get_counters(const struct xt
 		ARPT_ENTRY_ITERATE(t->entries[cpu],
 				   t->size,
 				   add_entry_to_counter,
+				   cpu,
 				   counters,
 				   &i);
 	}
@@ -1082,8 +1084,7 @@ static inline int add_counter_to_entry(s
 				       const struct xt_counters addme[],
 				       unsigned int *i)
 {
-
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
+	xt_add_counter(&e->counters, addme[*i].bcnt, addme[*i].pcnt);
 
 	(*i)++;
 	return 0;
--- a/net/ipv4/netfilter/ip_tables.c	2009-01-30 08:31:48.538730580 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-01-30 09:12:40.169542168 -0800
@@ -366,7 +366,7 @@ ipt_do_table(struct sk_buff *skb,
 			if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
 				goto no_match;
 
-			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
+			xt_add_counter(&e->counters, ntohs(ip->tot_len), 1);
 
 			t = ipt_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -872,10 +872,11 @@ translate_table(const char *name,
 /* Gets counters. */
 static inline int
 add_entry_to_counter(const struct ipt_entry *e,
+		     int cpu,
 		     struct xt_counters total[],
 		     unsigned int *i)
 {
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+	xt_sum_counter(total, cpu, &e->counters);
 
 	(*i)++;
 	return 0;
@@ -921,6 +922,7 @@ get_counters(const struct xt_table_info 
 		IPT_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
 				  add_entry_to_counter,
+				  cpu,
 				  counters,
 				  &i);
 	}
@@ -1327,8 +1329,7 @@ add_counter_to_entry(struct ipt_entry *e
 		 (long unsigned int)addme[*i].pcnt,
 		 (long unsigned int)addme[*i].bcnt);
 #endif
-
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
+	xt_add_counter(&e->counters, addme[*i].bcnt, addme[*i].pcnt);
 
 	(*i)++;
 	return 0;
--- a/net/ipv6/netfilter/ip6_tables.c	2009-01-30 08:31:48.605479850 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-01-30 09:12:40.205542065 -0800
@@ -392,9 +392,9 @@ ip6t_do_table(struct sk_buff *skb,
 			if (IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
 				goto no_match;
 
-			ADD_COUNTER(e->counters,
-				    ntohs(ipv6_hdr(skb)->payload_len) +
-				    sizeof(struct ipv6hdr), 1);
+			xt_add_counter(&e->counters,
+					ntohs(ipv6_hdr(skb)->payload_len) +
+					sizeof(struct ipv6hdr), 1);
 
 			t = ip6t_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -901,10 +901,11 @@ translate_table(const char *name,
 /* Gets counters. */
 static inline int
 add_entry_to_counter(const struct ip6t_entry *e,
+		     int cpu,
 		     struct xt_counters total[],
 		     unsigned int *i)
 {
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+	xt_sum_counter(total, cpu, &e->counters);
 
 	(*i)++;
 	return 0;
@@ -948,10 +949,11 @@ get_counters(const struct xt_table_info 
 			continue;
 		i = 0;
 		IP6T_ENTRY_ITERATE(t->entries[cpu],
-				  t->size,
-				  add_entry_to_counter,
-				  counters,
-				  &i);
+				   t->size,
+				   add_entry_to_counter,
+				   cpu,
+				   counters,
+				   &i);
 	}
 }
 
@@ -1357,8 +1359,7 @@ add_counter_to_entry(struct ip6t_entry *
 		 (long unsigned int)addme[*i].pcnt,
 		 (long unsigned int)addme[*i].bcnt);
 #endif
-
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
+	xt_add_counter(&e->counters, addme[*i].bcnt, addme[*i].pcnt);
 
 	(*i)++;
 	return 0;
--- a/net/netfilter/x_tables.c	2009-01-30 08:38:32.949293300 -0800
+++ b/net/netfilter/x_tables.c	2009-01-30 09:13:27.636792850 -0800
@@ -577,6 +577,21 @@ int xt_compat_target_to_user(struct xt_e
 EXPORT_SYMBOL_GPL(xt_compat_target_to_user);
 #endif
 
+void xt_add_counter(struct xt_counters *c, unsigned b, unsigned p)
+{
+	c->bcnt += b;
+	c->pcnt += p;
+}
+EXPORT_SYMBOL_GPL(xt_add_counter);
+
+void xt_sum_counter(struct xt_counters *t, int cpu,
+		    const struct xt_counters *c)
+{
+	t->pcnt += c->pcnt;
+	t->bcnt += c->bcnt;
+}
+EXPORT_SYMBOL_GPL(xt_sum_counter);
+
 struct xt_table_info *xt_alloc_table_info(unsigned int size)
 {
 	struct xt_table_info *newinfo;

-- 

