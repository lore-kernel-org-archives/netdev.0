From: NeilBrown <neilb@suse.de>
Subject: [PATCH] hso: fix refcnt leak in recent patch.
Date: Tue, 14 Apr 2015 09:36:34 +1000
Message-ID: <20150414093634.4fe24ba3@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/PYbU3c00gd2=sKDuYNj6pgy"; protocol="application/pgp-signature"
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	GTA04 owners <gta04-owner@goldelico.com>
To: Olivier Sobrie <olivier@sobrie.be>,
	"David S. Miller" <davem@davemloft.net>,
	Jan Dumon <j.dumon@option.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/PYbU3c00gd2=sKDuYNj6pgy
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



Prior to
commit 29bd3bc1194c624ce863cab2a7da9bc1f0c3b47b
    hso: fix crash when device disappears while serial port is open

hso_serial_open would always kref_get(&serial->parent->ref) before
returning zero.
Since that commit, it only calls kref_get when returning 0 if
serial->port.count was zero.

This results in calls to
       kref_put(&serial->parent->ref, hso_serial_ref_free);

after hso_serial_ref_free has been called, which dereferences a freed
pointer.

This patch adds the missing kref_get().

Fixes: commit 29bd3bc1194c624ce863cab2a7da9bc1f0c3b47b
Cc: stable@vger.kernel.org (v4.0)
Cc: Olivier Sobrie <olivier@sobrie.be>
Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 75befc1bd816..6848fc903340 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -1299,6 +1299,7 @@ static int hso_serial_open(struct tty_struct *tty, st=
ruct file *filp)
 		}
 	} else {
 		D1("Port was already open");
+		kref_get(&serial->parent->ref);
 	}
=20
 	usb_autopm_put_interface(serial->parent->interface);

--Sig_/PYbU3c00gd2=sKDuYNj6pgy
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVSxTAjnsnt1WYoG5AQIEOA/+MvJxANmt5k8pIpodsslXNQoiixv43X/E
yJoZYLice2S+TADLCfT4wO1O/eMHtWMRUQUARI2grLWx2ZUQV5Bka7d2JgxeXv6M
OTj++3PpquMNmB0TQOD9axPu2f41gvgCz1dex/RaZWjJYstIBimDIE25Vc3keFMO
w1pEC6CxFRd2NJysOCNz6YtptHoBOuieAem1/jkeT9FgeB/DeStoKWMJ6O+eM+b9
tYaUcVVoXbL+++G/y4iv5N8zjonC374oz7gfp5ltShX2IRyd5YXZTPGzd7MW5IAF
PfbECn4qF2qKSLgo8NNbeu5ZWXgj+3AZF9GsZHSbWoV1YqxbQsFxe1S/qI/ZbNvp
qqBfQPMurUi9xHthckpqRZKpl3y3xwmbMyAiiCNis7hxk8EsPnj/Qzum9WZ4phP5
/w3MSXa0Q/buDdyI4UxCDOJIbO3aics8H0r5HKk5WyyZGFymbUp+KEy8POlcgTcr
CyfprrOei4QwTDuk4FdMy2Bk2fTRo0ul6e+vLytF6FpISKQsTjPJsf0wimQQDKWA
jpufLiHkx9p0OWzC1WcamrLNdx5mg6NmjayA9IMGtKOYgiUUIgwXN8/IPdTe85hZ
djY24luLKzaRjIsw4HaGl2O74wZi6Gi5mXwYt4FNsF2z13WbAFkDXxKc4l98gla9
HY4lbiGEhCc=
=bji5
-----END PGP SIGNATURE-----

--Sig_/PYbU3c00gd2=sKDuYNj6pgy--
