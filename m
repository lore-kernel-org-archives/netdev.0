From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2 for 3.19 6/7] rtlwifi: rtl8192ee: Fix problems with calculating free space in FIFO
Date: Tue, 20 Jan 2015 11:01:25 -0600
Message-ID: <1421773286-1039-7-git-send-email-Larry.Finger@lwfinger.net>
References: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:43530 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755462AbbATRBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 12:01:49 -0500
In-Reply-To: <1421773286-1039-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver utilizes a FIFO buffer for RX descriptors. There are four places
in the code where it calculates the number of free slots. Several of those
locations do the calculation incorrectly. To fix these and to prevent future
mistakes, a common inline routine is created.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org> [V3.18]
---
 drivers/net/wireless/rtlwifi/pci.h           |  7 +++++++
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c | 26 ++++++--------------------
 2 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.h b/drivers/net/wireless/rtlwifi/pci.h
index 5e83230..d4567d1 100644
--- a/drivers/net/wireless/rtlwifi/pci.h
+++ b/drivers/net/wireless/rtlwifi/pci.h
@@ -325,4 +325,11 @@ static inline void pci_write32_async(struct rtl_priv *rtlpriv,
 	writel(val, (u8 __iomem *) rtlpriv->io.pci_mem_start + addr);
 }
 
+static inline u16 calc_fifo_space(u16 rp, u16 wp)
+{
+	if (rp <= wp)
+		return RTL_PCI_MAX_RX_COUNT - 1 + rp - wp;
+	return rp - wp - 1;
+}
+
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
index cb3cbb6..80658bdf 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ee/trx.c
@@ -499,14 +499,7 @@ u16 rtl92ee_rx_desc_buff_remained_cnt(struct ieee80211_hw *hw, u8 queue_index)
 	if (!start_rx)
 		return 0;
 
-	if ((last_read_point > (RX_DESC_NUM_92E / 2)) &&
-	    (read_point <= (RX_DESC_NUM_92E / 2))) {
-		remind_cnt = RX_DESC_NUM_92E - write_point;
-	} else {
-		remind_cnt = (read_point >= write_point) ?
-			     (read_point - write_point) :
-			     (RX_DESC_NUM_92E - write_point + read_point);
-	}
+	remind_cnt = calc_fifo_space(read_point, write_point);
 
 	if (remind_cnt == 0)
 		return 0;
@@ -568,10 +561,8 @@ u16 rtl92ee_get_available_desc(struct ieee80211_hw *hw, u8 q_idx)
 	current_tx_read_point = (u16)((tmp_4byte >> 16) & 0x0fff);
 	current_tx_write_point = (u16)((tmp_4byte) & 0x0fff);
 
-	point_diff = ((current_tx_read_point > current_tx_write_point) ?
-		      (current_tx_read_point - current_tx_write_point) :
-		      (TX_DESC_NUM_92E - current_tx_write_point +
-		       current_tx_read_point));
+	point_diff = calc_fifo_space(current_tx_read_point,
+				     current_tx_write_point);
 
 	rtlpci->tx_ring[q_idx].avl_desc = point_diff;
 	return point_diff;
@@ -973,11 +964,8 @@ void rtl92ee_set_desc(struct ieee80211_hw *hw, u8 *pdesc, bool istx,
 
 				ring->cur_tx_wp = cur_tx_wp;
 				ring->cur_tx_rp = cur_tx_rp;
-				point_diff = ((cur_tx_rp > cur_tx_wp) ?
-					      (cur_tx_rp - cur_tx_wp) :
-					      (TX_DESC_NUM_92E - 1 -
-					       cur_tx_wp + cur_tx_rp));
-
+				point_diff = calc_fifo_space(cur_tx_rp,
+							     cur_tx_wp);
 				ring->avl_desc = point_diff;
 			}
 		}
@@ -1066,9 +1054,7 @@ bool rtl92ee_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue, u16 index)
 
 		ring->cur_tx_wp = cur_tx_wp;
 		ring->cur_tx_rp = cur_tx_rp;
-		point_diff = ((cur_tx_rp > cur_tx_wp) ?
-			      (cur_tx_rp - cur_tx_wp) :
-			      (TX_DESC_NUM_92E - cur_tx_wp + cur_tx_rp));
+		point_diff = calc_fifo_space(cur_tx_rp, cur_tx_wp);
 
 		ring->avl_desc = point_diff;
 	}
-- 
2.1.2
