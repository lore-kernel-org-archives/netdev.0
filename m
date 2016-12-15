From: Geoff Lansberry <geoff@kuvee.com>
Subject: [PATCH 1/3] NFC: trf7970a: add device tree option for 27MHz clock
Date: Thu, 15 Dec 2016 17:30:42 -0500
Message-ID: <1481841044-4314-1-git-send-email-glansberry@gmail.com>
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
        sameo@linux.intel.com, robh+dt@kernel.org, mark.rutland@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, mgreer@animalcreek.com,
        justin@kuvee.com, Geoff Lansberry <geoff@kuvee.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geoff Lansberry <geoff@kuvee.com>

---
 .../devicetree/bindings/net/nfc/trf7970a.txt       |  3 ++
 drivers/nfc/trf7970a.c                             | 42 ++++++++++++++++------
 2 files changed, 34 insertions(+), 11 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
index 32b35a0..9dda879 100644
--- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
+++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
@@ -21,6 +21,8 @@ Optional SoC Specific Properties:
 - t5t-rmb-extra-byte-quirk: Specify that the trf7970a has the erratum
   where an extra byte is returned by Read Multiple Block commands issued
   to Type 5 tags.
+- crystal_27mhz: Set to specify that the input frequency to the trf7970a is 27.12MHz
+
 
 Example (for ARM-based BeagleBone with TRF7970A on SPI1):
 
@@ -43,6 +45,7 @@ Example (for ARM-based BeagleBone with TRF7970A on SPI1):
 		irq-status-read-quirk;
 		en2-rf-quirk;
 		t5t-rmb-extra-byte-quirk;
+		crystal_27mhz;
 		status = "okay";
 	};
 };
diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
index 26c9dbb..2d2a077 100644
--- a/drivers/nfc/trf7970a.c
+++ b/drivers/nfc/trf7970a.c
@@ -1056,12 +1056,11 @@ static int trf7970a_init(struct trf7970a *trf)
 
 	trf->chip_status_ctrl &= ~TRF7970A_CHIP_STATUS_RF_ON;
 
-	ret = trf7970a_write(trf, TRF7970A_MODULATOR_SYS_CLK_CTRL, 0);
+	ret = trf7970a_write(trf, TRF7970A_MODULATOR_SYS_CLK_CTRL,
+			trf->modulator_sys_clk_ctrl);
 	if (ret)
 		goto err_out;
 
-	trf->modulator_sys_clk_ctrl = 0;
-
 	ret = trf7970a_write(trf, TRF7970A_ADJUTABLE_FIFO_IRQ_LEVELS,
 			TRF7970A_ADJUTABLE_FIFO_IRQ_LEVELS_WLH_96 |
 			TRF7970A_ADJUTABLE_FIFO_IRQ_LEVELS_WLL_32);
@@ -1181,27 +1180,37 @@ static int trf7970a_in_config_rf_tech(struct trf7970a *trf, int tech)
 	switch (tech) {
 	case NFC_DIGITAL_RF_TECH_106A:
 		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_14443A_106;
-		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_OOK;
+		trf->modulator_sys_clk_ctrl =
+			(trf->modulator_sys_clk_ctrl & 0xF8) |
+			TRF7970A_MODULATOR_DEPTH_OOK;
 		trf->guard_time = TRF7970A_GUARD_TIME_NFCA;
 		break;
 	case NFC_DIGITAL_RF_TECH_106B:
 		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_14443B_106;
-		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_ASK10;
+		trf->modulator_sys_clk_ctrl =
+			(trf->modulator_sys_clk_ctrl & 0xF8) |
+			TRF7970A_MODULATOR_DEPTH_ASK10;
 		trf->guard_time = TRF7970A_GUARD_TIME_NFCB;
 		break;
 	case NFC_DIGITAL_RF_TECH_212F:
 		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_FELICA_212;
-		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_ASK10;
+		trf->modulator_sys_clk_ctrl =
+			(trf->modulator_sys_clk_ctrl & 0xF8) |
+			TRF7970A_MODULATOR_DEPTH_ASK10;
 		trf->guard_time = TRF7970A_GUARD_TIME_NFCF;
 		break;
 	case NFC_DIGITAL_RF_TECH_424F:
 		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_FELICA_424;
-		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_ASK10;
+		trf->modulator_sys_clk_ctrl =
+			(trf->modulator_sys_clk_ctrl & 0xF8) |
+			TRF7970A_MODULATOR_DEPTH_ASK10;
 		trf->guard_time = TRF7970A_GUARD_TIME_NFCF;
 		break;
 	case NFC_DIGITAL_RF_TECH_ISO15693:
 		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_15693_SGL_1OF4_2648;
-		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_OOK;
+		trf->modulator_sys_clk_ctrl =
+			(trf->modulator_sys_clk_ctrl & 0xF8) |
+			TRF7970A_MODULATOR_DEPTH_OOK;
 		trf->guard_time = TRF7970A_GUARD_TIME_15693;
 		break;
 	default:
@@ -1571,17 +1580,23 @@ static int trf7970a_tg_config_rf_tech(struct trf7970a *trf, int tech)
 		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_NFC_NFC_CE_MODE |
 			TRF7970A_ISO_CTRL_NFC_CE |
 			TRF7970A_ISO_CTRL_NFC_CE_14443A;
-		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_OOK;
+		trf->modulator_sys_clk_ctrl =
+			(trf->modulator_sys_clk_ctrl & 0xF8) |
+			TRF7970A_MODULATOR_DEPTH_OOK;
 		break;
 	case NFC_DIGITAL_RF_TECH_212F:
 		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_NFC_NFC_CE_MODE |
 			TRF7970A_ISO_CTRL_NFC_NFCF_212;
-		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_ASK10;
+		trf->modulator_sys_clk_ctrl =
+			(trf->modulator_sys_clk_ctrl & 0xF8) |
+			TRF7970A_MODULATOR_DEPTH_ASK10;
 		break;
 	case NFC_DIGITAL_RF_TECH_424F:
 		trf->iso_ctrl_tech = TRF7970A_ISO_CTRL_NFC_NFC_CE_MODE |
 			TRF7970A_ISO_CTRL_NFC_NFCF_424;
-		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_DEPTH_ASK10;
+		trf->modulator_sys_clk_ctrl =
+			(trf->modulator_sys_clk_ctrl & 0xF8) |
+			TRF7970A_MODULATOR_DEPTH_ASK10;
 		break;
 	default:
 		dev_dbg(trf->dev, "Unsupported rf technology: %d\n", tech);
@@ -2043,6 +2058,11 @@ static int trf7970a_probe(struct spi_device *spi)
 		return ret;
 	}
 
+	if (of_property_read_bool(np, "crystal_27mhz")) {
+		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_27MHZ;
+		dev_dbg(trf->dev, "trf7970a configure crystal_27mhz\n");
+	}
+
 	if (of_property_read_bool(np, "en2-rf-quirk"))
 		trf->quirks |= TRF7970A_QUIRK_EN2_MUST_STAY_LOW;
 
-- 
Signed-off-by: Geoff Lansberry <geoff@kuvee.com>
