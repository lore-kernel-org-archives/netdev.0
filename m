From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] r8169: fix 8168evl frame padding.
Date: Sat, 27 Apr 2013 01:49:32 +0200
Message-ID: <20130426234932.GA20296@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>,
	Stefan Bader <stefan.bader@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47897 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480Ab3DZXtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 19:49:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Bader <stefan.bader@canonical.com>

Signed-off-by: Stefan Bader <stefan.bader@canonical.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: hayeswang <hayeswang@realtek.com>
---

Stefan reported that Realtek's driver solves his problem as well.
It works differently though: skb_checksum_help vs skb_pad here.

 drivers/net/ethernet/realtek/r8169.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 4ecbe64..15ba8c4 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -5787,6 +5787,14 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 		goto err_stop_0;
 	}
 
+	/* 8168evl does not automatically pad to minimum length. */
+	if (unlikely(tp->mac_version == RTL_GIGA_MAC_VER_34 &&
+		     skb->len < ETH_ZLEN)) {
+		if (skb_padto(skb, ETH_ZLEN))
+			goto err_update_stats;
+		skb_put(skb, ETH_ZLEN - skb->len);
+	}
+
 	if (unlikely(le32_to_cpu(txd->opts1) & DescOwn))
 		goto err_stop_0;
 
@@ -5858,6 +5866,7 @@ err_dma_1:
 	rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
 err_dma_0:
 	dev_kfree_skb(skb);
+err_update_stats:
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
 
-- 
1.8.1.4
