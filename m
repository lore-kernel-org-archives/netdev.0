From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/17] netfilter: nft_ct: add byte/packet counter support
Date: Fri,  8 Jan 2016 15:02:17 +0100
Message-ID: <1452261737-7475-18-git-send-email-pablo@netfilter.org>
References: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54144 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279AbcAHODc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 09:03:32 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 83F46DA88B
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:31 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 6C572DA86D
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:31 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 69686EBAF0
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 15:03:29 +0100 (CET)
In-Reply-To: <1452261737-7475-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

If the accounting extension isn't present, we'll return a counter
value of 0.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |  2 ++
 net/netfilter/nft_ct.c                   | 38 ++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 03c28a4..be41ffc 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -757,6 +757,8 @@ enum nft_ct_keys {
 	NFT_CT_PROTO_SRC,
 	NFT_CT_PROTO_DST,
 	NFT_CT_LABELS,
+	NFT_CT_PKTS,
+	NFT_CT_BYTES,
 };
 
 /**
diff --git a/net/netfilter/nft_ct.c b/net/netfilter/nft_ct.c
index 8cbca34..6f74109 100644
--- a/net/netfilter/nft_ct.c
+++ b/net/netfilter/nft_ct.c
@@ -16,6 +16,7 @@
 #include <linux/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables.h>
 #include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_acct.h>
 #include <net/netfilter/nf_conntrack_tuple.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
@@ -30,6 +31,18 @@ struct nft_ct {
 	};
 };
 
+static u64 nft_ct_get_eval_counter(const struct nf_conn_counter *c,
+				   enum nft_ct_keys k,
+				   enum ip_conntrack_dir d)
+{
+	if (d < IP_CT_DIR_MAX)
+		return k == NFT_CT_BYTES ? atomic64_read(&c[d].bytes) :
+					   atomic64_read(&c[d].packets);
+
+	return nft_ct_get_eval_counter(c, k, IP_CT_DIR_ORIGINAL) +
+	       nft_ct_get_eval_counter(c, k, IP_CT_DIR_REPLY);
+}
+
 static void nft_ct_get_eval(const struct nft_expr *expr,
 			    struct nft_regs *regs,
 			    const struct nft_pktinfo *pkt)
@@ -114,6 +127,17 @@ static void nft_ct_get_eval(const struct nft_expr *expr,
 			       NF_CT_LABELS_MAX_SIZE - size);
 		return;
 	}
+	case NFT_CT_BYTES: /* fallthrough */
+	case NFT_CT_PKTS: {
+		const struct nf_conn_acct *acct = nf_conn_acct_find(ct);
+		u64 count = 0;
+
+		if (acct)
+			count = nft_ct_get_eval_counter(acct->counter,
+							priv->key, priv->dir);
+		memcpy(dest, &count, sizeof(count));
+		return;
+	}
 #endif
 	default:
 		break;
@@ -291,6 +315,13 @@ static int nft_ct_get_init(const struct nft_ctx *ctx,
 			return -EINVAL;
 		len = FIELD_SIZEOF(struct nf_conntrack_tuple, src.u.all);
 		break;
+	case NFT_CT_BYTES:
+	case NFT_CT_PKTS:
+		/* no direction? return sum of original + reply */
+		if (tb[NFTA_CT_DIRECTION] == NULL)
+			priv->dir = IP_CT_DIR_MAX;
+		len = sizeof(u64);
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -373,6 +404,13 @@ static int nft_ct_get_dump(struct sk_buff *skb, const struct nft_expr *expr)
 	case NFT_CT_PROTO_DST:
 		if (nla_put_u8(skb, NFTA_CT_DIRECTION, priv->dir))
 			goto nla_put_failure;
+		break;
+	case NFT_CT_BYTES:
+	case NFT_CT_PKTS:
+		if (priv->dir < IP_CT_DIR_MAX &&
+		    nla_put_u8(skb, NFTA_CT_DIRECTION, priv->dir))
+			goto nla_put_failure;
+		break;
 	default:
 		break;
 	}
-- 
2.1.4
