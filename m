From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Suspend/resume - slow resume
Date: Wed, 20 Apr 2011 20:16:02 +0200
Message-ID: <20110420181602.GA18740@electric-eye.fr.zoreil.com>
References: <Pine.SOC.4.64.1104150931390.1320@er3.rutgers.edu> <BANLkTinO+HFq+Mgg1aUz9V==zYs7qSBtDw@mail.gmail.com> <Pine.SOC.4.64.1104151122330.1320@er3.rutgers.edu> <BANLkTi=Gq5thZk2f1nWTz3dDA5Non8ANZg@mail.gmail.com> <20110417101731.GA17986@electric-eye.fr.zoreil.com> <BANLkTi=tPc6NmUuTYqbVZduNRNbE=-c34Q@mail.gmail.com> <20110418180813.GA18469@electric-eye.fr.zoreil.com> <BANLkTim_1OgqjCeD1a4Ay2fWJSmPHa_XTQ@mail.gmail.com> <Pine.SOC.4.64.1104181519490.1320@er3.rutgers.edu> <BANLkTi=dke10HougmiQn9hSF15nK0B8mdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ciprian Docan <docan@eden.rutgers.edu>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
	"Rafael, J. Wysocki" <rjw@sisk.pl>, Greg KH <gregkh@suse.de>,
	nic_swsd@realtek.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTi=dke10HougmiQn9hSF15nK0B8mdA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> :
[...]
> Francois' patch is fine and improves on things, I only had a few
> arguments with it. The problems I think it had were really about some
> rather special cases.

They may be addressed by the patch below.

I'll test it as soon as my 2.6.39-rc stops softlocking and I have a
working suspend / resume. No joke.

Subject: [PATCH] r8169: don't request firmware when there's no userspace.

The firmware is cached during the first successfull call to open() and
released once the network device is unregistered. The driver uses the
cached firmware between open() and unregister_netdev().

So far the firmware is optional : a failure to load the firmware does
not prevent open() to success. It is thus necessary to 1) unregister
all 816x / 810[23] devices and 2) force a driver probe to issue a new
firmware load.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |   92 ++++++++++++++++++++++++++++++++++++---------------
 1 files changed, 65 insertions(+), 27 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 493b0de..fceb954 100644
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
@@ -565,6 +575,7 @@ struct rtl8169_private {
 	u32 saved_wolopts;
 
 	const struct firmware *fw;
+#define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN);
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -1790,24 +1801,24 @@ rtl_phy_write_fw(struct rtl8169_private *tp, const struct firmware *fw)
 static void rtl_release_firmware(struct rtl8169_private *tp)
 {
 	release_firmware(tp->fw);
-	tp->fw = NULL;
+	tp->fw = RTL_FIRMWARE_UNKNOWN;
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
+	if (!IS_ERR_OR_NULL(fw))
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
@@ -2246,10 +2257,8 @@ static void rtl8168d_1_hw_phy_config(struct rtl8169_private *tp)
 
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
@@ -2351,10 +2360,8 @@ static void rtl8168d_2_hw_phy_config(struct rtl8169_private *tp)
 
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
@@ -2474,8 +2481,7 @@ static void rtl8105e_hw_phy_config(struct rtl8169_private *tp)
 	rtl_writephy(tp, 0x18, 0x0310);
 	msleep(100);
 
-	if (rtl_apply_firmware(tp, FIRMWARE_8105E_1) < 0)
-		netif_warn(tp, probe, tp->dev, "unable to apply firmware patch\n");
+	rtl_apply_firmware(tp);
 
 	rtl_writephy_batch(tp, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
@@ -3237,6 +3243,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
 
+	tp->fw = RTL_FIRMWARE_UNKNOWN;
+
 	rc = register_netdev(dev);
 	if (rc < 0)
 		goto err_out_msi_4;
@@ -3288,10 +3296,10 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 
 	cancel_delayed_work_sync(&tp->task);
 
-	rtl_release_firmware(tp);
-
 	unregister_netdev(dev);
 
+	rtl_release_firmware(tp);
+
 	if (pci_dev_run_wake(pdev))
 		pm_runtime_get_noresume(&pdev->dev);
 
@@ -3303,6 +3311,33 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
+static void rtl_request_firmware(struct rtl8169_private *tp)
+{
+	int i;
+
+	/* Return early if the firmware is already loaded / cached. */
+	if (!IS_ERR(tp->fw))
+		return;
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
+			return;
+		}
+	}
+
+	tp->fw = NULL;
+}
+
 static int rtl8169_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -3334,11 +3369,13 @@ static int rtl8169_open(struct net_device *dev)
 
 	smp_mb();
 
+	rtl_request_firmware(tp);
+
 	retval = request_irq(dev->irq, rtl8169_interrupt,
 			     (tp->features & RTL_FEATURE_MSI) ? 0 : IRQF_SHARED,
 			     dev->name, dev);
 	if (retval < 0)
-		goto err_release_ring_2;
+		goto err_release_fw_2;
 
 	napi_enable(&tp->napi);
 
@@ -3359,7 +3396,8 @@ static int rtl8169_open(struct net_device *dev)
 out:
 	return retval;
 
-err_release_ring_2:
+err_release_fw_2:
+	rtl_release_firmware(tp);
 	rtl8169_rx_clear(tp);
 err_free_rx_1:
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
-- 
1.7.4.2
