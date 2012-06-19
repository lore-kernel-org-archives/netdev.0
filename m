From: pablo@netfilter.org
Subject: [PATCH 2/4] netfilter: nf_ct_helper: disable automatic helper re-assignment of different type
Date: Tue, 19 Jun 2012 05:16:27 +0200
Message-ID: <1340075789-6196-3-git-send-email-pablo@netfilter.org>
References: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>

This patch modifies __nf_ct_try_assign_helper in a way that invalidates support
for the following scenario:

1) attach the helper A for first time when the conntrack is created
2) attach new (different) helper B due to changes the reply tuple caused by NAT

eg. port redirection from TCP/21 to TCP/5060 with both FTP and SIP helpers
loaded, which seems to be a quite unorthodox scenario.

I can provide a more elaborated patch to support this scenario but explicit
helper attachment provides a better solution for this since now the use can
attach the helpers consistently, without relying on the automatic helper
lookup magic.

This patch fixes a possible out of bound zeroing of the conntrack helper
extension if the helper B uses more memory for its private data than
helper A.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_helper.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 2918ec2..c4bc637 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -229,7 +229,13 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 			goto out;
 		}
 	} else {
-		memset(help->data, 0, helper->data_len);
+		/* We only allow helper re-assignment of the same sort since
+		 * we cannot reallocate the helper extension area.
+		 */
+		if (help->helper != helper) {
+			RCU_INIT_POINTER(help->helper, NULL);
+			goto out;
+		}
 	}
 
 	rcu_assign_pointer(help->helper, helper);
-- 
1.7.10

