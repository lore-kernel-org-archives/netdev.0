From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 6/8] tg3: Eliminate tg3_write_sig_post_reset()
 prototype
Date: Wed, 31 Aug 2011 14:44:52 -0700
Message-ID: <1314827094-29714-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2586 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932165Ab1HaRzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 13:55:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves the implementation of tg3_write_sig_post_reset()
earlier to eliminate its prototype.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  458 +++++++++++++++++------------------
 1 files changed, 228 insertions(+), 230 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 333f370..272aa11 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -94,6 +94,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
 #define DRV_MODULE_RELDATE	"August 18, 2011"
 
+#define RESET_KIND_SHUTDOWN	0
+#define RESET_KIND_INIT		1
+#define RESET_KIND_SUSPEND	2
+
 #define TG3_DEF_RX_MODE		0
 #define TG3_DEF_TX_MODE		0
 #define TG3_DEF_MSG_ENABLE	  \
@@ -724,6 +728,103 @@ static void tg3_ape_unlock(struct tg3 *tp, int locknum)
 	tg3_ape_write32(tp, gnt + 4 * locknum, bit);
 }
 
+static void tg3_ape_send_event(struct tg3 *tp, u32 event)
+{
+	int i;
+	u32 apedata;
+
+	/* NCSI does not support APE events */
+	if (tg3_flag(tp, APE_HAS_NCSI))
+		return;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_SEG_SIG);
+	if (apedata != APE_SEG_SIG_MAGIC)
+		return;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_FW_STATUS);
+	if (!(apedata & APE_FW_STATUS_READY))
+		return;
+
+	/* Wait for up to 1 millisecond for APE to service previous event. */
+	for (i = 0; i < 10; i++) {
+		if (tg3_ape_lock(tp, TG3_APE_LOCK_MEM))
+			return;
+
+		apedata = tg3_ape_read32(tp, TG3_APE_EVENT_STATUS);
+
+		if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
+			tg3_ape_write32(tp, TG3_APE_EVENT_STATUS,
+					event | APE_EVENT_STATUS_EVENT_PENDING);
+
+		tg3_ape_unlock(tp, TG3_APE_LOCK_MEM);
+
+		if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
+			break;
+
+		udelay(100);
+	}
+
+	if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
+		tg3_ape_write32(tp, TG3_APE_EVENT, APE_EVENT_1);
+}
+
+static void tg3_ape_driver_state_change(struct tg3 *tp, int kind)
+{
+	u32 event;
+	u32 apedata;
+
+	if (!tg3_flag(tp, ENABLE_APE))
+		return;
+
+	switch (kind) {
+	case RESET_KIND_INIT:
+		tg3_ape_write32(tp, TG3_APE_HOST_SEG_SIG,
+				APE_HOST_SEG_SIG_MAGIC);
+		tg3_ape_write32(tp, TG3_APE_HOST_SEG_LEN,
+				APE_HOST_SEG_LEN_MAGIC);
+		apedata = tg3_ape_read32(tp, TG3_APE_HOST_INIT_COUNT);
+		tg3_ape_write32(tp, TG3_APE_HOST_INIT_COUNT, ++apedata);
+		tg3_ape_write32(tp, TG3_APE_HOST_DRIVER_ID,
+			APE_HOST_DRIVER_ID_MAGIC(TG3_MAJ_NUM, TG3_MIN_NUM));
+		tg3_ape_write32(tp, TG3_APE_HOST_BEHAVIOR,
+				APE_HOST_BEHAV_NO_PHYLOCK);
+		tg3_ape_write32(tp, TG3_APE_HOST_DRVR_STATE,
+				    TG3_APE_HOST_DRVR_STATE_START);
+
+		event = APE_EVENT_STATUS_STATE_START;
+		break;
+	case RESET_KIND_SHUTDOWN:
+		/* With the interface we are currently using,
+		 * APE does not track driver state.  Wiping
+		 * out the HOST SEGMENT SIGNATURE forces
+		 * the APE to assume OS absent status.
+		 */
+		tg3_ape_write32(tp, TG3_APE_HOST_SEG_SIG, 0x0);
+
+		if (device_may_wakeup(&tp->pdev->dev) &&
+		    tg3_flag(tp, WOL_ENABLE)) {
+			tg3_ape_write32(tp, TG3_APE_HOST_WOL_SPEED,
+					    TG3_APE_HOST_WOL_SPEED_AUTO);
+			apedata = TG3_APE_HOST_DRVR_STATE_WOL;
+		} else
+			apedata = TG3_APE_HOST_DRVR_STATE_UNLOAD;
+
+		tg3_ape_write32(tp, TG3_APE_HOST_DRVR_STATE, apedata);
+
+		event = APE_EVENT_STATUS_STATE_UNLOAD;
+		break;
+	case RESET_KIND_SUSPEND:
+		event = APE_EVENT_STATUS_STATE_SUSPEND;
+		break;
+	default:
+		return;
+	}
+
+	event |= APE_EVENT_STATUS_DRIVER_EVNT | APE_EVENT_STATUS_STATE_CHNGE;
+
+	tg3_ape_send_event(tp, event);
+}
+
 static void tg3_disable_ints(struct tg3 *tp)
 {
 	int i;
@@ -1412,6 +1513,133 @@ static void tg3_stop_fw(struct tg3 *tp)
 	}
 }
 
+/* tp->lock is held. */
+static void tg3_write_sig_pre_reset(struct tg3 *tp, int kind)
+{
+	tg3_write_mem(tp, NIC_SRAM_FIRMWARE_MBOX,
+		      NIC_SRAM_FIRMWARE_MBOX_MAGIC1);
+
+	if (tg3_flag(tp, ASF_NEW_HANDSHAKE)) {
+		switch (kind) {
+		case RESET_KIND_INIT:
+			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
+				      DRV_STATE_START);
+			break;
+
+		case RESET_KIND_SHUTDOWN:
+			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
+				      DRV_STATE_UNLOAD);
+			break;
+
+		case RESET_KIND_SUSPEND:
+			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
+				      DRV_STATE_SUSPEND);
+			break;
+
+		default:
+			break;
+		}
+	}
+
+	if (kind == RESET_KIND_INIT ||
+	    kind == RESET_KIND_SUSPEND)
+		tg3_ape_driver_state_change(tp, kind);
+}
+
+/* tp->lock is held. */
+static void tg3_write_sig_post_reset(struct tg3 *tp, int kind)
+{
+	if (tg3_flag(tp, ASF_NEW_HANDSHAKE)) {
+		switch (kind) {
+		case RESET_KIND_INIT:
+			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
+				      DRV_STATE_START_DONE);
+			break;
+
+		case RESET_KIND_SHUTDOWN:
+			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
+				      DRV_STATE_UNLOAD_DONE);
+			break;
+
+		default:
+			break;
+		}
+	}
+
+	if (kind == RESET_KIND_SHUTDOWN)
+		tg3_ape_driver_state_change(tp, kind);
+}
+
+/* tp->lock is held. */
+static void tg3_write_sig_legacy(struct tg3 *tp, int kind)
+{
+	if (tg3_flag(tp, ENABLE_ASF)) {
+		switch (kind) {
+		case RESET_KIND_INIT:
+			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
+				      DRV_STATE_START);
+			break;
+
+		case RESET_KIND_SHUTDOWN:
+			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
+				      DRV_STATE_UNLOAD);
+			break;
+
+		case RESET_KIND_SUSPEND:
+			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
+				      DRV_STATE_SUSPEND);
+			break;
+
+		default:
+			break;
+		}
+	}
+}
+
+static int tg3_poll_fw(struct tg3 *tp)
+{
+	int i;
+	u32 val;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		/* Wait up to 20ms for init done. */
+		for (i = 0; i < 200; i++) {
+			if (tr32(VCPU_STATUS) & VCPU_STATUS_INIT_DONE)
+				return 0;
+			udelay(100);
+		}
+		return -ENODEV;
+	}
+
+	/* Wait for firmware initialization to complete. */
+	for (i = 0; i < 100000; i++) {
+		tg3_read_mem(tp, NIC_SRAM_FIRMWARE_MBOX, &val);
+		if (val == ~NIC_SRAM_FIRMWARE_MBOX_MAGIC1)
+			break;
+		udelay(10);
+	}
+
+	/* Chip might not be fitted with firmware.  Some Sun onboard
+	 * parts are configured like that.  So don't signal the timeout
+	 * of the above loop as an error, but do report the lack of
+	 * running firmware once.
+	 */
+	if (i >= 100000 && !tg3_flag(tp, NO_FWARE_REPORTED)) {
+		tg3_flag_set(tp, NO_FWARE_REPORTED);
+
+		netdev_info(tp->dev, "No firmware running\n");
+	}
+
+	if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0) {
+		/* The 57765 A0 needs a little more
+		 * time to do some important work.
+		 */
+		mdelay(10);
+	}
+
+	return 0;
+}
+
 static void tg3_link_report(struct tg3 *tp)
 {
 	if (!netif_carrier_ok(tp->dev)) {
@@ -2503,12 +2731,6 @@ static int tg3_5700_link_polarity(struct tg3 *tp, u32 speed)
 }
 
 static int tg3_setup_phy(struct tg3 *, int);
-
-#define RESET_KIND_SHUTDOWN	0
-#define RESET_KIND_INIT		1
-#define RESET_KIND_SUSPEND	2
-
-static void tg3_write_sig_post_reset(struct tg3 *, int);
 static int tg3_halt_cpu(struct tg3 *, u32);
 
 static void tg3_power_down_phy(struct tg3 *tp, bool do_low_power)
@@ -7147,230 +7369,6 @@ static int tg3_abort_hw(struct tg3 *tp, int silent)
 	return err;
 }
 
-static void tg3_ape_send_event(struct tg3 *tp, u32 event)
-{
-	int i;
-	u32 apedata;
-
-	/* NCSI does not support APE events */
-	if (tg3_flag(tp, APE_HAS_NCSI))
-		return;
-
-	apedata = tg3_ape_read32(tp, TG3_APE_SEG_SIG);
-	if (apedata != APE_SEG_SIG_MAGIC)
-		return;
-
-	apedata = tg3_ape_read32(tp, TG3_APE_FW_STATUS);
-	if (!(apedata & APE_FW_STATUS_READY))
-		return;
-
-	/* Wait for up to 1 millisecond for APE to service previous event. */
-	for (i = 0; i < 10; i++) {
-		if (tg3_ape_lock(tp, TG3_APE_LOCK_MEM))
-			return;
-
-		apedata = tg3_ape_read32(tp, TG3_APE_EVENT_STATUS);
-
-		if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
-			tg3_ape_write32(tp, TG3_APE_EVENT_STATUS,
-					event | APE_EVENT_STATUS_EVENT_PENDING);
-
-		tg3_ape_unlock(tp, TG3_APE_LOCK_MEM);
-
-		if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
-			break;
-
-		udelay(100);
-	}
-
-	if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
-		tg3_ape_write32(tp, TG3_APE_EVENT, APE_EVENT_1);
-}
-
-static void tg3_ape_driver_state_change(struct tg3 *tp, int kind)
-{
-	u32 event;
-	u32 apedata;
-
-	if (!tg3_flag(tp, ENABLE_APE))
-		return;
-
-	switch (kind) {
-	case RESET_KIND_INIT:
-		tg3_ape_write32(tp, TG3_APE_HOST_SEG_SIG,
-				APE_HOST_SEG_SIG_MAGIC);
-		tg3_ape_write32(tp, TG3_APE_HOST_SEG_LEN,
-				APE_HOST_SEG_LEN_MAGIC);
-		apedata = tg3_ape_read32(tp, TG3_APE_HOST_INIT_COUNT);
-		tg3_ape_write32(tp, TG3_APE_HOST_INIT_COUNT, ++apedata);
-		tg3_ape_write32(tp, TG3_APE_HOST_DRIVER_ID,
-			APE_HOST_DRIVER_ID_MAGIC(TG3_MAJ_NUM, TG3_MIN_NUM));
-		tg3_ape_write32(tp, TG3_APE_HOST_BEHAVIOR,
-				APE_HOST_BEHAV_NO_PHYLOCK);
-		tg3_ape_write32(tp, TG3_APE_HOST_DRVR_STATE,
-				    TG3_APE_HOST_DRVR_STATE_START);
-
-		event = APE_EVENT_STATUS_STATE_START;
-		break;
-	case RESET_KIND_SHUTDOWN:
-		/* With the interface we are currently using,
-		 * APE does not track driver state.  Wiping
-		 * out the HOST SEGMENT SIGNATURE forces
-		 * the APE to assume OS absent status.
-		 */
-		tg3_ape_write32(tp, TG3_APE_HOST_SEG_SIG, 0x0);
-
-		if (device_may_wakeup(&tp->pdev->dev) &&
-		    tg3_flag(tp, WOL_ENABLE)) {
-			tg3_ape_write32(tp, TG3_APE_HOST_WOL_SPEED,
-					    TG3_APE_HOST_WOL_SPEED_AUTO);
-			apedata = TG3_APE_HOST_DRVR_STATE_WOL;
-		} else
-			apedata = TG3_APE_HOST_DRVR_STATE_UNLOAD;
-
-		tg3_ape_write32(tp, TG3_APE_HOST_DRVR_STATE, apedata);
-
-		event = APE_EVENT_STATUS_STATE_UNLOAD;
-		break;
-	case RESET_KIND_SUSPEND:
-		event = APE_EVENT_STATUS_STATE_SUSPEND;
-		break;
-	default:
-		return;
-	}
-
-	event |= APE_EVENT_STATUS_DRIVER_EVNT | APE_EVENT_STATUS_STATE_CHNGE;
-
-	tg3_ape_send_event(tp, event);
-}
-
-/* tp->lock is held. */
-static void tg3_write_sig_pre_reset(struct tg3 *tp, int kind)
-{
-	tg3_write_mem(tp, NIC_SRAM_FIRMWARE_MBOX,
-		      NIC_SRAM_FIRMWARE_MBOX_MAGIC1);
-
-	if (tg3_flag(tp, ASF_NEW_HANDSHAKE)) {
-		switch (kind) {
-		case RESET_KIND_INIT:
-			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
-				      DRV_STATE_START);
-			break;
-
-		case RESET_KIND_SHUTDOWN:
-			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
-				      DRV_STATE_UNLOAD);
-			break;
-
-		case RESET_KIND_SUSPEND:
-			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
-				      DRV_STATE_SUSPEND);
-			break;
-
-		default:
-			break;
-		}
-	}
-
-	if (kind == RESET_KIND_INIT ||
-	    kind == RESET_KIND_SUSPEND)
-		tg3_ape_driver_state_change(tp, kind);
-}
-
-/* tp->lock is held. */
-static void tg3_write_sig_post_reset(struct tg3 *tp, int kind)
-{
-	if (tg3_flag(tp, ASF_NEW_HANDSHAKE)) {
-		switch (kind) {
-		case RESET_KIND_INIT:
-			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
-				      DRV_STATE_START_DONE);
-			break;
-
-		case RESET_KIND_SHUTDOWN:
-			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
-				      DRV_STATE_UNLOAD_DONE);
-			break;
-
-		default:
-			break;
-		}
-	}
-
-	if (kind == RESET_KIND_SHUTDOWN)
-		tg3_ape_driver_state_change(tp, kind);
-}
-
-/* tp->lock is held. */
-static void tg3_write_sig_legacy(struct tg3 *tp, int kind)
-{
-	if (tg3_flag(tp, ENABLE_ASF)) {
-		switch (kind) {
-		case RESET_KIND_INIT:
-			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
-				      DRV_STATE_START);
-			break;
-
-		case RESET_KIND_SHUTDOWN:
-			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
-				      DRV_STATE_UNLOAD);
-			break;
-
-		case RESET_KIND_SUSPEND:
-			tg3_write_mem(tp, NIC_SRAM_FW_DRV_STATE_MBOX,
-				      DRV_STATE_SUSPEND);
-			break;
-
-		default:
-			break;
-		}
-	}
-}
-
-static int tg3_poll_fw(struct tg3 *tp)
-{
-	int i;
-	u32 val;
-
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-		/* Wait up to 20ms for init done. */
-		for (i = 0; i < 200; i++) {
-			if (tr32(VCPU_STATUS) & VCPU_STATUS_INIT_DONE)
-				return 0;
-			udelay(100);
-		}
-		return -ENODEV;
-	}
-
-	/* Wait for firmware initialization to complete. */
-	for (i = 0; i < 100000; i++) {
-		tg3_read_mem(tp, NIC_SRAM_FIRMWARE_MBOX, &val);
-		if (val == ~NIC_SRAM_FIRMWARE_MBOX_MAGIC1)
-			break;
-		udelay(10);
-	}
-
-	/* Chip might not be fitted with firmware.  Some Sun onboard
-	 * parts are configured like that.  So don't signal the timeout
-	 * of the above loop as an error, but do report the lack of
-	 * running firmware once.
-	 */
-	if (i >= 100000 && !tg3_flag(tp, NO_FWARE_REPORTED)) {
-		tg3_flag_set(tp, NO_FWARE_REPORTED);
-
-		netdev_info(tp->dev, "No firmware running\n");
-	}
-
-	if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0) {
-		/* The 57765 A0 needs a little more
-		 * time to do some important work.
-		 */
-		mdelay(10);
-	}
-
-	return 0;
-}
-
 /* Save PCI command register before chip reset */
 static void tg3_save_pci_state(struct tg3 *tp)
 {
-- 
1.7.3.4
