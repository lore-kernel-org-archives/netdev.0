From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCHv2 09/10] rfkill: Userspace control for airplane mode
Date: Mon, 22 Feb 2016 11:36:40 -0500
Message-ID: <1456159001-20307-10-git-send-email-jprvita@endlessm.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Sender: linux-kernel-owner@vger.kernel.org
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

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 Documentation/rfkill.txt    | 10 ++++++++++
 include/uapi/linux/rfkill.h |  6 ++++++
 net/rfkill/core.c           | 35 +++++++++++++++++++++++++++++++++--
 3 files changed, 49 insertions(+), 2 deletions(-)

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
index b13025a..9dbe3fc 100644
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
+using RFKILL_OP_AIRPLANE_MODE_INDICATOR_ACQUIRE, and is only available=
 for one
+userspace application at a time. Closing the fd reverts the airplane-m=
ode
+indicator back to the default kernel policy and makes it available for=
 other
+applications to take control. Changes to the airplane-mode indicator s=
tate can
+be made using RFKILL_OP_AIRPLANE_MODE_INDICATOR_CHANGE, passing the ne=
w value
+in the 'soft' field of 'struct rfkill_event'.
+
=20
 For further details consult Documentation/ABI/stable/sysfs-class-rfkil=
l.
diff --git a/include/uapi/linux/rfkill.h b/include/uapi/linux/rfkill.h
index 2e00dce..36e0770 100644
--- a/include/uapi/linux/rfkill.h
+++ b/include/uapi/linux/rfkill.h
@@ -61,12 +61,18 @@ enum rfkill_type {
  * @RFKILL_OP_CHANGE_ALL: userspace changes all devices (of a type, or=
 all)
  *	into a state, also updating the default state used for devices that
  *	are hot-plugged later.
+ * @RFKILL_OP_AIRPLANE_MODE_INDICATOR_ACQUIRE: userspace acquires cont=
rol of
+ * 	the airplane-mode indicator.
+ * @RFKILL_OP_AIRPLANE_MODE_INDICATOR_CHANGE: userspace changes the
+ * 	airplane-mode indicator state.
  */
 enum rfkill_operation {
 	RFKILL_OP_ADD =3D 0,
 	RFKILL_OP_DEL,
 	RFKILL_OP_CHANGE,
 	RFKILL_OP_CHANGE_ALL,
+	RFKILL_OP_AIRPLANE_MODE_INDICATOR_ACQUIRE,
+	RFKILL_OP_AIRPLANE_MODE_INDICATOR_CHANGE,
 };
=20
 /**
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 04d7fa1..8ea8b73 100644
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
@@ -1180,9 +1182,23 @@ static ssize_t rfkill_fop_read(struct file *file=
, char __user *buf,
 	return ret;
 }
=20
+static int rfkill_airplane_mode_release(struct rfkill_data *data)
+{
+	bool state =3D rfkill_global_states[RFKILL_TYPE_ALL].cur;
+
+	if (rfkill_apm_owned && data->is_apm_owner) {
+		rfkill_apm_owned =3D false;
+		data->is_apm_owner =3D false;
+		rfkill_apm_led_trigger_event(state);
+		return 0;
+	}
+	return -EACCES;
+}
+
 static ssize_t rfkill_fop_write(struct file *file, const char __user *=
buf,
 				size_t count, loff_t *pos)
 {
+	struct rfkill_data *data =3D file->private_data;
 	struct rfkill *rfkill;
 	struct rfkill_event ev;
 	int ret =3D 0;
@@ -1218,6 +1234,20 @@ static ssize_t rfkill_fop_write(struct file *fil=
e, const char __user *buf,
 			if (rfkill->idx =3D=3D ev.idx && rfkill->type =3D=3D ev.type)
 				rfkill_set_block(rfkill, ev.soft);
 		break;
+	case RFKILL_OP_AIRPLANE_MODE_INDICATOR_ACQUIRE:
+		if (rfkill_apm_owned && !data->is_apm_owner) {
+			ret =3D -EACCES;
+		} else {
+			rfkill_apm_owned =3D true;
+			data->is_apm_owner =3D true;
+		}
+		break;
+	case RFKILL_OP_AIRPLANE_MODE_INDICATOR_CHANGE:
+		if (rfkill_apm_owned && data->is_apm_owner)
+			rfkill_apm_led_trigger_event(ev.soft);
+		else
+			ret =3D -EACCES;
+		break;
 	default:
 		ret =3D -EINVAL;
 		break;
@@ -1234,6 +1264,7 @@ static int rfkill_fop_release(struct inode *inode=
, struct file *file)
 	struct rfkill_int_event *ev, *tmp;
=20
 	mutex_lock(&rfkill_global_mutex);
+	rfkill_airplane_mode_release(data);
 	list_del(&data->list);
 	mutex_unlock(&rfkill_global_mutex);
=20
--=20
2.5.0
