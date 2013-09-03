From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH v2] rtl8187: fix use after free on failure path in rtl8187_init_urbs()
Date: Wed,  4 Sep 2013 00:37:17 +0400
Message-ID: <1378240637-18560-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Hin-Tak Leung <htl10@users.sourceforge.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case of __dev_alloc_skb() failure rtl8187_init_urbs()
calls usb_free_urb(entry) where 'entry' can points to urb
allocated at the previous iteration. That means refcnt will be
decremented incorrectly and the urb can be used after memory
deallocation.

The patch fixes the issue and implements error handling of init_urbs
in rtl8187_start().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/rtl818x/rtl8187/dev.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/rtl818x/rtl8187/dev.c b/drivers/net/wireless/rtl818x/rtl8187/dev.c
index f49220e..a668c0e 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/dev.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/dev.c
@@ -438,17 +438,16 @@ static int rtl8187_init_urbs(struct ieee80211_hw *dev)
 		skb_queue_tail(&priv->rx_queue, skb);
 		usb_anchor_urb(entry, &priv->anchored);
 		ret = usb_submit_urb(entry, GFP_KERNEL);
+		usb_put_urb(entry);
 		if (ret) {
 			skb_unlink(skb, &priv->rx_queue);
 			usb_unanchor_urb(entry);
 			goto err;
 		}
-		usb_free_urb(entry);
 	}
 	return ret;
 
 err:
-	usb_free_urb(entry);
 	kfree_skb(skb);
 	usb_kill_anchored_urbs(&priv->anchored);
 	return ret;
@@ -956,8 +955,12 @@ static int rtl8187_start(struct ieee80211_hw *dev)
 				  (RETRY_COUNT << 8  /* short retry limit */) |
 				  (RETRY_COUNT << 0  /* long retry limit */) |
 				  (7 << 21 /* MAX TX DMA */));
-		rtl8187_init_urbs(dev);
-		rtl8187b_init_status_urb(dev);
+		ret = rtl8187_init_urbs(dev);
+		if (ret)
+			goto rtl8187_start_exit;
+		ret = rtl8187b_init_status_urb(dev);
+		if (ret)
+			usb_kill_anchored_urbs(&priv->anchored);
 		goto rtl8187_start_exit;
 	}
 
@@ -966,7 +969,9 @@ static int rtl8187_start(struct ieee80211_hw *dev)
 	rtl818x_iowrite32(priv, &priv->map->MAR[0], ~0);
 	rtl818x_iowrite32(priv, &priv->map->MAR[1], ~0);
 
-	rtl8187_init_urbs(dev);
+	ret = rtl8187_init_urbs(dev);
+	if (ret)
+		goto rtl8187_start_exit;
 
 	reg = RTL818X_RX_CONF_ONLYERLPKT |
 	      RTL818X_RX_CONF_RX_AUTORESETPHY |
-- 
1.8.1.2
