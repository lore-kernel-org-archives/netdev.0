From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/5] ixgbe: Fix disabling of relaxed ordering with Tx
	DCA
Date: Wed, 30 Sep 2009 15:07:16 -0700
Message-ID: <20090930220705.27479.62694.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:35753
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752462AbZI3WIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 18:08:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

82599 has a different register offset for the Tx DCA control registers.
We disable relaxed ordering of the descriptor writebacks for Tx head
writeback, but didn't disable it properly for 82599.  However, this
shouldn't be a visible issue, since ixgbe doesn't use Tx head writeback.
This patch just makes sure we're not doing blind writes to offsets we
don't expect.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c407bd9..fe52736 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1885,12 +1885,29 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_TDT(j), 0);
 		adapter->tx_ring[i].head = IXGBE_TDH(j);
 		adapter->tx_ring[i].tail = IXGBE_TDT(j);
-		/* Disable Tx Head Writeback RO bit, since this hoses
+		/*
+		 * Disable Tx Head Writeback RO bit, since this hoses
 		 * bookkeeping if things aren't delivered in order.
 		 */
-		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(j));
+		switch (hw->mac.type) {
+		case ixgbe_mac_82598EB:
+			txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(j));
+			break;
+		case ixgbe_mac_82599EB:
+		default:
+			txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(j));
+			break;
+		}
 		txctrl &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(j), txctrl);
+		switch (hw->mac.type) {
+		case ixgbe_mac_82598EB:
+			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(j), txctrl);
+			break;
+		case ixgbe_mac_82599EB:
+		default:
+			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(j), txctrl);
+			break;
+		}
 	}
 	if (hw->mac.type == ixgbe_mac_82599EB) {
 		/* We enable 8 traffic classes, DCB only */

