From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/2] net: Add function to get SW rxhash
Date: Tue, 24 Sep 2013 09:20:51 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1309240915001.24581@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f202.google.com ([209.85.220.202]:49662 "EHLO
	mail-vc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856Ab3IXQUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:20:52 -0400
Received: by mail-vc0-f202.google.com with SMTP id gd11so541022vcb.3
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:20:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some uses of skb_get_rxhash expect that the function will return
a consistent value whether it is called on RX or TX paths. On RX
path, we will use the rxhash if provided by the NIC, so this
would not normally be the same result computed in TX path which is
a software calculation.

This patch adds skb_get_sw_rxhash to explicitly request a hash
calculated by the stack, disregarding the hash provided by NIC.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h    | 11 ++++++++++-
 net/core/flow_dissector.c |  1 +
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2ddb48d..917a590 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -488,6 +488,7 @@ struct sk_buff {
 	__u8			pfmemalloc:1;
 	__u8			ooo_okay:1;
 	__u8			l4_rxhash:1;
+	__u8			sw_rxhash:1;
 	__u8			wifi_acked_valid:1;
 	__u8			wifi_acked:1;
 	__u8			no_fcs:1;
@@ -498,7 +499,7 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
-	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
+	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
@@ -726,6 +727,14 @@ static inline __u32 skb_get_rxhash(struct sk_buff *skb)
 	return skb->rxhash;
 }
 
+static inline __u32 skb_get_sw_rxhash(struct sk_buff *skb)
+{
+	if (!skb->l4_rxhash && !skb->sw_rxhash)
+		__skb_get_rxhash(skb);
+
+	return skb->rxhash;
+}
+
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 static inline unsigned char *skb_end_pointer(const struct sk_buff *skb)
 {
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1929af8..8979121 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -200,6 +200,7 @@ void __skb_get_rxhash(struct sk_buff *skb)
 		hash = 1;
 
 	skb->rxhash = hash;
+	skb->sw_rxhash = 1;
 }
 EXPORT_SYMBOL(__skb_get_rxhash);
 
-- 
1.8.4
