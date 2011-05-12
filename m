From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 10/15] ehea: Simplify type 3 transmit routine
Date: Thu, 12 May 2011 10:52:23 +1000
Message-ID: <20110512005623.360860022@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54692 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755480Ab1ELB2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:28:00 -0400
Content-Disposition: inline; filename=ehea_13.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a nonlinear skb fits within the immediate area, use skb_copy_bits
instead of copying the frags by hand.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-12 07:47:59.140267294 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-12 07:48:00.220284417 +1000
@@ -2091,29 +2091,14 @@ static void ehea_xmit2(struct sk_buff *s
 static void ehea_xmit3(struct sk_buff *skb, struct net_device *dev,
 		       struct ehea_swqe *swqe)
 {
-	int nfrags = skb_shinfo(skb)->nr_frags;
 	u8 *imm_data = &swqe->u.immdata_nodesc.immediate_data[0];
-	skb_frag_t *frag;
-	int i;
 
 	xmit_common(skb, swqe);
 
-	if (nfrags == 0) {
+	if (!skb->data_len)
 		skb_copy_from_linear_data(skb, imm_data, skb->len);
-	} else {
-		skb_copy_from_linear_data(skb, imm_data,
-					  skb_headlen(skb));
-		imm_data += skb_headlen(skb);
-
-		/* ... then copy data from the fragments */
-		for (i = 0; i < nfrags; i++) {
-			frag = &skb_shinfo(skb)->frags[i];
-			memcpy(imm_data,
-			       page_address(frag->page) + frag->page_offset,
-			       frag->size);
-			imm_data += frag->size;
-		}
-	}
+	else
+		skb_copy_bits(skb, 0, imm_data, skb->len);
 
 	swqe->immediate_data_length = skb->len;
 	dev_kfree_skb(skb);


