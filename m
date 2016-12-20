From: Geoff Lansberry <geoff@kuvee.com>
Subject: [PATCH 2/3] NFC: trf7970a: Add device tree option of 1.8 Volt IO voltage
Date: Tue, 20 Dec 2016 11:10:46 -0500
Message-ID: <1482250250-4192-3-git-send-email-glansberry@gmail.com>
References: <1482250250-4192-1-git-send-email-glansberry@gmail.com>
Cc: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
        sameo@linux.intel.com, robh+dt@kernel.org, mark.rutland@arm.com,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, mgreer@animalcreek.com,
        justin@kuvee.com, Geoff Lansberry <geoff@kuvee.com>
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482250250-4192-1-git-send-email-glansberry@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geoff Lansberry <geoff@kuvee.com>

The TRF7970A has configuration options for supporting hardware designs
with 1.8 Volt or 3.3 Volt IO.   This commit adds a device tree option,
using a fixed regulator binding, for setting the io voltage to match
the hardware configuration. If no option is supplied it defaults to
3.3 volt configuration.
---
 .../devicetree/bindings/net/nfc/trf7970a.txt       |  4 ++--
 drivers/nfc/trf7970a.c                             | 28 +++++++++++++++++++++-
 2 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
index e262ac1..b5777d8 100644
--- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
+++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
@@ -21,9 +21,9 @@ Optional SoC Specific Properties:
 - t5t-rmb-extra-byte-quirk: Specify that the trf7970a has the erratum
   where an extra byte is returned by Read Multiple Block commands issued
   to Type 5 tags.
+- vdd-io-supply: Regulator specifying voltage for vdd-io
 - clock-frequency: Set to specify that the input frequency to the trf7970a is 13560000Hz or 27120000Hz
 
-
 Example (for ARM-based BeagleBone with TRF7970A on SPI1):
 
 &spi1 {
@@ -41,11 +41,11 @@ Example (for ARM-based BeagleBone with TRF7970A on SPI1):
 				  <&gpio2 5 GPIO_ACTIVE_LOW>;
 		vin-supply = <&ldo3_reg>;
 		vin-voltage-override = <5000000>;
+		vdd-io-supply = <&ldo2_reg>;
 		autosuspend-delay = <30000>;
 		irq-status-read-quirk;
 		en2-rf-quirk;
 		t5t-rmb-extra-byte-quirk;
-		vdd_io_1v8;
 		clock-frequency = <27120000>;
 		status = "okay";
 	};
diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
index 4e051e9..8a88195 100644
--- a/drivers/nfc/trf7970a.c
+++ b/drivers/nfc/trf7970a.c
@@ -444,6 +444,7 @@ struct trf7970a {
 	u8				iso_ctrl_tech;
 	u8				modulator_sys_clk_ctrl;
 	u8				special_fcn_reg1;
+	u8				io_ctrl;
 	unsigned int			guard_time;
 	int				technology;
 	int				framing;
@@ -1051,6 +1052,11 @@ static int trf7970a_init(struct trf7970a *trf)
 	if (ret)
 		goto err_out;
 
+	ret = trf7970a_write(trf, TRF7970A_REG_IO_CTRL,
+			trf->io_ctrl | TRF7970A_REG_IO_CTRL_VRS(0x1));
+	if (ret)
+		goto err_out;
+
 	ret = trf7970a_write(trf, TRF7970A_NFC_TARGET_LEVEL, 0);
 	if (ret)
 		goto err_out;
@@ -1767,7 +1773,7 @@ static int _trf7970a_tg_listen(struct nfc_digital_dev *ddev, u16 timeout,
 		goto out_err;
 
 	ret = trf7970a_write(trf, TRF7970A_REG_IO_CTRL,
-			TRF7970A_REG_IO_CTRL_VRS(0x1));
+			trf->io_ctrl | TRF7970A_REG_IO_CTRL_VRS(0x1));
 	if (ret)
 		goto out_err;
 
@@ -2062,6 +2068,7 @@ static int trf7970a_probe(struct spi_device *spi)
 		return ret;
 	}
 
+
 	of_property_read_u32(np, "clock-frequency", &clk_freq);
 	if ((clk_freq != TRF7970A_27MHZ_CLOCK_FREQUENCY) ||
 		(clk_freq != TRF7970A_27MHZ_CLOCK_FREQUENCY)) {
@@ -2105,6 +2112,25 @@ static int trf7970a_probe(struct spi_device *spi)
 	if (uvolts > 4000000)
 		trf->chip_status_ctrl = TRF7970A_CHIP_STATUS_VRS5_3;
 
+	trf->regulator = devm_regulator_get(&spi->dev, "vdd-io");
+	if (IS_ERR(trf->regulator)) {
+		ret = PTR_ERR(trf->regulator);
+		dev_err(trf->dev, "Can't get VDD_IO regulator: %d\n", ret);
+		goto err_destroy_lock;
+	}
+
+	ret = regulator_enable(trf->regulator);
+	if (ret) {
+		dev_err(trf->dev, "Can't enable VDD_IO: %d\n", ret);
+		goto err_destroy_lock;
+	}
+
+
+	if (regulator_get_voltage(trf->regulator) == 1800000) {
+		trf->io_ctrl = TRF7970A_REG_IO_CTRL_IO_LOW;
+		dev_dbg(trf->dev, "trf7970a config vdd_io to 1.8V\n");
+	}
+
 	trf->ddev = nfc_digital_allocate_device(&trf7970a_nfc_ops,
 			TRF7970A_SUPPORTED_PROTOCOLS,
 			NFC_DIGITAL_DRV_CAPS_IN_CRC |
-- 
Signed-off-by: Geoff Lansberry <geoff@kuvee.com>
