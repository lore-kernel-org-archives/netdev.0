From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: Ignore ampdu status reports
Date: Tue, 06 Feb 2007 00:16:35 -0600
Message-ID: <45c81d43.P6v/adIydh88LL+j%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
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

From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>

iIf bcm43xx were to process an afterburner (ampdu) status response, Linux would oops. The
ampdu and intermediate status bits are properly named.

Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -1453,12 +1453,10 @@ static void handle_irq_transmit_status(s
 
 		bcm43xx_debugfs_log_txstat(bcm, &stat);
 
-		if (stat.flags & BCM43xx_TXSTAT_FLAG_IGNORE)
+		if (stat.flags & BCM43xx_TXSTAT_FLAG_AMPDU)
+			continue;
+		if (stat.flags & BCM43xx_TXSTAT_FLAG_INTER)
 			continue;
-		if (!(stat.flags & BCM43xx_TXSTAT_FLAG_ACK)) {
-			//TODO: packet was not acked (was lost)
-		}
-		//TODO: There are more (unknown) flags to test. see bcm43xx_main.h
 
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_handle_xmitstatus(bcm, &stat);
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_xmit.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_xmit.h
@@ -137,14 +137,8 @@ struct bcm43xx_xmitstatus {
 	u16 unknown; //FIXME
 };
 
-#define BCM43xx_TXSTAT_FLAG_ACK		0x01
-//TODO #define BCM43xx_TXSTAT_FLAG_???	0x02
-//TODO #define BCM43xx_TXSTAT_FLAG_???	0x04
-//TODO #define BCM43xx_TXSTAT_FLAG_???	0x08
-//TODO #define BCM43xx_TXSTAT_FLAG_???	0x10
-#define BCM43xx_TXSTAT_FLAG_IGNORE	0x20
-//TODO #define BCM43xx_TXSTAT_FLAG_???	0x40
-//TODO #define BCM43xx_TXSTAT_FLAG_???	0x80
+#define BCM43xx_TXSTAT_FLAG_AMPDU	0x10
+#define BCM43xx_TXSTAT_FLAG_INTER	0x20
 
 u8 bcm43xx_plcp_get_ratecode_cck(const u8 bitrate);
 u8 bcm43xx_plcp_get_ratecode_ofdm(const u8 bitrate);
