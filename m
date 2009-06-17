From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] skbuff:  don't corrupt mac_header on skb expansion
Date: Wed, 17 Jun 2009 15:17:34 -0700
Message-ID: <20090617151734.5ce02459@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33074 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835AbZFQWRh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 18:17:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb mac_header field is sometimes NULL (or ~0u) as a sentinel
value. The places where skb is expanded add an offset which would
change this flag into an invalid pointer (or offset).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/core/skbuff.c	2009-06-17 15:02:19.208725168 -0700
+++ b/net/core/skbuff.c	2009-06-17 15:04:50.139435754 -0700
@@ -657,7 +657,8 @@ static void copy_skb_header(struct sk_bu
 	/* {transport,network,mac}_header are relative to skb->head */
 	new->transport_header += offset;
 	new->network_header   += offset;
-	new->mac_header	      += offset;
+	if (skb_mac_header_was_set(new))
+		new->mac_header	      += offset;
 #endif
 	skb_shinfo(new)->gso_size = skb_shinfo(old)->gso_size;
 	skb_shinfo(new)->gso_segs = skb_shinfo(old)->gso_segs;
@@ -839,7 +840,8 @@ int pskb_expand_head(struct sk_buff *skb
 	skb->tail	      += off;
 	skb->transport_header += off;
 	skb->network_header   += off;
-	skb->mac_header	      += off;
+	if (skb_mac_header_was_set(skb))
+		skb->mac_header += off;
 	skb->csum_start       += nhead;
 	skb->cloned   = 0;
 	skb->hdr_len  = 0;
@@ -931,7 +933,8 @@ struct sk_buff *skb_copy_expand(const st
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 	n->transport_header += off;
 	n->network_header   += off;
-	n->mac_header	    += off;
+	if (skb_mac_header_was_set(skb))
+		n->mac_header += off;
 #endif
 
 	return n;
