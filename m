From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: keep firmware in memory.
Date: Fri, 14 Jan 2011 00:07:53 +0100
Message-ID: <20110113230753.GA2750@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Jarek =?utf-8?B?S2FtacWEc2tp?= <jarek@vilo.eu.org>,
	Hayes <hayeswang@realtek.com>, Ben Hutchings <benh@debian.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:37613 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663Ab1AMXJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 18:09:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The firmware agent is not available during resume. Loading the firmware
during open() (see eee3a96c6368f47df8df5bd4ed1843600652b337) is not
enough.

close() is run during resume through rtl8169_reset_task(), whence the
mildly natural release of firmware in the driver removal method instead=
=2E

It will help with http://bugs.debian.org/609538. It will not avoid
the 60 seconds delay when:
- there is no firmware
- the driver is loaded and the device is not up before a suspend/resume

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Jarek Kami=C5=84ski <jarek@vilo.eu.org>
Cc: Hayes <hayeswang@realtek.com>
Cc: Ben Hutchings <benh@debian.org>
---
 drivers/net/r8169.c |   43 +++++++++++++++++++++++++++++++------------
 1 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index bb8645a..bde7d61 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -554,6 +554,8 @@ struct rtl8169_private {
 	struct mii_if_info mii;
 	struct rtl8169_counters counters;
 	u32 saved_wolopts;
+
+	const struct firmware *fw;
 };
=20
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.or=
g>");
@@ -1766,6 +1768,29 @@ rtl_phy_write_fw(struct rtl8169_private *tp, con=
st struct firmware *fw)
 	}
 }
=20
+static void rtl_release_firmware(struct rtl8169_private *tp)
+{
+	release_firmware(tp->fw);
+	tp->fw =3D NULL;
+}
+
+static int rtl_apply_firmware(struct rtl8169_private *tp, const char *=
fw_name)
+{
+	const struct firmware **fw =3D &tp->fw;
+	int rc =3D !*fw;
+
+	if (rc) {
+		rc =3D request_firmware(fw, fw_name, &tp->pci_dev->dev);
+		if (rc < 0)
+			goto out;
+	}
+
+	/* TODO: release firmware once rtl_phy_write_fw signals failures. */
+	rtl_phy_write_fw(tp, *fw);
+out:
+	return rc;
+}
+
 static void rtl8169s_hw_phy_config(struct rtl8169_private *tp)
 {
 	static const struct phy_reg phy_reg_init[] =3D {
@@ -2139,7 +2164,6 @@ static void rtl8168d_1_hw_phy_config(struct rtl81=
69_private *tp)
 		{ 0x0d, 0xf880 }
 	};
 	void __iomem *ioaddr =3D tp->mmio_addr;
-	const struct firmware *fw;
=20
 	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
=20
@@ -2203,11 +2227,8 @@ static void rtl8168d_1_hw_phy_config(struct rtl8=
169_private *tp)
=20
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x001b);
-	if (rtl_readphy(tp, 0x06) =3D=3D 0xbf00 &&
-	    request_firmware(&fw, FIRMWARE_8168D_1, &tp->pci_dev->dev) =3D=3D=
 0) {
-		rtl_phy_write_fw(tp, fw);
-		release_firmware(fw);
-	} else {
+	if ((rtl_readphy(tp, 0x06) !=3D 0xbf00) ||
+	    (rtl_apply_firmware(tp, FIRMWARE_8168D_1) < 0)) {
 		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
 	}
=20
@@ -2257,7 +2278,6 @@ static void rtl8168d_2_hw_phy_config(struct rtl81=
69_private *tp)
 		{ 0x0d, 0xf880 }
 	};
 	void __iomem *ioaddr =3D tp->mmio_addr;
-	const struct firmware *fw;
=20
 	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
=20
@@ -2312,11 +2332,8 @@ static void rtl8168d_2_hw_phy_config(struct rtl8=
169_private *tp)
=20
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x001b);
-	if (rtl_readphy(tp, 0x06) =3D=3D 0xb300 &&
-	    request_firmware(&fw, FIRMWARE_8168D_2, &tp->pci_dev->dev) =3D=3D=
 0) {
-		rtl_phy_write_fw(tp, fw);
-		release_firmware(fw);
-	} else {
+	if ((rtl_readphy(tp, 0x06) !=3D 0xb300) ||
+	    (rtl_apply_firmware(tp, FIRMWARE_8168D_2) < 0)) {
 		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
 	}
=20
@@ -3200,6 +3217,8 @@ static void __devexit rtl8169_remove_one(struct p=
ci_dev *pdev)
=20
 	cancel_delayed_work_sync(&tp->task);
=20
+	rtl_release_firmware(tp);
+
 	unregister_netdev(dev);
=20
 	if (pci_dev_run_wake(pdev))
--=20
1.7.3.4

