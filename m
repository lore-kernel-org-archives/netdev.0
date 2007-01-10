From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH] d80211: fix default key symlink creation/cleanup
Date: Wed, 10 Jan 2007 21:42:01 +0100
Message-ID: <45A54F99.6030802@web.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig890FDB93850E3F7BCF6BBF7C"
Cc: netdev <netdev@vger.kernel.org>, Ivo Van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:58547 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965047AbXAJUmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 15:42:53 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig890FDB93850E3F7BCF6BBF7C
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Hi Jiri,

here is the revised version of 'don't symlink empty default keys'. Run-te=
sted
and diff'ed against your repos.

Jan


----------

This gets rid of annoying

wlan0: cannot create symlink to default key

in my syslog with latest rt2x00. The patch takes care to always delete an=

existing symlink to the default key before trying to register a new one.
Moreover, it avoids to call ieee80211_key_sysfs_add_default for a NULL ke=
y.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>

---
 net/d80211/ieee80211_ioctl.c     |    9 ++++-----
 net/d80211/ieee80211_sysfs_sta.c |    3 ++-
 2 files changed, 6 insertions(+), 6 deletions(-)

Index: linux-dscape/net/d80211/ieee80211_ioctl.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-dscape.orig/net/d80211/ieee80211_ioctl.c
+++ linux-dscape/net/d80211/ieee80211_ioctl.c
@@ -627,7 +627,7 @@ static int ieee80211_set_encryption(stru
 		}
 		kfree(keyconf);
=20
-		if (key && sdata->default_key =3D=3D key) {
+		if (set_tx_key || sdata->default_key =3D=3D key) {
 			ieee80211_key_sysfs_remove_default(sdata);
 			sdata->default_key =3D NULL;
 		}
@@ -671,7 +671,7 @@ static int ieee80211_set_encryption(stru
 			}
 		}
=20
-		if (old_key && sdata->default_key =3D=3D old_key) {
+		if (set_tx_key || sdata->default_key =3D=3D old_key) {
 			ieee80211_key_sysfs_remove_default(sdata);
 			sdata->default_key =3D NULL;
 		}
@@ -698,7 +698,7 @@ static int ieee80211_set_encryption(stru
=20
 	if (set_tx_key || (!sta && !sdata->default_key && key)) {
 		sdata->default_key =3D key;
-		if (ieee80211_key_sysfs_add_default(sdata))
+		if (key && ieee80211_key_sysfs_add_default(sdata))
 			printk(KERN_WARNING "%s: cannot create symlink to "
 			       "default key\n", dev->name);
 		if (local->ops->set_key_idx &&
@@ -2892,8 +2892,7 @@ static int ieee80211_ioctl_siwencode(str
 	else if (erq->length =3D=3D 0) {
 		/* No key data - just set the default TX key index */
 		if (sdata->default_key !=3D sdata->keys[idx]) {
-			if (sdata->default_key)
-				ieee80211_key_sysfs_remove_default(sdata);
+			ieee80211_key_sysfs_remove_default(sdata);
 			sdata->default_key =3D sdata->keys[idx];
 			if (sdata->default_key)
 				ieee80211_key_sysfs_add_default(sdata);
Index: linux-dscape/net/d80211/ieee80211_sysfs_sta.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-dscape.orig/net/d80211/ieee80211_sysfs_sta.c
+++ linux-dscape/net/d80211/ieee80211_sysfs_sta.c
@@ -433,5 +433,6 @@ int ieee80211_key_sysfs_add_default(stru
=20
 void ieee80211_key_sysfs_remove_default(struct ieee80211_sub_if_data *sd=
ata)
 {
-	sysfs_remove_link(&sdata->key_kset.kobj, "default");
+	if (sdata->default_key)
+		sysfs_remove_link(&sdata->key_kset.kobj, "default");
 }




--------------enig890FDB93850E3F7BCF6BBF7C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFFpU+ZniDOoMHTA+kRAnp2AJwPiu/6fmxkO9PIfxojP/wx2XL0xACeKoxw
8JKyF5kETE8oY5FS21AEeEA=
=ExnN
-----END PGP SIGNATURE-----

--------------enig890FDB93850E3F7BCF6BBF7C--
