From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/27] netfilter: nft_ct: add average bytes per packet support
Date: Fri,  3 Feb 2017 13:25:15 +0100
Message-ID: <1486124738-3013-5-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58876 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752888AbdBCM2h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:37 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 96AC9BA71F
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 81D49DA80C
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:34 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id CC269DA84D
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:31 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

Similar to xt_connbytes, user can match how many average bytes per packet
a connection has transferred so far.

Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  2 ++
 net/netfilter/nft_ct.c                   | 22 +++++++++++++++++++++-
 2 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 5726f90bfc2f..b00a05d1ee56 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -863,6 +863,7 @@ enum nft_rt_attributes {
  * @NFT_CT_LABELS: conntrack labels
  * @NFT_CT_PKTS: conntrack packets
  * @NFT_CT_BYTES: conntrack bytes
+ * @NFT_CT_AVGPKT: conntrack average bytes per packet
  */
 enum nft_ct_keys {
 	NFT_CT_STATE,
@@ -881,6 +882,7 @@ enum nft_ct_keys {
 	NFT_CT_LABELS,
 	NFT_CT_PKTS,
 	NFT_CT_BYTES,
+	NFT_CT_AVGPKT,
 };
 
 /**
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index e6baeaebe653..d774d7823688 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -129,6 +129,22 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 		memcpy(dest, &count, sizeof(count));
 		return;
 	}
+	case NFT_CT_AVGPKT: {
+		const struct nf_conn_acct *acct = nf_conn_acct_find(ct);
+		u64 avgcnt = 0, bcnt = 0, pcnt = 0;
+
+		if (acct) {
+			pcnt = nft_ct_get_eval_counter(acct->counter,
+						       NFT_CT_PKTS, priv->dir);
+			bcnt = nft_ct_get_eval_counter(acct->counter,
+						       NFT_CT_BYTES, priv->dir);
+			if (pcnt != 0)
+				avgcnt = div64_u64(bcnt, pcnt);
+		}
+
+		memcpy(dest, &avgcnt, sizeof(avgcnt));
+		return;
+	}
 	case NFT_CT_L3PROTOCOL:
 		*dest = nf_ct_l3num(ct);
 		return;
@@ -316,6 +332,7 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 		break;
 	case NFT_CT_BYTES:
 	case NFT_CT_PKTS:
+	case NFT_CT_AVGPKT:
 		/* no direction? return sum of original + reply */
 		if (tb[NFTA_CT_DIRECTION] == NULL)
 			priv->dir = IP_CT_DIR_MAX;
@@ -346,7 +363,9 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 	if (err < 0)
 		return err;
 
-	if (priv->key == NFT_CT_BYTES || priv->key == NFT_CT_PKTS)
+	if (priv->key == NFT_CT_BYTES ||
+	    priv->key == NFT_CT_PKTS  ||
+	    priv->key == NFT_CT_AVGPKT)
 		nf_ct_set_acct(ctx->net, true);
 
 	return 0;
@@ -445,6 +464,7 @@ static int nft_ct_get_dump(struct sk_buff *skb, const struct nft_expr *expr)
 		break;
 	case NFT_CT_BYTES:
 	case NFT_CT_PKTS:
+	case NFT_CT_AVGPKT:
 		if (priv->dir < IP_CT_DIR_MAX &&
 		    nla_put_u8(skb, NFTA_CT_DIRECTION, priv->dir))
 			goto nla_put_failure;
-- 
2.1.4
