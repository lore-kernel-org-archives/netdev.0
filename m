From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 25/53] netfilter: nft_ct: allow to set ctnetlink event types of a connection
Date: Mon,  1 May 2017 12:46:52 +0200
Message-ID: <1493635640-24325-26-git-send-email-pablo@netfilter.org>
References: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1493635640-24325-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

By default the kernel emits all ctnetlink events for a connection.
This allows to select the types of events to generate.

This can be used to e.g. only send DESTROY events but no NEW/UPDATE ones
and will work even if sysctl net.netfilter.nf_conntrack_events is set to 0.

This was already possible via iptables' CT target, but the nft version has
the advantage that it can also be used with already-established conntracks.

The added nf_ct_is_template() check isn't a bug fix as we only support
mark and labels (and unlike ecache the conntrack core doesn't copy those).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  2 ++
 net/netfilter/nft_ct.c                   | 25 ++++++++++++++++++++++++-
 2 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 8f3842690d17..683f6f88fcac 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -901,6 +901,7 @@ enum nft_rt_attributes {
  * @NFT_CT_BYTES: conntrack bytes
  * @NFT_CT_AVGPKT: conntrack average bytes per packet
  * @NFT_CT_ZONE: conntrack zone
+ * @NFT_CT_EVENTMASK: ctnetlink events to be generated for this conntrack
  */
 enum nft_ct_keys {
 	NFT_CT_STATE,
@@ -921,6 +922,7 @@ enum nft_ct_keys {
 	NFT_CT_BYTES,
 	NFT_CT_AVGPKT,
 	NFT_CT_ZONE,
+	NFT_CT_EVENTMASK,
 };
 
 /**
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 6c6fd48b024c..a34ceb38fc55 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -264,7 +264,7 @@ static void nft_ct_set_eval(const struct nft_expr *expr,
 	struct nf_conn *ct;
 
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct == NULL)
+	if (ct == NULL || nf_ct_is_template(ct))
 		return;
 
 	switch (priv->key) {
@@ -284,6 +284,22 @@ static void nft_ct_set_eval(const struct nft_expr *expr,
 				      NF_CT_LABELS_MAX_SIZE / sizeof(u32));
 		break;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
+	case NFT_CT_EVENTMASK: {
+		struct nf_conntrack_ecache *e = nf_ct_ecache_find(ct);
+		u32 ctmask = regs->data[priv->sreg];
+
+		if (e) {
+			if (e->ctmask != ctmask)
+				e->ctmask = ctmask;
+			break;
+		}
+
+		if (ctmask && !nf_ct_is_confirmed(ct))
+			nf_ct_ecache_ext_add(ct, ctmask, 0, GFP_ATOMIC);
+		break;
+	}
+#endif
 	default:
 		break;
 	}
@@ -539,6 +555,13 @@ static int nft_ct_set_init(const struct nft_ctx *ctx,
 		len = sizeof(u16);
 		break;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_EVENTS
+	case NFT_CT_EVENTMASK:
+		if (tb[NFTA_CT_DIRECTION])
+			return -EINVAL;
+		len = sizeof(u32);
+		break;
+#endif
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.1.4

