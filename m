From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 2/2] enic: use spin_lock(wq_lock) instead of spin_lock_irqsave(wq_lock)
Date: Sun, 23 Nov 2014 01:22:52 +0530
Message-ID: <1416685972-1368-2-git-send-email-_govind@gmx.com>
References: <1416685972-1368-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:60954 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752453AbaKVTyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 14:54:16 -0500
In-Reply-To: <1416685972-1368-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the access to wq has been moved out of hardirq context. We no longer need to
use spin_lock_irqsave.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index b42a480..4664740 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -529,7 +529,6 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 {
 	struct enic *enic = netdev_priv(netdev);
 	struct vnic_wq *wq;
-	unsigned long flags;
 	unsigned int txq_map;
 	struct netdev_queue *txq;
 
@@ -554,14 +553,14 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	spin_lock_irqsave(&enic->wq_lock[txq_map], flags);
+	spin_lock(&enic->wq_lock[txq_map]);
 
 	if (vnic_wq_desc_avail(wq) <
 	    skb_shinfo(skb)->nr_frags + ENIC_DESC_MAX_SPLITS) {
 		netif_tx_stop_queue(txq);
 		/* This is a hard error, log it */
 		netdev_err(netdev, "BUG! Tx ring full when queue awake!\n");
-		spin_unlock_irqrestore(&enic->wq_lock[txq_map], flags);
+		spin_unlock(&enic->wq_lock[txq_map]);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -572,7 +571,7 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 	if (!skb->xmit_more || netif_xmit_stopped(txq))
 		vnic_wq_doorbell(wq);
 
-	spin_unlock_irqrestore(&enic->wq_lock[txq_map], flags);
+	spin_unlock(&enic->wq_lock[txq_map]);
 
 	return NETDEV_TX_OK;
 }
-- 
2.1.0
