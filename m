From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 12/16] Host AP: Fix netif_carrier_off() in non-client modes
Date: Sat, 13 Nov 2004 21:21:57 -0800
Message-ID: <20041114052157.GD14810@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Connection status is reported properly only in client modes, so do not
try to set netif_carrier_off() in non-client modes. Previously, Master
mode may end up being in state where netif_carrier was left off and
this may break things like bridging.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
--- a/drivers/net/wireless/hostap/hostap_hw.c	2004-11-13 20:56:17 -08:00
+++ b/drivers/net/wireless/hostap/hostap_hw.c	2004-11-13 20:56:17 -08:00
@@ -3399,8 +3399,11 @@
 					   "", dev_template);
 
 	if (local->ddev) {
-		netif_carrier_off(local->dev);
-		netif_carrier_off(local->ddev);
+		if (local->iw_mode == IW_MODE_INFRA ||
+		    local->iw_mode == IW_MODE_ADHOC) {
+			netif_carrier_off(local->dev);
+			netif_carrier_off(local->ddev);
+		}
 		hostap_init_proc(local);
 		hostap_init_ap_proc(local);
 		return 0;
diff -Nru a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
--- a/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-13 20:56:17 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-13 20:56:17 -08:00
@@ -1108,6 +1108,13 @@
 	if (double_reset && local->func->reset_port(dev))
 		return -EINVAL;
 
+	if (local->iw_mode != IW_MODE_INFRA && local->iw_mode != IW_MODE_ADHOC)
+	{
+		/* netif_carrier is used only in client modes for now, so make
+		 * sure carrier is on when moving to non-client modes. */
+		netif_carrier_on(local->dev);
+		netif_carrier_on(local->ddev);
+	}
 	return 0;
 }
 


-- 
Jouni Malinen                                            PGP id EFC895FA
