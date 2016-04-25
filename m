From: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
Subject: [PATCH RFC] b43: stop hardcoding LED behavior
Date: Mon, 25 Apr 2016 09:40:51 +0200
Message-ID: <1461570051-3950-1-git-send-email-dev@lynxeye.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

The code to hardcode the LED behavior is basically unchanged from when it
was first merged in 2007. It is likely wrong for many modern systems using
the b43 driver.

On my system the SPROM correctly defines the only wired LED (radio) but
skips all others, leading to the hardcode to register LEDs with RX and TX
triggers. These triggers cause many uneccesary CPU wakeups to drive LEDs
that aren't even present in the system, reducing battery runtime.

Remove the hardcode to stop it from doing any harm. If this code is useful
for others it should probably be reworked as a quirk table triggering only
for individual systems that need it.

Signed-off-by: Lucas Stach <dev-8ppwABl0HbeELgA04lAiVw@public.gmane.org>
---
 drivers/net/wireless/broadcom/b43/leds.c | 26 ++------------------------
 1 file changed, 2 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/broadcom/b43/leds.c b/drivers/net/wireless/broadcom/b43/leds.c
index d79ab2a..77d2dad 100644
--- a/drivers/net/wireless/broadcom/b43/leds.c
+++ b/drivers/net/wireless/broadcom/b43/leds.c
@@ -224,31 +224,9 @@ static void b43_led_get_sprominfo(struct b43_wldev *dev,
 
 	if (sprom[led_index] == 0xFF) {
 		/* There is no LED information in the SPROM
-		 * for this LED. Hardcode it here. */
+		 * for this LED. Keep it disabled. */
 		*activelow = false;
-		switch (led_index) {
-		case 0:
-			*behaviour = B43_LED_ACTIVITY;
-			*activelow = true;
-			if (dev->dev->board_vendor == PCI_VENDOR_ID_COMPAQ)
-				*behaviour = B43_LED_RADIO_ALL;
-			break;
-		case 1:
-			*behaviour = B43_LED_RADIO_B;
-			if (dev->dev->board_vendor == PCI_VENDOR_ID_ASUSTEK)
-				*behaviour = B43_LED_ASSOC;
-			break;
-		case 2:
-			*behaviour = B43_LED_RADIO_A;
-			break;
-		case 3:
-			*behaviour = B43_LED_OFF;
-			break;
-		default:
-			*behaviour = B43_LED_OFF;
-			B43_WARN_ON(1);
-			return;
-		}
+		*behaviour = B43_LED_OFF;
 	} else {
 		*behaviour = sprom[led_index] & B43_LED_BEHAVIOUR;
 		*activelow = !!(sprom[led_index] & B43_LED_ACTIVELOW);
-- 
2.5.5
