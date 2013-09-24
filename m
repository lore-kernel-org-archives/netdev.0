From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/2 v2] net: Add function to get SW rxhash
Date: Tue, 24 Sep 2013 13:42:07 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1309241335380.23856@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f202.google.com ([209.85.213.202]:46782 "EHLO
	mail-ye0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951Ab3IXUmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 16:42:09 -0400
Received: by mail-ye0-f202.google.com with SMTP id r14so589852yen.1
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 13:42:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some uses of skb_get_rxhash expect that the function will return
a consistent value whether it is called on RX or TX paths. On RX
path, we will use the rxhash if provided by the NIC, so this
would not normally be the same result computed in TX path would be
a software calculation.

This patch adds skb_get_sw_rxhash to explicitly request a hash
calculated by the stack, disregarding the hash provided by NIC.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h    | 14 ++++++++++++--
 net/core/flow_dissector.c |  1 +
 net/core/skbuff.c         |  1 +
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2ddb48d..fdde013 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -381,6 +381,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
  *	@l4_rxhash: indicate rxhash is a canonical 4-tuple hash over transport
  *		ports.
+ *	@sw_rxhash: indicate rxhash was computed by the stack
  *	@wifi_acked_valid: wifi_acked was set
  *	@wifi_acked: whether frame was acked on wifi or not
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
@@ -488,6 +489,7 @@ struct sk_buff {
 	__u8			pfmemalloc:1;
 	__u8			ooo_okay:1;
 	__u8			l4_rxhash:1;
+	__u8			sw_rxhash:1;
 	__u8			wifi_acked_valid:1;
 	__u8			wifi_acked:1;
 	__u8			no_fcs:1;
@@ -498,7 +500,7 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
-	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
+	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
@@ -720,7 +722,15 @@ extern unsigned int   skb_find_text(struct sk_buff *skb, unsigned int from,
 extern void __skb_get_rxhash(struct sk_buff *skb);
 static inline __u32 skb_get_rxhash(struct sk_buff *skb)
 {
-	if (!skb->l4_rxhash)
+	if (!skb->l4_rxhash && !skb->sw_rxhash)
+		__skb_get_rxhash(skb);
+
+	return skb->rxhash;
+}
+
+static inline __u32 skb_get_sw_rxhash(struct sk_buff *skb)
+{
+	if (!skb->sw_rxhash)
 		__skb_get_rxhash(skb);
 
 	return skb->rxhash;
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
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d81cff1..5021318 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -706,6 +706,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->rxhash		= old->rxhash;
 	new->ooo_okay		= old->ooo_okay;
 	new->l4_rxhash		= old->l4_rxhash;
+	new->sw_rxhash		= old->sw_rxhash;
 	new->no_fcs		= old->no_fcs;
 	new->encapsulation	= old->encapsulation;
 #ifdef CONFIG_XFRM
-- 
1.8.4
