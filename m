From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx: fix unexpected LED control values in BCM4303 sprom
Date: Tue, 17 Oct 2006 23:38:26 -0500
Message-ID: <4535AFC2.mail3S81JGSDJ@lwfinger.net>
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

The bcm43xx driver uses 4 locations in the devices sprom to determine
the behavior of the leds. Certain defaults are assigned if all bits are
set in those locations. On at least one BCM4303 chip, the sprom contains
values other than the default, which executes an assertion placed in the
default case of a following switch statement. This patch makes the leds
on the above mentioned interface behave correctly. In addition, it limits
the number of logged messages to 20 for the case of unexpected values in
the sprom locations.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

 bcm43xx_leds.c |   12 +++++++++++-
 bcm43xx_leds.h |    4 ++++
 2 files changed, 15 insertions(+), 1 deletion(-)


John,

This patch should be applied to wireless-2.6 so as to be ready for 2.6.20.

Larry




Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.c
@@ -168,6 +168,8 @@ void bcm43xx_leds_exit(struct bcm43xx_pr
 	bcm43xx_leds_switch_all(bcm, 0);
 }
 
+static int bcm43xx_max_led_err = 20;
+
 void bcm43xx_leds_update(struct bcm43xx_private *bcm, int activity)
 {
 	struct bcm43xx_led *led;
@@ -189,20 +191,24 @@ void bcm43xx_leds_update(struct bcm43xx_
 		case BCM43xx_LED_INACTIVE:
 			continue;
 		case BCM43xx_LED_OFF:
+		case BCM43xx_LED_BCM4303_3:
 			break;
 		case BCM43xx_LED_ON:
 			turn_on = 1;
 			break;
 		case BCM43xx_LED_ACTIVITY:
+		case BCM43xx_LED_BCM4303_0:
 			turn_on = activity;
 			break;
 		case BCM43xx_LED_RADIO_ALL:
 			turn_on = radio->enabled;
 			break;
 		case BCM43xx_LED_RADIO_A:
+		case BCM43xx_LED_BCM4303_2:
 			turn_on = (radio->enabled && phy->type == BCM43xx_PHYTYPE_A);
 			break;
 		case BCM43xx_LED_RADIO_B:
+		case BCM43xx_LED_BCM4303_1:
 			turn_on = (radio->enabled &&
 				   (phy->type == BCM43xx_PHYTYPE_B ||
 				    phy->type == BCM43xx_PHYTYPE_G));
@@ -257,7 +263,11 @@ void bcm43xx_leds_update(struct bcm43xx_
 			continue;
 #endif /* CONFIG_BCM43XX_DEBUG */
 		default:
-			assert(0);
+			if (bcm43xx_max_led_err) {
+				printkl(KERN_INFO PFX "Bad value in leds_update,"
+					" led->behaviour: 0x%x\n", led->behaviour);
+				--bcm43xx_max_led_err;
+			}
 		};
 
 		if (led->activelow)
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_leds.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_leds.h
@@ -24,6 +24,10 @@ struct bcm43xx_led {
 
 #define BCM43xx_LED_BEHAVIOUR		0x7F
 #define BCM43xx_LED_ACTIVELOW		0x80
+#define BCM43xx_LED_BCM4303_0		0x2B
+#define BCM43xx_LED_BCM4303_1		0x78
+#define BCM43xx_LED_BCM4303_2		0x2E
+#define BCM43xx_LED_BCM4303_3		0x19
 enum { /* LED behaviour values */
 	BCM43xx_LED_OFF,
 	BCM43xx_LED_ON,

========
