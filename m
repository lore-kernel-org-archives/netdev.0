From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH 3/8] rfkill: Improve code readability
Date: Tue, 19 Jan 2016 10:42:38 -0500
Message-ID: <1453218163-31998-4-git-send-email-jprvita@endlessm.com>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jprvita@endlessm.com,
	linux@endlessm.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34484 "EHLO
	mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755861AbcASPoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 10:44:06 -0500
In-Reply-To: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__rfkill_set_hw_state() is only one used in rfkill_set_hw_state(), and
none of them are long or complicated, so merging the two makes the code
easier to read.

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 net/rfkill/core.c | 41 +++++++++++++++--------------------------
 1 file changed, 15 insertions(+), 26 deletions(-)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 838e869..5406c76 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -233,29 +233,6 @@ static void rfkill_event(struct rfkill *rfkill)
 	rfkill_send_events(rfkill, RFKILL_OP_CHANGE);
 }
=20
-static bool __rfkill_set_hw_state(struct rfkill *rfkill,
-				  bool blocked, bool *change)
-{
-	unsigned long flags;
-	bool prev, any;
-
-	BUG_ON(!rfkill);
-
-	spin_lock_irqsave(&rfkill->lock, flags);
-	prev =3D !!(rfkill->state & RFKILL_BLOCK_HW);
-	if (blocked)
-		rfkill->state |=3D RFKILL_BLOCK_HW;
-	else
-		rfkill->state &=3D ~RFKILL_BLOCK_HW;
-	*change =3D prev !=3D blocked;
-	any =3D !!(rfkill->state & RFKILL_BLOCK_ANY);
-	spin_unlock_irqrestore(&rfkill->lock, flags);
-
-	rfkill_led_trigger_event(rfkill);
-
-	return any;
-}
-
 /**
  * rfkill_set_block - wrapper for set_block method
  *
@@ -479,14 +456,26 @@ bool rfkill_get_global_sw_state(const enum rfkill=
_type type)
=20
 bool rfkill_set_hw_state(struct rfkill *rfkill, bool blocked)
 {
-	bool ret, change;
+	unsigned long flags;
+	bool ret, prev;
+
+	BUG_ON(!rfkill);
+
+	spin_lock_irqsave(&rfkill->lock, flags);
+	prev =3D !!(rfkill->state & RFKILL_BLOCK_HW);
+	if (blocked)
+		rfkill->state |=3D RFKILL_BLOCK_HW;
+	else
+		rfkill->state &=3D ~RFKILL_BLOCK_HW;
+	ret =3D !!(rfkill->state & RFKILL_BLOCK_ANY);
+	spin_unlock_irqrestore(&rfkill->lock, flags);
=20
-	ret =3D __rfkill_set_hw_state(rfkill, blocked, &change);
+	rfkill_led_trigger_event(rfkill);
=20
 	if (!rfkill->registered)
 		return ret;
=20
-	if (change)
+	if (prev !=3D blocked)
 		schedule_work(&rfkill->uevent_work);
=20
 	return ret;
--=20
2.5.0
