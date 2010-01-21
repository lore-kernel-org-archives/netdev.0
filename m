From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 02/10] tg3: Improve internal resource
 allocations
Date: Wed, 20 Jan 2010 18:58:03 -0800
Message-ID: <1264042691-28284-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1734 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246Ab0AUC61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jan 2010 21:58:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5717 and the 57765 have more resources at their disposal internally.
This patch tunes the driver to get better performance.  The adjustments
made here only apply to the 57765 and 5717 asic revs.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   25 +++++++++++++++++++++----
 drivers/net/tg3.h |    4 ++++
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index b80e7ee..adb579f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8152,7 +8152,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	/* Prevent chip from dropping frames when flow control
 	 * is enabled.
 	 */
-	tw32_f(MAC_LOW_WMARK_MAX_RX_FRAME, 2);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765)
+		val = 1;
+	else
+		val = 2;
+	tw32_f(MAC_LOW_WMARK_MAX_RX_FRAME, val);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 &&
 	    (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)) {
@@ -14091,9 +14095,22 @@ static void __devinit tg3_init_link_config(struct tg3 *tp)
 
 static void __devinit tg3_init_bufmgr_config(struct tg3 *tp)
 {
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57765) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) {
+		tp->bufmgr_config.mbuf_read_dma_low_water =
+			DEFAULT_MB_RDMA_LOW_WATER_5705;
+		tp->bufmgr_config.mbuf_mac_rx_low_water =
+			DEFAULT_MB_MACRX_LOW_WATER_57765;
+		tp->bufmgr_config.mbuf_high_water =
+			DEFAULT_MB_HIGH_WATER_57765;
+
+		tp->bufmgr_config.mbuf_read_dma_low_water_jumbo =
+			DEFAULT_MB_RDMA_LOW_WATER_5705;
+		tp->bufmgr_config.mbuf_mac_rx_low_water_jumbo =
+			DEFAULT_MB_MACRX_LOW_WATER_JUMBO_57765;
+		tp->bufmgr_config.mbuf_high_water_jumbo =
+			DEFAULT_MB_HIGH_WATER_JUMBO_57765;
+	} else if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
 		tp->bufmgr_config.mbuf_read_dma_low_water =
 			DEFAULT_MB_RDMA_LOW_WATER_5705;
 		tp->bufmgr_config.mbuf_mac_rx_low_water =
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 44a505d..91139fd 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1203,14 +1203,18 @@
 #define  DEFAULT_MB_MACRX_LOW_WATER	  0x00000020
 #define  DEFAULT_MB_MACRX_LOW_WATER_5705  0x00000010
 #define  DEFAULT_MB_MACRX_LOW_WATER_5906  0x00000004
+#define  DEFAULT_MB_MACRX_LOW_WATER_57765 0x0000002a
 #define  DEFAULT_MB_MACRX_LOW_WATER_JUMBO 0x00000098
 #define  DEFAULT_MB_MACRX_LOW_WATER_JUMBO_5780 0x0000004b
+#define  DEFAULT_MB_MACRX_LOW_WATER_JUMBO_57765 0x0000007e
 #define BUFMGR_MB_HIGH_WATER		0x00004418
 #define  DEFAULT_MB_HIGH_WATER		 0x00000060
 #define  DEFAULT_MB_HIGH_WATER_5705	 0x00000060
 #define  DEFAULT_MB_HIGH_WATER_5906	 0x00000010
+#define  DEFAULT_MB_HIGH_WATER_57765	 0x000000a0
 #define  DEFAULT_MB_HIGH_WATER_JUMBO	 0x0000017c
 #define  DEFAULT_MB_HIGH_WATER_JUMBO_5780 0x00000096
+#define  DEFAULT_MB_HIGH_WATER_JUMBO_57765 0x000000ea
 #define BUFMGR_RX_MB_ALLOC_REQ		0x0000441c
 #define  BUFMGR_MB_ALLOC_BIT		 0x10000000
 #define BUFMGR_RX_MB_ALLOC_RESP		0x00004420
-- 
1.6.4.4


