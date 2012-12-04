From: pablo@netfilter.org
Subject: [PATCH 2/6] netfilter: nf_conntrack: improve nf_conn object traceability
Date: Tue,  4 Dec 2012 18:31:29 +0100
Message-ID: <1354642293-4114-3-git-send-email-pablo@netfilter.org>
References: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54424 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751347Ab2LDRbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 12:31:49 -0500
In-Reply-To: <1354642293-4114-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch modifies the conntrack subsystem so that all existing
allocated conntrack objects can be found in any of the following
places:

* the hash table, this is the typical place for alive conntrack objects.
* the unconfirmed list, this is the place for newly created conntrack objects
  that are still traversing the stack.
* the dying list, this is where you can find conntrack objects that are dying
  or that should die anytime soon (eg. once the destroy event is delivered to
  the conntrackd daemon).

Thus, we make sure that we follow the track for all existing conntrack
objects. This patch, together with some extension of the ctnetlink interface
to dump the content of the dying and unconfirmed lists, will help in case
to debug suspected nf_conn object leaks.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |    2 +-
 net/netfilter/nf_conntrack_core.c    |   25 +++++++++----------------
 net/netfilter/nf_conntrack_netlink.c |    2 +-
 3 files changed, 11 insertions(+), 18 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index f1494fe..caca0c4 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -182,7 +182,7 @@ __nf_conntrack_find(struct net *net, u16 zone,
 
 extern int nf_conntrack_hash_check_insert(struct nf_conn *ct);
 extern void nf_ct_delete_from_lists(struct nf_conn *ct);
-extern void nf_ct_insert_dying_list(struct nf_conn *ct);
+extern void nf_ct_dying_timeout(struct nf_conn *ct);
 
 extern void nf_conntrack_flush_report(struct net *net, u32 pid, int report);
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 0f241be..af17516 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -221,11 +221,9 @@ destroy_conntrack(struct nf_conntrack *nfct)
 	 * too. */
 	nf_ct_remove_expectations(ct);
 
-	/* We overload first tuple to link into unconfirmed list. */
-	if (!nf_ct_is_confirmed(ct)) {
-		BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode));
-		hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
-	}
+	/* We overload first tuple to link into unconfirmed or dying list.*/
+	BUG_ON(hlist_nulls_unhashed(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode));
+	hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
 
 	NF_CT_STAT_INC(net, delete);
 	spin_unlock_bh(&nf_conntrack_lock);
@@ -247,6 +245,9 @@ void nf_ct_delete_from_lists(struct nf_conn *ct)
 	 * Otherwise we can get spurious warnings. */
 	NF_CT_STAT_INC(net, delete_list);
 	clean_from_lists(ct);
+	/* add this conntrack to the dying list */
+	hlist_nulls_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
+			     &net->ct.dying);
 	spin_unlock_bh(&nf_conntrack_lock);
 }
 EXPORT_SYMBOL_GPL(nf_ct_delete_from_lists);
@@ -268,31 +269,23 @@ static void death_by_event(unsigned long ul_conntrack)
 	}
 	/* we've got the event delivered, now it's dying */
 	set_bit(IPS_DYING_BIT, &ct->status);
-	spin_lock(&nf_conntrack_lock);
-	hlist_nulls_del(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
-	spin_unlock(&nf_conntrack_lock);
 	nf_ct_put(ct);
 }
 
-void nf_ct_insert_dying_list(struct nf_conn *ct)
+void nf_ct_dying_timeout(struct nf_conn *ct)
 {
 	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_ecache *ecache = nf_ct_ecache_find(ct);
 
 	BUG_ON(ecache == NULL);
 
-	/* add this conntrack to the dying list */
-	spin_lock_bh(&nf_conntrack_lock);
-	hlist_nulls_add_head(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode,
-			     &net->ct.dying);
-	spin_unlock_bh(&nf_conntrack_lock);
 	/* set a new timer to retry event delivery */
 	setup_timer(&ecache->timeout, death_by_event, (unsigned long)ct);
 	ecache->timeout.expires = jiffies +
 		(random32() % net->ct.sysctl_events_retry_timeout);
 	add_timer(&ecache->timeout);
 }
-EXPORT_SYMBOL_GPL(nf_ct_insert_dying_list);
+EXPORT_SYMBOL_GPL(nf_ct_dying_timeout);
 
 static void death_by_timeout(unsigned long ul_conntrack)
 {
@@ -307,7 +300,7 @@ static void death_by_timeout(unsigned long ul_conntrack)
 	    unlikely(nf_conntrack_event(IPCT_DESTROY, ct) < 0)) {
 		/* destroy event was not delivered */
 		nf_ct_delete_from_lists(ct);
-		nf_ct_insert_dying_list(ct);
+		nf_ct_dying_timeout(ct);
 		return;
 	}
 	set_bit(IPS_DYING_BIT, &ct->status);
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 7bbfb3d..34370a9 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -989,7 +989,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 					      nlmsg_report(nlh)) < 0) {
 			nf_ct_delete_from_lists(ct);
 			/* we failed to report the event, try later */
-			nf_ct_insert_dying_list(ct);
+			nf_ct_dying_timeout(ct);
 			nf_ct_put(ct);
 			return 0;
 		}
-- 
1.7.10.4
