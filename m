From: Christian Engelmayer <cengelma@gmx.at>
Subject: [PATCH resend] rsi: Fix a potential memory leak in
 rsi_set_channel()
Date: Thu, 10 Apr 2014 20:31:46 +0200
Message-ID: <20140410203146.767149e7@spike>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/iHoF=8G47JmKKQiDyzh/ZF7"; protocol="application/pgp-signature"
Cc: dan.carpenter@oracle.com, joe@perches.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com, fariyaf@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/iHoF=8G47JmKKQiDyzh/ZF7
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Fix a potential memory leak in function rsi_set_channel() that is used to
program channel changes. The channel check block for the frequency bands
directly exits the function in case of an error, thus leaving an already
allocated skb unreferenced. Move the checks above allocating the skb.
Detected by Coverity: CID 1195576.

Signed-off-by: Christian Engelmayer <cengelma@gmx.at>
---
Applies against git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.g=
it
Compile tested.
---
 drivers/net/wireless/rsi/rsi_91x_mgmt.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_mgmt.c b/drivers/net/wireless=
/rsi/rsi_91x_mgmt.c
index 2361a68..be5b1fd 100644
--- a/drivers/net/wireless/rsi/rsi_91x_mgmt.c
+++ b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
@@ -841,16 +841,6 @@ int rsi_set_channel(struct rsi_common *common, u16 cha=
nnel)
 	rsi_dbg(MGMT_TX_ZONE,
 		"%s: Sending scan req frame\n", __func__);
=20
-	skb =3D dev_alloc_skb(FRAME_DESC_SZ);
-	if (!skb) {
-		rsi_dbg(ERR_ZONE, "%s: Failed in allocation of skb\n",
-			__func__);
-		return -ENOMEM;
-	}
-
-	memset(skb->data, 0, FRAME_DESC_SZ);
-	mgmt_frame =3D (struct rsi_mac_frame *)skb->data;
-
 	if (common->band =3D=3D IEEE80211_BAND_5GHZ) {
 		if ((channel >=3D 36) && (channel <=3D 64))
 			channel =3D ((channel - 32) / 4);
@@ -868,6 +858,16 @@ int rsi_set_channel(struct rsi_common *common, u16 cha=
nnel)
 		}
 	}
=20
+	skb =3D dev_alloc_skb(FRAME_DESC_SZ);
+	if (!skb) {
+		rsi_dbg(ERR_ZONE, "%s: Failed in allocation of skb\n",
+			__func__);
+		return -ENOMEM;
+	}
+
+	memset(skb->data, 0, FRAME_DESC_SZ);
+	mgmt_frame =3D (struct rsi_mac_frame *)skb->data;
+
 	mgmt_frame->desc_word[0] =3D cpu_to_le16(RSI_WIFI_MGMT_Q << 12);
 	mgmt_frame->desc_word[1] =3D cpu_to_le16(SCAN_REQUEST);
 	mgmt_frame->desc_word[4] =3D cpu_to_le16(channel);
--=20
1.8.3.2

--Sig_/iHoF=8G47JmKKQiDyzh/ZF7
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJTRuOSAAoJEKssnEpaPQKE8b8P/RQcnFMCHuu4EQsD7Uo9p36I
xe4nYc6hImIpaQV1HsbBXA0Zvi7PjssSOOqobyVdyhsWrwxwiR9LvEH+n/+I+DIm
qr8V09UnM7mcW6Qk7Kc5hojTZG0ggG+1G9WbDXNT9aJgskX2Q2ltPWdk1R6ShqJW
L7QEY1+qX3LxVkUD60fPCa6xMt9UgRjEzB2MD57gOxDJYZ5rHXoVsOEvaeWcNQPe
T7JOK2F+h/x7vhyRBOYkfWL7nM5JhOh3Sx7b3VE3nUkDy+QMu3cK5nq+d6YKFptK
XLRqY3/hNmuaY8s6wVRlx7ES1q4flYQK2MLx0K+ElNzkkfOuYFnGPVBdyiLQGyKm
DiUl7rOMsrLoqGB1MytZRPPZTQPqp8So9/HsKkOpfoslYichsbPvmKKMk92DQPw7
SoOwPh7O7qgczgOGlHuZG3XHl2zA0jiZWR+EAWsX1ygJG2fsSuy0TxbT+e1b0aL3
Fk2SbzqrNjY4UMx3bHN4H14wePhKbJuvjShVZfOcZm5rJCSrGbZQ10zoFgM3ya1l
uqqhaYmeq9FLBOeoj9/H0GYaRt7/36lP59xXE8eLQB29TpHmSmzYmVRhbzdlHmFU
NB3+tlv8GdoUP6PX+/m4CjbbyznrwfbWQ8RbAin08lHDv1n4SkA8EV/qhWZpB2wZ
YqUhbqhuJ0XREhFNC/bQ
=mh/v
-----END PGP SIGNATURE-----

--Sig_/iHoF=8G47JmKKQiDyzh/ZF7--
