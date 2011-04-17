From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Suspend/resume - slow resume
Date: Sun, 17 Apr 2011 12:17:31 +0200
Message-ID: <20110417101731.GA17986@electric-eye.fr.zoreil.com>
References: <Pine.SOC.4.64.1104150931390.1320@er3.rutgers.edu> <BANLkTinO+HFq+Mgg1aUz9V==zYs7qSBtDw@mail.gmail.com> <Pine.SOC.4.64.1104151122330.1320@er3.rutgers.edu> <BANLkTi=Gq5thZk2f1nWTz3dDA5Non8ANZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ciprian Docan <docan@eden.rutgers.edu>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	"Rafael, J. Wysocki" <rjw@sisk.pl>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:34483 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab1DQKZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 06:25:49 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=Gq5thZk2f1nWTz3dDA5Non8ANZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> :
[...]
> So Francois, can we please not load the firmware at resume time when
> it wasn't loaded when suspended!

One can try the patch below. It is completely untested yet.

Subject: [PATCH] r8169: don't request firmware when there's no userspace.

The firmware is cached during open() and released during close().
The driver uses the cached firmware between open() and close().

Don't bother with rtl8169_pcierr_interrupt. It is special anyway.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   76 +++++++++++++++++++++++++++++++++++----------------
 1 files changed, 52 insertions(+), 24 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 493b0de..ccc25cd 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -170,6 +170,16 @@ static const struct {
 };
 #undef _R
 
+static const struct rtl_firmware_info {
+	int mac_version;
+	const char *fw_name;
+} rtl_firmware_infos[] = {
+	{ .mac_version = RTL_GIGA_MAC_VER_25, .fw_name = FIRMWARE_8168D_1 },
+	{ .mac_version = RTL_GIGA_MAC_VER_26, .fw_name = FIRMWARE_8168D_2 },
+	{ .mac_version = RTL_GIGA_MAC_VER_29, .fw_name = FIRMWARE_8105E_1 },
+	{ .mac_version = RTL_GIGA_MAC_VER_30, .fw_name = FIRMWARE_8105E_1 }
+};
+
 enum cfg_version {
 	RTL_CFG_0 = 0x00,
 	RTL_CFG_1,
@@ -1793,21 +1803,21 @@ static void rtl_release_firmware(struct rtl8169_private *tp)
 	tp->fw = NULL;
 }
 
-static int rtl_apply_firmware(struct rtl8169_private *tp, const char *fw_name)
+static void rtl_apply_firmware(struct rtl8169_private *tp)
 {
-	const struct firmware **fw = &tp->fw;
-	int rc = !*fw;
-
-	if (rc) {
-		rc = request_firmware(fw, fw_name, &tp->pci_dev->dev);
-		if (rc < 0)
-			goto out;
-	}
+	const struct firmware *fw = tp->fw;
 
 	/* TODO: release firmware once rtl_phy_write_fw signals failures. */
-	rtl_phy_write_fw(tp, *fw);
-out:
-	return rc;
+	if (fw)
+		rtl_phy_write_fw(tp, fw);
+}
+
+static void rtl_apply_firmware_cond(struct rtl8169_private *tp, u8 reg, u16 val)
+{
+	if (rtl_readphy(tp, reg) != val)
+		netif_warn(tp, hw, tp->dev, "chipset not ready for firmware\n");
+	else
+		rtl_apply_firmware(tp);
 }
 
 static void rtl8169s_hw_phy_config(struct rtl8169_private *tp)
@@ -2246,10 +2256,8 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x001b);
-	if ((rtl_readphy(tp, 0x06) != 0xbf00) ||
-	    (rtl_apply_firmware(tp, FIRMWARE_8168D_1) < 0)) {
-		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
-	}
+
+	rtl_apply_firmware_cond(tp, MII_EXPANSION, 0xbf00);
 
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
@@ -2351,10 +2359,8 @@ static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
 
 	rtl_writephy(tp, 0x1f, 0x0005);
 	rtl_writephy(tp, 0x05, 0x001b);
-	if ((rtl_readphy(tp, 0x06) != 0xb300) ||
-	    (rtl_apply_firmware(tp, FIRMWARE_8168D_2) < 0)) {
-		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
-	}
+
+	rtl_apply_firmware_cond(tp, MII_EXPANSION, 0xb300);
 
 	rtl_writephy(tp, 0x1f, 0x0000);
 }
@@ -2474,8 +2480,7 @@ static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x18, 0x0310);
 	msleep(100);
 
-	if (rtl_apply_firmware(tp, FIRMWARE_8105E_1) < 0)
-		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
+	rtl_apply_firmware(tp);
 
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
@@ -3288,8 +3293,6 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 
 	cancel_delayed_work_sync(&tp->task);
 
-	rtl_release_firmware(tp);
-
 	unregister_netdev(dev);
 
 	if (pci_dev_run_wake(pdev))
@@ -3303,6 +3306,27 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
+static void rtl_request_firmware(struct rtl8169_private *tp)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(rtl_firmware_infos); i++) {
+		const struct rtl_firmware_info *info = rtl_firmware_infos + i;
+
+		if (info->mac_version == tp->mac_version) {
+			const char *name = info->fw_name;
+			int rc;
+
+			rc = request_firmware(&tp->fw, name, &tp->pci_dev->dev);
+			if (rc < 0) {
+				netif_warn(tp, ifup, tp->dev, "unable to load "
+					"firmware patch %s (%d)\n", name, rc);
+			}
+			break;
+		}
+	}
+}
+
 static int rtl8169_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3334,6 +3358,8 @@ static int rtl8169_open(struct net_device *dev)
 
 	smp_mb();
 
+	rtl_request_firmware(tp);
+
 	retval = request_irq(dev->irq, rtl8169_interrupt,
 			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
 			     dev->name, dev);
@@ -4891,6 +4917,8 @@ static int rtl8169_close(struct net_device *dev)
 
 	free_irq(dev->irq, dev);
 
+	rtl_release_firmware(tp);
+
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			  tp->RxPhyAddr);
 	dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->TxDescArray,
-- 
1.7.4

