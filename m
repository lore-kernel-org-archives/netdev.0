From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/22] netfilter: nft_fib: Support existence check
Date: Mon, 20 Mar 2017 11:08:40 +0100
Message-ID: <1490004530-9128-13-git-send-email-pablo@netfilter.org>
References: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52168 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754073AbdCTKJq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 06:09:46 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4255C52335
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 31DAEDA729
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:16 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DAD91DA729
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 11:09:09 +0100 (CET)
In-Reply-To: <1490004530-9128-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>

Instead of the actual interface index or name, set destination register
to just 1 or 0 depending on whether the lookup succeeded or not if
NFTA_FIB_F_PRESENT was set in userspace.

Signed-off-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nft_fib.h          |  2 +-
 include/uapi/linux/netfilter/nf_tables.h |  1 +
 net/ipv4/netfilter/nft_fib_ipv4.c        |  4 ++--
 net/ipv6/netfilter/nft_fib_ipv6.c        |  2 +-
 net/netfilter/nft_fib.c                  | 14 +++++++++-----
 5 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/net/netfilter/nft_fib.h b/include/net/netfilter/nft_fib.h
index 5ceb2205e4e3..381af9469e6a 100644
--- a/include/net/netfilter/nft_fib.h
+++ b/include/net/netfilter/nft_fib.h
@@ -32,6 +32,6 @@ void nft_fib6_eval_type(const struct nft_expr *expr, struct nft_regs *regs,
 void nft_fib6_eval(const struct nft_expr *expr, struct nft_regs *regs,
 		   const struct nft_pktinfo *pkt);
 
-void nft_fib_store_result(void *reg, enum nft_fib_result r,
+void nft_fib_store_result(void *reg, const struct nft_fib *priv,
 			  const struct nft_pktinfo *pkt, int index);
 #endif
diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 34c8d08b687a..8f3842690d17 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -1257,6 +1257,7 @@ enum nft_fib_flags {
 	NFTA_FIB_F_MARK		= 1 << 2,	/* use skb->mark */
 	NFTA_FIB_F_IIF		= 1 << 3,	/* restrict to iif */
 	NFTA_FIB_F_OIF		= 1 << 4,	/* restrict to oif */
+	NFTA_FIB_F_PRESENT	= 1 << 5,	/* check existence only */
 };
 
 enum nft_ct_helper_attributes {
diff --git a/net/ipv4/netfilter/nft_fib_ipv4.c b/net/ipv4/netfilter/nft_fib_ipv4.c
index 2981291910dd..f4e4462cb5bb 100644
--- a/net/ipv4/netfilter/nft_fib_ipv4.c
+++ b/net/ipv4/netfilter/nft_fib_ipv4.c
@@ -90,7 +90,7 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 
 	if (nft_hook(pkt) == NF_INET_PRE_ROUTING &&
 	    nft_fib_is_loopback(pkt->skb, nft_in(pkt))) {
-		nft_fib_store_result(dest, priv->result, pkt,
+		nft_fib_store_result(dest, priv, pkt,
 				     nft_in(pkt)->ifindex);
 		return;
 	}
@@ -99,7 +99,7 @@ void nft_fib4_eval(const struct nft_expr *expr, struct nft_regs *regs,
 	if (ipv4_is_zeronet(iph->saddr)) {
 		if (ipv4_is_lbcast(iph->daddr) ||
 		    ipv4_is_local_multicast(iph->daddr)) {
-			nft_fib_store_result(dest, priv->result, pkt,
+			nft_fib_store_result(dest, priv, pkt,
 					     get_ifindex(pkt->skb->dev));
 			return;
 		}
diff --git a/net/ipv6/netfilter/nft_fib_ipv6.c b/net/ipv6/netfilter/nft_fib_ipv6.c
index 765facf03d45..e8d88d82636b 100644
--- a/net/ipv6/netfilter/nft_fib_ipv6.c
+++ b/net/ipv6/netfilter/nft_fib_ipv6.c
@@ -159,7 +159,7 @@ void nft_fib6_eval(const struct nft_expr *expr, struct nft_regs *regs,
 
 	if (nft_hook(pkt) == NF_INET_PRE_ROUTING &&
 	    nft_fib_is_loopback(pkt->skb, nft_in(pkt))) {
-		nft_fib_store_result(dest, priv->result, pkt,
+		nft_fib_store_result(dest, priv, pkt,
 				     nft_in(pkt)->ifindex);
 		return;
 	}
diff --git a/net/netfilter/nft_fib.c b/net/netfilter/nft_fib.c
index fd0b19303b0d..21df8cccea65 100644
--- a/net/netfilter/nft_fib.c
+++ b/net/netfilter/nft_fib.c
@@ -24,7 +24,8 @@ const struct nla_policy nft_fib_policy[NFTA_FIB_MAX + 1] = {
 EXPORT_SYMBOL(nft_fib_policy);
 
 #define NFTA_FIB_F_ALL (NFTA_FIB_F_SADDR | NFTA_FIB_F_DADDR | \
-			NFTA_FIB_F_MARK | NFTA_FIB_F_IIF | NFTA_FIB_F_OIF)
+			NFTA_FIB_F_MARK | NFTA_FIB_F_IIF | NFTA_FIB_F_OIF | \
+			NFTA_FIB_F_PRESENT)
 
 int nft_fib_validate(const struct nft_ctx *ctx, const struct nft_expr *expr,
 		     const struct nft_data **data)
@@ -133,19 +134,22 @@ int nft_fib_dump(struct sk_buff *skb, const struct nft_expr *expr)
 }
 EXPORT_SYMBOL_GPL(nft_fib_dump);
 
-void nft_fib_store_result(void *reg, enum nft_fib_result r,
+void nft_fib_store_result(void *reg, const struct nft_fib *priv,
 			  const struct nft_pktinfo *pkt, int index)
 {
 	struct net_device *dev;
 	u32 *dreg = reg;
 
-	switch (r) {
+	switch (priv->result) {
 	case NFT_FIB_RESULT_OIF:
-		*dreg = index;
+		*dreg = (priv->flags & NFTA_FIB_F_PRESENT) ? !!index : index;
 		break;
 	case NFT_FIB_RESULT_OIFNAME:
 		dev = dev_get_by_index_rcu(nft_net(pkt), index);
-		strncpy(reg, dev ? dev->name : "", IFNAMSIZ);
+		if (priv->flags & NFTA_FIB_F_PRESENT)
+			*dreg = !!dev;
+		else
+			strncpy(reg, dev ? dev->name : "", IFNAMSIZ);
 		break;
 	default:
 		WARN_ON_ONCE(1);
-- 
2.1.4
