From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH for 3.19] rtlwifi: Fix error when accessing unmapped memory in skb
Date: Mon, 22 Dec 2014 11:37:06 -0600
Message-ID: <1419269826-12552-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Eric Biggers <ebiggers3@gmail.com>,
	Stable <stable@vger.kernel.org>
To: kvalo@codeaurora.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Under heavy memory pressure, it is possible for the allocation of a
new skb to fail. When this happens, the kernel gets a memory access
violation. Previous versions of the drivers would drop the read request;
however, this logic was missed in the 3.18 update. This patch restores
the previous behavior.

Reported-by: Eric Biggers <ebiggers3@gmail.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Eric Biggers <ebiggers3@gmail.com>
Cc: Stable <stable@vger.kernel.org> [3.18]
---
 drivers/net/wireless/rtlwifi/pci.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 846a2e6..55334ca 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -912,13 +912,15 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 		}
 end:
 		if (rtlpriv->use_new_trx_flow) {
-			_rtl_pci_init_one_rxdesc(hw, (u8 *)buffer_desc,
-						 rxring_idx,
-					       rtlpci->rx_ring[rxring_idx].idx);
+			if (!_rtl_pci_init_one_rxdesc(hw, (u8 *)buffer_desc,
+					     rxring_idx,
+					     rtlpci->rx_ring[rxring_idx].idx))
+				return;
 		} else {
-			_rtl_pci_init_one_rxdesc(hw, (u8 *)pdesc, rxring_idx,
-						 rtlpci->rx_ring[rxring_idx].idx);
-
+			if (!_rtl_pci_init_one_rxdesc(hw, (u8 *)pdesc,
+					     rxring_idx,
+					     rtlpci->rx_ring[rxring_idx].idx))
+				return;
 			if (rtlpci->rx_ring[rxring_idx].idx ==
 			    rtlpci->rxringcount - 1)
 				rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc,
-- 
2.1.2
