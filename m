From: "Andy Cress" <andy.cress@us.kontron.com>
Subject: [PATCH 4/4] pch_gbe: vlan skb len fix
Date: Mon, 16 Jul 2012 13:05:49 -0700
Message-ID: <40680C535D6FE6498883F1640FACD44D011432DC@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.kontron.com ([209.118.138.70]:46201 "EHLO
	mail.us.kontron.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075Ab2GPUFx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 16:05:53 -0400
Received: from ka-exchange-1.kontronamerica.local ([10.100.2.39]) by mail.us.kontron.com with ESMTP id sTlsZ4CfnfjyuPlW for <netdev@vger.kernel.org>; Mon, 16 Jul 2012 13:05:52 -0700 (PDT)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Author: Veaceslav Falico <vfalico@redhat.com>
Date:   Tue Apr 10 08:14:17 2012 +0200

pch_gbe_xmit_frame skb->len verification was incorrect in vlan case 
causing bogus transfer length errors.  One correction could be:
    offset = skb->protocol == htons(ETH_P_8021Q) ? 0 : 4;
    if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - offset))) 
However, this verification is not necessary, so remove it.

Merged-by: Andy Cress <andy.cress@us.kontron.com>
Signed-off-by: Andy Cress <andy.cress@us.kontron.com>

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 2ccdca6..5eaac7f 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2160,13 +2160,6 @@ static int pch_gbe_xmit_frame(struct sk_buff
*skb, struct net_device *netdev)
 	struct pch_gbe_tx_ring *tx_ring = adapter->tx_ring;
 	unsigned long flags;
 
-	if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
-		pr_err("Transfer length Error: skb len: %d > max: %d\n",
-		       skb->len, adapter->hw.mac.max_frame_size);
-		dev_kfree_skb_any(skb);
-		adapter->stats.tx_length_errors++;
-		return NETDEV_TX_OK;
-	}
 	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags)) {
 		/* Collision - tell upper layer to requeue */
 		return NETDEV_TX_LOCKED;
