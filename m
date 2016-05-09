From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/36] netfilter: nftables: add connlabel set support
Date: Mon,  9 May 2016 20:46:32 +0200
Message-ID: <1462819614-5402-15-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

Conntrack labels are currently sized depending on the iptables
ruleset, i.e. if we're asked to test or set bits 1, 2, and 65 then we
would allocate enough room to store at least bit 65.

However, with nft, the input is just a register with arbitrary runtime
content.

We therefore ask for the upper ceiling we currently have, which is
enough room to store 128 bits.

Alternatively, we could alter nf_connlabel_replace to increase
net->ct.label_words at run time, but since 128 bits is not that
big we'd only save sizeof(long) so it doesn't seem worth it for now.

This follows a similar approach that xtables 'connlabel'
match uses, so when user inputs

    ct label set bar

then we will set the bit used by the 'bar' label and leave the rest alone.

This is done by passing the sreg content to nf_connlabels_replace
as both value and mask argument.
Labels (bits) already set thus cannot be re-set to zero, but
this is not supported by xtables connlabel match either.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_ct.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 25998fa..137e308 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -198,6 +198,14 @@ static void nft_ct_set_eval(const struct nft_expr *expr,
 		}
 		break;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	case NFT_CT_LABELS:
+		nf_connlabels_replace(ct,
+				      &regs->data[priv->sreg],
+				      &regs->data[priv->sreg],
+				      NF_CT_LABELS_MAX_SIZE / sizeof(u32));
+		break;
+#endif
 	default:
 		break;
 	}
@@ -365,6 +373,16 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 		len = FIELD_SIZEOF(struct nf_conn, mark);
 		break;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	case NFT_CT_LABELS:
+		if (tb[NFTA_CT_DIRECTION])
+			return -EINVAL;
+		len = NF_CT_LABELS_MAX_SIZE;
+		err = nf_connlabels_get(ctx->net, (len * BITS_PER_BYTE) - 1);
+		if (err)
+			return err;
+		break;
+#endif
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -384,6 +402,18 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 static void nft_ct_destroy(const struct nft_ctx *ctx,
 			   const struct nft_expr *expr)
 {
+	struct nft_ct *priv = nft_expr_priv(expr);
+
+	switch (priv->key) {
+#ifdef CONFIG_NF_CONNTRACK_LABELS
+	case NFT_CT_LABELS:
+		nf_connlabels_put(ctx->net);
+		break;
+#endif
+	default:
+		break;
+	}
+
 	nft_ct_l3proto_module_put(ctx->afi->family);
 }
 
-- 
2.1.4

