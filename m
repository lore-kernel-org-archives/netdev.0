From: pablo@netfilter.org
Subject: [PATCH 1/2] Revert "netfilter: ctnetlink: fix soft lockup when netlink adds new entries"
Date: Fri, 24 Feb 2012 23:38:23 +0100
Message-ID: <1330123104-3953-2-git-send-email-pablo@netfilter.org>
References: <1330123104-3953-1-git-send-email-pablo@netfilter.org>
Cc: netfilter-devel@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1330123104-3953-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This reverts commit af14cca162ddcdea017b648c21b9b091e4bf1fa4.

This patch contains a race condition between packets and ctnetlink
in the conntrack addition. A new patch to fix this issue follows up.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   43 +++++++++++++++++++++------------
 1 files changed, 27 insertions(+), 16 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index cc70517..9307b03 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1367,12 +1367,15 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 						    nf_ct_protonum(ct));
 		if (helper == NULL) {
 			rcu_read_unlock();
+			spin_unlock_bh(&nf_conntrack_lock);
 #ifdef CONFIG_MODULES
 			if (request_module("nfct-helper-%s", helpname) < 0) {
+				spin_lock_bh(&nf_conntrack_lock);
 				err = -EOPNOTSUPP;
 				goto err1;
 			}
 
+			spin_lock_bh(&nf_conntrack_lock);
 			rcu_read_lock();
 			helper = __nf_conntrack_helper_find(helpname,
 							    nf_ct_l3num(ct),
@@ -1466,10 +1469,7 @@ ctnetlink_create_conntrack(struct net *net, u16 zone,
 		tstamp->start = ktime_to_ns(ktime_get_real());
 
 	add_timer(&ct->timeout);
-	spin_lock_bh(&nf_conntrack_lock);
 	nf_conntrack_hash_insert(ct);
-	nf_conntrack_get(&ct->ct_general);
-	spin_unlock_bh(&nf_conntrack_lock);
 	rcu_read_unlock();
 
 	return ct;
@@ -1490,7 +1490,6 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conntrack_tuple otuple, rtuple;
 	struct nf_conntrack_tuple_hash *h = NULL;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
-	struct nf_conn *ct;
 	u_int8_t u3 = nfmsg->nfgen_family;
 	u16 zone;
 	int err;
@@ -1513,22 +1512,25 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	spin_lock_bh(&nf_conntrack_lock);
 	if (cda[CTA_TUPLE_ORIG])
-		h = nf_conntrack_find_get(net, zone, &otuple);
+		h = __nf_conntrack_find(net, zone, &otuple);
 	else if (cda[CTA_TUPLE_REPLY])
-		h = nf_conntrack_find_get(net, zone, &rtuple);
-	spin_unlock_bh(&nf_conntrack_lock);
+		h = __nf_conntrack_find(net, zone, &rtuple);
 
 	if (h == NULL) {
 		err = -ENOENT;
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
+			struct nf_conn *ct;
 			enum ip_conntrack_events events;
 
 			ct = ctnetlink_create_conntrack(net, zone, cda, &otuple,
 							&rtuple, u3);
-			if (IS_ERR(ct))
-				return PTR_ERR(ct);
-
+			if (IS_ERR(ct)) {
+				err = PTR_ERR(ct);
+				goto out_unlock;
+			}
 			err = 0;
+			nf_conntrack_get(&ct->ct_general);
+			spin_unlock_bh(&nf_conntrack_lock);
 			if (test_bit(IPS_EXPECTED_BIT, &ct->status))
 				events = IPCT_RELATED;
 			else
@@ -1543,19 +1545,23 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 						      ct, NETLINK_CB(skb).pid,
 						      nlmsg_report(nlh));
 			nf_ct_put(ct);
-		}
+		} else
+			spin_unlock_bh(&nf_conntrack_lock);
 
 		return err;
 	}
 	/* implicit 'else' */
 
+	/* We manipulate the conntrack inside the global conntrack table lock,
+	 * so there's no need to increase the refcount */
 	err = -EEXIST;
-	ct = nf_ct_tuplehash_to_ctrack(h);
 	if (!(nlh->nlmsg_flags & NLM_F_EXCL)) {
-		spin_lock_bh(&nf_conntrack_lock);
+		struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
+
 		err = ctnetlink_change_conntrack(ct, cda);
-		spin_unlock_bh(&nf_conntrack_lock);
 		if (err == 0) {
+			nf_conntrack_get(&ct->ct_general);
+			spin_unlock_bh(&nf_conntrack_lock);
 			nf_conntrack_eventmask_report((1 << IPCT_REPLY) |
 						      (1 << IPCT_ASSURED) |
 						      (1 << IPCT_HELPER) |
@@ -1564,10 +1570,15 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 						      (1 << IPCT_MARK),
 						      ct, NETLINK_CB(skb).pid,
 						      nlmsg_report(nlh));
-		}
+			nf_ct_put(ct);
+		} else
+			spin_unlock_bh(&nf_conntrack_lock);
+
+		return err;
 	}
 
-	nf_ct_put(ct);
+out_unlock:
+	spin_unlock_bh(&nf_conntrack_lock);
 	return err;
 }
 
-- 
1.7.7.3

