From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 2/5] sis900 printk and stack usage audit
Date: Wed, 8 Dec 2004 12:04:26 +0100
Message-ID: <20041208110426.GC31707@picchio.gall.it>
References: <20041208104721.GA31707@picchio.gall.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uxuisgdDHaNETlh8"
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041208104721.GA31707@picchio.gall.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--uxuisgdDHaNETlh8
Content-Type: multipart/mixed; boundary="vOmOzSkFvhd7u8Ms"
Content-Disposition: inline


--vOmOzSkFvhd7u8Ms
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Added some initialization debug output
Version bump

Signed-off-by: Daniele Venzano <webvenza@libero.it>

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--vOmOzSkFvhd7u8Ms
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900-debug2.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 40)
+++ b/drivers/net/sis900.c	(revision 41)
@@ -1,6 +1,6 @@
 /* sis900.c: A SiS 900/7016 PCI Fast Ethernet driver for Linux.
    Copyright 1999 Silicon Integrated System Corporation 
-   Revision:	1.08.06 Sep. 24 2002
+   Revision:	1.08.08 Nov. 28 2004
    
    Modified from the driver which is originally written by Donald Becker.
    
@@ -18,6 +18,7 @@
    preliminary Rev. 1.0 Jan. 18, 1998
    http://www.sis.com.tw/support/databook.htm
 
+   Rev 1.08.08 Nov. 28 2004 Daniele Venzano audit debug code and printk() calls
    Rev 1.08.07 Nov.  2 2003 Daniele Venzano <webvenza@libero.it> add suspend/resume support
    Rev 1.08.06 Sep. 24 2002 Mufasa Yang bug fix for Tx timeout & add SiS963 support
    Rev 1.08.05 Jun.  6 2002 Mufasa Yang bug fix for read_eeprom & Tx descriptor over-boundary
@@ -74,7 +75,7 @@
 #include "sis900.h"
 
 #define SIS900_MODULE_NAME "sis900"
-#define SIS900_DRV_VERSION "v1.08.07 11/02/2003"
+#define SIS900_DRV_VERSION "v1.08.08 Nov. 28 2004"
 
 static char version[] __devinitdata =
 KERN_INFO "sis900.c: " SIS900_DRV_VERSION "\n";
@@ -107,8 +108,6 @@
 };
 MODULE_DEVICE_TABLE (pci, sis900_pci_tbl);
 
-static void sis900_read_mode(struct net_device *net_dev, int *speed, int *duplex);
-
 static struct mii_chip_info {
 	const char * name;
 	u16 phy_id0;
@@ -216,6 +215,7 @@
 static u16 sis900_reset_phy(struct net_device *net_dev, int phy_addr);
 static void sis900_auto_negotiate(struct net_device *net_dev, int phy_addr);
 static void sis900_set_mode (long ioaddr, int speed, int duplex);
+static void sis900_read_mode(struct net_device *net_dev, int *speed, int *duplex);
 static struct ethtool_ops sis900_ethtool_ops;
 
 /**
@@ -269,7 +269,7 @@
 	if (!isa_bridge) {
 		isa_bridge = pci_find_device(PCI_VENDOR_ID_SI, 0x0018, isa_bridge);
 		if (!isa_bridge) {
-			printk(KERN_WARNING "%s: Can not find ISA bridge\n", net_dev->name);
+			printk(KERN_WARNING "%s: Cannot find ISA bridge\n", net_dev->name);
 			return 0;
 		}
 	}
@@ -455,10 +455,15 @@
 	if (ret)
 		goto err_unmap_rx;
 		
+	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &revision);
+
+	if(sis900_debug > 0)
+		printk(KERN_DEBUG "%s: detected revision %2.2x,"
+				"trying to get MAC address...\n",
+				net_dev->name, revision);
+
 	/* Get Mac address according to the chip revision */
-	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &revision);
 	ret = 0;
-
 	if (revision == SIS630E_900_REV)
 		ret = sis630e_get_mac_addr(pci_dev, net_dev);
 	else if ((revision > 0x81) && (revision <= 0x90) )
@@ -469,6 +474,7 @@
 		ret = sis900_get_mac_addr(pci_dev, net_dev);
 
 	if (ret == 0) {
+		printk(KERN_WARNING "%s: Cannot read MAC address.\n", net_dev->name);
 		ret = -ENODEV;
 		goto err_out_unregister;
 	}
@@ -479,6 +485,7 @@
 
 	/* probe for mii transceiver */
 	if (sis900_mii_probe(net_dev) == 0) {
+		printk(KERN_WARNING "%s: Error probing MII device.\n", net_dev->name);
 		ret = -ENODEV;
 		goto err_out_unregister;
 	}
@@ -542,9 +549,14 @@
 		for(i = 0; i < 2; i++)
 			mii_status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
-		if (mii_status == 0xffff || mii_status == 0x0000)
+		if (mii_status == 0xffff || mii_status == 0x0000) {
 			/* the mii is not accessible, try next one */
+			if (sis900_debug > 0)
+				printk(KERN_DEBUG "%s: MII at address %d"
+						" not accessible\n",
+						net_dev->name, phy_addr);
 			continue;
+		}
 		
 		if ((mii_phy = kmalloc(sizeof(struct mii_phy), GFP_KERNEL)) == NULL) {
 			printk(KERN_WARNING "Cannot allocate mem for struct mii_phy\n");
@@ -568,14 +580,15 @@
 
 		for (i = 0; mii_chip_table[i].phy_id1; i++)
 			if ((mii_phy->phy_id0 == mii_chip_table[i].phy_id0 ) &&
-			    ((mii_phy->phy_id1 & 0xFFF0) == mii_chip_table[i].phy_id1)){
+			    ((mii_phy->phy_id1 & 0xFFF0) == mii_chip_table[i].phy_id1))
+			{
 				mii_phy->phy_types = mii_chip_table[i].phy_types;
 				if (mii_chip_table[i].phy_types == MIX)
-					mii_phy->phy_types =
-					    (mii_status & (MII_STAT_CAN_TX_FDX | MII_STAT_CAN_TX)) ? LAN : HOME;
+					mii_phy->phy_types = (mii_status & (MII_STAT_CAN_TX_FDX | MII_STAT_CAN_TX)) ? LAN : HOME;
 				printk(KERN_INFO "%s: %s transceiver found at address %d.\n",
-				       net_dev->name, mii_chip_table[i].name,
-				       phy_addr);
+							net_dev->name,
+							mii_chip_table[i].name,
+							phy_addr);
 				break;
 			}
 			

--vOmOzSkFvhd7u8Ms--

--uxuisgdDHaNETlh8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBtt+62rmHZCWzV+0RAmfHAJwPWQeSrRvdBpuPFZS1ldYrON4b4wCglYiG
o7Gxt7+sQQUgYjVLkDhV2JU=
=Ikf7
-----END PGP SIGNATURE-----

--uxuisgdDHaNETlh8--
