From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 4/5] sis900 printk and stack usage audit
Date: Wed, 8 Dec 2004 12:08:35 +0100
Message-ID: <20041208110835.GE31707@picchio.gall.it>
References: <20041208104721.GA31707@picchio.gall.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jaoouwwPWoQSJZYp"
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041208104721.GA31707@picchio.gall.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--jaoouwwPWoQSJZYp
Content-Type: multipart/mixed; boundary="B8ONY/mu/bqBak9m"
Content-Disposition: inline


--B8ONY/mu/bqBak9m
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Don't do useless calls of sis630_set_eq
Kill now unneeded paramenter of sis630_set_eq

Signed-off-by: Daniele Venzano <webvenza@libero.it>

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--B8ONY/mu/bqBak9m
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900-sis630-set-eq.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 42)
+++ b/drivers/net/sis900.c	(revision 43)
@@ -209,7 +209,7 @@
 static u16 sis900_mcast_bitnr(u8 *addr, u8 revision);
 static void set_rx_mode(struct net_device *net_dev);
 static void sis900_reset(struct net_device *net_dev);
-static void sis630_set_eq(struct net_device *net_dev, u8 revision);
+static void sis630_set_eq(struct net_device *net_dev);
 static int sis900_set_config(struct net_device *dev, struct ifmap *map);
 static u16 sis900_default_phy(struct net_device * net_dev);
 static void sis900_set_capability( struct net_device *net_dev ,struct mii_phy *phy);
@@ -952,7 +952,11 @@
 	sis900_reset(net_dev);
 
 	/* Equalizer workaround Rule */
-	sis630_set_eq(net_dev, sis_priv->chipset_rev);
+	if (sis_priv->chipset_rev == SIS630E_900_REV ||
+			sis_priv->chipset_rev == SIS630EA1_900_REV ||
+			sis_priv->chipset_rev == SIS630A_900_REV ||
+			sis_priv->chipset_rev ==  SIS630ET_900_REV)
+		sis630_set_eq(net_dev);
 
 	ret = request_irq(net_dev->irq, &sis900_interrupt, SA_SHIRQ,
 						net_dev->name, net_dev);
@@ -1141,16 +1145,12 @@
  *	max >= 15      --> set equalizer to max+5 or set equalizer to max+6 if max == min
  */
 
-static void sis630_set_eq(struct net_device *net_dev, u8 revision)
+static void sis630_set_eq(struct net_device *net_dev)
 {
 	struct sis900_private *sis_priv = net_dev->priv;
 	u16 reg14h, eq_value=0, max_value=0, min_value=0;
 	int i, maxcount=10;
 
-	if ( !(revision == SIS630E_900_REV || revision == SIS630EA1_900_REV ||
-	       revision == SIS630A_900_REV || revision ==  SIS630ET_900_REV) )
-		return;
-
 	if (netif_carrier_ok(net_dev)) {
 		reg14h = mdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
 		mdio_write(net_dev, sis_priv->cur_phy, MII_RESV,
@@ -1166,8 +1166,9 @@
 						eq_value : min_value;
 		}
 		/* 630E rule to determine the equalizer value */
-		if (revision == SIS630E_900_REV || revision == SIS630EA1_900_REV ||
-		    revision == SIS630ET_900_REV) {
+		if (sis_priv->chipset_rev == SIS630E_900_REV ||
+				sis_priv->chipset_rev == SIS630EA1_900_REV ||
+				sis_priv->chipset_rev == SIS630ET_900_REV) {
 			if (max_value < 5)
 				eq_value = max_value;
 			else if (max_value >= 5 && max_value < 15)
@@ -1178,7 +1179,7 @@
 						max_value+6 : max_value+5;
 		}
 		/* 630B0&B1 rule to determine the equalizer value */
-		if (revision == SIS630A_900_REV && 
+		if (sis_priv->chipset_rev == SIS630A_900_REV && 
 		    (sis_priv->host_bridge_rev == SIS630B0 || 
 		     sis_priv->host_bridge_rev == SIS630B1)) {
 			if (max_value == 0)
@@ -1193,7 +1194,7 @@
 		mdio_write(net_dev, sis_priv->cur_phy, MII_RESV, reg14h);
 	} else {
 		reg14h = mdio_read(net_dev, sis_priv->cur_phy, MII_RESV);
-		if (revision == SIS630A_900_REV && 
+		if (sis_priv->chipset_rev == SIS630A_900_REV && 
 		    (sis_priv->host_bridge_rev == SIS630B0 || 
 		     sis_priv->host_bridge_rev == SIS630B1)) 
 			mdio_write(net_dev, sis_priv->cur_phy, MII_RESV,
@@ -1227,7 +1228,11 @@
 		sis900_read_mode(net_dev, &speed, &duplex);
 		if (duplex){
 			sis900_set_mode(net_dev->base_addr, speed, duplex);
-			sis630_set_eq(net_dev, sis_priv->chipset_rev);
+			if (sis_priv->chipset_rev == SIS630E_900_REV ||
+					sis_priv->chipset_rev == SIS630EA1_900_REV ||
+					sis_priv->chipset_rev == SIS630A_900_REV ||
+					sis_priv->chipset_rev ==  SIS630ET_900_REV)
+				sis630_set_eq(net_dev);
 			netif_start_queue(net_dev);
 		}
 
@@ -1260,9 +1265,13 @@
                 	if ((mii_phy->phy_id0 == 0x001D) && 
 			    ((mii_phy->phy_id1 & 0xFFF0) == 0x8000))
                			sis900_reset_phy(net_dev,  sis_priv->cur_phy);
+
+			if (sis_priv->chipset_rev == SIS630E_900_REV ||
+					sis_priv->chipset_rev == SIS630EA1_900_REV ||
+					sis_priv->chipset_rev == SIS630A_900_REV ||
+					sis_priv->chipset_rev ==  SIS630ET_900_REV)
+				sis630_set_eq(net_dev);
   
-			sis630_set_eq(net_dev, sis_priv->chipset_rev);
-  
                 	goto LookForLink;
                 }
 	}

--B8ONY/mu/bqBak9m--

--jaoouwwPWoQSJZYp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBtuCz2rmHZCWzV+0RAnSJAJ9XXuoldG7DCKmKGrTD9nDQjt/rBgCfebjo
3d5CGqu9Q38MsjW/XKFiMvE=
=Dp2S
-----END PGP SIGNATURE-----

--jaoouwwPWoQSJZYp--
