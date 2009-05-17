From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 06/11] ixgbe: Enable FCoE redirection table
	feature in 82599
Date: Sun, 17 May 2009 15:34:14 -0700
Message-ID: <20090517223413.14124.35244.stgit@localhost.localdomain>
References: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:43664
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755239AbZEQWec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 18:34:32 -0400
In-Reply-To: <20090517223213.14124.61405.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Enable using FCoE redirection table feature in 82599. The FCoE
redirection table has maximum of eight entries, corresponding
to maximum of eight receive queues to be used for distributing
incoming FCoE packets. This patch sets up the FCoE redirection
table when multiple receive queues are available for FCoE.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |   28 ++++++++++++++++++++++++----
 1 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index a11c620..d5939de 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -482,8 +482,10 @@ int ixgbe_fso(struct ixgbe_adapter *adapter,
  */
 void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 {
+	int i, fcoe_q, fcoe_i;
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
+	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_FCOE];
 
 	/* create the pool for ddp if not created yet */
 	if (!fcoe->pool) {
@@ -497,12 +499,30 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 
 		spin_lock_init(&fcoe->lock);
 	}
-	/* L2 filter for FCoE: default to queue 0 */
+
+	/* Enable L2 eth type filter for FCoE */
 	IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_FCOE),
 			(ETH_P_FCOE | IXGBE_ETQF_FCOE | IXGBE_ETQF_FILTER_EN));
-	IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, 0);
-	IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE),
-			IXGBE_ETQS_QUEUE_EN);
+	if (adapter->ring_feature[RING_F_FCOE].indices) {
+		/* Use multiple rx queues for FCoE by redirection table */
+		for (i = 0; i < IXGBE_FCRETA_SIZE; i++) {
+			fcoe_i = f->mask + i % f->indices;
+			fcoe_i &= IXGBE_FCRETA_ENTRY_MASK;
+			fcoe_q = adapter->rx_ring[fcoe_i].reg_idx;
+			IXGBE_WRITE_REG(hw, IXGBE_FCRETA(i), fcoe_q);
+		}
+		IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, IXGBE_FCRECTL_ENA);
+		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE), 0);
+	} else  {
+		/* Use single rx queue for FCoE */
+		fcoe_i = f->mask;
+		fcoe_q = adapter->rx_ring[fcoe_i].reg_idx;
+		IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, 0);
+		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE),
+				IXGBE_ETQS_QUEUE_EN |
+				(fcoe_q << IXGBE_ETQS_RX_QUEUE_SHIFT));
+	}
+
 	IXGBE_WRITE_REG(hw, IXGBE_FCRXCTRL,
 			IXGBE_FCRXCTRL_FCOELLI |
 			IXGBE_FCRXCTRL_FCCRCBO |

