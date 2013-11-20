From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/5] net: Add flag for SW computed rxhash
Date: Wed, 20 Nov 2013 12:26:21 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311201220310.19505@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, edumazet@google.com, hkchu@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:34869 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755002Ab3KTUbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:31:49 -0500
Received: by mail-oa0-f74.google.com with SMTP id o6so834252oag.5
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 12:31:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds sw_rxhash flag bit to the skbuff.  It is set in
flow_dissecor.c to indicate that the rxhash was computed in the stack
as opposed to being provided by hardware.  This flag is checked in
skb_get_rxhash so don't repeatedly do full flow dissection every
time for a packet for which we can't extract an L4 hash.  The
skb_get_sw_rxhash function was also added to explictly force that
the rxhash is computed by the stack.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h    | 14 ++++++++++++--
 net/core/flow_dissector.c |  1 +
 net/core/skbuff.c         |  1 +
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 76d3aa9..3c8ea3c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -379,6 +379,7 @@ typedef unsigned char *sk_buff_data_t;
  *	@ooo_okay: allow the mapping of a socket to a queue to be changed
  *	@l4_rxhash: indicate rxhash is a canonical 4-tuple hash over transport
  *		ports.
+ *	@sw_rxhash: indicate rxhash was computed in software (flow_dissector).
  *	@wifi_acked_valid: wifi_acked was set
  *	@wifi_acked: whether frame was acked on wifi or not
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
@@ -483,6 +484,7 @@ struct sk_buff {
 	__u8			pfmemalloc:1;
 	__u8			ooo_okay:1;
 	__u8			l4_rxhash:1;
+	__u8			sw_rxhash:1;
 	__u8			wifi_acked_valid:1;
 	__u8			wifi_acked:1;
 	__u8			no_fcs:1;
@@ -493,7 +495,7 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
-	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
+	/* 5/7 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #if defined CONFIG_NET_DMA || defined CONFIG_NET_RX_BUSY_POLL
@@ -706,7 +708,15 @@ unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
 void __skb_get_rxhash(struct sk_buff *skb);
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
index d6ef173..6a4bee4 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -233,6 +233,7 @@ void __skb_get_rxhash(struct sk_buff *skb)
 		hash = 1;
 
 	skb->rxhash = hash;
+	skb->sw_rxhash = 1;
 }
 EXPORT_SYMBOL(__skb_get_rxhash);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8cec1e6..a16f486 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -715,6 +715,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->rxhash		= old->rxhash;
 	new->ooo_okay		= old->ooo_okay;
 	new->l4_rxhash		= old->l4_rxhash;
+	new->sw_rxhash		= old->sw_rxhash;
 	new->no_fcs		= old->no_fcs;
 	new->encapsulation	= old->encapsulation;
 #ifdef CONFIG_XFRM
-- 
1.8.4.1
