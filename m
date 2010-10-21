From: kaber@trash.net
Subject: [PATCH 34/72] netfilter: xtables: resolve indirect macros 3/3
Date: Thu, 21 Oct 2010 17:19:21 +0200
Message-ID: <1287674399-31455-35-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59988 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869Ab0JUPUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:09 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

---
 include/linux/netfilter_arp/arp_tables.h  |   33 ++++----------
 include/linux/netfilter_ipv4/ip_tables.h  |   69 +++++++++++++---------------
 include/linux/netfilter_ipv6/ip6_tables.h |   69 ++++++++++------------------
 net/ipv4/netfilter/arp_tables.c           |   14 +++---
 net/ipv4/netfilter/arpt_mangle.c          |    2 +-
 net/ipv4/netfilter/ip_tables.c            |   18 ++++----
 net/ipv6/netfilter/ip6_tables.c           |   18 ++++----
 net/sched/act_ipt.c                       |    2 +-
 8 files changed, 94 insertions(+), 131 deletions(-)

diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index 7e193c9..6e2341a 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -26,6 +26,14 @@
 #define ARPT_TABLE_MAXNAMELEN XT_TABLE_MAXNAMELEN
 #define arpt_entry_target xt_entry_target
 #define arpt_standard_target xt_standard_target
+#define ARPT_CONTINUE XT_CONTINUE
+#define ARPT_RETURN XT_RETURN
+#define arpt_counters_info xt_counters_info
+#define arpt_counters xt_counters
+#define ARPT_STANDARD_TARGET XT_STANDARD_TARGET
+#define ARPT_ERROR_TARGET XT_ERROR_TARGET
+#define ARPT_ENTRY_ITERATE(entries, size, fn, args...) \
+	XT_ENTRY_ITERATE(struct arpt_entry, entries, size, fn, ## args)
 #endif
 
 #define ARPT_DEV_ADDR_LEN_MAX 16
@@ -126,12 +134,6 @@ struct arpt_entry
 #define ARPT_SO_GET_REVISION_TARGET	(ARPT_BASE_CTL + 3)
 #define ARPT_SO_GET_MAX			(ARPT_SO_GET_REVISION_TARGET)
 
-/* CONTINUE verdict for targets */
-#define ARPT_CONTINUE XT_CONTINUE
-
-/* For standard target */
-#define ARPT_RETURN XT_RETURN
-
 /* The argument to ARPT_SO_GET_INFO */
 struct arpt_getinfo {
 	/* Which table: caller fills this in. */
@@ -185,10 +187,6 @@ struct arpt_replace {
 	struct arpt_entry entries[0];
 };
 
-/* The argument to ARPT_SO_ADD_COUNTERS. */
-#define arpt_counters_info xt_counters_info
-#define arpt_counters xt_counters
-
 /* The argument to ARPT_SO_GET_ENTRIES. */
 struct arpt_get_entries {
 	/* Which table: user fills this in. */
@@ -201,23 +199,12 @@ struct arpt_get_entries {
 	struct arpt_entry entrytable[0];
 };
 
-/* Standard return verdict, or do jump. */
-#define ARPT_STANDARD_TARGET XT_STANDARD_TARGET
-/* Error verdict. */
-#define ARPT_ERROR_TARGET XT_ERROR_TARGET
-
 /* Helper functions */
 static __inline__ struct xt_entry_target *arpt_get_target(struct arpt_entry *e)
 {
 	return (void *)e + e->target_offset;
 }
 
-#ifndef __KERNEL__
-/* fn returns 0 to continue iteration */
-#define ARPT_ENTRY_ITERATE(entries, size, fn, args...) \
-	XT_ENTRY_ITERATE(struct arpt_entry, entries, size, fn, ## args)
-#endif
-
 /*
  *	Main firewall chains definitions and global var's definitions.
  */
@@ -248,7 +235,7 @@ struct arpt_error {
 #define ARPT_STANDARD_INIT(__verdict)					       \
 {									       \
 	.entry		= ARPT_ENTRY_INIT(sizeof(struct arpt_standard)),       \
-	.target		= XT_TARGET_INIT(ARPT_STANDARD_TARGET,		       \
+	.target		= XT_TARGET_INIT(XT_STANDARD_TARGET,		       \
 					 sizeof(struct xt_standard_target)), \
 	.target.verdict	= -(__verdict) - 1,				       \
 }
@@ -256,7 +243,7 @@ struct arpt_error {
 #define ARPT_ERROR_INIT							       \
 {									       \
 	.entry		= ARPT_ENTRY_INIT(sizeof(struct arpt_error)),	       \
-	.target		= XT_TARGET_INIT(ARPT_ERROR_TARGET,		       \
+	.target		= XT_TARGET_INIT(XT_ERROR_TARGET,		       \
 					 sizeof(struct arpt_error_target)),    \
 	.target.errorname = "ERROR",					       \
 }
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index ec50691..ee54b3b 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -38,6 +38,36 @@
 #define ipt_entry_target xt_entry_target
 #define ipt_standard_target xt_standard_target
 #define ipt_counters xt_counters
+#define IPT_CONTINUE XT_CONTINUE
+#define IPT_RETURN XT_RETURN
+
+/* This group is older than old (iptables < v1.4.0-rc1~89) */
+#include <linux/netfilter/xt_tcpudp.h>
+#define ipt_udp xt_udp
+#define ipt_tcp xt_tcp
+#define IPT_TCP_INV_SRCPT	XT_TCP_INV_SRCPT
+#define IPT_TCP_INV_DSTPT	XT_TCP_INV_DSTPT
+#define IPT_TCP_INV_FLAGS	XT_TCP_INV_FLAGS
+#define IPT_TCP_INV_OPTION	XT_TCP_INV_OPTION
+#define IPT_TCP_INV_MASK	XT_TCP_INV_MASK
+#define IPT_UDP_INV_SRCPT	XT_UDP_INV_SRCPT
+#define IPT_UDP_INV_DSTPT	XT_UDP_INV_DSTPT
+#define IPT_UDP_INV_MASK	XT_UDP_INV_MASK
+
+/* The argument to IPT_SO_ADD_COUNTERS. */
+#define ipt_counters_info xt_counters_info
+/* Standard return verdict, or do jump. */
+#define IPT_STANDARD_TARGET XT_STANDARD_TARGET
+/* Error verdict. */
+#define IPT_ERROR_TARGET XT_ERROR_TARGET
+
+/* fn returns 0 to continue iteration */
+#define IPT_MATCH_ITERATE(e, fn, args...) \
+	XT_MATCH_ITERATE(struct ipt_entry, e, fn, ## args)
+
+/* fn returns 0 to continue iteration */
+#define IPT_ENTRY_ITERATE(entries, size, fn, args...) \
+	XT_ENTRY_ITERATE(struct ipt_entry, entries, size, fn, ## args)
 #endif
 
 /* Yes, Virginia, you have to zero the padding. */
@@ -116,23 +146,6 @@ struct ipt_entry {
 #define IPT_SO_GET_REVISION_TARGET	(IPT_BASE_CTL + 3)
 #define IPT_SO_GET_MAX			IPT_SO_GET_REVISION_TARGET
 
-#define IPT_CONTINUE XT_CONTINUE
-#define IPT_RETURN XT_RETURN
-
-#include <linux/netfilter/xt_tcpudp.h>
-#define ipt_udp xt_udp
-#define ipt_tcp xt_tcp
-
-#define IPT_TCP_INV_SRCPT	XT_TCP_INV_SRCPT
-#define IPT_TCP_INV_DSTPT	XT_TCP_INV_DSTPT
-#define IPT_TCP_INV_FLAGS	XT_TCP_INV_FLAGS
-#define IPT_TCP_INV_OPTION	XT_TCP_INV_OPTION
-#define IPT_TCP_INV_MASK	XT_TCP_INV_MASK
-
-#define IPT_UDP_INV_SRCPT	XT_UDP_INV_SRCPT
-#define IPT_UDP_INV_DSTPT	XT_UDP_INV_DSTPT
-#define IPT_UDP_INV_MASK	XT_UDP_INV_MASK
-
 /* ICMP matching stuff */
 struct ipt_icmp {
 	u_int8_t type;				/* type to match */
@@ -196,9 +209,6 @@ struct ipt_replace {
 	struct ipt_entry entries[0];
 };
 
-/* The argument to IPT_SO_ADD_COUNTERS. */
-#define ipt_counters_info xt_counters_info
-
 /* The argument to IPT_SO_GET_ENTRIES. */
 struct ipt_get_entries {
 	/* Which table: user fills this in. */
@@ -211,11 +221,6 @@ struct ipt_get_entries {
 	struct ipt_entry entrytable[0];
 };
 
-/* Standard return verdict, or do jump. */
-#define IPT_STANDARD_TARGET XT_STANDARD_TARGET
-/* Error verdict. */
-#define IPT_ERROR_TARGET XT_ERROR_TARGET
-
 /* Helper functions */
 static __inline__ struct xt_entry_target *
 ipt_get_target(struct ipt_entry *e)
@@ -223,16 +228,6 @@ ipt_get_target(struct ipt_entry *e)
 	return (void *)e + e->target_offset;
 }
 
-#ifndef __KERNEL__
-/* fn returns 0 to continue iteration */
-#define IPT_MATCH_ITERATE(e, fn, args...) \
-	XT_MATCH_ITERATE(struct ipt_entry, e, fn, ## args)
-
-/* fn returns 0 to continue iteration */
-#define IPT_ENTRY_ITERATE(entries, size, fn, args...) \
-	XT_ENTRY_ITERATE(struct ipt_entry, entries, size, fn, ## args)
-#endif
-
 /*
  *	Main firewall chains definitions and global var's definitions.
  */
@@ -271,7 +266,7 @@ struct ipt_error {
 #define IPT_STANDARD_INIT(__verdict)					       \
 {									       \
 	.entry		= IPT_ENTRY_INIT(sizeof(struct ipt_standard)),	       \
-	.target		= XT_TARGET_INIT(IPT_STANDARD_TARGET,		       \
+	.target		= XT_TARGET_INIT(XT_STANDARD_TARGET,		       \
 					 sizeof(struct xt_standard_target)),   \
 	.target.verdict	= -(__verdict) - 1,				       \
 }
@@ -279,7 +274,7 @@ struct ipt_error {
 #define IPT_ERROR_INIT							       \
 {									       \
 	.entry		= IPT_ENTRY_INIT(sizeof(struct ipt_error)),	       \
-	.target		= XT_TARGET_INIT(IPT_ERROR_TARGET,		       \
+	.target		= XT_TARGET_INIT(XT_ERROR_TARGET,		       \
 					 sizeof(struct ipt_error_target)),     \
 	.target.errorname = "ERROR",					       \
 }
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 40d11fa..ac2b411 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -38,6 +38,29 @@
 #define ip6t_entry_target xt_entry_target
 #define ip6t_standard_target xt_standard_target
 #define ip6t_counters xt_counters
+#define IP6T_CONTINUE XT_CONTINUE
+#define IP6T_RETURN XT_RETURN
+
+/* Pre-iptables-1.4.0 */
+#include <linux/netfilter/xt_tcpudp.h>
+#define ip6t_tcp xt_tcp
+#define ip6t_udp xt_udp
+#define IP6T_TCP_INV_SRCPT	XT_TCP_INV_SRCPT
+#define IP6T_TCP_INV_DSTPT	XT_TCP_INV_DSTPT
+#define IP6T_TCP_INV_FLAGS	XT_TCP_INV_FLAGS
+#define IP6T_TCP_INV_OPTION	XT_TCP_INV_OPTION
+#define IP6T_TCP_INV_MASK	XT_TCP_INV_MASK
+#define IP6T_UDP_INV_SRCPT	XT_UDP_INV_SRCPT
+#define IP6T_UDP_INV_DSTPT	XT_UDP_INV_DSTPT
+#define IP6T_UDP_INV_MASK	XT_UDP_INV_MASK
+
+#define ip6t_counters_info xt_counters_info
+#define IP6T_STANDARD_TARGET XT_STANDARD_TARGET
+#define IP6T_ERROR_TARGET XT_ERROR_TARGET
+#define IP6T_MATCH_ITERATE(e, fn, args...) \
+	XT_MATCH_ITERATE(struct ip6t_entry, e, fn, ## args)
+#define IP6T_ENTRY_ITERATE(entries, size, fn, args...) \
+	XT_ENTRY_ITERATE(struct ip6t_entry, entries, size, fn, ## args)
 #endif
 
 /* Yes, Virginia, you have to zero the padding. */
@@ -133,7 +156,7 @@ struct ip6t_error {
 #define IP6T_STANDARD_INIT(__verdict)					       \
 {									       \
 	.entry		= IP6T_ENTRY_INIT(sizeof(struct ip6t_standard)),       \
-	.target		= XT_TARGET_INIT(IP6T_STANDARD_TARGET,		       \
+	.target		= XT_TARGET_INIT(XT_STANDARD_TARGET,		       \
 					 sizeof(struct xt_standard_target)),   \
 	.target.verdict	= -(__verdict) - 1,				       \
 }
@@ -141,7 +164,7 @@ struct ip6t_error {
 #define IP6T_ERROR_INIT							       \
 {									       \
 	.entry		= IP6T_ENTRY_INIT(sizeof(struct ip6t_error)),	       \
-	.target		= XT_TARGET_INIT(IP6T_ERROR_TARGET,		       \
+	.target		= XT_TARGET_INIT(XT_ERROR_TARGET,		       \
 					 sizeof(struct ip6t_error_target)),    \
 	.target.errorname = "ERROR",					       \
 }
@@ -165,30 +188,6 @@ struct ip6t_error {
 #define IP6T_SO_GET_REVISION_TARGET	(IP6T_BASE_CTL + 5)
 #define IP6T_SO_GET_MAX			IP6T_SO_GET_REVISION_TARGET
 
-/* CONTINUE verdict for targets */
-#define IP6T_CONTINUE XT_CONTINUE
-
-/* For standard target */
-#define IP6T_RETURN XT_RETURN
-
-/* TCP/UDP matching stuff */
-#include <linux/netfilter/xt_tcpudp.h>
-
-#define ip6t_tcp xt_tcp
-#define ip6t_udp xt_udp
-
-/* Values for "inv" field in struct ipt_tcp. */
-#define IP6T_TCP_INV_SRCPT	XT_TCP_INV_SRCPT
-#define IP6T_TCP_INV_DSTPT	XT_TCP_INV_DSTPT
-#define IP6T_TCP_INV_FLAGS	XT_TCP_INV_FLAGS
-#define IP6T_TCP_INV_OPTION	XT_TCP_INV_OPTION
-#define IP6T_TCP_INV_MASK	XT_TCP_INV_MASK
-
-/* Values for "invflags" field in struct ipt_udp. */
-#define IP6T_UDP_INV_SRCPT	XT_UDP_INV_SRCPT
-#define IP6T_UDP_INV_DSTPT	XT_UDP_INV_DSTPT
-#define IP6T_UDP_INV_MASK	XT_UDP_INV_MASK
-
 /* ICMP matching stuff */
 struct ip6t_icmp {
 	u_int8_t type;				/* type to match */
@@ -252,9 +251,6 @@ struct ip6t_replace {
 	struct ip6t_entry entries[0];
 };
 
-/* The argument to IP6T_SO_ADD_COUNTERS. */
-#define ip6t_counters_info xt_counters_info
-
 /* The argument to IP6T_SO_GET_ENTRIES. */
 struct ip6t_get_entries {
 	/* Which table: user fills this in. */
@@ -267,11 +263,6 @@ struct ip6t_get_entries {
 	struct ip6t_entry entrytable[0];
 };
 
-/* Standard return verdict, or do jump. */
-#define IP6T_STANDARD_TARGET XT_STANDARD_TARGET
-/* Error verdict. */
-#define IP6T_ERROR_TARGET XT_ERROR_TARGET
-
 /* Helper functions */
 static __inline__ struct xt_entry_target *
 ip6t_get_target(struct ip6t_entry *e)
@@ -279,16 +270,6 @@ ip6t_get_target(struct ip6t_entry *e)
 	return (void *)e + e->target_offset;
 }
 
-#ifndef __KERNEL__
-/* fn returns 0 to continue iteration */
-#define IP6T_MATCH_ITERATE(e, fn, args...) \
-	XT_MATCH_ITERATE(struct ip6t_entry, e, fn, ## args)
-
-/* fn returns 0 to continue iteration */
-#define IP6T_ENTRY_ITERATE(entries, size, fn, args...) \
-	XT_ENTRY_ITERATE(struct ip6t_entry, entries, size, fn, ## args)
-#endif
-
 /*
  *	Main firewall chains definitions and global var's definitions.
  */
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index ed178cb..d756eda 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -300,7 +300,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 			v = ((struct xt_standard_target *)t)->verdict;
 			if (v < 0) {
 				/* Pop from stack? */
-				if (v != ARPT_RETURN) {
+				if (v != XT_RETURN) {
 					verdict = (unsigned)(-v) - 1;
 					break;
 				}
@@ -332,7 +332,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 		/* Target might have changed stuff. */
 		arp = arp_hdr(skb);
 
-		if (verdict == ARPT_CONTINUE)
+		if (verdict == XT_CONTINUE)
 			e = arpt_next_entry(e);
 		else
 			/* Verdict */
@@ -392,13 +392,13 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 			/* Unconditional return/END. */
 			if ((e->target_offset == sizeof(struct arpt_entry) &&
 			     (strcmp(t->target.u.user.name,
-				     ARPT_STANDARD_TARGET) == 0) &&
+				     XT_STANDARD_TARGET) == 0) &&
 			     t->verdict < 0 && unconditional(&e->arp)) ||
 			    visited) {
 				unsigned int oldpos, size;
 
 				if ((strcmp(t->target.u.user.name,
-					    ARPT_STANDARD_TARGET) == 0) &&
+					    XT_STANDARD_TARGET) == 0) &&
 				    t->verdict < -NF_MAX_VERDICT - 1) {
 					duprintf("mark_source_chains: bad "
 						"negative verdict (%i)\n",
@@ -433,7 +433,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 				int newpos = t->verdict;
 
 				if (strcmp(t->target.u.user.name,
-					   ARPT_STANDARD_TARGET) == 0 &&
+					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
 					if (newpos > newinfo->size -
 						sizeof(struct arpt_entry)) {
@@ -1828,7 +1828,7 @@ void arpt_unregister_table(struct xt_table *table)
 /* The built-in targets: standard (NULL) and error. */
 static struct xt_target arpt_builtin_tg[] __read_mostly = {
 	{
-		.name             = ARPT_STANDARD_TARGET,
+		.name             = XT_STANDARD_TARGET,
 		.targetsize       = sizeof(int),
 		.family           = NFPROTO_ARP,
 #ifdef CONFIG_COMPAT
@@ -1838,7 +1838,7 @@ static struct xt_target arpt_builtin_tg[] __read_mostly = {
 #endif
 	},
 	{
-		.name             = ARPT_ERROR_TARGET,
+		.name             = XT_ERROR_TARGET,
 		.target           = arpt_error,
 		.targetsize       = XT_FUNCTION_MAXNAMELEN,
 		.family           = NFPROTO_ARP,
diff --git a/net/ipv4/netfilter/arpt_mangle.c b/net/ipv4/netfilter/arpt_mangle.c
index e1be7dd..b8ddcc4 100644
--- a/net/ipv4/netfilter/arpt_mangle.c
+++ b/net/ipv4/netfilter/arpt_mangle.c
@@ -63,7 +63,7 @@ static int checkentry(const struct xt_tgchk_param *par)
 		return false;
 
 	if (mangle->target != NF_DROP && mangle->target != NF_ACCEPT &&
-	   mangle->target != ARPT_CONTINUE)
+	   mangle->target != XT_CONTINUE)
 		return false;
 	return true;
 }
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index cb10888..d31b007 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -232,7 +232,7 @@ get_chainname_rulenum(const struct ipt_entry *s, const struct ipt_entry *e,
 {
 	const struct xt_standard_target *t = (void *)ipt_get_target_c(s);
 
-	if (strcmp(t->target.u.kernel.target->name, IPT_ERROR_TARGET) == 0) {
+	if (strcmp(t->target.u.kernel.target->name, XT_ERROR_TARGET) == 0) {
 		/* Head of user chain: ERROR target with chainname */
 		*chainname = t->target.data;
 		(*rulenum) = 0;
@@ -241,7 +241,7 @@ get_chainname_rulenum(const struct ipt_entry *s, const struct ipt_entry *e,
 
 		if (s->target_offset == sizeof(struct ipt_entry) &&
 		    strcmp(t->target.u.kernel.target->name,
-			   IPT_STANDARD_TARGET) == 0 &&
+			   XT_STANDARD_TARGET) == 0 &&
 		   t->verdict < 0 &&
 		   unconditional(&s->ip)) {
 			/* Tail of chains: STANDARD target (return/policy) */
@@ -383,7 +383,7 @@ ipt_do_table(struct sk_buff *skb,
 			v = ((struct xt_standard_target *)t)->verdict;
 			if (v < 0) {
 				/* Pop from stack? */
-				if (v != IPT_RETURN) {
+				if (v != XT_RETURN) {
 					verdict = (unsigned)(-v) - 1;
 					break;
 				}
@@ -421,7 +421,7 @@ ipt_do_table(struct sk_buff *skb,
 		verdict = t->u.kernel.target->target(skb, &acpar);
 		/* Target might have changed stuff. */
 		ip = ip_hdr(skb);
-		if (verdict == IPT_CONTINUE)
+		if (verdict == XT_CONTINUE)
 			e = ipt_next_entry(e);
 		else
 			/* Verdict */
@@ -475,13 +475,13 @@ mark_source_chains(const struct xt_table_info *newinfo,
 			/* Unconditional return/END. */
 			if ((e->target_offset == sizeof(struct ipt_entry) &&
 			     (strcmp(t->target.u.user.name,
-				     IPT_STANDARD_TARGET) == 0) &&
+				     XT_STANDARD_TARGET) == 0) &&
 			     t->verdict < 0 && unconditional(&e->ip)) ||
 			    visited) {
 				unsigned int oldpos, size;
 
 				if ((strcmp(t->target.u.user.name,
-			    		    IPT_STANDARD_TARGET) == 0) &&
+			    		    XT_STANDARD_TARGET) == 0) &&
 				    t->verdict < -NF_MAX_VERDICT - 1) {
 					duprintf("mark_source_chains: bad "
 						"negative verdict (%i)\n",
@@ -524,7 +524,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				int newpos = t->verdict;
 
 				if (strcmp(t->target.u.user.name,
-					   IPT_STANDARD_TARGET) == 0 &&
+					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
 					if (newpos > newinfo->size -
 						sizeof(struct ipt_entry)) {
@@ -2176,7 +2176,7 @@ static int icmp_checkentry(const struct xt_mtchk_param *par)
 
 static struct xt_target ipt_builtin_tg[] __read_mostly = {
 	{
-		.name             = IPT_STANDARD_TARGET,
+		.name             = XT_STANDARD_TARGET,
 		.targetsize       = sizeof(int),
 		.family           = NFPROTO_IPV4,
 #ifdef CONFIG_COMPAT
@@ -2186,7 +2186,7 @@ static struct xt_target ipt_builtin_tg[] __read_mostly = {
 #endif
 	},
 	{
-		.name             = IPT_ERROR_TARGET,
+		.name             = XT_ERROR_TARGET,
 		.target           = ipt_error,
 		.targetsize       = XT_FUNCTION_MAXNAMELEN,
 		.family           = NFPROTO_IPV4,
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index c7334c1..c683e9e 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -262,7 +262,7 @@ get_chainname_rulenum(const struct ip6t_entry *s, const struct ip6t_entry *e,
 {
 	const struct xt_standard_target *t = (void *)ip6t_get_target_c(s);
 
-	if (strcmp(t->target.u.kernel.target->name, IP6T_ERROR_TARGET) == 0) {
+	if (strcmp(t->target.u.kernel.target->name, XT_ERROR_TARGET) == 0) {
 		/* Head of user chain: ERROR target with chainname */
 		*chainname = t->target.data;
 		(*rulenum) = 0;
@@ -271,7 +271,7 @@ get_chainname_rulenum(const struct ip6t_entry *s, const struct ip6t_entry *e,
 
 		if (s->target_offset == sizeof(struct ip6t_entry) &&
 		    strcmp(t->target.u.kernel.target->name,
-			   IP6T_STANDARD_TARGET) == 0 &&
+			   XT_STANDARD_TARGET) == 0 &&
 		    t->verdict < 0 &&
 		    unconditional(&s->ipv6)) {
 			/* Tail of chains: STANDARD target (return/policy) */
@@ -406,7 +406,7 @@ ip6t_do_table(struct sk_buff *skb,
 			v = ((struct xt_standard_target *)t)->verdict;
 			if (v < 0) {
 				/* Pop from stack? */
-				if (v != IP6T_RETURN) {
+				if (v != XT_RETURN) {
 					verdict = (unsigned)(-v) - 1;
 					break;
 				}
@@ -434,7 +434,7 @@ ip6t_do_table(struct sk_buff *skb,
 		acpar.targinfo = t->data;
 
 		verdict = t->u.kernel.target->target(skb, &acpar);
-		if (verdict == IP6T_CONTINUE)
+		if (verdict == XT_CONTINUE)
 			e = ip6t_next_entry(e);
 		else
 			/* Verdict */
@@ -488,13 +488,13 @@ mark_source_chains(const struct xt_table_info *newinfo,
 			/* Unconditional return/END. */
 			if ((e->target_offset == sizeof(struct ip6t_entry) &&
 			     (strcmp(t->target.u.user.name,
-				     IP6T_STANDARD_TARGET) == 0) &&
+				     XT_STANDARD_TARGET) == 0) &&
 			     t->verdict < 0 &&
 			     unconditional(&e->ipv6)) || visited) {
 				unsigned int oldpos, size;
 
 				if ((strcmp(t->target.u.user.name,
-					    IP6T_STANDARD_TARGET) == 0) &&
+					    XT_STANDARD_TARGET) == 0) &&
 				    t->verdict < -NF_MAX_VERDICT - 1) {
 					duprintf("mark_source_chains: bad "
 						"negative verdict (%i)\n",
@@ -537,7 +537,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 				int newpos = t->verdict;
 
 				if (strcmp(t->target.u.user.name,
-					   IP6T_STANDARD_TARGET) == 0 &&
+					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
 					if (newpos > newinfo->size -
 						sizeof(struct ip6t_entry)) {
@@ -2191,7 +2191,7 @@ static int icmp6_checkentry(const struct xt_mtchk_param *par)
 /* The built-in targets: standard (NULL) and error. */
 static struct xt_target ip6t_builtin_tg[] __read_mostly = {
 	{
-		.name             = IP6T_STANDARD_TARGET,
+		.name             = XT_STANDARD_TARGET,
 		.targetsize       = sizeof(int),
 		.family           = NFPROTO_IPV6,
 #ifdef CONFIG_COMPAT
@@ -2201,7 +2201,7 @@ static struct xt_target ip6t_builtin_tg[] __read_mostly = {
 #endif
 	},
 	{
-		.name             = IP6T_ERROR_TARGET,
+		.name             = XT_ERROR_TARGET,
 		.target           = ip6t_error,
 		.targetsize       = XT_FUNCTION_MAXNAMELEN,
 		.family           = NFPROTO_IPV6,
diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index f6d464f..8daef96 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -230,7 +230,7 @@ static int tcf_ipt(struct sk_buff *skb, struct tc_action *a,
 		result = TC_ACT_SHOT;
 		ipt->tcf_qstats.drops++;
 		break;
-	case IPT_CONTINUE:
+	case XT_CONTINUE:
 		result = TC_ACT_PIPE;
 		break;
 	default:
-- 
1.7.1

