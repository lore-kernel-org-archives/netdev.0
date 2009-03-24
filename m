From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 27/41: ctnetlink: cleanup master conntrack assignation
Date: Tue, 24 Mar 2009 15:03:43 +0100 (MET)
Message-ID: <20090324140338.31401.95818.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34812 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758437AbZCXODp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:45 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 7ec4749675bf33ea639bbcca8a5365ccc5091a6a
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Mar 16 15:25:46 2009 +0100

    netfilter: ctnetlink: cleanup master conntrack assignation
    
    This patch moves the assignation of the master conntrack to
    ctnetlink_create_conntrack(), which is where it really belongs.
    This patch is a cleanup.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index cb78aa0..cca22d5 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1128,9 +1128,9 @@ static int
 ctnetlink_create_conntrack(struct nlattr *cda[],
 			   struct nf_conntrack_tuple *otuple,
 			   struct nf_conntrack_tuple *rtuple,
-			   struct nf_conn *master_ct,
 			   u32 pid,
-			   int report)
+			   int report,
+			   u8 u3)
 {
 	struct nf_conn *ct;
 	int err = -EINVAL;
@@ -1241,7 +1241,22 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 #endif
 
 	/* setup master conntrack: this is a confirmed expectation */
-	if (master_ct) {
+	if (cda[CTA_TUPLE_MASTER]) {
+		struct nf_conntrack_tuple master;
+		struct nf_conntrack_tuple_hash *master_h;
+		struct nf_conn *master_ct;
+
+		err = ctnetlink_parse_tuple(cda, &master, CTA_TUPLE_MASTER, u3);
+		if (err < 0)
+			goto err;
+
+		master_h = __nf_conntrack_find(&init_net, &master);
+		if (master_h == NULL) {
+			err = -ENOENT;
+			goto err;
+		}
+		master_ct = nf_ct_tuplehash_to_ctrack(master_h);
+		nf_conntrack_get(&master_ct->ct_general);
 		__set_bit(IPS_EXPECTED_BIT, &ct->status);
 		ct->master = master_ct;
 	}
@@ -1289,39 +1304,15 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 		h = __nf_conntrack_find(&init_net, &rtuple);
 
 	if (h == NULL) {
-		struct nf_conntrack_tuple master;
-		struct nf_conntrack_tuple_hash *master_h = NULL;
-		struct nf_conn *master_ct = NULL;
-
-		if (cda[CTA_TUPLE_MASTER]) {
-			err = ctnetlink_parse_tuple(cda,
-						    &master,
-						    CTA_TUPLE_MASTER,
-						    u3);
-			if (err < 0)
-				goto out_unlock;
-
-			master_h = __nf_conntrack_find(&init_net, &master);
-			if (master_h == NULL) {
-				err = -ENOENT;
-				goto out_unlock;
-			}
-			master_ct = nf_ct_tuplehash_to_ctrack(master_h);
-			nf_conntrack_get(&master_ct->ct_general);
-		}
-
 		err = -ENOENT;
 		if (nlh->nlmsg_flags & NLM_F_CREATE)
 			err = ctnetlink_create_conntrack(cda,
 							 &otuple,
 							 &rtuple,
-							 master_ct,
 							 NETLINK_CB(skb).pid,
-							 nlmsg_report(nlh));
+							 nlmsg_report(nlh),
+							 u3);
 		spin_unlock_bh(&nf_conntrack_lock);
-		if (err < 0 && master_ct)
-			nf_ct_put(master_ct);
-
 		return err;
 	}
 	/* implicit 'else' */
