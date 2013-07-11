From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 30/50] wireless: ath9k: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:53 +0800
Message-ID: <1373533573-12272-31-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:33160 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932278Ab3GKJKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:10:38 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/wireless/ath/ath9k/hif_usb.c      |   29 ++++++++++++++-----------
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c |    9 ++++----
 drivers/net/wireless/ath/ath9k/wmi.c          |   11 +++++-----
 3 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hif_usb.c b/drivers/net/wireless/ath/ath9k/hif_usb.c
index 9e582e1..9d5e15a 100644
--- a/drivers/net/wireless/ath/ath9k/hif_usb.c
+++ b/drivers/net/wireless/ath/ath9k/hif_usb.c
@@ -136,6 +136,7 @@ static void hif_usb_mgmt_cb(struct urb *urb)
 	struct cmd_buf *cmd = (struct cmd_buf *)urb->context;
 	struct hif_device_usb *hif_dev;
 	bool txok = true;
+	unsigned long flags;
 
 	if (!cmd || !cmd->skb || !cmd->hif_dev)
 		return;
@@ -155,14 +156,14 @@ static void hif_usb_mgmt_cb(struct urb *urb)
 		 * If the URBs are being flushed, no need to complete
 		 * this packet.
 		 */
-		spin_lock(&hif_dev->tx.tx_lock);
+		spin_lock_irqsave(&hif_dev->tx.tx_lock, flags);
 		if (hif_dev->tx.flags & HIF_USB_TX_FLUSH) {
-			spin_unlock(&hif_dev->tx.tx_lock);
+			spin_unlock_irqrestore(&hif_dev->tx.tx_lock, flags);
 			dev_kfree_skb_any(cmd->skb);
 			kfree(cmd);
 			return;
 		}
-		spin_unlock(&hif_dev->tx.tx_lock);
+		spin_unlock_irqrestore(&hif_dev->tx.tx_lock, flags);
 
 		break;
 	default:
@@ -253,6 +254,7 @@ static void hif_usb_tx_cb(struct urb *urb)
 	struct tx_buf *tx_buf = (struct tx_buf *) urb->context;
 	struct hif_device_usb *hif_dev;
 	bool txok = true;
+	unsigned long flags;
 
 	if (!tx_buf || !tx_buf->hif_dev)
 		return;
@@ -272,13 +274,13 @@ static void hif_usb_tx_cb(struct urb *urb)
 		 * If the URBs are being flushed, no need to add this
 		 * URB to the free list.
 		 */
-		spin_lock(&hif_dev->tx.tx_lock);
+		spin_lock_irqsave(&hif_dev->tx.tx_lock, flags);
 		if (hif_dev->tx.flags & HIF_USB_TX_FLUSH) {
-			spin_unlock(&hif_dev->tx.tx_lock);
+			spin_unlock_irqrestore(&hif_dev->tx.tx_lock, flags);
 			ath9k_skb_queue_purge(hif_dev, &tx_buf->skb_queue);
 			return;
 		}
-		spin_unlock(&hif_dev->tx.tx_lock);
+		spin_unlock_irqrestore(&hif_dev->tx.tx_lock, flags);
 
 		break;
 	default:
@@ -293,13 +295,13 @@ static void hif_usb_tx_cb(struct urb *urb)
 	__skb_queue_head_init(&tx_buf->skb_queue);
 
 	/* Add this TX buffer to the free list */
-	spin_lock(&hif_dev->tx.tx_lock);
+	spin_lock_irqsave(&hif_dev->tx.tx_lock, flags);
 	list_move_tail(&tx_buf->list, &hif_dev->tx.tx_buf);
 	hif_dev->tx.tx_buf_cnt++;
 	if (!(hif_dev->tx.flags & HIF_USB_TX_STOP))
 		__hif_usb_tx(hif_dev); /* Check for pending SKBs */
 	TX_STAT_INC(buf_completed);
-	spin_unlock(&hif_dev->tx.tx_lock);
+	spin_unlock_irqrestore(&hif_dev->tx.tx_lock, flags);
 }
 
 /* TX lock has to be taken */
@@ -530,8 +532,9 @@ static void ath9k_hif_usb_rx_stream(struct hif_device_usb *hif_dev,
 	int rx_remain_len, rx_pkt_len;
 	u16 pool_index = 0;
 	u8 *ptr;
+	unsigned long flags;
 
-	spin_lock(&hif_dev->rx_lock);
+	spin_lock_irqsave(&hif_dev->rx_lock, flags);
 
 	rx_remain_len = hif_dev->rx_remain_len;
 	rx_pkt_len = hif_dev->rx_transfer_len;
@@ -559,7 +562,7 @@ static void ath9k_hif_usb_rx_stream(struct hif_device_usb *hif_dev,
 		}
 	}
 
-	spin_unlock(&hif_dev->rx_lock);
+	spin_unlock_irqrestore(&hif_dev->rx_lock, flags);
 
 	while (index < len) {
 		u16 pkt_len;
@@ -585,7 +588,7 @@ static void ath9k_hif_usb_rx_stream(struct hif_device_usb *hif_dev,
 		index = index + 4 + pkt_len + pad_len;
 
 		if (index > MAX_RX_BUF_SIZE) {
-			spin_lock(&hif_dev->rx_lock);
+			spin_lock_irqsave(&hif_dev->rx_lock, flags);
 			hif_dev->rx_remain_len = index - MAX_RX_BUF_SIZE;
 			hif_dev->rx_transfer_len =
 				MAX_RX_BUF_SIZE - chk_idx - 4;
@@ -595,7 +598,7 @@ static void ath9k_hif_usb_rx_stream(struct hif_device_usb *hif_dev,
 			if (!nskb) {
 				dev_err(&hif_dev->udev->dev,
 					"ath9k_htc: RX memory allocation error\n");
-				spin_unlock(&hif_dev->rx_lock);
+				spin_unlock_irqrestore(&hif_dev->rx_lock, flags);
 				goto err;
 			}
 			skb_reserve(nskb, 32);
@@ -606,7 +609,7 @@ static void ath9k_hif_usb_rx_stream(struct hif_device_usb *hif_dev,
 
 			/* Record the buffer pointer */
 			hif_dev->remain_skb = nskb;
-			spin_unlock(&hif_dev->rx_lock);
+			spin_unlock_irqrestore(&hif_dev->rx_lock, flags);
 		} else {
 			nskb = __dev_alloc_skb(pkt_len + 32, GFP_ATOMIC);
 			if (!nskb) {
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index e602c95..a6f34f8 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -1156,25 +1156,26 @@ void ath9k_htc_rxep(void *drv_priv, struct sk_buff *skb,
 	struct ath_hw *ah = priv->ah;
 	struct ath_common *common = ath9k_hw_common(ah);
 	struct ath9k_htc_rxbuf *rxbuf = NULL, *tmp_buf = NULL;
+	unsigned long flags;
 
-	spin_lock(&priv->rx.rxbuflock);
+	spin_lock_irqsave(&priv->rx.rxbuflock, flags);
 	list_for_each_entry(tmp_buf, &priv->rx.rxbuf, list) {
 		if (!tmp_buf->in_process) {
 			rxbuf = tmp_buf;
 			break;
 		}
 	}
-	spin_unlock(&priv->rx.rxbuflock);
+	spin_unlock_irqrestore(&priv->rx.rxbuflock, flags);
 
 	if (rxbuf == NULL) {
 		ath_dbg(common, ANY, "No free RX buffer\n");
 		goto err;
 	}
 
-	spin_lock(&priv->rx.rxbuflock);
+	spin_lock_irqsave(&priv->rx.rxbuflock, flags);
 	rxbuf->skb = skb;
 	rxbuf->in_process = true;
-	spin_unlock(&priv->rx.rxbuflock);
+	spin_unlock_irqrestore(&priv->rx.rxbuflock, flags);
 
 	tasklet_schedule(&priv->rx_tasklet);
 	return;
diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireless/ath/ath9k/wmi.c
index 65c8894..101b771 100644
--- a/drivers/net/wireless/ath/ath9k/wmi.c
+++ b/drivers/net/wireless/ath/ath9k/wmi.c
@@ -207,6 +207,7 @@ static void ath9k_wmi_ctrl_rx(void *priv, struct sk_buff *skb,
 	struct wmi *wmi = (struct wmi *) priv;
 	struct wmi_cmd_hdr *hdr;
 	u16 cmd_id;
+	unsigned long flags;
 
 	if (unlikely(wmi->stopped))
 		goto free_skb;
@@ -215,20 +216,20 @@ static void ath9k_wmi_ctrl_rx(void *priv, struct sk_buff *skb,
 	cmd_id = be16_to_cpu(hdr->command_id);
 
 	if (cmd_id & 0x1000) {
-		spin_lock(&wmi->wmi_lock);
+		spin_lock_irqsave(&wmi->wmi_lock, flags);
 		__skb_queue_tail(&wmi->wmi_event_queue, skb);
-		spin_unlock(&wmi->wmi_lock);
+		spin_unlock_irqrestore(&wmi->wmi_lock, flags);
 		tasklet_schedule(&wmi->wmi_event_tasklet);
 		return;
 	}
 
 	/* Check if there has been a timeout. */
-	spin_lock(&wmi->wmi_lock);
+	spin_lock_irqsave(&wmi->wmi_lock, flags);
 	if (cmd_id != wmi->last_cmd_id) {
-		spin_unlock(&wmi->wmi_lock);
+		spin_unlock_irqrestore(&wmi->wmi_lock, flags);
 		goto free_skb;
 	}
-	spin_unlock(&wmi->wmi_lock);
+	spin_unlock_irqrestore(&wmi->wmi_lock, flags);
 
 	/* WMI command response */
 	ath9k_wmi_rsp_callback(wmi, skb);
-- 
1.7.9.5
