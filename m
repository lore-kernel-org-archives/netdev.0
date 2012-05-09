From: pablo@netfilter.org
Subject: [PATCH 4/5] netfilter: hashlimit: move rateinfo initialization to helper
Date: Wed,  9 May 2012 13:33:07 +0200
Message-ID: <1336563188-6720-5-git-send-email-pablo@netfilter.org>
References: <1336563188-6720-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:33924 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758240Ab2EILdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 07:33:41 -0400
In-Reply-To: <1336563188-6720-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

followup patch would bloat main match function too much.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_hashlimit.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 2195eb0..b6bbd06 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -407,6 +407,15 @@ static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now)
 	dh->rateinfo.prev = now;
 }
 
+static void rateinfo_init(struct dsthash_ent *dh,
+			  struct xt_hashlimit_htable *hinfo)
+{
+	dh->rateinfo.prev = jiffies;
+	dh->rateinfo.credit = user2credits(hinfo->cfg.avg * hinfo->cfg.burst);
+	dh->rateinfo.cost = user2credits(hinfo->cfg.avg);
+	dh->rateinfo.credit_cap = dh->rateinfo.credit;
+}
+
 static inline __be32 maskl(__be32 a, unsigned int l)
 {
 	return l ? htonl(ntohl(a) & ~0 << (32 - l)) : 0;
@@ -531,11 +540,7 @@ hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 			goto hotdrop;
 		}
 		dh->expires = jiffies + msecs_to_jiffies(hinfo->cfg.expire);
-		dh->rateinfo.prev = jiffies;
-		dh->rateinfo.credit = user2credits(hinfo->cfg.avg *
-		                      hinfo->cfg.burst);
-		dh->rateinfo.credit_cap = dh->rateinfo.credit;
-		dh->rateinfo.cost = user2credits(hinfo->cfg.avg);
+		rateinfo_init(dh, hinfo);
 	} else {
 		/* update expiration timeout */
 		dh->expires = now + msecs_to_jiffies(hinfo->cfg.expire);
-- 
1.7.9.5
