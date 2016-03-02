From: Marek Vasut <marex@denx.de>
Subject: [PATCH 1/4] net: can: ifi: Fix clock generator configuration
Date: Wed,  2 Mar 2016 21:23:18 +0100
Message-ID: <1456950201-4812-2-git-send-email-marex@denx.de>
References: <1456950201-4812-1-git-send-email-marex@denx.de>
Cc: netdev@vger.kernel.org, Marek Vasut <marex@denx.de>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>
To: linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1456950201-4812-1-git-send-email-marex@denx.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The clock generation does not match reality when using the CAN IP
core outside of the FPGA design. This patch fixes the computation
of values which are programmed into the clock generator registers.

First, there are some off-by-one errors which manifest themselves
only when communicating with different controller, so those are
fixed.

Second, the bits in the clock generator registers have different
meaning depending on whether the core is in ISO CANFD mode or any
of the other modes (BOSCH CANFD or CAN2.0). Detect the ISO CANFD
mode and fix handling of this special case of clock configuration.

Finally, the CAN clock speed is in CANCLOCK register, not SYSCLOCK
register, so fix this as well.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/ifi_canfd/ifi_canfd.c | 43 ++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/can/ifi_canfd/ifi_canfd.c b/drivers/net/can/ifi_canfd/ifi_canfd.c
index 639868b..72f5205 100644
--- a/drivers/net/can/ifi_canfd/ifi_canfd.c
+++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
@@ -514,25 +514,25 @@ static irqreturn_t ifi_canfd_isr(int irq, void *dev_id)
 
 static const struct can_bittiming_const ifi_canfd_bittiming_const = {
 	.name		= KBUILD_MODNAME,
-	.tseg1_min	= 2,	/* Time segment 1 = prop_seg + phase_seg1 */
+	.tseg1_min	= 1,	/* Time segment 1 = prop_seg + phase_seg1 */
 	.tseg1_max	= 64,
-	.tseg2_min	= 1,	/* Time segment 2 = phase_seg2 */
-	.tseg2_max	= 16,
+	.tseg2_min	= 2,	/* Time segment 2 = phase_seg2 */
+	.tseg2_max	= 64,
 	.sjw_max	= 16,
-	.brp_min	= 1,
-	.brp_max	= 1024,
+	.brp_min	= 2,
+	.brp_max	= 256,
 	.brp_inc	= 1,
 };
 
 static const struct can_bittiming_const ifi_canfd_data_bittiming_const = {
 	.name		= KBUILD_MODNAME,
-	.tseg1_min	= 2,	/* Time segment 1 = prop_seg + phase_seg1 */
-	.tseg1_max	= 16,
-	.tseg2_min	= 1,	/* Time segment 2 = phase_seg2 */
-	.tseg2_max	= 8,
-	.sjw_max	= 4,
-	.brp_min	= 1,
-	.brp_max	= 32,
+	.tseg1_min	= 1,	/* Time segment 1 = prop_seg + phase_seg1 */
+	.tseg1_max	= 64,
+	.tseg2_min	= 2,	/* Time segment 2 = phase_seg2 */
+	.tseg2_max	= 64,
+	.sjw_max	= 16,
+	.brp_min	= 2,
+	.brp_max	= 256,
 	.brp_inc	= 1,
 };
 
@@ -545,32 +545,33 @@ static void ifi_canfd_set_bittiming(struct net_device *ndev)
 	u32 noniso_arg = 0;
 	u32 time_off;
 
-	if (priv->can.ctrlmode & CAN_CTRLMODE_FD_NON_ISO) {
+	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
+		time_off = IFI_CANFD_TIME_SJW_OFF_ISO;
+	} else {
 		noniso_arg = IFI_CANFD_TIME_SET_TIMEB_BOSCH |
 			     IFI_CANFD_TIME_SET_TIMEA_BOSCH |
 			     IFI_CANFD_TIME_SET_PRESC_BOSCH |
 			     IFI_CANFD_TIME_SET_SJW_BOSCH;
 		time_off = IFI_CANFD_TIME_SJW_OFF_BOSCH;
-	} else {
-		time_off = IFI_CANFD_TIME_SJW_OFF_ISO;
 	}
 
 	/* Configure bit timing */
-	brp = bt->brp - 1;
+	brp = bt->brp - 2;
 	sjw = bt->sjw - 1;
 	tseg1 = bt->prop_seg + bt->phase_seg1 - 1;
-	tseg2 = bt->phase_seg2 - 1;
+	tseg2 = bt->phase_seg2 - 2;
 	writel((tseg2 << IFI_CANFD_TIME_TIMEB_OFF) |
 	       (tseg1 << IFI_CANFD_TIME_TIMEA_OFF) |
 	       (brp << IFI_CANFD_TIME_PRESCALE_OFF) |
-	       (sjw << time_off),
+	       (sjw << time_off) |
+	       noniso_arg,
 	       priv->base + IFI_CANFD_TIME);
 
 	/* Configure data bit timing */
-	brp = dbt->brp - 1;
+	brp = dbt->brp - 2;
 	sjw = dbt->sjw - 1;
 	tseg1 = dbt->prop_seg + dbt->phase_seg1 - 1;
-	tseg2 = dbt->phase_seg2 - 1;
+	tseg2 = dbt->phase_seg2 - 2;
 	writel((tseg2 << IFI_CANFD_TIME_TIMEB_OFF) |
 	       (tseg1 << IFI_CANFD_TIME_TIMEA_OFF) |
 	       (brp << IFI_CANFD_TIME_PRESCALE_OFF) |
@@ -847,7 +848,7 @@ static int ifi_canfd_plat_probe(struct platform_device *pdev)
 
 	priv->can.state = CAN_STATE_STOPPED;
 
-	priv->can.clock.freq = readl(addr + IFI_CANFD_SYSCLOCK);
+	priv->can.clock.freq = readl(addr + IFI_CANFD_CANCLOCK);
 
 	priv->can.bittiming_const	= &ifi_canfd_bittiming_const;
 	priv->can.data_bittiming_const	= &ifi_canfd_data_bittiming_const;
-- 
2.7.0

