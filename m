From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 06/08: xtables: replace XT_MATCH_ITERATE macro
Date: Wed, 24 Feb 2010 18:49:35 +0100 (MET)
Message-ID: <20100224174935.16391.47695.sendpatchset@x2.localnet>
References: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48789 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757418Ab0BXRth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 12:49:37 -0500
In-Reply-To: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit dcea992aca82cb08b4674c4c783e325835408d1e
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Feb 24 18:34:48 2010 +0100

    netfilter: xtables: replace XT_MATCH_ITERATE macro
    
    The macro is replaced by a list.h-like foreach loop. This makes
    the code more inspectable.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 9df3f5a..84c7c92 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -120,6 +120,7 @@ struct xt_counters_info {
 
 #define XT_INV_PROTO		0x40	/* Invert the sense of PROTO. */
 
+#ifndef __KERNEL__
 /* fn returns 0 to continue iteration */
 #define XT_MATCH_ITERATE(type, e, fn, args...)			\
 ({								\
@@ -139,7 +140,6 @@ struct xt_counters_info {
 	__ret;							\
 })
 
-#ifndef __KERNEL__
 /* fn returns 0 to continue iteration */
 #define XT_ENTRY_ITERATE_CONTINUE(type, entries, size, n, fn, args...) \
 ({								\
@@ -172,6 +172,14 @@ struct xt_counters_info {
 	     (pos) < (typeof(pos))((char *)(ehead) + (esize)); \
 	     (pos) = (typeof(pos))((char *)(pos) + (pos)->next_offset))
 
+/* can only be xt_entry_match, so no use of typeof here */
+#define xt_ematch_foreach(pos, entry) \
+	for ((pos) = (struct xt_entry_match *)entry->elems; \
+	     (pos) < (struct xt_entry_match *)((char *)(entry) + \
+	             (entry)->target_offset); \
+	     (pos) = (struct xt_entry_match *)((char *)(pos) + \
+	             (pos)->u.match_size))
+
 #ifdef __KERNEL__
 
 #include <linux/netdevice.h>
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 5b20ae7..704a7b6 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -223,11 +223,11 @@ ipt_get_target(struct ipt_entry *e)
 	return (void *)e + e->target_offset;
 }
 
+#ifndef __KERNEL__
 /* fn returns 0 to continue iteration */
 #define IPT_MATCH_ITERATE(e, fn, args...) \
 	XT_MATCH_ITERATE(struct ipt_entry, e, fn, ## args)
 
-#ifndef __KERNEL__
 /* fn returns 0 to continue iteration */
 #define IPT_ENTRY_ITERATE(entries, size, fn, args...) \
 	XT_ENTRY_ITERATE(struct ipt_entry, entries, size, fn, ## args)
@@ -315,10 +315,6 @@ compat_ipt_get_target(struct compat_ipt_entry *e)
 
 #define COMPAT_IPT_ALIGN(s) 	COMPAT_XT_ALIGN(s)
 
-/* fn returns 0 to continue iteration */
-#define COMPAT_IPT_MATCH_ITERATE(e, fn, args...) \
-	XT_MATCH_ITERATE(struct compat_ipt_entry, e, fn, ## args)
-
 #endif /* CONFIG_COMPAT */
 #endif /*__KERNEL__*/
 #endif /* _IPTABLES_H */
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 8bb3f5b..e5ba03d 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -280,11 +280,11 @@ ip6t_get_target(struct ip6t_entry *e)
 	return (void *)e + e->target_offset;
 }
 
+#ifndef __KERNEL__
 /* fn returns 0 to continue iteration */
 #define IP6T_MATCH_ITERATE(e, fn, args...) \
 	XT_MATCH_ITERATE(struct ip6t_entry, e, fn, ## args)
 
-#ifndef __KERNEL__
 /* fn returns 0 to continue iteration */
 #define IP6T_ENTRY_ITERATE(entries, size, fn, args...) \
 	XT_ENTRY_ITERATE(struct ip6t_entry, entries, size, fn, ## args)
@@ -343,10 +343,6 @@ compat_ip6t_get_target(struct compat_ip6t_entry *e)
 
 #define COMPAT_IP6T_ALIGN(s)	COMPAT_XT_ALIGN(s)
 
-/* fn returns 0 to continue iteration */
-#define COMPAT_IP6T_MATCH_ITERATE(e, fn, args...) \
-	XT_MATCH_ITERATE(struct compat_ip6t_entry, e, fn, ## args)
-
 #endif /* CONFIG_COMPAT */
 #endif /*__KERNEL__*/
 #endif /* _IP6_TABLES_H */
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 9c8aa39..3a7fc73 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -366,16 +366,21 @@ ipt_do_table(struct sk_buff *skb,
 
 	do {
 		const struct ipt_entry_target *t;
+		const struct xt_entry_match *ematch;
 
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
 		if (!ip_packet_match(ip, indev, outdev,
-		    &e->ip, mtpar.fragoff) ||
-		    IPT_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0) {
+		    &e->ip, mtpar.fragoff)) {
+ no_match:
 			e = ipt_next_entry(e);
 			continue;
 		}
 
+		xt_ematch_foreach(ematch, e)
+			if (do_match(ematch, skb, &mtpar) != 0)
+				goto no_match;
+
 		ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
 
 		t = ipt_get_target(e);
@@ -686,6 +691,7 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	int ret;
 	unsigned int j;
 	struct xt_mtchk_param mtpar;
+	struct xt_entry_match *ematch;
 
 	ret = check_entry(e, name);
 	if (ret)
@@ -697,7 +703,11 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	mtpar.entryinfo = &e->ip;
 	mtpar.hook_mask = e->comefrom;
 	mtpar.family    = NFPROTO_IPV4;
-	ret = IPT_MATCH_ITERATE(e, find_check_match, &mtpar, &j);
+	xt_ematch_foreach(ematch, e) {
+		ret = find_check_match(ematch, &mtpar, &j);
+		if (ret != 0)
+			break;
+	}
 	if (ret != 0)
 		goto cleanup_matches;
 
@@ -720,7 +730,9 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
  err:
 	module_put(t->u.kernel.target->me);
  cleanup_matches:
-	IPT_MATCH_ITERATE(e, cleanup_match, net, &j);
+	xt_ematch_foreach(ematch, e)
+		if (cleanup_match(ematch, net, &j) != 0)
+			break;
 	return ret;
 }
 
@@ -791,9 +803,12 @@ cleanup_entry(struct ipt_entry *e, struct net *net)
 {
 	struct xt_tgdtor_param par;
 	struct ipt_entry_target *t;
+	struct xt_entry_match *ematch;
 
 	/* Cleanup all matches */
-	IPT_MATCH_ITERATE(e, cleanup_match, net, NULL);
+	xt_ematch_foreach(ematch, e)
+		if (cleanup_match(ematch, net, NULL) != 0)
+			break;
 	t = ipt_get_target(e);
 
 	par.net      = net;
@@ -1060,13 +1075,16 @@ static int compat_calc_entry(const struct ipt_entry *e,
 			     const struct xt_table_info *info,
 			     const void *base, struct xt_table_info *newinfo)
 {
+	const struct xt_entry_match *ematch;
 	const struct ipt_entry_target *t;
 	unsigned int entry_offset;
 	int off, i, ret;
 
 	off = sizeof(struct ipt_entry) - sizeof(struct compat_ipt_entry);
 	entry_offset = (void *)e - base;
-	IPT_MATCH_ITERATE(e, compat_calc_match, &off);
+	xt_ematch_foreach(ematch, e)
+		if (compat_calc_match(ematch, &off) != 0)
+			break;
 	t = ipt_get_target_c(e);
 	off += xt_compat_target_offset(t->u.kernel.target);
 	newinfo->size -= off;
@@ -1441,7 +1459,8 @@ compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
 	struct compat_ipt_entry __user *ce;
 	u_int16_t target_offset, next_offset;
 	compat_uint_t origsize;
-	int ret;
+	const struct xt_entry_match *ematch;
+	int ret = 0;
 
 	origsize = *size;
 	ce = (struct compat_ipt_entry __user *)*dstptr;
@@ -1453,7 +1472,11 @@ compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
 	*dstptr += sizeof(struct compat_ipt_entry);
 	*size -= sizeof(struct ipt_entry) - sizeof(struct compat_ipt_entry);
 
-	ret = IPT_MATCH_ITERATE(e, xt_compat_match_to_user, dstptr, size);
+	xt_ematch_foreach(ematch, e) {
+		ret = xt_compat_match_to_user(ematch, dstptr, size);
+		if (ret != 0)
+			break;
+	}
 	target_offset = e->target_offset - (origsize - *size);
 	if (ret)
 		return ret;
@@ -1505,9 +1528,12 @@ compat_release_match(struct ipt_entry_match *m, unsigned int *i)
 static void compat_release_entry(struct compat_ipt_entry *e)
 {
 	struct ipt_entry_target *t;
+	struct xt_entry_match *ematch;
 
 	/* Cleanup all matches */
-	COMPAT_IPT_MATCH_ITERATE(e, compat_release_match, NULL);
+	xt_ematch_foreach(ematch, e)
+		if (compat_release_match(ematch, NULL) != 0)
+			break;
 	t = compat_ipt_get_target(e);
 	module_put(t->u.kernel.target->me);
 }
@@ -1522,6 +1548,7 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 				  const unsigned int *underflows,
 				  const char *name)
 {
+	struct xt_entry_match *ematch;
 	struct ipt_entry_target *t;
 	struct xt_target *target;
 	unsigned int entry_offset;
@@ -1550,8 +1577,12 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 	off = sizeof(struct ipt_entry) - sizeof(struct compat_ipt_entry);
 	entry_offset = (void *)e - (void *)base;
 	j = 0;
-	ret = COMPAT_IPT_MATCH_ITERATE(e, compat_find_calc_match, name,
-				       &e->ip, e->comefrom, &off, &j);
+	xt_ematch_foreach(ematch, e) {
+		ret = compat_find_calc_match(ematch, name,
+		      &e->ip, e->comefrom, &off, &j);
+		if (ret != 0)
+			break;
+	}
 	if (ret != 0)
 		goto release_matches;
 
@@ -1590,7 +1621,9 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 out:
 	module_put(t->u.kernel.target->me);
 release_matches:
-	IPT_MATCH_ITERATE(e, compat_release_match, &j);
+	xt_ematch_foreach(ematch, e)
+		if (compat_release_match(ematch, &j) != 0)
+			break;
 	return ret;
 }
 
@@ -1604,6 +1637,7 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 	struct ipt_entry *de;
 	unsigned int origsize;
 	int ret, h;
+	struct xt_entry_match *ematch;
 
 	ret = 0;
 	origsize = *size;
@@ -1614,8 +1648,11 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 	*dstptr += sizeof(struct ipt_entry);
 	*size += sizeof(struct ipt_entry) - sizeof(struct compat_ipt_entry);
 
-	ret = COMPAT_IPT_MATCH_ITERATE(e, xt_compat_match_from_user,
-				       dstptr, size);
+	xt_ematch_foreach(ematch, e) {
+		ret = xt_compat_match_from_user(ematch, dstptr, size);
+		if (ret != 0)
+			break;
+	}
 	if (ret)
 		return ret;
 	de->target_offset = e->target_offset - (origsize - *size);
@@ -1636,9 +1673,10 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 static int
 compat_check_entry(struct ipt_entry *e, struct net *net, const char *name)
 {
+	struct xt_entry_match *ematch;
 	struct xt_mtchk_param mtpar;
 	unsigned int j;
-	int ret;
+	int ret = 0;
 
 	j = 0;
 	mtpar.net	= net;
@@ -1646,7 +1684,11 @@ compat_check_entry(struct ipt_entry *e, struct net *net, const char *name)
 	mtpar.entryinfo = &e->ip;
 	mtpar.hook_mask = e->comefrom;
 	mtpar.family    = NFPROTO_IPV4;
-	ret = IPT_MATCH_ITERATE(e, check_match, &mtpar, &j);
+	xt_ematch_foreach(ematch, e) {
+		ret = check_match(ematch, &mtpar, &j);
+		if (ret != 0)
+			break;
+	}
 	if (ret)
 		goto cleanup_matches;
 
@@ -1656,7 +1698,9 @@ compat_check_entry(struct ipt_entry *e, struct net *net, const char *name)
 	return 0;
 
  cleanup_matches:
-	IPT_MATCH_ITERATE(e, cleanup_match, net, &j);
+	xt_ematch_foreach(ematch, e)
+		if (cleanup_match(ematch, net, &j) != 0)
+			break;
 	return ret;
 }
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index b7e27c1..1537e6b 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -393,16 +393,21 @@ ip6t_do_table(struct sk_buff *skb,
 
 	do {
 		const struct ip6t_entry_target *t;
+		const struct xt_entry_match *ematch;
 
 		IP_NF_ASSERT(e);
 		IP_NF_ASSERT(back);
 		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
-		    &mtpar.thoff, &mtpar.fragoff, &hotdrop) ||
-		    IP6T_MATCH_ITERATE(e, do_match, skb, &mtpar) != 0) {
+		    &mtpar.thoff, &mtpar.fragoff, &hotdrop)) {
+ no_match:
 			e = ip6t_next_entry(e);
 			continue;
 		}
 
+		xt_ematch_foreach(ematch, e)
+			if (do_match(ematch, skb, &mtpar) != 0)
+				goto no_match;
+
 		ADD_COUNTER(e->counters,
 			    ntohs(ipv6_hdr(skb)->payload_len) +
 			    sizeof(struct ipv6hdr), 1);
@@ -717,6 +722,7 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 	int ret;
 	unsigned int j;
 	struct xt_mtchk_param mtpar;
+	struct xt_entry_match *ematch;
 
 	ret = check_entry(e, name);
 	if (ret)
@@ -728,7 +734,11 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 	mtpar.entryinfo = &e->ipv6;
 	mtpar.hook_mask = e->comefrom;
 	mtpar.family    = NFPROTO_IPV6;
-	ret = IP6T_MATCH_ITERATE(e, find_check_match, &mtpar, &j);
+	xt_ematch_foreach(ematch, e) {
+		ret = find_check_match(ematch, &mtpar, &j);
+		if (ret != 0)
+			break;
+	}
 	if (ret != 0)
 		goto cleanup_matches;
 
@@ -751,7 +761,9 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
  err:
 	module_put(t->u.kernel.target->me);
  cleanup_matches:
-	IP6T_MATCH_ITERATE(e, cleanup_match, net, &j);
+	xt_ematch_foreach(ematch, e)
+		if (cleanup_match(ematch, net, &j) != 0)
+			break;
 	return ret;
 }
 
@@ -821,9 +833,12 @@ static void cleanup_entry(struct ip6t_entry *e, struct net *net)
 {
 	struct xt_tgdtor_param par;
 	struct ip6t_entry_target *t;
+	struct xt_entry_match *ematch;
 
 	/* Cleanup all matches */
-	IP6T_MATCH_ITERATE(e, cleanup_match, net, NULL);
+	xt_ematch_foreach(ematch, e)
+		if (cleanup_match(ematch, net, NULL) != 0)
+			break;
 	t = ip6t_get_target(e);
 
 	par.net      = net;
@@ -1090,13 +1105,16 @@ static int compat_calc_entry(const struct ip6t_entry *e,
 			     const struct xt_table_info *info,
 			     const void *base, struct xt_table_info *newinfo)
 {
+	const struct xt_entry_match *ematch;
 	const struct ip6t_entry_target *t;
 	unsigned int entry_offset;
 	int off, i, ret;
 
 	off = sizeof(struct ip6t_entry) - sizeof(struct compat_ip6t_entry);
 	entry_offset = (void *)e - base;
-	IP6T_MATCH_ITERATE(e, compat_calc_match, &off);
+	xt_ematch_foreach(ematch, e)
+		if (compat_calc_match(ematch, &off) != 0)
+			break;
 	t = ip6t_get_target_c(e);
 	off += xt_compat_target_offset(t->u.kernel.target);
 	newinfo->size -= off;
@@ -1474,7 +1492,8 @@ compat_copy_entry_to_user(struct ip6t_entry *e, void __user **dstptr,
 	struct compat_ip6t_entry __user *ce;
 	u_int16_t target_offset, next_offset;
 	compat_uint_t origsize;
-	int ret;
+	const struct xt_entry_match *ematch;
+	int ret = 0;
 
 	origsize = *size;
 	ce = (struct compat_ip6t_entry __user *)*dstptr;
@@ -1486,7 +1505,11 @@ compat_copy_entry_to_user(struct ip6t_entry *e, void __user **dstptr,
 	*dstptr += sizeof(struct compat_ip6t_entry);
 	*size -= sizeof(struct ip6t_entry) - sizeof(struct compat_ip6t_entry);
 
-	ret = IP6T_MATCH_ITERATE(e, xt_compat_match_to_user, dstptr, size);
+	xt_ematch_foreach(ematch, e) {
+		ret = xt_compat_match_to_user(ematch, dstptr, size);
+		if (ret != 0)
+			break;
+	}
 	target_offset = e->target_offset - (origsize - *size);
 	if (ret)
 		return ret;
@@ -1538,9 +1561,12 @@ compat_release_match(struct ip6t_entry_match *m, unsigned int *i)
 static void compat_release_entry(struct compat_ip6t_entry *e)
 {
 	struct ip6t_entry_target *t;
+	struct xt_entry_match *ematch;
 
 	/* Cleanup all matches */
-	COMPAT_IP6T_MATCH_ITERATE(e, compat_release_match, NULL);
+	xt_ematch_foreach(ematch, e)
+		if (compat_release_match(ematch, NULL) != 0)
+			break;
 	t = compat_ip6t_get_target(e);
 	module_put(t->u.kernel.target->me);
 }
@@ -1555,6 +1581,7 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 				  const unsigned int *underflows,
 				  const char *name)
 {
+	struct xt_entry_match *ematch;
 	struct ip6t_entry_target *t;
 	struct xt_target *target;
 	unsigned int entry_offset;
@@ -1583,8 +1610,12 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 	off = sizeof(struct ip6t_entry) - sizeof(struct compat_ip6t_entry);
 	entry_offset = (void *)e - (void *)base;
 	j = 0;
-	ret = COMPAT_IP6T_MATCH_ITERATE(e, compat_find_calc_match, name,
-					&e->ipv6, e->comefrom, &off, &j);
+	xt_ematch_foreach(ematch, e) {
+		ret = compat_find_calc_match(ematch, name,
+		      &e->ipv6, e->comefrom, &off, &j);
+		if (ret != 0)
+			break;
+	}
 	if (ret != 0)
 		goto release_matches;
 
@@ -1623,7 +1654,9 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 out:
 	module_put(t->u.kernel.target->me);
 release_matches:
-	IP6T_MATCH_ITERATE(e, compat_release_match, &j);
+	xt_ematch_foreach(ematch, e)
+		if (compat_release_match(ematch, &j) != 0)
+			break;
 	return ret;
 }
 
@@ -1637,6 +1670,7 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 	struct ip6t_entry *de;
 	unsigned int origsize;
 	int ret, h;
+	struct xt_entry_match *ematch;
 
 	ret = 0;
 	origsize = *size;
@@ -1647,8 +1681,11 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 	*dstptr += sizeof(struct ip6t_entry);
 	*size += sizeof(struct ip6t_entry) - sizeof(struct compat_ip6t_entry);
 
-	ret = COMPAT_IP6T_MATCH_ITERATE(e, xt_compat_match_from_user,
-					dstptr, size);
+	xt_ematch_foreach(ematch, e) {
+		ret = xt_compat_match_from_user(ematch, dstptr, size);
+		if (ret != 0)
+			break;
+	}
 	if (ret)
 		return ret;
 	de->target_offset = e->target_offset - (origsize - *size);
@@ -1670,8 +1707,9 @@ static int compat_check_entry(struct ip6t_entry *e, struct net *net,
 			      const char *name)
 {
 	unsigned int j;
-	int ret;
+	int ret = 0;
 	struct xt_mtchk_param mtpar;
+	struct xt_entry_match *ematch;
 
 	j = 0;
 	mtpar.net	= net;
@@ -1679,7 +1717,11 @@ static int compat_check_entry(struct ip6t_entry *e, struct net *net,
 	mtpar.entryinfo = &e->ipv6;
 	mtpar.hook_mask = e->comefrom;
 	mtpar.family    = NFPROTO_IPV6;
-	ret = IP6T_MATCH_ITERATE(e, check_match, &mtpar, &j);
+	xt_ematch_foreach(ematch, e) {
+		ret = check_match(ematch, &mtpar, &j);
+		if (ret != 0)
+			break;
+	}
 	if (ret)
 		goto cleanup_matches;
 
@@ -1689,7 +1731,9 @@ static int compat_check_entry(struct ip6t_entry *e, struct net *net,
 	return 0;
 
  cleanup_matches:
-	IP6T_MATCH_ITERATE(e, cleanup_match, net, &j);
+	xt_ematch_foreach(ematch, e)
+		if (cleanup_match(ematch, net, &j) != 0)
+			break;
 	return ret;
 }
 
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 6f21b43..0e357ac 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -239,6 +239,7 @@ static bool tcpmss_tg4_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_tcpmss_info *info = par->targinfo;
 	const struct ipt_entry *e = par->entryinfo;
+	const struct xt_entry_match *ematch;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU &&
 	    (par->hook_mask & ~((1 << NF_INET_FORWARD) |
@@ -248,8 +249,9 @@ static bool tcpmss_tg4_check(const struct xt_tgchk_param *par)
 		       "FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return false;
 	}
-	if (IPT_MATCH_ITERATE(e, find_syn_match))
-		return true;
+	xt_ematch_foreach(ematch, e)
+		if (find_syn_match(ematch))
+			return true;
 	printk("xt_TCPMSS: Only works on TCP SYN packets\n");
 	return false;
 }
@@ -259,6 +261,7 @@ static bool tcpmss_tg6_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_tcpmss_info *info = par->targinfo;
 	const struct ip6t_entry *e = par->entryinfo;
+	const struct xt_entry_match *ematch;
 
 	if (info->mss == XT_TCPMSS_CLAMP_PMTU &&
 	    (par->hook_mask & ~((1 << NF_INET_FORWARD) |
@@ -268,8 +271,9 @@ static bool tcpmss_tg6_check(const struct xt_tgchk_param *par)
 		       "FORWARD, OUTPUT and POSTROUTING hooks\n");
 		return false;
 	}
-	if (IP6T_MATCH_ITERATE(e, find_syn_match))
-		return true;
+	xt_ematch_foreach(ematch, e)
+		if (find_syn_match(ematch))
+			return true;
 	printk("xt_TCPMSS: Only works on TCP SYN packets\n");
 	return false;
 }
