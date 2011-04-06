From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2011-04-06
Date: Wed, 6 Apr 2011 16:00:33 -0400
Message-ID: <20110406200032.GK11941@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another batch of fixes intended for 2.6.39...

This includes a fix to avoid receiving duplicate frames in "cooked"
monitor mode, a mac80211 documentation fix to avoid developer
confusion, an rt2x00 fix to avoid cancelling some uninitialized work,
a wl12xx buffer overflow fix, an email address correction for wl12xx
module info, a zd1211rw regression fix, a zd1211rw WARNING fix,
and rtlwifi fix to avoid using some uninitialized variables, a fix
to broaden the iwl600 hardware supported by iwlagn to match what the
Windows driver is supporting, a b43 fix to allocate properly sized
receive buffers, and some stuff related to device IDs.

Please let me know if there are problems!

John

---

The following changes since commit 738faca34335cd1d5d87fa7c58703139c7fa15bd:

  ipv6: Don't pass invalid dst_entry pointer to dst_release(). (2011-04-04 13:07:26 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (1):
      p54usb: IDs for two new devices

Helmut Schaa (1):
      mac80211: Fix duplicate frames on cooked monitor

Johannes Berg (1):
      mac80211: fix comment regarding aggregation buf_size

John W. Linville (2):
      b43: allocate receive buffers big enough for max frame len + offset
      iwlwifi: accept EEPROM version 0x423 for iwl6000

Jussi Kivilinna (2):
      zd1211rw: remove URB_SHORT_NOT_OK flag in zd_usb_iowrite16v_async()
      zd1211rw: reset rx idle timer from tasklet

Larry Finger (1):
      rtlwifi: Fix some warnings/bugs

Luciano Coelho (2):
      wl12xx: fix module author's email address in the spi and sdio modules
      wl12xx: fix potential buffer overflow in testmode nvs push

Senthil Balasubramanian (1):
      ath9k: Fix phy info print message with AR9485 chipset.

Stanislaw Gruszka (1):
      rt2x00: fix cancelling uninitialized work

 drivers/net/wireless/ath/ath9k/hw.c               |    1 +
 drivers/net/wireless/b43/dma.c                    |    2 +-
 drivers/net/wireless/b43/dma.h                    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h         |    2 +-
 drivers/net/wireless/p54/p54usb.c                 |    2 ++
 drivers/net/wireless/rt2x00/rt2x00dev.c           |    6 ++++--
 drivers/net/wireless/rtlwifi/efuse.c              |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c |    2 +-
 drivers/net/wireless/rtlwifi/usb.c                |    2 +-
 drivers/net/wireless/wl12xx/sdio.c                |    2 +-
 drivers/net/wireless/wl12xx/spi.c                 |    2 +-
 drivers/net/wireless/wl12xx/testmode.c            |    5 ++++-
 drivers/net/wireless/zd1211rw/zd_usb.c            |   20 ++++++++++++++++++--
 drivers/net/wireless/zd1211rw/zd_usb.h            |    1 +
 include/net/mac80211.h                            |   15 +++++++++++++--
 net/mac80211/rx.c                                 |    2 +-
 16 files changed, 52 insertions(+), 16 deletions(-)
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 338b075..1ec9bcd 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -2546,6 +2546,7 @@ static struct {
 	{ AR_SREV_VERSION_9287,         "9287" },
 	{ AR_SREV_VERSION_9271,         "9271" },
 	{ AR_SREV_VERSION_9300,         "9300" },
+	{ AR_SREV_VERSION_9485,         "9485" },
 };
 
 /* For devices with external radios */
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 3d5566e..ff0f5ba 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -1536,7 +1536,7 @@ static void dma_rx(struct b43_dmaring *ring, int *slot)
 		dmaaddr = meta->dmaaddr;
 		goto drop_recycle_buffer;
 	}
-	if (unlikely(len > ring->rx_buffersize)) {
+	if (unlikely(len + ring->frameoffset > ring->rx_buffersize)) {
 		/* The data did not fit into one descriptor buffer
 		 * and is split over multiple buffers.
 		 * This should never happen, as we try to allocate buffers
diff --git a/drivers/net/wireless/b43/dma.h b/drivers/net/wireless/b43/dma.h
index a01c210..e8a80a1 100644
--- a/drivers/net/wireless/b43/dma.h
+++ b/drivers/net/wireless/b43/dma.h
@@ -163,7 +163,7 @@ struct b43_dmadesc_generic {
 /* DMA engine tuning knobs */
 #define B43_TXRING_SLOTS		256
 #define B43_RXRING_SLOTS		64
-#define B43_DMA0_RX_BUFFERSIZE		IEEE80211_MAX_FRAME_LEN
+#define B43_DMA0_RX_BUFFERSIZE		(B43_DMA0_RX_FRAMEOFFSET + IEEE80211_MAX_FRAME_LEN)
 
 /* Pointer poison */
 #define B43_DMA_PTR_POISON		((void *)ERR_PTR(-ENOMEM))
diff --git a/drivers/net/wireless/iwlwifi/iwl-eeprom.h b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
index 98aa8af..20b6646 100644
--- a/drivers/net/wireless/iwlwifi/iwl-eeprom.h
+++ b/drivers/net/wireless/iwlwifi/iwl-eeprom.h
@@ -241,7 +241,7 @@ struct iwl_eeprom_enhanced_txpwr {
 
 /* 6x00 Specific */
 #define EEPROM_6000_TX_POWER_VERSION    (4)
-#define EEPROM_6000_EEPROM_VERSION	(0x434)
+#define EEPROM_6000_EEPROM_VERSION	(0x423)
 
 /* 6x50 Specific */
 #define EEPROM_6050_TX_POWER_VERSION    (4)
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 9b344a9..e183587 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -56,6 +56,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x0846, 0x4210)},	/* Netgear WG121 the second ? */
 	{USB_DEVICE(0x0846, 0x4220)},	/* Netgear WG111 */
 	{USB_DEVICE(0x09aa, 0x1000)},	/* Spinnaker Proto board */
+	{USB_DEVICE(0x0bf8, 0x1007)},	/* Fujitsu E-5400 USB */
 	{USB_DEVICE(0x0cde, 0x0006)},	/* Medion 40900, Roper Europe */
 	{USB_DEVICE(0x0db0, 0x6826)},	/* MSI UB54G (MS-6826) */
 	{USB_DEVICE(0x107b, 0x55f2)},	/* Gateway WGU-210 (Gemtek) */
@@ -68,6 +69,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x1915, 0x2235)},	/* Linksys WUSB54G Portable OEM */
 	{USB_DEVICE(0x2001, 0x3701)},	/* DLink DWL-G120 Spinnaker */
 	{USB_DEVICE(0x2001, 0x3703)},	/* DLink DWL-G122 */
+	{USB_DEVICE(0x2001, 0x3762)},	/* Conceptronic C54U */
 	{USB_DEVICE(0x5041, 0x2234)},	/* Linksys WUSB54G */
 	{USB_DEVICE(0x5041, 0x2235)},	/* Linksys WUSB54G Portable */
 
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 9de9dbe..84eb6ad 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -1062,8 +1062,10 @@ void rt2x00lib_remove_dev(struct rt2x00_dev *rt2x00dev)
 	 * Stop all work.
 	 */
 	cancel_work_sync(&rt2x00dev->intf_work);
-	cancel_work_sync(&rt2x00dev->rxdone_work);
-	cancel_work_sync(&rt2x00dev->txdone_work);
+	if (rt2x00_is_usb(rt2x00dev)) {
+		cancel_work_sync(&rt2x00dev->rxdone_work);
+		cancel_work_sync(&rt2x00dev->txdone_work);
+	}
 	destroy_workqueue(rt2x00dev->workqueue);
 
 	/*
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index f74a870..590f14f 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -685,7 +685,7 @@ static int efuse_pg_packet_read(struct ieee80211_hw *hw, u8 offset, u8 *data)
 
 	u8 efuse_data, word_cnts = 0;
 	u16 efuse_addr = 0;
-	u8 hworden;
+	u8 hworden = 0;
 	u8 tmpdata[8];
 
 	if (data == NULL)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
index 5ef9137..28a6ce3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -303,7 +303,7 @@ static void _rtl92c_fill_h2c_command(struct ieee80211_hw *hw,
 	u16 box_reg, box_extreg;
 	u8 u1b_tmp;
 	bool isfw_read = false;
-	u8 buf_index;
+	u8 buf_index = 0;
 	bool bwrite_sucess = false;
 	u8 wait_h2c_limmit = 100;
 	u8 wait_writeh2c_limmit = 100;
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlwifi/usb.c
index a4b2613..f5d8573 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -246,7 +246,7 @@ static void _rtl_usb_io_handler_init(struct device *dev,
 
 static void _rtl_usb_io_handler_release(struct ieee80211_hw *hw)
 {
-	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_priv __maybe_unused *rtlpriv = rtl_priv(hw);
 
 	mutex_destroy(&rtlpriv->io.bb_mutex);
 }
diff --git a/drivers/net/wireless/wl12xx/sdio.c b/drivers/net/wireless/wl12xx/sdio.c
index 5b9dbea..b1c7d03 100644
--- a/drivers/net/wireless/wl12xx/sdio.c
+++ b/drivers/net/wireless/wl12xx/sdio.c
@@ -340,7 +340,7 @@ module_init(wl1271_init);
 module_exit(wl1271_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Luciano Coelho <luciano.coelho@nokia.com>");
+MODULE_AUTHOR("Luciano Coelho <coelho@ti.com>");
 MODULE_AUTHOR("Juuso Oikarinen <juuso.oikarinen@nokia.com>");
 MODULE_FIRMWARE(WL1271_FW_NAME);
 MODULE_FIRMWARE(WL1271_AP_FW_NAME);
diff --git a/drivers/net/wireless/wl12xx/spi.c b/drivers/net/wireless/wl12xx/spi.c
index 18cf017..ffc745b 100644
--- a/drivers/net/wireless/wl12xx/spi.c
+++ b/drivers/net/wireless/wl12xx/spi.c
@@ -487,7 +487,7 @@ module_init(wl1271_init);
 module_exit(wl1271_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Luciano Coelho <luciano.coelho@nokia.com>");
+MODULE_AUTHOR("Luciano Coelho <coelho@ti.com>");
 MODULE_AUTHOR("Juuso Oikarinen <juuso.oikarinen@nokia.com>");
 MODULE_FIRMWARE(WL1271_FW_NAME);
 MODULE_FIRMWARE(WL1271_AP_FW_NAME);
diff --git a/drivers/net/wireless/wl12xx/testmode.c b/drivers/net/wireless/wl12xx/testmode.c
index e64403b..6ec06a4 100644
--- a/drivers/net/wireless/wl12xx/testmode.c
+++ b/drivers/net/wireless/wl12xx/testmode.c
@@ -204,7 +204,10 @@ static int wl1271_tm_cmd_nvs_push(struct wl1271 *wl, struct nlattr *tb[])
 
 	kfree(wl->nvs);
 
-	wl->nvs = kzalloc(sizeof(struct wl1271_nvs_file), GFP_KERNEL);
+	if (len != sizeof(struct wl1271_nvs_file))
+		return -EINVAL;
+
+	wl->nvs = kzalloc(len, GFP_KERNEL);
 	if (!wl->nvs) {
 		wl1271_error("could not allocate memory for the nvs file");
 		ret = -ENOMEM;
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 58236e6..ab607bb 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -643,7 +643,7 @@ static void rx_urb_complete(struct urb *urb)
 	usb = urb->context;
 	rx = &usb->rx;
 
-	zd_usb_reset_rx_idle_timer(usb);
+	tasklet_schedule(&rx->reset_timer_tasklet);
 
 	if (length%rx->usb_packet_size > rx->usb_packet_size-4) {
 		/* If there is an old first fragment, we don't care. */
@@ -812,6 +812,7 @@ void zd_usb_disable_rx(struct zd_usb *usb)
 	__zd_usb_disable_rx(usb);
 	mutex_unlock(&rx->setup_mutex);
 
+	tasklet_kill(&rx->reset_timer_tasklet);
 	cancel_delayed_work_sync(&rx->idle_work);
 }
 
@@ -1106,6 +1107,13 @@ static void zd_rx_idle_timer_handler(struct work_struct *work)
 	zd_usb_reset_rx(usb);
 }
 
+static void zd_usb_reset_rx_idle_timer_tasklet(unsigned long param)
+{
+	struct zd_usb *usb = (struct zd_usb *)param;
+
+	zd_usb_reset_rx_idle_timer(usb);
+}
+
 void zd_usb_reset_rx_idle_timer(struct zd_usb *usb)
 {
 	struct zd_usb_rx *rx = &usb->rx;
@@ -1127,6 +1135,7 @@ static inline void init_usb_interrupt(struct zd_usb *usb)
 static inline void init_usb_rx(struct zd_usb *usb)
 {
 	struct zd_usb_rx *rx = &usb->rx;
+
 	spin_lock_init(&rx->lock);
 	mutex_init(&rx->setup_mutex);
 	if (interface_to_usbdev(usb->intf)->speed == USB_SPEED_HIGH) {
@@ -1136,11 +1145,14 @@ static inline void init_usb_rx(struct zd_usb *usb)
 	}
 	ZD_ASSERT(rx->fragment_length == 0);
 	INIT_DELAYED_WORK(&rx->idle_work, zd_rx_idle_timer_handler);
+	rx->reset_timer_tasklet.func = zd_usb_reset_rx_idle_timer_tasklet;
+	rx->reset_timer_tasklet.data = (unsigned long)usb;
 }
 
 static inline void init_usb_tx(struct zd_usb *usb)
 {
 	struct zd_usb_tx *tx = &usb->tx;
+
 	spin_lock_init(&tx->lock);
 	atomic_set(&tx->enabled, 0);
 	tx->stopped = 0;
@@ -1671,6 +1683,10 @@ static void iowrite16v_urb_complete(struct urb *urb)
 
 	if (urb->status && !usb->cmd_error)
 		usb->cmd_error = urb->status;
+
+	if (!usb->cmd_error &&
+			urb->actual_length != urb->transfer_buffer_length)
+		usb->cmd_error = -EIO;
 }
 
 static int zd_submit_waiting_urb(struct zd_usb *usb, bool last)
@@ -1805,7 +1821,7 @@ int zd_usb_iowrite16v_async(struct zd_usb *usb, const struct zd_ioreq16 *ioreqs,
 	usb_fill_int_urb(urb, udev, usb_sndintpipe(udev, EP_REGS_OUT),
 			 req, req_len, iowrite16v_urb_complete, usb,
 			 ep->desc.bInterval);
-	urb->transfer_flags |= URB_FREE_BUFFER | URB_SHORT_NOT_OK;
+	urb->transfer_flags |= URB_FREE_BUFFER;
 
 	/* Submit previous URB */
 	r = zd_submit_waiting_urb(usb, false);
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zd1211rw/zd_usb.h
index b3df2c8..325d0f9 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -183,6 +183,7 @@ struct zd_usb_rx {
 	spinlock_t lock;
 	struct mutex setup_mutex;
 	struct delayed_work idle_work;
+	struct tasklet_struct reset_timer_tasklet;
 	u8 fragment[2 * USB_MAX_RX_SIZE];
 	unsigned int fragment_length;
 	unsigned int usb_packet_size;
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index cefe1b3..965f1b1 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1753,8 +1753,19 @@ enum ieee80211_ampdu_mlme_action {
  * 	that TX/RX_STOP can pass NULL for this parameter.
  *	The @buf_size parameter is only valid when the action is set to
  *	%IEEE80211_AMPDU_TX_OPERATIONAL and indicates the peer's reorder
- *	buffer size (number of subframes) for this session -- aggregates
- *	containing more subframes than this may not be transmitted to the peer.
+ *	buffer size (number of subframes) for this session -- the driver
+ *	may neither send aggregates containing more subframes than this
+ *	nor send aggregates in a way that lost frames would exceed the
+ *	buffer size. If just limiting the aggregate size, this would be
+ *	possible with a buf_size of 8:
+ *	 - TX: 1.....7
+ *	 - RX:  2....7 (lost frame #1)
+ *	 - TX:        8..1...
+ *	which is invalid since #1 was now re-transmitted well past the
+ *	buffer size of 8. Correct ways to retransmit #1 would be:
+ *	 - TX:       1 or 18 or 81
+ *	Even "189" would be wrong since 1 could be lost again.
+ *
  *	Returns a negative error code on failure.
  *	The callback can sleep.
  *
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index aa5cc37..2afeac9 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -2541,7 +2541,6 @@ static void ieee80211_rx_handlers(struct ieee80211_rx_data *rx)
 		 * same TID from the same station
 		 */
 		rx->skb = skb;
-		rx->flags = 0;
 
 		CALL_RXH(ieee80211_rx_h_decrypt)
 		CALL_RXH(ieee80211_rx_h_check_more_data)
@@ -2612,6 +2611,7 @@ void ieee80211_release_reorder_timeout(struct sta_info *sta, int tid)
 		.sdata = sta->sdata,
 		.local = sta->local,
 		.queue = tid,
+		.flags = 0,
 	};
 	struct tid_ampdu_rx *tid_agg_rx;
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
