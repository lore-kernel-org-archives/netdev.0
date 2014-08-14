From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] at76c50x-usb: fix use after free on failure path in at76_probe()
Date: Fri, 15 Aug 2014 03:00:06 +0400
Message-ID: <1408057206-8854-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Andrea Merello <andrea.merello@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After commit 174beab7d445 ("at76c50x-usb: Don't perform DMA from stack memory")
at76_delete_device() and usb_put_dev() are called both
if at76_init_new_device() fails in at76_probe().
But at76_delete_device() does usb_put_dev(priv->dev) itself
that means double usb_put_dev().

The patch avoids the problem by moving usb_put_dev() from
at76_delete_device() to at76_disconnect().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/at76c50x-usb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 334c2ece855a..da92bfa76b7c 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -2423,8 +2423,6 @@ static void at76_delete_device(struct at76_priv *priv)
 
 	kfree_skb(priv->rx_skb);
 
-	usb_put_dev(priv->udev);
-
 	at76_dbg(DBG_PROC_ENTRY, "%s: before freeing priv/ieee80211_hw",
 		 __func__);
 	ieee80211_free_hw(priv->hw);
@@ -2558,6 +2556,7 @@ static void at76_disconnect(struct usb_interface *interface)
 
 	wiphy_info(priv->hw->wiphy, "disconnecting\n");
 	at76_delete_device(priv);
+	usb_put_dev(priv->udev);
 	dev_info(&interface->dev, "disconnected\n");
 }
 
-- 
1.9.1
