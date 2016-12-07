From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 24/50] netfilter: x_tables: pass xt_counters struct to counter allocator
Date: Wed,  7 Dec 2016 22:52:30 +0100
Message-ID: <1481147576-5690-25-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60212 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933368AbcLGVxp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:45 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 65A46A7E2F
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:39 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 4E636DA863
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:39 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 18294DA849
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:37 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Keeps some noise away from a followup patch.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h | 27 +--------------------------
 net/ipv4/netfilter/arp_tables.c    |  5 +----
 net/ipv4/netfilter/ip_tables.c     |  5 +----
 net/ipv6/netfilter/ip6_tables.c    |  5 +----
 net/netfilter/x_tables.c           | 30 ++++++++++++++++++++++++++++++
 5 files changed, 34 insertions(+), 38 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 6e61edeb68e3..05a94bd32c55 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -404,32 +404,7 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 }
 
 
-/* On SMP, ip(6)t_entry->counters.pcnt holds address of the
- * real (percpu) counter.  On !SMP, its just the packet count,
- * so nothing needs to be done there.
- *
- * xt_percpu_counter_alloc returns the address of the percpu
- * counter, or 0 on !SMP. We force an alignment of 16 bytes
- * so that bytes/packets share a common cache line.
- *
- * Hence caller must use IS_ERR_VALUE to check for error, this
- * allows us to return 0 for single core systems without forcing
- * callers to deal with SMP vs. NONSMP issues.
- */
-static inline unsigned long xt_percpu_counter_alloc(void)
-{
-	if (nr_cpu_ids > 1) {
-		void __percpu *res = __alloc_percpu(sizeof(struct xt_counters),
-						    sizeof(struct xt_counters));
-
-		if (res == NULL)
-			return -ENOMEM;
-
-		return (__force unsigned long) res;
-	}
-
-	return 0;
-}
+bool xt_percpu_counter_alloc(struct xt_counters *counters);
 void xt_percpu_counter_free(struct xt_counters *cnt);
 
 static inline struct xt_counters *
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 019f8e8dda6d..808deb275ceb 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -415,13 +415,10 @@ find_check_entry(struct arpt_entry *e, const char *name, unsigned int size)
 {
 	struct xt_entry_target *t;
 	struct xt_target *target;
-	unsigned long pcnt;
 	int ret;
 
-	pcnt = xt_percpu_counter_alloc();
-	if (IS_ERR_VALUE(pcnt))
+	if (!xt_percpu_counter_alloc(&e->counters))
 		return -ENOMEM;
-	e->counters.pcnt = pcnt;
 
 	t = arpt_get_target(e);
 	target = xt_request_find_target(NFPROTO_ARP, t->u.user.name,
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index acc9a0c45bdf..a48430d3420f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -539,12 +539,9 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	unsigned int j;
 	struct xt_mtchk_param mtpar;
 	struct xt_entry_match *ematch;
-	unsigned long pcnt;
 
-	pcnt = xt_percpu_counter_alloc();
-	if (IS_ERR_VALUE(pcnt))
+	if (!xt_percpu_counter_alloc(&e->counters))
 		return -ENOMEM;
-	e->counters.pcnt = pcnt;
 
 	j = 0;
 	mtpar.net	= net;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 88b56a98905b..a5a92083fd62 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -570,12 +570,9 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 	unsigned int j;
 	struct xt_mtchk_param mtpar;
 	struct xt_entry_match *ematch;
-	unsigned long pcnt;
 
-	pcnt = xt_percpu_counter_alloc();
-	if (IS_ERR_VALUE(pcnt))
+	if (!xt_percpu_counter_alloc(&e->counters))
 		return -ENOMEM;
-	e->counters.pcnt = pcnt;
 
 	j = 0;
 	mtpar.net	= net;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 0580029eb0ee..be5e83047594 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1615,6 +1615,36 @@ void xt_proto_fini(struct net *net, u_int8_t af)
 }
 EXPORT_SYMBOL_GPL(xt_proto_fini);
 
+/**
+ * xt_percpu_counter_alloc - allocate x_tables rule counter
+ *
+ * @counter: pointer to counter struct inside the ip(6)/arpt_entry struct
+ *
+ * On SMP, the packet counter [ ip(6)t_entry->counters.pcnt ] will then
+ * contain the address of the real (percpu) counter.
+ *
+ * Rule evaluation needs to use xt_get_this_cpu_counter() helper
+ * to fetch the real percpu counter.
+ *
+ * returns false on error.
+ */
+bool xt_percpu_counter_alloc(struct xt_counters *counter)
+{
+	void __percpu *res;
+
+	if (nr_cpu_ids <= 1)
+		return true;
+
+	res = __alloc_percpu(sizeof(struct xt_counters),
+			     sizeof(struct xt_counters));
+	if (!res)
+		return false;
+
+	counter->pcnt = (__force unsigned long)res;
+	return true;
+}
+EXPORT_SYMBOL_GPL(xt_percpu_counter_alloc);
+
 void xt_percpu_counter_free(struct xt_counters *counters)
 {
 	unsigned long pcnt = counters->pcnt;
-- 
2.1.4
