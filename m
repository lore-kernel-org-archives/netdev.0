From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 20/31: conntrack: don't report events on module removal
Date: Wed, 10 Jun 2009 21:46:47 +0200 (MEST)
Message-ID: <20090610194645.11112.90196.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33189 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761119AbZFJTqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:45 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 274d383b9c1906847a64bbb267b0183599ce86a0
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue Jun 2 20:08:38 2009 +0200

    netfilter: conntrack: don't report events on module removal
    
    During the module removal there are no possible event listeners
    since ctnetlink must be removed before to allow removing
    nf_conntrack. This patch removes the event reporting for the
    module removal case which is not of any use in the existing code.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index b909241..2ba36dd 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -203,7 +203,7 @@ __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple);
 
 extern void nf_conntrack_hash_insert(struct nf_conn *ct);
 
-extern void nf_conntrack_flush(struct net *net, u32 pid, int report);
+extern void nf_conntrack_flush_report(struct net *net, u32 pid, int report);
 
 extern bool nf_ct_get_tuplepr(const struct sk_buff *skb,
 			      unsigned int nhoff, u_int16_t l3num,
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 8020db6..f59c4ed 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1001,7 +1001,7 @@ struct __nf_ct_flush_report {
 	int report;
 };
 
-static int kill_all(struct nf_conn *i, void *data)
+static int kill_report(struct nf_conn *i, void *data)
 {
 	struct __nf_ct_flush_report *fr = (struct __nf_ct_flush_report *)data;
 
@@ -1013,6 +1013,11 @@ static int kill_all(struct nf_conn *i, void *data)
 	return 1;
 }
 
+static int kill_all(struct nf_conn *i, void *data)
+{
+	return 1;
+}
+
 void nf_ct_free_hashtable(void *hash, int vmalloced, unsigned int size)
 {
 	if (vmalloced)
@@ -1023,15 +1028,15 @@ void nf_ct_free_hashtable(void *hash, int vmalloced, unsigned int size)
 }
 EXPORT_SYMBOL_GPL(nf_ct_free_hashtable);
 
-void nf_conntrack_flush(struct net *net, u32 pid, int report)
+void nf_conntrack_flush_report(struct net *net, u32 pid, int report)
 {
 	struct __nf_ct_flush_report fr = {
 		.pid 	= pid,
 		.report = report,
 	};
-	nf_ct_iterate_cleanup(net, kill_all, &fr);
+	nf_ct_iterate_cleanup(net, kill_report, &fr);
 }
-EXPORT_SYMBOL_GPL(nf_conntrack_flush);
+EXPORT_SYMBOL_GPL(nf_conntrack_flush_report);
 
 static void nf_conntrack_cleanup_init_net(void)
 {
@@ -1045,7 +1050,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	nf_ct_event_cache_flush(net);
 	nf_conntrack_ecache_fini(net);
  i_see_dead_people:
-	nf_conntrack_flush(net, 0, 0);
+	nf_ct_iterate_cleanup(net, kill_all, NULL);
 	if (atomic_read(&net->ct.count) != 0) {
 		schedule();
 		goto i_see_dead_people;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 58fde0e..3a20de1 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -777,9 +777,9 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_REPLY, u3);
 	else {
 		/* Flush the whole table */
-		nf_conntrack_flush(&init_net, 
-				   NETLINK_CB(skb).pid, 
-				   nlmsg_report(nlh));
+		nf_conntrack_flush_report(&init_net,
+					 NETLINK_CB(skb).pid,
+					 nlmsg_report(nlh));
 		return 0;
 	}
 
