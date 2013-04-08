From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2013-04-08
Date: Mon, 8 Apr 2013 15:21:02 -0400
Message-ID: <20130408192102.GB25564@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9amGYk9869ThD9tj"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please consider this set of fixes for the 3.9 stream...

For the cfg80211 fix, Johannes says:

"I have another straggler for 3.9, adding locking forgotten in a previous
fix."

On top of that:

Bing Zhao provides an mwifiex fix to properly order a scan completion.

Franky Lin gives us a brcmfmac fix to fail at the firmware loading
stage if the nvram cannot be downloaded.

Gabor Juhos brings what at first looks like a rather big rt2x00 patch.
I think it is OK because it is really just reorganizing some code
within the rt2x00 driver in order to fix a build failure.

Hante Meuleman offers a trio of brcmfmac fixes related to running in
AP mode.

Robert Shade sends an ath9k fix to reenable interrupts even if a
channel change fails.

Tim Gardner gives us an rt2x00 fix to cut-down on some log SPAM.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit b50b72de2f2feed4adfbd8e18610a393b5a04cc7:

  net: mvneta: enable features before registering the driver (2013-04-08 12=
:16:38 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 64e5751918b4d03015b185750a46ecd050e1ce77:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-04-08 14:26:57 -0400)

----------------------------------------------------------------

Artem Savkov (1):
      cfg80211: sched_scan_mtx lock in cfg80211_conn_work()

Bing Zhao (1):
      mwifiex: complete last internal scan

Franky Lin (1):
      brcmfmac: do not proceed if fail to download nvram to dongle

Gabor Juhos (1):
      rt2x00: rt2x00pci: fix build error on Ralink RT3x5x SoCs

Hante Meuleman (3):
      brcmfmac: fix tkip mic tx/rx ap swap bug.
      brcmfmac: fix stopping AP.
      brcmfmac: fix returning cipher_suite for get_key operation.

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Robert Shade (1):
      ath9k: Re-enable interrupts after a channel change failure

Tim Gardner (1):
      rt2x00: rt2x00pci_regbusy_read() - only print register access failure=
 once

 drivers/net/wireless/ath/ath9k/main.c              |   4 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   6 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  46 +++--
 drivers/net/wireless/mwifiex/scan.c                |  11 +-
 drivers/net/wireless/rt2x00/Kconfig                |   7 +
 drivers/net/wireless/rt2x00/Makefile               |   1 +
 drivers/net/wireless/rt2x00/rt2400pci.c            |   1 +
 drivers/net/wireless/rt2x00/rt2500pci.c            |   1 +
 drivers/net/wireless/rt2x00/rt2800pci.c            |   1 +
 drivers/net/wireless/rt2x00/rt2x00mmio.c           | 216 +++++++++++++++++=
++++
 drivers/net/wireless/rt2x00/rt2x00mmio.h           | 119 ++++++++++++
 drivers/net/wireless/rt2x00/rt2x00pci.c            | 176 -----------------
 drivers/net/wireless/rt2x00/rt2x00pci.h            |  88 ---------
 drivers/net/wireless/rt2x00/rt61pci.c              |   1 +
 net/wireless/sme.c                                 |   2 +
 15 files changed, 390 insertions(+), 290 deletions(-)
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00mmio.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00mmio.h

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 6e66f9c..988372d 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -280,6 +280,10 @@ static int ath_reset_internal(struct ath_softc *sc, st=
ruct ath9k_channel *hchan)
 	if (r) {
 		ath_err(common,
 			"Unable to reset channel, reset status %d\n", r);
+
+		ath9k_hw_enable_interrupts(ah);
+		ath9k_queue_reset(sc, RESET_TYPE_BB_HANG);
+
 		goto out;
 	}
=20
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/n=
et/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 4469321..35fc68b 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -3317,15 +3317,15 @@ static int _brcmf_sdbrcm_download_firmware(struct b=
rcmf_sdio *bus)
 		goto err;
 	}
=20
-	/* External image takes precedence if specified */
 	if (brcmf_sdbrcm_download_code_file(bus)) {
 		brcmf_err("dongle image file download failed\n");
 		goto err;
 	}
=20
-	/* External nvram takes precedence if specified */
-	if (brcmf_sdbrcm_download_nvram(bus))
+	if (brcmf_sdbrcm_download_nvram(bus)) {
 		brcmf_err("dongle nvram file download failed\n");
+		goto err;
+	}
=20
 	/* Take arm out of reset */
 	if (brcmf_sdbrcm_download_state(bus, false)) {
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 2af9c0f..ec46fff 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -1891,8 +1891,10 @@ static s32
 brcmf_add_keyext(struct wiphy *wiphy, struct net_device *ndev,
 	      u8 key_idx, const u8 *mac_addr, struct key_params *params)
 {
+	struct brcmf_if *ifp =3D netdev_priv(ndev);
 	struct brcmf_wsec_key key;
 	s32 err =3D 0;
+	u8 keybuf[8];
=20
 	memset(&key, 0, sizeof(key));
 	key.index =3D (u32) key_idx;
@@ -1916,8 +1918,9 @@ brcmf_add_keyext(struct wiphy *wiphy, struct net_devi=
ce *ndev,
 		brcmf_dbg(CONN, "Setting the key index %d\n", key.index);
 		memcpy(key.data, params->key, key.len);
=20
-		if (params->cipher =3D=3D WLAN_CIPHER_SUITE_TKIP) {
-			u8 keybuf[8];
+		if ((ifp->vif->mode !=3D WL_MODE_AP) &&
+		    (params->cipher =3D=3D WLAN_CIPHER_SUITE_TKIP)) {
+			brcmf_dbg(CONN, "Swapping RX/TX MIC key\n");
 			memcpy(keybuf, &key.data[24], sizeof(keybuf));
 			memcpy(&key.data[24], &key.data[16], sizeof(keybuf));
 			memcpy(&key.data[16], keybuf, sizeof(keybuf));
@@ -2013,7 +2016,7 @@ brcmf_cfg80211_add_key(struct wiphy *wiphy, struct ne=
t_device *ndev,
 		break;
 	case WLAN_CIPHER_SUITE_TKIP:
 		if (ifp->vif->mode !=3D WL_MODE_AP) {
-			brcmf_dbg(CONN, "Swapping key\n");
+			brcmf_dbg(CONN, "Swapping RX/TX MIC key\n");
 			memcpy(keybuf, &key.data[24], sizeof(keybuf));
 			memcpy(&key.data[24], &key.data[16], sizeof(keybuf));
 			memcpy(&key.data[16], keybuf, sizeof(keybuf));
@@ -2118,8 +2121,7 @@ brcmf_cfg80211_get_key(struct wiphy *wiphy, struct ne=
t_device *ndev,
 		err =3D -EAGAIN;
 		goto done;
 	}
-	switch (wsec & ~SES_OW_ENABLED) {
-	case WEP_ENABLED:
+	if (wsec & WEP_ENABLED) {
 		sec =3D &profile->sec;
 		if (sec->cipher_pairwise & WLAN_CIPHER_SUITE_WEP40) {
 			params.cipher =3D WLAN_CIPHER_SUITE_WEP40;
@@ -2128,16 +2130,13 @@ brcmf_cfg80211_get_key(struct wiphy *wiphy, struct =
net_device *ndev,
 			params.cipher =3D WLAN_CIPHER_SUITE_WEP104;
 			brcmf_dbg(CONN, "WLAN_CIPHER_SUITE_WEP104\n");
 		}
-		break;
-	case TKIP_ENABLED:
+	} else if (wsec & TKIP_ENABLED) {
 		params.cipher =3D WLAN_CIPHER_SUITE_TKIP;
 		brcmf_dbg(CONN, "WLAN_CIPHER_SUITE_TKIP\n");
-		break;
-	case AES_ENABLED:
+	} else if (wsec & AES_ENABLED) {
 		params.cipher =3D WLAN_CIPHER_SUITE_AES_CMAC;
 		brcmf_dbg(CONN, "WLAN_CIPHER_SUITE_AES_CMAC\n");
-		break;
-	default:
+	} else  {
 		brcmf_err("Invalid algo (0x%x)\n", wsec);
 		err =3D -EINVAL;
 		goto done;
@@ -3824,8 +3823,9 @@ exit:
 static int brcmf_cfg80211_stop_ap(struct wiphy *wiphy, struct net_device *=
ndev)
 {
 	struct brcmf_if *ifp =3D netdev_priv(ndev);
-	s32 err =3D -EPERM;
+	s32 err;
 	struct brcmf_fil_bss_enable_le bss_enable;
+	struct brcmf_join_params join_params;
=20
 	brcmf_dbg(TRACE, "Enter\n");
=20
@@ -3833,16 +3833,21 @@ static int brcmf_cfg80211_stop_ap(struct wiphy *wip=
hy, struct net_device *ndev)
 		/* Due to most likely deauths outstanding we sleep */
 		/* first to make sure they get processed by fw. */
 		msleep(400);
-		err =3D brcmf_fil_cmd_int_set(ifp, BRCMF_C_SET_AP, 0);
-		if (err < 0) {
-			brcmf_err("setting AP mode failed %d\n", err);
-			goto exit;
-		}
+
+		memset(&join_params, 0, sizeof(join_params));
+		err =3D brcmf_fil_cmd_data_set(ifp, BRCMF_C_SET_SSID,
+					     &join_params, sizeof(join_params));
+		if (err < 0)
+			brcmf_err("SET SSID error (%d)\n", err);
 		err =3D brcmf_fil_cmd_int_set(ifp, BRCMF_C_UP, 0);
-		if (err < 0) {
+		if (err < 0)
 			brcmf_err("BRCMF_C_UP error %d\n", err);
-			goto exit;
-		}
+		err =3D brcmf_fil_cmd_int_set(ifp, BRCMF_C_SET_AP, 0);
+		if (err < 0)
+			brcmf_err("setting AP mode failed %d\n", err);
+		err =3D brcmf_fil_cmd_int_set(ifp, BRCMF_C_SET_INFRA, 0);
+		if (err < 0)
+			brcmf_err("setting INFRA mode failed %d\n", err);
 	} else {
 		bss_enable.bsscfg_idx =3D cpu_to_le32(ifp->bssidx);
 		bss_enable.enable =3D cpu_to_le32(0);
@@ -3855,7 +3860,6 @@ static int brcmf_cfg80211_stop_ap(struct wiphy *wiphy=
, struct net_device *ndev)
 	set_bit(BRCMF_VIF_STATUS_AP_CREATING, &ifp->vif->sme_state);
 	clear_bit(BRCMF_VIF_STATUS_AP_CREATED, &ifp->vif->sme_state);
=20
-exit:
 	return err;
 }
=20
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwi=
fiex/scan.c
index d215b4d..e7f6dea 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -1393,8 +1393,10 @@ int mwifiex_scan_networks(struct mwifiex_private *pr=
iv,
 			queue_work(adapter->workqueue, &adapter->main_work);
=20
 			/* Perform internal scan synchronously */
-			if (!priv->scan_request)
+			if (!priv->scan_request) {
+				dev_dbg(adapter->dev, "wait internal scan\n");
 				mwifiex_wait_queue_complete(adapter, cmd_node);
+			}
 		} else {
 			spin_unlock_irqrestore(&adapter->scan_pending_q_lock,
 					       flags);
@@ -1793,7 +1795,12 @@ check_next_scan:
 		/* Need to indicate IOCTL complete */
 		if (adapter->curr_cmd->wait_q_enabled) {
 			adapter->cmd_wait_q.status =3D 0;
-			mwifiex_complete_cmd(adapter, adapter->curr_cmd);
+			if (!priv->scan_request) {
+				dev_dbg(adapter->dev,
+					"complete internal scan\n");
+				mwifiex_complete_cmd(adapter,
+						     adapter->curr_cmd);
+			}
 		}
 		if (priv->report_scan_result)
 			priv->report_scan_result =3D false;
diff --git a/drivers/net/wireless/rt2x00/Kconfig b/drivers/net/wireless/rt2=
x00/Kconfig
index 2bf4efa..76cd47e 100644
--- a/drivers/net/wireless/rt2x00/Kconfig
+++ b/drivers/net/wireless/rt2x00/Kconfig
@@ -20,6 +20,7 @@ if RT2X00
 config RT2400PCI
 	tristate "Ralink rt2400 (PCI/PCMCIA) support"
 	depends on PCI
+	select RT2X00_LIB_MMIO
 	select RT2X00_LIB_PCI
 	select EEPROM_93CX6
 	---help---
@@ -31,6 +32,7 @@ config RT2400PCI
 config RT2500PCI
 	tristate "Ralink rt2500 (PCI/PCMCIA) support"
 	depends on PCI
+	select RT2X00_LIB_MMIO
 	select RT2X00_LIB_PCI
 	select EEPROM_93CX6
 	---help---
@@ -43,6 +45,7 @@ config RT61PCI
 	tristate "Ralink rt2501/rt61 (PCI/PCMCIA) support"
 	depends on PCI
 	select RT2X00_LIB_PCI
+	select RT2X00_LIB_MMIO
 	select RT2X00_LIB_FIRMWARE
 	select RT2X00_LIB_CRYPTO
 	select CRC_ITU_T
@@ -57,6 +60,7 @@ config RT2800PCI
 	tristate "Ralink rt27xx/rt28xx/rt30xx (PCI/PCIe/PCMCIA) support"
 	depends on PCI || SOC_RT288X || SOC_RT305X
 	select RT2800_LIB
+	select RT2X00_LIB_MMIO
 	select RT2X00_LIB_PCI if PCI
 	select RT2X00_LIB_SOC if SOC_RT288X || SOC_RT305X
 	select RT2X00_LIB_FIRMWARE
@@ -185,6 +189,9 @@ endif
 config RT2800_LIB
 	tristate
=20
+config RT2X00_LIB_MMIO
+	tristate
+
 config RT2X00_LIB_PCI
 	tristate
 	select RT2X00_LIB
diff --git a/drivers/net/wireless/rt2x00/Makefile b/drivers/net/wireless/rt=
2x00/Makefile
index 349d5b8..f069d8b 100644
--- a/drivers/net/wireless/rt2x00/Makefile
+++ b/drivers/net/wireless/rt2x00/Makefile
@@ -9,6 +9,7 @@ rt2x00lib-$(CONFIG_RT2X00_LIB_FIRMWARE)	+=3D rt2x00firmware=
=2Eo
 rt2x00lib-$(CONFIG_RT2X00_LIB_LEDS)	+=3D rt2x00leds.o
=20
 obj-$(CONFIG_RT2X00_LIB)		+=3D rt2x00lib.o
+obj-$(CONFIG_RT2X00_LIB_MMIO)		+=3D rt2x00mmio.o
 obj-$(CONFIG_RT2X00_LIB_PCI)		+=3D rt2x00pci.o
 obj-$(CONFIG_RT2X00_LIB_SOC)		+=3D rt2x00soc.o
 obj-$(CONFIG_RT2X00_LIB_USB)		+=3D rt2x00usb.o
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless=
/rt2x00/rt2400pci.c
index 221beaa..dcfb54e 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -34,6 +34,7 @@
 #include <linux/slab.h>
=20
 #include "rt2x00.h"
+#include "rt2x00mmio.h"
 #include "rt2x00pci.h"
 #include "rt2400pci.h"
=20
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless=
/rt2x00/rt2500pci.c
index 39edc59..e1d2dc9 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -34,6 +34,7 @@
 #include <linux/slab.h>
=20
 #include "rt2x00.h"
+#include "rt2x00mmio.h"
 #include "rt2x00pci.h"
 #include "rt2500pci.h"
=20
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless=
/rt2x00/rt2800pci.c
index ded73da..ba5a056 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -41,6 +41,7 @@
 #include <linux/eeprom_93cx6.h>
=20
 #include "rt2x00.h"
+#include "rt2x00mmio.h"
 #include "rt2x00pci.h"
 #include "rt2x00soc.h"
 #include "rt2800lib.h"
diff --git a/drivers/net/wireless/rt2x00/rt2x00mmio.c b/drivers/net/wireles=
s/rt2x00/rt2x00mmio.c
new file mode 100644
index 0000000..d84a680
--- /dev/null
+++ b/drivers/net/wireless/rt2x00/rt2x00mmio.c
@@ -0,0 +1,216 @@
+/*
+	Copyright (C) 2004 - 2009 Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+	<http://rt2x00.serialmonkey.com>
+
+	This program is free software; you can redistribute it and/or modify
+	it under the terms of the GNU General Public License as published by
+	the Free Software Foundation; either version 2 of the License, or
+	(at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	You should have received a copy of the GNU General Public License
+	along with this program; if not, write to the
+	Free Software Foundation, Inc.,
+	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+/*
+	Module: rt2x00mmio
+	Abstract: rt2x00 generic mmio device routines.
+ */
+
+#include <linux/dma-mapping.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+
+#include "rt2x00.h"
+#include "rt2x00mmio.h"
+
+/*
+ * Register access.
+ */
+int rt2x00pci_regbusy_read(struct rt2x00_dev *rt2x00dev,
+			   const unsigned int offset,
+			   const struct rt2x00_field32 field,
+			   u32 *reg)
+{
+	unsigned int i;
+
+	if (!test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags))
+		return 0;
+
+	for (i =3D 0; i < REGISTER_BUSY_COUNT; i++) {
+		rt2x00pci_register_read(rt2x00dev, offset, reg);
+		if (!rt2x00_get_field32(*reg, field))
+			return 1;
+		udelay(REGISTER_BUSY_DELAY);
+	}
+
+	printk_once(KERN_ERR "%s() Indirect register access failed: "
+	      "offset=3D0x%.08x, value=3D0x%.08x\n", __func__, offset, *reg);
+	*reg =3D ~0;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rt2x00pci_regbusy_read);
+
+bool rt2x00pci_rxdone(struct rt2x00_dev *rt2x00dev)
+{
+	struct data_queue *queue =3D rt2x00dev->rx;
+	struct queue_entry *entry;
+	struct queue_entry_priv_pci *entry_priv;
+	struct skb_frame_desc *skbdesc;
+	int max_rx =3D 16;
+
+	while (--max_rx) {
+		entry =3D rt2x00queue_get_entry(queue, Q_INDEX);
+		entry_priv =3D entry->priv_data;
+
+		if (rt2x00dev->ops->lib->get_entry_state(entry))
+			break;
+
+		/*
+		 * Fill in desc fields of the skb descriptor
+		 */
+		skbdesc =3D get_skb_frame_desc(entry->skb);
+		skbdesc->desc =3D entry_priv->desc;
+		skbdesc->desc_len =3D entry->queue->desc_size;
+
+		/*
+		 * DMA is already done, notify rt2x00lib that
+		 * it finished successfully.
+		 */
+		rt2x00lib_dmastart(entry);
+		rt2x00lib_dmadone(entry);
+
+		/*
+		 * Send the frame to rt2x00lib for further processing.
+		 */
+		rt2x00lib_rxdone(entry, GFP_ATOMIC);
+	}
+
+	return !max_rx;
+}
+EXPORT_SYMBOL_GPL(rt2x00pci_rxdone);
+
+void rt2x00pci_flush_queue(struct data_queue *queue, bool drop)
+{
+	unsigned int i;
+
+	for (i =3D 0; !rt2x00queue_empty(queue) && i < 10; i++)
+		msleep(10);
+}
+EXPORT_SYMBOL_GPL(rt2x00pci_flush_queue);
+
+/*
+ * Device initialization handlers.
+ */
+static int rt2x00pci_alloc_queue_dma(struct rt2x00_dev *rt2x00dev,
+				     struct data_queue *queue)
+{
+	struct queue_entry_priv_pci *entry_priv;
+	void *addr;
+	dma_addr_t dma;
+	unsigned int i;
+
+	/*
+	 * Allocate DMA memory for descriptor and buffer.
+	 */
+	addr =3D dma_alloc_coherent(rt2x00dev->dev,
+				  queue->limit * queue->desc_size,
+				  &dma, GFP_KERNEL);
+	if (!addr)
+		return -ENOMEM;
+
+	memset(addr, 0, queue->limit * queue->desc_size);
+
+	/*
+	 * Initialize all queue entries to contain valid addresses.
+	 */
+	for (i =3D 0; i < queue->limit; i++) {
+		entry_priv =3D queue->entries[i].priv_data;
+		entry_priv->desc =3D addr + i * queue->desc_size;
+		entry_priv->desc_dma =3D dma + i * queue->desc_size;
+	}
+
+	return 0;
+}
+
+static void rt2x00pci_free_queue_dma(struct rt2x00_dev *rt2x00dev,
+				     struct data_queue *queue)
+{
+	struct queue_entry_priv_pci *entry_priv =3D
+	    queue->entries[0].priv_data;
+
+	if (entry_priv->desc)
+		dma_free_coherent(rt2x00dev->dev,
+				  queue->limit * queue->desc_size,
+				  entry_priv->desc, entry_priv->desc_dma);
+	entry_priv->desc =3D NULL;
+}
+
+int rt2x00pci_initialize(struct rt2x00_dev *rt2x00dev)
+{
+	struct data_queue *queue;
+	int status;
+
+	/*
+	 * Allocate DMA
+	 */
+	queue_for_each(rt2x00dev, queue) {
+		status =3D rt2x00pci_alloc_queue_dma(rt2x00dev, queue);
+		if (status)
+			goto exit;
+	}
+
+	/*
+	 * Register interrupt handler.
+	 */
+	status =3D request_irq(rt2x00dev->irq,
+			     rt2x00dev->ops->lib->irq_handler,
+			     IRQF_SHARED, rt2x00dev->name, rt2x00dev);
+	if (status) {
+		ERROR(rt2x00dev, "IRQ %d allocation failed (error %d).\n",
+		      rt2x00dev->irq, status);
+		goto exit;
+	}
+
+	return 0;
+
+exit:
+	queue_for_each(rt2x00dev, queue)
+		rt2x00pci_free_queue_dma(rt2x00dev, queue);
+
+	return status;
+}
+EXPORT_SYMBOL_GPL(rt2x00pci_initialize);
+
+void rt2x00pci_uninitialize(struct rt2x00_dev *rt2x00dev)
+{
+	struct data_queue *queue;
+
+	/*
+	 * Free irq line.
+	 */
+	free_irq(rt2x00dev->irq, rt2x00dev);
+
+	/*
+	 * Free DMA
+	 */
+	queue_for_each(rt2x00dev, queue)
+		rt2x00pci_free_queue_dma(rt2x00dev, queue);
+}
+EXPORT_SYMBOL_GPL(rt2x00pci_uninitialize);
+
+/*
+ * rt2x00mmio module information.
+ */
+MODULE_AUTHOR(DRV_PROJECT);
+MODULE_VERSION(DRV_VERSION);
+MODULE_DESCRIPTION("rt2x00 mmio library");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/wireless/rt2x00/rt2x00mmio.h b/drivers/net/wireles=
s/rt2x00/rt2x00mmio.h
new file mode 100644
index 0000000..4ecaf60
--- /dev/null
+++ b/drivers/net/wireless/rt2x00/rt2x00mmio.h
@@ -0,0 +1,119 @@
+/*
+	Copyright (C) 2004 - 2009 Ivo van Doorn <IvDoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+	<http://rt2x00.serialmonkey.com>
+
+	This program is free software; you can redistribute it and/or modify
+	it under the terms of the GNU General Public License as published by
+	the Free Software Foundation; either version 2 of the License, or
+	(at your option) any later version.
+
+	This program is distributed in the hope that it will be useful,
+	but WITHOUT ANY WARRANTY; without even the implied warranty of
+	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+	GNU General Public License for more details.
+
+	You should have received a copy of the GNU General Public License
+	along with this program; if not, write to the
+	Free Software Foundation, Inc.,
+	59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
+ */
+
+/*
+	Module: rt2x00mmio
+	Abstract: Data structures for the rt2x00mmio module.
+ */
+
+#ifndef RT2X00MMIO_H
+#define RT2X00MMIO_H
+
+#include <linux/io.h>
+
+/*
+ * Register access.
+ */
+static inline void rt2x00pci_register_read(struct rt2x00_dev *rt2x00dev,
+					   const unsigned int offset,
+					   u32 *value)
+{
+	*value =3D readl(rt2x00dev->csr.base + offset);
+}
+
+static inline void rt2x00pci_register_multiread(struct rt2x00_dev *rt2x00d=
ev,
+						const unsigned int offset,
+						void *value, const u32 length)
+{
+	memcpy_fromio(value, rt2x00dev->csr.base + offset, length);
+}
+
+static inline void rt2x00pci_register_write(struct rt2x00_dev *rt2x00dev,
+					    const unsigned int offset,
+					    u32 value)
+{
+	writel(value, rt2x00dev->csr.base + offset);
+}
+
+static inline void rt2x00pci_register_multiwrite(struct rt2x00_dev *rt2x00=
dev,
+						 const unsigned int offset,
+						 const void *value,
+						 const u32 length)
+{
+	__iowrite32_copy(rt2x00dev->csr.base + offset, value, length >> 2);
+}
+
+/**
+ * rt2x00pci_regbusy_read - Read from register with busy check
+ * @rt2x00dev: Device pointer, see &struct rt2x00_dev.
+ * @offset: Register offset
+ * @field: Field to check if register is busy
+ * @reg: Pointer to where register contents should be stored
+ *
+ * This function will read the given register, and checks if the
+ * register is busy. If it is, it will sleep for a couple of
+ * microseconds before reading the register again. If the register
+ * is not read after a certain timeout, this function will return
+ * FALSE.
+ */
+int rt2x00pci_regbusy_read(struct rt2x00_dev *rt2x00dev,
+			   const unsigned int offset,
+			   const struct rt2x00_field32 field,
+			   u32 *reg);
+
+/**
+ * struct queue_entry_priv_pci: Per entry PCI specific information
+ *
+ * @desc: Pointer to device descriptor
+ * @desc_dma: DMA pointer to &desc.
+ * @data: Pointer to device's entry memory.
+ * @data_dma: DMA pointer to &data.
+ */
+struct queue_entry_priv_pci {
+	__le32 *desc;
+	dma_addr_t desc_dma;
+};
+
+/**
+ * rt2x00pci_rxdone - Handle RX done events
+ * @rt2x00dev: Device pointer, see &struct rt2x00_dev.
+ *
+ * Returns true if there are still rx frames pending and false if all
+ * pending rx frames were processed.
+ */
+bool rt2x00pci_rxdone(struct rt2x00_dev *rt2x00dev);
+
+/**
+ * rt2x00pci_flush_queue - Flush data queue
+ * @queue: Data queue to stop
+ * @drop: True to drop all pending frames.
+ *
+ * This will wait for a maximum of 100ms, waiting for the queues
+ * to become empty.
+ */
+void rt2x00pci_flush_queue(struct data_queue *queue, bool drop);
+
+/*
+ * Device initialization handlers.
+ */
+int rt2x00pci_initialize(struct rt2x00_dev *rt2x00dev);
+void rt2x00pci_uninitialize(struct rt2x00_dev *rt2x00dev);
+
+#endif /* RT2X00MMIO_H */
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless=
/rt2x00/rt2x00pci.c
index a0c8cae..e87865e 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -33,182 +33,6 @@
 #include "rt2x00pci.h"
=20
 /*
- * Register access.
- */
-int rt2x00pci_regbusy_read(struct rt2x00_dev *rt2x00dev,
-			   const unsigned int offset,
-			   const struct rt2x00_field32 field,
-			   u32 *reg)
-{
-	unsigned int i;
-
-	if (!test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags))
-		return 0;
-
-	for (i =3D 0; i < REGISTER_BUSY_COUNT; i++) {
-		rt2x00pci_register_read(rt2x00dev, offset, reg);
-		if (!rt2x00_get_field32(*reg, field))
-			return 1;
-		udelay(REGISTER_BUSY_DELAY);
-	}
-
-	ERROR(rt2x00dev, "Indirect register access failed: "
-	      "offset=3D0x%.08x, value=3D0x%.08x\n", offset, *reg);
-	*reg =3D ~0;
-
-	return 0;
-}
-EXPORT_SYMBOL_GPL(rt2x00pci_regbusy_read);
-
-bool rt2x00pci_rxdone(struct rt2x00_dev *rt2x00dev)
-{
-	struct data_queue *queue =3D rt2x00dev->rx;
-	struct queue_entry *entry;
-	struct queue_entry_priv_pci *entry_priv;
-	struct skb_frame_desc *skbdesc;
-	int max_rx =3D 16;
-
-	while (--max_rx) {
-		entry =3D rt2x00queue_get_entry(queue, Q_INDEX);
-		entry_priv =3D entry->priv_data;
-
-		if (rt2x00dev->ops->lib->get_entry_state(entry))
-			break;
-
-		/*
-		 * Fill in desc fields of the skb descriptor
-		 */
-		skbdesc =3D get_skb_frame_desc(entry->skb);
-		skbdesc->desc =3D entry_priv->desc;
-		skbdesc->desc_len =3D entry->queue->desc_size;
-
-		/*
-		 * DMA is already done, notify rt2x00lib that
-		 * it finished successfully.
-		 */
-		rt2x00lib_dmastart(entry);
-		rt2x00lib_dmadone(entry);
-
-		/*
-		 * Send the frame to rt2x00lib for further processing.
-		 */
-		rt2x00lib_rxdone(entry, GFP_ATOMIC);
-	}
-
-	return !max_rx;
-}
-EXPORT_SYMBOL_GPL(rt2x00pci_rxdone);
-
-void rt2x00pci_flush_queue(struct data_queue *queue, bool drop)
-{
-	unsigned int i;
-
-	for (i =3D 0; !rt2x00queue_empty(queue) && i < 10; i++)
-		msleep(10);
-}
-EXPORT_SYMBOL_GPL(rt2x00pci_flush_queue);
-
-/*
- * Device initialization handlers.
- */
-static int rt2x00pci_alloc_queue_dma(struct rt2x00_dev *rt2x00dev,
-				     struct data_queue *queue)
-{
-	struct queue_entry_priv_pci *entry_priv;
-	void *addr;
-	dma_addr_t dma;
-	unsigned int i;
-
-	/*
-	 * Allocate DMA memory for descriptor and buffer.
-	 */
-	addr =3D dma_alloc_coherent(rt2x00dev->dev,
-				  queue->limit * queue->desc_size,
-				  &dma, GFP_KERNEL);
-	if (!addr)
-		return -ENOMEM;
-
-	memset(addr, 0, queue->limit * queue->desc_size);
-
-	/*
-	 * Initialize all queue entries to contain valid addresses.
-	 */
-	for (i =3D 0; i < queue->limit; i++) {
-		entry_priv =3D queue->entries[i].priv_data;
-		entry_priv->desc =3D addr + i * queue->desc_size;
-		entry_priv->desc_dma =3D dma + i * queue->desc_size;
-	}
-
-	return 0;
-}
-
-static void rt2x00pci_free_queue_dma(struct rt2x00_dev *rt2x00dev,
-				     struct data_queue *queue)
-{
-	struct queue_entry_priv_pci *entry_priv =3D
-	    queue->entries[0].priv_data;
-
-	if (entry_priv->desc)
-		dma_free_coherent(rt2x00dev->dev,
-				  queue->limit * queue->desc_size,
-				  entry_priv->desc, entry_priv->desc_dma);
-	entry_priv->desc =3D NULL;
-}
-
-int rt2x00pci_initialize(struct rt2x00_dev *rt2x00dev)
-{
-	struct data_queue *queue;
-	int status;
-
-	/*
-	 * Allocate DMA
-	 */
-	queue_for_each(rt2x00dev, queue) {
-		status =3D rt2x00pci_alloc_queue_dma(rt2x00dev, queue);
-		if (status)
-			goto exit;
-	}
-
-	/*
-	 * Register interrupt handler.
-	 */
-	status =3D request_irq(rt2x00dev->irq,
-			     rt2x00dev->ops->lib->irq_handler,
-			     IRQF_SHARED, rt2x00dev->name, rt2x00dev);
-	if (status) {
-		ERROR(rt2x00dev, "IRQ %d allocation failed (error %d).\n",
-		      rt2x00dev->irq, status);
-		goto exit;
-	}
-
-	return 0;
-
-exit:
-	queue_for_each(rt2x00dev, queue)
-		rt2x00pci_free_queue_dma(rt2x00dev, queue);
-
-	return status;
-}
-EXPORT_SYMBOL_GPL(rt2x00pci_initialize);
-
-void rt2x00pci_uninitialize(struct rt2x00_dev *rt2x00dev)
-{
-	struct data_queue *queue;
-
-	/*
-	 * Free irq line.
-	 */
-	free_irq(rt2x00dev->irq, rt2x00dev);
-
-	/*
-	 * Free DMA
-	 */
-	queue_for_each(rt2x00dev, queue)
-		rt2x00pci_free_queue_dma(rt2x00dev, queue);
-}
-EXPORT_SYMBOL_GPL(rt2x00pci_uninitialize);
-
-/*
  * PCI driver handlers.
  */
 static void rt2x00pci_free_reg(struct rt2x00_dev *rt2x00dev)
diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.h b/drivers/net/wireless=
/rt2x00/rt2x00pci.h
index e2c99f2..60d90b2 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.h
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.h
@@ -36,94 +36,6 @@
 #define PCI_DEVICE_DATA(__ops)	.driver_data =3D (kernel_ulong_t)(__ops)
=20
 /*
- * Register access.
- */
-static inline void rt2x00pci_register_read(struct rt2x00_dev *rt2x00dev,
-					   const unsigned int offset,
-					   u32 *value)
-{
-	*value =3D readl(rt2x00dev->csr.base + offset);
-}
-
-static inline void rt2x00pci_register_multiread(struct rt2x00_dev *rt2x00d=
ev,
-						const unsigned int offset,
-						void *value, const u32 length)
-{
-	memcpy_fromio(value, rt2x00dev->csr.base + offset, length);
-}
-
-static inline void rt2x00pci_register_write(struct rt2x00_dev *rt2x00dev,
-					    const unsigned int offset,
-					    u32 value)
-{
-	writel(value, rt2x00dev->csr.base + offset);
-}
-
-static inline void rt2x00pci_register_multiwrite(struct rt2x00_dev *rt2x00=
dev,
-						 const unsigned int offset,
-						 const void *value,
-						 const u32 length)
-{
-	__iowrite32_copy(rt2x00dev->csr.base + offset, value, length >> 2);
-}
-
-/**
- * rt2x00pci_regbusy_read - Read from register with busy check
- * @rt2x00dev: Device pointer, see &struct rt2x00_dev.
- * @offset: Register offset
- * @field: Field to check if register is busy
- * @reg: Pointer to where register contents should be stored
- *
- * This function will read the given register, and checks if the
- * register is busy. If it is, it will sleep for a couple of
- * microseconds before reading the register again. If the register
- * is not read after a certain timeout, this function will return
- * FALSE.
- */
-int rt2x00pci_regbusy_read(struct rt2x00_dev *rt2x00dev,
-			   const unsigned int offset,
-			   const struct rt2x00_field32 field,
-			   u32 *reg);
-
-/**
- * struct queue_entry_priv_pci: Per entry PCI specific information
- *
- * @desc: Pointer to device descriptor
- * @desc_dma: DMA pointer to &desc.
- * @data: Pointer to device's entry memory.
- * @data_dma: DMA pointer to &data.
- */
-struct queue_entry_priv_pci {
-	__le32 *desc;
-	dma_addr_t desc_dma;
-};
-
-/**
- * rt2x00pci_rxdone - Handle RX done events
- * @rt2x00dev: Device pointer, see &struct rt2x00_dev.
- *
- * Returns true if there are still rx frames pending and false if all
- * pending rx frames were processed.
- */
-bool rt2x00pci_rxdone(struct rt2x00_dev *rt2x00dev);
-
-/**
- * rt2x00pci_flush_queue - Flush data queue
- * @queue: Data queue to stop
- * @drop: True to drop all pending frames.
- *
- * This will wait for a maximum of 100ms, waiting for the queues
- * to become empty.
- */
-void rt2x00pci_flush_queue(struct data_queue *queue, bool drop);
-
-/*
- * Device initialization handlers.
- */
-int rt2x00pci_initialize(struct rt2x00_dev *rt2x00dev);
-void rt2x00pci_uninitialize(struct rt2x00_dev *rt2x00dev);
-
-/*
  * PCI driver handlers.
  */
 int rt2x00pci_probe(struct pci_dev *pci_dev, const struct rt2x00_ops *ops);
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/r=
t2x00/rt61pci.c
index f95792c..9e3c8ff 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -35,6 +35,7 @@
 #include <linux/eeprom_93cx6.h>
=20
 #include "rt2x00.h"
+#include "rt2x00mmio.h"
 #include "rt2x00pci.h"
 #include "rt61pci.h"
=20
diff --git a/net/wireless/sme.c b/net/wireless/sme.c
index 09d994d..482c70e 100644
--- a/net/wireless/sme.c
+++ b/net/wireless/sme.c
@@ -224,6 +224,7 @@ void cfg80211_conn_work(struct work_struct *work)
 	rtnl_lock();
 	cfg80211_lock_rdev(rdev);
 	mutex_lock(&rdev->devlist_mtx);
+	mutex_lock(&rdev->sched_scan_mtx);
=20
 	list_for_each_entry(wdev, &rdev->wdev_list, list) {
 		wdev_lock(wdev);
@@ -248,6 +249,7 @@ void cfg80211_conn_work(struct work_struct *work)
 		wdev_unlock(wdev);
 	}
=20
+	mutex_unlock(&rdev->sched_scan_mtx);
 	mutex_unlock(&rdev->devlist_mtx);
 	cfg80211_unlock_rdev(rdev);
 	rtnl_unlock();
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--9amGYk9869ThD9tj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRYxieAAoJEJctW/TcYTgGHr8P/2PM2FcLC2nU4AUxvm5WU4gd
ZhrVDAxFvQc7CeG7EWvsqmymYalUz3x73gJXgDRZ5N0C9aVVomgZgh9EytnPeS5T
FaaGwCVFJebqojhH21beQRtspebeENjpAxy40YnLXpjdbDB/DUpb5pqdrpWHB58Q
J6a8xSQp+ZMwoGu4UkS2ntNzCqOSStFDX/H9eJgwOmEm03jZtfzyb0MmKbV92bm5
TktWPlPwesdTjEdJJiJ4oRqIOk5+xmNVFWjT/YCBpqurgmR1v8DXUD9R79cOd7Tv
JKD1vmY7p2pzILLS8wgz0qPqho6QyqR36ctIhTzH0swIrGB0J0Kx9Eq/0CeIlJM+
OnXQGlXM5PEA8z58/3UmVBK/DgmN7MC4Z6CpvlMomvMP5ttomZw8J61cO1Q/MHxc
3NbFsxOtKYE1zSxAQERrDk9PKsvqWt1cCTYP9kPtBPFY+R4oIFp6wO5PLA7powOT
o4bHcpyawt+xqgbwTMJ8AaAH5Rstl0vk+boSuvMvikN2y/EsIblTW0DUsG5XfGss
dnnuf8RcupRGmXjcNH3M3aM1sP2bxPUzm3fjMzo024VqvE3kkFoQc4btZlhz9Cu4
NwMOpKtaqjF25yp7b69wuTTbaw3yzv/WF49Gfg0jr0D3k4qYWow47W9F7G4n6coK
lyiRIviNKylqAx4l73F1
=ZzjD
-----END PGP SIGNATURE-----

--9amGYk9869ThD9tj--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
