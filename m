From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: Fix DCB traffic class mapping for 82599
Date: Thu, 16 Apr 2009 18:00:20 -0700
Message-ID: <20090417010019.19018.62374.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	stable@kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:41081
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753009AbZDQBAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 21:00:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The traffic classes in hardware are not symmetrical for Rx and Tx.  Rx
is every 16 descriptor queues, Tx is not.  It runs 32-32-16-16-8-8-8 when
running with 8 traffic classes, and runs 64-32-16 when running with 4
traffic classes.  This patch fixes the mapping.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Cc: stable@kernel.org
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   52 +++++++++++++++++++++++++++++++++++++---
 1 files changed, 48 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 49a9037..0188425 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2841,11 +2841,55 @@ static inline bool ixgbe_cache_ring_dcb(struct ixgbe_adapter *adapter)
 			}
 			ret = true;
 		} else if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-			for (i = 0; i < dcb_i; i++) {
-				adapter->rx_ring[i].reg_idx = i << 4;
-				adapter->tx_ring[i].reg_idx = i << 4;
+			if (dcb_i == 8) {
+				/*
+				 * Tx TC0 starts at: descriptor queue 0
+				 * Tx TC1 starts at: descriptor queue 32
+				 * Tx TC2 starts at: descriptor queue 64
+				 * Tx TC3 starts at: descriptor queue 80
+				 * Tx TC4 starts at: descriptor queue 96
+				 * Tx TC5 starts at: descriptor queue 104
+				 * Tx TC6 starts at: descriptor queue 112
+				 * Tx TC7 starts at: descriptor queue 120
+				 *
+				 * Rx TC0-TC7 are offset by 16 queues each
+				 */
+				for (i = 0; i < 3; i++) {
+					adapter->tx_ring[i].reg_idx = i << 5;
+					adapter->rx_ring[i].reg_idx = i << 4;
+				}
+				for ( ; i < 5; i++) {
+					adapter->tx_ring[i].reg_idx =
+					                         ((i + 2) << 4);
+					adapter->rx_ring[i].reg_idx = i << 4;
+				}
+				for ( ; i < dcb_i; i++) {
+					adapter->tx_ring[i].reg_idx =
+					                         ((i + 8) << 3);
+					adapter->rx_ring[i].reg_idx = i << 4;
+				}
+
+				ret = true;
+			} else if (dcb_i == 4) {
+				/*
+				 * Tx TC0 starts at: descriptor queue 0
+				 * Tx TC1 starts at: descriptor queue 64
+				 * Tx TC2 starts at: descriptor queue 96
+				 * Tx TC3 starts at: descriptor queue 112
+				 *
+				 * Rx TC0-TC3 are offset by 32 queues each
+				 */
+				adapter->tx_ring[0].reg_idx = 0;
+				adapter->tx_ring[1].reg_idx = 64;
+				adapter->tx_ring[2].reg_idx = 96;
+				adapter->tx_ring[3].reg_idx = 112;
+				for (i = 0 ; i < dcb_i; i++)
+					adapter->rx_ring[i].reg_idx = i << 5;
+
+				ret = true;
+			} else {
+				ret = false;
 			}
-			ret = true;
 		} else {
 			ret = false;
 		}

