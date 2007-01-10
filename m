From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH] d80211: Fix __ieee80211_if_del on live interfaces
Date: Wed, 10 Jan 2007 01:19:14 -0500
Message-ID: <200701100119.19523.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1449393.rhhnhEXfsI";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Ulrich Kunitz <kune@deine-taler.de>,
	Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:46183 "EHLO
	server8.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932614AbXAJGUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 01:20:05 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1449393.rhhnhEXfsI
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: Fix __ieee80211_if_del on live interfaces

ieee80211_if_reinit is called in __ieee80211_if_del, which clears the
contents of sdata->u. After that, unregister_netdevice is called. If the
interface is still up, unregister_netdevice will end up calling dev->stop,
and dev->stop expects the contents of sdata->u to be valid. Bad things
typically happen at this point.

This patch fixes that by setting dev->uninit to ieee80211_if_reinit and
eliminating the call to ieee80211_if_reinit in __ieee80211_if_del. This
allows ieee80211_if_reinit to be called at a safer time. It also allows
the removal of the call to ieee80211_if_shutdown in ieee80211_if_reinit
because ieee80211_if_reinit now will never be called while the interface
is up.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 net/d80211/ieee80211.c       |    2 ++
 net/d80211/ieee80211_iface.c |    4 ----
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 964fe45..2f1dce5 100644
=2D-- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4324,6 +4324,7 @@ void ieee80211_if_setup(struct net_devic
 	dev->open =3D ieee80211_open;
 	dev->stop =3D ieee80211_stop;
 	dev->tx_queue_len =3D 0;
+	dev->uninit =3D ieee80211_if_reinit;
 	dev->destructor =3D ieee80211_if_free;
 }
=20
@@ -4338,6 +4339,7 @@ void ieee80211_if_mgmt_setup(struct net_
 	dev->type =3D ARPHRD_IEEE80211_PRISM;
 	dev->hard_header_parse =3D header_parse_80211;
 	dev->tx_queue_len =3D 0;
+	dev->uninit =3D ieee80211_if_reinit;
 	dev->destructor =3D ieee80211_if_free;
 }
=20
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index cac0dd5..3b2d259 100644
=2D-- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -234,9 +234,6 @@ void ieee80211_if_reinit(struct net_devi
 		sdata->keys[i] =3D NULL;
 	}
=20
=2D	/* Shouldn't be necessary but won't hurt */
=2D	ieee80211_if_shutdown(dev);
=2D
 	switch (sdata->type) {
 	case IEEE80211_IF_TYPE_AP: {
 		/* Remove all virtual interfaces that use this BSS
@@ -311,7 +308,6 @@ void __ieee80211_if_del(struct ieee80211
 {
 	struct net_device *dev =3D sdata->dev;
=20
=2D	ieee80211_if_reinit(dev);
 	list_del(&sdata->list);
 	ieee80211_sysfs_remove_netdevice(dev);
 	unregister_netdevice(dev);

--nextPart1449393.rhhnhEXfsI
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFpIVnT3Oqt9AH4aERAlR7AJ4mWNmgd1kHegAtTwFxqMGsfF3OqwCfQ4mA
gr4VjeMXcExIe0rwMO02cQk=
=FHDo
-----END PGP SIGNATURE-----

--nextPart1449393.rhhnhEXfsI--
