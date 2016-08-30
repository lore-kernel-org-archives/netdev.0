From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/7] netfilter: cttimeout: put back l4proto when replacing timeout policy
Date: Tue, 30 Aug 2016 13:26:19 +0200
Message-ID: <1472556383-6787-4-git-send-email-pablo@netfilter.org>
References: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1472556383-6787-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liping Zhang <liping.zhang@spreadtrum.com>

We forget to call nf_ct_l4proto_put when replacing the existing
timeout policy. Acctually, there's no need to get ct l4proto
before doing replace, so we can move it to a later position.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_cttimeout.c | 33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index f74fee1..6844c7a 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -98,31 +98,28 @@ static int cttimeout_new_timeout(struct net *net, struct sock *ctnl,
 		break;
 	}
 
-	l4proto = nf_ct_l4proto_find_get(l3num, l4num);
-
-	/* This protocol is not supportted, skip. */
-	if (l4proto->l4proto != l4num) {
-		ret = -EOPNOTSUPP;
-		goto err_proto_put;
-	}
-
 	if (matching) {
 		if (nlh->nlmsg_flags & NLM_F_REPLACE) {
 			/* You cannot replace one timeout policy by another of
 			 * different kind, sorry.
 			 */
 			if (matching->l3num != l3num ||
-			    matching->l4proto->l4proto != l4num) {
-				ret = -EINVAL;
-				goto err_proto_put;
-			}
-
-			ret = ctnl_timeout_parse_policy(&matching->data,
-							l4proto, net,
-							cda[CTA_TIMEOUT_DATA]);
-			return ret;
+			    matching->l4proto->l4proto != l4num)
+				return -EINVAL;
+
+			return ctnl_timeout_parse_policy(&matching->data,
+							 matching->l4proto, net,
+							 cda[CTA_TIMEOUT_DATA]);
 		}
-		ret = -EBUSY;
+
+		return -EBUSY;
+	}
+
+	l4proto = nf_ct_l4proto_find_get(l3num, l4num);
+
+	/* This protocol is not supportted, skip. */
+	if (l4proto->l4proto != l4num) {
+		ret = -EOPNOTSUPP;
 		goto err_proto_put;
 	}
 
-- 
2.1.4

