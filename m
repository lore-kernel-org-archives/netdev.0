From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 3/5] sis900 printk and stack usage audit
Date: Wed, 8 Dec 2004 12:06:10 +0100
Message-ID: <20041208110610.GD31707@picchio.gall.it>
References: <20041208104721.GA31707@picchio.gall.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="hUH5gZbnpyIv7Mn4"
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041208104721.GA31707@picchio.gall.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--hUH5gZbnpyIv7Mn4
Content-Type: multipart/mixed; boundary="9crTWz/Z+Zyzu20v"
Content-Disposition: inline


--9crTWz/Z+Zyzu20v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Chip revision is now a member of sis_priv structure
Kill all calls to pci_read_config_byte but one
Change the code to use sis_priv->chipset_rev

Signed-off-by: Daniele Venzano <webvenza@libero.it>

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--9crTWz/Z+Zyzu20v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900-chipset-revision.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 41)
+++ b/drivers/net/sis900.c	(revision 42)
@@ -173,6 +173,7 @@
 
 	unsigned int tx_full; /* The Tx queue is full. */
 	u8 host_bridge_rev;
+	u8 chipset_rev;
 	u32 pci_state[16];
 };
 
@@ -387,7 +388,6 @@
 	void *ring_space;
 	long ioaddr;
 	int i, ret;
-	u8 revision;
 	char *card_name = card_names[pci_id->driver_data];
 
 	/* setup various bits in PCI command register */
@@ -455,20 +455,20 @@
 	if (ret)
 		goto err_unmap_rx;
 		
-	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &revision);
+	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &(sis_priv->chipset_rev));
 
 	if(sis900_debug > 0)
 		printk(KERN_DEBUG "%s: detected revision %2.2x,"
 				"trying to get MAC address...\n",
-				net_dev->name, revision);
+				net_dev->name, sis_priv->chipset_rev);
 
 	/* Get Mac address according to the chip revision */
 	ret = 0;
-	if (revision == SIS630E_900_REV)
+	if (sis_priv->chipset_rev == SIS630E_900_REV)
 		ret = sis630e_get_mac_addr(pci_dev, net_dev);
-	else if ((revision > 0x81) && (revision <= 0x90) )
+	else if ((sis_priv->chipset_rev > 0x81) && (sis_priv->chipset_rev <= 0x90))
 		ret = sis635_get_mac_addr(pci_dev, net_dev);
-	else if (revision == SIS96x_900_REV)
+	else if (sis_priv->chipset_rev == SIS96x_900_REV)
 		ret = sis96x_get_mac_addr(pci_dev, net_dev);
 	else
 		ret = sis900_get_mac_addr(pci_dev, net_dev);
@@ -480,7 +480,7 @@
 	}
 	
 	/* 630ET : set the mii access mode as software-mode */
-	if (revision == SIS630ET_900_REV)
+	if (sis_priv->chipset_rev == SIS630ET_900_REV)
 		outl(ACCESSMODE | inl(ioaddr + cr), ioaddr + cr);
 
 	/* probe for mii transceiver */
@@ -535,7 +535,6 @@
 	u16 poll_bit = MII_STAT_LINK, status = 0;
 	unsigned long timeout = jiffies + 5 * HZ;
 	int phy_addr;
-	u8 revision;
 
 	sis_priv->mii = NULL;
 
@@ -632,8 +631,7 @@
 		}
 	}
 
-	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
-	if (revision == SIS630E_900_REV) {
+	if (sis_priv->chipset_rev == SIS630E_900_REV) {
 		/* SiS 630E has some bugs on default value of PHY registers */
 		mdio_write(net_dev, sis_priv->cur_phy, MII_ANADV, 0x05e1);
 		mdio_write(net_dev, sis_priv->cur_phy, MII_CONFIG1, 0x22);
@@ -948,15 +946,13 @@
 {
 	struct sis900_private *sis_priv = net_dev->priv;
 	long ioaddr = net_dev->base_addr;
-	u8 revision;
 	int ret;
 
 	/* Soft reset the chip. */
 	sis900_reset(net_dev);
 
 	/* Equalizer workaround Rule */
-	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
-	sis630_set_eq(net_dev, revision);
+	sis630_set_eq(net_dev, sis_priv->chipset_rev);
 
 	ret = request_irq(net_dev->irq, &sis900_interrupt, SA_SHIRQ,
 						net_dev->name, net_dev);
@@ -1224,7 +1220,6 @@
 	struct mii_phy *mii_phy = sis_priv->mii;
 	static int next_tick = 5*HZ;
 	u16 status;
-	u8 revision;
 
 	if (!sis_priv->autong_complete){
 		int speed, duplex = 0;
@@ -1232,9 +1227,7 @@
 		sis900_read_mode(net_dev, &speed, &duplex);
 		if (duplex){
 			sis900_set_mode(net_dev->base_addr, speed, duplex);
-			pci_read_config_byte(sis_priv->pci_dev,
-						PCI_CLASS_REVISION, &revision);
-			sis630_set_eq(net_dev, revision);
+			sis630_set_eq(net_dev, sis_priv->chipset_rev);
 			netif_start_queue(net_dev);
 		}
 
@@ -1268,9 +1261,7 @@
 			    ((mii_phy->phy_id1 & 0xFFF0) == 0x8000))
                			sis900_reset_phy(net_dev,  sis_priv->cur_phy);
   
-                	pci_read_config_byte(sis_priv->pci_dev,
-					PCI_CLASS_REVISION, &revision);
-			sis630_set_eq(net_dev, revision);
+			sis630_set_eq(net_dev, sis_priv->chipset_rev);
   
                 	goto LookForLink;
                 }
@@ -2102,11 +2093,10 @@
 	u16 mc_filter[16] = {0};	/* 256/128 bits multicast hash table */
 	int i, table_entries;
 	u32 rx_mode;
-	u8 revision;
 
 	/* 635 Hash Table entires = 256(2^16) */
-	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
-	if((revision >= SIS635A_900_REV) || (revision == SIS900B_900_REV))
+	if((sis_priv->chipset_rev >= SIS635A_900_REV) ||
+			(sis_priv->chipset_rev == SIS900B_900_REV))
 		table_entries = 16;
 	else
 		table_entries = 8;
@@ -2132,7 +2122,7 @@
 			mclist && i < net_dev->mc_count;
 			i++, mclist = mclist->next) {
 			unsigned int bit_nr =
-				sis900_mcast_bitnr(mclist->dmi_addr, revision);
+				sis900_mcast_bitnr(mclist->dmi_addr, sis_priv->chipset_rev);
 			mc_filter[bit_nr >> 4] |= (1 << (bit_nr & 0xf));
 		}
 	}
@@ -2178,7 +2168,6 @@
 	long ioaddr = net_dev->base_addr;
 	int i = 0;
 	u32 status = TxRCMP | RxRCMP;
-	u8  revision;
 
 	outl(0, ioaddr + ier);
 	outl(0, ioaddr + imr);
@@ -2191,8 +2180,8 @@
 		status ^= (inl(isr + ioaddr) & status);
 	}
 
-	pci_read_config_byte(sis_priv->pci_dev, PCI_CLASS_REVISION, &revision);
-	if( (revision >= SIS635A_900_REV) || (revision == SIS900B_900_REV) )
+	if( (sis_priv->chipset_rev >= SIS635A_900_REV) ||
+			(sis_priv->chipset_rev == SIS900B_900_REV) )
 		outl(PESEL | RND_CNT, ioaddr + cfg);
 	else
 		outl(PESEL, ioaddr + cfg);

--9crTWz/Z+Zyzu20v--

--hUH5gZbnpyIv7Mn4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBtuAi2rmHZCWzV+0RAsOuAJ91SdqW9b0XjtWJKTsYPMw6nLq18wCgneuq
18Au9MtLx2C5hSy0CKy0aqg=
=F0z5
-----END PGP SIGNATURE-----

--hUH5gZbnpyIv7Mn4--
