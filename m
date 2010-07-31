From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 08/29] LMC: Remove "dummy" media functions.
Date: Sat, 31 Jul 2010 17:05:31 +0200
Message-ID: <1280588752-9340-8-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59291 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756488Ab0GaPGN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:13 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/main.c  |   18 ++++++---
 drivers/net/wan/lmc/media.c |   80 +++++++++++++----------------------=
-------
 2 files changed, 37 insertions(+), 61 deletions(-)

diff --git a/drivers/net/wan/lmc/main.c b/drivers/net/wan/lmc/main.c
index 13bb6f6..6b7c09a 100644
--- a/drivers/net/wan/lmc/main.c
+++ b/drivers/net/wan/lmc/main.c
@@ -261,7 +261,8 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 			break;
 		}
 		spin_lock_irqsave(&sc->lmc_lock, flags);
-		sc->lmc_media->set_circuit_type(sc, ctl.circuit_type);
+		if (sc->lmc_media->set_circuit_type)
+			sc->lmc_media->set_circuit_type(sc, ctl.circuit_type);
 		sc->ictl.circuit_type =3D ctl.circuit_type;
 		spin_unlock_irqrestore(&sc->lmc_lock, flags);
 		ret =3D 0;
@@ -356,7 +357,8 @@ int lmc_ioctl(struct net_device *dev, struct ifreq =
*ifr, int cmd)
 			lmc_gpio_mkinput(sc, 0xff);
=20
 			/* Reset the frammer hardware */
-			sc->lmc_media->set_link_status(sc, 1);
+			if (sc->lmc_media->set_link_status)
+				sc->lmc_media->set_link_status(sc, 1);
 			sc->lmc_media->set_status(sc, NULL);
 			/* lmc_softreset(sc); */
=20
@@ -856,7 +858,8 @@ static int __devinit lmc_init_one(struct pci_dev *p=
dev,
=20
 	sc->lmc_media->defaults(sc);
=20
-	sc->lmc_media->set_link_status(sc, LMC_LINK_UP);
+	if (sc->lmc_media->set_link_status)
+		sc->lmc_media->set_link_status(sc, LMC_LINK_UP);
=20
 	/* verify that the PCI Sub System ID matches the Adapter Model number
 	   from the MII register */
@@ -951,7 +954,8 @@ static int lmc_open(struct net_device *dev)
=20
 	/* Assert Terminal Active */
 	sc->lmc_miireg16 |=3D LMC_MII16_LED_ALL;
-	sc->lmc_media->set_link_status(sc, LMC_LINK_UP);
+	if (sc->lmc_media->set_link_status)
+		sc->lmc_media->set_link_status(sc, LMC_LINK_UP);
=20
 	/*
 	 * reset to last state.
@@ -1026,7 +1030,8 @@ static void lmc_running_reset(struct net_device *=
dev)
 	lmc_reset(sc);
 	lmc_softreset(sc);
 	/* sc->lmc_miireg16 |=3D LMC_MII16_LED_ALL; */
-	sc->lmc_media->set_link_status(sc, 1);
+	if (sc->lmc_media->set_link_status)
+		sc->lmc_media->set_link_status(sc, 1);
 	sc->lmc_media->set_status(sc, NULL);
=20
 	netif_wake_queue(dev);
@@ -1054,7 +1059,8 @@ static int lmc_close(struct net_device *dev)
 	lmc_trace(dev, "lmc_close in");
=20
 	sc->lmc_ok =3D 0;
-	sc->lmc_media->set_link_status(sc, 0);
+	if (sc->lmc_media->set_link_status)
+		sc->lmc_media->set_link_status(sc, 0);
 	del_timer(&sc->timer);
 	hdlc_close(sc->lmc_device);
 	lmc_ifdown(dev);
diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index 36b685f..baf6e43 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -78,9 +78,6 @@ static void lmc_t1_set_crc_length(struct card * const=
, int);
 static void lmc_t1_set_clock(struct card * const, int);
 static void lmc_t1_watchdog(struct card * const);
=20
-static void lmc_dummy_set_1(struct card * const, int);
-static void lmc_dummy_set2_1(struct card * const, struct control *);
-
 static inline void write_av9110_bit(struct card *, int);
 static void write_av9110(struct card *, u32, u32, u32, u32, u32);
=20
@@ -88,14 +85,10 @@ struct media lmc_ds3_media =3D {
 	.init =3D lmc_ds3_init,
 	.defaults =3D lmc_ds3_default,
 	.set_status =3D lmc_ds3_set_status,
-	.set_clock_source =3D lmc_dummy_set_1,
-	.set_speed =3D lmc_dummy_set2_1,
 	.set_cable_length =3D lmc_ds3_set_100ft,
 	.set_scrambler =3D lmc_ds3_set_scram,
 	.get_link_status =3D lmc_ds3_get_link_status,
-	.set_link_status =3D lmc_dummy_set_1,
 	.set_crc_length =3D lmc_ds3_set_crc_length,
-	.set_circuit_type =3D lmc_dummy_set_1,
 	.watchdog =3D lmc_ds3_watchdog,
 };
=20
@@ -104,13 +97,9 @@ struct media lmc_hssi_media =3D {
 	.defaults =3D lmc_hssi_default,
 	.set_status =3D lmc_hssi_set_status,
 	.set_clock_source =3D lmc_hssi_set_clock,
-	.set_speed =3D lmc_dummy_set2_1,
-	.set_cable_length =3D lmc_dummy_set_1,
-	.set_scrambler =3D lmc_dummy_set_1,
 	.get_link_status =3D lmc_hssi_get_link_status,
 	.set_link_status =3D lmc_hssi_set_link_status,
 	.set_crc_length =3D lmc_hssi_set_crc_length,
-	.set_circuit_type =3D lmc_dummy_set_1,
 	.watchdog =3D lmc_hssi_watchdog,
 };
=20
@@ -120,12 +109,9 @@ struct media lmc_ssi_media =3D {
 	.set_status =3D lmc_ssi_set_status,
 	.set_clock_source =3D lmc_ssi_set_clock,
 	.set_speed =3D lmc_ssi_set_speed,
-	.set_cable_length =3D lmc_dummy_set_1,
-	.set_scrambler =3D lmc_dummy_set_1,
 	.get_link_status =3D lmc_ssi_get_link_status,
 	.set_link_status =3D lmc_ssi_set_link_status,
 	.set_crc_length =3D lmc_ssi_set_crc_length,
-	.set_circuit_type =3D lmc_dummy_set_1,
 	.watchdog =3D lmc_ssi_watchdog,
 };
=20
@@ -134,24 +120,12 @@ struct media lmc_t1_media =3D {
 	.defaults =3D lmc_t1_default,
 	.set_status =3D lmc_t1_set_status,
 	.set_clock_source =3D lmc_t1_set_clock,
-	.set_speed =3D lmc_dummy_set2_1,
-	.set_cable_length =3D lmc_dummy_set_1,
-	.set_scrambler =3D lmc_dummy_set_1,
 	.get_link_status =3D lmc_t1_get_link_status,
-	.set_link_status =3D lmc_dummy_set_1,
 	.set_crc_length =3D lmc_t1_set_crc_length,
 	.set_circuit_type =3D lmc_t1_set_circuit_type,
 	.watchdog =3D lmc_t1_watchdog,
 };
=20
-static void lmc_dummy_set_1(struct card * const sc, int a)
-{
-}
-
-static void lmc_dummy_set2_1(struct card * const sc, struct control * =
a)
-{
-}
-
 /* HSSI methods */
=20
 static void lmc_hssi_init(struct card * const sc)
@@ -163,10 +137,9 @@ static void lmc_hssi_init(struct card * const sc)
 static void lmc_hssi_default(struct card * const sc)
 {
 	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
-
-	sc->lmc_media->set_link_status(sc, LMC_LINK_DOWN);
-	sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_EXT);
-	sc->lmc_media->set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
+	lmc_hssi_set_link_status(sc, LMC_LINK_DOWN);
+	lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+	lmc_hssi_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
 }
=20
 /* Given a user provided state, set ourselves up to match it.
@@ -174,7 +147,7 @@ static void lmc_hssi_default(struct card * const sc=
)
 static void lmc_hssi_set_status(struct card * const sc, struct control=
 *ctl)
 {
 	if (ctl =3D=3D NULL) {
-		sc->lmc_media->set_clock_source(sc, sc->ictl.clock_source);
+		lmc_hssi_set_clock(sc, sc->ictl.clock_source);
 		lmc_set_protocol(sc, NULL);
=20
 		return;
@@ -182,11 +155,11 @@ static void lmc_hssi_set_status(struct card * con=
st sc, struct control *ctl)
=20
 	/* check for change in clock source */
 	if (ctl->clock_source && !sc->ictl.clock_source) {
-		sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_INT);
+		lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_INT);
 		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
 	} else if (!ctl->clock_source && sc->ictl.clock_source) {
 		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
-		sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+		lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
 	}
=20
 	lmc_set_protocol(sc, ctl);
@@ -272,10 +245,9 @@ static void lmc_ds3_default(struct card * const sc=
)
 {
 	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
=20
-	sc->lmc_media->set_link_status(sc, LMC_LINK_DOWN);
-	sc->lmc_media->set_cable_length(sc, LMC_CTL_CABLE_LENGTH_LT_100FT);
-	sc->lmc_media->set_scrambler(sc, LMC_CTL_OFF);
-	sc->lmc_media->set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
+	lmc_ds3_set_100ft(sc, LMC_CTL_CABLE_LENGTH_LT_100FT);
+	lmc_ds3_set_scram(sc, LMC_CTL_OFF);
+	lmc_ds3_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
 }
=20
 /* Given a user provided state, set ourselves up to match it.
@@ -283,8 +255,8 @@ static void lmc_ds3_default(struct card * const sc)
 static void lmc_ds3_set_status(struct card * const sc, struct control =
*ctl)
 {
 	if (ctl =3D=3D NULL) {
-		sc->lmc_media->set_cable_length(sc, sc->ictl.cable_length);
-		sc->lmc_media->set_scrambler(sc, sc->ictl.scrambler_onoff);
+		lmc_ds3_set_100ft(sc, sc->ictl.cable_length);
+		lmc_ds3_set_scram(sc, sc->ictl.scrambler_onoff);
 		lmc_set_protocol(sc, NULL);
 		return;
 	}
@@ -480,10 +452,10 @@ static void lmc_ssi_default(struct card * const s=
c)
 	/* make TXCLOCK always be an output */
 	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
=20
-	sc->lmc_media->set_link_status(sc, LMC_LINK_DOWN);
-	sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_EXT);
-	sc->lmc_media->set_speed(sc, NULL);
-	sc->lmc_media->set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
+	lmc_ssi_set_link_status(sc, LMC_LINK_DOWN);
+	lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+	lmc_ssi_set_speed(sc, NULL);
+	lmc_ssi_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
 }
=20
 /* Given a user provided state, set ourselves up to match it.
@@ -491,8 +463,8 @@ static void lmc_ssi_default(struct card * const sc)
 static void lmc_ssi_set_status(struct card * const sc, struct control =
*ctl)
 {
 	if (ctl =3D=3D NULL) {
-		sc->lmc_media->set_clock_source(sc, sc->ictl.clock_source);
-		sc->lmc_media->set_speed(sc, &sc->ictl);
+		lmc_ssi_set_clock(sc, sc->ictl.clock_source);
+		lmc_ssi_set_speed(sc, &sc->ictl);
 		lmc_set_protocol(sc, NULL);
 		return;
 	}
@@ -500,16 +472,16 @@ static void lmc_ssi_set_status(struct card * cons=
t sc, struct control *ctl)
 	/* check for change in clock source */
 	if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT
 	    && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
-		sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_INT);
+		lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_INT);
 		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
 	} else if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT
 		 && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT) {
-		sc->lmc_media->set_clock_source(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+		lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
 		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
 	}
=20
 	if (ctl->clock_rate !=3D sc->ictl.clock_rate)
-		sc->lmc_media->set_speed(sc, ctl);
+		lmc_ssi_set_speed(sc, ctl);
=20
 	lmc_set_protocol(sc, ctl);
 }
@@ -833,9 +805,8 @@ static void lmc_t1_init(struct card * const sc)
 static void lmc_t1_default(struct card * const sc)
 {
 	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
-	sc->lmc_media->set_link_status(sc, LMC_LINK_DOWN);
-	sc->lmc_media->set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
-	sc->lmc_media->set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
+	lmc_t1_set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
+	lmc_t1_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
 	/* Right now we can only clock from out internal source */
 	sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
 }
@@ -844,18 +815,17 @@ static void lmc_t1_default(struct card * const sc=
)
 static void lmc_t1_set_status(struct card * const sc, struct control *=
ctl)
 {
 	if (ctl =3D=3D NULL) {
-		sc->lmc_media->set_circuit_type(sc, sc->ictl.circuit_type);
+		lmc_t1_set_circuit_type(sc, sc->ictl.circuit_type);
 		lmc_set_protocol(sc, NULL);
-
 		return;
 	}
 	/* check for change in circuit type */
 	if (ctl->circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_T1
 	    && sc->ictl.circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_E1)
-		sc->lmc_media->set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_E1);
+		lmc_t1_set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_E1);
 	else if (ctl->circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_E1
 		 && sc->ictl.circuit_type =3D=3D LMC_CTL_CIRCUIT_TYPE_T1)
-		sc->lmc_media->set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
+		lmc_t1_set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
 	lmc_set_protocol(sc, ctl);
 }
=20
--=20
1.7.1.1

