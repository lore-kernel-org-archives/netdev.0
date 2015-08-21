From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 15/15] netfilter: nft_payload: work around vlan header stripping
Date: Fri, 21 Aug 2015 06:32:44 +0200
Message-ID: <1440131564-8807-16-git-send-email-pablo@netfilter.org>
References: <1440131564-8807-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48187 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbbHUE1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 00:27:32 -0400
In-Reply-To: <1440131564-8807-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

make payload expression aware of the fact that VLAN offload may have
removed a vlan header.

When we encounter tagged skb, transparently insert the tag into the
register so that vlan header matching can work without userspace being
aware of offload features.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nft_payload.c |   57 ++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 56 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nft_payload.c b/net/netfilter/nft_payload.c
index 94fb3b2..09b4b07 100644
--- a/net/netfilter/nft_payload.c
+++ b/net/netfilter/nft_payload.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/kernel.h>
+#include <linux/if_vlan.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/netlink.h>
@@ -17,6 +18,53 @@
 #include <net/netfilter/nf_tables_core.h>
 #include <net/netfilter/nf_tables.h>
 
+/* add vlan header into the user buffer for if tag was removed by offloads */
+static bool
+nft_payload_copy_vlan(u32 *d, const struct sk_buff *skb, u8 offset, u8 len)
+{
+	int mac_off = skb_mac_header(skb) - skb->data;
+	u8 vlan_len, *vlanh, *dst_u8 = (u8 *) d;
+	struct vlan_ethhdr veth;
+
+	vlanh = (u8 *) &veth;
+	if (offset < ETH_HLEN) {
+		u8 ethlen = min_t(u8, len, ETH_HLEN - offset);
+
+		if (skb_copy_bits(skb, mac_off, &veth, ETH_HLEN))
+			return false;
+
+		veth.h_vlan_proto = skb->vlan_proto;
+
+		memcpy(dst_u8, vlanh + offset, ethlen);
+
+		len -= ethlen;
+		if (len == 0)
+			return true;
+
+		dst_u8 += ethlen;
+		offset = ETH_HLEN;
+	} else if (offset >= VLAN_ETH_HLEN) {
+		offset -= VLAN_HLEN;
+		goto skip;
+	}
+
+	veth.h_vlan_TCI = htons(skb_vlan_tag_get(skb));
+	veth.h_vlan_encapsulated_proto = skb->protocol;
+
+	vlanh += offset;
+
+	vlan_len = min_t(u8, len, VLAN_ETH_HLEN - offset);
+	memcpy(dst_u8, vlanh, vlan_len);
+
+	len -= vlan_len;
+	if (!len)
+		return true;
+
+	dst_u8 += vlan_len;
+ skip:
+	return skb_copy_bits(skb, offset + mac_off, dst_u8, len) == 0;
+}
+
 static void nft_payload_eval(const struct nft_expr *expr,
 			     struct nft_regs *regs,
 			     const struct nft_pktinfo *pkt)
@@ -26,10 +74,18 @@ static void nft_payload_eval(const struct nft_expr *expr,
 	u32 *dest = &regs->data[priv->dreg];
 	int offset;
 
+	dest[priv->len / NFT_REG32_SIZE] = 0;
 	switch (priv->base) {
 	case NFT_PAYLOAD_LL_HEADER:
 		if (!skb_mac_header_was_set(skb))
 			goto err;
+
+		if (skb_vlan_tag_present(skb)) {
+			if (!nft_payload_copy_vlan(dest, skb,
+						   priv->offset, priv->len))
+				goto err;
+			return;
+		}
 		offset = skb_mac_header(skb) - skb->data;
 		break;
 	case NFT_PAYLOAD_NETWORK_HEADER:
@@ -43,7 +99,6 @@ static void nft_payload_eval(const struct nft_expr *expr,
 	}
 	offset += priv->offset;
 
-	dest[priv->len / NFT_REG32_SIZE] = 0;
 	if (skb_copy_bits(skb, offset, dest, priv->len) < 0)
 		goto err;
 	return;
-- 
1.7.10.4
