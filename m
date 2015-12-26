From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net/rfkill: Create "airplane mode" LED trigger
Date: Sat, 26 Dec 2015 10:05:03 -0500
Message-ID: <1451142303-1872-2-git-send-email-jprvita@endlessm.com>
References: <1451142303-1872-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451142303-1872-1-git-send-email-jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46or platform drivers to be able to correctly drive the "Airplane Mode=
"
indicative LED there needs to be a RFKill LED trigger tied to the globa=
l
state of RFKILL_TYPE_ALL (instead of to a specific RFKill) and that
works in an inverted manner of regular RFKill LED triggers, that is, th=
e
LED is ON when the state is blocked, and OFF otherwise.

This commit implements such a trigger, which will be used by the
asus-wireless x86 platform driver.

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
---
 net/rfkill/core.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index b41e9ea..3effc29 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -124,6 +124,26 @@ static bool rfkill_epo_lock_active;
=20
=20
 #ifdef CONFIG_RFKILL_LEDS
+static void airplane_mode_led_trigger_activate(struct led_classdev *le=
d);
+
+static struct led_trigger airplane_mode_led_trigger =3D {
+	.name     =3D "rfkill-airplane-mode",
+	.activate =3D airplane_mode_led_trigger_activate,
+};
+
+static void airplane_mode_led_trigger_event(void)
+{
+	if (rfkill_global_states[RFKILL_TYPE_ALL].cur & RFKILL_BLOCK_ANY)
+		led_trigger_event(&airplane_mode_led_trigger, LED_FULL);
+	else
+		led_trigger_event(&airplane_mode_led_trigger, LED_OFF);
+}
+
+static void airplane_mode_led_trigger_activate(struct led_classdev *le=
d)
+{
+	airplane_mode_led_trigger_event();
+}
+
 static void rfkill_led_trigger_event(struct rfkill *rfkill)
 {
 	struct led_trigger *trigger;
@@ -175,6 +195,10 @@ static void rfkill_led_trigger_unregister(struct r=
fkill *rfkill)
 	led_trigger_unregister(&rfkill->led_trigger);
 }
 #else
+static void airplane_mode_led_trigger_event(void)
+{
+}
+
 static void rfkill_led_trigger_event(struct rfkill *rfkill)
 {
 }
@@ -346,6 +370,7 @@ static void __rfkill_switch_all(const enum rfkill_t=
ype type, bool blocked)
=20
 		for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
 			rfkill_global_states[i].cur =3D blocked;
+		airplane_mode_led_trigger_event();
 	} else {
 		rfkill_global_states[type].cur =3D blocked;
 	}
@@ -1177,6 +1202,7 @@ static ssize_t rfkill_fop_write(struct file *file=
, const char __user *buf,
 			enum rfkill_type i;
 			for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
 				rfkill_global_states[i].cur =3D ev.soft;
+			airplane_mode_led_trigger_event();
 		} else {
 			rfkill_global_states[ev.type].cur =3D ev.soft;
 		}
@@ -1293,6 +1319,10 @@ static int __init rfkill_init(void)
 	}
 #endif
=20
+#ifdef CONFIG_RFKILL_LEDS
+	led_trigger_register(&airplane_mode_led_trigger);
+#endif
+
  out:
 	return error;
 }
--=20
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
