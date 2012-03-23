From: pablo@netfilter.org
Subject: [PATCH 3/5] netfilter: xt_CT: missing rcu_read_lock section in timeout assignment
Date: Fri, 23 Mar 2012 10:34:15 +0100
Message-ID: <1332495257-3149-4-git-send-email-pablo@netfilter.org>
References: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47829 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757985Ab2CWJej (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2012 05:34:39 -0400
In-Reply-To: <1332495257-3149-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

Fix a dereference to pointer without rcu_read_lock held.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_CT.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index 80c39f0..33a02b4 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -218,6 +218,7 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 		struct ctnl_timeout *timeout;
 		struct nf_conn_timeout *timeout_ext;
 
+		rcu_read_lock();
 		timeout_find_get =
 			rcu_dereference(nf_ct_timeout_find_get_hook);
 
@@ -228,21 +229,21 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 				ret = -EINVAL;
 				pr_info("You cannot use inversion on "
 					 "L4 protocol\n");
-				goto err3;
+				goto err4;
 			}
 			timeout = timeout_find_get(info->timeout);
 			if (timeout == NULL) {
 				ret = -ENOENT;
 				pr_info("No such timeout policy \"%s\"\n",
 					info->timeout);
-				goto err3;
+				goto err4;
 			}
 			if (timeout->l3num != par->family) {
 				ret = -EINVAL;
 				pr_info("Timeout policy `%s' can only be "
 					"used by L3 protocol number %d\n",
 					info->timeout, timeout->l3num);
-				goto err3;
+				goto err4;
 			}
 			if (timeout->l4proto->l4proto != e->ip.proto) {
 				ret = -EINVAL;
@@ -250,19 +251,20 @@ static int xt_ct_tg_check_v1(const struct xt_tgchk_param *par)
 					"used by L4 protocol number %d\n",
 					info->timeout,
 					timeout->l4proto->l4proto);
-				goto err3;
+				goto err4;
 			}
 			timeout_ext = nf_ct_timeout_ext_add(ct, timeout,
 							    GFP_KERNEL);
 			if (timeout_ext == NULL) {
 				ret = -ENOMEM;
-				goto err3;
+				goto err4;
 			}
 		} else {
 			ret = -ENOENT;
 			pr_info("Timeout policy base is empty\n");
-			goto err3;
+			goto err4;
 		}
+		rcu_read_unlock();
 	}
 #endif
 
@@ -272,6 +274,8 @@ out:
 	info->ct = ct;
 	return 0;
 
+err4:
+	rcu_read_unlock();
 err3:
 	nf_conntrack_free(ct);
 err2:
@@ -313,6 +317,7 @@ static void xt_ct_tg_destroy_v1(const struct xt_tgdtor_param *par)
 		nf_ct_l3proto_module_put(par->family);
 
 #ifdef CONFIG_NF_CONNTRACK_TIMEOUT
+		rcu_read_lock();
 		timeout_put = rcu_dereference(nf_ct_timeout_put_hook);
 
 		if (timeout_put) {
@@ -320,6 +325,7 @@ static void xt_ct_tg_destroy_v1(const struct xt_tgdtor_param *par)
 			if (timeout_ext)
 				timeout_put(timeout_ext->timeout);
 		}
+		rcu_read_unlock();
 #endif
 	}
 	nf_ct_put(info->ct);
-- 
1.7.2.5
