From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 10/14] ehea: Simplify type 3 transmit routine
Date: Tue, 5 Apr 2011 21:41:08 +1000
Message-ID: <20110405214108.2fbed081@kryten>
References: <20110405212825.6eb85677@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael@ellerman.id.au
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46695 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753183Ab1DELlL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:41:11 -0400
In-Reply-To: <20110405212825.6eb85677@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If a nonlinear skb fits within the immediate area, use skb_copy_bits
instead of copying the frags by hand.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-2.6/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_main.c	2011-03-21 18:32:44.258651836 +1100
+++ linux-2.6/drivers/net/ehea/ehea_main.c	2011-03-21 18:32:50.638888481 +1100
@@ -2095,29 +2095,14 @@ static void ehea_xmit2(struct sk_buff *s
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
