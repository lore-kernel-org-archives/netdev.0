From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/19] netfilter: nf_conntrack: don't send destroy events from iterator
Date: Tue, 20 Aug 2013 12:54:47 +0200
Message-ID: <1376996091-3964-16-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60121 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282Ab3HTKzQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:16 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Let nf_ct_delete handle delivery of the DESTROY event.

Based on earlier patch from Pablo Neira.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |    4 +++-
 net/ipv4/netfilter/ipt_MASQUERADE.c  |    2 +-
 net/ipv6/netfilter/ip6t_MASQUERADE.c |    2 +-
 net/netfilter/nf_conntrack_core.c    |   36 ++++------------------------------
 net/netfilter/nf_conntrack_proto.c   |    4 ++--
 net/netfilter/nf_nat_core.c          |    6 +++---
 6 files changed, 14 insertions(+), 40 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index e5eb8b6..0c1288a 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -248,7 +248,9 @@ extern void nf_ct_untracked_status_or(unsigned long bits);
 
 /* Iterate over all conntracks: if iter returns true, it's deleted. */
 extern void
-nf_ct_iterate_cleanup(struct net *net, int (*iter)(struct nf_conn *i, void *data), void *data);
+nf_ct_iterate_cleanup(struct net *net,
+		      int (*iter)(struct nf_conn *i, void *data),
+		      void *data, u32 portid, int report);
 extern void nf_conntrack_free(struct nf_conn *ct);
 extern struct nf_conn *
 nf_conntrack_alloc(struct net *net, u16 zone,
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 30e4de9..00352ce 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -118,7 +118,7 @@ static int masq_device_event(struct notifier_block *this,
 		NF_CT_ASSERT(dev->ifindex != 0);
 
 		nf_ct_iterate_cleanup(net, device_cmp,
-				      (void *)(long)dev->ifindex);
+				      (void *)(long)dev->ifindex, 0, 0);
 	}
 
 	return NOTIFY_DONE;
diff --git a/net/ipv6/netfilter/ip6t_MASQUERADE.c b/net/ipv6/netfilter/ip6t_MASQUERADE.c
index 47bff61..3e4e92d 100644
--- a/net/ipv6/netfilter/ip6t_MASQUERADE.c
+++ b/net/ipv6/netfilter/ip6t_MASQUERADE.c
@@ -76,7 +76,7 @@ static int masq_device_event(struct notifier_block *this,
 
 	if (event == NETDEV_DOWN)
 		nf_ct_iterate_cleanup(net, device_cmp,
-				      (void *)(long)dev->ifindex);
+				      (void *)(long)dev->ifindex, 0, 0);
 
 	return NOTIFY_DONE;
 }
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 0934611..da6f178 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1246,7 +1246,7 @@ found:
 
 void nf_ct_iterate_cleanup(struct net *net,
 			   int (*iter)(struct nf_conn *i, void *data),
-			   void *data)
+			   void *data, u32 portid, int report)
 {
 	struct nf_conn *ct;
 	unsigned int bucket = 0;
@@ -1254,7 +1254,7 @@ void nf_ct_iterate_cleanup(struct net *net,
 	while ((ct = get_next_corpse(net, iter, data, &bucket)) != NULL) {
 		/* Time to push up daises... */
 		if (del_timer(&ct->timeout))
-			death_by_timeout((unsigned long)ct);
+			nf_ct_delete(ct, portid, report);
 
 		/* ... else the timer will get him soon. */
 
@@ -1263,30 +1263,6 @@ void nf_ct_iterate_cleanup(struct net *net,
 }
 EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup);
 
-struct __nf_ct_flush_report {
-	u32 portid;
-	int report;
-};
-
-static int kill_report(struct nf_conn *i, void *data)
-{
-	struct __nf_ct_flush_report *fr = (struct __nf_ct_flush_report *)data;
-	struct nf_conn_tstamp *tstamp;
-
-	tstamp = nf_conn_tstamp_find(i);
-	if (tstamp && tstamp->stop == 0)
-		tstamp->stop = ktime_to_ns(ktime_get_real());
-
-	/* If we fail to deliver the event, death_by_timeout() will retry */
-	if (nf_conntrack_event_report(IPCT_DESTROY, i,
-				      fr->portid, fr->report) < 0)
-		return 1;
-
-	/* Avoid the delivery of the destroy event in death_by_timeout(). */
-	set_bit(IPS_DYING_BIT, &i->status);
-	return 1;
-}
-
 static int kill_all(struct nf_conn *i, void *data)
 {
 	return 1;
@@ -1304,11 +1280,7 @@ EXPORT_SYMBOL_GPL(nf_ct_free_hashtable);
 
 void nf_conntrack_flush_report(struct net *net, u32 portid, int report)
 {
-	struct __nf_ct_flush_report fr = {
-		.portid	= portid,
-		.report = report,
-	};
-	nf_ct_iterate_cleanup(net, kill_report, &fr);
+	nf_ct_iterate_cleanup(net, kill_all, NULL, portid, report);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_flush_report);
 
@@ -1389,7 +1361,7 @@ void nf_conntrack_cleanup_net_list(struct list_head *net_exit_list)
 i_see_dead_people:
 	busy = 0;
 	list_for_each_entry(net, net_exit_list, exit_list) {
-		nf_ct_iterate_cleanup(net, kill_all, NULL);
+		nf_ct_iterate_cleanup(net, kill_all, NULL, 0, 0);
 		nf_ct_release_dying_list(net);
 		if (atomic_read(&net->ct.count) != 0)
 			busy = 1;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 0ab9636..ce30041 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -281,7 +281,7 @@ void nf_ct_l3proto_pernet_unregister(struct net *net,
 	nf_ct_l3proto_unregister_sysctl(net, proto);
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(net, kill_l3proto, proto);
+	nf_ct_iterate_cleanup(net, kill_l3proto, proto, 0, 0);
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_unregister);
 
@@ -476,7 +476,7 @@ void nf_ct_l4proto_pernet_unregister(struct net *net,
 	nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto);
+	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto, 0, 0);
 }
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_pernet_unregister);
 
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 038eee5..6ff8083 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -497,7 +497,7 @@ static void nf_nat_l4proto_clean(u8 l3proto, u8 l4proto)
 
 	rtnl_lock();
 	for_each_net(net)
-		nf_ct_iterate_cleanup(net, nf_nat_proto_remove, &clean);
+		nf_ct_iterate_cleanup(net, nf_nat_proto_remove, &clean, 0, 0);
 	rtnl_unlock();
 }
 
@@ -511,7 +511,7 @@ static void nf_nat_l3proto_clean(u8 l3proto)
 	rtnl_lock();
 
 	for_each_net(net)
-		nf_ct_iterate_cleanup(net, nf_nat_proto_remove, &clean);
+		nf_ct_iterate_cleanup(net, nf_nat_proto_remove, &clean, 0, 0);
 	rtnl_unlock();
 }
 
@@ -749,7 +749,7 @@ static void __net_exit nf_nat_net_exit(struct net *net)
 {
 	struct nf_nat_proto_clean clean = {};
 
-	nf_ct_iterate_cleanup(net, &nf_nat_proto_remove, &clean);
+	nf_ct_iterate_cleanup(net, &nf_nat_proto_remove, &clean, 0, 0);
 	synchronize_rcu();
 	nf_ct_free_hashtable(net->ct.nat_bysource, net->ct.nat_htable_size);
 }
-- 
1.7.10.4
