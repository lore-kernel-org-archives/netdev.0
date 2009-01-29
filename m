From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/5] netfilter: use sequence number synchronization for counters
Date: Wed, 28 Jan 2009 22:25:25 -0800
Message-ID: <20090129062549.234454895@vyatta.com>
References: <20090129062521.092861272@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:59982 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751851AbZA2G1U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 01:27:20 -0500
Content-Disposition: inline; filename=counters-seqcount.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change how synchronization is done on the iptables counters. Use seqcount
wrapper instead of depending on reader/writer lock.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/netfilter/x_tables.h |    3 +++
 net/ipv4/netfilter/arp_tables.c    |   24 +++++++++++++++++++-----
 net/ipv4/netfilter/ip_tables.c     |   24 +++++++++++++++++++-----
 net/ipv6/netfilter/ip6_tables.c    |   32 +++++++++++++++++++++++---------
 net/netfilter/x_tables.c           |   11 +++++++++++
 5 files changed, 75 insertions(+), 19 deletions(-)
4
--- a/net/ipv4/netfilter/arp_tables.c	2009-01-28 21:24:39.223991934 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-01-28 22:13:16.423490077 -0800
@@ -230,6 +230,7 @@ unsigned int arpt_do_table(struct sk_buf
 	void *table_base;
 	const struct xt_table_info *private;
 	struct xt_target_param tgpar;
+	seqcount_t *seq;
 
 	if (!pskb_may_pull(skb, arp_hdr_len(skb->dev)))
 		return NF_DROP;
@@ -240,6 +241,7 @@ unsigned int arpt_do_table(struct sk_buf
 	read_lock_bh(&table->lock);
 	private = table->private;
 	table_base = (void *)private->entries[smp_processor_id()];
+	seq = per_cpu_ptr(private->seq, smp_processor_id());
 	e = get_entry(table_base, private->hook_entry[hook]);
 	back = get_entry(table_base, private->underflow[hook]);
 
@@ -256,7 +258,9 @@ unsigned int arpt_do_table(struct sk_buf
 
 			hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
 				(2 * skb->dev->addr_len);
+			write_seqcount_begin(seq);
 			ADD_COUNTER(e->counters, hdr_len, 1);
+			write_seqcount_end(seq);
 
 			t = arpt_get_target(e);
 
@@ -662,10 +666,20 @@ static int translate_table(const char *n
 
 /* Gets counters. */
 static inline int add_entry_to_counter(const struct arpt_entry *e,
+				       seqcount_t *seq,
 				       struct xt_counters total[],
 				       unsigned int *i)
 {
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+	struct xt_counters count;
+	unsigned int start;
+
+	/* Atomic fetch */
+	do {
+		start = read_seqcount_begin(seq);
+		count = e->counters;
+	} while (read_seqcount_retry(seq, start));
+
+	ADD_COUNTER(total[*i], count.bcnt, count.pcnt);
 
 	(*i)++;
 	return 0;
@@ -709,6 +723,7 @@ static void get_counters(const struct xt
 		ARPT_ENTRY_ITERATE(t->entries[cpu],
 				   t->size,
 				   add_entry_to_counter,
+				   per_cpu_ptr(t->seq, cpu),
 				   counters,
 				   &i);
 	}
@@ -731,9 +746,9 @@ static inline struct xt_counters *alloc_
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
@@ -1736,8 +1751,7 @@ struct xt_table *arpt_register_table(str
 {
 	int ret;
 	struct xt_table_info *newinfo;
-	struct xt_table_info bootstrap
-		= { 0, 0, 0, { 0 }, { 0 }, { } };
+	struct xt_table_info bootstrap = { 0 };
 	void *loc_cpu_entry;
 	struct xt_table *new_table;
 
--- a/net/ipv4/netfilter/ip_tables.c	2009-01-28 21:24:39.211990658 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-01-28 22:06:10.596739805 -0800
@@ -327,6 +327,7 @@ ipt_do_table(struct sk_buff *skb,
 	struct xt_table_info *private;
 	struct xt_match_param mtpar;
 	struct xt_target_param tgpar;
+	seqcount_t *seq;
 
 	/* Initialization */
 	ip = ip_hdr(skb);
@@ -351,6 +352,7 @@ ipt_do_table(struct sk_buff *skb,
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 	private = table->private;
 	table_base = (void *)private->entries[smp_processor_id()];
+	seq = per_cpu_ptr(private->seq, smp_processor_id());
 	e = get_entry(table_base, private->hook_entry[hook]);
 
 	/* For return from builtin chain */
@@ -366,7 +368,9 @@ ipt_do_table(struct sk_buff *skb,
 			if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
 				goto no_match;
 
+			write_seqcount_begin(seq);
 			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
+			write_seqcount_end(seq);
 
 			t = ipt_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -872,10 +876,20 @@ translate_table(const char *name,
 /* Gets counters. */
 static inline int
 add_entry_to_counter(const struct ipt_entry *e,
+		     seqcount_t *seq,
 		     struct xt_counters total[],
 		     unsigned int *i)
 {
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
+	struct xt_counters count;
+	unsigned int start;
+
+	/* Atomic fetch */
+	do {
+		start = read_seqcount_begin(seq);
+		count = e->counters;
+	} while (read_seqcount_retry(seq, start));
+
+	ADD_COUNTER(total[*i], count.bcnt, count.pcnt);
 
 	(*i)++;
 	return 0;
@@ -921,6 +935,7 @@ get_counters(const struct xt_table_info 
 		IPT_ENTRY_ITERATE(t->entries[cpu],
 				  t->size,
 				  add_entry_to_counter,
+				  per_cpu_ptr(t->seq, cpu),
 				  counters,
 				  &i);
 	}
@@ -942,9 +957,9 @@ static struct xt_counters * alloc_counte
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
@@ -2064,8 +2079,7 @@ struct xt_table *ipt_register_table(stru
 {
 	int ret;
 	struct xt_table_info *newinfo;
-	struct xt_table_info bootstrap
-		= { 0, 0, 0, { 0 }, { 0 }, { } };
+	struct xt_table_info bootstrap = { 0 };
 	void *loc_cpu_entry;
 	struct xt_table *new_table;
 
--- a/net/ipv6/netfilter/ip6_tables.c	2009-01-28 21:24:39.243992135 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-01-28 22:13:16.419490741 -0800
@@ -357,6 +357,7 @@ ip6t_do_table(struct sk_buff *skb,
 	struct xt_table_info *private;
 	struct xt_match_param mtpar;
 	struct xt_target_param tgpar;
+	seqcount_t *seq;
 
 	/* Initialization */
 	indev = in ? in->name : nulldevname;
@@ -377,6 +378,7 @@ ip6t_do_table(struct sk_buff *skb,
 	IP_NF_ASSERT(table->valid_hooks & (1 << hook));
 	private = table->private;
 	table_base = (void *)private->entries[smp_processor_id()];
+	seq = per_cpu_ptr(private->seq, smp_processor_id());
 	e = get_entry(table_base, private->hook_entry[hook]);
 
 	/* For return from builtin chain */
@@ -392,9 +394,11 @@ ip6t_do_table(struct sk_buff *skb,
 			if (IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
 				goto no_match;
 
+			write_seqcount_begin(seq);
 			ADD_COUNTER(e->counters,
 				    ntohs(ipv6_hdr(skb)->payload_len) +
 				    sizeof(struct ipv6hdr), 1);
+			write_seqcount_end(seq);
 
 			t = ip6t_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -901,11 +905,21 @@ translate_table(const char *name,
 /* Gets counters. */
 static inline int
 add_entry_to_counter(const struct ip6t_entry *e,
+		     seqcount_t *seq,
 		     struct xt_counters total[],
 		     unsigned int *i)
 {
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
 
+	struct xt_counters count;
+	unsigned int start;
+
+	/* Atomic fetch */
+	do {
+		start = read_seqcount_begin(seq);
+		count = e->counters;
+	} while (read_seqcount_retry(seq, start));
+
+	ADD_COUNTER(total[*i], count.bcnt, count.pcnt);
 	(*i)++;
 	return 0;
 }
@@ -948,10 +962,11 @@ get_counters(const struct xt_table_info 
 			continue;
 		i = 0;
 		IP6T_ENTRY_ITERATE(t->entries[cpu],
-				  t->size,
-				  add_entry_to_counter,
-				  counters,
-				  &i);
+				   t->size,
+				   add_entry_to_counter,
+				   per_cpu_ptr(t->seq, cpu),
+				   counters,
+				   &i);
 	}
 }
 
@@ -971,9 +986,9 @@ static struct xt_counters *alloc_counter
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
@@ -2094,8 +2109,7 @@ struct xt_table *ip6t_register_table(str
 {
 	int ret;
 	struct xt_table_info *newinfo;
-	struct xt_table_info bootstrap
-		= { 0, 0, 0, { 0 }, { 0 }, { } };
+	struct xt_table_info bootstrap =  { 0 };
 	void *loc_cpu_entry;
 	struct xt_table *new_table;
 
--- a/net/netfilter/x_tables.c	2009-01-28 21:39:17.644495623 -0800
+++ b/net/netfilter/x_tables.c	2009-01-28 22:14:33.143990681 -0800
@@ -591,8 +591,18 @@ struct xt_table_info *xt_alloc_table_inf
 		return NULL;
 
 	newinfo->size = size;
+	newinfo->seq = alloc_percpu(seqcount_t);
+	if (!newinfo->seq) {
+		kfree(newinfo);
+		return NULL;
+	}
+
 
 	for_each_possible_cpu(cpu) {
+		seqcount_t *cnt = per_cpu_ptr(newinfo->seq, cpu);
+
+		seqcount_init(cnt);
+
 		if (size <= PAGE_SIZE)
 			newinfo->entries[cpu] = kmalloc_node(size,
 							GFP_KERNEL,
@@ -621,6 +631,7 @@ void xt_free_table_info(struct xt_table_
 		else
 			vfree(info->entries[cpu]);
 	}
+	free_percpu(info->seq);
 	kfree(info);
 }
 EXPORT_SYMBOL(xt_free_table_info);
--- a/include/linux/netfilter/x_tables.h	2009-01-28 21:35:12.044240843 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-01-28 22:04:39.316517913 -0800
@@ -383,6 +383,9 @@ struct xt_table_info
 	unsigned int hook_entry[NF_INET_NUMHOOKS];
 	unsigned int underflow[NF_INET_NUMHOOKS];
 
+	/* Secret compartment */
+	seqcount_t *seq;
+
 	/* ipt_entry tables: one per CPU */
 	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
 	char *entries[1];

-- 

