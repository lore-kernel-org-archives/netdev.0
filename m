From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 08/11] ixgbe: Set Priority Flow Control low water
	threshhold for DCB
Date: Sun, 17 May 2009 15:34:55 -0700
Message-ID: <20090517223455.14124.12286.stgit@localhost.localdomain>
References: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090517223213.14124.61405.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This sets the low water threshhold for priority flow control for 82598
and 82599 controllers in DCB mode.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |   48 +++++++++++++++++++++++++++++---------
 1 files changed, 37 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index af39275..530da90 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1589,6 +1589,13 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 	u32 mflcn_reg;
 	u32 fccfg_reg;
 	u32 reg;
+	u32 rx_pba_size;
+
+#ifdef CONFIG_DCB
+	if (hw->fc.requested_mode == ixgbe_fc_pfc)
+		goto out;
+
+#endif /* CONFIG_DCB */
 
 	mflcn_reg = IXGBE_READ_REG(hw, IXGBE_MFLCN);
 	mflcn_reg &= ~(IXGBE_MFLCN_RFCE | IXGBE_MFLCN_RPFCE);
@@ -1651,21 +1658,40 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 	IXGBE_WRITE_REG(hw, IXGBE_MFLCN, mflcn_reg);
 	IXGBE_WRITE_REG(hw, IXGBE_FCCFG, fccfg_reg);
 
-	/* Set up and enable Rx high/low water mark thresholds, enable XON. */
-	if (hw->fc.current_mode & ixgbe_fc_tx_pause) {
-		if (hw->fc.send_xon)
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(packetbuf_num),
-			                (hw->fc.low_water | IXGBE_FCRTL_XONE));
-		else
-			IXGBE_WRITE_REG(hw, IXGBE_FCRTL_82599(packetbuf_num),
-			                hw->fc.low_water);
+	reg = IXGBE_READ_REG(hw, IXGBE_MTQC);
+	/* Thresholds are different for link flow control when in DCB mode */
+	if (reg & IXGBE_MTQC_RT_ENA) {
+		rx_pba_size = IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(packetbuf_num));
 
-		IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(packetbuf_num),
-		                (hw->fc.high_water | IXGBE_FCRTH_FCEN));
+		/* Always disable XON for LFC when in DCB mode */
+		reg = (rx_pba_size >> 2) & 0xFFE0;
+		if (hw->fc.current_mode & ixgbe_fc_tx_pause)
+			reg |= IXGBE_FCRTH_FCEN;
+		IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(packetbuf_num), reg);
+	} else {
+		/*
+		 * Set up and enable Rx high/low water mark thresholds,
+		 * enable XON.
+		 */
+		if (hw->fc.current_mode & ixgbe_fc_tx_pause) {
+			if (hw->fc.send_xon) {
+				IXGBE_WRITE_REG(hw,
+				              IXGBE_FCRTL_82599(packetbuf_num),
+			                      (hw->fc.low_water |
+				              IXGBE_FCRTL_XONE));
+			} else {
+				IXGBE_WRITE_REG(hw,
+				              IXGBE_FCRTL_82599(packetbuf_num),
+				              hw->fc.low_water);
+			}
+
+			IXGBE_WRITE_REG(hw, IXGBE_FCRTH_82599(packetbuf_num),
+			               (hw->fc.high_water | IXGBE_FCRTH_FCEN));
+		}
 	}
 
 	/* Configure pause time (2 TCs per register) */
-	reg = IXGBE_READ_REG(hw, IXGBE_FCTTV(packetbuf_num));
+	reg = IXGBE_READ_REG(hw, IXGBE_FCTTV(packetbuf_num / 2));
 	if ((packetbuf_num & 1) == 0)
 		reg = (reg & 0xFFFF0000) | hw->fc.pause_time;
 	else

