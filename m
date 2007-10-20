From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 19 Oct 2007 23:08:58 -0400
Message-ID: <20071020030858.GA20283@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:59242 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642AbXJTDI7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 23:08:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/Kconfig                         |   41 ++++-----------------
 drivers/net/dm9000.c                        |    6 ++--
 drivers/net/phy/mdio-bitbang.c              |    2 +
 drivers/net/tsi108_eth.c                    |    2 +-
 drivers/net/tulip/Kconfig                   |   14 +++----
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
 drivers/s390/net/qeth_main.c                |    3 +-
 23 files changed, 158 insertions(+), 133 deletions(-)

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

Mike Rapoport (1):
      DM9000 initialization fix

Olof Johansson (1):
      Fix build break in tsi108.c

Randy Dunlap (3):
      phy/bitbang: missing MODULE_LICENSE
      NAPI: kconfig prompt and deleted doc file
      ir-functions.c:(.text+0xbce18): undefined reference to `input_event'

Ron Rindjunsky (1):
      iwlwifi: set correct base rate for A band in rs_dbgfs_set_mcs

Tomas Winkler (1):
      iwlwifi: Fix rate setting in probe request for HW sacn

Ursula Braun (1):
      qeth: remove header_ops bug

WANG Cong (1):
      drivers/net/wireless/b43/main.c: fix an uninitialized variable

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 83d52c8..2cafa5c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1293,9 +1293,6 @@ config PCNET32_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config AMD8111_ETH
@@ -1313,7 +1310,7 @@ config AMD8111_ETH
 	  will be called amd8111e.
 
 config AMD8111E_NAPI
-	bool "Enable NAPI support"
+	bool "Use RX polling (NAPI)"
 	depends on AMD8111_ETH
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
@@ -1324,9 +1321,6 @@ config AMD8111E_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config ADAPTEC_STARFIRE
@@ -1355,9 +1349,6 @@ config ADAPTEC_STARFIRE_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config AC3200
@@ -1431,7 +1422,7 @@ config FORCEDETH
 	  called forcedeth.
 
 config FORCEDETH_NAPI
-	bool "Use Rx and Tx Polling (NAPI) (EXPERIMENTAL)"
+	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
 	depends on FORCEDETH && EXPERIMENTAL
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
@@ -1442,9 +1433,6 @@ config FORCEDETH_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config CS89x0
@@ -1756,9 +1744,6 @@ config VIA_RHINE_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 config LAN_SAA9730
 	bool "Philips SAA9730 Ethernet support"
 	depends on NET_PCI && PCI && MIPS_ATLAS
@@ -2003,9 +1988,6 @@ config E1000_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config E1000_DISABLE_PACKET_SPLIT
@@ -2099,7 +2081,7 @@ config R8169
 	  will be called r8169.  This is recommended.
 
 config R8169_NAPI
-	bool "Use Rx and Tx Polling (NAPI) (EXPERIMENTAL)"
+	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
 	depends on R8169 && EXPERIMENTAL
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
@@ -2110,9 +2092,6 @@ config R8169_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config R8169_VLAN
@@ -2364,7 +2343,7 @@ config GIANFAR
 	  and MPC86xx family of chips, and the FEC on the 8540.
 
 config GFAR_NAPI
-	bool "NAPI Support"
+	bool "Use Rx Polling (NAPI)"
 	depends on GIANFAR
 
 config UCC_GETH
@@ -2376,7 +2355,7 @@ config UCC_GETH
 	  which is available on some Freescale SOCs.
 
 config UGETH_NAPI
-	bool "NAPI Support"
+	bool "Use Rx Polling (NAPI)"
 	depends on UCC_GETH
 
 config UGETH_MAGIC_PACKET
@@ -2494,7 +2473,7 @@ config CHELSIO_T3
 
 config EHEA
 	tristate "eHEA Ethernet support"
-	depends on IBMEBUS
+	depends on IBMEBUS && INET
 	select INET_LRO
 	---help---
 	  This driver supports the IBM pSeries eHEA ethernet adapter.
@@ -2559,9 +2538,6 @@ config IXGB_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config S2IO
@@ -2584,14 +2560,11 @@ config S2IO_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config MYRI10GE
 	tristate "Myricom Myri-10G Ethernet support"
-	depends on PCI
+	depends on PCI && INET
 	select FW_LOADER
 	select CRC32
 	select INET_LRO
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 27ac010..3286d2a 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -542,7 +542,8 @@ dm9000_probe(struct platform_device *pdev)
 
 	if (id_val != DM9000_ID) {
 		printk("%s: wrong id: 0x%08x\n", CARDNAME, id_val);
-		goto release;
+		ret = -ENODEV;
+		goto out;
 	}
 
 	/* from this point we assume that we have found a DM9000 */
@@ -602,8 +603,7 @@ dm9000_probe(struct platform_device *pdev)
 	}
 	return 0;
 
- release:
- out:
+out:
 	printk("%s: not found (%d).\n", CARDNAME, ret);
 
 	dm9000_release_board(pdev, db);
diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
index 8cd243d..2747b1f 100644
--- a/drivers/net/phy/mdio-bitbang.c
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -185,3 +185,5 @@ void free_mdio_bitbang(struct mii_bus *bus)
 	module_put(ctrl->ops->owner);
 	kfree(bus);
 }
+
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index df10af7..35d15e8 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1629,7 +1629,7 @@ tsi108_init_one(struct platform_device *pdev)
 		goto register_fail;
 	}
 
-	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: %s\n"
+	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: %s\n",
 	       dev->name, print_mac(mac, dev->dev_addr));
 #ifdef DEBUG
 	data->msg_enable = DEBUG;
diff --git a/drivers/net/tulip/Kconfig b/drivers/net/tulip/Kconfig
index 1c537d5..49d7a29 100644
--- a/drivers/net/tulip/Kconfig
+++ b/drivers/net/tulip/Kconfig
@@ -67,7 +67,7 @@ config TULIP_MMIO
 	  If in doubt, say N.
 
 config TULIP_NAPI
-	bool "Use NAPI RX polling "
+	bool "Use RX polling (NAPI)"
 	depends on TULIP
 	help
 	  NAPI is a new driver API designed to reduce CPU and interrupt load
@@ -78,18 +78,16 @@ config TULIP_NAPI
 	  deployed on potentially unfriendly networks (e.g. in a firewall),
 	  then say Y here.
 
-	  See <file:Documentation/networking/NAPI_HOWTO.txt> for more
-	  information.
-
 	  If in doubt, say N.
 
 config TULIP_NAPI_HW_MITIGATION
-	bool "Use Interrupt Mitigation "
+	bool "Use Interrupt Mitigation"
 	depends on TULIP_NAPI
 	---help---
-	  Use HW to reduce RX interrupts. Not strict necessary since NAPI reduces
-	  RX interrupts but itself. Although this reduces RX interrupts even at
-	  low levels traffic at the cost of a small latency.
+	  Use HW to reduce RX interrupts. Not strictly necessary since NAPI
+	  reduces RX interrupts by itself. Interrupt mitigation reduces RX
+	  interrupts even at low levels of traffic at the cost of a small
+	  latency.
 
 	  If in doubt, say Y.
 
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
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index a2d08c9..ff999ff 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -6643,7 +6643,8 @@ qeth_netdev_init(struct net_device *dev)
 	dev->vlan_rx_kill_vid = qeth_vlan_rx_kill_vid;
 	dev->vlan_rx_add_vid = qeth_vlan_rx_add_vid;
 #endif
-	dev->header_ops = &qeth_null_ops;
+	if (qeth_get_netdev_flags(card) & IFF_NOARP)
+		dev->header_ops = &qeth_null_ops;
 
 #ifdef CONFIG_QETH_IPV6
 	/*IPv6 address autoconfiguration stuff*/
