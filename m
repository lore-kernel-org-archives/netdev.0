From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH v2 net-next 1/3] net: simplify and make pkt_type_ok() available for other users
Date: Sat,  2 Jul 2016 06:43:14 -0400
Message-ID: <1467456196-25712-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, fw@strlen.de,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35246 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbcGBKn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 06:43:27 -0400
Received: by mail-io0-f194.google.com with SMTP id u25so13852114iou.2
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 03:43:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 include/linux/skbuff.h   | 10 ++++++++++
 net/netfilter/nft_meta.c |  9 +--------
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index dc0fca7..638b0e0 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -37,6 +37,7 @@
 #include <net/flow_dissector.h>
 #include <linux/splice.h>
 #include <linux/in6.h>
+#include <linux/if_packet.h>
 #include <net/flow.h>
 
 /* The interface for checksum offload between the stack and networking drivers
@@ -881,6 +882,15 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
 	return (struct rtable *)skb_dst(skb);
 }
 
+/* For mangling skb->pkt_type from user space side from applications
+ * such as nft, tc, etc, we only allow a conservative subset of
+ * possible pkt_types to be set.
+*/
+static inline bool skb_pkt_type_ok(u32 ptype)
+{
+	return ptype <= PACKET_OTHERHOST;
+}
+
 void kfree_skb(struct sk_buff *skb);
 void kfree_skb_list(struct sk_buff *segs);
 void skb_tx_error(struct sk_buff *skb);
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 16c50b0..03e5e33 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -199,13 +199,6 @@ err:
 }
 EXPORT_SYMBOL_GPL(nft_meta_get_eval);
 
-/* don't change or set _LOOPBACK, _USER, etc. */
-static bool pkt_type_ok(u32 p)
-{
-	return p == PACKET_HOST || p == PACKET_BROADCAST ||
-	       p == PACKET_MULTICAST || p == PACKET_OTHERHOST;
-}
-
 void nft_meta_set_eval(const struct nft_expr *expr,
 		       struct nft_regs *regs,
 		       const struct nft_pktinfo *pkt)
@@ -223,7 +216,7 @@ void nft_meta_set_eval(const struct nft_expr *expr,
 		break;
 	case NFT_META_PKTTYPE:
 		if (skb->pkt_type != value &&
-		    pkt_type_ok(value) && pkt_type_ok(skb->pkt_type))
+		    skb_pkt_type_ok(value) && skb_pkt_type_ok(skb->pkt_type))
 			skb->pkt_type = value;
 		break;
 	case NFT_META_NFTRACE:
-- 
1.9.1
