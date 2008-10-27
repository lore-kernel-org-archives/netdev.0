From: hamid.jafarian@gmail.com (hamid jafarian)
Subject: [PATCH 06/09]IPtablestng/KernelSpace - patch ip_tables.h
Date: Mon, 27 Oct 2008 08:24:21 +0330 (IRST)
Message-ID: <20081027045421.C6B85C6408E@host1.ystp.ac.ir>
Cc: Netdev <netdev@vger.kernel.org>
To: Netfilter-devel <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
cc: Pablo Neira Ayuso <pablo@netfilter.org>
cc: Patrick McHardy <kaber@trash.net>
cc: Jan Engelhardt <jengelh@medozas.de>
cc: David Miller <davem@davemloft.net>
cc: Rusty Russell <rusty@rustcorp.com.au>
cc: Harald Welte <laforge@gnumonks.org>
cc: Eric Leblond <eric@inl.fr>
cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
cc: Amin Azez <azez@ufomechanic.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

eliminating unnecessary definitions and adopting to new features.

by this patch, ip_tables.h will caontain the necessary definitions that are required by iptablestng to implement ipv4 tables.

diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index bfc889f..f133037 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -1,15 +1,6 @@
-/*
- * 25-Jul-1998 Major changes to allow for ip chain table
- *
- * 3-Jan-2000 Named tables to allow packet selection for different uses.
- */
-
-/*
- * 	Format of an IP firewall descriptor
+/* Packet Tables Code - IP4 part
  *
- * 	src, dst, src_mask, dst_mask are always stored in network byte order.
- * 	flags are stored in host byte order (of course).
- * 	Port numbers are stored in HOST byte order.
+ * Copyright (C) 2005-2008 Hamid Jafarian(hm.t.) <hamid.jafarian@gmail.com>
  */
 
 #ifndef _IPTABLES_H
@@ -21,8 +12,9 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/skbuff.h>
-#endif
 #include <linux/compiler.h>
+#endif
+
 #include <linux/netfilter_ipv4.h>
 
 #include <linux/netfilter/x_tables.h>
@@ -51,12 +43,13 @@ struct ipt_ip {
 	/* Inverse flags */
 	u_int8_t invflags;
 };
+#include <linux/netfilter/pkt_tables.h>
 
 #define ipt_entry_match xt_entry_match
 #define ipt_entry_target xt_entry_target
 #define ipt_standard_target xt_standard_target
 
-#define ipt_counters xt_counters
+#define ipt_counters pktt_counters
 
 /* Values for "flag" field in struct ipt_ip (general ip structure). */
 #define IPT_F_FRAG		0x01	/* Set if rule is a fragment rule */
@@ -73,30 +66,24 @@ struct ipt_ip {
 #define IPT_INV_PROTO		XT_INV_PROTO
 #define IPT_INV_MASK		0x7F	/* All possible flag bits mask. */
 
-/* This structure defines each of the firewall rules.  Consists of 3
-   parts which are 1) general IP header stuff 2) match specific
-   stuff 3) the target to perform if the rule matches */
-struct ipt_entry
-{
-	struct ipt_ip ip;
-
-	/* Mark with fields that we care about. */
-	unsigned int nfcache;
+#define ipt_entry pktt_entry
 
-	/* Size of ipt_entry + matches */
-	u_int16_t target_offset;
-	/* Size of ipt_entry + matches + target */
-	u_int16_t next_offset;
+#define IP4_SRCIP(skb) (ip_hdr(skb)->saddr)
+#define IP4_DSTIP(skb) (ip_hdr(skb)->daddr)
+#define IP4_PROTO(skb) (ip_hdr(skb)->protocol)
 
-	/* Back pointer */
-	unsigned int comefrom;
+#define IP4_TOTLEN(skb)(ntohs(ip_hdr(skb)->tot_len))
+#define IP4_PROTOFF(skb)(ip_hdr(skb)->ihl * 4)
+#define IP4_OFFSET(skb) (ntohs(ip_hdr(skb)->frag_off) & IP_OFFSET)
 
-	/* Packet and byte counters. */
-	struct xt_counters counters;
-
-	/* The matches (if any), then the target. */
-	unsigned char elems[0];
-};
+#define IP4_CHECK_FRAGMENT(ip, offset)                                  \
+({                                                                      \
+        int __ret = 0;                                                  \
+        if( (( (ip).flags & IPT_F_FRAG ) && !offset) /*he can't match*/ \
+        /* but if INV */ ^ !!((ip).invflags & IPT_INV_FRAG) )           \
+                __ret = NF_MAX_VERDICT +2;                              \
+        __ret;                                                          \
+}) 
 
 /*
  * New IP firewall options for [gs]etsockopt at the RAW IP level.
@@ -117,8 +104,8 @@ struct ipt_entry
 #define IPT_SO_GET_REVISION_TARGET	(IPT_BASE_CTL + 3)
 #define IPT_SO_GET_MAX			IPT_SO_GET_REVISION_TARGET
 
-#define IPT_CONTINUE XT_CONTINUE
-#define IPT_RETURN XT_RETURN
+#define IPT_CONTINUE PKTT_CONTINUE
+#define IPT_RETURN PKTT_RETURN
 
 #include <linux/netfilter/xt_tcpudp.h>
 #define ipt_udp xt_udp
@@ -145,96 +132,19 @@ struct ipt_icmp
 /* Values for "inv" field for struct ipt_icmp. */
 #define IPT_ICMP_INV	0x01	/* Invert the sense of type/code test */
 
-/* The argument to IPT_SO_GET_INFO */
-struct ipt_getinfo
-{
-	/* Which table: caller fills this in. */
-	char name[IPT_TABLE_MAXNAMELEN];
-
-	/* Kernel fills these in. */
-	/* Which hook entry points are valid: bitmask */
-	unsigned int valid_hooks;
-
-	/* Hook entry points: one per netfilter hook. */
-	unsigned int hook_entry[NF_INET_NUMHOOKS];
-
-	/* Underflow points. */
-	unsigned int underflow[NF_INET_NUMHOOKS];
-
-	/* Number of entries */
-	unsigned int num_entries;
-
-	/* Size of entries. */
-	unsigned int size;
-};
-
-/* The argument to IPT_SO_SET_REPLACE. */
-struct ipt_replace
-{
-	/* Which table. */
-	char name[IPT_TABLE_MAXNAMELEN];
-
-	/* Which hook entry points are valid: bitmask.  You can't
-           change this. */
-	unsigned int valid_hooks;
-
-	/* Number of entries */
-	unsigned int num_entries;
-
-	/* Total size of new entries */
-	unsigned int size;
-
-	/* Hook entry points. */
-	unsigned int hook_entry[NF_INET_NUMHOOKS];
-
-	/* Underflow points. */
-	unsigned int underflow[NF_INET_NUMHOOKS];
-
-	/* Information about old entries: */
-	/* Number of counters (must be equal to current number of entries). */
-	unsigned int num_counters;
-	/* The old entries' counters. */
-	struct xt_counters __user *counters;
-
-	/* The entries (hang off end: not really an array). */
-	struct ipt_entry entries[0];
-};
-
 /* The argument to IPT_SO_ADD_COUNTERS. */
 #define ipt_counters_info xt_counters_info
 
-/* The argument to IPT_SO_GET_ENTRIES. */
-struct ipt_get_entries
-{
-	/* Which table: user fills this in. */
-	char name[IPT_TABLE_MAXNAMELEN];
-
-	/* User fills this in: total entry size. */
-	unsigned int size;
-
-	/* The entries. */
-	struct ipt_entry entrytable[0];
-};
-
 /* Standard return verdict, or do jump. */
 #define IPT_STANDARD_TARGET XT_STANDARD_TARGET
 /* Error verdict. */
 #define IPT_ERROR_TARGET XT_ERROR_TARGET
 
 /* Helper functions */
-static __inline__ struct ipt_entry_target *
-ipt_get_target(struct ipt_entry *e)
-{
-	return (void *)e + e->target_offset;
-}
+#define ipt_get_target(e) pktt_entry_get_target(e)
 
-/* fn returns 0 to continue iteration */
-#define IPT_MATCH_ITERATE(e, fn, args...) \
-	XT_MATCH_ITERATE(struct ipt_entry, e, fn, ## args)
-
-/* fn returns 0 to continue iteration */
-#define IPT_ENTRY_ITERATE(entries, size, fn, args...) \
-	XT_ENTRY_ITERATE(struct ipt_entry, entries, size, fn, ## args)
+#define IPT_MATCH_ITERATE(e, fn, args...)       \
+                PKTT_ENTRY_MATCH_ITERATE(e, fn, ## args)
 
 /*
  *	Main firewall chains definitions and global var's definitions.
@@ -244,96 +154,7 @@ ipt_get_target(struct ipt_entry *e)
 #include <linux/init.h>
 extern void ipt_init(void) __init;
 
-extern struct xt_table *ipt_register_table(struct net *net,
-					   struct xt_table *table,
-					   const struct ipt_replace *repl);
-extern void ipt_unregister_table(struct xt_table *table);
-
-/* Standard entry. */
-struct ipt_standard
-{
-	struct ipt_entry entry;
-	struct ipt_standard_target target;
-};
-
-struct ipt_error_target
-{
-	struct ipt_entry_target target;
-	char errorname[IPT_FUNCTION_MAXNAMELEN];
-};
-
-struct ipt_error
-{
-	struct ipt_entry entry;
-	struct ipt_error_target target;
-};
-
-#define IPT_ENTRY_INIT(__size)						       \
-{									       \
-	.target_offset	= sizeof(struct ipt_entry),			       \
-	.next_offset	= (__size),					       \
-}
-
-#define IPT_STANDARD_INIT(__verdict)					       \
-{									       \
-	.entry		= IPT_ENTRY_INIT(sizeof(struct ipt_standard)),	       \
-	.target		= XT_TARGET_INIT(IPT_STANDARD_TARGET,		       \
-					 sizeof(struct xt_standard_target)),   \
-	.target.verdict	= -(__verdict) - 1,				       \
-}
-
-#define IPT_ERROR_INIT							       \
-{									       \
-	.entry		= IPT_ENTRY_INIT(sizeof(struct ipt_error)),	       \
-	.target		= XT_TARGET_INIT(IPT_ERROR_TARGET,		       \
-					 sizeof(struct ipt_error_target)),     \
-	.target.errorname = "ERROR",					       \
-}
-
-extern unsigned int ipt_do_table(struct sk_buff *skb,
-				 unsigned int hook,
-				 const struct net_device *in,
-				 const struct net_device *out,
-				 struct xt_table *table);
-
 #define IPT_ALIGN(s) XT_ALIGN(s)
 
-#ifdef CONFIG_COMPAT
-#include <net/compat.h>
-
-struct compat_ipt_entry
-{
-	struct ipt_ip ip;
-	compat_uint_t nfcache;
-	u_int16_t target_offset;
-	u_int16_t next_offset;
-	compat_uint_t comefrom;
-	struct compat_xt_counters counters;
-	unsigned char elems[0];
-};
-
-/* Helper functions */
-static inline struct ipt_entry_target *
-compat_ipt_get_target(struct compat_ipt_entry *e)
-{
-	return (void *)e + e->target_offset;
-}
-
-#define COMPAT_IPT_ALIGN(s) 	COMPAT_XT_ALIGN(s)
-
-/* fn returns 0 to continue iteration */
-#define COMPAT_IPT_MATCH_ITERATE(e, fn, args...) \
-	XT_MATCH_ITERATE(struct compat_ipt_entry, e, fn, ## args)
-
-/* fn returns 0 to continue iteration */
-#define COMPAT_IPT_ENTRY_ITERATE(entries, size, fn, args...) \
-	XT_ENTRY_ITERATE(struct compat_ipt_entry, entries, size, fn, ## args)
-
-/* fn returns 0 to continue iteration */
-#define COMPAT_IPT_ENTRY_ITERATE_CONTINUE(entries, size, n, fn, args...) \
-	XT_ENTRY_ITERATE_CONTINUE(struct compat_ipt_entry, entries, size, n, \
-				  fn, ## args)
-
-#endif /* CONFIG_COMPAT */
 #endif /*__KERNEL__*/
 #endif /* _IPTABLES_H */

