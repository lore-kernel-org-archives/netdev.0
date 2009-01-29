From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/6] netfilter: abstract xt_counters
Date: Thu, 29 Jan 2009 11:12:43 -0800
Message-ID: <20090129191520.400170603@vyatta.com>
References: <20090129191239.483204605@vyatta.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=xtables-counter.patch
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Break out the parts of the x_tables code that manipulates counters so
changes to locking are easier.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/netfilter/x_tables.h |   15 ++++++++++++++-
 net/ipv4/netfilter/arp_tables.c    |   12 ++++++++----
 net/ipv4/netfilter/ip_tables.c     |   12 ++++++++----
 net/ipv6/netfilter/ip6_tables.c    |   24 ++++++++++++++----------
 4 files changed, 44 insertions(+), 19 deletions(-)

--- a/include/linux/netfilter/x_tables.h	2009-01-29 09:45:14.475070733 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-01-29 10:51:50.194362708 -0800
@@ -105,13 +105,26 @@ struct _xt_align
 #define XT_ERROR_TARGET "ERROR"
 
 #define SET_COUNTER(c,b,p) do { (c).bcnt = (b); (c).pcnt = (p); } while(0)
-#define ADD_COUNTER(c,b,p) do { (c).bcnt += (b); (c).pcnt += (p); } while(0)
+#define SUM_COUNTER(s,c)  do { (s).bcnt += (c).bcnt; (s).pcnt += (c).pcnt; } while(0)
 
 struct xt_counters
 {
 	u_int64_t pcnt, bcnt;			/* Packet and byte counters */
 };
 
+static inline void xt_fetch_counter(struct xt_counters *v, int cpu,
+				    const struct xt_counters *c)
+{
+	*v = *c;
+}
+
+static inline void xt_incr_counter(struct xt_counters *c, unsigned b, unsigned p)
+{
+	c->pcnt += p;
+	c->bcnt += b;
+}
+
+
 /* The argument to IPT_SO_ADD_COUNTERS. */
 struct xt_counters_info
 {
--- a/net/ipv4/netfilter/arp_tables.c	2009-01-29 09:52:23.172320248 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-01-29 10:53:13.152543484 -0800
@@ -256,7 +256,7 @@ unsigned int arpt_do_table(struct sk_buf
 
 			hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
 				(2 * skb->dev->addr_len);
-			ADD_COUNTER(e->counters, hdr_len, 1);
+			xt_incr_counter(&e->counters, hdr_len, 1);
 
 			t = arpt_get_target(e);
 
@@ -662,10 +662,14 @@ static int translate_table(const char *n
 
 /* Gets counters. */
 static inline int add_entry_to_counter(const struct arpt_entry *e,
+				       int cpu,
 				       struct xt_counters total[],
 				       unsigned int *i)
 {
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+	struct xt_counters c;
+
+	xt_fetch_counter(&c, cpu, &e->counters);
+	SUM_COUNTER(total[*i], c);
 
 	(*i)++;
 	return 0;
@@ -709,6 +713,7 @@ static void get_counters(const struct xt
 		ARPT_ENTRY_ITERATE(t->entries[cpu],
 				   t->size,
 				   add_entry_to_counter,
+				   cpu,
 				   counters,
 				   &i);
 	}
@@ -1082,8 +1087,7 @@ static inline int add_counter_to_entry(s
 				       const struct xt_counters addme[],
 				       unsigned int *i)
 {
-
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
+	SUM_COUNTER(e->counters, addme[*i]);
 
 	(*i)++;
 	return 0;
--- a/net/ipv4/netfilter/ip_tables.c	2009-01-29 09:52:23.200320370 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-01-29 10:52:43.235570700 -0800
@@ -366,7 +366,7 @@ ipt_do_table(struct sk_buff *skb,
 			if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
 				goto no_match;
 
-			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
+			xt_incr_counter(&e->counters, ntohs(ip->tot_len), 1);
 
 			t = ipt_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -872,10 +872,14 @@ translate_table(const char *name,
 /* Gets counters. */
 static inline int
 add_entry_to_counter(const struct ipt_entry *e,
+		     int cpu,
 		     struct xt_counters total[],
 		     unsigned int *i)
 {
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+	struct xt_counters c;
+
+	xt_fetch_counter(&c, cpu, &e->counters);
+	SUM_COUNTER(total[*i], c);
 
 	(*i)++;
 	return 0;
@@ -921,6 +925,7 @@ get_counters(const struct xt_table_info 
 		IPT_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
 				  add_entry_to_counter,
+				  cpu,
 				  counters,
 				  &i);
 	}
@@ -1327,8 +1332,7 @@ add_counter_to_entry(struct ipt_entry *e
 		 (long unsigned int)addme[*i].pcnt,
 		 (long unsigned int)addme[*i].bcnt);
 #endif
-
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
+	SUM_COUNTER(e->counters, addme[*i]);
 
 	(*i)++;
 	return 0;
--- a/net/ipv6/netfilter/ip6_tables.c	2009-01-29 09:52:26.618819778 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-01-29 10:53:06.240695087 -0800
@@ -392,9 +392,9 @@ ip6t_do_table(struct sk_buff *skb,
 			if (IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
 				goto no_match;
 
-			ADD_COUNTER(e->counters,
-				    ntohs(ipv6_hdr(skb)->payload_len) +
-				    sizeof(struct ipv6hdr), 1);
+			xt_incr_counter(&e->counters,
+					ntohs(ipv6_hdr(skb)->payload_len) +
+					sizeof(struct ipv6hdr), 1);
 
 			t = ip6t_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -901,10 +901,14 @@ translate_table(const char *name,
 /* Gets counters. */
 static inline int
 add_entry_to_counter(const struct ip6t_entry *e,
+		     int cpu,
 		     struct xt_counters total[],
 		     unsigned int *i)
 {
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+	struct xt_counters c;
+
+	xt_fetch_counter(&c, cpu, &e->counters);
+	SUM_COUNTER(total[*i], c);
 
 	(*i)++;
 	return 0;
@@ -948,10 +952,11 @@ get_counters(const struct xt_table_info 
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
 
@@ -1357,8 +1362,7 @@ add_counter_to_entry(struct ip6t_entry *
 		 (long unsigned int)addme[*i].pcnt,
 		 (long unsigned int)addme[*i].bcnt);
 #endif
-
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
+	SUM_COUNTER(e->counters, addme[*i]);
 
 	(*i)++;
 	return 0;

-- 

