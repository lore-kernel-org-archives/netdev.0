From: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>
Subject: [PATCH] 1/5: eepro: cache EEPROM values
Date: Thu, 18 Nov 2004 21:40:43 -0200
Message-ID: <20041118234043.GF24080@cathedrallabs.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5VuzLDXibKSJvVYD"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--5VuzLDXibKSJvVYD
Content-Type: multipart/mixed; boundary="M0YLxmUXciMpOLPE"
Content-Disposition: inline


--M0YLxmUXciMpOLPE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


--=20
Aristeu


--M0YLxmUXciMpOLPE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="01-eepro-cache_eeprom_values.patch"
Content-Transfer-Encoding: quoted-printable

eepro: cache EEPROM values

Signed-off-by: Aristeu Sergio Rozanski Filho <aris@cathedrallabs.org>

--- 2.6-inc/drivers/net/eepro.c	2004-09-13 15:54:43.000000000 -0300
+++ 2.6-foo/drivers/net/eepro.c	2004-09-14 13:46:15.000000000 -0300
@@ -214,6 +214,7 @@ struct eepro_local {
 	short rcv_lower_limit;
 	short rcv_upper_limit;
 	unsigned char eeprom_reg;
+	unsigned short word[8];
 };
=20
 /* The station (ethernet) address prefix, used for IDing the board. */
@@ -608,16 +609,22 @@ out:
 }
 #endif
=20
-static void __init printEEPROMInfo(short ioaddr, struct net_device *dev)
+static void __init printEEPROMInfo(struct net_device *dev)
 {
+	struct eepro_local *lp =3D (struct eepro_local *)dev->priv;
+	int ioaddr =3D dev->base_addr;
 	unsigned short Word;
 	int i,j;
=20
-	for (i=3D0, j=3Dee_Checksum; i<ee_SIZE; i++)
-		j+=3Dread_eeprom(ioaddr,i,dev);
+	j =3D ee_Checksum;
+	for (i =3D 0; i < 8; i++)
+		j +=3D lp->word[i];
+	for ( ; i < ee_SIZE; i++)
+		j +=3D read_eeprom(ioaddr, i, dev);
+
 	printk(KERN_DEBUG "Checksum: %#x\n",j&0xffff);
=20
-	Word=3Dread_eeprom(ioaddr, 0, dev);
+	Word =3D lp->word[0];
 	printk(KERN_DEBUG "Word0:\n");
 	printk(KERN_DEBUG " Plug 'n Pray: %d\n",GetBit(Word,ee_PnP));
 	printk(KERN_DEBUG " Buswidth: %d\n",(GetBit(Word,ee_BusWidth)+1)*8 );
@@ -625,7 +632,7 @@ static void __init printEEPROMInfo(short
 	printk(KERN_DEBUG " IO Address: %#x\n", (Word>>ee_IO0)<<4);
=20
 	if (net_debug>4)  {
-		Word=3Dread_eeprom(ioaddr, 1, dev);
+		Word =3D lp->word[1];
 		printk(KERN_DEBUG "Word1:\n");
 		printk(KERN_DEBUG " INT: %d\n", Word & ee_IntMask);
 		printk(KERN_DEBUG " LI: %d\n", GetBit(Word,ee_LI));
@@ -636,7 +643,7 @@ static void __init printEEPROMInfo(short
 		printk(KERN_DEBUG " Duplex: %d\n", GetBit(Word,ee_Duplex));
 	}
=20
-	Word=3Dread_eeprom(ioaddr, 5, dev);
+	Word =3D lp->word[5];
 	printk(KERN_DEBUG "Word5:\n");
 	printk(KERN_DEBUG " BNC: %d\n",GetBit(Word,ee_BNC_TPE));
 	printk(KERN_DEBUG " NumConnectors: %d\n",GetBit(Word,ee_NumConn));
@@ -646,12 +653,12 @@ static void __init printEEPROMInfo(short
 	if (GetBit(Word,ee_PortAUI)) printk(KERN_DEBUG "AUI ");
 	printk(KERN_DEBUG "port(s) \n");
=20
-	Word=3Dread_eeprom(ioaddr, 6, dev);
+	Word =3D lp->word[6];
 	printk(KERN_DEBUG "Word6:\n");
 	printk(KERN_DEBUG " Stepping: %d\n",Word & ee_StepMask);
 	printk(KERN_DEBUG " BoardID: %d\n",Word>>ee_BoardID);
=20
-	Word=3Dread_eeprom(ioaddr, 7, dev);
+	Word =3D lp->word[7];
 	printk(KERN_DEBUG "Word7:\n");
 	printk(KERN_DEBUG " INT to IRQ:\n");
=20
@@ -725,7 +732,7 @@ static void __init eepro_print_info (str
 		printk(", %s.\n", ifmap[dev->if_port]);
=20
 	if (net_debug > 3) {
-		i =3D read_eeprom(dev->base_addr, 5, dev);
+		i =3D lp->word[5];
 		if (i & 0x2000) /* bit 13 of EEPROM word 5 */
 			printk(KERN_DEBUG "%s: Concurrent Processing is "
 				"enabled but not used!\n", dev->name);
@@ -733,7 +740,7 @@ static void __init eepro_print_info (str
=20
 	/* Check the station address for the manufacturer's code */
 	if (net_debug>3)
-		printEEPROMInfo(dev->base_addr, dev);
+		printEEPROMInfo(dev);
 }
=20
 /* This is the real probe routine.  Linux has a history of friendly device
@@ -796,11 +803,16 @@ static int __init eepro_probe1(struct ne
 		lp->xmt_bar =3D XMT_BAR_10;
 		station_addr[0] =3D read_eeprom(ioaddr, 2, dev);
 	}
-	station_addr[1] =3D read_eeprom(ioaddr, 3, dev);
-	station_addr[2] =3D read_eeprom(ioaddr, 4, dev);
+
+	/* get all words at once. will be used here and for ethtool */
+	for (i =3D 0; i < 8; i++) {
+		lp->word[i] =3D read_eeprom(ioaddr, i, dev);
+	}
+	station_addr[1] =3D lp->word[3];
+	station_addr[2] =3D lp->word[4];
=20
 	if (!lp->eepro) {
-		if (read_eeprom(ioaddr,7,dev)=3D=3D ee_FX_INT2IRQ)
+		if (lp->word[7] =3D=3D ee_FX_INT2IRQ)
 			lp->eepro =3D 2;
 		else if (station_addr[2] =3D=3D SA_ADDR1)
 			lp->eepro =3D 1;
@@ -817,15 +829,15 @@ static int __init eepro_probe1(struct ne
 	/* calculate {xmt,rcv}_{lower,upper}_limit */
 	eepro_recalc(dev);
=20
-	if (GetBit( read_eeprom(ioaddr, 5, dev),ee_BNC_TPE))
+	if (GetBit(lp->word[5], ee_BNC_TPE))
 		dev->if_port =3D BNC;
 	else
 		dev->if_port =3D TPE;
=20
  	if (dev->irq < 2 && lp->eepro !=3D 0) {
  		/* Mask off INT number */
- 		int count =3D read_eeprom(ioaddr, 1, dev) & 7;
- 		unsigned irqMask =3D read_eeprom(ioaddr, 7, dev);
+ 		int count =3D lp->word[1] & 7;
+ 		unsigned irqMask =3D lp->word[7];
 =20
  		while (count--)
  			irqMask &=3D irqMask - 1;
@@ -941,7 +953,7 @@ static int eepro_open(struct net_device=20
 	if (net_debug > 3)
 		printk(KERN_DEBUG "%s: entering eepro_open routine.\n", dev->name);
=20
-	irqMask =3D read_eeprom(ioaddr,7,dev);
+	irqMask =3D lp->word[7];
=20
 	if (lp->eepro =3D=3D LAN595FX_10ISA) {
 		if (net_debug > 3) printk(KERN_DEBUG "p->eepro =3D 3;\n");

--M0YLxmUXciMpOLPE--

--5VuzLDXibKSJvVYD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBnTL7RRJOudsVYbMRAgumAKC90412zmACQmAz8snwXbVAbGfrvwCfUKRr
gXg4AR8hsJj870jxJuK6FiQ=
=c30U
-----END PGP SIGNATURE-----

--5VuzLDXibKSJvVYD--
