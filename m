From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 29/41: ctnetlink: move event reporting for new entries outside the lock
Date: Tue, 24 Mar 2009 15:03:45 +0100 (MET)
Message-ID: <20090324140341.31401.12851.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34818 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758299AbZCXODs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:48 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f0a3c0869f3b0ef93d9df044e9a41e40086d4c97
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Mar 16 15:28:09 2009 +0100

    netfilter: ctnetlink: move event reporting for new entries outside the lock
    
    This patch moves the event reporting outside the lock section. With
    this patch, the creation and update of entries is homogeneous from
    the event reporting perspective. Moreover, as the event reporting is
    done outside the lock section, the netlink broadcast delivery can
    benefit of the yield() call under congestion.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index b67db69..9fb7cf7 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1128,12 +1128,10 @@ ctnetlink_event_report(struct nf_conn *ct, u32 pid, int report)
 				  report);
 }
 
-static int
+static struct nf_conn *
 ctnetlink_create_conntrack(struct nlattr *cda[],
 			   struct nf_conntrack_tuple *otuple,
 			   struct nf_conntrack_tuple *rtuple,
-			   u32 pid,
-			   int report,
 			   u8 u3)
 {
 	struct nf_conn *ct;
@@ -1142,7 +1140,7 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 
 	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_ATOMIC);
 	if (IS_ERR(ct))
-		return -ENOMEM;
+		return ERR_PTR(-ENOMEM);
 
 	if (!cda[CTA_TIMEOUT])
 		goto err;
@@ -1265,18 +1263,14 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 		ct->master = master_ct;
 	}
 
-	nf_conntrack_get(&ct->ct_general);
 	add_timer(&ct->timeout);
 	nf_conntrack_hash_insert(ct);
 	rcu_read_unlock();
-	ctnetlink_event_report(ct, pid, report);
-	nf_ct_put(ct);
-
-	return 0;
 
+	return ct;
 err:
 	nf_conntrack_free(ct);
-	return err;
+	return ERR_PTR(err);
 }
 
 static int
@@ -1309,14 +1303,25 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	if (h == NULL) {
 		err = -ENOENT;
-		if (nlh->nlmsg_flags & NLM_F_CREATE)
-			err = ctnetlink_create_conntrack(cda,
-							 &otuple,
-							 &rtuple,
-							 NETLINK_CB(skb).pid,
-							 nlmsg_report(nlh),
-							 u3);
-		spin_unlock_bh(&nf_conntrack_lock);
+		if (nlh->nlmsg_flags & NLM_F_CREATE) {
+			struct nf_conn *ct;
+
+			ct = ctnetlink_create_conntrack(cda, &otuple,
+							&rtuple, u3);
+			if (IS_ERR(ct)) {
+				err = PTR_ERR(ct);
+				goto out_unlock;
+			}
+			err = 0;
+			nf_conntrack_get(&ct->ct_general);
+			spin_unlock_bh(&nf_conntrack_lock);
+			ctnetlink_event_report(ct,
+					       NETLINK_CB(skb).pid,
+					       nlmsg_report(nlh));
+			nf_ct_put(ct);
+		} else
+			spin_unlock_bh(&nf_conntrack_lock);
+
 		return err;
 	}
 	/* implicit 'else' */
