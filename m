From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH] d80211: Fix inconsistent sta_lock usage
Date: Mon, 01 Jan 2007 21:19:06 +0100
Message-ID: <45996CBA.8020307@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4F1139249D2ECD8550217E42"
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>,
	rt2400-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:42237 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932817AbXAAUto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jan 2007 15:49:44 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4F1139249D2ECD8550217E42
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hacking a bit on rt2x00 to make it work in master and ad-hoc mode, lockde=
p
popped up on some hostapd ioctls, pointing out remaining inconsistencies
related to sta_lock:

1. sta_lock holders must always be protected against softirq
2. bss_tim_set/clear must not be called with sta_lock held, rather an
   unprotected variant
3. ieee80211_ioctl_remove_sta is not already holding the lock when callin=
g
   sta_info_free

As I was not sure if sta_info_remove_aid_ptr needs lock protection or
not, I played safe and moved it always under the lock. Please correct me
if this is overkill.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>

[Sorry, patch is against rt2x00 CVS. I'm lacking time and bandwidth to pu=
ll
the d80211 git repos and rebase.]

---
 ieee80211/ieee80211_i.h     |   24 ++++++++++++++++++------
 ieee80211/ieee80211_ioctl.c |    4 +++-
 ieee80211/sta_info.c        |    2 +-
 3 files changed, 22 insertions(+), 8 deletions(-)

Index: rt2x00/ieee80211/ieee80211_ioctl.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- rt2x00.orig/ieee80211/ieee80211_ioctl.c
+++ rt2x00/ieee80211/ieee80211_ioctl.c
@@ -286,7 +286,9 @@ static int ieee80211_ioctl_add_sta(struc
 	if (sta->dev !=3D dev) {
 		/* Binding STA to a new interface, so remove all references to
 		 * the old BSS. */
+		spin_lock_bh(&local->sta_lock);
 		sta_info_remove_aid_ptr(sta);
+		spin_unlock_bh(&local->sta_lock);
 	}
=20
         /* TODO
@@ -360,7 +362,7 @@ static int ieee80211_ioctl_remove_sta(st
 	sta =3D sta_info_get(local, param->sta_addr);
 	if (sta) {
 		sta_info_put(sta);
-		sta_info_free(sta, 1);
+		sta_info_free(sta, 0);
 	}
=20
 	return sta ? 0 : -ENOENT;
Index: rt2x00/ieee80211/ieee80211_i.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- rt2x00.orig/ieee80211/ieee80211_i.h
+++ rt2x00/ieee80211/ieee80211_i.h
@@ -565,20 +565,32 @@ struct sta_attribute {
 	ssize_t (*store)(struct sta_info *, const char *buf, size_t count);
 };
=20
+static inline void __bss_tim_set(struct ieee80211_local *local,
+				 struct ieee80211_if_ap *bss, int aid)
+{
+	bss->tim[(aid)/8] |=3D 1<<((aid) % 8);
+}
+
 static inline void bss_tim_set(struct ieee80211_local *local,
 			       struct ieee80211_if_ap *bss, int aid)
 {
-	spin_lock(&local->sta_lock);
-	bss->tim[(aid)/8] |=3D 1<<((aid) % 8);
-	spin_unlock(&local->sta_lock);
+	spin_lock_bh(&local->sta_lock);
+	__bss_tim_set(local, bss, aid);
+	spin_unlock_bh(&local->sta_lock);
+}
+
+static inline void __bss_tim_clear(struct ieee80211_local *local,
+				   struct ieee80211_if_ap *bss, int aid)
+{
+	bss->tim[(aid)/8] &=3D !(1<<((aid) % 8));
 }
=20
 static inline void bss_tim_clear(struct ieee80211_local *local,
 				 struct ieee80211_if_ap *bss, int aid)
 {
-	spin_lock(&local->sta_lock);
-	bss->tim[(aid)/8] &=3D !(1<<((aid) % 8));
-	spin_unlock(&local->sta_lock);
+	spin_lock_bh(&local->sta_lock);
+	__bss_tim_clear(local, bss, aid);
+	spin_unlock_bh(&local->sta_lock);
 }
=20
 /* ieee80211.c */
Index: rt2x00/ieee80211/sta_info.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- rt2x00.orig/ieee80211/sta_info.c
+++ rt2x00/ieee80211/sta_info.c
@@ -439,7 +439,7 @@ void sta_info_remove_aid_ptr(struct sta_
 		sdata->local->ops->set_tim(local_to_hw(sdata->local),
 					  sta->aid, 0);
 	if (sdata->bss)
-		bss_tim_clear(sdata->local, sdata->bss, sta->aid);
+		__bss_tim_clear(sdata->local, sdata->bss, sta->aid);
 }
=20
=20



--------------enig4F1139249D2ECD8550217E42
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iD8DBQFFmWy6niDOoMHTA+kRAnUwAJ9658b9fIF1YkSG7qYWp5pMj/QpTgCeNCPt
1F2u4E5Rql99IHC075sbOL0=
=mUnF
-----END PGP SIGNATURE-----

--------------enig4F1139249D2ECD8550217E42--
