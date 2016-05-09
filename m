From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/36] netfilter: fix IS_ERR_VALUE usage
Date: Mon,  9 May 2016 20:46:31 +0200
Message-ID: <1462819614-5402-14-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45732 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594AbcEISrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:23 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id B2875E8E89
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:21 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A2C3E13471F
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:21 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9EBC5134711
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:14 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a forward-port of the original patch from Andrzej Hajda,
he said:

"IS_ERR_VALUE should be used only with unsigned long type.
Otherwise it can work incorrectly. To achieve this function
xt_percpu_counter_alloc is modified to return unsigned long,
and its result is assigned to temporary variable to perform
error checking, before assigning to .pcnt field.

The patch follows conclusion from discussion on LKML [1][2].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2120927
[2]: http://permalink.gmane.org/gmane.linux.kernel/2150581"

Original patch from Andrzej is here:

http://patchwork.ozlabs.org/patch/582970/

This patch has clashed with input validation fixes for x_tables.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h | 6 +++---
 net/ipv4/netfilter/arp_tables.c    | 6 ++++--
 net/ipv4/netfilter/ip_tables.c     | 6 ++++--
 net/ipv6/netfilter/ip6_tables.c    | 6 ++++--
 4 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 4dd9306..dc4f58a 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -380,16 +380,16 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
  * allows us to return 0 for single core systems without forcing
  * callers to deal with SMP vs. NONSMP issues.
  */
-static inline u64 xt_percpu_counter_alloc(void)
+static inline unsigned long xt_percpu_counter_alloc(void)
 {
 	if (nr_cpu_ids > 1) {
 		void __percpu *res = __alloc_percpu(sizeof(struct xt_counters),
 						    sizeof(struct xt_counters));
 
 		if (res == NULL)
-			return (u64) -ENOMEM;
+			return -ENOMEM;
 
-		return (u64) (__force unsigned long) res;
+		return (__force unsigned long) res;
 	}
 
 	return 0;
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 60f5161..3355ed7 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -513,11 +513,13 @@ find_check_entry(struct arpt_entry *e, const char *name, unsigned int size)
 {
 	struct xt_entry_target *t;
 	struct xt_target *target;
+	unsigned long pcnt;
 	int ret;
 
-	e->counters.pcnt = xt_percpu_counter_alloc();
-	if (IS_ERR_VALUE(e->counters.pcnt))
+	pcnt = xt_percpu_counter_alloc();
+	if (IS_ERR_VALUE(pcnt))
 		return -ENOMEM;
+	e->counters.pcnt = pcnt;
 
 	t = arpt_get_target(e);
 	target = xt_request_find_target(NFPROTO_ARP, t->u.user.name,
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 735d1ee..21ccc19 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -656,10 +656,12 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	unsigned int j;
 	struct xt_mtchk_param mtpar;
 	struct xt_entry_match *ematch;
+	unsigned long pcnt;
 
-	e->counters.pcnt = xt_percpu_counter_alloc();
-	if (IS_ERR_VALUE(e->counters.pcnt))
+	pcnt = xt_percpu_counter_alloc();
+	if (IS_ERR_VALUE(pcnt))
 		return -ENOMEM;
+	e->counters.pcnt = pcnt;
 
 	j = 0;
 	mtpar.net	= net;
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 73e606c..17874e8 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -669,10 +669,12 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 	unsigned int j;
 	struct xt_mtchk_param mtpar;
 	struct xt_entry_match *ematch;
+	unsigned long pcnt;
 
-	e->counters.pcnt = xt_percpu_counter_alloc();
-	if (IS_ERR_VALUE(e->counters.pcnt))
+	pcnt = xt_percpu_counter_alloc();
+	if (IS_ERR_VALUE(pcnt))
 		return -ENOMEM;
+	e->counters.pcnt = pcnt;
 
 	j = 0;
 	mtpar.net	= net;
-- 
2.1.4
