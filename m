From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/4] net: Add skb_headers_offset_update helper function.
Date: Fri, 15 Feb 2013 17:06:02 -0800
Message-ID: <1360976762-1825-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, stephen@networkplumber.org,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:40606 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750858Ab3BPBEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 20:04:20 -0500
Received: by mail-qa0-f69.google.com with SMTP id hy16so1983701qab.8
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 17:04:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function will be used in next VXLAN-TSO patch. This patch does
not change any functionality.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/core/skbuff.c |   34 ++++++++++++++--------------------
 1 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2a3ca33..d388e77 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -867,6 +867,17 @@ struct sk_buff *skb_clone(struct sk_buff *skb, gfp_t gfp_mask)
 }
 EXPORT_SYMBOL(skb_clone);
 
+static void skb_headers_offset_update(struct sk_buff *skb, int off)
+{
+	/* {transport,network,mac}_header and tail are relative to skb->head */
+	skb->transport_header += off;
+	skb->network_header   += off;
+	if (skb_mac_header_was_set(skb))
+		skb->mac_header += off;
+	skb->inner_transport_header += off;
+	skb->inner_network_header += off;
+}
+
 static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 {
 #ifndef NET_SKBUFF_DATA_USES_OFFSET
@@ -879,13 +890,7 @@ static void copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	__copy_skb_header(new, old);
 
 #ifndef NET_SKBUFF_DATA_USES_OFFSET
-	/* {transport,network,mac}_header are relative to skb->head */
-	new->transport_header += offset;
-	new->network_header   += offset;
-	if (skb_mac_header_was_set(new))
-		new->mac_header	      += offset;
-	new->inner_transport_header += offset;
-	new->inner_network_header   += offset;
+	skb_headers_offset_update(new, offset);
 #endif
 	skb_shinfo(new)->gso_size = skb_shinfo(old)->gso_size;
 	skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
@@ -1077,14 +1082,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 #else
 	skb->end      = skb->head + size;
 #endif
-	/* {transport,network,mac}_header and tail are relative to skb->head */
 	skb->tail	      += off;
-	skb->transport_header += off;
-	skb->network_header   += off;
-	if (skb_mac_header_was_set(skb))
-		skb->mac_header += off;
-	skb->inner_transport_header += off;
-	skb->inner_network_header += off;
+	skb_headers_offset_update(skb, off);
 	/* Only adjust this if it actually is csum_start rather than csum */
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		skb->csum_start += nhead;
@@ -1180,12 +1179,7 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 	if (n->ip_summed == CHECKSUM_PARTIAL)
 		n->csum_start += off;
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
-	n->transport_header += off;
-	n->network_header   += off;
-	if (skb_mac_header_was_set(skb))
-		n->mac_header += off;
-	n->inner_transport_header += off;
-	n->inner_network_header	   += off;
+	skb_headers_offset_update(n, off);
 #endif
 
 	return n;
-- 
1.7.1
