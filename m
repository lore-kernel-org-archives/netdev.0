From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] usbnet: Do not implement ethtool get_link() if link state
 is unknown
Date: Tue, 03 Nov 2009 03:26:58 +0000
Message-ID: <1257218818.3136.440.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-xXXpU8pl7hpYCZntMTXa"
Cc: Greg Kroah-Hartman <greg@kroah.com>,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	David Brownell <dbrownell@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34756 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757621AbZKCD1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 22:27:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xXXpU8pl7hpYCZntMTXa
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

usbnet implements the ethtool get_link() operation, using the first
available method out of (1) driver_info->check_connect()
(2) mii_link_ok() (3) netif_carrier_ok().  Some drivers do not support
any of these methods and usbnet will always report the link as up,
confusing tools such as Network Manager.

Since we cannot tell in advance whether a driver will implement method
(2) or (3), add a driver_info flag to indicate this.  Define the
get_link() operation in usbnet only if the driver sets this flag or
implements check_connect().

Compile-tested only.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/usb/asix.c      |   12 ++++++------
 drivers/net/usb/cdc_ether.c |    2 +-
 drivers/net/usb/dm9601.c    |    2 +-
 drivers/net/usb/mcs7830.c   |    4 ++--
 drivers/net/usb/smsc95xx.c  |    2 +-
 drivers/net/usb/usbnet.c    |   17 +++++++++++++++--
 include/linux/usb/usbnet.h  |    2 ++
 7 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 6ce7f77..34483c0 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1327,7 +1327,7 @@ static const struct driver_info ax8817x_info =3D {
 	.status =3D asix_status,
 	.link_reset =3D ax88172_link_reset,
 	.reset =3D ax88172_link_reset,
-	.flags =3D  FLAG_ETHER,
+	.flags =3D  FLAG_ETHER | FLAG_GET_LINK,
 	.data =3D 0x00130103,
 };
=20
@@ -1337,7 +1337,7 @@ static const struct driver_info dlink_dub_e100_info =
=3D {
 	.status =3D asix_status,
 	.link_reset =3D ax88172_link_reset,
 	.reset =3D ax88172_link_reset,
-	.flags =3D  FLAG_ETHER,
+	.flags =3D  FLAG_ETHER | FLAG_GET_LINK,
 	.data =3D 0x009f9d9f,
 };
=20
@@ -1347,7 +1347,7 @@ static const struct driver_info netgear_fa120_info =
=3D {
 	.status =3D asix_status,
 	.link_reset =3D ax88172_link_reset,
 	.reset =3D ax88172_link_reset,
-	.flags =3D  FLAG_ETHER,
+	.flags =3D  FLAG_ETHER | FLAG_GET_LINK,
 	.data =3D 0x00130103,
 };
=20
@@ -1357,7 +1357,7 @@ static const struct driver_info hawking_uf200_info =
=3D {
 	.status =3D asix_status,
 	.link_reset =3D ax88172_link_reset,
 	.reset =3D ax88172_link_reset,
-	.flags =3D  FLAG_ETHER,
+	.flags =3D  FLAG_ETHER | FLAG_GET_LINK,
 	.data =3D 0x001f1d1f,
 };
=20
@@ -1367,7 +1367,7 @@ static const struct driver_info ax88772_info =3D {
 	.status =3D asix_status,
 	.link_reset =3D ax88772_link_reset,
 	.reset =3D ax88772_link_reset,
-	.flags =3D FLAG_ETHER | FLAG_FRAMING_AX,
+	.flags =3D FLAG_ETHER | FLAG_FRAMING_AX | FLAG_GET_LINK,
 	.rx_fixup =3D asix_rx_fixup,
 	.tx_fixup =3D asix_tx_fixup,
 };
@@ -1378,7 +1378,7 @@ static const struct driver_info ax88178_info =3D {
 	.status =3D asix_status,
 	.link_reset =3D ax88178_link_reset,
 	.reset =3D ax88178_link_reset,
-	.flags =3D FLAG_ETHER | FLAG_FRAMING_AX,
+	.flags =3D FLAG_ETHER | FLAG_FRAMING_AX | FLAG_GET_LINK,
 	.rx_fixup =3D asix_rx_fixup,
 	.tx_fixup =3D asix_tx_fixup,
 };
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 71e65fc..b7ff514 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -413,7 +413,7 @@ static int cdc_bind(struct usbnet *dev, struct usb_inte=
rface *intf)
=20
 static const struct driver_info	cdc_info =3D {
 	.description =3D	"CDC Ethernet Device",
-	.flags =3D	FLAG_ETHER,
+	.flags =3D	FLAG_ETHER | FLAG_GET_LINK,
 	// .check_connect =3D cdc_check_connect,
 	.bind =3D		cdc_bind,
 	.unbind =3D	usbnet_cdc_unbind,
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index a2b30a1..495f2b4 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -611,7 +611,7 @@ static int dm9601_link_reset(struct usbnet *dev)
=20
 static const struct driver_info dm9601_info =3D {
 	.description	=3D "Davicom DM9601 USB Ethernet",
-	.flags		=3D FLAG_ETHER,
+	.flags		=3D FLAG_ETHER | FLAG_GET_LINK,
 	.bind		=3D dm9601_bind,
 	.rx_fixup	=3D dm9601_rx_fixup,
 	.tx_fixup	=3D dm9601_tx_fixup,
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index 10873d9..168f3be 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -549,7 +549,7 @@ static const struct driver_info moschip_info =3D {
 	.description	=3D "MOSCHIP 7830/7730 usb-NET adapter",
 	.bind		=3D mcs7830_bind,
 	.rx_fixup	=3D mcs7830_rx_fixup,
-	.flags		=3D FLAG_ETHER,
+	.flags		=3D FLAG_ETHER | FLAG_GET_LINK,
 	.in		=3D 1,
 	.out		=3D 2,
 };
@@ -558,7 +558,7 @@ static const struct driver_info sitecom_info =3D {
 	.description    =3D "Sitecom LN-30 usb-NET adapter",
 	.bind		=3D mcs7830_bind,
 	.rx_fixup	=3D mcs7830_rx_fixup,
-	.flags		=3D FLAG_ETHER,
+	.flags		=3D FLAG_ETHER | FLAG_GET_LINK,
 	.in		=3D 1,
 	.out		=3D 2,
 };
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index c6c9222..f1062c7 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -1227,7 +1227,7 @@ static const struct driver_info smsc95xx_info =3D {
 	.rx_fixup	=3D smsc95xx_rx_fixup,
 	.tx_fixup	=3D smsc95xx_tx_fixup,
 	.status		=3D smsc95xx_status,
-	.flags		=3D FLAG_ETHER | FLAG_SEND_ZLP,
+	.flags		=3D FLAG_ETHER | FLAG_SEND_ZLP | FLAG_GET_LINK,
 };
=20
 static const struct usb_device_id products[] =3D {
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 378da8c..85b5b5d 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -854,7 +854,7 @@ void usbnet_set_msglevel (struct net_device *net, u32 l=
evel)
 EXPORT_SYMBOL_GPL(usbnet_set_msglevel);
=20
 /* drivers may override default ethtool_ops in their bind() routine */
-static const struct ethtool_ops usbnet_ethtool_ops =3D {
+static const struct ethtool_ops usbnet_get_link_ethtool_ops =3D {
 	.get_settings		=3D usbnet_get_settings,
 	.set_settings		=3D usbnet_set_settings,
 	.get_link		=3D usbnet_get_link,
@@ -864,6 +864,15 @@ static const struct ethtool_ops usbnet_ethtool_ops =3D=
 {
 	.set_msglevel		=3D usbnet_set_msglevel,
 };
=20
+static const struct ethtool_ops usbnet_ethtool_ops =3D {
+	.get_settings		=3D usbnet_get_settings,
+	.set_settings		=3D usbnet_set_settings,
+	.nway_reset		=3D usbnet_nway_reset,
+	.get_drvinfo		=3D usbnet_get_drvinfo,
+	.get_msglevel		=3D usbnet_get_msglevel,
+	.set_msglevel		=3D usbnet_set_msglevel,
+};
+
 /*------------------------------------------------------------------------=
-*/
=20
 /* work that cannot be done in interrupt context uses keventd.
@@ -1285,7 +1294,11 @@ usbnet_probe (struct usb_interface *udev, const stru=
ct usb_device_id *prod)
=20
 	net->netdev_ops =3D &usbnet_netdev_ops;
 	net->watchdog_timeo =3D TX_TIMEOUT_JIFFIES;
-	net->ethtool_ops =3D &usbnet_ethtool_ops;
+	if (dev->driver_info->check_connect ||
+	    dev->driver_info->flags & FLAG_GET_LINK)
+		net->ethtool_ops =3D &usbnet_get_link_ethtool_ops;
+	else
+		net->ethtool_ops =3D &usbnet_ethtool_ops;
=20
 	// allow device-specific bind/init procedures
 	// NOTE net->name still not usable ...
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 86c31b7..a00424d 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -92,6 +92,8 @@ struct driver_info {
 #define FLAG_SEND_ZLP	0x0200		/* hw requires ZLPs are sent */
 #define FLAG_WWAN	0x0400		/* use "wwan%d" names */
=20
+#define FLAG_GET_LINK	0x0800		/* link state is available through
+					 * MII or netif_carrier_ok() */
=20
 	/* init device ... can sleep, or cause probe() failure */
 	int	(*bind)(struct usbnet *, struct usb_interface *);
--=20
1.6.5.2



--=-xXXpU8pl7hpYCZntMTXa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUASu+i/ee/yOyVhhEJAQLdMg/+OB4iUPUOb3iS3IM7a5jGeYvdwZzXf7Z2
RUl+yab315jqfU5++EDd8moYranku65nE7hndpqFPyddVQ4DYQ6GZJSmVie1a+ky
tWkDzfJNt3s9P8NUATtUGmuf5Ww3JZhWF+1gjmsEJ+m+htAQ4Jk2ltj8xPGVr8J6
lcAgpmz2I0qkqMZUIa6HJz2vbr+TU18rX8n+aRTLw2eCQbHJkE1QK+XjZtGOLECX
sQiOa04MdI2cRclEKmt2hgYfj6IlcyISDHcYF4OFq/XxEdUS3bd8QfugkBFJzkR3
8LE7GsyRO5e+2cGbwCodPoDEHPjKSuDc53dxaLOTCsCp/YjD7q+wrZauKJFje0dE
AZ+2xqBBClNA4FR5TbRWB33sXhlA0opEhRD+SRymBIzmMUykM7k+woq3Y/pfpXaU
ObRJR6rvBtF8D205c8eeziN6Dajqo/hr97uKU4UqpshmCxfd6VkFK2lfgRFyPwtd
SP+zfUC9t8JshXqHEeJ5FVkVBOWTTUdsBoJAjoH/5g+NpsC+Y84FhqF2fw62gtQY
Ig5Rpq0D9sCB6y92GGCwrYM2WZ8rk+mTRRxmclGaP0PSapYo/75KJghDPuYl/TcA
Ukk7BWOWE5UCx1ibKEc5v2eVFwfy9DoTXMTXKvpz93L5u85X6nVgooYk1EUIBF9D
S/bJfPwhEPE=
=j/Yz
-----END PGP SIGNATURE-----

--=-xXXpU8pl7hpYCZntMTXa--
