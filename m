From: Pavel Andrianov <andrianov@ispras.ru>
Subject: [PATCH] libertas: Add spinlock to avoid race condition
Date: Wed, 15 Jun 2016 15:34:03 +0400
Message-ID: <1465990443-19738-1-git-send-email-andrianov@ispras.ru>
Cc: Pavel Andrianov <andrianov@ispras.ru>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org, vaishali.thakkar@oracle.com
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

lbs_mac_event_disconnected may free priv->currenttxskb
while lbs_hard_start_xmit accesses to it.
The patch adds a spinlock for mutual exclusion.

Tested on OLPC XO-1 (usb8388) and XO-1.5 (sd8686) with v4.7-rc3.

Confirmed that lbs_mac_event_disconnected is being called on the
station when hostapd on access point is given SIGHUP.

Signed-off-by: Pavel <andrianov@ispras.ru>
Tested-by: James Cameron <quozl@laptop.org>
---
 drivers/net/wireless/marvell/libertas/cmdresp.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/wireless/marvell/libertas/cmdresp.c b/drivers/net/wireless/marvell/libertas/cmdresp.c
index c95bf6d..c67ae07 100644
--- a/drivers/net/wireless/marvell/libertas/cmdresp.c
+++ b/drivers/net/wireless/marvell/libertas/cmdresp.c
@@ -27,6 +27,8 @@
 void lbs_mac_event_disconnected(struct lbs_private *priv,
 				bool locally_generated)
 {
+	unsigned long flags;
+
 	if (priv->connect_status != LBS_CONNECTED)
 		return;
 
@@ -46,9 +48,11 @@ void lbs_mac_event_disconnected(struct lbs_private *priv,
 	netif_carrier_off(priv->dev);
 
 	/* Free Tx and Rx packets */
+	spin_lock_irqsave(&priv->driver_lock, flags);
 	kfree_skb(priv->currenttxskb);
 	priv->currenttxskb = NULL;
 	priv->tx_pending_len = 0;
+	spin_unlock_irqrestore(&priv->driver_lock, flags);
 
 	priv->connect_status = LBS_DISCONNECTED;
 
-- 
1.7.11.7
