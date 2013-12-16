From: Matthew Whitehead <tedheadster@gmail.com>
Subject: [PATCH net-next] 3c59x: Add software timestamping
Date: Mon, 16 Dec 2013 10:20:26 -0500
Message-ID: <1387207226-17076-1-git-send-email-tedheadster@gmail.com>
Cc: Matthew Whitehead <tedheadster@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:62813 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab3LPP1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:27:46 -0500
Received: by mail-ie0-f172.google.com with SMTP id qd12so6655617ieb.17
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 07:27:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added software timestamping ability. Tested with linuxptp and synchronized
clocks to an average of less than 200 microseconds on 10 megabit ethernet.

Tested on both Vortex and Boomerang models.

Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>
---
 drivers/net/ethernet/3com/3c59x.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index ad5272b..10ad402 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2079,10 +2079,12 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		iowrite16(len, ioaddr + Wn7_MasterLen);
 		spin_unlock_irq(&vp->window_lock);
 		vp->tx_skb = skb;
+		skb_tx_timestamp(skb);
 		iowrite16(StartDMADown, ioaddr + EL3_CMD);
 		/* netif_wake_queue() will be called at the DMADone interrupt. */
 	} else {
 		/* ... and the packet rounded to a doubleword. */
+		skb_tx_timestamp(skb);
 		iowrite32_rep(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
 		dev_kfree_skb (skb);
 		if (ioread16(ioaddr + TxFree) > 1536) {
@@ -2212,6 +2214,7 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		prev_entry->status &= cpu_to_le32(~TxIntrUploaded);
 #endif
 	}
+	skb_tx_timestamp(skb);
 	iowrite16(DownUnstall, ioaddr + EL3_CMD);
 	spin_unlock_irqrestore(&vp->lock, flags);
 	return NETDEV_TX_OK;
@@ -2986,6 +2989,7 @@ static const struct ethtool_ops vortex_ethtool_ops = {
 	.nway_reset             = vortex_nway_reset,
 	.get_wol                = vortex_get_wol,
 	.set_wol                = vortex_set_wol,
+	.get_ts_info		= ethtool_op_get_ts_info,
 };
 
 #ifdef CONFIG_PCI
-- 
1.7.1
