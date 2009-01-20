From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/3] ixgbe: fix dca issue with relaxed ordering turned on
Date: Mon, 19 Jan 2009 16:11:05 -0800
Message-ID: <20090120001101.22544.15858.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:52474
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763334AbZATAL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:11:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The is an issue where setting Relaxed Ordering (RO) bit
(in a PCI-E write transaction) on 82598 causing the chipset
to drop DCA hints.  This patch forces RO not to be set for
descriptors as well as payload.  This will only be in effect
while DCA is enabled and no performance difference was
noticed in testing.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    3 +++
 drivers/net/ixgbe/ixgbe_type.h |    3 +++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index acef3c6..92d9b17 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -318,6 +318,9 @@ static void ixgbe_update_rx_dca(struct ixgbe_adapter *adapter,
 		rxctrl |= dca3_get_tag(&adapter->pdev->dev, cpu);
 		rxctrl |= IXGBE_DCA_RXCTRL_DESC_DCA_EN;
 		rxctrl |= IXGBE_DCA_RXCTRL_HEAD_DCA_EN;
+		rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_RRO_EN);
+		rxctrl &= ~(IXGBE_DCA_RXCTRL_DESC_WRO_EN |
+			    IXGBE_DCA_RXCTRL_DESC_HSRO_EN);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DCA_RXCTRL(q), rxctrl);
 		rx_ring->cpu = cpu;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 83a11ff..f011c57 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -404,6 +404,9 @@
 #define IXGBE_DCA_RXCTRL_DESC_DCA_EN (1 << 5) /* DCA Rx Desc enable */
 #define IXGBE_DCA_RXCTRL_HEAD_DCA_EN (1 << 6) /* DCA Rx Desc header enable */
 #define IXGBE_DCA_RXCTRL_DATA_DCA_EN (1 << 7) /* DCA Rx Desc payload enable */
+#define IXGBE_DCA_RXCTRL_DESC_RRO_EN (1 << 9) /* DCA Rx rd Desc Relax Order */
+#define IXGBE_DCA_RXCTRL_DESC_WRO_EN (1 << 13) /* DCA Rx wr Desc Relax Order */
+#define IXGBE_DCA_RXCTRL_DESC_HSRO_EN (1 << 15) /* DCA Rx Split Header RO */
 
 #define IXGBE_DCA_TXCTRL_CPUID_MASK 0x0000001F /* Tx CPUID Mask */
 #define IXGBE_DCA_TXCTRL_DESC_DCA_EN (1 << 5) /* DCA Tx Desc enable */

