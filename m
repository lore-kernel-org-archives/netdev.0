From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH] 3/5: eepro: basic ethtool support
Date: Thu, 18 Nov 2004 21:40:53 -0200
Message-ID: <20041118234053.GH24080@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mejza3ZMMA5Za1mX"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--mejza3ZMMA5Za1mX
Content-Type: multipart/mixed; boundary="Iys0Un1O+0sigPHU"
Content-Disposition: inline


--Iys0Un1O+0sigPHU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


--=20
Aristeu


--Iys0Un1O+0sigPHU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="03-eepro-ethtool_basic.patch"
Content-Transfer-Encoding: quoted-printable

eepro: basic ethtool support

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6-inc/drivers/net/eepro.c	2004-09-14 13:47:07.000000000 -0300
+++ 2.6-work/drivers/net/eepro.c	2004-09-14 14:33:20.000000000 -0300
@@ -23,6 +23,7 @@
 	This is a compatibility hardware problem.
=20
 	Versions:
+	0.13b	basic ethtool support (aris, 09/13/2004)
 	0.13a   in memory shortage, drop packets also in board
 		(Michael Westermann <mw@microdata-pos.de>, 07/30/2002)
 	0.13    irq sharing, rewrote probe function, fixed a nasty bug in
@@ -104,7 +105,7 @@
 */
=20
 static const char version[] =3D
-	"eepro.c: v0.13 11/08/2001 aris@cathedrallabs.org\n";
+	"eepro.c: v0.13b 09/13/2004 aris@cathedrallabs.org\n";
=20
 #include <linux/module.h>
=20
@@ -145,6 +146,7 @@ static const char version[] =3D
 #include <linux/spinlock.h>
 #include <linux/init.h>
 #include <linux/delay.h>
+#include <linux/ethtool.h>
=20
 #include <asm/system.h>
 #include <asm/bitops.h>
@@ -152,13 +154,14 @@ static const char version[] =3D
 #include <asm/dma.h>
=20
 #define DRV_NAME "eepro"
+#define DRV_VERSION "0.13b"
=20
 #define compat_dev_kfree_skb( skb, mode ) dev_kfree_skb( (skb) )
 /* I had reports of looong delays with SLOW_DOWN defined as udelay(2) */
 #define SLOW_DOWN inb(0x80)
 /* udelay(2) */
 #define compat_init_data     __initdata
-
+enum iftype { AUI=3D0, BNC=3D1, TPE=3D2 };
=20
 /* First, a few definitions that the brave might change. */
 /* A zero-terminated list of I/O addresses to be probed. */
@@ -743,16 +746,17 @@ static void __init eepro_print_info (str
 		printEEPROMInfo(dev);
 }
=20
+static struct ethtool_ops eepro_ethtool_ops;
+
 /* This is the real probe routine.  Linux has a history of friendly device
    probes on the ISA bus.  A good device probe avoids doing writes, and
    verifies that the correct device exists and functions.  */
=20
 static int __init eepro_probe1(struct net_device *dev, int autoprobe)
 {
-	unsigned short station_addr[6], id, counter;
+	unsigned short station_addr[3], id, counter;
 	int i;
 	struct eepro_local *lp;
-	enum iftype { AUI=3D0, BNC=3D1, TPE=3D2 };
 	int ioaddr =3D dev->base_addr;
=20
 	/* Grab the region so we can find another board if autoIRQ fails. */
@@ -862,6 +866,7 @@ static int __init eepro_probe1(struct ne
  	dev->set_multicast_list =3D &set_multicast_list;
  	dev->tx_timeout		=3D eepro_tx_timeout;
  	dev->watchdog_timeo	=3D TX_TIMEOUT;
+	dev->ethtool_ops	=3D &eepro_ethtool_ops;
 =20
 	/* print boot time info */
 	eepro_print_info(dev);
@@ -1082,8 +1087,6 @@ static int eepro_open(struct net_device=20
 		old9 =3D inb(ioaddr + 9);
=20
 		if (irqMask=3D=3Dee_FX_INT2IRQ) {
-			enum iftype { AUI=3D0, BNC=3D1, TPE=3D2 };
-
 			if (net_debug > 3) {
 				printk(KERN_DEBUG "IrqMask: %#x\n",irqMask);
 				printk(KERN_DEBUG "i82595FX detected!\n");
@@ -1713,6 +1716,64 @@ eepro_transmit_interrupt(struct net_devi
 	}
 }
=20
+static int eepro_ethtool_get_settings(struct net_device *dev,
+					struct ethtool_cmd *cmd)
+{
+	struct eepro_local	*lp =3D (struct eepro_local *)dev->priv;
+
+	cmd->supported =3D 	SUPPORTED_10baseT_Half |=20
+				SUPPORTED_10baseT_Full |
+				SUPPORTED_Autoneg;
+	cmd->advertising =3D	ADVERTISED_10baseT_Half |
+				ADVERTISED_10baseT_Full |
+				ADVERTISED_Autoneg;
+
+	if (GetBit(lp->word[5], ee_PortTPE)) {
+		cmd->supported |=3D SUPPORTED_TP;
+		cmd->advertising |=3D ADVERTISED_TP;
+	}
+	if (GetBit(lp->word[5], ee_PortBNC)) {
+		cmd->supported |=3D SUPPORTED_BNC;
+		cmd->advertising |=3D ADVERTISED_BNC;
+	}
+	if (GetBit(lp->word[5], ee_PortAUI)) {
+		cmd->supported |=3D SUPPORTED_AUI;
+		cmd->advertising |=3D ADVERTISED_AUI;
+	}
+
+	cmd->speed =3D SPEED_10;
+
+	if (dev->if_port =3D=3D TPE && lp->word[1] & ee_Duplex) {
+		cmd->duplex =3D DUPLEX_FULL;
+	}
+	else {
+		cmd->duplex =3D DUPLEX_HALF;
+	}
+
+	cmd->port =3D dev->if_port;
+	cmd->phy_address =3D dev->base_addr;
+	cmd->transceiver =3D XCVR_INTERNAL;
+
+	if (lp->word[0] & ee_AutoNeg) {
+		cmd->autoneg =3D 1;
+	}
+
+	return 0;
+}
+
+static void eepro_ethtool_get_drvinfo(struct net_device *dev,
+					struct ethtool_drvinfo *drvinfo)
+{
+	strcpy(drvinfo->driver, DRV_NAME);
+	strcpy(drvinfo->version, DRV_VERSION);
+	sprintf(drvinfo->bus_info, "ISA 0x%lx", dev->base_addr);
+}
+
+static struct ethtool_ops eepro_ethtool_ops =3D {
+	.get_settings	=3D eepro_ethtool_get_settings,
+	.get_drvinfo 	=3D eepro_ethtool_get_drvinfo,
+};
+
 #ifdef MODULE
=20
 #define MAX_EEPRO 8
@@ -1728,7 +1789,7 @@ static int autodetect;
 static int n_eepro;
 /* For linux 2.1.xx */
=20
-MODULE_AUTHOR("Pascal Dupuis, and aris@cathedrallabs.org");
+MODULE_AUTHOR("Pascal Dupuis and others");
 MODULE_DESCRIPTION("Intel i82595 ISA EtherExpressPro10/10+ driver");
 MODULE_LICENSE("GPL");
=20

--Iys0Un1O+0sigPHU--

--mejza3ZMMA5Za1mX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBnTMFRRJOudsVYbMRAtI0AKCpQCJ7zTfnOGbrlKDFsCQwln4FGwCgx814
7rwaoFnqL2VLevjKUtweYOI=
=FbBi
-----END PGP SIGNATURE-----

--mejza3ZMMA5Za1mX--
