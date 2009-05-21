From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/2] igb: do not re-register DCA requester on
	device reset
Date: Thu, 21 May 2009 16:06:56 -0700
Message-ID: <20090521230639.21776.59261.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:36720 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754090AbZEUXHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 19:07:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The current driver is re-registering the DCA requester after every reset.
Instead of doing this we should only be updating the on board DCA registers
and not unregistering/re-registering our requester.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ffd7315..2ec9809 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -996,6 +996,11 @@ void igb_down(struct igb_adapter *adapter)
 		igb_reset(adapter);
 	igb_clean_all_tx_rings(adapter);
 	igb_clean_all_rx_rings(adapter);
+#ifdef CONFIG_IGB_DCA
+
+	/* since we reset the hardware DCA settings were cleared */
+	igb_setup_dca(adapter);
+#endif
 }
 
 void igb_reinit_locked(struct igb_adapter *adapter)
@@ -1457,9 +1462,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IGB_FLAG_DCA_ENABLED;
 		dev_info(&pdev->dev, "DCA enabled\n");
-		/* Always use CB2 mode, difference is masked
-		 * in the CB driver. */
-		wr32(E1000_DCA_CTRL, E1000_DCA_CTRL_DCA_MODE_CB2);
 		igb_setup_dca(adapter);
 	}
 #endif
@@ -3771,11 +3773,15 @@ static void igb_update_tx_dca(struct igb_ring *tx_ring)
 
 static void igb_setup_dca(struct igb_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	int i;
 
 	if (!(adapter->flags & IGB_FLAG_DCA_ENABLED))
 		return;
 
+	/* Always use CB2 mode, difference is masked in the CB driver. */
+	wr32(E1000_DCA_CTRL, E1000_DCA_CTRL_DCA_MODE_CB2);
+
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		adapter->tx_ring[i].cpu = -1;
 		igb_update_tx_dca(&adapter->tx_ring[i]);

