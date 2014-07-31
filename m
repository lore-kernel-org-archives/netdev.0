From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/9] netfilter: nfnetlink_acct: avoid using NFACCT_F_OVERQUOTA with bit helper functions
Date: Thu, 31 Jul 2014 21:27:07 +0200
Message-ID: <1406834828-8500-9-git-send-email-pablo@netfilter.org>
References: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35678 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752370AbaGaT1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 15:27:19 -0400
In-Reply-To: <1406834828-8500-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Perevalov <a.perevalov@samsung.com>

Bit helper functions were used for manipulation with NFACCT_F_OVERQUOTA,
but they are accepting pit position, but not a bit mask. As a result
not a third bit for NFACCT_F_OVERQUOTA was set, but forth. Such
behaviour was dangarous and could lead to unexpected overquota report
result.

Signed-off-by: Alexey Perevalov <a.perevalov@samsung.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_acct.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 11d863c..3ea0eac 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -41,6 +41,7 @@ struct nf_acct {
 };
 
 #define NFACCT_F_QUOTA (NFACCT_F_QUOTA_PKTS | NFACCT_F_QUOTA_BYTES)
+#define NFACCT_OVERQUOTA_BIT	2	/* NFACCT_F_OVERQUOTA */
 
 static int
 nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
@@ -77,7 +78,8 @@ nfnl_acct_new(struct sock *nfnl, struct sk_buff *skb,
 			smp_mb__before_atomic();
 			/* reset overquota flag if quota is enabled. */
 			if ((matching->flags & NFACCT_F_QUOTA))
-				clear_bit(NFACCT_F_OVERQUOTA, &matching->flags);
+				clear_bit(NFACCT_OVERQUOTA_BIT,
+					  &matching->flags);
 			return 0;
 		}
 		return -EBUSY;
@@ -150,7 +152,7 @@ nfnl_acct_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 		bytes = atomic64_xchg(&acct->bytes, 0);
 		smp_mb__before_atomic();
 		if (acct->flags & NFACCT_F_QUOTA)
-			clear_bit(NFACCT_F_OVERQUOTA, &acct->flags);
+			clear_bit(NFACCT_OVERQUOTA_BIT, &acct->flags);
 	} else {
 		pkts = atomic64_read(&acct->pkts);
 		bytes = atomic64_read(&acct->bytes);
@@ -414,7 +416,7 @@ int nfnl_acct_overquota(const struct sk_buff *skb, struct nf_acct *nfacct)
 	ret = now > *quota;
 
 	if (now >= *quota &&
-	    !test_and_set_bit(NFACCT_F_OVERQUOTA, &nfacct->flags)) {
+	    !test_and_set_bit(NFACCT_OVERQUOTA_BIT, &nfacct->flags)) {
 		nfnl_overquota_report(nfacct);
 	}
 
-- 
1.7.10.4
