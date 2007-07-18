From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Tue, 17 Jul 2007 22:19:53 -0400
Message-ID: <20070718021953.GC26907@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3700 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755985AbXGRCcs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2007 22:32:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A few more for 2.6.23...

Thanks!

John

---

The following changes since commit 4ad1366376bfef32ec0ffa12d1faa483d6f330bd:
  NeilBrown (1):
        md: change bitmap_unplug and others to void functions

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik

Daniel Drake (1):
      zd1211rw: Add ID for Siemens Gigaset USB Stick 54

Jean Tourrilhes (1):
      softmac: Channel is listed twice in scan output

Masakazu Mokuno (1):
      zd1211rw: Add ID for Planex GW-US54GXS

Zhu Yi (4):
      ipw2100: Fix `iwpriv set_power` error
      Fix ipw2200 set wrong power parameter causing firmware error
      ipw2200: Fix ipw_isr() comments error on shared IRQ
      Update version ipw2200 stamp to 1.2.2

 drivers/net/wireless/ipw2100.c         |    6 +++---
 drivers/net/wireless/ipw2200.c         |   18 ++++++++----------
 drivers/net/wireless/zd1211rw/zd_usb.c |    2 ++
 net/ieee80211/ieee80211_wx.c           |    7 ++-----
 4 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 072ede7..8990585 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -7868,10 +7868,10 @@ static int ipw2100_wx_set_powermode(struct net_device *dev,
 		goto done;
 	}
 
-	if ((mode < 1) || (mode > POWER_MODES))
+	if ((mode < 0) || (mode > POWER_MODES))
 		mode = IPW_POWER_AUTO;
 
-	if (priv->power_mode != mode)
+	if (IPW_POWER_LEVEL(priv->power_mode) != mode)
 		err = ipw2100_set_power_mode(priv, mode);
       done:
 	mutex_unlock(&priv->action_mutex);
@@ -7902,7 +7902,7 @@ static int ipw2100_wx_get_powermode(struct net_device *dev,
 			break;
 		case IPW_POWER_AUTO:
 			snprintf(extra, MAX_POWER_STRING,
-				 "Power save level: %d (Auto)", 0);
+				 "Power save level: %d (Auto)", level);
 			break;
 		default:
 			timeout = timeout_duration[level - 1] / 1000;
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index aa32a97..61497c4 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -70,7 +70,7 @@
 #define VQ
 #endif
 
-#define IPW2200_VERSION "1.2.0" VK VD VM VP VR VQ
+#define IPW2200_VERSION "1.2.2" VK VD VM VP VR VQ
 #define DRV_DESCRIPTION	"Intel(R) PRO/Wireless 2200/2915 Network Driver"
 #define DRV_COPYRIGHT	"Copyright(c) 2003-2006 Intel Corporation"
 #define DRV_VERSION     IPW2200_VERSION
@@ -2506,7 +2506,7 @@ static int ipw_send_power_mode(struct ipw_priv *priv, u32 mode)
 		break;
 	}
 
-	param = cpu_to_le32(mode);
+	param = cpu_to_le32(param);
 	return ipw_send_cmd_pdu(priv, IPW_CMD_POWER_MODE, sizeof(param),
 				&param);
 }
@@ -9568,6 +9568,7 @@ static int ipw_wx_set_power(struct net_device *dev,
 		priv->power_mode = IPW_POWER_ENABLED | IPW_POWER_BATTERY;
 	else
 		priv->power_mode = IPW_POWER_ENABLED | priv->power_mode;
+
 	err = ipw_send_power_mode(priv, IPW_POWER_LEVEL(priv->power_mode));
 	if (err) {
 		IPW_DEBUG_WX("failed setting power mode.\n");
@@ -9604,22 +9605,19 @@ static int ipw_wx_set_powermode(struct net_device *dev,
 	struct ipw_priv *priv = ieee80211_priv(dev);
 	int mode = *(int *)extra;
 	int err;
+
 	mutex_lock(&priv->mutex);
-	if ((mode < 1) || (mode > IPW_POWER_LIMIT)) {
+	if ((mode < 1) || (mode > IPW_POWER_LIMIT))
 		mode = IPW_POWER_AC;
-		priv->power_mode = mode;
-	} else {
-		priv->power_mode = IPW_POWER_ENABLED | mode;
-	}
 
-	if (priv->power_mode != mode) {
+	if (IPW_POWER_LEVEL(priv->power_mode) != mode) {
 		err = ipw_send_power_mode(priv, mode);
-
 		if (err) {
 			IPW_DEBUG_WX("failed setting power mode.\n");
 			mutex_unlock(&priv->mutex);
 			return err;
 		}
+		priv->power_mode = IPW_POWER_ENABLED | mode;
 	}
 	mutex_unlock(&priv->mutex);
 	return 0;
@@ -10555,7 +10553,7 @@ static irqreturn_t ipw_isr(int irq, void *data)
 	spin_lock(&priv->irq_lock);
 
 	if (!(priv->status & STATUS_INT_ENABLED)) {
-		/* Shared IRQ */
+		/* IRQ is disabled */
 		goto none;
 	}
 
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 28d41a2..a9c339e 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -72,6 +72,8 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x0586, 0x3413), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0053, 0x5301), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0411, 0x00da), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x2019, 0x5303), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x129b, 0x1667), .driver_info = DEVICE_ZD1211B },
 	/* "Driverless" devices that need ejecting */
 	{ USB_DEVICE(0x0ace, 0x2011), .driver_info = DEVICE_INSTALLER },
 	{ USB_DEVICE(0x0ace, 0x20ff), .driver_info = DEVICE_INSTALLER },
diff --git a/net/ieee80211/ieee80211_wx.c b/net/ieee80211/ieee80211_wx.c
index 523a137..465b73d 100644
--- a/net/ieee80211/ieee80211_wx.c
+++ b/net/ieee80211/ieee80211_wx.c
@@ -90,14 +90,11 @@ static char *ieee80211_translate_scan(struct ieee80211_device *ieee,
 	}
 
 	/* Add channel and frequency */
+	/* Note : userspace automatically computes channel using iwrange */
 	iwe.cmd = SIOCGIWFREQ;
-	iwe.u.freq.m = network->channel;
-	iwe.u.freq.e = 0;
-	iwe.u.freq.i = 0;
-	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
-
 	iwe.u.freq.m = ieee80211_channel_to_freq(ieee, network->channel);
 	iwe.u.freq.e = 6;
+	iwe.u.freq.i = 0;
 	start = iwe_stream_add_event(start, stop, &iwe, IW_EV_FREQ_LEN);
 
 	/* Add encryption capability */
-- 
John W. Linville
linville@tuxdriver.com
