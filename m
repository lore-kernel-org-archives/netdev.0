From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: [PATCH 2/3] prism54: add WE17 support
Date: Thu, 19 Aug 2004 19:03:06 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040819230306.GA6044@ruslug.rutgers.edu>
References: <20040819225424.GY6044@ruslug.rutgers.edu>
	<20040819230003.GZ6044@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0392733072=="
Return-path: <prism54-devel-bounces@prism54.org>
To: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
	prism54-devel@prism54.org
In-Reply-To: <20040819230003.GZ6044@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============0392733072==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YPJ8CVbwFUtL7OFW"
Content-Disposition: inline


--YPJ8CVbwFUtL7OFW
Content-Type: multipart/mixed; boundary="+ZmrHH5cGjskQnY1"
Content-Disposition: inline


--+ZmrHH5cGjskQnY1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Relies on patches for WE17 from Jean Tourrilhes

2004-08-18	Jean Tourrilhes <jt@bougret.hpl.hp.com>

	* isl_ioctl.c, islpci_dev.[ch]: Add support for Wireless Extension 17

	* isl_ioctl.c (const struct iw_handler_def prism54_handler_def): Add .spy_=
offset=20
	only if WE =3D=3D 16 only check as this is being deprecated.=20

--=20
GnuPG Key fingerprint =3D 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E

--+ZmrHH5cGjskQnY1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="02-handle-WIRELESS_EXT17.diff"
Content-Transfer-Encoding: quoted-printable

diff -Naurp linux-2.6.8.1/drivers/net/wireless/prism54/isl_ioctl.c linux-2.=
6.8.1-prism54/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.8.1/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-16 18:05=
:53.000000000 +0000
+++ linux-2.6.8.1-prism54/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-=
16 18:02:34.000000000 +0000
@@ -451,6 +451,15 @@ prism54_get_range(struct net_device *nde
 	/* txpower is supported in dBm's */
 	range->txpower_capa =3D IW_TXPOW_DBM;
=20
+#if WIRELESS_EXT > 16
+	/* Event capability (kernel + driver) */
+	range->event_capa[0] =3D (IW_EVENT_CAPA_K_0 |
+	IW_EVENT_CAPA_MASK(SIOCGIWTHRSPY) |
+	IW_EVENT_CAPA_MASK(SIOCGIWAP));
+	range->event_capa[1] =3D IW_EVENT_CAPA_K_1;
+	range->event_capa[4] =3D IW_EVENT_CAPA_MASK(IWEVCUSTOM);
+#endif /* WIRELESS_EXT > 16 */
+
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return 0;
=20
@@ -656,19 +665,33 @@ prism54_get_scan(struct net_device *ndev
 	rvalue =3D mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
 	noise =3D r.u;
=20
-	/* Ask the device for a list of known bss. We can report at most
-	 * IW_MAX_AP=3D64 to the range struct. But the device won't repport anyth=
ing
-	 * if you change the value of IWMAX_BSS=3D24.
-	 */
+	/* Ask the device for a list of known bss.
+	* The old API, using SIOCGIWAPLIST, had a hard limit of IW_MAX_AP=3D64.
+	* The new API, using SIOCGIWSCAN, is only limited by the buffer size.
+	* WE-14->WE-16, the buffer is limited to IW_SCAN_MAX_DATA bytes.
+	* Starting with WE-17, the buffer can be as big as needed.
+	* But the device won't repport anything if you change the value
+	* of IWMAX_BSS=3D24. */
+=09
 	rvalue |=3D mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
 	bsslist =3D r.ptr;
=20
 	/* ok now, scan the list and translate its info */
-	for (i =3D 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
+	for (i =3D 0; i < (int) bsslist->nr; i++) {
 		current_ev =3D prism54_translate_bss(ndev, current_ev,
-						   extra + IW_SCAN_MAX_DATA,
+						   extra + dwrq->length,
 						   &(bsslist->bsslist[i]),
 						   noise);
+#if WIRELESS_EXT > 16
+		/* Check if there is space for one more entry */
+		if((extra + dwrq->length - current_ev) <=3D IW_EV_ADDR_LEN) {
+			/* Ask user space to try again with a bigger buffer */
+			rvalue =3D -E2BIG;
+			break;
+		}
+#endif /* WIRELESS_EXT > 16 */
+	}
+
 	kfree(bsslist);
 	dwrq->length =3D (current_ev - extra);
 	dwrq->flags =3D 0;	/* todo */
@@ -2222,7 +2245,9 @@ const struct iw_handler_def prism54_hand
 	.standard =3D (iw_handler *) prism54_handler,
 	.private =3D (iw_handler *) prism54_private_handler,
 	.private_args =3D (struct iw_priv_args *) prism54_private_args,
+#if WIRELESS_EXT =3D=3D 16
 	.spy_offset =3D offsetof(islpci_private, spy_data),
+#endif /* WIRELESS_EXT =3D=3D 16 */
 };
=20
 /* For ioctls that don't work with the new API */
diff -Naurp linux-2.6.8.1/drivers/net/wireless/prism54/islpci_dev.c linux-2=
.6.8.1-prism54/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.8.1/drivers/net/wireless/prism54/islpci_dev.c	2004-08-16 14:4=
7:48.000000000 +0000
+++ linux-2.6.8.1-prism54/drivers/net/wireless/prism54/islpci_dev.c	2004-08=
-16 18:10:30.000000000 +0000
@@ -829,6 +829,12 @@ islpci_setup(struct pci_dev *pdev)
 	priv->ndev->type =3D (priv->iw_mode =3D=3D IW_MODE_MONITOR) ?
 		priv->monitor_type : ARPHRD_ETHER;
=20
+#if WIRELESS_EXT > 16
+	/* Add pointers to enable iwspy support. */
+	priv->wireless_data.spy_data =3D &priv->spy_data;
+	ndev->wireless_data =3D &priv->wireless_data;
+#endif /* WIRELESS_EXT > 16 */
+
 	/* save the start and end address of the PCI memory area */
 	ndev->mem_start =3D (unsigned long) priv->device_base;
 	ndev->mem_end =3D ndev->mem_start + ISL38XX_PCI_MEM_SIZE;
diff -Naurp linux-2.6.8.1/drivers/net/wireless/prism54/islpci_dev.h linux-2=
.6.8.1-prism54/drivers/net/wireless/prism54/islpci_dev.h
--- linux-2.6.8.1/drivers/net/wireless/prism54/islpci_dev.h	2004-07-01 05:5=
4:35.000000000 +0000
+++ linux-2.6.8.1-prism54/drivers/net/wireless/prism54/islpci_dev.h	2004-08=
-16 18:19:50.000000000 +0000
@@ -100,6 +100,10 @@ typedef struct {
=20
 	struct iw_spy_data spy_data; /* iwspy support */
=20
+#if WIRELESS_EXT > 16
+	struct iw_public_data wireless_data;
+#endif /* WIRELESS_EXT > 16 */
+
 	int monitor_type; /* ARPHRD_IEEE80211 or ARPHRD_IEEE80211_PRISM */
=20
 	struct islpci_acl acl;

--+ZmrHH5cGjskQnY1--

--YPJ8CVbwFUtL7OFW
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBJTGqat1JN+IKUl4RAiMsAJ9uB4pq5Nog4TW+DW1aeYJjE3z+XACgmxwl
biQNZ1BjuDgKROziki9vcfo=
=Jc7+
-----END PGP SIGNATURE-----

--YPJ8CVbwFUtL7OFW--

--===============0392733072==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0392733072==--
