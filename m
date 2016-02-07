From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: [PATCH 6/7] net: phy: spi_ks8995: add support for MICREL KSZ8795CLX
Date: Sun,  7 Feb 2016 23:39:12 +0100
Message-ID: <1454884753-4560-7-git-send-email-helmut.buchsbaum@gmail.com>
References: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35052 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754991AbcBGWkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 17:40:01 -0500
Received: by mail-wm0-f68.google.com with SMTP id g62so12876872wme.2
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 14:40:01 -0800 (PST)
In-Reply-To: <1454884753-4560-1-git-send-email-helmut.buchsbaum@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for MICREL KSZ8795CLX Integrated 5-Port, 10-/100-Managed
Ethernet Switch with Gigabit GMII/RGMII and MII/RMII interfaces.

Signed-off-by: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
---
 drivers/net/phy/spi_ks8995.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/drivers/net/phy/spi_ks8995.c b/drivers/net/phy/spi_ks8995.c
index 6d6f984..5a3f75d 100644
--- a/drivers/net/phy/spi_ks8995.c
+++ b/drivers/net/phy/spi_ks8995.c
@@ -77,6 +77,7 @@
 
 #define KS8995_REGS_SIZE	0x80
 #define KSZ8864_REGS_SIZE	0x100
+#define KSZ8795_REGS_SIZE	0x100
 
 #define ID1_CHIPID_M		0xf
 #define ID1_CHIPID_S		4
@@ -85,9 +86,11 @@
 #define ID1_START_SW		1	/* start the switch */
 
 #define FAMILY_KS8995		0x95
+#define FAMILY_KSZ8795		0x87
 #define CHIPID_M		0
 #define KS8995_CHIP_ID		0x00
 #define KSZ8864_CHIP_ID		0x01
+#define KSZ8795_CHIP_ID		0x09
 
 #define KS8995_CMD_WRITE	0x02U
 #define KS8995_CMD_READ		0x03U
@@ -97,6 +100,7 @@
 enum ks8995_chip_variant {
 	ks8995,
 	ksz8864,
+	ksz8795,
 	max_variant
 };
 
@@ -126,6 +130,14 @@ static const struct ks8995_chip_params ks8995_chip[] = {
 		.addr_width = 8,
 		.addr_shift = 0,
 	},
+	[ksz8795] = {
+		.name = "KSZ8795CLX",
+		.family_id = FAMILY_KSZ8795,
+		.chip_id = KSZ8795_CHIP_ID,
+		.regs_size = KSZ8795_REGS_SIZE,
+		.addr_width = 12,
+		.addr_shift = 1,
+	},
 };
 
 struct ks8995_pdata {
@@ -150,6 +162,7 @@ struct ks8995_switch {
 static const struct spi_device_id ks8995_id[] = {
 	{"ks8995", ks8995},
 	{"ksz8864", ksz8864},
+	{"ksz8795", ksz8795},
 	{ }
 };
 MODULE_DEVICE_TABLE(spi, ks8995_id);
@@ -408,6 +421,22 @@ static int ks8995_get_revision(struct ks8995_switch *ks)
 			err = -ENODEV;
 		}
 		break;
+	case FAMILY_KSZ8795:
+		/* try reading chip id at CHIP ID1 */
+		err = ks8995_read_reg(ks, KS8995_REG_ID1, &id1);
+		if (err) {
+			err = -EIO;
+			goto err_out;
+		}
+
+		if (get_chip_id(id1) == ks->chip->chip_id) {
+			ks->revision_id = get_chip_rev(id1);
+		} else {
+			dev_err(&ks->spi->dev, "unsupported chip id for KSZ8795 family: 0x%02x\n",
+				id1);
+			err = -ENODEV;
+		}
+		break;
 	default:
 		dev_err(&ks->spi->dev, "unsupported family id: 0x%02x\n", id0);
 		err = -ENODEV;
-- 
2.1.4
