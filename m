From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 05/13] netfilter: fix memory leak when register sysctl failed
Date: Thu, 21 Jun 2012 22:36:42 +0800
Message-ID: <1340289410-17642-5-git-send-email-gaofeng@cn.fujitsu.com>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

in nf_ct_l4proto_register_sysctl,when register l4proto' sysctl failed,
we should free the compat sysctl table.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto.c |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 63612e6..42e686b 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -341,25 +341,28 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
 				kfree(pn->ctl_table);
 				pn->ctl_table = NULL;
 			}
-			goto out;
 		}
 	}
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 	if (l4proto->l3proto != AF_INET6 && pn->ctl_compat_table != NULL) {
-		err = nf_ct_register_sysctl(net,
-					    &pn->ctl_compat_header,
-					    "net/ipv4/netfilter",
-					    pn->ctl_compat_table);
-		if (err == 0)
-			goto out;
-
-		nf_ct_kfree_compat_sysctl_table(pn);
-		nf_ct_unregister_sysctl(&pn->ctl_table_header,
-					&pn->ctl_table,
-					pn->users);
+		if (err < 0)
+			nf_ct_kfree_compat_sysctl_table(pn);
+		else {
+			err = nf_ct_register_sysctl(net,
+						    &pn->ctl_compat_header,
+						    "net/ipv4/netfilter",
+						    pn->ctl_compat_table);
+			if (err == 0)
+				goto out;
+
+			nf_ct_kfree_compat_sysctl_table(pn);
+			nf_ct_unregister_sysctl(&pn->ctl_table_header,
+						&pn->ctl_table,
+						pn->users);
+		}
 	}
-#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 out:
+#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 	return err;
 }
-- 
1.7.7.6

