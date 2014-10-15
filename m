From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v2 1/1] net: fec: ptp: fix convergence issue to support LinuxPTP stack
Date: Wed, 15 Oct 2014 17:30:12 +0800
Message-ID: <1413365412-22072-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<b20596@freescale.com>, <b38611@freescale.com>
To: <richardcochran@gmail.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0132.outbound.protection.outlook.com ([157.56.110.132]:57248
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751395AbaJOKAi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2014 06:00:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iMX6SX IEEE 1588 module has one hw issue in capturing the ATVR register.
The current SW flow is:
		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
		ts_counter_ns = ENET0->ATVR;
The ATVR value is not expected value that cause LinuxPTP stack cannot be convergent.

ENET Block Guide/ Chapter for the iMX6SX (PELE) address the issue:
After set ENET_ATCR[Capture], there need some time cycles before the counter
value is capture in the register clock domain. The wait-time-cycles is at least
6 clock cycles of the slower clock between the register clock and the 1588 clock.
So need something like:
		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
		wait();
		ts_counter_ns = ENET0->ATVR;

For iMX6SX, the 1588 ts_clk is fixed to 25Mhz, register clock is 66Mhz, so the
wait-time-cycles must be greater than 240ns (40ns * 6). The patch add 1us delay
before cpu read ATVR register.

Changes V2:
Modify the commit/comments log to describe the issue clearly.

Signed-off-by: Fugang Duan <B38611@freescale.com>
---
 drivers/net/ethernet/freescale/fec.h      |   50 +++++++++++++++++++++++++++++
 drivers/net/ethernet/freescale/fec_main.c |   43 +------------------------
 drivers/net/ethernet/freescale/fec_ptp.c  |    5 +++
 3 files changed, 56 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 1d5e182..906b739 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -367,6 +367,56 @@ struct bufdesc_ex {
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
+/* ENET Block Guide/ Chapter for the iMX6SX (PELE) address one issue:
+ * After set ENET_ATCR[Capture], there need some time cycles before the counter
+ * value is capture in the register clock domain.
+ * The wait-time-cycles is at least 6 clock cycles of the slower clock between
+ * the register clock and the 1588 clock. The 1588 ts_clk is fixed to 25Mhz,
+ * register clock is 66Mhz, so the wait-time-cycles must be greater than 240ns
+ * (40ns * 6).
+ */
+#define FEC_QUIRK_BUG_CAPTURE		(1 << 10)
+
 struct fec_enet_priv_tx_q {
 	int index;
 	unsigned char *tx_bounce[TX_RING_SIZE];
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 87975b5..965f1c8 100644
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
