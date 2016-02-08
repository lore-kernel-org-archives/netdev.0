From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 8/9] rfkill: Userspace control for airplane mode
Date: Mon,  8 Feb 2016 10:41:35 -0500
Message-ID: <1454946096-9752-9-git-send-email-jprvita@endlessm.com>
References: <1454946096-9752-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Darren Hart <dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1454946096-9752-1-git-send-email-jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Provide an interface for the airplane-mode indicator be controlled from
userspace. User has to first acquire the control through
RFKILL_OP_AIRPLANE_MODE_ACQUIRE and keep the fd open for the whole time
it wants to be in control of the indicator. Closing the fd or using
RFKILL_OP_AIRPLANE_MODE_RELEASE restores the default policy.

To change state of the indicator, the RFKILL_OP_AIRPLANE_MODE_CHANGE
operation is used, passing the value on "struct rfkill_event.soft". If
the caller has not acquired the airplane-mode control beforehand, the
operation fails.

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
---
 Documentation/rfkill.txt    | 10 ++++++++++
 include/uapi/linux/rfkill.h |  3 +++
 net/rfkill/core.c           | 47 +++++++++++++++++++++++++++++++++++++=
+++++---
 3 files changed, 57 insertions(+), 3 deletions(-)

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
index b13025a..aa6e014 100644
--- a/Documentation/rfkill.txt
+++ b/Documentation/rfkill.txt
@@ -87,6 +87,7 @@ RFKill provides per-switch LED triggers, which can be=
 used to drive LEDs
 according to the switch state (LED_FULL when blocked, LED_OFF otherwis=
e).
 An airplane-mode indicator LED trigger is also available, which trigge=
rs
 LED_FULL when all radios known by RFKill are blocked, and LED_OFF othe=
rwise.
+The airplane-mode indicator LED trigger policy can be overridden by us=
erspace.
=20
=20
 5. Userspace support
@@ -123,5 +124,14 @@ RFKILL_TYPE
 The contents of these variables corresponds to the "name", "state" and
 "type" sysfs files explained above.
=20
+Userspace can also override the default airplane-mode indicator policy=
 through
+/dev/rfkill. Control of the airplane mode indicator has to be acquired=
 first,
+using RFKILL_OP_AIRPLANE_MODE_ACQUIRE, and is only available for one u=
serspace
+application at a time. Closing the fd or using RFKILL_OP_AIRPLANE_MODE=
_RELEASE
+reverts the airplane-mode indicator back to the default kernel policy =
and makes
+it available for other applications to take control. Changes to the
+airplane-mode indicator state can be made using RFKILL_OP_AIRPLANE_MOD=
E_CHANGE,
+passing the new value in the 'soft' field of 'struct rfkill_event'.
+
=20
 For further details consult Documentation/ABI/stable/sysfs-class-rfkil=
l.
diff --git a/include/uapi/linux/rfkill.h b/include/uapi/linux/rfkill.h
index 2e00dce..9cb999b 100644
--- a/include/uapi/linux/rfkill.h
+++ b/include/uapi/linux/rfkill.h
@@ -67,6 +67,9 @@ enum rfkill_operation {
 	RFKILL_OP_DEL,
 	RFKILL_OP_CHANGE,
 	RFKILL_OP_CHANGE_ALL,
+	RFKILL_OP_AIRPLANE_MODE_ACQUIRE,
+	RFKILL_OP_AIRPLANE_MODE_RELEASE,
+	RFKILL_OP_AIRPLANE_MODE_CHANGE,
 };
=20
 /**
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index fb11547..8067701 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -89,6 +89,7 @@ struct rfkill_data {
 	struct mutex		mtx;
 	wait_queue_head_t	read_wait;
 	bool			input_handler;
+	bool			is_apm_owner;
 };
=20
=20
@@ -123,7 +124,7 @@ static struct {
 } rfkill_global_states[NUM_RFKILL_TYPES];
=20
 static bool rfkill_epo_lock_active;
-
+static bool rfkill_apm_owned;
=20
 #ifdef CONFIG_RFKILL_LEDS
 static struct led_trigger rfkill_apm_led_trigger;
@@ -350,7 +351,8 @@ static void rfkill_update_global_state(enum rfkill_=
type type, bool blocked)
=20
 	for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
 		rfkill_global_states[i].cur =3D blocked;
-	rfkill_apm_led_trigger_event(blocked);
+	if (!rfkill_apm_owned)
+		rfkill_apm_led_trigger_event(blocked);
 }
=20
 #ifdef CONFIG_RFKILL_INPUT
@@ -1183,6 +1185,7 @@ static ssize_t rfkill_fop_read(struct file *file,=
 char __user *buf,
 static ssize_t rfkill_fop_write(struct file *file, const char __user *=
buf,
 				size_t count, loff_t *pos)
 {
+	struct rfkill_data *data =3D file->private_data;
 	struct rfkill *rfkill;
 	struct rfkill_event ev;
=20
@@ -1199,7 +1202,7 @@ static ssize_t rfkill_fop_write(struct file *file=
, const char __user *buf,
 	if (copy_from_user(&ev, buf, count))
 		return -EFAULT;
=20
-	if (ev.op !=3D RFKILL_OP_CHANGE && ev.op !=3D RFKILL_OP_CHANGE_ALL)
+	if (ev.op < RFKILL_OP_CHANGE)
 		return -EINVAL;
=20
 	if (ev.type >=3D NUM_RFKILL_TYPES)
@@ -1207,6 +1210,34 @@ static ssize_t rfkill_fop_write(struct file *fil=
e, const char __user *buf,
=20
 	mutex_lock(&rfkill_global_mutex);
=20
+	if (ev.op =3D=3D RFKILL_OP_AIRPLANE_MODE_ACQUIRE) {
+		if (rfkill_apm_owned && !data->is_apm_owner) {
+			count =3D -EACCES;
+		} else {
+			rfkill_apm_owned =3D true;
+			data->is_apm_owner =3D true;
+		}
+	}
+
+	if (ev.op =3D=3D RFKILL_OP_AIRPLANE_MODE_RELEASE) {
+		if (rfkill_apm_owned && !data->is_apm_owner) {
+			count =3D -EACCES;
+		} else {
+			bool state =3D rfkill_global_states[RFKILL_TYPE_ALL].cur;
+
+			rfkill_apm_owned =3D false;
+			data->is_apm_owner =3D false;
+			rfkill_apm_led_trigger_event(state);
+		}
+	}
+
+	if (ev.op =3D=3D RFKILL_OP_AIRPLANE_MODE_CHANGE) {
+		if (rfkill_apm_owned && data->is_apm_owner)
+			rfkill_apm_led_trigger_event(ev.soft);
+		else
+			count =3D -EACCES;
+	}
+
 	if (ev.op =3D=3D RFKILL_OP_CHANGE_ALL)
 		rfkill_update_global_state(ev.type, ev.soft);
=20
@@ -1230,7 +1261,17 @@ static int rfkill_fop_release(struct inode *inod=
e, struct file *file)
 	struct rfkill_int_event *ev, *tmp;
=20
 	mutex_lock(&rfkill_global_mutex);
+
+	if (data->is_apm_owner) {
+		bool state =3D rfkill_global_states[RFKILL_TYPE_ALL].cur;
+
+		rfkill_apm_owned =3D false;
+		data->is_apm_owner =3D false;
+		rfkill_apm_led_trigger_event(state);
+	}
+
 	list_del(&data->list);
+
 	mutex_unlock(&rfkill_global_mutex);
=20
 	mutex_destroy(&data->mtx);
--=20
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
