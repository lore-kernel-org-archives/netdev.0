From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH] net: fec: ptp: fix convergence issue to support LinuxPTP stack
Date: Tue, 14 Oct 2014 13:39:47 +0800
Message-ID: <1413265187-5228-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<b20596@freescale.com>, <b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0135.outbound.protection.outlook.com ([157.56.110.135]:28965
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753725AbaJNGKM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2014 02:10:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IEEE 1588 module has one hw issue in capturing the ATVR register. According
to the user manual it is:
		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
		while(ENET0->ATCR & ENET_ATCR_CAPTURE_MASK);
		ts_counter_ns = ENET0->ATVR;

Incorrect behavior for ENET_ATCR[Capture and Restart Bits]. These bits will always
read a value zero. According to SPEC, when these bits are set to 1'b1, these should
hold value 1'b1 until the counter value is capture in the register clock domain.

Unfortunately there is a bug with the way the bit "ENET_ATCR_CAPTURE" clears.
So need something like:
		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
		wait();
		ts_counter_ns = ENET0->ATVR;

The wait-time to be at least 6 clock cycle of the slower clock between the register
clock and the 1588 clock. The 1588 ts_clk is 25Mhz, register clock is 66Mhz, so the
wait-time must be greater than 240ns (40ns * 6). The workaround is that adding 1us
delay before read ATVR.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |   47 +++++++++++++++++++++++++++++
 drivers/net/ethernet/freescale/fec_main.c |   43 +-------------------------
 drivers/net/ethernet/freescale/fec_ptp.c  |    5 +++
 3 files changed, 53 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 1d5e182..b4dccec 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -367,6 +367,53 @@ struct bufdesc_ex {
 #define FEC_VLAN_TAG_LEN       0x04
 #define FEC_ETHTYPE_LEN                0x02
 
+/* Controller is ENET-MAC */
+#define FEC_QUIRK_ENET_MAC		(1 << 0)
+/* Controller needs driver to swap frame */
+#define FEC_QUIRK_SWAP_FRAME		(1 << 1)
+/* Controller uses gasket */
+#define FEC_QUIRK_USE_GASKET		(1 << 2)
+/* Controller has GBIT support */
+#define FEC_QUIRK_HAS_GBIT		(1 << 3)
+/* Controller has extend desc buffer */
+#define FEC_QUIRK_HAS_BUFDESC_EX	(1 << 4)
+/* Controller has hardware checksum support */
+#define FEC_QUIRK_HAS_CSUM		(1 << 5)
+/* Controller has hardware vlan support */
+#define FEC_QUIRK_HAS_VLAN		(1 << 6)
+/* ENET IP errata ERR006358
+ *
+ * If the ready bit in the transmit buffer descriptor (TxBD[R]) is previously
+ * detected as not set during a prior frame transmission, then the
+ * ENET_TDAR[TDAR] bit is cleared at a later time, even if additional TxBDs
+ * were added to the ring and the ENET_TDAR[TDAR] bit is set. This results in
+ * frames not being transmitted until there is a 0-to-1 transition on
+ * ENET_TDAR[TDAR].
+ */
+#define FEC_QUIRK_ERR006358            (1 << 7)
+/* ENET IP hw AVB
+ *
+ * i.MX6SX ENET IP add Audio Video Bridging (AVB) feature support.
+ * - Two class indicators on receive with configurable priority
+ * - Two class indicators and line speed timer on transmit allowing
+ *   implementation class credit based shapers externally
+ * - Additional DMA registers provisioned to allow managing up to 3
+ *   independent rings
+ */
+#define FEC_QUIRK_HAS_AVB		(1 << 8)
+/* There is a TDAR race condition for mutliQ when the software sets TDAR
+ * and the UDMA clears TDAR simultaneously or in a small window (2-4 cycles).
+ * This will cause the udma_tx and udma_tx_arbiter state machines to hang.
+ * The issue exist at i.MX6SX enet IP.
+ */
+#define FEC_QUIRK_ERR007885		(1 << 9)
+/* ENET Block Guide/ Chapter for the iMX6SLX (PELE) address one issue:
+ * Incorrect behavior for ENET_ATCR[Capture and Restart Bits]. These bits will
+ * always read a value zero. When these bits are set to 1'b1, these should hold
+ * value 1'b1 until the counter value is capture in the register clock domain.
+ */
+#define FEC_QUIRK_BUG_CAPTURE		(1 << 10)
+
 struct fec_enet_priv_tx_q {
 	int index;
 	unsigned char *tx_bounce[TX_RING_SIZE];
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 7a8209e..26d0525 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -78,47 +78,6 @@ static void fec_enet_itr_coal_init(struct net_device *ndev);
 #define FEC_ENET_RAFL_V	0x8
 #define FEC_ENET_OPD_V	0xFFF0
 
-/* Controller is ENET-MAC */
-#define FEC_QUIRK_ENET_MAC		(1 << 0)
-/* Controller needs driver to swap frame */
-#define FEC_QUIRK_SWAP_FRAME		(1 << 1)
-/* Controller uses gasket */
-#define FEC_QUIRK_USE_GASKET		(1 << 2)
-/* Controller has GBIT support */
-#define FEC_QUIRK_HAS_GBIT		(1 << 3)
-/* Controller has extend desc buffer */
-#define FEC_QUIRK_HAS_BUFDESC_EX	(1 << 4)
-/* Controller has hardware checksum support */
-#define FEC_QUIRK_HAS_CSUM		(1 << 5)
-/* Controller has hardware vlan support */
-#define FEC_QUIRK_HAS_VLAN		(1 << 6)
-/* ENET IP errata ERR006358
- *
- * If the ready bit in the transmit buffer descriptor (TxBD[R]) is previously
- * detected as not set during a prior frame transmission, then the
- * ENET_TDAR[TDAR] bit is cleared at a later time, even if additional TxBDs
- * were added to the ring and the ENET_TDAR[TDAR] bit is set. This results in
- * frames not being transmitted until there is a 0-to-1 transition on
- * ENET_TDAR[TDAR].
- */
-#define FEC_QUIRK_ERR006358            (1 << 7)
-/* ENET IP hw AVB
- *
- * i.MX6SX ENET IP add Audio Video Bridging (AVB) feature support.
- * - Two class indicators on receive with configurable priority
- * - Two class indicators and line speed timer on transmit allowing
- *   implementation class credit based shapers externally
- * - Additional DMA registers provisioned to allow managing up to 3
- *   independent rings
- */
-#define FEC_QUIRK_HAS_AVB		(1 << 8)
-/* There is a TDAR race condition for mutliQ when the software sets TDAR
- * and the UDMA clears TDAR simultaneously or in a small window (2-4 cycles).
- * This will cause the udma_tx and udma_tx_arbiter state machines to hang.
- * The issue exist at i.MX6SX enet IP.
- */
-#define FEC_QUIRK_ERR007885		(1 << 9)
-
 static struct platform_device_id fec_devtype[] = {
 	{
 		/* keep it for coldfire */
@@ -146,7 +105,7 @@ static struct platform_device_id fec_devtype[] = {
 		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_HAS_GBIT |
 				FEC_QUIRK_HAS_BUFDESC_EX | FEC_QUIRK_HAS_CSUM |
 				FEC_QUIRK_HAS_VLAN | FEC_QUIRK_HAS_AVB |
-				FEC_QUIRK_ERR007885,
+				FEC_QUIRK_ERR007885 | FEC_QUIRK_BUG_CAPTURE,
 	}, {
 		/* sentinel */
 	}
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index cca3617..380bb10 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -82,12 +82,17 @@ static cycle_t fec_ptp_read(const struct cyclecounter *cc)
 {
 	struct fec_enet_private *fep =
 		container_of(cc, struct fec_enet_private, cc);
+	const struct platform_device_id *id_entry =
+		platform_get_device_id(fep->pdev);
 	u32 tempval;
 
 	tempval = readl(fep->hwp + FEC_ATIME_CTRL);
 	tempval |= FEC_T_CTRL_CAPTURE;
 	writel(tempval, fep->hwp + FEC_ATIME_CTRL);
 
+	if (id_entry->driver_data & FEC_QUIRK_BUG_CAPTURE)
+		udelay(1);
+
 	return readl(fep->hwp + FEC_ATIME);
 }
 
-- 
1.7.8
