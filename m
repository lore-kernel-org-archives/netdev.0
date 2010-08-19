From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 16/20] ixgbe: move all GPIE register config into
	a single function
Date: Thu, 19 Aug 2010 16:39:20 -0700
Message-ID: <20100819233917.10335.91882.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:60793
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751828Ab0HSXjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:39:40 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves all GPIE register configuration into a single function.
The advantage of this is that we can avoid a number of unnecessary
read/modify/write cycles on the register.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   72 +++++++++++++++++-----------------------
 1 files changed, 30 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d358bef..0b23522 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3362,38 +3362,15 @@ static inline void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 	                      (adapter->rx_ring[rxr]->count - 1));
 }
 
-static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
+static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int i, j = 0;
-	int num_rx_rings = adapter->num_rx_queues;
-	int err;
-	u32 txdctl, rxdctl;
-	u32 dmatxctl;
-	u32 gpie;
-	u32 ctrl_ext;
-
-	ixgbe_get_hw_control(adapter);
-
-	if ((adapter->flags & IXGBE_FLAG_MSIX_ENABLED) ||
-	    (adapter->flags & IXGBE_FLAG_MSI_ENABLED)) {
-		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
-			gpie = (IXGBE_GPIE_MSIX_MODE | IXGBE_GPIE_EIAME |
-			        IXGBE_GPIE_PBA_SUPPORT | IXGBE_GPIE_OCD);
-		} else {
-			/* MSI only */
-			gpie = 0;
-		}
-		if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
-			gpie &= ~IXGBE_GPIE_VTMODE_MASK;
-			gpie |= IXGBE_GPIE_VTMODE_64;
-		}
-		/* XXX: to interrupt immediately for EICS writes, enable this */
-		/* gpie |= IXGBE_GPIE_EIMEN; */
-		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
-	}
+	u32 gpie = 0;
 
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
+		gpie = IXGBE_GPIE_MSIX_MODE | IXGBE_GPIE_PBA_SUPPORT |
+		       IXGBE_GPIE_OCD;
+		gpie |= IXGBE_GPIE_EIAME;
 		/*
 		 * use EIAM to auto-mask when MSI-X interrupt is asserted
 		 * this saves a register write for every interrupt
@@ -3414,26 +3391,37 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_EIAM, IXGBE_EICS_RTX_QUEUE);
 	}
 
-	/* Enable Thermal over heat sensor interrupt */
-	if (adapter->flags2 & IXGBE_FLAG2_TEMP_SENSOR_CAPABLE) {
-		gpie = IXGBE_READ_REG(hw, IXGBE_GPIE);
-		gpie |= IXGBE_SDP0_GPIEN;
-		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
+	/* XXX: to interrupt immediately for EICS writes, enable this */
+	/* gpie |= IXGBE_GPIE_EIMEN; */
+
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
+		gpie &= ~IXGBE_GPIE_VTMODE_MASK;
+		gpie |= IXGBE_GPIE_VTMODE_64;
 	}
 
-	/* Enable fan failure interrupt if media type is copper */
-	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE) {
-		gpie = IXGBE_READ_REG(hw, IXGBE_GPIE);
+	/* Enable fan failure interrupt */
+	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE)
 		gpie |= IXGBE_SDP1_GPIEN;
-		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
-	}
 
-	if (hw->mac.type == ixgbe_mac_82599EB) {
-		gpie = IXGBE_READ_REG(hw, IXGBE_GPIE);
+	if (hw->mac.type == ixgbe_mac_82599EB)
 		gpie |= IXGBE_SDP1_GPIEN;
 		gpie |= IXGBE_SDP2_GPIEN;
-		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
-	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
+}
+
+static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i, j = 0;
+	int num_rx_rings = adapter->num_rx_queues;
+	int err;
+	u32 txdctl, rxdctl;
+	u32 dmatxctl;
+	u32 ctrl_ext;
+
+	ixgbe_get_hw_control(adapter);
+	ixgbe_setup_gpie(adapter);
 
 	if (hw->mac.type == ixgbe_mac_82599EB) {
 		/* DMATXCTL.EN must be set after all Tx queue config is done */

