From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-08-17
Date: Sun, 17 Aug 2008 14:56:06 -0400
Message-ID: <20080817185605.GC30679@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is the latest round of wireless fixes for 2.6.27.  The silliest on=
e
is the one from Adrian Bunk, which applies the gcc-related fix to ath9k
again because there were two identical pieces of code to fix -- I guess
I didn't get the joke *facepalm*...

I don't think there is anything else remarkable, although I think we fi=
x
a couple of the current regressions on LKML.

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 23197916c447a1623d196e6547781180905f=
0bb2:
  Matt Carlson (1):
        tg3: Update version to 3.94

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it master

Adrian Bunk (1):
      ath9k: work around gcc ICEs (again)

Christian Lamparter (3):
      p54: Fix regression due to commit b19fa1f
      p54: move p54_vdcf_init to the right place.
      p54u: reset skb's data/tail pointer on requeue

Henrique de Moraes Holschuh (1):
      rfkill: protect suspended rfkill controllers

Holger Schurig (1):
      ssb: allow compilation on systems without PCI

Huang Weiyi (1):
      removed unused #include <version.h>

Jiri Slaby (1):
      iwlwifi: fix printk newlines

Jochen Friedrich (1):
      rt2x00: Fix txdone_entry_desc_flags

Larry Finger (2):
      b43: Fix for SPROM coding error in Linksys WMP54G (BCM4306/3)
      b43: Fix for another Bluetooth Coexistence SPROM Programming erro=
r for BCM4306

Luis R. Rodriguez (1):
      mac80211: remove kdoc references to IEEE80211_HW_HOST_GEN_BEACON_=
TEMPLATE

Michael Karcher (1):
      ath5k: Don't fiddle with MSI on suspend/resume.

Ron Rindjunsky (1):
      mac80211: update new sta's rx timestamp

matthieu Barth=E9lemy (1):
      rtl8187: Add USB ID for Netgear WG111V3

 Documentation/rfkill.txt                    |    5 +++
 drivers/net/wireless/ath5k/base.c           |    9 +----
 drivers/net/wireless/ath9k/hw.c             |    6 +++-
 drivers/net/wireless/b43/main.c             |    3 +-
 drivers/net/wireless/ipw2100.c              |    1 -
 drivers/net/wireless/ipw2200.c              |    1 -
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    3 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    1 -
 drivers/net/wireless/iwlwifi/iwl-core.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-eeprom.c   |    7 ++--
 drivers/net/wireless/iwlwifi/iwl-hcmd.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-power.c    |    1 -
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    4 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c       |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    7 ++--
 drivers/net/wireless/p54/p54common.c        |   51 ++++++++++++++-----=
-------
 drivers/net/wireless/p54/p54common.h        |   18 +++++-----
 drivers/net/wireless/p54/p54usb.c           |   10 +++++
 drivers/net/wireless/rt2x00/rt2x00queue.h   |    8 ++--
 drivers/net/wireless/rt2x00/rt2x00usb.c     |    1 +
 drivers/net/wireless/rtl8187_dev.c          |    1 +
 drivers/ssb/main.c                          |    8 ++++
 include/net/mac80211.h                      |   11 ++----
 net/mac80211/mlme.c                         |    2 +
 net/rfkill/rfkill.c                         |   14 +++++--
 27 files changed, 100 insertions(+), 80 deletions(-)

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
index 28b6ec8..6fcb306 100644
--- a/Documentation/rfkill.txt
+++ b/Documentation/rfkill.txt
@@ -363,6 +363,11 @@ This rule exists because users of the rfkill subsy=
stem expect to get (and set,
 when possible) the overall transmitter rfkill state, not of a particul=
ar rfkill
 line.
=20
+5. During suspend, the rfkill class will attempt to soft-block the rad=
io
+through a call to rfkill->toggle_radio, and will try to restore its pr=
evious
+state during resume.  After a rfkill class is suspended, it will *not*=
 call
+rfkill->toggle_radio until it is resumed.
+
 Example of a WLAN wireless driver connected to the rfkill subsystem:
 --------------------------------------------------------------------
=20
diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/a=
th5k/base.c
index 2028866..b20a45a 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -40,7 +40,6 @@
  *
  */
=20
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/hardirq.h>
@@ -587,7 +586,6 @@ ath5k_pci_suspend(struct pci_dev *pdev, pm_message_=
t state)
 	ath5k_stop_hw(sc);
=20
 	free_irq(pdev->irq, sc);
-	pci_disable_msi(pdev);
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, PCI_D3hot);
@@ -616,12 +614,10 @@ ath5k_pci_resume(struct pci_dev *pdev)
 	 */
 	pci_write_config_byte(pdev, 0x41, 0);
=20
-	pci_enable_msi(pdev);
-
 	err =3D request_irq(pdev->irq, ath5k_intr, IRQF_SHARED, "ath", sc);
 	if (err) {
 		ATH5K_ERR(sc, "request_irq failed\n");
-		goto err_msi;
+		goto err_no_irq;
 	}
=20
 	err =3D ath5k_init(sc);
@@ -642,8 +638,7 @@ ath5k_pci_resume(struct pci_dev *pdev)
 	return 0;
 err_irq:
 	free_irq(pdev->irq, sc);
-err_msi:
-	pci_disable_msi(pdev);
+err_no_irq:
 	pci_disable_device(pdev);
 	return err;
 }
diff --git a/drivers/net/wireless/ath9k/hw.c b/drivers/net/wireless/ath=
9k/hw.c
index bde162f..a17eb13 100644
--- a/drivers/net/wireless/ath9k/hw.c
+++ b/drivers/net/wireless/ath9k/hw.c
@@ -5017,7 +5017,11 @@ static void ath9k_hw_spur_mitigate(struct ath_ha=
l *ah,
=20
 	for (i =3D 0; i < 123; i++) {
 		if ((cur_vit_mask > lower) && (cur_vit_mask < upper)) {
-			if ((abs(cur_vit_mask - bin)) < 75)
+
+			/* workaround for gcc bug #37014 */
+			volatile int tmp =3D abs(cur_vit_mask - bin);
+
+			if (tmp < 75)
 				mask_amt =3D 1;
 			else
 				mask_amt =3D 0;
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43=
/main.c
index 3bf3a86..7205a93 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -33,7 +33,6 @@
 #include <linux/moduleparam.h>
 #include <linux/if_arp.h>
 #include <linux/etherdevice.h>
-#include <linux/version.h>
 #include <linux/firmware.h>
 #include <linux/wireless.h>
 #include <linux/workqueue.h>
@@ -4615,7 +4614,9 @@ static void b43_sprom_fixup(struct ssb_bus *bus)
 	if (bus->bustype =3D=3D SSB_BUSTYPE_PCI) {
 		pdev =3D bus->host_pci;
 		if (IS_PDEV(pdev, BROADCOM, 0x4318, ASUSTEK, 0x100F) ||
+		    IS_PDEV(pdev, BROADCOM, 0x4320,    DELL, 0x0003) ||
 		    IS_PDEV(pdev, BROADCOM, 0x4320, LINKSYS, 0x0015) ||
+		    IS_PDEV(pdev, BROADCOM, 0x4320, LINKSYS, 0x0014) ||
 		    IS_PDEV(pdev, BROADCOM, 0x4320, LINKSYS, 0x0013))
 			bus->sprom.boardflags_lo &=3D ~B43_BFL_BTCOEXIST;
 	}
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2=
100.c
index c6f886e..19a401c 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -157,7 +157,6 @@ that only one external action is invoked at a time.
 #include <linux/stringify.h>
 #include <linux/tcp.h>
 #include <linux/types.h>
-#include <linux/version.h>
 #include <linux/time.h>
 #include <linux/firmware.h>
 #include <linux/acpi.h>
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2=
200.c
index 36e8d2f..dcce354 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -31,7 +31,6 @@
 **********************************************************************=
********/
=20
 #include "ipw2200.h"
-#include <linux/version.h>
=20
=20
 #ifndef KBUILD_EXTMOD
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wire=
less/iwlwifi/iwl-3945.c
index b3931f6..3f51f36 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -26,7 +26,6 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wire=
less/iwlwifi/iwl-4965.c
index 22bb269..e258122 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -26,7 +26,6 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
@@ -967,7 +966,7 @@ static int iwl4965_interpolate_chan(struct iwl_priv=
 *priv, u32 channel,
=20
 	s =3D iwl4965_get_sub_band(priv, channel);
 	if (s >=3D EEPROM_TX_POWER_BANDS) {
-		IWL_ERROR("Tx Power can not find channel %d ", channel);
+		IWL_ERROR("Tx Power can not find channel %d\n", channel);
 		return -1;
 	}
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-5000.c b/drivers/net/wire=
less/iwlwifi/iwl-5000.c
index f3d139b..cbc01a0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-5000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-5000.c
@@ -25,7 +25,6 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wirel=
ess/iwlwifi/iwl-agn.c
index ed09e48..061ffba 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -29,7 +29,6 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wire=
less/iwlwifi/iwl-core.c
index 9bd6180..c72f725 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -28,7 +28,6 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <net/mac80211.h>
=20
 struct iwl_priv; /* FIXME: remove */
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom.c b/drivers/net/wi=
reless/iwlwifi/iwl-eeprom.c
index bce5383..3715575 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.c
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.c
@@ -63,7 +63,6 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/init.h>
=20
 #include <net/mac80211.h>
@@ -146,7 +145,7 @@ int iwlcore_eeprom_verify_signature(struct iwl_priv=
 *priv)
 {
 	u32 gp =3D iwl_read32(priv, CSR_EEPROM_GP);
 	if ((gp & CSR_EEPROM_GP_VALID_MSK) =3D=3D CSR_EEPROM_GP_BAD_SIGNATURE=
) {
-		IWL_ERROR("EEPROM not found, EEPROM_GP=3D0x%08x", gp);
+		IWL_ERROR("EEPROM not found, EEPROM_GP=3D0x%08x\n", gp);
 		return -ENOENT;
 	}
 	return 0;
@@ -227,7 +226,7 @@ int iwl_eeprom_init(struct iwl_priv *priv)
=20
 	ret =3D priv->cfg->ops->lib->eeprom_ops.verify_signature(priv);
 	if (ret < 0) {
-		IWL_ERROR("EEPROM not found, EEPROM_GP=3D0x%08x", gp);
+		IWL_ERROR("EEPROM not found, EEPROM_GP=3D0x%08x\n", gp);
 		ret =3D -ENOENT;
 		goto err;
 	}
@@ -254,7 +253,7 @@ int iwl_eeprom_init(struct iwl_priv *priv)
 		}
=20
 		if (!(r & CSR_EEPROM_REG_READ_VALID_MSK)) {
-			IWL_ERROR("Time out reading EEPROM[%d]", addr);
+			IWL_ERROR("Time out reading EEPROM[%d]\n", addr);
 			ret =3D -ETIMEDOUT;
 			goto done;
 		}
diff --git a/drivers/net/wireless/iwlwifi/iwl-hcmd.c b/drivers/net/wire=
less/iwlwifi/iwl-hcmd.c
index 6512834..2eb03ee 100644
--- a/drivers/net/wireless/iwlwifi/iwl-hcmd.c
+++ b/drivers/net/wireless/iwlwifi/iwl-hcmd.c
@@ -28,7 +28,6 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <net/mac80211.h>
=20
 #include "iwl-dev.h" /* FIXME: remove */
diff --git a/drivers/net/wireless/iwlwifi/iwl-power.c b/drivers/net/wir=
eless/iwlwifi/iwl-power.c
index 028e305..a099c9e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-power.c
+++ b/drivers/net/wireless/iwlwifi/iwl-power.c
@@ -29,7 +29,6 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/init.h>
=20
 #include <net/mac80211.h>
diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.c b/drivers/net/wirel=
ess/iwlwifi/iwl-sta.c
index 60a6e01..6283a3a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-sta.c
@@ -207,7 +207,7 @@ static void iwl_set_ht_add_station(struct iwl_priv =
*priv, u8 index,
 	case WLAN_HT_CAP_MIMO_PS_DISABLED:
 		break;
 	default:
-		IWL_WARNING("Invalid MIMO PS mode %d", mimo_ps_mode);
+		IWL_WARNING("Invalid MIMO PS mode %d\n", mimo_ps_mode);
 		break;
 	}
=20
@@ -969,7 +969,7 @@ int iwl_get_sta_id(struct iwl_priv *priv, struct ie=
ee80211_hdr *hdr)
 		return priv->hw_params.bcast_sta_id;
=20
 	default:
-		IWL_WARNING("Unknown mode of operation: %d", priv->iw_mode);
+		IWL_WARNING("Unknown mode of operation: %d\n", priv->iw_mode);
 		return priv->hw_params.bcast_sta_id;
 	}
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wirele=
ss/iwlwifi/iwl-tx.c
index 4108c7c..d82823b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -493,7 +493,7 @@ int iwl_txq_ctx_reset(struct iwl_priv *priv)
 	/* Alloc keep-warm buffer */
 	ret =3D iwl_kw_alloc(priv);
 	if (ret) {
-		IWL_ERROR("Keep Warm allocation failed");
+		IWL_ERROR("Keep Warm allocation failed\n");
 		goto error_kw;
 	}
 	spin_lock_irqsave(&priv->lock, flags);
@@ -1463,7 +1463,7 @@ void iwl_rx_reply_compressed_ba(struct iwl_priv *=
priv,
 	u16 ba_resp_scd_ssn =3D le16_to_cpu(ba_resp->scd_ssn);
=20
 	if (scd_flow >=3D priv->hw_params.max_txq_num) {
-		IWL_ERROR("BUG_ON scd_flow is bigger than number of queues");
+		IWL_ERROR("BUG_ON scd_flow is bigger than number of queues\n");
 		return;
 	}
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/=
wireless/iwlwifi/iwl3945-base.c
index 444847a..b775d5b 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -29,7 +29,6 @@
=20
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/pci.h>
 #include <linux/dma-mapping.h>
@@ -1558,7 +1557,7 @@ int iwl3945_eeprom_init(struct iwl3945_priv *priv=
)
 	BUILD_BUG_ON(sizeof(priv->eeprom) !=3D IWL_EEPROM_IMAGE_SIZE);
=20
 	if ((gp & CSR_EEPROM_GP_VALID_MSK) =3D=3D CSR_EEPROM_GP_BAD_SIGNATURE=
) {
-		IWL_ERROR("EEPROM not found, EEPROM_GP=3D0x%08x", gp);
+		IWL_ERROR("EEPROM not found, EEPROM_GP=3D0x%08x\n", gp);
 		return -ENOENT;
 	}
=20
@@ -1583,7 +1582,7 @@ int iwl3945_eeprom_init(struct iwl3945_priv *priv=
)
 		}
=20
 		if (!(r & CSR_EEPROM_REG_READ_VALID_MSK)) {
-			IWL_ERROR("Time out reading EEPROM[%d]", addr);
+			IWL_ERROR("Time out reading EEPROM[%d]\n", addr);
 			return -ETIMEDOUT;
 		}
 		e[addr / 2] =3D le16_to_cpu((__force __le16)(r >> 16));
@@ -2507,7 +2506,7 @@ static int iwl3945_get_sta_id(struct iwl3945_priv=
 *priv, struct ieee80211_hdr *h
 		return priv->hw_setting.bcast_sta_id;
=20
 	default:
-		IWL_WARNING("Unknown mode of operation: %d", priv->iw_mode);
+		IWL_WARNING("Unknown mode of operation: %d\n", priv->iw_mode);
 		return priv->hw_setting.bcast_sta_id;
 	}
 }
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireles=
s/p54/p54common.c
index 83cd85e..29be3dc 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -413,12 +413,12 @@ static void p54_rx_frame_sent(struct ieee80211_hw=
 *dev, struct sk_buff *skb)
 			last_addr =3D range->end_addr;
 			__skb_unlink(entry, &priv->tx_queue);
 			memset(&info->status, 0, sizeof(info->status));
-			priv->tx_stats[skb_get_queue_mapping(skb)].len--;
 			entry_hdr =3D (struct p54_control_hdr *) entry->data;
 			entry_data =3D (struct p54_tx_control_allocdata *) entry_hdr->data;
 			if ((entry_hdr->magic1 & cpu_to_le16(0x4000)) !=3D 0)
 				pad =3D entry_data->align[0];
=20
+			priv->tx_stats[entry_data->hw_queue - 4].len--;
 			if (!(info->flags & IEEE80211_TX_CTL_NO_ACK)) {
 				if (!(payload->status & 0x01))
 					info->flags |=3D IEEE80211_TX_STAT_ACK;
@@ -557,6 +557,7 @@ static int p54_tx(struct ieee80211_hw *dev, struct =
sk_buff *skb)
 	struct p54_tx_control_allocdata *txhdr;
 	size_t padding, len;
 	u8 rate;
+	u8 cts_rate =3D 0x20;
=20
 	current_queue =3D &priv->tx_stats[skb_get_queue_mapping(skb)];
 	if (unlikely(current_queue->len > current_queue->limit))
@@ -581,28 +582,28 @@ static int p54_tx(struct ieee80211_hw *dev, struc=
t sk_buff *skb)
 	hdr->type =3D (info->flags & IEEE80211_TX_CTL_NO_ACK) ? 0 : cpu_to_le=
16(1);
 	hdr->retry1 =3D hdr->retry2 =3D info->control.retry_limit;
=20
-	memset(txhdr->wep_key, 0x0, 16);
-	txhdr->padding =3D 0;
-	txhdr->padding2 =3D 0;
-
 	/* TODO: add support for alternate retry TX rates */
 	rate =3D ieee80211_get_tx_rate(dev, info)->hw_value;
-	if (info->flags & IEEE80211_TX_CTL_SHORT_PREAMBLE)
+	if (info->flags & IEEE80211_TX_CTL_SHORT_PREAMBLE) {
 		rate |=3D 0x10;
-	if (info->flags & IEEE80211_TX_CTL_USE_RTS_CTS)
+		cts_rate |=3D 0x10;
+	}
+	if (info->flags & IEEE80211_TX_CTL_USE_RTS_CTS) {
 		rate |=3D 0x40;
-	else if (info->flags & IEEE80211_TX_CTL_USE_CTS_PROTECT)
+		cts_rate |=3D ieee80211_get_rts_cts_rate(dev, info)->hw_value;
+	} else if (info->flags & IEEE80211_TX_CTL_USE_CTS_PROTECT) {
 		rate |=3D 0x20;
+		cts_rate |=3D ieee80211_get_rts_cts_rate(dev, info)->hw_value;
+	}
 	memset(txhdr->rateset, rate, 8);
-	txhdr->wep_key_present =3D 0;
-	txhdr->wep_key_len =3D 0;
-	txhdr->frame_type =3D cpu_to_le32(skb_get_queue_mapping(skb) + 4);
-	txhdr->magic4 =3D 0;
-	txhdr->antenna =3D (info->antenna_sel_tx =3D=3D 0) ?
+	txhdr->key_type =3D 0;
+	txhdr->key_len =3D 0;
+	txhdr->hw_queue =3D skb_get_queue_mapping(skb) + 4;
+	txhdr->tx_antenna =3D (info->antenna_sel_tx =3D=3D 0) ?
 		2 : info->antenna_sel_tx - 1;
 	txhdr->output_power =3D 0x7f; // HW Maximum
-	txhdr->magic5 =3D (info->flags & IEEE80211_TX_CTL_NO_ACK) ?
-		0 : ((rate > 0x3) ? cpu_to_le32(0x33) : cpu_to_le32(0x23));
+	txhdr->cts_rate =3D (info->flags & IEEE80211_TX_CTL_NO_ACK) ?
+			  0 : cts_rate;
 	if (padding)
 		txhdr->align[0] =3D padding;
=20
@@ -836,10 +837,21 @@ static int p54_start(struct ieee80211_hw *dev)
 	struct p54_common *priv =3D dev->priv;
 	int err;
=20
+	if (!priv->cached_vdcf) {
+		priv->cached_vdcf =3D kzalloc(sizeof(struct p54_tx_control_vdcf)+
+			priv->tx_hdr_len + sizeof(struct p54_control_hdr),
+			GFP_KERNEL);
+
+		if (!priv->cached_vdcf)
+			return -ENOMEM;
+	}
+
 	err =3D priv->open(dev);
 	if (!err)
 		priv->mode =3D IEEE80211_IF_TYPE_MNTR;
=20
+	p54_init_vdcf(dev);
+
 	return err;
 }
=20
@@ -1019,15 +1031,6 @@ struct ieee80211_hw *p54_init_common(size_t priv=
_data_len)
 	dev->extra_tx_headroom =3D sizeof(struct p54_control_hdr) + 4 +
 				 sizeof(struct p54_tx_control_allocdata);
=20
-        priv->cached_vdcf =3D kzalloc(sizeof(struct p54_tx_control_vdc=
f) +
-              priv->tx_hdr_len + sizeof(struct p54_control_hdr), GFP_K=
ERNEL);
-
-	if (!priv->cached_vdcf) {
-		ieee80211_free_hw(dev);
-		return NULL;
-	}
-
-	p54_init_vdcf(dev);
 	mutex_init(&priv->conf_mutex);
=20
 	return dev;
diff --git a/drivers/net/wireless/p54/p54common.h b/drivers/net/wireles=
s/p54/p54common.h
index 2245fcc..8db6c0e 100644
--- a/drivers/net/wireless/p54/p54common.h
+++ b/drivers/net/wireless/p54/p54common.h
@@ -183,16 +183,16 @@ struct p54_frame_sent_hdr {
=20
 struct p54_tx_control_allocdata {
 	u8 rateset[8];
-	u16 padding;
-	u8 wep_key_present;
-	u8 wep_key_len;
-	u8 wep_key[16];
-	__le32 frame_type;
-	u32 padding2;
-	__le16 magic4;
-	u8 antenna;
+	u8 unalloc0[2];
+	u8 key_type;
+	u8 key_len;
+	u8 key[16];
+	u8 hw_queue;
+	u8 unalloc1[9];
+	u8 tx_antenna;
 	u8 output_power;
-	__le32 magic5;
+	u8 cts_rate;
+	u8 unalloc2[3];
 	u8 align[0];
 } __attribute__ ((packed));
=20
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p=
54/p54usb.c
index 815c095..cbaca23 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -109,7 +109,17 @@ static void p54u_rx_cb(struct urb *urb)
 		urb->context =3D skb;
 		skb_queue_tail(&priv->rx_queue, skb);
 	} else {
+		if (!priv->hw_type)
+			skb_push(skb, sizeof(struct net2280_tx_hdr));
+
+		skb_reset_tail_pointer(skb);
 		skb_trim(skb, 0);
+		if (urb->transfer_buffer !=3D skb_tail_pointer(skb)) {
+			/* this should not happen */
+			WARN_ON(1);
+			urb->transfer_buffer =3D skb_tail_pointer(skb);
+		}
+
 		skb_queue_tail(&priv->rx_queue, skb);
 	}
=20
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.h b/drivers/net/wi=
reless/rt2x00/rt2x00queue.h
index a4a8c57..ff78e52 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.h
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.h
@@ -173,10 +173,10 @@ struct rxdone_entry_desc {
  *	frame transmission failed due to excessive retries.
  */
 enum txdone_entry_desc_flags {
-	TXDONE_UNKNOWN =3D 1 << 0,
-	TXDONE_SUCCESS =3D 1 << 1,
-	TXDONE_FAILURE =3D 1 << 2,
-	TXDONE_EXCESSIVE_RETRY =3D 1 << 3,
+	TXDONE_UNKNOWN,
+	TXDONE_SUCCESS,
+	TXDONE_FAILURE,
+	TXDONE_EXCESSIVE_RETRY,
 };
=20
 /**
diff --git a/drivers/net/wireless/rt2x00/rt2x00usb.c b/drivers/net/wire=
less/rt2x00/rt2x00usb.c
index 8d76bb2..2050227 100644
--- a/drivers/net/wireless/rt2x00/rt2x00usb.c
+++ b/drivers/net/wireless/rt2x00/rt2x00usb.c
@@ -181,6 +181,7 @@ static void rt2x00usb_interrupt_txdone(struct urb *=
urb)
 	 * (Only indirectly by looking at the failed TX counters
 	 * in the register).
 	 */
+	txdesc.flags =3D 0;
 	if (!urb->status)
 		__set_bit(TXDONE_UNKNOWN, &txdesc.flags);
 	else
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/=
rtl8187_dev.c
index 57376fb..ca5deb6 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -40,6 +40,7 @@ static struct usb_device_id rtl8187_table[] __devinit=
data =3D {
 	/* Netgear */
 	{USB_DEVICE(0x0846, 0x6100), .driver_info =3D DEVICE_RTL8187},
 	{USB_DEVICE(0x0846, 0x6a00), .driver_info =3D DEVICE_RTL8187},
+	{USB_DEVICE(0x0846, 0x4260), .driver_info =3D DEVICE_RTL8187B},
 	/* HP */
 	{USB_DEVICE(0x03f0, 0xca02), .driver_info =3D DEVICE_RTL8187},
 	/* Sitecom */
diff --git a/drivers/ssb/main.c b/drivers/ssb/main.c
index d831a2b..87ab244 100644
--- a/drivers/ssb/main.c
+++ b/drivers/ssb/main.c
@@ -1165,15 +1165,19 @@ EXPORT_SYMBOL(ssb_dma_translation);
=20
 int ssb_dma_set_mask(struct ssb_device *dev, u64 mask)
 {
+#ifdef CONFIG_SSB_PCIHOST
 	int err;
+#endif
=20
 	switch (dev->bus->bustype) {
 	case SSB_BUSTYPE_PCI:
+#ifdef CONFIG_SSB_PCIHOST
 		err =3D pci_set_dma_mask(dev->bus->host_pci, mask);
 		if (err)
 			return err;
 		err =3D pci_set_consistent_dma_mask(dev->bus->host_pci, mask);
 		return err;
+#endif
 	case SSB_BUSTYPE_SSB:
 		return dma_set_mask(dev->dev, mask);
 	default:
@@ -1188,6 +1192,7 @@ void * ssb_dma_alloc_consistent(struct ssb_device=
 *dev, size_t size,
 {
 	switch (dev->bus->bustype) {
 	case SSB_BUSTYPE_PCI:
+#ifdef CONFIG_SSB_PCIHOST
 		if (gfp_flags & GFP_DMA) {
 			/* Workaround: The PCI API does not support passing
 			 * a GFP flag. */
@@ -1195,6 +1200,7 @@ void * ssb_dma_alloc_consistent(struct ssb_device=
 *dev, size_t size,
 						  size, dma_handle, gfp_flags);
 		}
 		return pci_alloc_consistent(dev->bus->host_pci, size, dma_handle);
+#endif
 	case SSB_BUSTYPE_SSB:
 		return dma_alloc_coherent(dev->dev, size, dma_handle, gfp_flags);
 	default:
@@ -1210,6 +1216,7 @@ void ssb_dma_free_consistent(struct ssb_device *d=
ev, size_t size,
 {
 	switch (dev->bus->bustype) {
 	case SSB_BUSTYPE_PCI:
+#ifdef CONFIG_SSB_PCIHOST
 		if (gfp_flags & GFP_DMA) {
 			/* Workaround: The PCI API does not support passing
 			 * a GFP flag. */
@@ -1220,6 +1227,7 @@ void ssb_dma_free_consistent(struct ssb_device *d=
ev, size_t size,
 		pci_free_consistent(dev->bus->host_pci, size,
 				    vaddr, dma_handle);
 		return;
+#endif
 	case SSB_BUSTYPE_SSB:
 		dma_free_coherent(dev->dev, size, vaddr, dma_handle);
 		return;
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index b397e4d..ff137fd 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -708,10 +708,7 @@ enum ieee80211_tkip_key_type {
  *	rely on the host system for such buffering. This option is used
  *	to configure the IEEE 802.11 upper layer to buffer broadcast and
  *	multicast frames when there are power saving stations so that
- *	the driver can fetch them with ieee80211_get_buffered_bc(). Note
- *	that not setting this flag works properly only when the
- *	%IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE is also not set because
- *	otherwise the stack will not know when the DTIM beacon was sent.
+ *	the driver can fetch them with ieee80211_get_buffered_bc().
  *
  * @IEEE80211_HW_2GHZ_SHORT_SLOT_INCAPABLE:
  *	Hardware is not capable of short slot operation on the 2.4 GHz band=
=2E
@@ -1099,10 +1096,8 @@ enum ieee80211_ampdu_mlme_action {
  *	See the section "Frame filtering" for more information.
  *	This callback must be implemented and atomic.
  *
- * @set_tim: Set TIM bit. If the hardware/firmware takes care of beaco=
n
- *	generation (that is, %IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE is set)
- *	mac80211 calls this function when a TIM bit must be set or cleared
- *	for a given AID. Must be atomic.
+ * @set_tim: Set TIM bit. mac80211 calls this function when a TIM bit
+ * 	must be set or cleared for a given AID. Must be atomic.
  *
  * @set_key: See the section "Hardware crypto acceleration"
  *	This callback can sleep, and is only called between add_interface
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index e1d11c9..1e97fb9 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2103,6 +2103,8 @@ static void ieee80211_rx_mgmt_assoc_resp(struct i=
eee80211_sub_if_data *sdata,
 			rcu_read_unlock();
 			return;
 		}
+		/* update new sta with its last rx activity */
+		sta->last_rx =3D jiffies;
 	}
=20
 	/*
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index d2d4565..35a9994 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -150,6 +150,8 @@ static void update_rfkill_state(struct rfkill *rfki=
ll)
  * calls and handling all the red tape such as issuing notifications
  * if the call is successful.
  *
+ * Suspended devices are not touched at all, and -EAGAIN is returned.
+ *
  * Note that the @force parameter cannot override a (possibly cached)
  * state of RFKILL_STATE_HARD_BLOCKED.  Any device making use of
  * RFKILL_STATE_HARD_BLOCKED implements either get_state() or
@@ -168,6 +170,9 @@ static int rfkill_toggle_radio(struct rfkill *rfkil=
l,
 	int retval =3D 0;
 	enum rfkill_state oldstate, newstate;
=20
+	if (unlikely(rfkill->dev.power.power_state.event & PM_EVENT_SLEEP))
+		return -EBUSY;
+
 	oldstate =3D rfkill->state;
=20
 	if (rfkill->get_state && !force &&
@@ -214,7 +219,7 @@ static int rfkill_toggle_radio(struct rfkill *rfkil=
l,
  *
  * This function toggles the state of all switches of given type,
  * unless a specific switch is claimed by userspace (in which case,
- * that switch is left alone).
+ * that switch is left alone) or suspended.
  */
 void rfkill_switch_all(enum rfkill_type type, enum rfkill_state state)
 {
@@ -239,8 +244,8 @@ EXPORT_SYMBOL(rfkill_switch_all);
 /**
  * rfkill_epo - emergency power off all transmitters
  *
- * This kicks all rfkill devices to RFKILL_STATE_SOFT_BLOCKED, ignorin=
g
- * everything in its path but rfkill_mutex and rfkill->mutex.
+ * This kicks all non-suspended rfkill devices to RFKILL_STATE_SOFT_BL=
OCKED,
+ * ignoring everything in its path but rfkill_mutex and rfkill->mutex.
  */
 void rfkill_epo(void)
 {
@@ -458,13 +463,14 @@ static int rfkill_resume(struct device *dev)
 	if (dev->power.power_state.event !=3D PM_EVENT_ON) {
 		mutex_lock(&rfkill->mutex);
=20
+		dev->power.power_state.event =3D PM_EVENT_ON;
+
 		/* restore radio state AND notify everybody */
 		rfkill_toggle_radio(rfkill, rfkill->state, 1);
=20
 		mutex_unlock(&rfkill->mutex);
 	}
=20
-	dev->power.power_state =3D PMSG_ON;
 	return 0;
 }
 #else
--=20
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
