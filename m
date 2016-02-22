From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCHv2 07/10] rfkill: Create "rfkill-airplane-mode" LED trigger
Date: Mon, 22 Feb 2016 11:36:38 -0500
Message-ID: <1456159001-20307-8-git-send-email-jprvita@endlessm.com>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This creates a new LED trigger to be used by platform drivers as a
default trigger for airplane-mode indicator LEDs.

By default this trigger will fire when RFKILL_OP_CHANGE_ALL is called
for all types (RFKILL_TYPE_ALL), setting the LED brightness to LED_FULL
when the changing the state to blocked, and to LED_OFF when the changin=
g
the state to unblocked. In the future there will be a mechanism for
userspace to override the default policy, so it can implement its own.

This trigger will be used by the asus-wireless x86 platform driver.

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 Documentation/rfkill.txt |  2 ++
 net/rfkill/core.c        | 49 ++++++++++++++++++++++++++++++++++++++++=
+++++++-
 2 files changed, 50 insertions(+), 1 deletion(-)

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
index 1f0c270..b13025a 100644
--- a/Documentation/rfkill.txt
+++ b/Documentation/rfkill.txt
@@ -85,6 +85,8 @@ device). Don't do this unless you cannot get the even=
t in any other way.
=20
 RFKill provides per-switch LED triggers, which can be used to drive LE=
Ds
 according to the switch state (LED_FULL when blocked, LED_OFF otherwis=
e).
+An airplane-mode indicator LED trigger is also available, which trigge=
rs
+LED_FULL when all radios known by RFKill are blocked, and LED_OFF othe=
rwise.
=20
=20
 5. Userspace support
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 8b96869..50b538b 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -126,6 +126,30 @@ static bool rfkill_epo_lock_active;
=20
=20
 #ifdef CONFIG_RFKILL_LEDS
+static struct led_trigger rfkill_apm_led_trigger;
+
+static void rfkill_apm_led_trigger_event(bool state)
+{
+	led_trigger_event(&rfkill_apm_led_trigger, state ? LED_FULL : LED_OFF=
);
+}
+
+static void rfkill_apm_led_trigger_activate(struct led_classdev *led)
+{
+	rfkill_apm_led_trigger_event(!rfkill_default_state);
+}
+
+static int rfkill_apm_led_trigger_register(void)
+{
+	rfkill_apm_led_trigger.name =3D "rfkill-airplane-mode";
+	rfkill_apm_led_trigger.activate =3D rfkill_apm_led_trigger_activate;
+	return led_trigger_register(&rfkill_apm_led_trigger);
+}
+
+static void rfkill_apm_led_trigger_unregister(void)
+{
+	led_trigger_unregister(&rfkill_apm_led_trigger);
+}
+
 static void rfkill_led_trigger_event(struct rfkill *rfkill)
 {
 	struct led_trigger *trigger;
@@ -177,6 +201,19 @@ static void rfkill_led_trigger_unregister(struct r=
fkill *rfkill)
 	led_trigger_unregister(&rfkill->led_trigger);
 }
 #else
+static void rfkill_apm_led_trigger_event(bool state)
+{
+}
+
+static int rfkill_apm_led_trigger_register(void)
+{
+	return 0;
+}
+
+static void rfkill_apm_led_trigger_unregister(void)
+{
+}
+
 static void rfkill_led_trigger_event(struct rfkill *rfkill)
 {
 }
@@ -313,6 +350,7 @@ static void rfkill_update_global_state(enum rfkill_=
type type, bool blocked)
=20
 	for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
 		rfkill_global_states[i].cur =3D blocked;
+	rfkill_apm_led_trigger_event(blocked);
 }
=20
 #ifdef CONFIG_RFKILL_INPUT
@@ -1260,15 +1298,22 @@ static int __init rfkill_init(void)
 {
 	int error;
=20
+	error =3D rfkill_apm_led_trigger_register();
+	if (error)
+		goto out;
+
 	rfkill_update_global_state(RFKILL_TYPE_ALL, !rfkill_default_state);
=20
 	error =3D class_register(&rfkill_class);
-	if (error)
+	if (error) {
+		rfkill_apm_led_trigger_unregister();
 		goto out;
+	}
=20
 	error =3D misc_register(&rfkill_miscdev);
 	if (error) {
 		class_unregister(&rfkill_class);
+		rfkill_apm_led_trigger_unregister();
 		goto out;
 	}
=20
@@ -1277,6 +1322,7 @@ static int __init rfkill_init(void)
 	if (error) {
 		misc_deregister(&rfkill_miscdev);
 		class_unregister(&rfkill_class);
+		rfkill_apm_led_trigger_unregister();
 		goto out;
 	}
 #endif
@@ -1293,5 +1339,6 @@ static void __exit rfkill_exit(void)
 #endif
 	misc_deregister(&rfkill_miscdev);
 	class_unregister(&rfkill_class);
+	rfkill_apm_led_trigger_unregister();
 }
 module_exit(rfkill_exit);
--=20
2.5.0
