From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/29] netfilter: conntrack: rename nf_ct_iterate_cleanup
Date: Fri, 30 Jun 2017 00:53:03 +0200
Message-ID: <1498776807-11124-6-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57590 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752124AbdF2Wxr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 29 Jun 2017 18:53:47 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 1FB63BDF5F
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0E78CD1D96
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 70554D1D96
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2017 00:53:27 +0200 (CEST)
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

There are several places where we needlesly call nf_ct_iterate_cleanup,
we should instead iterate the full table at module unload time.

This is a leftover from back when the conntrack table got duplicated
per net namespace.

So rename nf_ct_iterate_cleanup to nf_ct_iterate_cleanup_net.
A later patch will then add a non-net variant.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h        |  6 +++---
 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c |  4 ++--
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c | 10 +++++-----
 net/netfilter/nf_conntrack_core.c           | 10 +++++-----
 net/netfilter/nf_conntrack_netlink.c        |  4 ++--
 net/netfilter/nf_conntrack_proto.c          |  4 ++--
 net/netfilter/nf_nat_core.c                 |  6 +++---
 7 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 8ece3612d0cd..f21180ea4558 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -225,9 +225,9 @@ extern s32 (*nf_ct_nat_offset)(const struct nf_conn *ct,
 			       u32 seq);
 
 /* Iterate over all conntracks: if iter returns true, it's deleted. */
-void nf_ct_iterate_cleanup(struct net *net,
-			   int (*iter)(struct nf_conn *i, void *data),
-			   void *data, u32 portid, int report);
+void nf_ct_iterate_cleanup_net(struct net *net,
+			       int (*iter)(struct nf_conn *i, void *data),
+			       void *data, u32 portid, int report);
 
 struct nf_conntrack_zone;
 
diff --git a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
index dc1dea15c1b4..f39037fca923 100644
--- a/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
@@ -98,8 +98,8 @@ static int masq_device_event(struct notifier_block *this,
 		 */
 		NF_CT_ASSERT(dev->ifindex != 0);
 
-		nf_ct_iterate_cleanup(net, device_cmp,
-				      (void *)(long)dev->ifindex, 0, 0);
+		nf_ct_iterate_cleanup_net(net, device_cmp,
+					  (void *)(long)dev->ifindex, 0, 0);
 	}
 
 	return NOTIFY_DONE;
diff --git a/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
index 2297c9f073ba..d7b679037bae 100644
--- a/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
@@ -75,8 +75,8 @@ static int masq_device_event(struct notifier_block *this,
 	struct net *net = dev_net(dev);
 
 	if (event == NETDEV_DOWN)
-		nf_ct_iterate_cleanup(net, device_cmp,
-				      (void *)(long)dev->ifindex, 0, 0);
+		nf_ct_iterate_cleanup_net(net, device_cmp,
+					  (void *)(long)dev->ifindex, 0, 0);
 
 	return NOTIFY_DONE;
 }
@@ -99,7 +99,7 @@ static void iterate_cleanup_work(struct work_struct *work)
 	w = container_of(work, struct masq_dev_work, work);
 
 	index = w->ifindex;
-	nf_ct_iterate_cleanup(w->net, device_cmp, (void *)index, 0, 0);
+	nf_ct_iterate_cleanup_net(w->net, device_cmp, (void *)index, 0, 0);
 
 	put_net(w->net);
 	kfree(w);
@@ -110,12 +110,12 @@ static void iterate_cleanup_work(struct work_struct *work)
 /* ipv6 inet notifier is an atomic notifier, i.e. we cannot
  * schedule.
  *
- * Unfortunately, nf_ct_iterate_cleanup can run for a long
+ * Unfortunately, nf_ct_iterate_cleanup_net can run for a long
  * time if there are lots of conntracks and the system
  * handles high softirq load, so it frequently calls cond_resched
  * while iterating the conntrack table.
  *
- * So we defer nf_ct_iterate_cleanup walk to the system workqueue.
+ * So we defer nf_ct_iterate_cleanup_net walk to the system workqueue.
  *
  * As we can have 'a lot' of inet_events (depending on amount
  * of ipv6 addresses being deleted), we also need to add an upper
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index e847dbaa0c6b..2730f9df33b7 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1634,9 +1634,9 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 	return ct;
 }
 
-void nf_ct_iterate_cleanup(struct net *net,
-			   int (*iter)(struct nf_conn *i, void *data),
-			   void *data, u32 portid, int report)
+void nf_ct_iterate_cleanup_net(struct net *net,
+			       int (*iter)(struct nf_conn *i, void *data),
+			       void *data, u32 portid, int report)
 {
 	struct nf_conn *ct;
 	unsigned int bucket = 0;
@@ -1654,7 +1654,7 @@ void nf_ct_iterate_cleanup(struct net *net,
 		cond_resched();
 	}
 }
-EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup);
+EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup_net);
 
 static int kill_all(struct nf_conn *i, void *data)
 {
@@ -1723,7 +1723,7 @@ void nf_conntrack_cleanup_net_list(struct list_head *net_exit_list)
 i_see_dead_people:
 	busy = 0;
 	list_for_each_entry(net, net_exit_list, exit_list) {
-		nf_ct_iterate_cleanup(net, kill_all, NULL, 0, 0);
+		nf_ct_iterate_cleanup_net(net, kill_all, NULL, 0, 0);
 		if (atomic_read(&net->ct.count) != 0)
 			busy = 1;
 	}
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index f08604dd1a59..e1eca47105bd 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1117,8 +1117,8 @@ static int ctnetlink_flush_conntrack(struct net *net,
 			return PTR_ERR(filter);
 	}
 
-	nf_ct_iterate_cleanup(net, ctnetlink_filter_match, filter,
-			      portid, report);
+	nf_ct_iterate_cleanup_net(net, ctnetlink_filter_match, filter,
+				  portid, report);
 	kfree(filter);
 
 	return 0;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 2de6c1fe3261..b7d01f27d463 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -282,7 +282,7 @@ void nf_ct_l3proto_pernet_unregister(struct net *net,
 		proto->net_ns_put(net);
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(net, kill_l3proto, proto, 0, 0);
+	nf_ct_iterate_cleanup_net(net, kill_l3proto, proto, 0, 0);
 }
 EXPORT_SYMBOL_GPL(nf_ct_l3proto_pernet_unregister);
 
@@ -450,7 +450,7 @@ void nf_ct_l4proto_pernet_unregister_one(struct net *net,
 	nf_ct_l4proto_unregister_sysctl(net, pn, l4proto);
 
 	/* Remove all contrack entries for this protocol */
-	nf_ct_iterate_cleanup(net, kill_l4proto, l4proto, 0, 0);
+	nf_ct_iterate_cleanup_net(net, kill_l4proto, l4proto, 0, 0);
 }
 EXPORT_SYMBOL_GPL(nf_ct_l4proto_pernet_unregister_one);
 
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index ef0be325a0c6..daf5b22c07f8 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -586,7 +586,7 @@ static void nf_nat_l4proto_clean(u8 l3proto, u8 l4proto)
 
 	rtnl_lock();
 	for_each_net(net)
-		nf_ct_iterate_cleanup(net, nf_nat_proto_remove, &clean, 0, 0);
+		nf_ct_iterate_cleanup_net(net, nf_nat_proto_remove, &clean, 0, 0);
 	rtnl_unlock();
 }
 
@@ -600,7 +600,7 @@ static void nf_nat_l3proto_clean(u8 l3proto)
 	rtnl_lock();
 
 	for_each_net(net)
-		nf_ct_iterate_cleanup(net, nf_nat_proto_remove, &clean, 0, 0);
+		nf_ct_iterate_cleanup_net(net, nf_nat_proto_remove, &clean, 0, 0);
 	rtnl_unlock();
 }
 
@@ -826,7 +826,7 @@ static void __net_exit nf_nat_net_exit(struct net *net)
 {
 	struct nf_nat_proto_clean clean = {};
 
-	nf_ct_iterate_cleanup(net, nf_nat_proto_clean, &clean, 0, 0);
+	nf_ct_iterate_cleanup_net(net, nf_nat_proto_clean, &clean, 0, 0);
 }
 
 static struct pernet_operations nf_nat_net_ops = {
-- 
2.1.4
