From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/6] net: generalize skb_segment()
Date: Sat, 19 Oct 2013 11:42:54 -0700
Message-ID: <1382208178-22347-3-git-send-email-edumazet@google.com>
References: <1382208178-22347-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:56145 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab3JSSnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 14:43:10 -0400
Received: by mail-qa0-f74.google.com with SMTP id ii20so199883qab.3
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 11:43:09 -0700 (PDT)
In-Reply-To: <1382208178-22347-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While implementing GSO/TSO support for IPIP, I found skb_segment()
was assuming network header was immediately following mac header.

Its not really true in the case inet_gso_segment() is stacked :
By the time tcp_gso_segment() is called, network header points
to the inner IP header.

Let's instead assume nothing and pick the current offsets found in
original skb, we have skb_headers_offset_update() helper for that.

Also move the csum_start update inside skb_headers_offset_update()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/skbuff.c | 22 +++++-----------------
 1 file changed, 5 insertions(+), 17 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8ead744..0ab32fa 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -903,6 +903,9 @@ EXPORT_SYMBOL(skb_clone);
 
 static void skb_headers_offset_update(struct sk_buff *skb, int off)
 {
+	/* Only adjust this if it actually is csum_start rather than csum */
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		skb->csum_start += off;
 	/* {transport,network,mac}_header and tail are relative to skb->head */
 	skb->transport_header += off;
 	skb->network_header   += off;
@@ -1109,9 +1112,6 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 #endif
 	skb->tail	      += off;
 	skb_headers_offset_update(skb, nhead);
-	/* Only adjust this if it actually is csum_start rather than csum */
-	if (skb->ip_summed == CHECKSUM_PARTIAL)
-		skb->csum_start += nhead;
 	skb->cloned   = 0;
 	skb->hdr_len  = 0;
 	skb->nohdr    = 0;
@@ -1176,7 +1176,6 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 					NUMA_NO_NODE);
 	int oldheadroom = skb_headroom(skb);
 	int head_copy_len, head_copy_off;
-	int off;
 
 	if (!n)
 		return NULL;
@@ -1200,11 +1199,7 @@ struct sk_buff *skb_copy_expand(const struct sk_buff *skb,
 
 	copy_skb_header(n, skb);
 
-	off                  = newheadroom - oldheadroom;
-	if (n->ip_summed == CHECKSUM_PARTIAL)
-		n->csum_start += off;
-
-	skb_headers_offset_update(n, off);
+	skb_headers_offset_update(n, newheadroom - oldheadroom);
 
 	return n;
 }
@@ -2837,14 +2832,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		__copy_skb_header(nskb, skb);
 		nskb->mac_len = skb->mac_len;
 
-		/* nskb and skb might have different headroom */
-		if (nskb->ip_summed == CHECKSUM_PARTIAL)
-			nskb->csum_start += skb_headroom(nskb) - headroom;
-
-		skb_reset_mac_header(nskb);
-		skb_set_network_header(nskb, skb->mac_len);
-		nskb->transport_header = (nskb->network_header +
-					  skb_network_header_len(skb));
+		skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);
 
 		skb_copy_from_linear_data_offset(skb, -tnl_hlen,
 						 nskb->data - tnl_hlen,
-- 
1.8.4
