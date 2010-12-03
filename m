From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-12-03
Date: Fri, 3 Dec 2010 15:16:02 -0500
Message-ID: <20101203201602.GE2348@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David,

This is a batch of fixes intended for 2.6.37.  There are a number of
small fixes that speak for themselves.  Also included are a small patch
for ar9170 to advertise Wi-Fi Peer-to-peer capability -- not truly a
fix, but helpful for those developing the related userland bits and
harmless to everyone else.  There are also some endian related patches
for ath9k from Felix that are a bit large, but they mostly just refactor
some tables in order to fix an endian problem that can result in invalid
regulatory settings on some boxes.

Also includes are some Bluetooth patches via Gustavo Padovan:

"Here goes 3 simple patches intended to 2.6.37. First one is from myself
and fix some trivial return values. Then we also have a fix from Stefan
Seyfried on btusb to avoid emitting an err when we USB is autosupended.
Last, a patch from Bala Shanmugam that fix the firmware loading process
for the ath3k driver."

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 25888e30319f8896fc656fc68643e6a078263060:

  af_unix: limit recursion level (2010-11-29 09:45:15 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bala Shanmugam (1):
      Bluetooth: Add new PID for Atheros 3011

Christian Lamparter (2):
      carl9170: fix carl9170_tx_prepare typo
      mac80211: ignore non-bcast mcast deauth/disassoc franes

Daniel Drake (1):
      libertas: fix memory corruption in lbs_remove_card()

David Kilroy (1):
      orinoco: abort scan on interface down

Felix Fietkau (2):
      ath9k_hw: fix endian issues with CTLs on AR9003
      ath9k_hw: fix more bitfield related endian issues

Gabor Juhos (1):
      ath9k: use per-device struct for pm_qos_* operations

Gustavo F. Padovan (1):
      Bluetooth: Fix not returning proper error in SCO

Johannes Berg (1):
      ath9k/carl9170: advertise P2P

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth-2.6
      Revert "ath9k: Fix STA disconnect issue due to received MIC failed bcast frames"

Jouni Malinen (1):
      mac80211: Fix frame injection using non-AP vif

Rajkumar Manoharan (1):
      ath9k: Disable SWBA interrupt on remove_interface

Senthil Balasubramanian (2):
      mac80211: Fix STA disconnect due to MIC failure
      ath9k: Fix STA disconnect issue due to received MIC failed bcast frames

Stefan Seyfried (1):
      Bluetooth: Fix log spamming in btusb due to autosuspend

Sven Neumann (1):
      libertas: fix invalid access

Vasanthakumar Thiagarajan (1):
      ath9k: Fix bug in reading input gpio state for ar9003

 drivers/bluetooth/ath3k.c                      |    4 +
 drivers/bluetooth/btusb.c                      |   12 +++-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c |   73 ++++++++++++-----------
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h |    9 +--
 drivers/net/wireless/ath/ath9k/ath9k.h         |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom.c        |    6 +-
 drivers/net/wireless/ath/ath9k/eeprom.h        |   27 +++++----
 drivers/net/wireless/ath/ath9k/eeprom_def.c    |   11 ++--
 drivers/net/wireless/ath/ath9k/hw.c            |    3 +-
 drivers/net/wireless/ath/ath9k/init.c          |    9 +--
 drivers/net/wireless/ath/ath9k/main.c          |   16 ++++-
 drivers/net/wireless/ath/ath9k/reg.h           |    6 +-
 drivers/net/wireless/ath/carl9170/fw.c         |    3 +-
 drivers/net/wireless/ath/carl9170/main.c       |    3 +-
 drivers/net/wireless/ath/carl9170/tx.c         |    2 +-
 drivers/net/wireless/libertas/if_sdio.c        |    1 -
 drivers/net/wireless/libertas/if_spi.c         |    1 -
 drivers/net/wireless/libertas/main.c           |    2 -
 drivers/net/wireless/orinoco/main.c            |   12 ++--
 drivers/net/wireless/orinoco/scan.c            |    8 +++
 drivers/net/wireless/orinoco/scan.h            |    1 +
 net/bluetooth/sco.c                            |    6 +-
 net/mac80211/rx.c                              |    6 ++
 net/mac80211/tx.c                              |    7 ++-
 24 files changed, 135 insertions(+), 97 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index 128cae4..949ed09 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -35,6 +35,10 @@
 static struct usb_device_id ath3k_table[] = {
 	/* Atheros AR3011 */
 	{ USB_DEVICE(0x0CF3, 0x3000) },
+
+	/* Atheros AR3011 with sflash firmware*/
+	{ USB_DEVICE(0x0CF3, 0x3002) },
+
 	{ }	/* Terminating entry */
 };
 
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index ab3894f..1da773f 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -99,6 +99,9 @@ static struct usb_device_id blacklist_table[] = {
 	/* Broadcom BCM2033 without firmware */
 	{ USB_DEVICE(0x0a5c, 0x2033), .driver_info = BTUSB_IGNORE },
 
+	/* Atheros 3011 with sflash firmware */
+	{ USB_DEVICE(0x0cf3, 0x3002), .driver_info = BTUSB_IGNORE },
+
 	/* Broadcom BCM2035 */
 	{ USB_DEVICE(0x0a5c, 0x2035), .driver_info = BTUSB_WRONG_SCO_MTU },
 	{ USB_DEVICE(0x0a5c, 0x200a), .driver_info = BTUSB_WRONG_SCO_MTU },
@@ -239,7 +242,8 @@ static void btusb_intr_complete(struct urb *urb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		BT_ERR("%s urb %p failed to resubmit (%d)",
+		if (err != -EPERM)
+			BT_ERR("%s urb %p failed to resubmit (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -323,7 +327,8 @@ static void btusb_bulk_complete(struct urb *urb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		BT_ERR("%s urb %p failed to resubmit (%d)",
+		if (err != -EPERM)
+			BT_ERR("%s urb %p failed to resubmit (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
@@ -412,7 +417,8 @@ static void btusb_isoc_complete(struct urb *urb)
 
 	err = usb_submit_urb(urb, GFP_ATOMIC);
 	if (err < 0) {
-		BT_ERR("%s urb %p failed to resubmit (%d)",
+		if (err != -EPERM)
+			BT_ERR("%s urb %p failed to resubmit (%d)",
 						hdev->name, urb, -err);
 		usb_unanchor_urb(urb);
 	}
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index c418235..a7b82f0 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -55,6 +55,8 @@
 #define SUB_NUM_CTL_MODES_AT_5G_40 2    /* excluding HT40, EXT-OFDM */
 #define SUB_NUM_CTL_MODES_AT_2G_40 3    /* excluding HT40, EXT-OFDM, EXT-CCK */
 
+#define CTL(_tpower, _flag) ((_tpower) | ((_flag) << 6))
+
 static const struct ar9300_eeprom ar9300_default = {
 	.eepromVersion = 2,
 	.templateVersion = 2,
@@ -290,20 +292,21 @@ static const struct ar9300_eeprom ar9300_default = {
 		}
 	 },
 	.ctlPowerData_2G = {
-		 { { {60, 0}, {60, 1}, {60, 0}, {60, 0} } },
-		 { { {60, 0}, {60, 1}, {60, 0}, {60, 0} } },
-		 { { {60, 1}, {60, 0}, {60, 0}, {60, 1} } },
+		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
+		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
+		 { { CTL(60, 1), CTL(60, 0), CTL(60, 0), CTL(60, 1) } },
 
-		 { { {60, 1}, {60, 0}, {0, 0}, {0, 0} } },
-		 { { {60, 0}, {60, 1}, {60, 0}, {60, 0} } },
-		 { { {60, 0}, {60, 1}, {60, 0}, {60, 0} } },
+		 { { CTL(60, 1), CTL(60, 0), CTL(0, 0), CTL(0, 0) } },
+		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
+		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 
-		 { { {60, 0}, {60, 1}, {60, 1}, {60, 0} } },
-		 { { {60, 0}, {60, 1}, {60, 0}, {60, 0} } },
-		 { { {60, 0}, {60, 1}, {60, 0}, {60, 0} } },
+		 { { CTL(60, 0), CTL(60, 1), CTL(60, 1), CTL(60, 0) } },
+		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
+		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
 
-		 { { {60, 0}, {60, 1}, {60, 0}, {60, 0} } },
-		 { { {60, 0}, {60, 1}, {60, 1}, {60, 1} } },
+		 { { CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 0) } },
+		 { { CTL(60, 0), CTL(60, 1), CTL(60, 1), CTL(60, 1) } },
+		 { { CTL(60, 0), CTL(60, 1), CTL(60, 1), CTL(60, 1) } },
 	 },
 	.modalHeader5G = {
 		/* 4 idle,t1,t2,b (4 bits per setting) */
@@ -568,56 +571,56 @@ static const struct ar9300_eeprom ar9300_default = {
 	.ctlPowerData_5G = {
 		{
 			{
-				{60, 1}, {60, 1}, {60, 1}, {60, 1},
-				{60, 1}, {60, 1}, {60, 1}, {60, 0},
+				CTL(60, 1), CTL(60, 1), CTL(60, 1), CTL(60, 1),
+				CTL(60, 1), CTL(60, 1), CTL(60, 1), CTL(60, 0),
 			}
 		},
 		{
 			{
-				{60, 1}, {60, 1}, {60, 1}, {60, 1},
-				{60, 1}, {60, 1}, {60, 1}, {60, 0},
+				CTL(60, 1), CTL(60, 1), CTL(60, 1), CTL(60, 1),
+				CTL(60, 1), CTL(60, 1), CTL(60, 1), CTL(60, 0),
 			}
 		},
 		{
 			{
-				{60, 0}, {60, 1}, {60, 0}, {60, 1},
-				{60, 1}, {60, 1}, {60, 1}, {60, 1},
+				CTL(60, 0), CTL(60, 1), CTL(60, 0), CTL(60, 1),
+				CTL(60, 1), CTL(60, 1), CTL(60, 1), CTL(60, 1),
 			}
 		},
 		{
 			{
-				{60, 0}, {60, 1}, {60, 1}, {60, 0},
-				{60, 1}, {60, 0}, {60, 0}, {60, 0},
+				CTL(60, 0), CTL(60, 1), CTL(60, 1), CTL(60, 0),
+				CTL(60, 1), CTL(60, 0), CTL(60, 0), CTL(60, 0),
 			}
 		},
 		{
 			{
-				{60, 1}, {60, 1}, {60, 1}, {60, 0},
-				{60, 0}, {60, 0}, {60, 0}, {60, 0},
+				CTL(60, 1), CTL(60, 1), CTL(60, 1), CTL(60, 0),
+				CTL(60, 0), CTL(60, 0), CTL(60, 0), CTL(60, 0),
 			}
 		},
 		{
 			{
-				{60, 1}, {60, 1}, {60, 1}, {60, 1},
-				{60, 1}, {60, 0}, {60, 0}, {60, 0},
+				CTL(60, 1), CTL(60, 1), CTL(60, 1), CTL(60, 1),
+				CTL(60, 1), CTL(60, 0), CTL(60, 0), CTL(60, 0),
 			}
 		},
 		{
 			{
-				{60, 1}, {60, 1}, {60, 1}, {60, 1},
-				{60, 1}, {60, 1}, {60, 1}, {60, 1},
+				CTL(60, 1), CTL(60, 1), CTL(60, 1), CTL(60, 1),
+				CTL(60, 1), CTL(60, 1), CTL(60, 1), CTL(60, 1),
 			}
 		},
 		{
 			{
-				{60, 1}, {60, 1}, {60, 0}, {60, 1},
-				{60, 1}, {60, 1}, {60, 1}, {60, 0},
+				CTL(60, 1), CTL(60, 1), CTL(60, 0), CTL(60, 1),
+				CTL(60, 1), CTL(60, 1), CTL(60, 1), CTL(60, 0),
 			}
 		},
 		{
 			{
-				{60, 1}, {60, 0}, {60, 1}, {60, 1},
-				{60, 1}, {60, 1}, {60, 0}, {60, 1},
+				CTL(60, 1), CTL(60, 0), CTL(60, 1), CTL(60, 1),
+				CTL(60, 1), CTL(60, 1), CTL(60, 0), CTL(60, 1),
 			}
 		},
 	 }
@@ -1827,9 +1830,9 @@ static u16 ar9003_hw_get_direct_edge_power(struct ar9300_eeprom *eep,
 	struct cal_ctl_data_5g *ctl_5g = eep->ctlPowerData_5G;
 
 	if (is2GHz)
-		return ctl_2g[idx].ctlEdges[edge].tPower;
+		return CTL_EDGE_TPOWER(ctl_2g[idx].ctlEdges[edge]);
 	else
-		return ctl_5g[idx].ctlEdges[edge].tPower;
+		return CTL_EDGE_TPOWER(ctl_5g[idx].ctlEdges[edge]);
 }
 
 static u16 ar9003_hw_get_indirect_edge_power(struct ar9300_eeprom *eep,
@@ -1847,12 +1850,12 @@ static u16 ar9003_hw_get_indirect_edge_power(struct ar9300_eeprom *eep,
 
 	if (is2GHz) {
 		if (ath9k_hw_fbin2freq(ctl_freqbin[edge - 1], 1) < freq &&
-		    ctl_2g[idx].ctlEdges[edge - 1].flag)
-			return ctl_2g[idx].ctlEdges[edge - 1].tPower;
+		    CTL_EDGE_FLAGS(ctl_2g[idx].ctlEdges[edge - 1]))
+			return CTL_EDGE_TPOWER(ctl_2g[idx].ctlEdges[edge - 1]);
 	} else {
 		if (ath9k_hw_fbin2freq(ctl_freqbin[edge - 1], 0) < freq &&
-		    ctl_5g[idx].ctlEdges[edge - 1].flag)
-			return ctl_5g[idx].ctlEdges[edge - 1].tPower;
+		    CTL_EDGE_FLAGS(ctl_5g[idx].ctlEdges[edge - 1]))
+			return CTL_EDGE_TPOWER(ctl_5g[idx].ctlEdges[edge - 1]);
 	}
 
 	return AR9300_MAX_RATE_POWER;
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.h b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.h
index 3c533bb..655b303 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.h
@@ -261,17 +261,12 @@ struct cal_tgt_pow_ht {
 	u8 tPow2x[14];
 } __packed;
 
-struct cal_ctl_edge_pwr {
-	u8 tPower:6,
-	   flag:2;
-} __packed;
-
 struct cal_ctl_data_2g {
-	struct cal_ctl_edge_pwr ctlEdges[AR9300_NUM_BAND_EDGES_2G];
+	u8 ctlEdges[AR9300_NUM_BAND_EDGES_2G];
 } __packed;
 
 struct cal_ctl_data_5g {
-	struct cal_ctl_edge_pwr ctlEdges[AR9300_NUM_BAND_EDGES_5G];
+	u8 ctlEdges[AR9300_NUM_BAND_EDGES_5G];
 } __packed;
 
 struct ar9300_eeprom {
diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 170d44a..0d0bec3 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -21,6 +21,7 @@
 #include <linux/device.h>
 #include <linux/leds.h>
 #include <linux/completion.h>
+#include <linux/pm_qos_params.h>
 
 #include "debug.h"
 #include "common.h"
@@ -646,6 +647,8 @@ struct ath_softc {
 	struct ath_descdma txsdma;
 
 	struct ath_ant_comb ant_comb;
+
+	struct pm_qos_request_list pm_qos_req;
 };
 
 struct ath_wiphy {
@@ -675,7 +678,6 @@ static inline void ath_read_cachesize(struct ath_common *common, int *csz)
 }
 
 extern struct ieee80211_ops ath9k_ops;
-extern struct pm_qos_request_list ath9k_pm_qos_req;
 extern int modparam_nohwcrypt;
 extern int led_blink;
 
diff --git a/drivers/net/wireless/ath/ath9k/eeprom.c b/drivers/net/wireless/ath/ath9k/eeprom.c
index 1266333..2bbf94d 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom.c
@@ -240,16 +240,16 @@ u16 ath9k_hw_get_max_edge_power(u16 freq, struct cal_ctl_edges *pRdEdgesPower,
 	for (i = 0; (i < num_band_edges) &&
 		     (pRdEdgesPower[i].bChannel != AR5416_BCHAN_UNUSED); i++) {
 		if (freq == ath9k_hw_fbin2freq(pRdEdgesPower[i].bChannel, is2GHz)) {
-			twiceMaxEdgePower = pRdEdgesPower[i].tPower;
+			twiceMaxEdgePower = CTL_EDGE_TPOWER(pRdEdgesPower[i].ctl);
 			break;
 		} else if ((i > 0) &&
 			   (freq < ath9k_hw_fbin2freq(pRdEdgesPower[i].bChannel,
 						      is2GHz))) {
 			if (ath9k_hw_fbin2freq(pRdEdgesPower[i - 1].bChannel,
 					       is2GHz) < freq &&
-			    pRdEdgesPower[i - 1].flag) {
+			    CTL_EDGE_FLAGS(pRdEdgesPower[i - 1].ctl)) {
 				twiceMaxEdgePower =
-					pRdEdgesPower[i - 1].tPower;
+					CTL_EDGE_TPOWER(pRdEdgesPower[i - 1].ctl);
 			}
 			break;
 		}
diff --git a/drivers/net/wireless/ath/ath9k/eeprom.h b/drivers/net/wireless/ath/ath9k/eeprom.h
index dacb45e..dd59f09 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.h
+++ b/drivers/net/wireless/ath/ath9k/eeprom.h
@@ -233,6 +233,18 @@
 
 #define AR9287_CHECKSUM_LOCATION (AR9287_EEP_START_LOC + 1)
 
+#define CTL_EDGE_TPOWER(_ctl) ((_ctl) & 0x3f)
+#define CTL_EDGE_FLAGS(_ctl) (((_ctl) >> 6) & 0x03)
+
+#define LNA_CTL_BUF_MODE	BIT(0)
+#define LNA_CTL_ISEL_LO		BIT(1)
+#define LNA_CTL_ISEL_HI		BIT(2)
+#define LNA_CTL_BUF_IN		BIT(3)
+#define LNA_CTL_FEM_BAND	BIT(4)
+#define LNA_CTL_LOCAL_BIAS	BIT(5)
+#define LNA_CTL_FORCE_XPA	BIT(6)
+#define LNA_CTL_USE_ANT1	BIT(7)
+
 enum eeprom_param {
 	EEP_NFTHRESH_5,
 	EEP_NFTHRESH_2,
@@ -378,10 +390,7 @@ struct modal_eep_header {
 	u8 xatten2Margin[AR5416_MAX_CHAINS];
 	u8 ob_ch1;
 	u8 db_ch1;
-	u8 useAnt1:1,
-	    force_xpaon:1,
-	    local_bias:1,
-	    femBandSelectUsed:1, xlnabufin:1, xlnaisel:2, xlnabufmode:1;
+	u8 lna_ctl;
 	u8 miscBits;
 	u16 xpaBiasLvlFreq[3];
 	u8 futureModal[6];
@@ -535,18 +544,10 @@ struct cal_target_power_ht {
 	u8 tPow2x[8];
 } __packed;
 
-
-#ifdef __BIG_ENDIAN_BITFIELD
-struct cal_ctl_edges {
-	u8 bChannel;
-	u8 flag:2, tPower:6;
-} __packed;
-#else
 struct cal_ctl_edges {
 	u8 bChannel;
-	u8 tPower:6, flag:2;
+	u8 ctl;
 } __packed;
-#endif
 
 struct cal_data_op_loop_ar9287 {
 	u8 pwrPdg[2][5];
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index 76b4d65..526d7c9 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -451,9 +451,10 @@ static void ath9k_hw_def_set_board_values(struct ath_hw *ah,
 		ath9k_hw_analog_shift_rmw(ah, AR_AN_TOP2,
 					  AR_AN_TOP2_LOCALBIAS,
 					  AR_AN_TOP2_LOCALBIAS_S,
-					  pModal->local_bias);
+					  !!(pModal->lna_ctl &
+					     LNA_CTL_LOCAL_BIAS));
 		REG_RMW_FIELD(ah, AR_PHY_XPA_CFG, AR_PHY_FORCE_XPA_CFG,
-			      pModal->force_xpaon);
+			      !!(pModal->lna_ctl & LNA_CTL_FORCE_XPA));
 	}
 
 	REG_RMW_FIELD(ah, AR_PHY_SETTLING, AR_PHY_SETTLING_SWITCH,
@@ -1428,9 +1429,9 @@ static u8 ath9k_hw_def_get_num_ant_config(struct ath_hw *ah,
 
 	num_ant_config = 1;
 
-	if (pBase->version >= 0x0E0D)
-		if (pModal->useAnt1)
-			num_ant_config += 1;
+	if (pBase->version >= 0x0E0D &&
+	    (pModal->lna_ctl & LNA_CTL_USE_ANT1))
+		num_ant_config += 1;
 
 	return num_ant_config;
 }
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 6ebc68b..c7fbe25 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -2044,7 +2044,8 @@ u32 ath9k_hw_gpio_get(struct ath_hw *ah, u32 gpio)
 		val = REG_READ(ah, AR7010_GPIO_IN);
 		return (MS(val, AR7010_GPIO_IN_VAL) & AR_GPIO_BIT(gpio)) == 0;
 	} else if (AR_SREV_9300_20_OR_LATER(ah))
-		return MS_REG_READ(AR9300, gpio) != 0;
+		return (MS(REG_READ(ah, AR_GPIO_IN), AR9300_GPIO_IN_VAL) &
+			AR_GPIO_BIT(gpio)) != 0;
 	else if (AR_SREV_9271(ah))
 		return MS_REG_READ(AR9271, gpio) != 0;
 	else if (AR_SREV_9287_11_OR_LATER(ah))
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 92bc5c5..14b8ab3 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -15,7 +15,6 @@
  */
 
 #include <linux/slab.h>
-#include <linux/pm_qos_params.h>
 
 #include "ath9k.h"
 
@@ -180,8 +179,6 @@ static const struct ath_ops ath9k_common_ops = {
 	.write = ath9k_iowrite32,
 };
 
-struct pm_qos_request_list ath9k_pm_qos_req;
-
 /**************************/
 /*     Initialization     */
 /**************************/
@@ -664,6 +661,8 @@ void ath9k_set_hw_capab(struct ath_softc *sc, struct ieee80211_hw *hw)
 		hw->flags |= IEEE80211_HW_MFP_CAPABLE;
 
 	hw->wiphy->interface_modes =
+		BIT(NL80211_IFTYPE_P2P_GO) |
+		BIT(NL80211_IFTYPE_P2P_CLIENT) |
 		BIT(NL80211_IFTYPE_AP) |
 		BIT(NL80211_IFTYPE_WDS) |
 		BIT(NL80211_IFTYPE_STATION) |
@@ -759,7 +758,7 @@ int ath9k_init_device(u16 devid, struct ath_softc *sc, u16 subsysid,
 	ath_init_leds(sc);
 	ath_start_rfkill_poll(sc);
 
-	pm_qos_add_request(&ath9k_pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
+	pm_qos_add_request(&sc->pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
 			   PM_QOS_DEFAULT_VALUE);
 
 	return 0;
@@ -830,7 +829,7 @@ void ath9k_deinit_device(struct ath_softc *sc)
 	}
 
 	ieee80211_unregister_hw(hw);
-	pm_qos_remove_request(&ath9k_pm_qos_req);
+	pm_qos_remove_request(&sc->pm_qos_req);
 	ath_rx_cleanup(sc);
 	ath_tx_cleanup(sc);
 	ath9k_deinit_softc(sc);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 25d3ef4..dace215 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -15,7 +15,6 @@
  */
 
 #include <linux/nl80211.h>
-#include <linux/pm_qos_params.h>
 #include "ath9k.h"
 #include "btcoex.h"
 
@@ -1244,7 +1243,7 @@ static int ath9k_start(struct ieee80211_hw *hw)
 			ath9k_btcoex_timer_resume(sc);
 	}
 
-	pm_qos_update_request(&ath9k_pm_qos_req, 55);
+	pm_qos_update_request(&sc->pm_qos_req, 55);
 
 mutex_unlock:
 	mutex_unlock(&sc->mutex);
@@ -1423,7 +1422,7 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 
 	sc->sc_flags |= SC_OP_INVALID;
 
-	pm_qos_update_request(&ath9k_pm_qos_req, PM_QOS_DEFAULT_VALUE);
+	pm_qos_update_request(&sc->pm_qos_req, PM_QOS_DEFAULT_VALUE);
 
 	mutex_unlock(&sc->mutex);
 
@@ -1520,6 +1519,7 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 	struct ath_softc *sc = aphy->sc;
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_vif *avp = (void *)vif->drv_priv;
+	bool bs_valid = false;
 	int i;
 
 	ath_print(common, ATH_DBG_CONFIG, "Detach Interface\n");
@@ -1548,7 +1548,15 @@ static void ath9k_remove_interface(struct ieee80211_hw *hw,
 			       "slot\n", __func__);
 			sc->beacon.bslot[i] = NULL;
 			sc->beacon.bslot_aphy[i] = NULL;
-		}
+		} else if (sc->beacon.bslot[i])
+			bs_valid = true;
+	}
+	if (!bs_valid && (sc->sc_ah->imask & ATH9K_INT_SWBA)) {
+		/* Disable SWBA interrupt */
+		sc->sc_ah->imask &= ~ATH9K_INT_SWBA;
+		ath9k_ps_wakeup(sc);
+		ath9k_hw_set_interrupts(sc->sc_ah, sc->sc_ah->imask);
+		ath9k_ps_restore(sc);
 	}
 
 	sc->nvifs--;
diff --git a/drivers/net/wireless/ath/ath9k/reg.h b/drivers/net/wireless/ath/ath9k/reg.h
index dddf579..2c6a22f 100644
--- a/drivers/net/wireless/ath/ath9k/reg.h
+++ b/drivers/net/wireless/ath/ath9k/reg.h
@@ -984,11 +984,13 @@ enum {
 #define AR9287_GPIO_IN_VAL_S                     11
 #define AR9271_GPIO_IN_VAL                       0xFFFF0000
 #define AR9271_GPIO_IN_VAL_S                     16
-#define AR9300_GPIO_IN_VAL                       0x0001FFFF
-#define AR9300_GPIO_IN_VAL_S                     0
 #define AR7010_GPIO_IN_VAL                       0x0000FFFF
 #define AR7010_GPIO_IN_VAL_S                     0
 
+#define AR_GPIO_IN				 0x404c
+#define AR9300_GPIO_IN_VAL                       0x0001FFFF
+#define AR9300_GPIO_IN_VAL_S                     0
+
 #define AR_GPIO_OE_OUT                           (AR_SREV_9300_20_OR_LATER(ah) ? 0x4050 : 0x404c)
 #define AR_GPIO_OE_OUT_DRV                       0x3
 #define AR_GPIO_OE_OUT_DRV_NO                    0x0
diff --git a/drivers/net/wireless/ath/carl9170/fw.c b/drivers/net/wireless/ath/carl9170/fw.c
index ae6c006..546b4e4 100644
--- a/drivers/net/wireless/ath/carl9170/fw.c
+++ b/drivers/net/wireless/ath/carl9170/fw.c
@@ -291,7 +291,8 @@ static int carl9170_fw(struct ar9170 *ar, const __u8 *data, size_t len)
 
 		if (SUPP(CARL9170FW_WLANTX_CAB)) {
 			ar->hw->wiphy->interface_modes |=
-				BIT(NL80211_IFTYPE_AP);
+				BIT(NL80211_IFTYPE_AP) |
+				BIT(NL80211_IFTYPE_P2P_GO);
 		}
 	}
 
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index a314c2c..dc7b30b 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -1631,7 +1631,8 @@ void *carl9170_alloc(size_t priv_size)
 	 * supports these modes. The code which will add the
 	 * additional interface_modes is in fw.c.
 	 */
-	hw->wiphy->interface_modes = BIT(NL80211_IFTYPE_STATION);
+	hw->wiphy->interface_modes = BIT(NL80211_IFTYPE_STATION) |
+				     BIT(NL80211_IFTYPE_P2P_CLIENT);
 
 	hw->flags |= IEEE80211_HW_RX_INCLUDES_FCS |
 		     IEEE80211_HW_REPORTS_TX_ACK_STATUS |
diff --git a/drivers/net/wireless/ath/carl9170/tx.c b/drivers/net/wireless/ath/carl9170/tx.c
index b575c86..7e6506a 100644
--- a/drivers/net/wireless/ath/carl9170/tx.c
+++ b/drivers/net/wireless/ath/carl9170/tx.c
@@ -810,7 +810,7 @@ static int carl9170_tx_prepare(struct ar9170 *ar, struct sk_buff *skb)
 
 	mac_tmp = cpu_to_le16(AR9170_TX_MAC_HW_DURATION |
 			      AR9170_TX_MAC_BACKOFF);
-	mac_tmp |= cpu_to_le16((hw_queue << AR9170_TX_MAC_QOS_S) &&
+	mac_tmp |= cpu_to_le16((hw_queue << AR9170_TX_MAC_QOS_S) &
 			       AR9170_TX_MAC_QOS);
 
 	no_ack = !!(info->flags & IEEE80211_TX_CTL_NO_ACK);
diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index e5685dc..b4de0ca 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -1170,7 +1170,6 @@ static void if_sdio_remove(struct sdio_func *func)
 	lbs_deb_sdio("call remove card\n");
 	lbs_stop_card(card->priv);
 	lbs_remove_card(card->priv);
-	card->priv->surpriseremoved = 1;
 
 	flush_workqueue(card->workqueue);
 	destroy_workqueue(card->workqueue);
diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
index 79bcb4e..ecd4d04 100644
--- a/drivers/net/wireless/libertas/if_spi.c
+++ b/drivers/net/wireless/libertas/if_spi.c
@@ -1055,7 +1055,6 @@ static int __devexit libertas_spi_remove(struct spi_device *spi)
 	lbs_stop_card(priv);
 	lbs_remove_card(priv); /* will call free_netdev */
 
-	priv->surpriseremoved = 1;
 	free_irq(spi->irq, card);
 	if_spi_terminate_spi_thread(card);
 	if (card->pdata->teardown)
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 46b88b1..fcd1bbf 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -915,8 +915,6 @@ void lbs_remove_card(struct lbs_private *priv)
 
 	lbs_free_adapter(priv);
 	lbs_cfg_free(priv);
-
-	priv->dev = NULL;
 	free_netdev(dev);
 
 	lbs_deb_leave(LBS_DEB_MAIN);
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index e8e2d0f..fa0cf74 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -1392,10 +1392,9 @@ static void orinoco_process_scan_results(struct work_struct *work)
 				orinoco_add_hostscan_results(priv, buf, len);
 
 			kfree(buf);
-		} else if (priv->scan_request) {
+		} else {
 			/* Either abort or complete the scan */
-			cfg80211_scan_done(priv->scan_request, (len < 0));
-			priv->scan_request = NULL;
+			orinoco_scan_done(priv, (len < 0));
 		}
 
 		spin_lock_irqsave(&priv->scan_lock, flags);
@@ -1684,6 +1683,8 @@ static int __orinoco_down(struct orinoco_private *priv)
 		hermes_write_regn(hw, EVACK, 0xffff);
 	}
 
+	orinoco_scan_done(priv, true);
+
 	/* firmware will have to reassociate */
 	netif_carrier_off(dev);
 	priv->last_linkstatus = 0xffff;
@@ -1762,10 +1763,7 @@ void orinoco_reset(struct work_struct *work)
 	orinoco_unlock(priv, &flags);
 
 	/* Scanning support: Notify scan cancellation */
-	if (priv->scan_request) {
-		cfg80211_scan_done(priv->scan_request, 1);
-		priv->scan_request = NULL;
-	}
+	orinoco_scan_done(priv, true);
 
 	if (priv->hard_reset) {
 		err = (*priv->hard_reset)(priv);
diff --git a/drivers/net/wireless/orinoco/scan.c b/drivers/net/wireless/orinoco/scan.c
index 4300d9d..86cb54c 100644
--- a/drivers/net/wireless/orinoco/scan.c
+++ b/drivers/net/wireless/orinoco/scan.c
@@ -229,3 +229,11 @@ void orinoco_add_hostscan_results(struct orinoco_private *priv,
 		priv->scan_request = NULL;
 	}
 }
+
+void orinoco_scan_done(struct orinoco_private *priv, bool abort)
+{
+	if (priv->scan_request) {
+		cfg80211_scan_done(priv->scan_request, abort);
+		priv->scan_request = NULL;
+	}
+}
diff --git a/drivers/net/wireless/orinoco/scan.h b/drivers/net/wireless/orinoco/scan.h
index 2dc4e04..27281fb 100644
--- a/drivers/net/wireless/orinoco/scan.h
+++ b/drivers/net/wireless/orinoco/scan.h
@@ -16,5 +16,6 @@ void orinoco_add_extscan_result(struct orinoco_private *priv,
 void orinoco_add_hostscan_results(struct orinoco_private *dev,
 				  unsigned char *buf,
 				  size_t len);
+void orinoco_scan_done(struct orinoco_private *priv, bool abort);
 
 #endif /* _ORINOCO_SCAN_H_ */
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index d0927d1..66b9e5c 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -882,7 +882,7 @@ static int sco_connect_ind(struct hci_dev *hdev, bdaddr_t *bdaddr, __u8 type)
 	int lm = 0;
 
 	if (type != SCO_LINK && type != ESCO_LINK)
-		return 0;
+		return -EINVAL;
 
 	BT_DBG("hdev %s, bdaddr %s", hdev->name, batostr(bdaddr));
 
@@ -908,7 +908,7 @@ static int sco_connect_cfm(struct hci_conn *hcon, __u8 status)
 	BT_DBG("hcon %p bdaddr %s status %d", hcon, batostr(&hcon->dst), status);
 
 	if (hcon->type != SCO_LINK && hcon->type != ESCO_LINK)
-		return 0;
+		return -EINVAL;
 
 	if (!status) {
 		struct sco_conn *conn;
@@ -927,7 +927,7 @@ static int sco_disconn_cfm(struct hci_conn *hcon, __u8 reason)
 	BT_DBG("hcon %p reason %d", hcon, reason);
 
 	if (hcon->type != SCO_LINK && hcon->type != ESCO_LINK)
-		return 0;
+		return -EINVAL;
 
 	sco_conn_del(hcon, bt_err(reason));
 
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 902b03e..54fb4a0e 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2247,6 +2247,10 @@ ieee80211_rx_h_mgmt(struct ieee80211_rx_data *rx)
 		break;
 	case cpu_to_le16(IEEE80211_STYPE_DEAUTH):
 	case cpu_to_le16(IEEE80211_STYPE_DISASSOC):
+		if (is_multicast_ether_addr(mgmt->da) &&
+		    !is_broadcast_ether_addr(mgmt->da))
+			return RX_DROP_MONITOR;
+
 		/* process only for station */
 		if (sdata->vif.type != NL80211_IFTYPE_STATION)
 			return RX_DROP_MONITOR;
@@ -2741,6 +2745,7 @@ static void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw,
 
 			if (ieee80211_prepare_and_rx_handle(&rx, skb, true))
 				return;
+			goto out;
 		}
 	}
 
@@ -2780,6 +2785,7 @@ static void __ieee80211_rx_handle_packet(struct ieee80211_hw *hw,
 			return;
 	}
 
+ out:
 	dev_kfree_skb(skb);
 }
 
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 96c5943..df6aac5 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1587,7 +1587,12 @@ static void ieee80211_xmit(struct ieee80211_sub_if_data *sdata,
 						list) {
 				if (!ieee80211_sdata_running(tmp_sdata))
 					continue;
-				if (tmp_sdata->vif.type != NL80211_IFTYPE_AP)
+				if (tmp_sdata->vif.type ==
+				    NL80211_IFTYPE_MONITOR ||
+				    tmp_sdata->vif.type ==
+				    NL80211_IFTYPE_AP_VLAN ||
+					tmp_sdata->vif.type ==
+				    NL80211_IFTYPE_WDS)
 					continue;
 				if (compare_ether_addr(tmp_sdata->vif.addr,
 						       hdr->addr2) == 0) {
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
