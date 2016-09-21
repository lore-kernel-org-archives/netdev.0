From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] net: can: ifi: Configure transmitter delay
Date: Wed, 21 Sep 2016 10:43:55 +0200
Message-ID: <20160921084355.20972-2-mkl@pengutronix.de>
References: <20160921084355.20972-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Marek Vasut <marex@denx.de>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Mark Rutland <mark.rutland@arm.com>,
        Oliver Hartkopp <socketcan@hartkopp.net>,
        Wolfgang Grandegger <wg@grandegger.com>,
        linux-stable <stable@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160921084355.20972-1-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marek Vasut <marex@denx.de>

Configure the transmitter delay register at +0x1c to correctly handle
the CAN FD bitrate switch (BRS). This moves the SSP (secondary sample
point) to a proper offset, so that the TDC mechanism works and won't
generate error frames on the CAN link.

Signed-off-by: Marek Vasut <marex@denx.de>
Cc: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: Wolfgang Grandegger <wg@grandegger.com>
Cc: linux-stable <stable@vger.kernel.org>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/ifi_canfd/ifi_canfd.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/can/ifi_canfd/ifi_canfd.c b/drivers/net/can/ifi_canfd/ifi_canfd.c
index 2d1d22eec750..368bb0710d8f 100644
--- a/drivers/net/can/ifi_canfd/ifi_canfd.c
+++ b/drivers/net/can/ifi_canfd/ifi_canfd.c
@@ -81,6 +81,10 @@
 #define IFI_CANFD_TIME_SET_TIMEA_4_12_6_6	BIT(15)
 
 #define IFI_CANFD_TDELAY			0x1c
+#define IFI_CANFD_TDELAY_DEFAULT		0xb
+#define IFI_CANFD_TDELAY_MASK			0x3fff
+#define IFI_CANFD_TDELAY_ABS			BIT(14)
+#define IFI_CANFD_TDELAY_EN			BIT(15)
 
 #define IFI_CANFD_ERROR				0x20
 #define IFI_CANFD_ERROR_TX_OFFSET		0
@@ -641,7 +645,7 @@ static void ifi_canfd_set_bittiming(struct net_device *ndev)
 	struct ifi_canfd_priv *priv = netdev_priv(ndev);
 	const struct can_bittiming *bt = &priv->can.bittiming;
 	const struct can_bittiming *dbt = &priv->can.data_bittiming;
-	u16 brp, sjw, tseg1, tseg2;
+	u16 brp, sjw, tseg1, tseg2, tdc;
 
 	/* Configure bit timing */
 	brp = bt->brp - 2;
@@ -664,6 +668,11 @@ static void ifi_canfd_set_bittiming(struct net_device *ndev)
 	       (brp << IFI_CANFD_TIME_PRESCALE_OFF) |
 	       (sjw << IFI_CANFD_TIME_SJW_OFF_7_9_8_8),
 	       priv->base + IFI_CANFD_FTIME);
+
+	/* Configure transmitter delay */
+	tdc = (dbt->brp * (dbt->phase_seg1 + 1)) & IFI_CANFD_TDELAY_MASK;
+	writel(IFI_CANFD_TDELAY_EN | IFI_CANFD_TDELAY_ABS | tdc,
+	       priv->base + IFI_CANFD_TDELAY);
 }
 
 static void ifi_canfd_set_filter(struct net_device *ndev, const u32 id,
-- 
2.9.3

