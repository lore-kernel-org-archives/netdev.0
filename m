From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: fix percpu memory leaks
Date: Mon, 02 Nov 2015 09:03:11 -0800
Message-ID: <1446483791.23275.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34393 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753682AbbKBRDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 12:03:12 -0500
Received: by padec8 with SMTP id ec8so44666836pad.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 09:03:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

This patch fixes following problems :

1) percpu_counter_init() can return an error, therefore
  init_frag_mem_limit() must propagate this error so that
  inet_frags_init_net() can do the same up to its callers.

2) If ip[46]_frags_ns_ctl_register() fail, we must unwind
   properly and free the percpu_counter.

Without this fix, we leave freed object in percpu_counters
global list (if CONFIG_HOTPLUG_CPU) leading to crashes.

This bug was detected by KASAN and syzkaller tool
(http://github.com/google/syzkaller)

Fixes: 6d7b857d541e ("net: use lib/percpu_counter API for fragmentation mem accounting")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/net/inet_frag.h                 |   15 +++++++++------
 net/ieee802154/6lowpan/reassembly.c     |   11 ++++++++---
 net/ipv4/inet_fragment.c                |    6 ------
 net/ipv4/ip_fragment.c                  |   12 +++++++++---
 net/ipv6/netfilter/nf_conntrack_reasm.c |   12 +++++++++---
 net/ipv6/reassembly.c                   |   12 +++++++++---
 6 files changed, 44 insertions(+), 24 deletions(-)

diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
index 53eead2da743..ac42bbb37b2d 100644
--- a/include/net/inet_frag.h
+++ b/include/net/inet_frag.h
@@ -108,7 +108,15 @@ struct inet_frags {
 int inet_frags_init(struct inet_frags *);
 void inet_frags_fini(struct inet_frags *);
 
-void inet_frags_init_net(struct netns_frags *nf);
+static inline int inet_frags_init_net(struct netns_frags *nf)
+{
+	return percpu_counter_init(&nf->mem, 0, GFP_KERNEL);
+}
+static inline void inet_frags_uninit_net(struct netns_frags *nf)
+{
+	percpu_counter_destroy(&nf->mem);
+}
+
 void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f);
 
 void inet_frag_kill(struct inet_frag_queue *q, struct inet_frags *f);
@@ -154,11 +162,6 @@ static inline void add_frag_mem_limit(struct netns_frags *nf, int i)
 	__percpu_counter_add(&nf->mem, i, frag_percpu_counter_batch);
 }
 
-static inline void init_frag_mem_limit(struct netns_frags *nf)
-{
-	percpu_counter_init(&nf->mem, 0, GFP_KERNEL);
-}
-
 static inline unsigned int sum_frag_mem_limit(struct netns_frags *nf)
 {
 	unsigned int res;
diff --git a/net/ieee802154/6lowpan/reassembly.c b/net/ieee802154/6lowpan/reassembly.c
index 12e8cf4bda9f..6b437e8760d3 100644
--- a/net/ieee802154/6lowpan/reassembly.c
+++ b/net/ieee802154/6lowpan/reassembly.c
@@ -580,14 +580,19 @@ static int __net_init lowpan_frags_init_net(struct net *net)
 {
 	struct netns_ieee802154_lowpan *ieee802154_lowpan =
 		net_ieee802154_lowpan(net);
+	int res;
 
 	ieee802154_lowpan->frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
 	ieee802154_lowpan->frags.low_thresh = IPV6_FRAG_LOW_THRESH;
 	ieee802154_lowpan->frags.timeout = IPV6_FRAG_TIMEOUT;
 
-	inet_frags_init_net(&ieee802154_lowpan->frags);
-
-	return lowpan_frags_ns_sysctl_register(net);
+	res = inet_frags_init_net(&ieee802154_lowpan->frags);
+	if (res)
+		return res;
+	res = lowpan_frags_ns_sysctl_register(net);
+	if (res)
+		inet_frags_uninit_net(&ieee802154_lowpan->frags);
+	return res;
 }
 
 static void __net_exit lowpan_frags_exit_net(struct net *net)
diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
index d0a7c0319e3d..fe144dae7372 100644
--- a/net/ipv4/inet_fragment.c
+++ b/net/ipv4/inet_fragment.c
@@ -209,12 +209,6 @@ int inet_frags_init(struct inet_frags *f)
 }
 EXPORT_SYMBOL(inet_frags_init);
 
-void inet_frags_init_net(struct netns_frags *nf)
-{
-	init_frag_mem_limit(nf);
-}
-EXPORT_SYMBOL(inet_frags_init_net);
-
 void inet_frags_fini(struct inet_frags *f)
 {
 	cancel_work_sync(&f->frags_work);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 5482745d5d68..1fe55ae81781 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -839,6 +839,8 @@ static void __init ip4_frags_ctl_register(void)
 
 static int __net_init ipv4_frags_init_net(struct net *net)
 {
+	int res;
+
 	/* Fragment cache limits.
 	 *
 	 * The fragment memory accounting code, (tries to) account for
@@ -862,9 +864,13 @@ static int __net_init ipv4_frags_init_net(struct net *net)
 	 */
 	net->ipv4.frags.timeout = IP_FRAG_TIME;
 
-	inet_frags_init_net(&net->ipv4.frags);
-
-	return ip4_frags_ns_ctl_register(net);
+	res = inet_frags_init_net(&net->ipv4.frags);
+	if (res)
+		return res;
+	res = ip4_frags_ns_ctl_register(net);
+	if (res)
+		inet_frags_uninit_net(&net->ipv4.frags);
+	return res;
 }
 
 static void __net_exit ipv4_frags_exit_net(struct net *net)
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 99610547fccc..d5efeb87350e 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -648,12 +648,18 @@ EXPORT_SYMBOL_GPL(nf_ct_frag6_consume_orig);
 
 static int nf_ct_net_init(struct net *net)
 {
+	int res;
+
 	net->nf_frag.frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
 	net->nf_frag.frags.low_thresh = IPV6_FRAG_LOW_THRESH;
 	net->nf_frag.frags.timeout = IPV6_FRAG_TIMEOUT;
-	inet_frags_init_net(&net->nf_frag.frags);
-
-	return nf_ct_frag6_sysctl_register(net);
+	res = inet_frags_init_net(&net->nf_frag.frags);
+	if (res)
+		return res;
+	res = nf_ct_frag6_sysctl_register(net);
+	if (res)
+		inet_frags_uninit_net(&net->nf_frag.frags);
+	return res;
 }
 
 static void nf_ct_net_exit(struct net *net)
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index f1159bb76e0a..44e21a03cfc3 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -706,13 +706,19 @@ static void ip6_frags_sysctl_unregister(void)
 
 static int __net_init ipv6_frags_init_net(struct net *net)
 {
+	int res;
+
 	net->ipv6.frags.high_thresh = IPV6_FRAG_HIGH_THRESH;
 	net->ipv6.frags.low_thresh = IPV6_FRAG_LOW_THRESH;
 	net->ipv6.frags.timeout = IPV6_FRAG_TIMEOUT;
 
-	inet_frags_init_net(&net->ipv6.frags);
-
-	return ip6_frags_ns_sysctl_register(net);
+	res = inet_frags_init_net(&net->ipv6.frags);
+	if (res)
+		return res;
+	res = ip6_frags_ns_sysctl_register(net);
+	if (res)
+		inet_frags_uninit_net(&net->ipv6.frags);
+	return res;
 }
 
 static void __net_exit ipv6_frags_exit_net(struct net *net)
