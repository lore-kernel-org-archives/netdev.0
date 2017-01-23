From: Davide Caratti <dcaratti@redhat.com>
Subject: [RFC PATCH net-next 2/5] net: split skb_checksum_help
Date: Mon, 23 Jan 2017 17:52:43 +0100
Message-ID: <532e1db70b6c40f1b1e5c60b5b51be9f3437a30b.1485177252.git.dcaratti@redhat.com>
References: <cover.1485177252.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35998 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750828AbdAWQ7T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 11:59:19 -0500
In-Reply-To: <cover.1485177252.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_checksum_help is designed to compute the Internet Checksum only. To
avoid duplicating code when other checksumming algorithms (e.g. crc32c)
are used, separate common part from RFC1624-specific part.

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 net/core/dev.c | 51 +++++++++++++++++++++++++++++++++++----------------
 1 file changed, 35 insertions(+), 16 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index ad5959e..6742160 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2532,13 +2532,36 @@ static void skb_warn_bad_offload(const struct sk_buff *skb)
 	     skb_shinfo(skb)->gso_type, skb->ip_summed);
 }
 
-/*
- * Invalidate hardware checksum when packet is to be mangled, and
+/* compute 16-bit RFC1624 checksum and store it at skb->data + offset */
+static int skb_rfc1624_csum(struct sk_buff *skb, int offset)
+{
+	__wsum csum;
+	int ret = 0;
+
+	csum = skb_checksum(skb, offset, skb->len - offset, 0);
+
+	offset += skb->csum_offset;
+	BUG_ON(offset + sizeof(__sum16) > skb_headlen(skb));
+
+	if (skb_cloned(skb) &&
+	    !skb_clone_writable(skb, offset + sizeof(__sum16))) {
+		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+		if (ret)
+			goto out;
+	}
+	*(__sum16 *)(skb->data + offset) = csum_fold(csum) ?: CSUM_MANGLED_0;
+out:
+	return ret;
+}
+
+/* Invalidate hardware checksum when packet is to be mangled, and
  * complete checksum manually on outgoing path.
+ *    @skb - buffer that needs checksum
+ *    @csum_algo(skb, offset) - function used to compute the checksum
  */
-int skb_checksum_help(struct sk_buff *skb)
+static int __skb_checksum_help(struct sk_buff *skb,
+			       int (*csum_algo)(struct sk_buff *, int))
 {
-	__wsum csum;
 	int ret = 0, offset;
 
 	if (skb->ip_summed == CHECKSUM_COMPLETE)
@@ -2560,24 +2583,20 @@ int skb_checksum_help(struct sk_buff *skb)
 
 	offset = skb_checksum_start_offset(skb);
 	BUG_ON(offset >= skb_headlen(skb));
-	csum = skb_checksum(skb, offset, skb->len - offset, 0);
-
-	offset += skb->csum_offset;
-	BUG_ON(offset + sizeof(__sum16) > skb_headlen(skb));
-
-	if (skb_cloned(skb) &&
-	    !skb_clone_writable(skb, offset + sizeof(__sum16))) {
-		ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (ret)
-			goto out;
-	}
 
-	*(__sum16 *)(skb->data + offset) = csum_fold(csum) ?: CSUM_MANGLED_0;
+	ret = csum_algo(skb, offset);
+	if (ret)
+		goto out;
 out_set_summed:
 	skb->ip_summed = CHECKSUM_NONE;
 out:
 	return ret;
 }
+
+int skb_checksum_help(struct sk_buff *skb)
+{
+	return __skb_checksum_help(skb, skb_rfc1624_csum);
+}
 EXPORT_SYMBOL(skb_checksum_help);
 
 __be16 skb_network_protocol(struct sk_buff *skb, int *depth)
-- 
2.7.4
