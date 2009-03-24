From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 38/41: ctnetlink: fix rcu context imbalance
Date: Tue, 24 Mar 2009 15:03:57 +0100 (MET)
Message-ID: <20090324140353.31401.47366.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34846 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118AbZCXOEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:04:01 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 0f5b3e85a3716efebb0150ebb7c6d022e2bf17d7
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Mar 18 17:36:40 2009 +0100

    netfilter: ctnetlink: fix rcu context imbalance
    
    Introduced by 7ec47496 (netfilter: ctnetlink: cleanup master conntrack assignation):
    
    net/netfilter/nf_conntrack_netlink.c:1275:2: warning: context imbalance in 'ctnetlink_create_conntrack' - different lock contexts for basic block
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 735ea9c..d1fe9d1 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1146,7 +1146,7 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 		return ERR_PTR(-ENOMEM);
 
 	if (!cda[CTA_TIMEOUT])
-		goto err;
+		goto err1;
 	ct->timeout.expires = ntohl(nla_get_be32(cda[CTA_TIMEOUT]));
 
 	ct->timeout.expires = jiffies + ct->timeout.expires * HZ;
@@ -1157,10 +1157,8 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
  		char *helpname;
  
  		err = ctnetlink_parse_help(cda[CTA_HELP], &helpname);
- 		if (err < 0) {
-			rcu_read_unlock();
-			goto err;
-		}
+ 		if (err < 0)
+			goto err2;
 
 		helper = __nf_conntrack_helper_find_byname(helpname);
 		if (helper == NULL) {
@@ -1168,28 +1166,26 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 #ifdef CONFIG_MODULES
 			if (request_module("nfct-helper-%s", helpname) < 0) {
 				err = -EOPNOTSUPP;
-				goto err;
+				goto err1;
 			}
 
 			rcu_read_lock();
 			helper = __nf_conntrack_helper_find_byname(helpname);
 			if (helper) {
-				rcu_read_unlock();
 				err = -EAGAIN;
-				goto err;
+				goto err2;
 			}
 			rcu_read_unlock();
 #endif
 			err = -EOPNOTSUPP;
-			goto err;
+			goto err1;
 		} else {
 			struct nf_conn_help *help;
 
 			help = nf_ct_helper_ext_add(ct, GFP_ATOMIC);
 			if (help == NULL) {
-				rcu_read_unlock();
 				err = -ENOMEM;
-				goto err;
+				goto err2;
 			}
 
 			/* not in hash table yet so not strictly necessary */
@@ -1198,44 +1194,34 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 	} else {
 		/* try an implicit helper assignation */
 		err = __nf_ct_try_assign_helper(ct, GFP_ATOMIC);
-		if (err < 0) {
-			rcu_read_unlock();
-			goto err;
-		}
+		if (err < 0)
+			goto err2;
 	}
 
 	if (cda[CTA_STATUS]) {
 		err = ctnetlink_change_status(ct, cda);
-		if (err < 0) {
-			rcu_read_unlock();
-			goto err;
-		}
+		if (err < 0)
+			goto err2;
 	}
 
 	if (cda[CTA_NAT_SRC] || cda[CTA_NAT_DST]) {
 		err = ctnetlink_change_nat(ct, cda);
-		if (err < 0) {
-			rcu_read_unlock();
-			goto err;
-		}
+		if (err < 0)
+			goto err2;
 	}
 
 #ifdef CONFIG_NF_NAT_NEEDED
 	if (cda[CTA_NAT_SEQ_ADJ_ORIG] || cda[CTA_NAT_SEQ_ADJ_REPLY]) {
 		err = ctnetlink_change_nat_seq_adj(ct, cda);
-		if (err < 0) {
-			rcu_read_unlock();
-			goto err;
-		}
+		if (err < 0)
+			goto err2;
 	}
 #endif
 
 	if (cda[CTA_PROTOINFO]) {
 		err = ctnetlink_change_protoinfo(ct, cda);
-		if (err < 0) {
-			rcu_read_unlock();
-			goto err;
-		}
+		if (err < 0)
+			goto err2;
 	}
 
 	nf_ct_acct_ext_add(ct, GFP_ATOMIC);
@@ -1253,12 +1239,12 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 
 		err = ctnetlink_parse_tuple(cda, &master, CTA_TUPLE_MASTER, u3);
 		if (err < 0)
-			goto err;
+			goto err2;
 
 		master_h = __nf_conntrack_find(&init_net, &master);
 		if (master_h == NULL) {
 			err = -ENOENT;
-			goto err;
+			goto err2;
 		}
 		master_ct = nf_ct_tuplehash_to_ctrack(master_h);
 		nf_conntrack_get(&master_ct->ct_general);
@@ -1271,7 +1257,10 @@ ctnetlink_create_conntrack(struct nlattr *cda[],
 	rcu_read_unlock();
 
 	return ct;
-err:
+
+err2:
+	rcu_read_unlock();
+err1:
 	nf_conntrack_free(ct);
 	return ERR_PTR(err);
 }
