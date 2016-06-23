From: Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/2] Bluetooth: Add LED triggers for HCI frames tx and rx
Date: Thu, 23 Jun 2016 12:58:42 +0800
Message-ID: <1466657923-5776-1-git-send-email-guodong.xu@linaro.org>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	haojian.zhuang-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Two LED triggers are defined: tx_led and rx_led. Upon frames
available in HCI core layer, for tx or for rx, the combined LED
can blink.

Verified on HiKey, 96boards. It uses hi6220 SoC and TI WL1835 combo
chip.

Signed-off-by: Guodong Xu <guodong.xu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 include/net/bluetooth/hci_core.h |  1 +
 net/bluetooth/hci_core.c         |  3 +++
 net/bluetooth/leds.c             | 15 +++++++++++++++
 net/bluetooth/leds.h             |  2 ++
 4 files changed, 21 insertions(+)

diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_core.h
index dc71473..37b8dd9 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -398,6 +398,7 @@ struct hci_dev {
 	bdaddr_t		rpa;
 
 	struct led_trigger	*power_led;
+	struct led_trigger	*tx_led, *rx_led;
 
 	int (*open)(struct hci_dev *hdev);
 	int (*close)(struct hci_dev *hdev);
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 45a9fc6..c6e1210 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -3248,6 +3248,7 @@ int hci_recv_frame(struct hci_dev *hdev, struct sk_buff *skb)
 	skb_queue_tail(&hdev->rx_q, skb);
 	queue_work(hdev->workqueue, &hdev->rx_work);
 
+	hci_leds_blink_oneshot(hdev->rx_led);
 	return 0;
 }
 EXPORT_SYMBOL(hci_recv_frame);
@@ -3325,6 +3326,8 @@ static void hci_send_frame(struct hci_dev *hdev, struct sk_buff *skb)
 		BT_ERR("%s sending frame failed (%d)", hdev->name, err);
 		kfree_skb(skb);
 	}
+
+	hci_leds_blink_oneshot(hdev->tx_led);
 }
 
 /* Send HCI command */
diff --git a/net/bluetooth/leds.c b/net/bluetooth/leds.c
index 8319c84..c4825d5 100644
--- a/net/bluetooth/leds.c
+++ b/net/bluetooth/leds.c
@@ -19,6 +19,8 @@ struct hci_basic_led_trigger {
 #define to_hci_basic_led_trigger(arg) container_of(arg, \
 			struct hci_basic_led_trigger, led_trigger)
 
+#define BLUETOOTH_BLINK_DELAY	50 /* ms */
+
 void hci_leds_update_powered(struct hci_dev *hdev, bool enabled)
 {
 	if (hdev->power_led)
@@ -37,6 +39,15 @@ static void power_activate(struct led_classdev *led_cdev)
 	led_trigger_event(led_cdev->trigger, powered ? LED_FULL : LED_OFF);
 }
 
+void hci_leds_blink_oneshot(struct led_trigger *trig)
+{
+	unsigned long led_delay = BLUETOOTH_BLINK_DELAY;
+
+	if (!trig)
+		return;
+	led_trigger_blink_oneshot(trig, &led_delay, &led_delay, 0);
+}
+
 static struct led_trigger *led_allocate_basic(struct hci_dev *hdev,
 			void (*activate)(struct led_classdev *led_cdev),
 			const char *name)
@@ -71,4 +82,8 @@ void hci_leds_init(struct hci_dev *hdev)
 {
 	/* initialize power_led */
 	hdev->power_led = led_allocate_basic(hdev, power_activate, "power");
+	/* initialize tx_led */
+	hdev->tx_led = led_allocate_basic(hdev, NULL, "tx");
+	/* initialize rx_led */
+	hdev->rx_led = led_allocate_basic(hdev, NULL, "rx");
 }
diff --git a/net/bluetooth/leds.h b/net/bluetooth/leds.h
index a9c4d6e..9b1cccd 100644
--- a/net/bluetooth/leds.h
+++ b/net/bluetooth/leds.h
@@ -9,8 +9,10 @@
 #if IS_ENABLED(CONFIG_BT_LEDS)
 void hci_leds_update_powered(struct hci_dev *hdev, bool enabled);
 void hci_leds_init(struct hci_dev *hdev);
+void hci_leds_blink_oneshot(struct led_trigger *trig);
 #else
 static inline void hci_leds_update_powered(struct hci_dev *hdev,
 					   bool enabled) {}
 static inline void hci_leds_init(struct hci_dev *hdev) {}
+static inline void hci_leds_blink_oneshot(struct led_trigger *trig) {}
 #endif
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
