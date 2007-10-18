From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Thu, 18 Oct 2007 18:09:46 -0400
Message-ID: <20071018220946.GH8510@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3313 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933080AbXJRWjb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 18:39:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Some bug fixes for 2.6.24.  There is also a USB ID for rt2x00, a
one-liner -- it would seem like a bug fix if you owned that device. :-)

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/fixes-jgarzik

---

The following changes since commit 4937ce87959629d31e9b09cf5bdf1e12a305c805:
  Linus Torvalds (1):
        Merge branch 'release' of git://git.kernel.org/.../aegl/linux-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

Adrian Bunk (1):
      iwl4965-base.c: fix off-by-one errors

Dan Williams (1):
      ipw2100: send WEXT scan events

Holger Schurig (1):
      janitorial: fix all double includes in drivers/net/wireless

Ivo van Doorn (1):
      rt2x00: Add new rt73usb USB ID

John W. Linville (1):
      zd1201: avoid null ptr access of skb->dev

Larry Finger (1):
      b43legacy: Fix potential return of uninitialized variable

Marc Pignat (1):
      zd1211rw, fix oops when ejecting install media

Mattias Nissler (1):
      rt2x00: Fix residual check in PLCP calculations.

Michael Buesch (1):
      b43: Make b43_stop() static

Michael Wu (3):
      rtl8187: Fix more frag bit checking, rts duration calc
      rtl8187: remove NICMAC setting in configure_filters callback
      p54: Make filter configuration atomic

Ron Rindjunsky (1):
      iwlwifi: set correct base rate for A band in rs_dbgfs_set_mcs

Tomas Winkler (1):
      iwlwifi: Fix rate setting in probe request for HW sacn

WANG Cong (1):
      drivers/net/wireless/b43/main.c: fix an uninitialized variable

 drivers/net/wireless/b43/main.c             |    5 +--
 drivers/net/wireless/b43legacy/main.c       |    2 +-
 drivers/net/wireless/ipw2100.c              |   39 ++++++++++++++++++++
 drivers/net/wireless/ipw2100.h              |    4 ++
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c  |    3 --
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    1 -
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c  |   13 ++++---
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    2 -
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   44 +++++++++++++---------
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   52 +++++++++++++++-----------
 drivers/net/wireless/iwlwifi/iwlwifi.h      |    7 +---
 drivers/net/wireless/p54common.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c       |    1 +
 drivers/net/wireless/rtl8187_dev.c          |   35 ++++++++----------
 drivers/net/wireless/zd1201.c               |    4 +-
 drivers/net/wireless/zd1211rw/zd_usb.c      |    7 +++-
 17 files changed, 137 insertions(+), 86 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index c141a26..9d9ff76 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -49,7 +49,6 @@
 #include "pio.h"
 #include "sysfs.h"
 #include "xmit.h"
-#include "sysfs.h"
 #include "lo.h"
 #include "pcmcia.h"
 
@@ -3495,7 +3494,7 @@ static int b43_start(struct ieee80211_hw *hw)
 	struct b43_wl *wl = hw_to_b43_wl(hw);
 	struct b43_wldev *dev = wl->current_dev;
 	int did_init = 0;
-	int err;
+	int err = 0;
 
 	mutex_lock(&wl->mutex);
 
@@ -3521,7 +3520,7 @@ static int b43_start(struct ieee80211_hw *hw)
 	return err;
 }
 
-void b43_stop(struct ieee80211_hw *hw)
+static void b43_stop(struct ieee80211_hw *hw)
 {
 	struct b43_wl *wl = hw_to_b43_wl(hw);
 	struct b43_wldev *dev = wl->current_dev;
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index f074951..d09479e 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -3306,7 +3306,7 @@ static int b43legacy_start(struct ieee80211_hw *hw)
 	struct b43legacy_wl *wl = hw_to_b43legacy_wl(hw);
 	struct b43legacy_wldev *dev = wl->current_dev;
 	int did_init = 0;
-	int err;
+	int err = 0;
 
 	mutex_lock(&wl->mutex);
 
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 2d46a16..2fa8eed 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -2105,12 +2105,46 @@ static void isr_indicate_rf_kill(struct ipw2100_priv *priv, u32 status)
 	queue_delayed_work(priv->workqueue, &priv->rf_kill, round_jiffies(HZ));
 }
 
+static void send_scan_event(void *data)
+{
+	struct ipw2100_priv *priv = data;
+	union iwreq_data wrqu;
+
+	wrqu.data.length = 0;
+	wrqu.data.flags = 0;
+	wireless_send_event(priv->net_dev, SIOCGIWSCAN, &wrqu, NULL);
+}
+
+static void ipw2100_scan_event_later(struct work_struct *work)
+{
+	send_scan_event(container_of(work, struct ipw2100_priv,
+					scan_event_later.work));
+}
+
+static void ipw2100_scan_event_now(struct work_struct *work)
+{
+	send_scan_event(container_of(work, struct ipw2100_priv,
+					scan_event_now));
+}
+
 static void isr_scan_complete(struct ipw2100_priv *priv, u32 status)
 {
 	IPW_DEBUG_SCAN("scan complete\n");
 	/* Age the scan results... */
 	priv->ieee->scans++;
 	priv->status &= ~STATUS_SCANNING;
+
+	/* Only userspace-requested scan completion events go out immediately */
+	if (!priv->user_requested_scan) {
+		if (!delayed_work_pending(&priv->scan_event_later))
+			queue_delayed_work(priv->workqueue,
+					&priv->scan_event_later,
+					round_jiffies(msecs_to_jiffies(4000)));
+	} else {
+		priv->user_requested_scan = 0;
+		cancel_delayed_work(&priv->scan_event_later);
+		queue_work(priv->workqueue, &priv->scan_event_now);
+	}
 }
 
 #ifdef CONFIG_IPW2100_DEBUG
@@ -4378,6 +4412,7 @@ static void ipw2100_kill_workqueue(struct ipw2100_priv *priv)
 		cancel_delayed_work(&priv->wx_event_work);
 		cancel_delayed_work(&priv->hang_check);
 		cancel_delayed_work(&priv->rf_kill);
+		cancel_delayed_work(&priv->scan_event_later);
 		destroy_workqueue(priv->workqueue);
 		priv->workqueue = NULL;
 	}
@@ -6121,6 +6156,8 @@ static struct net_device *ipw2100_alloc_device(struct pci_dev *pci_dev,
 	INIT_DELAYED_WORK(&priv->wx_event_work, ipw2100_wx_event_work);
 	INIT_DELAYED_WORK(&priv->hang_check, ipw2100_hang_check);
 	INIT_DELAYED_WORK(&priv->rf_kill, ipw2100_rf_kill);
+	INIT_WORK(&priv->scan_event_now, ipw2100_scan_event_now);
+	INIT_DELAYED_WORK(&priv->scan_event_later, ipw2100_scan_event_later);
 
 	tasklet_init(&priv->irq_tasklet, (void (*)(unsigned long))
 		     ipw2100_irq_tasklet, (unsigned long)priv);
@@ -7425,6 +7462,8 @@ static int ipw2100_wx_set_scan(struct net_device *dev,
 	}
 
 	IPW_DEBUG_WX("Initiating scan...\n");
+
+	priv->user_requested_scan = 1;
 	if (ipw2100_set_scan_options(priv) || ipw2100_start_scan(priv)) {
 		IPW_DEBUG_WX("Start scan failed.\n");
 
diff --git a/drivers/net/wireless/ipw2100.h b/drivers/net/wireless/ipw2100.h
index de7d384..1ee3348 100644
--- a/drivers/net/wireless/ipw2100.h
+++ b/drivers/net/wireless/ipw2100.h
@@ -588,6 +588,10 @@ struct ipw2100_priv {
 	struct delayed_work wx_event_work;
 	struct delayed_work hang_check;
 	struct delayed_work rf_kill;
+	struct work_struct scan_event_now;
+	struct delayed_work scan_event_later;
+
+	int user_requested_scan;
 
 	u32 interrupts;
 	int tx_interrupts;
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
index f4aabcf..262ab0b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
@@ -37,9 +37,6 @@
 
 #include <linux/workqueue.h>
 
-#include <net/mac80211.h>
-#include <linux/wireless.h>
-
 #define IWL 3945
 
 #include "../net/mac80211/ieee80211_rate.h"
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index acb3875..19bcb01 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -38,7 +38,6 @@
 #include <net/mac80211.h>
 
 #include <linux/etherdevice.h>
-#include <linux/delay.h>
 
 #define IWL 3945
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
index 287c757..8dc78c0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965-rs.c
@@ -36,9 +36,6 @@
 
 #include <linux/workqueue.h>
 
-#include <net/mac80211.h>
-#include <linux/wireless.h>
-
 #define IWL 4965
 
 #include "../net/mac80211/ieee80211_rate.h"
@@ -2024,12 +2021,18 @@ static int open_file_generic(struct inode *inode, struct file *file)
 static void rs_dbgfs_set_mcs(struct iwl_rate_scale_priv *rs_priv,
 				struct iwl_rate *mcs, int index)
 {
-	const u32 cck_rate = 0x820A;
+	u32 base_rate;
+
+	if (rs_priv->phymode == (u8) MODE_IEEE80211A)
+		base_rate = 0x800D;
+	else
+		base_rate = 0x820A;
+
 	if (rs_priv->dbg_fixed.rate_n_flags) {
 		if (index < 12)
 			mcs->rate_n_flags = rs_priv->dbg_fixed.rate_n_flags;
 		else
-			mcs->rate_n_flags = cck_rate;
+			mcs->rate_n_flags = base_rate;
 		IWL_DEBUG_RATE("Fixed rate ON\n");
 		return;
 	}
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index b50d202..557deeb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -35,9 +35,7 @@
 #include <linux/netdevice.h>
 #include <linux/wireless.h>
 #include <net/mac80211.h>
-#include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/delay.h>
 
 #define IWL 4965
 
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 75e3b5c..83019d1 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -48,8 +48,6 @@
 #include <linux/netdevice.h>
 #include <linux/wireless.h>
 #include <linux/firmware.h>
-#include <linux/skbuff.h>
-#include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 
@@ -1749,21 +1747,22 @@ static void iwl_unset_hw_setting(struct iwl_priv *priv)
  * return : set the bit for each supported rate insert in ie
  */
 static u16 iwl_supported_rate_to_ie(u8 *ie, u16 supported_rate,
-				    u16 basic_rate, int max_count)
+				    u16 basic_rate, int *left)
 {
 	u16 ret_rates = 0, bit;
 	int i;
-	u8 *rates;
-
-	rates = &(ie[1]);
+	u8 *cnt = ie;
+	u8 *rates = ie + 1;
 
 	for (bit = 1, i = 0; i < IWL_RATE_COUNT; i++, bit <<= 1) {
 		if (bit & supported_rate) {
 			ret_rates |= bit;
-			rates[*ie] = iwl_rates[i].ieee |
-			    ((bit & basic_rate) ? 0x80 : 0x00);
-			*ie = *ie + 1;
-			if (*ie >= max_count)
+			rates[*cnt] = iwl_rates[i].ieee |
+				((bit & basic_rate) ? 0x80 : 0x00);
+			(*cnt)++;
+			(*left)--;
+			if ((*left <= 0) ||
+			    (*cnt >= IWL_SUPPORTED_RATES_IE_LEN))
 				break;
 		}
 	}
@@ -1780,7 +1779,7 @@ static u16 iwl_fill_probe_req(struct iwl_priv *priv,
 {
 	int len = 0;
 	u8 *pos = NULL;
-	u16 ret_rates;
+	u16 active_rates, ret_rates, cck_rates;
 
 	/* Make sure there is enough space for the probe request,
 	 * two mandatory IEs and the data */
@@ -1825,19 +1824,27 @@ static u16 iwl_fill_probe_req(struct iwl_priv *priv,
 	left -= 2;
 	if (left < 0)
 		return 0;
+
 	/* ... fill it in... */
 	*pos++ = WLAN_EID_SUPP_RATES;
 	*pos = 0;
-	ret_rates = priv->active_rate = priv->rates_mask;
+
+	priv->active_rate = priv->rates_mask;
+	active_rates = priv->active_rate;
 	priv->active_rate_basic = priv->rates_mask & IWL_BASIC_RATES_MASK;
 
-	iwl_supported_rate_to_ie(pos, priv->active_rate,
-				 priv->active_rate_basic, left);
+	cck_rates = IWL_CCK_RATES_MASK & active_rates;
+	ret_rates = iwl_supported_rate_to_ie(pos, cck_rates,
+			priv->active_rate_basic, &left);
+	active_rates &= ~ret_rates;
+
+	ret_rates = iwl_supported_rate_to_ie(pos, active_rates,
+				 priv->active_rate_basic, &left);
+	active_rates &= ~ret_rates;
+
 	len += 2 + *pos;
 	pos += (*pos) + 1;
-	ret_rates = ~ret_rates & priv->active_rate;
-
-	if (ret_rates == 0)
+	if (active_rates == 0)
 		goto fill_end;
 
 	/* fill in supported extended rate */
@@ -1848,7 +1855,8 @@ static u16 iwl_fill_probe_req(struct iwl_priv *priv,
 	/* ... fill it in... */
 	*pos++ = WLAN_EID_EXT_SUPP_RATES;
 	*pos = 0;
-	iwl_supported_rate_to_ie(pos, ret_rates, priv->active_rate_basic, left);
+	iwl_supported_rate_to_ie(pos, active_rates,
+				 priv->active_rate_basic, &left);
 	if (*pos > 0)
 		len += 2 + *pos;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index b1a6e39..5e12792 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -48,8 +48,6 @@
 #include <linux/netdevice.h>
 #include <linux/wireless.h>
 #include <linux/firmware.h>
-#include <linux/skbuff.h>
-#include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/if_arp.h>
 
@@ -1802,21 +1800,22 @@ static void iwl_unset_hw_setting(struct iwl_priv *priv)
  * return : set the bit for each supported rate insert in ie
  */
 static u16 iwl_supported_rate_to_ie(u8 *ie, u16 supported_rate,
-				    u16 basic_rate, int max_count)
+				    u16 basic_rate, int *left)
 {
 	u16 ret_rates = 0, bit;
 	int i;
-	u8 *rates;
-
-	rates = &(ie[1]);
+	u8 *cnt = ie;
+	u8 *rates = ie + 1;
 
 	for (bit = 1, i = 0; i < IWL_RATE_COUNT; i++, bit <<= 1) {
 		if (bit & supported_rate) {
 			ret_rates |= bit;
-			rates[*ie] = iwl_rates[i].ieee |
-			    ((bit & basic_rate) ? 0x80 : 0x00);
-			*ie = *ie + 1;
-			if (*ie >= max_count)
+			rates[*cnt] = iwl_rates[i].ieee |
+				((bit & basic_rate) ? 0x80 : 0x00);
+			(*cnt)++;
+			(*left)--;
+			if ((*left <= 0) ||
+			    (*cnt >= IWL_SUPPORTED_RATES_IE_LEN))
 				break;
 		}
 	}
@@ -1839,7 +1838,7 @@ static u16 iwl_fill_probe_req(struct iwl_priv *priv,
 {
 	int len = 0;
 	u8 *pos = NULL;
-	u16 ret_rates;
+	u16 active_rates, ret_rates, cck_rates;
 
 	/* Make sure there is enough space for the probe request,
 	 * two mandatory IEs and the data */
@@ -1884,19 +1883,27 @@ static u16 iwl_fill_probe_req(struct iwl_priv *priv,
 	left -= 2;
 	if (left < 0)
 		return 0;
+
 	/* ... fill it in... */
 	*pos++ = WLAN_EID_SUPP_RATES;
 	*pos = 0;
-	ret_rates = priv->active_rate = priv->rates_mask;
+
+	priv->active_rate = priv->rates_mask;
+	active_rates = priv->active_rate;
 	priv->active_rate_basic = priv->rates_mask & IWL_BASIC_RATES_MASK;
 
-	iwl_supported_rate_to_ie(pos, priv->active_rate,
-				 priv->active_rate_basic, left);
+	cck_rates = IWL_CCK_RATES_MASK & active_rates;
+	ret_rates = iwl_supported_rate_to_ie(pos, cck_rates,
+			priv->active_rate_basic, &left);
+	active_rates &= ~ret_rates;
+
+	ret_rates = iwl_supported_rate_to_ie(pos, active_rates,
+				 priv->active_rate_basic, &left);
+	active_rates &= ~ret_rates;
+
 	len += 2 + *pos;
 	pos += (*pos) + 1;
-	ret_rates = ~ret_rates & priv->active_rate;
-
-	if (ret_rates == 0)
+	if (active_rates == 0)
 		goto fill_end;
 
 	/* fill in supported extended rate */
@@ -1907,7 +1914,8 @@ static u16 iwl_fill_probe_req(struct iwl_priv *priv,
 	/* ... fill it in... */
 	*pos++ = WLAN_EID_EXT_SUPP_RATES;
 	*pos = 0;
-	iwl_supported_rate_to_ie(pos, ret_rates, priv->active_rate_basic, left);
+	iwl_supported_rate_to_ie(pos, active_rates,
+				 priv->active_rate_basic, &left);
 	if (*pos > 0)
 		len += 2 + *pos;
 
@@ -4494,13 +4502,13 @@ static u8 ratio2dB[100] = {
  * Conversion assumes that levels are voltages (20*log), not powers (10*log). */
 int iwl_calc_db_from_ratio(int sig_ratio)
 {
-	/* Anything above 1000:1 just report as 60 dB */
-	if (sig_ratio > 1000)
+	/* 1000:1 or higher just report as 60 dB */
+	if (sig_ratio >= 1000)
 		return 60;
 
-	/* Above 100:1, divide by 10 and use table,
+	/* 100:1 or higher, divide by 10 and use table,
 	 *   add 20 dB to make up for divide by 10 */
-	if (sig_ratio > 100)
+	if (sig_ratio >= 100)
 		return (20 + (int)ratio2dB[sig_ratio/10]);
 
 	/* We shouldn't see this */
diff --git a/drivers/net/wireless/iwlwifi/iwlwifi.h b/drivers/net/wireless/iwlwifi/iwlwifi.h
index e0b97c3..432ce88 100644
--- a/drivers/net/wireless/iwlwifi/iwlwifi.h
+++ b/drivers/net/wireless/iwlwifi/iwlwifi.h
@@ -39,18 +39,13 @@ struct iwl_priv;
 /* Hardware specific file defines the PCI IDs table for that hardware module */
 extern struct pci_device_id iwl_hw_card_ids[];
 
+#include "iwl-hw.h"
 #if IWL == 3945
-
 #define DRV_NAME	"iwl3945"
-#include "iwl-hw.h"
 #include "iwl-3945-hw.h"
-
 #elif IWL == 4965
-
 #define DRV_NAME        "iwl4965"
-#include "iwl-hw.h"
 #include "iwl-4965-hw.h"
-
 #endif
 
 #include "iwl-prph.h"
diff --git a/drivers/net/wireless/p54common.c b/drivers/net/wireless/p54common.c
index 2c63cf0..1437db0 100644
--- a/drivers/net/wireless/p54common.c
+++ b/drivers/net/wireless/p54common.c
@@ -577,7 +577,7 @@ static int p54_set_filter(struct ieee80211_hw *dev, u16 filter_type,
 	struct p54_tx_control_filter *filter;
 
 	hdr = kzalloc(sizeof(*hdr) + sizeof(*filter) +
-		      priv->tx_hdr_len, GFP_KERNEL);
+		      priv->tx_hdr_len, GFP_ATOMIC);
 	if (!hdr)
 		return -ENOMEM;
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index bb6f46c..ff399f8 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -550,7 +550,7 @@ void rt2x00lib_write_tx_desc(struct rt2x00_dev *rt2x00dev,
 			/*
 			 * Check if we need to set the Length Extension
 			 */
-			if (bitrate == 110 && residual <= 3)
+			if (bitrate == 110 && residual <= 30)
 				desc.service |= 0x80;
 		}
 
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index 3e42759..46c8c08 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -2029,6 +2029,7 @@ static struct usb_device_id rt73usb_device_table[] = {
 	{ USB_DEVICE(0x050d, 0x7050), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x050d, 0x705a), USB_DEVICE_DATA(&rt73usb_ops) },
 	{ USB_DEVICE(0x050d, 0x905b), USB_DEVICE_DATA(&rt73usb_ops) },
+	{ USB_DEVICE(0x050d, 0x905c), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Billionton */
 	{ USB_DEVICE(0x1631, 0xc019), USB_DEVICE_DATA(&rt73usb_ops) },
 	/* Buffalo */
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index 0ef887d..de61c8f 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -131,7 +131,8 @@ static int rtl8187_tx(struct ieee80211_hw *dev, struct sk_buff *skb,
 	struct rtl8187_tx_hdr *hdr;
 	struct rtl8187_tx_info *info;
 	struct urb *urb;
-	u32 tmp;
+	__le16 rts_dur = 0;
+	u32 flags;
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
@@ -139,24 +140,24 @@ static int rtl8187_tx(struct ieee80211_hw *dev, struct sk_buff *skb,
 		return 0;
 	}
 
-	hdr = (struct rtl8187_tx_hdr *)skb_push(skb, sizeof(*hdr));
-	tmp = skb->len - sizeof(*hdr);
-	tmp |= RTL8187_TX_FLAG_NO_ENCRYPT;
-	tmp |= control->rts_cts_rate << 19;
-	tmp |= control->tx_rate << 24;
-	if (ieee80211_get_morefrag((struct ieee80211_hdr *)skb))
-		tmp |= RTL8187_TX_FLAG_MORE_FRAG;
+	flags = skb->len;
+	flags |= RTL8187_TX_FLAG_NO_ENCRYPT;
+	flags |= control->rts_cts_rate << 19;
+	flags |= control->tx_rate << 24;
+	if (ieee80211_get_morefrag((struct ieee80211_hdr *)skb->data))
+		flags |= RTL8187_TX_FLAG_MORE_FRAG;
 	if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS) {
-		tmp |= RTL8187_TX_FLAG_RTS;
-		hdr->rts_duration =
-			ieee80211_rts_duration(dev, priv->if_id, skb->len, control);
+		flags |= RTL8187_TX_FLAG_RTS;
+		rts_dur = ieee80211_rts_duration(dev, priv->if_id, skb->len, control);
 	}
 	if (control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)
-		tmp |= RTL8187_TX_FLAG_CTS;
-	hdr->flags = cpu_to_le32(tmp);
+		flags |= RTL8187_TX_FLAG_CTS;
+
+	hdr = (struct rtl8187_tx_hdr *)skb_push(skb, sizeof(*hdr));
+	hdr->flags = cpu_to_le32(flags);
 	hdr->len = 0;
-	tmp = control->retry_limit << 8;
-	hdr->retry = cpu_to_le32(tmp);
+	hdr->rts_duration = rts_dur;
+	hdr->retry = cpu_to_le32(control->retry_limit << 8);
 
 	info = (struct rtl8187_tx_info *)skb->cb;
 	info->control = kmemdup(control, sizeof(*control), GFP_ATOMIC);
@@ -587,8 +588,6 @@ static void rtl8187_configure_filter(struct ieee80211_hw *dev,
 
 	*total_flags = 0;
 
-	if (changed_flags & FIF_PROMISC_IN_BSS)
-		priv->rx_conf ^= RTL818X_RX_CONF_NICMAC;
 	if (changed_flags & FIF_ALLMULTI)
 		priv->rx_conf ^= RTL818X_RX_CONF_MULTICAST;
 	if (changed_flags & FIF_FCSFAIL)
@@ -601,8 +600,6 @@ static void rtl8187_configure_filter(struct ieee80211_hw *dev,
 	if (mc_count > 0)
 		priv->rx_conf |= RTL818X_RX_CONF_MULTICAST;
 
-	if (priv->rx_conf & RTL818X_RX_CONF_NICMAC)
-		*total_flags |= FIF_PROMISC_IN_BSS;
 	if (priv->rx_conf & RTL818X_RX_CONF_MULTICAST)
 		*total_flags |= FIF_ALLMULTI;
 	if (priv->rx_conf & RTL818X_RX_CONF_FCS)
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 935b144..d5c0c66 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -327,8 +327,8 @@ static void zd1201_usbrx(struct urb *urb)
 			memcpy(skb_put(skb, 6), &data[datalen-8], 6);
 			memcpy(skb_put(skb, 2), &data[datalen-24], 2);
 			memcpy(skb_put(skb, len), data, len);
-			skb->dev->last_rx = jiffies;
 			skb->protocol = eth_type_trans(skb, zd->dev);
+			skb->dev->last_rx = jiffies;
 			zd->stats.rx_packets++;
 			zd->stats.rx_bytes += skb->len;
 			netif_rx(skb);
@@ -384,8 +384,8 @@ static void zd1201_usbrx(struct urb *urb)
 			memcpy(skb_put(skb, 2), &data[6], 2);
 			memcpy(skb_put(skb, len), data+8, len);
 		}
-		skb->dev->last_rx = jiffies;
 		skb->protocol = eth_type_trans(skb, zd->dev);
+		skb->dev->last_rx = jiffies;
 		zd->stats.rx_packets++;
 		zd->stats.rx_bytes += skb->len;
 		netif_rx(skb);
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index b0684f9..c755b69 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -1044,14 +1044,17 @@ error:
 static void disconnect(struct usb_interface *intf)
 {
 	struct net_device *netdev = zd_intf_to_netdev(intf);
-	struct zd_mac *mac = zd_netdev_mac(netdev);
-	struct zd_usb *usb = &mac->chip.usb;
+	struct zd_mac *mac;
+	struct zd_usb *usb;
 
 	/* Either something really bad happened, or we're just dealing with
 	 * a DEVICE_INSTALLER. */
 	if (netdev == NULL)
 		return;
 
+	mac = zd_netdev_mac(netdev);
+	usb = &mac->chip.usb;
+
 	dev_dbg_f(zd_usb_dev(usb), "\n");
 
 	zd_netdev_disconnect(netdev);
-- 
John W. Linville
linville@tuxdriver.com
