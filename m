From: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/3] NFC: trf7970a: Add device tree option of 1.8 Volt IO voltage
Date: Thu, 15 Dec 2016 17:30:43 -0500
Message-ID: <1481841044-4314-2-git-send-email-glansberry@gmail.com>
References: <1481841044-4314-1-git-send-email-glansberry@gmail.com>
Cc: lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org, aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
        sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mgreer-luAo+O/VEmrlveNOaEYElw@public.gmane.org,
        justin-R+k406RtEhcAvxtiuMwx3w@public.gmane.org, Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1481841044-4314-1-git-send-email-glansberry-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>

---
 Documentation/devicetree/bindings/net/nfc/trf7970a.txt |  2 ++
 drivers/nfc/trf7970a.c                                 | 13 ++++++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
index 9dda879..208f045 100644
--- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
+++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
@@ -21,6 +21,7 @@ Optional SoC Specific Properties:
 - t5t-rmb-extra-byte-quirk: Specify that the trf7970a has the erratum
   where an extra byte is returned by Read Multiple Block commands issued
   to Type 5 tags.
+- vdd_io_1v8: Set to specify that the trf7970a io voltage should be set to 1.8V
 - crystal_27mhz: Set to specify that the input frequency to the trf7970a is 27.12MHz
 
 
@@ -45,6 +46,7 @@ Example (for ARM-based BeagleBone with TRF7970A on SPI1):
 		irq-status-read-quirk;
 		en2-rf-quirk;
 		t5t-rmb-extra-byte-quirk;
+		vdd_io_1v8;
 		crystal_27mhz;
 		status = "okay";
 	};
diff --git a/drivers/nfc/trf7970a.c b/drivers/nfc/trf7970a.c
index 2d2a077..b4c37ab 100644
--- a/drivers/nfc/trf7970a.c
+++ b/drivers/nfc/trf7970a.c
@@ -441,6 +441,7 @@ struct trf7970a {
 	u8				iso_ctrl_tech;
 	u8				modulator_sys_clk_ctrl;
 	u8				special_fcn_reg1;
+	u8				io_ctrl;
 	unsigned int			guard_time;
 	int				technology;
 	int				framing;
@@ -1048,6 +1049,11 @@ static int trf7970a_init(struct trf7970a *trf)
 	if (ret)
 		goto err_out;
 
+	ret = trf7970a_write(trf, TRF7970A_REG_IO_CTRL,
+			trf->io_ctrl|TRF7970A_REG_IO_CTRL_VRS(0x1));
+	if (ret)
+		goto err_out;
+
 	ret = trf7970a_write(trf, TRF7970A_NFC_TARGET_LEVEL, 0);
 	if (ret)
 		goto err_out;
@@ -1764,7 +1770,7 @@ static int _trf7970a_tg_listen(struct nfc_digital_dev *ddev, u16 timeout,
 		goto out_err;
 
 	ret = trf7970a_write(trf, TRF7970A_REG_IO_CTRL,
-			TRF7970A_REG_IO_CTRL_VRS(0x1));
+			trf->io_ctrl|TRF7970A_REG_IO_CTRL_VRS(0x1));
 	if (ret)
 		goto out_err;
 
@@ -2058,6 +2064,11 @@ static int trf7970a_probe(struct spi_device *spi)
 		return ret;
 	}
 
+	if (of_property_read_bool(np, "vdd_io_1v8")) {
+		trf->io_ctrl = TRF7970A_REG_IO_CTRL_IO_LOW;
+		dev_dbg(trf->dev, "trf7970a config vdd_io_1v8\n");
+	}
+
 	if (of_property_read_bool(np, "crystal_27mhz")) {
 		trf->modulator_sys_clk_ctrl = TRF7970A_MODULATOR_27MHZ;
 		dev_dbg(trf->dev, "trf7970a configure crystal_27mhz\n");
-- 
Signed-off-by: Geoff Lansberry <geoff-R+k406RtEhcAvxtiuMwx3w@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
