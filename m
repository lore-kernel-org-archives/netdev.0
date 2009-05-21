From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/2] ixgbe: only register DCA requester once
Date: Thu, 21 May 2009 16:07:12 -0700
Message-ID: <20090521230712.21776.83286.stgit@localhost.localdomain>
References: <20090521230639.21776.59261.stgit@localhost.localdomain>
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
	by vger.kernel.org with ESMTP id S1754538AbZEUXH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 19:07:26 -0400
In-Reply-To: <20090521230639.21776.59261.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The current driver tries to re-register the DCA requester after reset and
this is not correct.  This change makes it so all we are doing is resetting
the DCA registers after reset and not re-adding the requester.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   24 ++++--------------------
 1 files changed, 4 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3d5f7f5..e52798c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -411,6 +411,9 @@ static void ixgbe_setup_dca(struct ixgbe_adapter *adapter)
 	if (!(adapter->flags & IXGBE_FLAG_DCA_ENABLED))
 		return;
 
+	/* always use CB2 mode, difference is masked in the CB driver */
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
+
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		adapter->tx_ring[i].cpu = -1;
 		ixgbe_update_tx_dca(adapter, &adapter->tx_ring[i]);
@@ -432,9 +435,6 @@ static int __ixgbe_notify_dca(struct device *dev, void *data)
 		/* if we're already enabled, don't do it again */
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			break;
-		/* Always use CB2 mode, difference is masked
-		 * in the CB driver. */
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_CTRL, 2);
 		if (dca_add_requester(dev) == 0) {
 			adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
 			ixgbe_setup_dca(adapter);
@@ -2767,13 +2767,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	netif_carrier_off(netdev);
 
-#ifdef CONFIG_IXGBE_DCA
-	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
-		adapter->flags &= ~IXGBE_FLAG_DCA_ENABLED;
-		dca_remove_requester(&adapter->pdev->dev);
-	}
-
-#endif
 	if (!pci_channel_offline(adapter->pdev))
 		ixgbe_reset(adapter);
 	ixgbe_clean_all_tx_rings(adapter);
@@ -2781,13 +2774,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 #ifdef CONFIG_IXGBE_DCA
 	/* since we reset the hardware DCA settings were cleared */
-	if (dca_add_requester(&adapter->pdev->dev) == 0) {
-		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
-		/* always use CB2 mode, difference is masked
-		 * in the CB driver */
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_CTRL, 2);
-		ixgbe_setup_dca(adapter);
-	}
+	ixgbe_setup_dca(adapter);
 #endif
 }
 
@@ -5354,9 +5341,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 #ifdef CONFIG_IXGBE_DCA
 	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IXGBE_FLAG_DCA_ENABLED;
-		/* always use CB2 mode, difference is masked
-		 * in the CB driver */
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_CTRL, 2);
 		ixgbe_setup_dca(adapter);
 	}
 #endif

