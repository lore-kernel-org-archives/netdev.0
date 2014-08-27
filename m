From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Subject: [PATCH] carl9170: tx: Replace rcu_assign_pointer() with
 RCU_INIT_POINTER()
Date: Wed, 27 Aug 2014 16:27:30 +0300
Message-ID: <20140827132730.GA31650@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com
To: chunkeey@googlemail.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:48320 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932179AbaH0N1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 09:27:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to RCU_INIT_POINTER()'s block comment 3.a, it can be used if
"3.   The referenced data structure has already been exposed to readers=
 either
at compile time or via rcu_assign_pointer() -and-
 a.   You have not made -any- reader-visible changes to this structure =
since
then".

This case fulfills the conditions above because between the rcu_derefer=
ence()
call (cvif =3D rcu_dereference(ar->beacon_iter);) and the rcu_assign_po=
inter()
call there is no update of the "cvif" variable.
Therefore, this patch makes the replacement.

The following Coccinelle semantic patch was used:
@@
identifier v;
@@

v =3D rcu_dereference(...);
=2E.. when !=3D rcu_dereference(...);
    when !=3D v =3D ...;
    when !=3D (<+...v...+>)++;
    when !=3D \(memcpy\|memset\)(...);
(
- rcu_assign_pointer
+ RCU_INIT_POINTER
  (..., v);
|
 if(...) {
=2E.. when !=3D v =3D ...;
- rcu_assign_pointer
+ RCU_INIT_POINTER
  (..., v);
=2E.. when any
 }
)

Because there are cases where between a =E2=80=9Crcu_dereference()=E2=80=
=9D call and a
=E2=80=9Crcu_assign_pointer()=E2=80=9D call might be updates of the val=
ue that interests us,
the Coccinelle semantic patch ignores them and replaces with
"RCU_INIT_POINTER()" only when the update is not happening.

Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
---
 drivers/net/wireless/ath/carl9170/tx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/carl9170/tx.c b/drivers/net/wirel=
ess/ath/carl9170/tx.c
index 4cadfd4..ae86a600 100644
--- a/drivers/net/wireless/ath/carl9170/tx.c
+++ b/drivers/net/wireless/ath/carl9170/tx.c
@@ -1557,7 +1557,7 @@ static struct carl9170_vif_info *carl9170_pick_be=
aconing_vif(struct ar9170 *ar)
 	}
=20
 out:
-	rcu_assign_pointer(ar->beacon_iter, cvif);
+	RCU_INIT_POINTER(ar->beacon_iter, cvif);
 	return cvif;
 }
=20
--=20
1.9.1
