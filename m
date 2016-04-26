From: Florian Vallee <fvallee@eukrea.fr>
Subject: [PATCH] can: m_can: fix bitrate setup on latest silicon
Date: Tue, 26 Apr 2016 15:46:19 +0200
Message-ID: <1461678379-28257-1-git-send-email-fvallee@eukrea.fr>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebenard@eukrea.com,
	Florian Vallee <fvallee@eukrea.fr>
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to the m_can user manual changelog the BTP register layout was
updated with core revision 3.1.0

This change is not backward-compatible and using the current driver along
with a recent IP results in an incorrect bitrate on the wire.

Tested with a SAMA5D2 SoC (CREL = 0x31040730)

Signed-off-by: Florian Vallee <fvallee@eukrea.fr>
---
 drivers/net/can/m_can/m_can.c | 38 +++++++++++++++++++++++++++++++++++---
 1 file changed, 35 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index ef65517..d12b8f2 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -105,6 +105,10 @@ enum m_can_mram_cfg {
 	MRAM_CFG_NUM,
 };
 
+/* Core Release Register (CREL) */
+#define CRR_REL_MASK		0xfff
+#define CRR_REL_SHIFT		20
+
 /* Fast Bit Timing & Prescaler Register (FBTP) */
 #define FBTR_FBRP_MASK		0x1f
 #define FBTR_FBRP_SHIFT		16
@@ -136,7 +140,7 @@ enum m_can_mram_cfg {
 #define CCCR_INIT		BIT(0)
 #define CCCR_CANFD		0x10
 
-/* Bit Timing & Prescaler Register (BTP) */
+/* Bit Timing & Prescaler Register (BTP) (M_CAN IP < 3.1.0) */
 #define BTR_BRP_MASK		0x3ff
 #define BTR_BRP_SHIFT		16
 #define BTR_TSEG1_SHIFT		8
@@ -146,6 +150,16 @@ enum m_can_mram_cfg {
 #define BTR_SJW_SHIFT		0
 #define BTR_SJW_MASK		0xf
 
+/* Nominal Bit Timing & Prescaler Register (NBTP) (M_CAN IP >= 3.1.0) */
+#define NBTR_SJW_SHIFT		25
+#define NBTR_SJW_MASK		(0x7f << NBTR_SJW_SHIFT)
+#define NBTR_BRP_SHIFT		16
+#define NBTR_BRP_MASK		(0x3ff << NBTR_BRP_SHIFT)
+#define NBTR_TSEG1_SHIFT	8
+#define NBTR_TSEG1_MASK		(0xff << NBTR_TSEG1_SHIFT)
+#define NBTR_TSEG2_SHIFT	0
+#define NBTR_TSEG2_MASK		(0x7f << NBTR_TSEG2_SHIFT)
+
 /* Error Counter Register(ECR) */
 #define ECR_RP			BIT(15)
 #define ECR_REC_SHIFT		8
@@ -200,6 +214,9 @@ enum m_can_mram_cfg {
 			 IR_RF1L | IR_RF0L)
 #define IR_ERR_ALL	(IR_ERR_STATE | IR_ERR_BUS)
 
+/* Core Version */
+#define M_CAN_COREREL_3_1_0	0x310
+
 /* Interrupt Line Select (ILS) */
 #define ILS_ALL_INT0	0x0
 #define ILS_ALL_INT1	0xFFFFFFFF
@@ -357,6 +374,13 @@ static inline void m_can_disable_all_interrupts(const struct m_can_priv *priv)
 	m_can_write(priv, M_CAN_ILE, 0x0);
 }
 
+static inline int m_can_read_core_rev(const struct m_can_priv *priv)
+{
+	u32 reg = m_can_read(priv, M_CAN_CREL);
+
+	return ((reg >> CRR_REL_SHIFT) & CRR_REL_MASK);
+}
+
 static void m_can_read_fifo(struct net_device *dev, u32 rxfs)
 {
 	struct net_device_stats *stats = &dev->stats;
@@ -814,8 +838,16 @@ static int m_can_set_bittiming(struct net_device *dev)
 	sjw = bt->sjw - 1;
 	tseg1 = bt->prop_seg + bt->phase_seg1 - 1;
 	tseg2 = bt->phase_seg2 - 1;
-	reg_btp = (brp << BTR_BRP_SHIFT) | (sjw << BTR_SJW_SHIFT) |
-			(tseg1 << BTR_TSEG1_SHIFT) | (tseg2 << BTR_TSEG2_SHIFT);
+
+	if (m_can_read_core_rev(priv) < M_CAN_COREREL_3_1_0)
+		reg_btp = (brp << BTR_BRP_SHIFT) | (sjw << BTR_SJW_SHIFT) |
+				(tseg1 << BTR_TSEG1_SHIFT) |
+				(tseg2 << BTR_TSEG2_SHIFT);
+	else
+		reg_btp = (brp << NBTR_BRP_SHIFT) | (sjw << NBTR_SJW_SHIFT) |
+				(tseg1 << NBTR_TSEG1_SHIFT) |
+				(tseg2 << NBTR_TSEG2_SHIFT);
+
 	m_can_write(priv, M_CAN_BTP, reg_btp);
 
 	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
-- 
2.7.4
