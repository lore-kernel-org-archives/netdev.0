From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCHv2 05/10] rfkill: Factor rfkill_global_states[].cur assignments
Date: Mon, 22 Feb 2016 11:36:36 -0500
Message-ID: <1456159001-20307-6-git-send-email-jprvita@endlessm.com>
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

=46actor all assignments to rfkill_global_states[].cur into a single
function rfkill_update_global_state().

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 net/rfkill/core.c | 38 +++++++++++++++++---------------------
 1 file changed, 17 insertions(+), 21 deletions(-)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 56d79cb..8b96869 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -302,6 +302,19 @@ static void rfkill_set_block(struct rfkill *rfkill=
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
@@ -319,15 +332,7 @@ static void __rfkill_switch_all(const enum rfkill_=
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
@@ -1164,15 +1169,8 @@ static ssize_t rfkill_fop_write(struct file *fil=
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
@@ -1261,10 +1259,8 @@ static struct miscdevice rfkill_miscdev =3D {
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
