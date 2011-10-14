From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 10/15] ehea: Simplify type 3 transmit routine
Date: Fri, 14 Oct 2011 12:31:07 -0300
Message-ID: <1318606272-27647-11-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp03.br.ibm.com ([32.104.18.24]:39757 "EHLO
	e24smtp03.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933237Ab1JNPcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:32:04 -0400
Received: from /spool/local
	by br.ibm.com with XMail ESMTP
	for <netdev@vger.kernel.org> from <cascardo@linux.vnet.ibm.com>;
	Fri, 14 Oct 2011 12:32:01 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFZKLR700912
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:35:22 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVaKl008768
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:36 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

If a nonlinear skb fits within the immediate area, use skb_copy_bits
instead of copying the frags by hand.

v3:
[cascardo] fixed conflict with use of skb frag API

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   19 +++----------------
 1 files changed, 3 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 0fc0ae8..289ad4d 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -2087,27 +2087,14 @@ static void ehea_xmit2(struct sk_buff *skb, struct net_device *dev,
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
-			memcpy(imm_data, skb_frag_address(frag), frag->size);
-			imm_data += frag->size;
-		}
-	}
+	else
+		skb_copy_bits(skb, 0, imm_data, skb->len);
 
 	swqe->immediate_data_length = skb->len;
 	dev_kfree_skb(skb);
-- 
1.7.4.4
