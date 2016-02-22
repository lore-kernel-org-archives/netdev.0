From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCHv2 10/10] rfkill: Notify userspace of airplane-mode state changes
Date: Mon, 22 Feb 2016 11:36:41 -0500
Message-ID: <1456159001-20307-11-git-send-email-jprvita@endlessm.com>
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

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 Documentation/rfkill.txt    |  3 +++
 include/uapi/linux/rfkill.h |  4 ++--
 net/rfkill/core.c           | 13 +++++++++++++
 3 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/Documentation/rfkill.txt b/Documentation/rfkill.txt
index 9dbe3fc..588b4bf 100644
--- a/Documentation/rfkill.txt
+++ b/Documentation/rfkill.txt
@@ -133,5 +133,8 @@ applications to take control. Changes to the airpla=
ne-mode indicator state can
 be made using RFKILL_OP_AIRPLANE_MODE_INDICATOR_CHANGE, passing the ne=
w value
 in the 'soft' field of 'struct rfkill_event'.
=20
+This same API is also used to provide userspace with notifications of =
changes
+to airplane-mode indicator state.
+
=20
 For further details consult Documentation/ABI/stable/sysfs-class-rfkil=
l.
diff --git a/include/uapi/linux/rfkill.h b/include/uapi/linux/rfkill.h
index 36e0770..2ccb02f 100644
--- a/include/uapi/linux/rfkill.h
+++ b/include/uapi/linux/rfkill.h
@@ -63,8 +63,8 @@ enum rfkill_type {
  *	are hot-plugged later.
  * @RFKILL_OP_AIRPLANE_MODE_INDICATOR_ACQUIRE: userspace acquires cont=
rol of
  * 	the airplane-mode indicator.
- * @RFKILL_OP_AIRPLANE_MODE_INDICATOR_CHANGE: userspace changes the
- * 	airplane-mode indicator state.
+ * @RFKILL_OP_AIRPLANE_MODE_INDICATOR_CHANGE: the airplane-mode indica=
tor state
+ * 	changed -- userspace changes the airplane-mode indicator state.
  */
 enum rfkill_operation {
 	RFKILL_OP_ADD =3D 0,
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 8ea8b73..c59fd1d 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -131,7 +131,20 @@ static struct led_trigger rfkill_apm_led_trigger;
=20
 static void rfkill_apm_led_trigger_event(bool state)
 {
+	struct rfkill_data *data;
+	struct rfkill_int_event *ev;
+
 	led_trigger_event(&rfkill_apm_led_trigger, state ? LED_FULL : LED_OFF=
);
+
+	list_for_each_entry(data, &rfkill_fds, list) {
+		ev =3D kzalloc(sizeof(*ev), GFP_KERNEL);
+		if (!ev)
+			continue;
+		ev->ev.op =3D RFKILL_OP_AIRPLANE_MODE_INDICATOR_CHANGE;
+		ev->ev.soft =3D state;
+		list_add_tail(&ev->list, &data->events);
+		wake_up_interruptible(&data->read_wait);
+	}
 }
=20
 static void rfkill_apm_led_trigger_activate(struct led_classdev *led)
--=20
2.5.0
