From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/19] netfilter: nf_conntrack: remove duplicate code in ctnetlink
Date: Tue, 20 Aug 2013 12:54:40 +0200
Message-ID: <1376996091-3964-9-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60083 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751104Ab3HTKzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:10 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

ctnetlink contains copy-paste code from death_by_timeout.  In order to
avoid changing both places in upcoming event delivery patch,
export death_by_timeout functionality and use it in the ctnetlink code.

Based on earlier patch from Pablo Neira.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |    3 +--
 net/netfilter/nf_conntrack_core.c    |   29 ++++++++++++++++-------------
 net/netfilter/nf_conntrack_netlink.c |   18 +++---------------
 3 files changed, 20 insertions(+), 30 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 644d9c2..939aced 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -181,8 +181,7 @@ __nf_conntrack_find(struct net *net, u16 zone,
 		    const struct nf_conntrack_tuple *tuple);
 
 extern int nf_conntrack_hash_check_insert(struct nf_conn *ct);
-extern void nf_ct_delete_from_lists(struct nf_conn *ct);
-extern void nf_ct_dying_timeout(struct nf_conn *ct);
+bool nf_ct_delete(struct nf_conn *ct, u32 pid, int report);
 
 extern void nf_conntrack_flush_report(struct net *net, u32 portid, int report);
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index d32afaf..089e408 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -238,7 +238,7 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	nf_conntrack_free(ct);
 }
 
-void nf_ct_delete_from_lists(struct nf_conn *ct)
+static void nf_ct_delete_from_lists(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
 
@@ -253,7 +253,6 @@ void nf_ct_delete_from_lists(struct nf_conn *ct)
 			     &net->ct.dying);
 	spin_unlock_bh(&nf_conntrack_lock);
 }
-EXPORT_SYMBOL_GPL(nf_ct_delete_from_lists);
 
 static void death_by_event(unsigned long ul_conntrack)
 {
@@ -275,7 +274,7 @@ static void death_by_event(unsigned long ul_conntrack)
 	nf_ct_put(ct);
 }
 
-void nf_ct_dying_timeout(struct nf_conn *ct)
+static void nf_ct_dying_timeout(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *ecache = nf_ct_ecache_find(ct);
@@ -288,27 +287,33 @@ void nf_ct_dying_timeout(struct nf_conn *ct)
 		(prandom_u32() % net->ct.sysctl_events_retry_timeout);
 	add_timer(&ecache->timeout);
 }
-EXPORT_SYMBOL_GPL(nf_ct_dying_timeout);
 
-static void death_by_timeout(unsigned long ul_conntrack)
+bool nf_ct_delete(struct nf_conn *ct, u32 portid, int report)
 {
-	struct nf_conn *ct = (void *)ul_conntrack;
 	struct nf_conn_tstamp *tstamp;
 
 	tstamp = nf_conn_tstamp_find(ct);
 	if (tstamp && tstamp->stop == 0)
 		tstamp->stop = ktime_to_ns(ktime_get_real());
 
-	if (!test_bit(IPS_DYING_BIT, &ct->status) &&
-	    unlikely(nf_conntrack_event(IPCT_DESTROY, ct) < 0)) {
+	if (!nf_ct_is_dying(ct) &&
+	    unlikely(nf_conntrack_event_report(IPCT_DESTROY, ct,
+	    portid, report) < 0)) {
 		/* destroy event was not delivered */
 		nf_ct_delete_from_lists(ct);
 		nf_ct_dying_timeout(ct);
-		return;
+		return false;
 	}
 	set_bit(IPS_DYING_BIT, &ct->status);
 	nf_ct_delete_from_lists(ct);
 	nf_ct_put(ct);
+	return true;
+}
+EXPORT_SYMBOL_GPL(nf_ct_delete);
+
+static void death_by_timeout(unsigned long ul_conntrack)
+{
+	nf_ct_delete((struct nf_conn *)ul_conntrack, 0, 0);
 }
 
 /*
@@ -643,10 +648,7 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 		return dropped;
 
 	if (del_timer(&ct->timeout)) {
-		death_by_timeout((unsigned long)ct);
-		/* Check if we indeed killed this entry. Reliable event
-		   delivery may have inserted it into the dying list. */
-		if (test_bit(IPS_DYING_BIT, &ct->status)) {
+		if (nf_ct_delete(ct, 0, 0)) {
 			dropped = 1;
 			NF_CT_STAT_INC_ATOMIC(net, early_drop);
 		}
@@ -1253,6 +1255,7 @@ void nf_ct_iterate_cleanup(struct net *net,
 		/* Time to push up daises... */
 		if (del_timer(&ct->timeout))
 			death_by_timeout((unsigned long)ct);
+
 		/* ... else the timer will get him soon. */
 
 		nf_ct_put(ct);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index edc410e..e842c0d 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1038,21 +1038,9 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		}
 	}
 
-	if (del_timer(&ct->timeout)) {
-		if (nf_conntrack_event_report(IPCT_DESTROY, ct,
-					      NETLINK_CB(skb).portid,
-					      nlmsg_report(nlh)) < 0) {
-			nf_ct_delete_from_lists(ct);
-			/* we failed to report the event, try later */
-			nf_ct_dying_timeout(ct);
-			nf_ct_put(ct);
-			return 0;
-		}
-		/* death_by_timeout would report the event again */
-		set_bit(IPS_DYING_BIT, &ct->status);
-		nf_ct_delete_from_lists(ct);
-		nf_ct_put(ct);
-	}
+	if (del_timer(&ct->timeout))
+		nf_ct_delete(ct, NETLINK_CB(skb).portid, nlmsg_report(nlh));
+
 	nf_ct_put(ct);
 
 	return 0;
-- 
1.7.10.4
