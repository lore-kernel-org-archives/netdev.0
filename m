From: <y@shlinux1.ap.freescale.net>
Subject: [Patch net-next 05/11] net:fec: Disable enet-avb MAC instead of reset MAC
Date: Thu, 4 Sep 2014 04:34:40 +0800
Message-ID: <4443.35892466388$1409778754@news.gmane.org>
References: <1409776486-1403-1-git-send-email-y>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: <b38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <lznuaa-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1409776486-1403-1-git-send-email-y>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>

For i.MX6SX enet use AXI bus, reset MAC will make system bus dead
if ENET-AXI bus has pending access (AHB bus should not have such issue).
So, disable enet with AVB MAC instead of reset MAC itself.

Signed-off-by: Fugang Duan <B38611-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Signed-off-by: Frank Li <Frank.Li-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
---
 drivers/net/ethernet/freescale/fec_main.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index f973a92..5dab6a6 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -948,9 +948,16 @@ fec_restart(struct net_device *ndev)
 	u32 ecntl = 0x2; /* ETHEREN */
 	int i;
 
-	/* Whack a reset.  We should wait for this. */
-	writel(1, fep->hwp + FEC_ECNTRL);
-	udelay(10);
+	/* Whack a reset.  We should wait for this.
+	 * For i.MX6SX SOC, enet use AXI bus, we use disable MAC
+	 * instead of reset MAC itself.
+	 */
+	if (id_entry && id_entry->driver_data & FEC_QUIRK_HAS_AVB) {
+		writel(0, fep->hwp + FEC_ECNTRL);
+	} else {
+		writel(1, fep->hwp + FEC_ECNTRL);
+		udelay(10);
+	}
 
 	/*
 	 * enet-mac reset will reset mac address registers too,
@@ -1122,9 +1129,16 @@ fec_stop(struct net_device *ndev)
 			netdev_err(ndev, "Graceful transmit stop did not complete!\n");
 	}
 
-	/* Whack a reset.  We should wait for this. */
-	writel(1, fep->hwp + FEC_ECNTRL);
-	udelay(10);
+	/* Whack a reset.  We should wait for this.
+	 * For i.MX6SX SOC, enet use AXI bus, we use disable MAC
+	 * instead of reset MAC itself.
+	 */
+	if (id_entry && id_entry->driver_data & FEC_QUIRK_HAS_AVB) {
+		writel(0, fep->hwp + FEC_ECNTRL);
+	} else {
+		writel(1, fep->hwp + FEC_ECNTRL);
+		udelay(10);
+	}
 	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
 	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
