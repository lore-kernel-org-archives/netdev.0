From: Andy Cress <andycress@gmail.com>
Subject: [PATCH 3/3] pch_gbe: vlan skb len fix
Date: Thu, 26 Jul 2012 12:01:17 -0400
Message-ID: <20120726160117.GD10287@telcoserv5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:60216 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500Ab2GZP7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 11:59:44 -0400
Received: by vbbff1 with SMTP id ff1so1796984vbb.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 08:59:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


pch_gbe_xmit_frame skb->len verification was incorrect in vlan case 
causing bogus transfer length errors.  One correction could be:
    offset = skb->protocol == htons(ETH_P_8021Q) ? 0 : 4;
    if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - offset))) 
However, this verification is not necessary, so remove it.

Signed-off-by: Andy Cress <andy.cress@us.kontron.com>

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 000ef68..817614c 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2157,13 +2157,6 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
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
