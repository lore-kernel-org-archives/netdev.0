From: "Steven J. Hill" <sjhill@realitydiluted.com>
Subject: [PATCH] Merge GT/MV642xx Support into MV643xx Driver [7/8]
Date: Wed, 18 Jul 2007 23:56:51 -0500
Message-ID: <469EEF13.2000607@realitydiluted.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE4ADAE9500569E9191B90C05"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from real.realitydiluted.com ([66.43.201.61]:34038 "EHLO
	real.realitydiluted.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbXGSE4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 00:56:54 -0400
Received: from atlas.inter.net ([10.0.0.3])
	by real.realitydiluted.com with esmtp (Exim 4.67)
	(envelope-from <sjhill@realitydiluted.com>)
	id 1IBO6T-00067A-Kl
	for netdev@vger.kernel.org; Wed, 18 Jul 2007 23:59:07 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE4ADAE9500569E9191B90C05
Content-Type: multipart/mixed;
 boundary="------------040607000701050508020100"

This is a multi-part message in MIME format.
--------------040607000701050508020100
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Get rid of global PHY spinlock.

Signed-off-by: Steven J. Hill <sjhill1@rockwellcollins.com>
---

--------------040607000701050508020100
Content-Type: text/x-patch;
 name="07-mv643xx-remove-phy-spinlock.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
 filename="07-mv643xx-remove-phy-spinlock.patch"

diff -ur linux-2.6.22.1/drivers/net/mv643xx_eth.c linux-2.6.22.1-rci/driv=
ers/net/mv643xx_eth.c
--- linux-2.6.22.1/drivers/net/mv643xx_eth.c	2007-07-18 22:51:54.00000000=
0 -0500
+++ linux-2.6.22.1-rci/drivers/net/mv643xx_eth.c	2007-07-18 22:39:37.0000=
00000 -0500
@@ -74,7 +74,7 @@
 #endif
 static int ethernet_phy_get(unsigned int eth_port_num);
 static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
-static int ethernet_phy_detect(unsigned int eth_port_num);
+static int ethernet_phy_detect(struct mv643xx_private *mp);
 static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int loc=
ation);
 static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int l=
ocation, int val);
 static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *if=
r, int cmd);
@@ -85,8 +85,6 @@
=20
 static void __iomem *mv643xx_eth_shared_base;
=20
-/* used to protect MV643XX_ETH_SMI_REG, which is shared across ports */
-static DEFINE_SPINLOCK(mv643xx_eth_phy_lock);
 #ifdef CONFIG_GT64260
 extern struct mv64x60_handle bh;
 static u32 eth_hash_table_size[3] =3D { 1, 1, 1 };
@@ -936,11 +927,12 @@
 static int mv643xx_set_settings(struct net_device *dev, struct ethtool_c=
md *cmd)
 {
 	struct mv643xx_private *mp =3D netdev_priv(dev);
+	unsigned long flags;
 	int err;
=20
-	spin_lock_irq(&mp->lock);
+	spin_lock_irqsave(&mp->lock, flags);
 	err =3D mii_ethtool_sset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
+	spin_unlock_irqrestore(&mp->lock, flags);
=20
 	return err;
 }
@@ -948,11 +940,12 @@
 static int mv643xx_get_settings(struct net_device *dev, struct ethtool_c=
md *cmd)
 {
 	struct mv643xx_private *mp =3D netdev_priv(dev);
+	unsigned long flags;
 	int err;
=20
-	spin_lock_irq(&mp->lock);
+	spin_lock_irqsave(&mp->lock, flags);
 	err =3D mii_ethtool_gset(&mp->mii, cmd);
-	spin_unlock_irq(&mp->lock);
+	spin_unlock_irqrestore(&mp->lock, flags);
=20
 	/* The PHY may support 1000baseT_Half, but the mv643xx does not */
 	cmd->supported &=3D ~SUPPORTED_1000baseT_Half;
@@ -1594,12 +1599,12 @@
 static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
-	int port_num;
+	unsigned int port_num;
 	struct mv643xx_private *mp;
 	struct net_device *dev;
 	u8 *p;
 	struct resource *res;
-	int err;
+	int err =3D 0;
 	struct ethtool_cmd cmd;
 	int duplex =3D DUPLEX_HALF;
 	int speed =3D 0;			/* default to auto-negotiation */
@@ -1702,7 +1707,7 @@
 	mp->mii.phy_id_mask =3D 0x3f;
 	mp->mii.reg_num_mask =3D 0x1f;
=20
-	err =3D ethernet_phy_detect(port_num);
+	err =3D ethernet_phy_detect(mp);
 	if (err) {
 		pr_debug("MV643xx ethernet port %d: "
 					"No PHY detected at addr %d\n",
@@ -1710,7 +1715,7 @@
 		goto out;
 	}
=20
-	ethernet_phy_reset(port_num);
+	ethernet_phy_reset(mp);
 	mp->mii.supports_gmii =3D mii_check_gmii_support(&mp->mii);
 	mv643xx_init_ethtool_cmd(dev, mp->mii.phy_id, speed, duplex, &cmd);
 	mv643xx_eth_update_pscr(dev, &cmd);
@@ -2158,7 +2163,7 @@
=20
 	/* save phy settings across reset */
 	mv643xx_get_settings(dev, &ethtool_cmd);
-	ethernet_phy_reset(mp->port_num);
+	ethernet_phy_reset(mp);
 	mv643xx_set_settings(dev, &ethtool_cmd);
 }
=20
@@ -2761,22 +2766,22 @@
  *	-ENODEV on failure
  *
  */
-static int ethernet_phy_detect(unsigned int port_num)
+static int ethernet_phy_detect(struct mv643xx_private *mp)
 {
 	unsigned int phy_reg_data0;
 	int auto_neg;
=20
-	eth_port_read_smi_reg(port_num, 0, &phy_reg_data0);
+	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
 	auto_neg =3D phy_reg_data0 & 0x1000;
 	phy_reg_data0 ^=3D 0x1000;	/* invert auto_neg */
-	eth_port_write_smi_reg(port_num, 0, phy_reg_data0);
+	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
=20
-	eth_port_read_smi_reg(port_num, 0, &phy_reg_data0);
+	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
 	if ((phy_reg_data0 & 0x1000) =3D=3D auto_neg)
 		return -ENODEV;				/* change didn't take */
=20
 	phy_reg_data0 ^=3D 0x1000;
-	eth_port_write_smi_reg(port_num, 0, phy_reg_data0);
+	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
 	return 0;
 }
=20
@@ -2849,19 +2854,19 @@
  *	None.
  *
  */
-static void ethernet_phy_reset(unsigned int eth_port_num)
+static void ethernet_phy_reset(struct mv643xx_private *mp)
 {
 	unsigned int phy_reg_data;
=20
 	/* Reset the PHY */
-	eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data);
+	eth_port_read_smi_reg(mp, 0, &phy_reg_data);
 	phy_reg_data |=3D 0x8000;	/* Set bit 15 to reset the PHY */
-	eth_port_write_smi_reg(eth_port_num, 0, phy_reg_data);
+	eth_port_write_smi_reg(mp, 0, phy_reg_data);
=20
 	/* wait for PHY to come out of reset */
 	do {
 		udelay(1);
-		eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data);
+		eth_port_read_smi_reg(mp, 0, &phy_reg_data);
 	} while (phy_reg_data & 0x8000);
 }
=20
@@ -3033,15 +3038,18 @@
  *	true otherwise.
  *
  */
-static void eth_port_read_smi_reg(unsigned int port_num,
+static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 				unsigned int phy_reg, unsigned int *value)
 {
-	int phy_addr =3D ethernet_phy_get(port_num);
+	int port_num =3D mp->port_num;
+	int phy_addr;
 	unsigned long flags;
 	int i;
=20
+	phy_addr =3D ethernet_phy_get(port_num);
+
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
+	spin_lock_irqsave(&mp->lock, flags);
=20
 	/* wait for the SMI register to become available */
 	for (i =3D 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
@@ -3066,7 +3074,7 @@
=20
 	*value =3D mv_read(MV643XX_ETH_SMI_REG) & 0xffff;
 out:
-	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
+	spin_unlock_irqrestore(&mp->lock, flags);
 }
=20
 /*
@@ -3089,9 +3097,10 @@
  *	true otherwise.
  *
  */
-static void eth_port_write_smi_reg(unsigned int eth_port_num,
+static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 				   unsigned int phy_reg, unsigned int value)
 {
+	int eth_port_num =3D mp->port_num;
 	int phy_addr;
 	int i;
 	unsigned long flags;
@@ -3099,7 +3108,7 @@
 	phy_addr =3D ethernet_phy_get(eth_port_num);
=20
 	/* the SMI register is a shared resource */
-	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
+	spin_lock_irqsave(&mp->lock, flags);
=20
 	/* wait for the SMI register to become available */
 	for (i =3D 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
@@ -3114,7 +3123,7 @@
 	mv_write(MV643XX_ETH_SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
 				ETH_SMI_OPCODE_WRITE | (value & 0xffff));
 out:
-	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
+	spin_unlock_irqrestore(&mp->lock, flags);
 }
=20
 /*
@@ -3125,14 +3134,14 @@
 	int val;
 	struct mv643xx_private *mp =3D netdev_priv(dev);
=20
-	eth_port_read_smi_reg(mp->port_num, location, &val);
+	eth_port_read_smi_reg(mp, location, &val);
 	return val;
 }
=20
 static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int l=
ocation, int val)
 {
 	struct mv643xx_private *mp =3D netdev_priv(dev);
-	eth_port_write_smi_reg(mp->port_num, location, val);
+	eth_port_write_smi_reg(mp, location, val);
 }
=20
 /*
diff -ur linux-2.6.22.1/drivers/net/mv643xx_eth.h linux-2.6.22.1-rci/driv=
ers/net/mv643xx_eth.h
--- linux-2.6.22.1/drivers/net/mv643xx_eth.h	2007-07-18 22:47:02.00000000=
0 -0500
+++ linux-2.6.22.1-rci/drivers/net/mv643xx_eth.h	2007-07-11 09:28:16.0000=
00000 -0500
@@ -510,12 +510,12 @@
 static void eth_port_start(struct net_device *dev);
=20
 /* PHY and MIB routines */
-static void ethernet_phy_reset(unsigned int eth_port_num);
+static void ethernet_phy_reset(struct mv643xx_private *mp);
=20
-static void eth_port_write_smi_reg(unsigned int eth_port_num,
+static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 				   unsigned int phy_reg, unsigned int value);
=20
-static void eth_port_read_smi_reg(unsigned int eth_port_num,
+static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 				  unsigned int phy_reg, unsigned int *value);
=20
 static void eth_clear_mib_counters(unsigned int eth_port_num);

--------------040607000701050508020100--

--------------enigE4ADAE9500569E9191B90C05
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFGnu8TgyK5H2Ic36cRAlcrAJ48QFK5Cu+s/tHV/ytkvroA161K4gCghOJ4
QnH5uwd6UlMK1RCeGnmU7lo=
=jjXu
-----END PGP SIGNATURE-----

--------------enigE4ADAE9500569E9191B90C05--
