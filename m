From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: [RFC PATCH] can: m_can: Support higher speed CAN-FD bitrates
Date: Fri, 18 Aug 2017 14:39:47 -0500
Message-ID: <20170818193947.27862-1-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Franklin S Cooper Jr <fcooper@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <mario.huettel@gmx.net>,
        <socketcan@hartkopp.net>, <quentin.schulz@free-electrons.com>,
        <edumazet@google.com>, <linux-can@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During test transmitting using CAN-FD at high bitrates (4 Mbps) only
resulted in errors. Scoping the signals I noticed that only a single bit
was being transmitted and with a bit more investigation realized the actual
MCAN IP would go back to initialization mode automatically.

It appears this issue is due to the MCAN needing to use the Transmitter
Delay Compensation Mode as defined in the MCAN User's Guide. When this
mode is used the User's Guide indicates that the Transmitter Delay
Compensation Offset register should be set. The document mentions that this
register should be set to (1/dbitrate)/2*(Func Clk Freq).

Additional CAN-CIA's "Bit Time Requirements for CAN FD" document indicates
that this TDC mode is only needed for data bit rates above 2.5 Mbps.
Therefore, only enable this mode and only set TDCO when the data bit rate
is above 2.5 Mbps.

Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
---
I'm pretty surprised that this hasn't been implemented already since
the primary purpose of CAN-FD is to go beyond 1 Mbps and the MCAN IP
supports up to 10 Mbps.

So it will be nice to get comments from users of this driver to understand
if they have been able to use CAN-FD beyond 2.5 Mbps without this patch.
If they haven't what did they do to get around it if they needed higher
speeds.

Meanwhile I plan on testing this using a more "realistic" CAN bus to insure
everything still works at 5 Mbps which is the max speed of my CAN
transceiver.

 drivers/net/can/m_can/m_can.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index f4947a7..720e073 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -126,6 +126,12 @@ enum m_can_mram_cfg {
 #define DBTP_DSJW_SHIFT		0
 #define DBTP_DSJW_MASK		(0xf << DBTP_DSJW_SHIFT)
 
+/* Transmitter Delay Compensation Register (TDCR) */
+#define TDCR_TDCO_SHIFT		8
+#define TDCR_TDCO_MASK		(0x7F << TDCR_TDCO_SHIFT)
+#define TDCR_TDCF_SHIFT		0
+#define TDCR_TDCF_MASK		(0x7F << TDCR_TDCO_SHIFT)
+
 /* Test Register (TEST) */
 #define TEST_LBCK		BIT(4)
 
@@ -977,6 +983,8 @@ static int m_can_set_bittiming(struct net_device *dev)
 	const struct can_bittiming *dbt = &priv->can.data_bittiming;
 	u16 brp, sjw, tseg1, tseg2;
 	u32 reg_btp;
+	u32 enable_tdc = 0;
+	u32 tdco;
 
 	brp = bt->brp - 1;
 	sjw = bt->sjw - 1;
@@ -991,9 +999,23 @@ static int m_can_set_bittiming(struct net_device *dev)
 		sjw = dbt->sjw - 1;
 		tseg1 = dbt->prop_seg + dbt->phase_seg1 - 1;
 		tseg2 = dbt->phase_seg2 - 1;
+
+		/* TDC is only needed for bitrates beyond 2.5 MBit/s
+		 * Specified in the "Bit Time Requirements for CAN FD" document
+		 */
+		if (dbt->bitrate > 2500000) {
+			enable_tdc = DBTP_TDC;
+			/* Equation based on Bosch's M_CAN User Manual's
+			 * Transmitter Delay Compensation Section
+			 */
+			tdco = priv->can.clock.freq / (dbt->bitrate * 2);
+			m_can_write(priv, M_CAN_TDCR, tdco << TDCR_TDCO_SHIFT);
+		}
+
 		reg_btp = (brp << DBTP_DBRP_SHIFT) | (sjw << DBTP_DSJW_SHIFT) |
 			(tseg1 << DBTP_DTSEG1_SHIFT) |
-			(tseg2 << DBTP_DTSEG2_SHIFT);
+			(tseg2 << DBTP_DTSEG2_SHIFT) | enable_tdc;
+
 		m_can_write(priv, M_CAN_DBTP, reg_btp);
 	}
 
-- 
2.9.4.dirty
