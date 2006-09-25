From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: output proper link quality with scans
Date: Mon, 25 Sep 2006 15:33:20 -0500
Message-ID: <45183D10.mail64719C0VM@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

The bcm43xx-softmac driver fails to set two quantities needed for
iwlist to compute wireless quality when scanning. As a result, userland
programs using the quality to determine the best connection fail.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

This patch is intended for wireless-2.6.
 
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -365,6 +365,9 @@
 #define BCM43xx_DEFAULT_SHORT_RETRY_LIMIT	7
 #define BCM43xx_DEFAULT_LONG_RETRY_LIMIT	4
 
+/* FIXME: the next line is a guess as to what the maximum RSSI value might be */
+#define RX_RSSI_MAX				60
+
 /* Max size of a security key */
 #define BCM43xx_SEC_KEYSIZE			16
 /* Security algorithms. */
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3648,6 +3648,8 @@ static int bcm43xx_read_phyinfo(struct b
 		       phy_type);
 		return -ENODEV;
 	};
+	bcm->ieee->perfect_rssi = RX_RSSI_MAX;
+	bcm->ieee->worst_rssi = 0;
 	if (!phy_rev_ok) {
 		printk(KERN_WARNING PFX "Invalid PHY Revision %x\n",
 		       phy_rev);
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -47,9 +47,6 @@
 #define BCM43xx_WX_VERSION	18
 
 #define MAX_WX_STRING		80
-/* FIXME: the next line is a guess as to what the maximum RSSI value might be */
-#define RX_RSSI_MAX		60
-
 
 static int bcm43xx_wx_get_name(struct net_device *net_dev,
                                struct iw_request_info *info,
