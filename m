From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 22/29] LMC: Move model logic to media structs.
Date: Sat, 31 Jul 2010 17:05:45 +0200
Message-ID: <1280588752-9340-22-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45540 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756496Ab0GaPGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:24 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

There are 4 different card models driven by lmc driver. Move the model-=
specific
code out of the switch()/if statements and into the model-specific medi=
a
structs.

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c  |   75 +++++++++++++----------------------=
-------
 drivers/net/wan/lmc/media.c |   20 +++++++++--
 drivers/net/wan/lmc/var.h   |    3 +-
 3 files changed, 41 insertions(+), 57 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index bd7def0..1231d7c 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -75,8 +75,14 @@
 static int LMC_PKT_BUF_SZ =3D 1542;
=20
 static DEFINE_PCI_DEVICE_TABLE(lmc_pci_tbl) =3D {
-	{ PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST,
-	  PCI_VENDOR_ID_LMC, PCI_ANY_ID },
+	{PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST, PCI_VENDOR_ID_LMC,
+	 PCI_DEVICE_ID_LMC_SSI, .driver_data =3D (long)&lmc_ssi_media},
+	{PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST, PCI_VENDOR_ID_LMC,
+	 PCI_DEVICE_ID_LMC_HSSI, .driver_data =3D (long)&lmc_hssi_media},
+	{PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST, PCI_VENDOR_ID_LMC,
+	 PCI_DEVICE_ID_LMC_DS3, .driver_data =3D (long)&lmc_ds3_media},
+	{PCI_VENDOR_ID_DEC, PCI_DEVICE_ID_DEC_TULIP_FAST, PCI_VENDOR_ID_LMC,
+	 PCI_DEVICE_ID_LMC_T1, .driver_data =3D (long)&lmc_t1_media},
 	{ 0 }
 };
=20
@@ -167,7 +173,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 		spin_lock_irqsave(&sc->lock, flags);
 		sc->xinfo.Magic0 =3D 0xBEEFCAFE;
=20
-		sc->xinfo.PciCardType =3D sc->cardtype;
+		sc->xinfo.PciCardType =3D sc->media->cardtype;
 		sc->xinfo.PciSlotNumber =3D 0;
 		sc->xinfo.DriverMajorVersion =3D DRIVER_MAJOR_VERSION;
 		sc->xinfo.DriverMinorVersion =3D DRIVER_MINOR_VERSION;
@@ -190,7 +196,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
=20
 	case LMCIOCGETLMCSTATS:
 		spin_lock_irqsave(&sc->lock, flags);
-		if (sc->cardtype =3D=3D LMC_CARDTYPE_T1) {
+		if (sc->media->cardtype =3D=3D LMC_CARDTYPE_T1) {
 			lmc_mii_writereg(sc, 0, 17, T1FRAMER_FERR_LSB);
 			sc->extra_stats.framingBitErrorCount +=3D
 				lmc_mii_readreg(sc, 0, 18) & 0xff;
@@ -235,7 +241,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 		sc->extra_stats.check =3D STATCHECK;
 		sc->extra_stats.version_size =3D (DRIVER_VERSION << 16) +
 			sizeof(sc->netdev->stats) + sizeof(sc->extra_stats);
-		sc->extra_stats.cardtype =3D sc->cardtype;
+		sc->extra_stats.cardtype =3D sc->media->cardtype;
 		spin_unlock_irqrestore(&sc->lock, flags);
 		ret =3D 0;
 		break;
@@ -283,7 +289,7 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 		break;
=20
 	case LMCIOCT1CONTROL:
-		if (sc->cardtype !=3D LMC_CARDTYPE_T1) {
+		if (sc->media->cardtype !=3D LMC_CARDTYPE_T1) {
 			ret =3D -EOPNOTSUPP;
 			break;
 		}
@@ -708,10 +714,8 @@ static int __devinit lmc_init_one(struct pci_dev *=
pdev,
 {
 	struct card *sc;
 	struct net_device *dev;
-	u16 subdevice;
-	u16 AdapModelNum;
+	u16 model;
 	int err;
-	static int cards_found;
=20
 	/* lmc_trace(dev, "lmc_init_one in"); */
=20
@@ -768,34 +772,10 @@ static int __devinit lmc_init_one(struct pci_dev =
*pdev,
 		goto err_hdlcdev;
 	}
=20
-	sc->cardtype =3D LMC_CARDTYPE_UNKNOWN;
 	sc->timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
+	sc->media =3D (struct media*)ent->driver_data;
=20
-	switch (subdevice) {
-	case PCI_DEVICE_ID_LMC_HSSI:
-		dev_info(&pdev->dev, "%s =3D LMC HSSI\n", dev->name);
-		sc->cardtype =3D LMC_CARDTYPE_HSSI;
-		sc->media =3D &lmc_hssi_media;
-		break;
-	case PCI_DEVICE_ID_LMC_DS3:
-		dev_info(&pdev->dev, "%s =3D LMC DS3\n", dev->name);
-		sc->cardtype =3D LMC_CARDTYPE_DS3;
-		sc->media =3D &lmc_ds3_media;
-		break;
-	case PCI_DEVICE_ID_LMC_SSI:
-		dev_info(&pdev->dev, "%s =3D LMC SSI\n", dev->name);
-		sc->cardtype =3D LMC_CARDTYPE_SSI;
-		sc->media =3D &lmc_ssi_media;
-		break;
-	case PCI_DEVICE_ID_LMC_T1:
-		dev_info(&pdev->dev, "%s =3D LMC T1\n", dev->name);
-		sc->cardtype =3D LMC_CARDTYPE_T1;
-		sc->media =3D &lmc_t1_media;
-		break;
-	default:
-		dev_warn(&pdev->dev, "%s =3D LMC UNKNOWN CARD!\n", dev->name);
-		break;
-	}
+	dev_info(&pdev->dev, "%s =3D LMC %s\n", dev->name, sc->media->name);
=20
 	lmc_initcsrs(sc, dev->base_addr, 8);
=20
@@ -809,27 +789,18 @@ static int __devinit lmc_init_one(struct pci_dev =
*pdev,
=20
 	/* verify that the PCI Sub System ID matches the Adapter Model number
 	   from the MII register */
-	AdapModelNum =3D (lmc_mii_readreg(sc, 0, 3) & 0x3f0) >> 4;
-
-	if ((AdapModelNum !=3D LMC_ADAP_T1 || /* detect LMC1200 */
-	     subdevice !=3D PCI_DEVICE_ID_LMC_T1) &&
-	    (AdapModelNum !=3D LMC_ADAP_SSI || /* detect LMC1000 */
-	     subdevice !=3D PCI_DEVICE_ID_LMC_SSI) &&
-	    (AdapModelNum !=3D LMC_ADAP_DS3 || /* detect LMC5245 */
-	     subdevice !=3D PCI_DEVICE_ID_LMC_DS3) &&
-	    (AdapModelNum !=3D LMC_ADAP_HSSI || /* detect LMC5200 */
-	     subdevice !=3D PCI_DEVICE_ID_LMC_HSSI))
-		printk(KERN_WARNING "%s: Model number (%d) miscompare for PCI"
-		       " Subsystem ID =3D 0x%04x\n",
-		       dev->name, AdapModelNum, subdevice);
-
-	/* reset clock */
-	LMC_CSR_WRITE(sc, csr_gp_timer, 0xFFFFFFFFUL);
+	model =3D (lmc_mii_readreg(sc, 0, 3) & 0x3F0) >> 4;
+
+	if (model !=3D sc->media->mii_type)
+		dev_warn(&pdev->dev, "%s: Invalid model number (%d)",
+			 dev->name, model);
+
+	LMC_CSR_WRITE(sc, csr_gp_timer, 0xFFFFFFFFUL); /* reset clock */
=20
 	sc->extra_stats.check =3D STATCHECK;
 	sc->extra_stats.version_size =3D (DRIVER_VERSION << 16) +
 		sizeof(sc->netdev->stats) + sizeof(sc->extra_stats);
-	sc->extra_stats.cardtype =3D sc->cardtype;
+	sc->extra_stats.cardtype =3D sc->media->cardtype;
=20
 	sc->ok =3D 0;
 	sc->last_link_status =3D 0;
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index fde275a..ecf0f2a 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -906,7 +906,10 @@ static void lmc_t1_default(struct card * const sc)
 }
=20
=20
-struct media lmc_ssi_media =3D {
+struct media lmc_ssi_media =3D { /* LMC1000 */
+	.name =3D "SSI",
+	.cardtype =3D LMC_CARDTYPE_SSI,
+	.mii_type =3D LMC_ADAP_SSI,
 	.init =3D lmc_ssi_init,
 	.defaults =3D lmc_ssi_default,
 	.set_status =3D lmc_ssi_set_status,
@@ -918,7 +921,10 @@ struct media lmc_ssi_media =3D {
 	.watchdog =3D lmc_ssi_watchdog,
 };
=20
-struct media lmc_hssi_media =3D {
+struct media lmc_hssi_media =3D { /* LMC5200 */
+	.name =3D "HSSI",
+	.cardtype =3D LMC_CARDTYPE_HSSI,
+	.mii_type =3D LMC_ADAP_HSSI,
 	.init =3D lmc_hssi_init,
 	.defaults =3D lmc_hssi_default,
 	.set_status =3D lmc_hssi_set_status,
@@ -928,7 +934,10 @@ struct media lmc_hssi_media =3D {
 	.set_crc_length =3D lmc_hssi_set_crc_length,
 };
=20
-struct media lmc_ds3_media =3D {
+struct media lmc_ds3_media =3D { /* LMC5245 */
+	.name =3D "DS3",
+	.cardtype =3D LMC_CARDTYPE_DS3,
+	.mii_type =3D LMC_ADAP_DS3,
 	.init =3D lmc_ds3_init,
 	.defaults =3D lmc_ds3_default,
 	.set_status =3D lmc_ds3_set_status,
@@ -938,7 +947,10 @@ struct media lmc_ds3_media =3D {
 	.set_crc_length =3D lmc_ds3_set_crc_length,
 };
=20
-struct media lmc_t1_media =3D {
+struct media lmc_t1_media =3D { /* LMC1200 */
+	.name =3D "T1",
+	.cardtype =3D LMC_CARDTYPE_T1,
+	.mii_type =3D LMC_ADAP_T1,
 	.init =3D lmc_t1_init,
 	.defaults =3D lmc_t1_default,
 	.set_status =3D lmc_t1_set_status,
diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index 729ab9f..971f5d6 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -195,6 +195,8 @@ struct media {
 	void (* set_crc_length)(struct card * const, int);
 	void (* set_circuit_type)(struct card * const, int);
 	void (* watchdog)(struct card * const);
+	char * const name;
+	int cardtype, mii_type;
 };
=20
 #define STATCHECK 0xBEEFCAFE
@@ -292,7 +294,6 @@ struct card {
 	u16 miireg16;
 	int ok;
 	int last_link_status;
-	int cardtype;
 	u32 last_frameerr;
 	struct media *media;
 	struct timer_list timer;
--=20
1.7.1.1

