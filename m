From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2011-11-17
Date: Thu, 17 Nov 2011 14:36:31 -0500
Message-ID: <20111117193631.GF32622@tuxdriver.com>
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

Here is a little batch of fixes intended for 3.2.  This includes a new
USB ID for rt2x00, a fix for a sleep-while-atomic bug in rt2x00, and a
fix for a potential memory leak in libertas.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 102463b18d922dd55c29fbfa222e0355ecf3e42f:

  stmmac: fix pm functions avoiding sleep on spinlock (2011-11-17 03:13:42 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-davem

Gertjan van Wingerde (2):
      rt2x00: Add USB device ID of Buffalo WLI-UC-GNHP.
      rt2x00: Fix sleep-while-atomic bug in powersaving code.

Jesper Juhl (1):
      Net, libertas: Resolve memory leak in if_spi_host_to_card()

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless into for-davem

 drivers/net/wireless/libertas/if_spi.c  |    1 +
 drivers/net/wireless/rt2x00/rt2800usb.c |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h    |    1 +
 drivers/net/wireless/rt2x00/rt2x00dev.c |   22 ++++++++++++++++++++--
 4 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/libertas/if_spi.c b/drivers/net/wireless/libertas/if_spi.c
index 11b69b3..728baa4 100644
--- a/drivers/net/wireless/libertas/if_spi.c
+++ b/drivers/net/wireless/libertas/if_spi.c
@@ -995,6 +995,7 @@ static int if_spi_host_to_card(struct lbs_private *priv,
 		spin_unlock_irqrestore(&card->buffer_lock, flags);
 		break;
 	default:
+		kfree(packet);
 		netdev_err(priv->dev, "can't transfer buffer of type %d\n",
 			   type);
 		err = -EINVAL;
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index f156579..3778763 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -919,6 +919,7 @@ static struct usb_device_id rt2800usb_device_table[] = {
 	{ USB_DEVICE(0x050d, 0x935b) },
 	/* Buffalo */
 	{ USB_DEVICE(0x0411, 0x00e8) },
+	{ USB_DEVICE(0x0411, 0x0158) },
 	{ USB_DEVICE(0x0411, 0x016f) },
 	{ USB_DEVICE(0x0411, 0x01a2) },
 	/* Corega */
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 2ec5c00..99ff12d 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -943,6 +943,7 @@ struct rt2x00_dev {
 	 * Powersaving work
 	 */
 	struct delayed_work autowakeup_work;
+	struct work_struct sleep_work;
 
 	/*
 	 * Data queue arrays for RX, TX, Beacon and ATIM.
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index e1fb2a8..edd317f 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -465,6 +465,23 @@ static u8 *rt2x00lib_find_ie(u8 *data, unsigned int len, u8 ie)
 	return NULL;
 }
 
+static void rt2x00lib_sleep(struct work_struct *work)
+{
+	struct rt2x00_dev *rt2x00dev =
+	    container_of(work, struct rt2x00_dev, sleep_work);
+
+	if (!test_bit(DEVICE_STATE_PRESENT, &rt2x00dev->flags))
+		return;
+
+	/*
+	 * Check again is powersaving is enabled, to prevent races from delayed
+	 * work execution.
+	 */
+	if (!test_bit(CONFIG_POWERSAVING, &rt2x00dev->flags))
+		rt2x00lib_config(rt2x00dev, &rt2x00dev->hw->conf,
+				 IEEE80211_CONF_CHANGE_PS);
+}
+
 static void rt2x00lib_rxdone_check_ps(struct rt2x00_dev *rt2x00dev,
 				      struct sk_buff *skb,
 				      struct rxdone_entry_desc *rxdesc)
@@ -512,8 +529,7 @@ static void rt2x00lib_rxdone_check_ps(struct rt2x00_dev *rt2x00dev,
 	cam |= (tim_ie->bitmap_ctrl & 0x01);
 
 	if (!cam && !test_bit(CONFIG_POWERSAVING, &rt2x00dev->flags))
-		rt2x00lib_config(rt2x00dev, &rt2x00dev->hw->conf,
-				 IEEE80211_CONF_CHANGE_PS);
+		queue_work(rt2x00dev->workqueue, &rt2x00dev->sleep_work);
 }
 
 static int rt2x00lib_rxdone_read_signal(struct rt2x00_dev *rt2x00dev,
@@ -1141,6 +1157,7 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 
 	INIT_WORK(&rt2x00dev->intf_work, rt2x00lib_intf_scheduled);
 	INIT_DELAYED_WORK(&rt2x00dev->autowakeup_work, rt2x00lib_autowakeup);
+	INIT_WORK(&rt2x00dev->sleep_work, rt2x00lib_sleep);
 
 	/*
 	 * Let the driver probe the device to detect the capabilities.
@@ -1197,6 +1214,7 @@ void rt2x00lib_remove_dev(struct rt2x00_dev *rt2x00dev)
 	 */
 	cancel_work_sync(&rt2x00dev->intf_work);
 	cancel_delayed_work_sync(&rt2x00dev->autowakeup_work);
+	cancel_work_sync(&rt2x00dev->sleep_work);
 	if (rt2x00_is_usb(rt2x00dev)) {
 		del_timer_sync(&rt2x00dev->txstatus_timer);
 		cancel_work_sync(&rt2x00dev->rxdone_work);
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
