From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-01-04
Date: Wed, 4 Jan 2012 10:58:17 -0500
Message-ID: <20120104155816.GE2540@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xXmbgvnjoT4axfJE"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--xXmbgvnjoT4axfJE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit a3657f54f7f0371473d9d734ba1b0d15ddf24286

Dave,

Here are a handful of straggler wireless fixes for 3.2.  Included is
a NULL pointer fix for mwifiex, a regression fix for handling rx
header lengths for differnt b43 firmwares in PIO mode, a revert of
a one-liner for Bluetooth HCI that was causing uncomfortable delays
during resume, an ath9k fix for a panic when running in AP mode
with aggregation disabled, an an rtlwifi fix for an annoying WARNING
during suspend/resume.

The Bluetooth fix is a one-liner change of a delay value.  The mwifiex,
b43, and ath9k fixes are relatively small and isolated to their
respective drivers.  The rtlwifi fix is a bit porky, but it also
limits itself at least to the rtlwifi family.

I was hesitant to include the rtlwifi fix, but settled on inclusion
because it was a product of a recent ginormous thread about the
intersection of firmware loading and suspend/resume.  Plus it fixes
a bug report in the Red Hat Bugzilla. :-) If you don't think it is
worthy, let me know and I'll drop it from this release.

Please let me know if there are problems!

John

---

The following changes since commit 405cc2736527bd506fd8f652308b03b2c8a1e8b9:

  fix CAN MAINTAINERS SCM tree type (2012-01-03 14:57:43 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Amitkumar Karwar (1):
      mwifiex: fix crash during simultaneous scan and connect

Guennadi Liakhovetski (1):
      b43: fix regression in PIO case

Gustavo F. Padovan (1):
      Revert "Bluetooth: Increase HCI reset timeout in hci_dev_do_close"

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtl8192cu: Fix WARNING on suspend/resume

Mohammed Shafi Shajakhan (1):
      ath9k: Fix kernel panic in AR2427 in AP mode

 drivers/net/wireless/ath/ath9k/main.c             |    3 +
 drivers/net/wireless/b43/pio.c                    |   16 +++++-
 drivers/net/wireless/mwifiex/sta_ioctl.c          |    7 ++-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c |    1 -
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c       |    1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c       |   54 +++++++++++++++++=
---
 net/bluetooth/hci_core.c                          |    2 +-
 7 files changed, 70 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index d2348a5..a9c5ae7 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1843,6 +1843,9 @@ static void ath9k_sta_notify(struct ieee80211_hw *hw,
 	struct ath_softc *sc =3D hw->priv;
 	struct ath_node *an =3D (struct ath_node *) sta->drv_priv;
=20
+	if (!(sc->sc_flags & SC_OP_TXAGGR))
+		return;
+
 	switch (cmd) {
 	case STA_NOTIFY_SLEEP:
 		an->sleeping =3D true;
diff --git a/drivers/net/wireless/b43/pio.c b/drivers/net/wireless/b43/pio.c
index fcff923..279a53e 100644
--- a/drivers/net/wireless/b43/pio.c
+++ b/drivers/net/wireless/b43/pio.c
@@ -617,9 +617,19 @@ static bool pio_rx_frame(struct b43_pio_rxqueue *q)
 	const char *err_msg =3D NULL;
 	struct b43_rxhdr_fw4 *rxhdr =3D
 		(struct b43_rxhdr_fw4 *)wl->pio_scratchspace;
+	size_t rxhdr_size =3D sizeof(*rxhdr);
=20
 	BUILD_BUG_ON(sizeof(wl->pio_scratchspace) < sizeof(*rxhdr));
-	memset(rxhdr, 0, sizeof(*rxhdr));
+	switch (dev->fw.hdr_format) {
+	case B43_FW_HDR_410:
+	case B43_FW_HDR_351:
+		rxhdr_size -=3D sizeof(rxhdr->format_598) -
+			sizeof(rxhdr->format_351);
+		break;
+	case B43_FW_HDR_598:
+		break;
+	}
+	memset(rxhdr, 0, rxhdr_size);
=20
 	/* Check if we have data and wait for it to get ready. */
 	if (q->rev >=3D 8) {
@@ -657,11 +667,11 @@ data_ready:
=20
 	/* Get the preamble (RX header) */
 	if (q->rev >=3D 8) {
-		b43_block_read(dev, rxhdr, sizeof(*rxhdr),
+		b43_block_read(dev, rxhdr, rxhdr_size,
 			       q->mmio_base + B43_PIO8_RXDATA,
 			       sizeof(u32));
 	} else {
-		b43_block_read(dev, rxhdr, sizeof(*rxhdr),
+		b43_block_read(dev, rxhdr, rxhdr_size,
 			       q->mmio_base + B43_PIO_RXDATA,
 			       sizeof(u16));
 	}
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireles=
s/mwifiex/sta_ioctl.c
index ea4a29b..1679c25 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -55,9 +55,14 @@ int mwifiex_wait_queue_complete(struct mwifiex_adapter *=
adapter)
 {
 	bool cancel_flag =3D false;
 	int status =3D adapter->cmd_wait_q.status;
-	struct cmd_ctrl_node *cmd_queued =3D adapter->cmd_queued;
+	struct cmd_ctrl_node *cmd_queued;
=20
+	if (!adapter->cmd_queued)
+		return 0;
+
+	cmd_queued =3D adapter->cmd_queued;
 	adapter->cmd_queued =3D NULL;
+
 	dev_dbg(adapter->dev, "cmd pending\n");
 	atomic_inc(&adapter->cmd_pending);
=20
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/ne=
t/wireless/rtlwifi/rtl8192c/fw_common.c
index 950c65a..9fcb478 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -227,7 +227,6 @@ int rtl92c_download_fw(struct ieee80211_hw *hw)
 	u32 fwsize;
 	enum version_8192c version =3D rtlhal->version;
=20
-	pr_info("Loading firmware file %s\n", rtlpriv->cfg->fw_name);
 	if (!rtlhal->pfirmware)
 		return 1;
=20
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192ce/sw.c
index f2aa33d..acf9d14 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -186,6 +186,7 @@ int rtl92c_init_sw_vars(struct ieee80211_hw *hw)
 	memcpy(rtlpriv->rtlhal.pfirmware, firmware->data, firmware->size);
 	rtlpriv->rtlhal.fwsize =3D firmware->size;
 	release_firmware(firmware);
+	pr_info("rtl8192ce: Loaded firmware file %s\n", rtlpriv->cfg->fw_name);
=20
 	return 0;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/sw.c
index c244f2f..250fd9f 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -43,6 +43,8 @@
 #include "hw.h"
 #include <linux/vmalloc.h>
 #include <linux/module.h>
+#include <linux/atomic.h>
+#include <linux/types.h>
=20
 MODULE_AUTHOR("Georgia		<georgia@realtek.com>");
 MODULE_AUTHOR("Ziv Huang	<ziv_huang@realtek.com>");
@@ -51,6 +53,10 @@ MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Realtek 8192C/8188C 802.11n USB wireless");
 MODULE_FIRMWARE("rtlwifi/rtl8192cufw.bin");
=20
+static char *rtl8192cu_firmware;		/* pointer to firmware */
+static int firmware_size;
+static atomic_t usage_count;
+
 static int rtl92cu_init_sw_vars(struct ieee80211_hw *hw)
 {
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
@@ -62,12 +68,21 @@ static int rtl92cu_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->dm.disable_framebursting =3D 0;
 	rtlpriv->dm.thermalvalue =3D 0;
 	rtlpriv->dbg.global_debuglevel =3D rtlpriv->cfg->mod_params->debug;
-	rtlpriv->rtlhal.pfirmware =3D vmalloc(0x4000);
-	if (!rtlpriv->rtlhal.pfirmware) {
+
+	if (rtl8192cu_firmware) {
+		/* firmware already loaded - true for suspend/resume
+		 * and multiple instances of the device */
+		rtlpriv->rtlhal.pfirmware =3D rtl8192cu_firmware;
+		rtlpriv->rtlhal.fwsize =3D firmware_size;
+		return 0;
+	}
+	rtl8192cu_firmware =3D vzalloc(0x4000);
+	if (!rtl8192cu_firmware) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
 			 ("Can't alloc buffer for fw.\n"));
 		return 1;
 	}
+
 	/* request fw */
 	err =3D request_firmware(&firmware, rtlpriv->cfg->fw_name,
 			rtlpriv->io.dev);
@@ -82,9 +97,14 @@ static int rtl92cu_init_sw_vars(struct ieee80211_hw *hw)
 		release_firmware(firmware);
 		return 1;
 	}
-	memcpy(rtlpriv->rtlhal.pfirmware, firmware->data, firmware->size);
+	pr_info("rtl8192cu: Loaded firmware from file %s\n",
+		rtlpriv->cfg->fw_name);
+	memcpy(rtl8192cu_firmware, firmware->data, firmware->size);
+	firmware_size =3D firmware->size;
 	rtlpriv->rtlhal.fwsize =3D firmware->size;
+	rtlpriv->rtlhal.pfirmware =3D rtl8192cu_firmware;
 	release_firmware(firmware);
+	atomic_inc(&usage_count);
=20
 	return 0;
 }
@@ -93,12 +113,30 @@ static void rtl92cu_deinit_sw_vars(struct ieee80211_hw=
 *hw)
 {
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
=20
-	if (rtlpriv->rtlhal.pfirmware) {
-		vfree(rtlpriv->rtlhal.pfirmware);
+	atomic_dec(&usage_count);
+	if (!atomic_read(&usage_count) && rtlpriv->rtlhal.pfirmware) {
+		vfree(rtl8192cu_firmware);
+		rtl8192cu_firmware =3D NULL;
 		rtlpriv->rtlhal.pfirmware =3D NULL;
 	}
 }
=20
+#ifdef CONFIG_PM
+static int rtl8192cu_usb_suspend(struct usb_interface *pusb_intf,
+				 pm_message_t message)
+{
+	/* Increase usage_count to Save loaded fw across suspend/resume */
+	atomic_inc(&usage_count);
+	return 0;
+}
+
+static int rtl8192cu_usb_resume(struct usb_interface *pusb_intf)
+{
+	atomic_dec(&usage_count);	/* after resume, decrease usage count */
+	return 0;
+}
+#endif
+
 static struct rtl_hal_ops rtl8192cu_hal_ops =3D {
 	.init_sw_vars =3D rtl92cu_init_sw_vars,
 	.deinit_sw_vars =3D rtl92cu_deinit_sw_vars,
@@ -347,9 +385,9 @@ static struct usb_driver rtl8192cu_driver =3D {
 	.id_table =3D rtl8192c_usb_ids,
=20
 #ifdef CONFIG_PM
-	/* .suspend =3D rtl_usb_suspend, */
-	/* .resume =3D rtl_usb_resume, */
-	/* .reset_resume =3D rtl8192c_resume, */
+	.suspend =3D rtl8192cu_usb_suspend,
+	.resume =3D rtl8192cu_usb_resume,
+	.reset_resume =3D rtl8192cu_usb_resume,
 #endif /* CONFIG_PM */
 #ifdef CONFIG_AUTOSUSPEND
 	.supports_autosuspend =3D 1,
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index be84ae3..b84458d 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -613,7 +613,7 @@ static int hci_dev_do_close(struct hci_dev *hdev)
 	if (!test_bit(HCI_RAW, &hdev->flags)) {
 		set_bit(HCI_INIT, &hdev->flags);
 		__hci_request(hdev, hci_reset_req, 0,
-					msecs_to_jiffies(HCI_INIT_TIMEOUT));
+					msecs_to_jiffies(250));
 		clear_bit(HCI_INIT, &hdev->flags);
 	}
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--xXmbgvnjoT4axfJE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPBHcYAAoJEJctW/TcYTgG/icP/ipW/qNmKlJU11OJopw4JTpZ
naD9+kNe33G1uHDvSQMXh361tdvDZLIOcd57/FW39FEN+RybJGKkP250F1YxI8cd
E46OgI1x4B8OH0wmSDUX/M2RpXSirkT5itJqZOhfQjbg2AE2c4AHdWYFegYeAFog
2hy5RlAHYWOfkPpwS+IfBVG2QjucB25DkTy6gRxiu0isjtKFZX0rsp8UYlv4My0j
u4/qgbRVg7/nQkCPZP7qVJbjRxbxMaPuRRFWCNVl7MlZtSNJ3kgoTpEXYwmd1QnO
vIKLne3oTAT5NiTgc/hjSV+T5LWyzLMHZFCMPjnwgiTIvpvm1mCS7lHkxwKwk7zw
rks+840GXCcjwXFaV/gDTQH4/qjoLLL4vXGrA3E355GRb3/LUgxRuMCgStbEXZrL
iIF6ZHP8TlracQpBwKiRM7iDIPUY/C2q+HI7S9U1ZAodj2eb1Z0d+qWP4kfD7y5e
KxAd8PQJKtbLvrKrpUSQjISa6AW5xsktFaZ7McvBcWg8mH8qAvY8ybIU6wJKT8eV
4I8UDowmBqoH2mYgiNmTykfo+/6c/Zyv8+wVkM15uusoMzka4OdRGuaTQIi4BCO3
Cpvv3MwFKfx0F5F4qPtwZvNtJkuqBCQXzbwITgkITkxe3Q4GvxNJ3o+J1a9RhuWG
Z1wanfX/O0hcCr8rxjeN
=kCz8
-----END PGP SIGNATURE-----

--xXmbgvnjoT4axfJE--
