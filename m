From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/23] netfilter: x_tables: xt_compat_match_from_user doesn't need a retval
Date: Fri, 22 Apr 2016 15:39:44 +0200
Message-ID: <1461332394-3994-14-git-send-email-pablo@netfilter.org>
References: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45276 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753918AbcDVNkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Apr 2016 09:40:21 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 3F08B4B9F5
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:19 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 27BA29D114
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:19 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 193AF9D114
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 15:40:13 +0200 (CEST)
In-Reply-To: <1461332394-3994-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Always returned 0.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |  2 +-
 net/ipv4/netfilter/arp_tables.c    | 17 +++++------------
 net/ipv4/netfilter/ip_tables.c     | 26 +++++++++-----------------
 net/ipv6/netfilter/ip6_tables.c    | 27 +++++++++------------------
 net/netfilter/x_tables.c           |  5 ++---
 5 files changed, 26 insertions(+), 51 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 30cfb1e..e2da9b9 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -484,7 +484,7 @@ void xt_compat_init_offsets(u_int8_t af, unsigned int number);
 int xt_compat_calc_jump(u_int8_t af, unsigned int offset);
 
 int xt_compat_match_offset(const struct xt_match *match);
-int xt_compat_match_from_user(struct xt_entry_match *m, void **dstptr,
+void xt_compat_match_from_user(struct xt_entry_match *m, void **dstptr,
 			      unsigned int *size);
 int xt_compat_match_to_user(const struct xt_entry_match *m,
 			    void __user **dstptr, unsigned int *size);
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 1d1386d..be514c6 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1310,7 +1310,7 @@ out:
 	return ret;
 }
 
-static int
+static void
 compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
 			    unsigned int *size,
 			    struct xt_table_info *newinfo, unsigned char *base)
@@ -1319,9 +1319,8 @@ compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
 	struct xt_target *target;
 	struct arpt_entry *de;
 	unsigned int origsize;
-	int ret, h;
+	int h;
 
-	ret = 0;
 	origsize = *size;
 	de = (struct arpt_entry *)*dstptr;
 	memcpy(de, e, sizeof(struct arpt_entry));
@@ -1342,7 +1341,6 @@ compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
 		if ((unsigned char *)de - base < newinfo->underflow[h])
 			newinfo->underflow[h] -= origsize - *size;
 	}
-	return ret;
 }
 
 static int translate_compat_table(struct xt_table_info **pinfo,
@@ -1421,16 +1419,11 @@ static int translate_compat_table(struct xt_table_info **pinfo,
 	entry1 = newinfo->entries;
 	pos = entry1;
 	size = compatr->size;
-	xt_entry_foreach(iter0, entry0, compatr->size) {
-		ret = compat_copy_entry_from_user(iter0, &pos, &size,
-						  newinfo, entry1);
-		if (ret != 0)
-			break;
-	}
+	xt_entry_foreach(iter0, entry0, compatr->size)
+		compat_copy_entry_from_user(iter0, &pos, &size,
+					    newinfo, entry1);
 	xt_compat_flush_offsets(NFPROTO_ARP);
 	xt_compat_unlock(NFPROTO_ARP);
-	if (ret)
-		goto free_newinfo;
 
 	ret = -ELOOP;
 	if (!mark_source_chains(newinfo, compatr->valid_hooks, entry1))
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index d7041860..5c20eef 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1568,7 +1568,7 @@ release_matches:
 	return ret;
 }
 
-static int
+static void
 compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 			    unsigned int *size,
 			    struct xt_table_info *newinfo, unsigned char *base)
@@ -1577,10 +1577,9 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 	struct xt_target *target;
 	struct ipt_entry *de;
 	unsigned int origsize;
-	int ret, h;
+	int h;
 	struct xt_entry_match *ematch;
 
-	ret = 0;
 	origsize = *size;
 	de = (struct ipt_entry *)*dstptr;
 	memcpy(de, e, sizeof(struct ipt_entry));
@@ -1589,11 +1588,9 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 	*dstptr += sizeof(struct ipt_entry);
 	*size += sizeof(struct ipt_entry) - sizeof(struct compat_ipt_entry);
 
-	xt_ematch_foreach(ematch, e) {
-		ret = xt_compat_match_from_user(ematch, dstptr, size);
-		if (ret != 0)
-			return ret;
-	}
+	xt_ematch_foreach(ematch, e)
+		xt_compat_match_from_user(ematch, dstptr, size);
+
 	de->target_offset = e->target_offset - (origsize - *size);
 	t = compat_ipt_get_target(e);
 	target = t->u.kernel.target;
@@ -1606,7 +1603,6 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 		if ((unsigned char *)de - base < newinfo->underflow[h])
 			newinfo->underflow[h] -= origsize - *size;
 	}
-	return ret;
 }
 
 static int
@@ -1729,16 +1725,12 @@ translate_compat_table(struct net *net,
 	entry1 = newinfo->entries;
 	pos = entry1;
 	size = compatr->size;
-	xt_entry_foreach(iter0, entry0, compatr->size) {
-		ret = compat_copy_entry_from_user(iter0, &pos, &size,
-						  newinfo, entry1);
-		if (ret != 0)
-			break;
-	}
+	xt_entry_foreach(iter0, entry0, compatr->size)
+		compat_copy_entry_from_user(iter0, &pos, &size,
+					    newinfo, entry1);
+
 	xt_compat_flush_offsets(AF_INET);
 	xt_compat_unlock(AF_INET);
-	if (ret)
-		goto free_newinfo;
 
 	ret = -ELOOP;
 	if (!mark_source_chains(newinfo, compatr->valid_hooks, entry1))
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 8d082c55..620d54c 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1580,7 +1580,7 @@ release_matches:
 	return ret;
 }
 
-static int
+static void
 compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 			    unsigned int *size,
 			    struct xt_table_info *newinfo, unsigned char *base)
@@ -1588,10 +1588,9 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 	struct xt_entry_target *t;
 	struct ip6t_entry *de;
 	unsigned int origsize;
-	int ret, h;
+	int h;
 	struct xt_entry_match *ematch;
 
-	ret = 0;
 	origsize = *size;
 	de = (struct ip6t_entry *)*dstptr;
 	memcpy(de, e, sizeof(struct ip6t_entry));
@@ -1600,11 +1599,9 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 	*dstptr += sizeof(struct ip6t_entry);
 	*size += sizeof(struct ip6t_entry) - sizeof(struct compat_ip6t_entry);
 
-	xt_ematch_foreach(ematch, e) {
-		ret = xt_compat_match_from_user(ematch, dstptr, size);
-		if (ret != 0)
-			return ret;
-	}
+	xt_ematch_foreach(ematch, e)
+		xt_compat_match_from_user(ematch, dstptr, size);
+
 	de->target_offset = e->target_offset - (origsize - *size);
 	t = compat_ip6t_get_target(e);
 	xt_compat_target_from_user(t, dstptr, size);
@@ -1616,7 +1613,6 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 		if ((unsigned char *)de - base < newinfo->underflow[h])
 			newinfo->underflow[h] -= origsize - *size;
 	}
-	return ret;
 }
 
 static int compat_check_entry(struct ip6t_entry *e, struct net *net,
@@ -1737,17 +1733,12 @@ translate_compat_table(struct net *net,
 	}
 	entry1 = newinfo->entries;
 	pos = entry1;
-	size = compatr->size;
-	xt_entry_foreach(iter0, entry0, compatr->size) {
-		ret = compat_copy_entry_from_user(iter0, &pos, &size,
-						  newinfo, entry1);
-		if (ret != 0)
-			break;
-	}
+	xt_entry_foreach(iter0, entry0, compatr->size)
+		compat_copy_entry_from_user(iter0, &pos, &size,
+					    newinfo, entry1);
+
 	xt_compat_flush_offsets(AF_INET6);
 	xt_compat_unlock(AF_INET6);
-	if (ret)
-		goto free_newinfo;
 
 	ret = -ELOOP;
 	if (!mark_source_chains(newinfo, compatr->valid_hooks, entry1))
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index f9aa971..7e7173b 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -526,8 +526,8 @@ int xt_compat_match_offset(const struct xt_match *match)
 }
 EXPORT_SYMBOL_GPL(xt_compat_match_offset);
 
-int xt_compat_match_from_user(struct xt_entry_match *m, void **dstptr,
-			      unsigned int *size)
+void xt_compat_match_from_user(struct xt_entry_match *m, void **dstptr,
+			       unsigned int *size)
 {
 	const struct xt_match *match = m->u.kernel.match;
 	struct compat_xt_entry_match *cm = (struct compat_xt_entry_match *)m;
@@ -549,7 +549,6 @@ int xt_compat_match_from_user(struct xt_entry_match *m, void **dstptr,
 
 	*size += off;
 	*dstptr += msize;
-	return 0;
 }
 EXPORT_SYMBOL_GPL(xt_compat_match_from_user);
 
-- 
2.1.4
