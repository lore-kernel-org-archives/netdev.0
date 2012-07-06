From: pablo@netfilter.org
Subject: [PATCH 06/18] netfilter: nf_conntrack: fix memory leak if sysctl registration fails
Date: Fri,  6 Jul 2012 13:16:56 +0200
Message-ID: <1341573428-3204-7-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43468 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933535Ab2GFLTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:19:04 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

In nf_ct_l4proto_register_sysctl, if l4proto sysctl registration
fails, we have to make sure that we release the compat sysctl
table.

This can happen if TCP has been registered compat for IPv4, and
IPv6 compat registration fails.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 63612e6..21b850c 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -341,11 +341,14 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
 				kfree(pn->ctl_table);
 				pn->ctl_table = NULL;
 			}
-			goto out;
 		}
 	}
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 	if (l4proto->l3proto != AF_INET6 && pn->ctl_compat_table != NULL) {
+		if (err < 0) {
+			nf_ct_kfree_compat_sysctl_table(pn);
+			goto out;
+		}
 		err = nf_ct_register_sysctl(net,
 					    &pn->ctl_compat_header,
 					    "net/ipv4/netfilter",
@@ -358,8 +361,8 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
 					&pn->ctl_table,
 					pn->users);
 	}
-#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 out:
+#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 	return err;
 }
-- 
1.7.10
