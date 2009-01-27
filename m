From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFT 3/4] netfilter: use sequence number synchronization for counters
Date: Tue, 27 Jan 2009 15:53:13 -0800
Message-ID: <20090127235508.952787501@vyatta.com>
References: <20090127235310.159946902@vyatta.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:40010 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751262AbZA0X5t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 18:57:49 -0500
Content-Disposition: inline; filename=counters-seqcount.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change how synchronization is done on the iptables counters. Use seqcount
wrapper instead of depending on reader/writer lock.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 include/linux/netfilter/x_tables.h        |    2 +-
 include/linux/netfilter_arp/arp_tables.h  |    3 +++
 include/linux/netfilter_ipv4/ip_tables.h  |    3 +++
 include/linux/netfilter_ipv6/ip6_tables.h |    3 +++
 net/ipv4/netfilter/arp_tables.c           |   20 +++++++++++++-------
 net/ipv4/netfilter/ip_tables.c            |   20 +++++++++++++-------
 net/ipv6/netfilter/ip6_tables.c           |   20 +++++++++++++-------
 net/netfilter/x_tables.c                  |    1 +
 8 files changed, 50 insertions(+), 22 deletions(-)
4
--- a/include/linux/netfilter_ipv6/ip6_tables.h	2009-01-27 15:03:02.843376881 -0800
+++ b/include/linux/netfilter_ipv6/ip6_tables.h	2009-01-27 15:37:38.935377810 -0800
@@ -103,6 +103,9 @@ struct ip6t_entry
 	/* Back pointer */
 	unsigned int comefrom;
 
+	/* Update of counter synchronization */
+	seqcount_t seq;
+
 	/* Packet and byte counters. */
 	struct xt_counters counters;
 
--- a/net/ipv4/netfilter/arp_tables.c	2009-01-27 14:48:41.579877551 -0800
+++ b/net/ipv4/netfilter/arp_tables.c	2009-01-27 15:45:34.566650540 -0800
@@ -256,7 +256,9 @@ unsigned int arpt_do_table(struct sk_buf
 
 			hdr_len = sizeof(*arp) + (2 * sizeof(struct in_addr)) +
 				(2 * skb->dev->addr_len);
+			write_seqcount_begin(&e->seq);
 			ADD_COUNTER(e->counters, hdr_len, 1);
+			write_seqcount_end(&e->seq);
 
 			t = arpt_get_target(e);
 
@@ -549,6 +551,7 @@ static inline int check_entry_size_and_h
 	   < 0 (not ARPT_RETURN). --RR */
 
 	/* Clear counters and comefrom */
+	seqcount_init(&e->seq);
 	e->counters = ((struct xt_counters) { 0, 0 });
 	e->comefrom = 0;
 
@@ -703,14 +706,17 @@ static void get_counters(const struct xt
 			   &i);
 
 	for_each_possible_cpu(cpu) {
+		struct arpt_entry *e = t->entries[cpu];
+		unsigned int start;
+
 		if (cpu == curcpu)
 			continue;
 		i = 0;
-		ARPT_ENTRY_ITERATE(t->entries[cpu],
-				   t->size,
-				   add_entry_to_counter,
-				   counters,
-				   &i);
+		do {
+			start = read_seqcount_begin(&e->seq);
+			ARPT_ENTRY_ITERATE(t->entries[cpu], t->size,
+					   add_entry_to_counter, counters, &i);
+		} while (read_seqcount_retry(&e->seq, start));
 	}
 }
 
@@ -731,9 +737,9 @@ static inline struct xt_counters *alloc_
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
--- a/net/ipv4/netfilter/ip_tables.c	2009-01-27 14:48:41.567879095 -0800
+++ b/net/ipv4/netfilter/ip_tables.c	2009-01-27 15:45:05.766673246 -0800
@@ -366,7 +366,9 @@ ipt_do_table(struct sk_buff *skb,
 			if (IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
 				goto no_match;
 
+			write_seqcount_begin(&e->seq);
 			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
+			write_seqcount_end(&e->seq);
 
 			t = ipt_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -758,6 +760,7 @@ check_entry_size_and_hooks(struct ipt_en
 	   < 0 (not IPT_RETURN). --RR */
 
 	/* Clear counters and comefrom */
+	seqcount_init(&e->seq);
 	e->counters = ((struct xt_counters) { 0, 0 });
 	e->comefrom = 0;
 
@@ -915,14 +918,17 @@ get_counters(const struct xt_table_info 
 			  &i);
 
 	for_each_possible_cpu(cpu) {
+		struct ipt_entry *e = t->entries[cpu];
+		unsigned int start;
+
 		if (cpu == curcpu)
 			continue;
 		i = 0;
-		IPT_ENTRY_ITERATE(t->entries[cpu],
-				  t->size,
-				  add_entry_to_counter,
-				  counters,
-				  &i);
+		do {
+			start = read_seqcount_begin(&e->seq);
+			IPT_ENTRY_ITERATE(e, t->size,
+					  add_entry_to_counter, counters, &i);
+		} while (read_seqcount_retry(&e->seq, start));
 	}
 }
 
@@ -942,9 +948,9 @@ static struct xt_counters * alloc_counte
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
--- a/net/ipv6/netfilter/ip6_tables.c	2009-01-27 14:48:41.603877653 -0800
+++ b/net/ipv6/netfilter/ip6_tables.c	2009-01-27 15:45:22.262639173 -0800
@@ -392,9 +392,11 @@ ip6t_do_table(struct sk_buff *skb,
 			if (IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0)
 				goto no_match;
 
+			write_seqcount_begin(&e->seq);
 			ADD_COUNTER(e->counters,
 				    ntohs(ipv6_hdr(skb)->payload_len) +
 				    sizeof(struct ipv6hdr), 1);
+			write_seqcount_end(&e->seq);
 
 			t = ip6t_get_target(e);
 			IP_NF_ASSERT(t->u.kernel.target);
@@ -787,6 +789,7 @@ check_entry_size_and_hooks(struct ip6t_e
 	   < 0 (not IP6T_RETURN). --RR */
 
 	/* Clear counters and comefrom */
+	seqcount_init(&e->seq);
 	e->counters = ((struct xt_counters) { 0, 0 });
 	e->comefrom = 0;
 
@@ -944,14 +947,17 @@ get_counters(const struct xt_table_info 
 			   &i);
 
 	for_each_possible_cpu(cpu) {
+		struct ip6t_entry *e = t->entries[cpu];
+		unsigned int start;
+
 		if (cpu == curcpu)
 			continue;
 		i = 0;
-		IP6T_ENTRY_ITERATE(t->entries[cpu],
-				  t->size,
-				  add_entry_to_counter,
-				  counters,
-				  &i);
+		do {
+			start = read_seqcount_begin(&e->seq);
+			IP6T_ENTRY_ITERATE(e, t->size,
+					   add_entry_to_counter, counters, &i);
+		} while (read_seqcount_retry(&e->seq, start));
 	}
 }
 
@@ -971,9 +977,9 @@ static struct xt_counters *alloc_counter
 		return ERR_PTR(-ENOMEM);
 
 	/* First, sum counters... */
-	write_lock_bh(&table->lock);
+	local_bh_disable();
 	get_counters(private, counters);
-	write_unlock_bh(&table->lock);
+	local_bh_enable();
 
 	return counters;
 }
--- a/include/linux/netfilter_ipv4/ip_tables.h	2009-01-27 15:02:24.367376923 -0800
+++ b/include/linux/netfilter_ipv4/ip_tables.h	2009-01-27 15:16:43.940902866 -0800
@@ -91,6 +91,9 @@ struct ipt_entry
 	/* Back pointer */
 	unsigned int comefrom;
 
+	/* Update of counter synchronization */
+	seqcount_t seq;
+
 	/* Packet and byte counters. */
 	struct xt_counters counters;
 
--- a/net/netfilter/x_tables.c	2009-01-27 15:06:05.822878866 -0800
+++ b/net/netfilter/x_tables.c	2009-01-27 15:14:06.004743434 -0800
@@ -720,6 +720,7 @@ struct xt_table *xt_register_table(struc
 	/* Simplifies replace_table code. */
 	table->private = bootstrap;
 	rwlock_init(&table->lock);
+
 	if (!xt_replace_table(table, 0, newinfo, &ret))
 		goto unlock;
 
--- a/include/linux/netfilter/x_tables.h	2009-01-27 15:01:04.420377356 -0800
+++ b/include/linux/netfilter/x_tables.h	2009-01-27 15:33:10.791377313 -0800
@@ -385,7 +385,7 @@ struct xt_table_info
 
 	/* ipt_entry tables: one per CPU */
 	/* Note : this field MUST be the last one, see XT_TABLE_INFO_SZ */
-	char *entries[1];
+	void *entries[1];
 };
 
 #define XT_TABLE_INFO_SZ (offsetof(struct xt_table_info, entries) \
--- a/include/linux/netfilter_arp/arp_tables.h	2009-01-27 15:35:33.827376817 -0800
+++ b/include/linux/netfilter_arp/arp_tables.h	2009-01-27 15:36:48.919127941 -0800
@@ -99,6 +99,9 @@ struct arpt_entry
 	/* Back pointer */
 	unsigned int comefrom;
 
+	/* Update of counter synchronization */
+	seqcount_t seq;
+
 	/* Packet and byte counters. */
 	struct xt_counters counters;
 

-- 

