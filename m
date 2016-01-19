From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 8/8] rfkill: Factor common code
Date: Tue, 19 Jan 2016 10:42:43 -0500
Message-ID: <1453218163-31998-9-git-send-email-jprvita@endlessm.com>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org,
	linux-6IF/jdPJHihWk0Htik3J/w@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1453218163-31998-1-git-send-email-jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46actor all assignments to rfkill_global_states[].cur to
rfkill_update_global_state(), and also make accesses to
rfkill_global_states[].cur go through rfkill_get_global_sw_state().

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita-6IF/jdPJHihWk0Htik3J/w@public.gmane.org>
---
 net/rfkill/core.c | 40 ++++++++++++++++++----------------------
 1 file changed, 18 insertions(+), 22 deletions(-)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 0b9d5bf..ae3d15a 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -300,6 +300,19 @@ static void rfkill_set_block(struct rfkill *rfkill=
, bool blocked)
 		rfkill_event(rfkill);
 }
=20
+static void rfkill_update_global_state(enum rfkill_type type, bool blo=
cked)
+{
+	int i;
+
+	if (type !=3D RFKILL_TYPE_ALL) {
+		rfkill_global_states[type].cur =3D blocked;
+		return;
+	}
+
+	for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
+		rfkill_global_states[i].cur =3D blocked;
+}
+
 #ifdef CONFIG_RFKILL_INPUT
 static atomic_t rfkill_input_disabled =3D ATOMIC_INIT(0);
=20
@@ -317,15 +330,7 @@ static void __rfkill_switch_all(const enum rfkill_=
type type, bool blocked)
 {
 	struct rfkill *rfkill;
=20
-	if (type =3D=3D RFKILL_TYPE_ALL) {
-		int i;
-
-		for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
-			rfkill_global_states[i].cur =3D blocked;
-	} else {
-		rfkill_global_states[type].cur =3D blocked;
-	}
-
+	rfkill_update_global_state(type, blocked);
 	list_for_each_entry(rfkill, &rfkill_list, node) {
 		if (rfkill->type !=3D type && type !=3D RFKILL_TYPE_ALL)
 			continue;
@@ -877,7 +882,7 @@ static void rfkill_sync_work(struct work_struct *wo=
rk)
 	rfkill =3D container_of(work, struct rfkill, sync_work);
=20
 	mutex_lock(&rfkill_global_mutex);
-	cur =3D rfkill_global_states[rfkill->type].cur;
+	cur =3D rfkill_get_global_sw_state(rfkill->type);
 	rfkill_set_block(rfkill, cur);
 	mutex_unlock(&rfkill_global_mutex);
 }
@@ -1116,15 +1121,8 @@ static ssize_t rfkill_fop_write(struct file *fil=
e, const char __user *buf,
=20
 	mutex_lock(&rfkill_global_mutex);
=20
-	if (ev.op =3D=3D RFKILL_OP_CHANGE_ALL) {
-		if (ev.type =3D=3D RFKILL_TYPE_ALL) {
-			enum rfkill_type i;
-			for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
-				rfkill_global_states[i].cur =3D ev.soft;
-		} else {
-			rfkill_global_states[ev.type].cur =3D ev.soft;
-		}
-	}
+	if (ev.op =3D=3D RFKILL_OP_CHANGE_ALL)
+		rfkill_update_global_state(ev.type, ev.soft);
=20
 	list_for_each_entry(rfkill, &rfkill_list, node) {
 		if (rfkill->idx !=3D ev.idx && ev.op !=3D RFKILL_OP_CHANGE_ALL)
@@ -1213,10 +1211,8 @@ static struct miscdevice rfkill_miscdev =3D {
 static int __init rfkill_init(void)
 {
 	int error;
-	int i;
=20
-	for (i =3D 0; i < NUM_RFKILL_TYPES; i++)
-		rfkill_global_states[i].cur =3D !rfkill_default_state;
+	rfkill_update_global_state(RFKILL_TYPE_ALL, !rfkill_default_state);
=20
 	error =3D class_register(&rfkill_class);
 	if (error)
--=20
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
