From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bug#609538: r8169: long delay during resume
Date: Tue, 11 Jan 2011 14:25:24 +0100
Message-ID: <20110111132524.GA2479@electric-eye.fr.zoreil.com>
References: <20110110131439.GA663@rocket.almost.secure.la> <1294724952.3235.2.camel@localhost> <4D2C06CF.4090507@vilo.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>, 609538@bugs.debian.org,
	Hayes Wang <hayeswang@realtek.com>,
	netdev <netdev@vger.kernel.org>
To: Jarek =?utf-8?B?S2FtacWEc2tp?= <jarek@vilo.eu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:59236 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837Ab1AKN0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 08:26:05 -0500
Content-Disposition: inline
In-Reply-To: <4D2C06CF.4090507@vilo.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Kami=C5=84ski <jarek@vilo.eu.org> :
[...]
> The last 2.6.36 I've tried was 2.6.36-1~experimental.1, I've then
> passsed and returned to 2.6.32 for unrelated problems. I think it was=
n't
> affected, but I can re-check it and/or test later 2.6.36 versions if =
it
> may help.

The patch below against 2.6.37-git + davem's pending fixes (see
http://marc.info/?l=3Dlinux-netdev&m=3D129448910825754) should help.

Can you give it a try ?

r8169: keep firmware in memory.

The firmware agent is not available during resume.

It will help with http://bugs.debian.org/609538 but it will not avoid
the 60 seconds delay when there is no firmware.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Hayes <hayeswang@realtek.com>
Cc: Ben Hutchings <benh@debian.org>
---
 drivers/net/r8169.c |   43 +++++++++++++++++++++++++++++++------------
 1 files changed, 31 insertions(+), 12 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dd758cd..7e2f01c 100644
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
@@ -1668,6 +1670,29 @@ rtl_phy_write_fw(struct rtl8169_private *tp, con=
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
@@ -2041,7 +2066,6 @@ static void rtl8168d_1_hw_phy_config(struct rtl81=
69_private *tp)
 		{ 0x0d, 0xf880 }
 	};
 	void __iomem *ioaddr =3D tp->mmio_addr;
-	const struct firmware *fw;
=20
 	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
=20
@@ -2105,11 +2129,8 @@ static void rtl8168d_1_hw_phy_config(struct rtl8=
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
@@ -2159,7 +2180,6 @@ static void rtl8168d_2_hw_phy_config(struct rtl81=
69_private *tp)
 		{ 0x0d, 0xf880 }
 	};
 	void __iomem *ioaddr =3D tp->mmio_addr;
-	const struct firmware *fw;
=20
 	rtl_writephy_batch(tp, phy_reg_init_0, ARRAY_SIZE(phy_reg_init_0));
=20
@@ -2214,11 +2234,8 @@ static void rtl8168d_2_hw_phy_config(struct rtl8=
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
@@ -4662,6 +4679,8 @@ static int rtl8169_close(struct net_device *dev)
 	tp->TxDescArray =3D NULL;
 	tp->RxDescArray =3D NULL;
=20
+	rtl_release_firmware(tp);
+
 	pm_runtime_put_sync(&pdev->dev);
=20
 	return 0;
--=20
1.7.3.4

