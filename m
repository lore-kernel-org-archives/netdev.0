From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 3/3] ixgbe: fix traffic hangs on Tx with ioatdma loaded
Date: Fri, 06 Nov 2009 14:56:20 -0800
Message-ID: <20091106225620.28063.96209.stgit@localhost.localdomain>
References: <20091106225526.28063.83720.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:46098
	"EHLO QMTA13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760187AbZKFW4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 17:56:35 -0500
In-Reply-To: <20091106225526.28063.83720.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

When ioatdma was loaded we we were unable to transmit traffic.  We weren't
using the correct registers in ixgbe_update_tx_dca for 82599 systems.
Likewise in ixgbe_configure_tx() we weren't disabling the arbiter before
modifying MTQC.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   27 +++++++++++++++++++++++----
 1 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2d0f618..5bd9e6b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -44,6 +44,7 @@
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
+#include "ixgbe_dcb_82599.h"
 
 char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
@@ -462,19 +463,23 @@ static void ixgbe_update_tx_dca(struct ixgbe_adapter *adapter,
 	u32 txctrl;
 	int cpu = get_cpu();
 	int q = tx_ring - adapter->tx_ring;
+	struct ixgbe_hw *hw = &adapter->hw;
 
 	if (tx_ring->cpu != cpu) {
-		txctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q));
 		if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+			txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(q));
 			txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK;
 			txctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
+			txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
+			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(q), txctrl);
 		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+			txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(q));
 			txctrl &= ~IXGBE_DCA_TXCTRL_CPUID_MASK_82599;
 			txctrl |= (dca3_get_tag(&adapter->pdev->dev, cpu) <<
-			           IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599);
+			          IXGBE_DCA_TXCTRL_CPUID_SHIFT_82599);
+			txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
+			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(q), txctrl);
 		}
-		txctrl |= IXGBE_DCA_TXCTRL_DESC_DCA_EN;
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_TXCTRL(q), txctrl);
 		tx_ring->cpu = cpu;
 	}
 	put_cpu();
@@ -1963,11 +1968,25 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 			break;
 		}
 	}
+
 	if (hw->mac.type == ixgbe_mac_82599EB) {
+		u32 rttdcs;
+
+		/* disable the arbiter while setting MTQC */
+		rttdcs = IXGBE_READ_REG(hw, IXGBE_RTTDCS);
+		rttdcs |= IXGBE_RTTDCS_ARBDIS;
+		IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, rttdcs);
+
 		/* We enable 8 traffic classes, DCB only */
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
 			IXGBE_WRITE_REG(hw, IXGBE_MTQC, (IXGBE_MTQC_RT_ENA |
 			                IXGBE_MTQC_8TC_8TQ));
+		else
+			IXGBE_WRITE_REG(hw, IXGBE_MTQC, IXGBE_MTQC_64Q_1PB);
+
+		/* re-eable the arbiter */
+		rttdcs &= ~IXGBE_RTTDCS_ARBDIS;
+		IXGBE_WRITE_REG(hw, IXGBE_RTTDCS, rttdcs);
 	}
 }
 

