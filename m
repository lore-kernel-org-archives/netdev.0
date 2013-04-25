From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/10] ipvs: fix the remaining sparse warnings in ip_vs_ctl.c
Date: Thu, 25 Apr 2013 02:22:14 +0200
Message-ID: <1366849341-10466-4-git-send-email-pablo@netfilter.org>
References: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41117 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932167Ab3DYAWf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 20:22:35 -0400
In-Reply-To: <1366849341-10466-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

- RCU annotations for ip_vs_info_seq_start and _stop
- __percpu for cpustats
- properly dereference svc->pe in ip_vs_genl_fill_service

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5a65444..64075a7 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -1937,8 +1937,8 @@ static struct ip_vs_service *ip_vs_info_array(struct seq_file *seq, loff_t pos)
 }
 
 static void *ip_vs_info_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU)
 {
-
 	rcu_read_lock();
 	return *pos ? ip_vs_info_array(seq, *pos - 1) : SEQ_START_TOKEN;
 }
@@ -1993,6 +1993,7 @@ static void *ip_vs_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void ip_vs_info_seq_stop(struct seq_file *seq, void *v)
+	__releases(RCU)
 {
 	rcu_read_unlock();
 }
@@ -2137,7 +2138,7 @@ static int ip_vs_stats_percpu_show(struct seq_file *seq, void *v)
 {
 	struct net *net = seq_file_single_net(seq);
 	struct ip_vs_stats *tot_stats = &net_ipvs(net)->tot_stats;
-	struct ip_vs_cpu_stats *cpustats = tot_stats->cpustats;
+	struct ip_vs_cpu_stats __percpu *cpustats = tot_stats->cpustats;
 	struct ip_vs_stats_user rates;
 	int i;
 
@@ -2874,6 +2875,7 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 				   struct ip_vs_service *svc)
 {
 	struct ip_vs_scheduler *sched;
+	struct ip_vs_pe *pe;
 	struct nlattr *nl_service;
 	struct ip_vs_flags flags = { .flags = svc->flags,
 				     .mask = ~0 };
@@ -2895,9 +2897,9 @@ static int ip_vs_genl_fill_service(struct sk_buff *skb,
 	}
 
 	sched = rcu_dereference_protected(svc->scheduler, 1);
+	pe = rcu_dereference_protected(svc->pe, 1);
 	if (nla_put_string(skb, IPVS_SVC_ATTR_SCHED_NAME, sched->name) ||
-	    (svc->pe &&
-	     nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, svc->pe->name)) ||
+	    (pe && nla_put_string(skb, IPVS_SVC_ATTR_PE_NAME, pe->name)) ||
 	    nla_put(skb, IPVS_SVC_ATTR_FLAGS, sizeof(flags), &flags) ||
 	    nla_put_u32(skb, IPVS_SVC_ATTR_TIMEOUT, svc->timeout / HZ) ||
 	    nla_put_u32(skb, IPVS_SVC_ATTR_NETMASK, svc->netmask))
-- 
1.7.10.4
