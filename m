From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 09/29] LMC: shuffle protocol routines to avoid a need for prototypes.
Date: Sat, 31 Jul 2010 17:05:32 +0200
Message-ID: <1280588752-9340-9-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45540 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756496Ab0GaPGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:16 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/media.c |  940 +++++++++++++++++++++--------------=
--------
 1 files changed, 450 insertions(+), 490 deletions(-)

diff --git a/drivers/net/wan/lmc/media.c b/drivers/net/wan/lmc/media.c
index baf6e43..9701d30 100644
--- a/drivers/net/wan/lmc/media.c
+++ b/drivers/net/wan/lmc/media.c
@@ -37,134 +37,318 @@
  * the GNU General Public License version 2, incorporated herein by re=
ference.
  */
=20
-/* protocol independent method. */
-static void lmc_set_protocol(struct card * const, struct control *);
-
-/* media independent methods to check on media status, link, light LED=
s, etc. */
-static void lmc_ds3_init(struct card * const);
-static void lmc_ds3_default(struct card * const);
-static void lmc_ds3_set_status(struct card * const, struct control *);
-static void lmc_ds3_set_100ft(struct card * const, int);
-static int lmc_ds3_get_link_status(struct card * const);
-static void lmc_ds3_set_crc_length(struct card * const, int);
-static void lmc_ds3_set_scram(struct card * const, int);
-static void lmc_ds3_watchdog(struct card * const);
-
-static void lmc_hssi_init(struct card * const);
-static void lmc_hssi_default(struct card * const);
-static void lmc_hssi_set_status(struct card * const, struct control *)=
;
-static void lmc_hssi_set_clock(struct card * const, int);
-static int lmc_hssi_get_link_status(struct card * const);
-static void lmc_hssi_set_link_status(struct card * const, int);
-static void lmc_hssi_set_crc_length(struct card * const, int);
-static void lmc_hssi_watchdog(struct card * const);
-
-static void lmc_ssi_init(struct card * const);
-static void lmc_ssi_default(struct card * const);
-static void lmc_ssi_set_status(struct card * const, struct control *);
-static void lmc_ssi_set_clock(struct card * const, int);
-static void lmc_ssi_set_speed(struct card * const, struct control *);
-static int lmc_ssi_get_link_status(struct card * const);
-static void lmc_ssi_set_link_status(struct card * const, int);
-static void lmc_ssi_set_crc_length(struct card * const, int);
-static void lmc_ssi_watchdog(struct card * const);
-
-static void lmc_t1_init(struct card * const);
-static void lmc_t1_default(struct card * const);
-static void lmc_t1_set_status(struct card * const, struct control *);
-static int lmc_t1_get_link_status(struct card * const);
-static void lmc_t1_set_circuit_type(struct card * const, int);
-static void lmc_t1_set_crc_length(struct card * const, int);
-static void lmc_t1_set_clock(struct card * const, int);
-static void lmc_t1_watchdog(struct card * const);
-
-static inline void write_av9110_bit(struct card *, int);
-static void write_av9110(struct card *, u32, u32, u32, u32, u32);
+static void lmc_set_protocol(struct card * const sc, struct control *c=
tl)
+{
+	if (!ctl)
+		sc->ictl.keepalive_onoff =3D LMC_CTL_ON;
+}
=20
-struct media lmc_ds3_media =3D {
-	.init =3D lmc_ds3_init,
-	.defaults =3D lmc_ds3_default,
-	.set_status =3D lmc_ds3_set_status,
-	.set_cable_length =3D lmc_ds3_set_100ft,
-	.set_scrambler =3D lmc_ds3_set_scram,
-	.get_link_status =3D lmc_ds3_get_link_status,
-	.set_crc_length =3D lmc_ds3_set_crc_length,
-	.watchdog =3D lmc_ds3_watchdog,
-};
=20
-struct media lmc_hssi_media =3D {
-	.init =3D lmc_hssi_init,
-	.defaults =3D lmc_hssi_default,
-	.set_status =3D lmc_hssi_set_status,
-	.set_clock_source =3D lmc_hssi_set_clock,
-	.get_link_status =3D lmc_hssi_get_link_status,
-	.set_link_status =3D lmc_hssi_set_link_status,
-	.set_crc_length =3D lmc_hssi_set_crc_length,
-	.watchdog =3D lmc_hssi_watchdog,
-};
+/* SSI methods */
=20
-struct media lmc_ssi_media =3D {
-	.init =3D lmc_ssi_init,
-	.defaults =3D lmc_ssi_default,
-	.set_status =3D lmc_ssi_set_status,
-	.set_clock_source =3D lmc_ssi_set_clock,
-	.set_speed =3D lmc_ssi_set_speed,
-	.get_link_status =3D lmc_ssi_get_link_status,
-	.set_link_status =3D lmc_ssi_set_link_status,
-	.set_crc_length =3D lmc_ssi_set_crc_length,
-	.watchdog =3D lmc_ssi_watchdog,
-};
+/* These are bits to program the ssi frequency generator */
+static inline void write_av9110_bit(struct card *sc, int c)
+{
+	/* set the data bit as we need it. */
+	sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
+	if (c & 0x01)
+		sc->lmc_gpio |=3D LMC_GEP_DATA;
+	else
+		sc->lmc_gpio &=3D ~(LMC_GEP_DATA);
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
=20
-struct media lmc_t1_media =3D {
-	.init =3D lmc_t1_init,
-	.defaults =3D lmc_t1_default,
-	.set_status =3D lmc_t1_set_status,
-	.set_clock_source =3D lmc_t1_set_clock,
-	.get_link_status =3D lmc_t1_get_link_status,
-	.set_crc_length =3D lmc_t1_set_crc_length,
-	.set_circuit_type =3D lmc_t1_set_circuit_type,
-	.watchdog =3D lmc_t1_watchdog,
-};
+	/* set the clock to high */
+	sc->lmc_gpio |=3D LMC_GEP_CLK;
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
=20
-/* HSSI methods */
+	/* set the clock to low again. */
+	sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+}
=20
-static void lmc_hssi_init(struct card * const sc)
+static void write_av9110(struct card *sc, u32 n, u32 m, u32 v, u32 x, =
u32 r)
 {
-	sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC5200;
-	lmc_gpio_mkoutput(sc, LMC_GEP_HSSI_CLOCK);
+	int i;
+
+#if 0
+	printk(LMC_PRINTF_FMT ": speed %u, %d %d %d %d %d\n",
+	       LMC_PRINTF_ARGS, sc->ictl.clock_rate, n, m, v, x, r);
+#endif
+
+	sc->lmc_gpio |=3D LMC_GEP_SSI_GENERATOR;
+	sc->lmc_gpio &=3D ~(LMC_GEP_DATA | LMC_GEP_CLK);
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+	/* Set the TXCLOCK, GENERATOR, SERIAL, and SERIALCLK as outputs. */
+	lmc_gpio_mkoutput(sc, (LMC_GEP_DATA | LMC_GEP_CLK
+				| LMC_GEP_SSI_GENERATOR));
+
+	sc->lmc_gpio &=3D ~(LMC_GEP_SSI_GENERATOR);
+	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+
+	/* a shifting we will go... */
+	for (i =3D 0; i < 7; i++)
+		write_av9110_bit(sc, n >> i);
+	for (i =3D 0; i < 7; i++)
+		write_av9110_bit(sc, m >> i);
+	for (i =3D 0; i < 1; i++)
+		write_av9110_bit(sc, v >> i);
+	for (i =3D 0; i < 2; i++)
+		write_av9110_bit(sc, x >> i);
+	for (i =3D 0; i < 2; i++)
+		write_av9110_bit(sc, r >> i);
+	for (i =3D 0; i < 5; i++)
+		write_av9110_bit(sc, 0x17 >> i);
+
+	/* stop driving serial-related signals */
+	lmc_gpio_mkinput(sc, (LMC_GEP_DATA | LMC_GEP_CLK |
+			      LMC_GEP_SSI_GENERATOR));
 }
=20
-static void lmc_hssi_default(struct card * const sc)
+static void lmc_ssi_init(struct card * const sc)
 {
-	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
-	lmc_hssi_set_link_status(sc, LMC_LINK_DOWN);
-	lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
-	lmc_hssi_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
+	u16 mii17;
+	int cable;
+
+	sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC1000;
+
+	mii17 =3D lmc_mii_readreg(sc, 0, 17);
+
+	cable =3D (mii17 & LMC_MII17_SSI_CABLE_MASK) >> LMC_MII17_SSI_CABLE_S=
HIFT;
+	sc->ictl.cable_type =3D cable;
+
+	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
+}
+
+/* 1 =3D=3D internal, 0 =3D=3D external */
+static void lmc_ssi_set_clock(struct card * const sc, int ie)
+{
+	int old;
+	old =3D ie;
+	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
+		sc->lmc_gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
+		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
+		if (ie !=3D old)
+			printk(LMC_PRINTF_FMT ": clock external\n",
+			       LMC_PRINTF_ARGS);
+	} else {
+		sc->lmc_gpio |=3D LMC_GEP_SSI_TXCLOCK;
+		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
+		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
+		if (ie !=3D old)
+			printk(LMC_PRINTF_FMT ": clock internal\n",
+			       LMC_PRINTF_ARGS);
+	}
+}
+
+static void lmc_ssi_set_speed(struct card * const sc, struct control *=
ctl)
+{
+	struct control *ictl =3D &sc->ictl;
+	lmc_av9110_t *av;
+
+	/* original settings for clock rate of 100 Khz (8,25,0,0,2) were
+	   incorrect. They should have been 80,125,1,3,3. There are 17 param
+	   combinations to produce this freq. For 1.5 Mhz use 120,100,1,1,2
+	   (226 param. combinations) */
+	if (ctl =3D=3D NULL) {
+		av =3D &ictl->cardspec.ssi;
+		ictl->clock_rate =3D 1500000;
+		av->f =3D ictl->clock_rate;
+		av->n =3D 120;
+		av->m =3D 100;
+		av->v =3D 1;
+		av->x =3D 1;
+		av->r =3D 2;
+		write_av9110(sc, av->n, av->m, av->v, av->x, av->r);
+		return;
+	}
+
+	av =3D &ctl->cardspec.ssi;
+
+	if (av->f =3D=3D 0)
+		return;
+
+	ictl->clock_rate =3D av->f;	/* really, this is the rate we are */
+	ictl->cardspec.ssi =3D *av;
+
+	write_av9110(sc, av->n, av->m, av->v, av->x, av->r);
 }
=20
 /* Given a user provided state, set ourselves up to match it.
    This will always reset the card if needed. */
-static void lmc_hssi_set_status(struct card * const sc, struct control=
 *ctl)
+static void lmc_ssi_set_status(struct card * const sc, struct control =
*ctl)
 {
 	if (ctl =3D=3D NULL) {
-		lmc_hssi_set_clock(sc, sc->ictl.clock_source);
+		lmc_ssi_set_clock(sc, sc->ictl.clock_source);
+		lmc_ssi_set_speed(sc, &sc->ictl);
 		lmc_set_protocol(sc, NULL);
-
 		return;
 	}
=20
 	/* check for change in clock source */
-	if (ctl->clock_source && !sc->ictl.clock_source) {
-		lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_INT);
+	if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT
+	    && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
+		lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_INT);
 		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
-	} else if (!ctl->clock_source && sc->ictl.clock_source) {
+	} else if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT
+		 && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT) {
+		lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
 		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
-		lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
 	}
=20
+	if (ctl->clock_rate !=3D sc->ictl.clock_rate)
+		lmc_ssi_set_speed(sc, ctl);
+
 	lmc_set_protocol(sc, ctl);
 }
=20
+/* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
+static int lmc_ssi_get_link_status(struct card * const sc)
+{
+	u16 link_status;
+	u32 ticks;
+	int ret =3D 1;
+	int hw_hdsk =3D 1;
+
+	/* missing CTS?  Hmm.  If we require CTS on, we may never get the
+	   link to come up, so omit it in this test.
+
+	   Also, it seems that with a loopback cable, DCD isn't asserted,
+	   so just check for things like this:
+	   - DSR _must_ be asserted.
+	   - One of DCD or CTS must be asserted. */
+
+	/* LMC 1000 (SSI) LED definitions
+	   - led0 green =3D power to adapter, Gate Array loaded & driver atta=
ched
+	   - led1 green =3D DSR and DTR and RTS and CTS are set
+	   - led2 green =3D Cable detected
+	   - led3 red   =3D No timing is available from the cable or the on-b=
oard
+			  frequency generator. */
+
+	link_status =3D lmc_mii_readreg(sc, 0, 16);
+
+	/* Is the transmit clock still available */
+	ticks =3D LMC_CSR_READ(sc, csr_gp_timer);
+	ticks =3D 0x0000ffff - (ticks & 0x0000ffff);
+
+	lmc_led_on(sc, LMC_MII16_LED0);
+
+	/* transmit clock determination */
+	if (sc->lmc_timing =3D=3D LMC_CTL_CLOCK_SOURCE_INT)
+		lmc_led_off(sc, LMC_MII16_LED3);
+	else if (ticks =3D=3D 0) {	/* no clock found ? */
+		ret =3D 0;
+		if (sc->last_led_err[3] !=3D 1) {
+			sc->extra_stats.tx_lossOfClockCnt++;
+			printk(KERN_WARNING "%s: Lost Clock, Link Down\n",
+			       sc->name);
+		}
+		sc->last_led_err[3] =3D 1;
+		lmc_led_on(sc, LMC_MII16_LED3);	/* turn ON red LED */
+	} else {
+		if (sc->last_led_err[3] =3D=3D 1)
+			printk(KERN_WARNING "%s: Clock Returned\n", sc->name);
+		sc->last_led_err[3] =3D 0;
+		lmc_led_off(sc, LMC_MII16_LED3); /* turn OFF red LED */
+	}
+
+	if ((link_status & LMC_MII16_SSI_DSR) =3D=3D 0) { /* Also HSSI CA */
+		ret =3D 0;
+		hw_hdsk =3D 0;
+	}
+
+#ifdef CONFIG_LMC_IGNORE_HARDWARE_HANDSHAKE
+	if ((link_status & (LMC_MII16_SSI_CTS | LMC_MII16_SSI_DCD)) =3D=3D 0)=
 {
+		ret =3D 0;
+		hw_hdsk =3D 0;
+	}
+#endif
+
+	if (hw_hdsk =3D=3D 0) {
+		if (sc->last_led_err[1] !=3D 1)
+			printk(KERN_WARNING "%s: DSR not asserted\n", sc->name);
+		sc->last_led_err[1] =3D 1;
+		lmc_led_off(sc, LMC_MII16_LED1);
+	} else {
+		if (sc->last_led_err[1] !=3D 0)
+			printk(KERN_WARNING "%s: DSR now asserted\n", sc->name);
+		sc->last_led_err[1] =3D 0;
+		lmc_led_on(sc, LMC_MII16_LED1);
+	}
+
+	if (ret =3D=3D 1)
+		lmc_led_on(sc, LMC_MII16_LED2); /* Over all good status? */
+
+	return ret;
+}
+
+static void lmc_ssi_set_link_status(struct card * const sc, int state)
+{
+	if (state =3D=3D LMC_LINK_UP) {
+		sc->lmc_miireg16 |=3D (LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
+		printk(LMC_PRINTF_FMT ": asserting DTR and RTS\n",
+		       LMC_PRINTF_ARGS);
+	} else {
+		sc->lmc_miireg16 &=3D ~(LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
+		printk(LMC_PRINTF_FMT ": deasserting DTR and RTS\n",
+		       LMC_PRINTF_ARGS);
+	}
+
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+
+}
+
+/* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
+static void lmc_ssi_set_crc_length(struct card * const sc, int state)
+{
+	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
+		/* 32 bit */
+		sc->lmc_miireg16 |=3D LMC_MII16_SSI_CRC;
+		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
+		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_4;
+
+	} else {
+		/* 16 bit */
+		sc->lmc_miireg16 &=3D ~LMC_MII16_SSI_CRC;
+		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
+		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_2;
+	}
+
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+}
+
+static void lmc_ssi_default(struct card * const sc)
+{
+	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+
+	/* make TXCLOCK always be an output */
+	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
+
+	lmc_ssi_set_link_status(sc, LMC_LINK_DOWN);
+	lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+	lmc_ssi_set_speed(sc, NULL);
+	lmc_ssi_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
+}
+
+static void lmc_ssi_watchdog(struct card * const sc)
+{
+	u16 mii17 =3D lmc_mii_readreg(sc, 0, 17);
+	if (((mii17 >> 3) & 7) =3D=3D 7)
+		lmc_led_off(sc, LMC_MII16_LED2);
+	else
+		lmc_led_on(sc, LMC_MII16_LED2);
+}
+
+
+/* HSSI methods */
+
+static void lmc_hssi_init(struct card * const sc)
+{
+	sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC5200;
+	lmc_gpio_mkoutput(sc, LMC_GEP_HSSI_CLOCK);
+}
+
 /* 1 =3D=3D internal, 0 =3D=3D external */
 static void lmc_hssi_set_clock(struct card * const sc, int ie)
 {
@@ -187,8 +371,31 @@ static void lmc_hssi_set_clock(struct card * const=
 sc, int ie)
 	}
 }
=20
+/* Given a user provided state, set ourselves up to match it.
+   This will always reset the card if needed. */
+static void lmc_hssi_set_status(struct card * const sc, struct control=
 *ctl)
+{
+	if (ctl =3D=3D NULL) {
+		lmc_hssi_set_clock(sc, sc->ictl.clock_source);
+		lmc_set_protocol(sc, NULL);
+
+		return;
+	}
+
+	/* check for change in clock source */
+	if (ctl->clock_source && !sc->ictl.clock_source) {
+		lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_INT);
+		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
+	} else if (!ctl->clock_source && sc->ictl.clock_source) {
+		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
+		lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+	}
+
+	lmc_set_protocol(sc, ctl);
+}
+
 /* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
-static int lmc_hssi_get_link_status(struct card * const sc)
+static inline int lmc_hssi_get_link_status(struct card * const sc)
 {
 	/* We're using the same code as SSI since they're practically
 	   the same */
@@ -226,6 +433,15 @@ static void lmc_hssi_watchdog(struct card * const =
sc)
 	/* HSSI is blank */
 }
=20
+static void lmc_hssi_default(struct card * const sc)
+{
+	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+	lmc_hssi_set_link_status(sc, LMC_LINK_DOWN);
+	lmc_hssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
+	lmc_hssi_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
+}
+
+
 /* DS3 methods */
=20
 /* Set cable length */
@@ -241,13 +457,17 @@ static void lmc_ds3_set_100ft(struct card * const=
 sc, int ie)
 	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-static void lmc_ds3_default(struct card * const sc)
+/* 1 =3D=3D DS3 payload scrambled, 0 =3D=3D not scrambled */
+static void lmc_ds3_set_scram(struct card * const sc, int ie)
 {
-	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
-
-	lmc_ds3_set_100ft(sc, LMC_CTL_CABLE_LENGTH_LT_100FT);
-	lmc_ds3_set_scram(sc, LMC_CTL_OFF);
-	lmc_ds3_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
+	if (ie =3D=3D LMC_CTL_ON) {
+		sc->lmc_miireg16 |=3D LMC_MII16_DS3_SCRAM;
+		sc->ictl.scrambler_onoff =3D LMC_CTL_ON;
+	} else {
+		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_SCRAM;
+		sc->ictl.scrambler_onoff =3D LMC_CTL_OFF;
+	}
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
 /* Given a user provided state, set ourselves up to match it.
@@ -305,19 +525,6 @@ static void lmc_ds3_init(struct card * const sc)
 	}
 }
=20
-/* 1 =3D=3D DS3 payload scrambled, 0 =3D=3D not scrambled */
-static void lmc_ds3_set_scram(struct card * const sc, int ie)
-{
-	if (ie =3D=3D LMC_CTL_ON) {
-		sc->lmc_miireg16 |=3D LMC_MII16_DS3_SCRAM;
-		sc->ictl.scrambler_onoff =3D LMC_CTL_ON;
-	} else {
-		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_SCRAM;
-		sc->ictl.scrambler_onoff =3D LMC_CTL_OFF;
-	}
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-}
-
 /* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
 static int lmc_ds3_get_link_status(struct card * const sc)
 {
@@ -339,390 +546,103 @@ static int lmc_ds3_get_link_status(struct card =
* const sc)
 	lmc_led_on(sc, LMC_DS3_LED2);
=20
 	if ((link_status & LMC_FRAMER_REG0_DLOS) ||
-	    (link_status & LMC_FRAMER_REG0_OOFS)) {
-		ret =3D 0;
-		if (sc->last_led_err[3] !=3D 1) {
-			u16 r1;
-
-			 /* Turn on Xbit error as our cisco does */
-			lmc_mii_writereg(sc, 0, 17, 01);
-			r1 =3D lmc_mii_readreg(sc, 0, 18);
-			r1 &=3D 0xfe;
-			lmc_mii_writereg(sc, 0, 18, r1);
-			printk(KERN_WARNING
-			       "%s: Red Alarm - Loss of Signal or Loss of Framing\n",
-			       sc->name);
-		}
-		lmc_led_on(sc, LMC_DS3_LED3);	/* turn on red LED */
-		sc->last_led_err[3] =3D 1;
-	} else {
-		lmc_led_off(sc, LMC_DS3_LED3);	/* turn on red LED */
-		if (sc->last_led_err[3] =3D=3D 1) {
-			u16 r1;
-			/* Turn off Xbit error */
-			lmc_mii_writereg(sc, 0, 17, 01);
-			r1 =3D lmc_mii_readreg(sc, 0, 18);
-			r1 |=3D 0x01;
-			lmc_mii_writereg(sc, 0, 18, r1);
-		}
-		sc->last_led_err[3] =3D 0;
-	}
-
-	lmc_mii_writereg(sc, 0, 17, 0x10);
-	link_status_11 =3D lmc_mii_readreg(sc, 0, 18);
-	if ((link_status & LMC_FRAMER_REG0_AIS) ||
-	   (link_status_11 & LMC_FRAMER_REG10_XBIT)) {
-		ret =3D 0;
-		if (sc->last_led_err[0] !=3D 1) {
-			printk(KERN_WARNING
-			       "%s: AIS Alarm or XBit Error\n", sc->name);
-			printk(KERN_WARNING
-			       "%s: Remote end has loss of signal or framing\n",
-			       sc->name);
-		}
-		lmc_led_on(sc, LMC_DS3_LED0);
-		sc->last_led_err[0] =3D 1;
-	} else {
-		lmc_led_off(sc, LMC_DS3_LED0);
-		sc->last_led_err[0] =3D 0;
-	}
-
-	lmc_mii_writereg(sc, 0, 17, 9);
-	link_status =3D lmc_mii_readreg(sc, 0, 18);
-
-	if (link_status & LMC_FRAMER_REG9_RBLUE) {
-		ret =3D 0;
-		if (sc->last_led_err[1] !=3D 1) {
-			printk(KERN_WARNING
-			       "%s: Blue Alarm - Receiving all 1's\n",
-			       sc->name);
-		}
-		lmc_led_on(sc, LMC_DS3_LED1);
-		sc->last_led_err[1] =3D 1;
-	} else {
-		lmc_led_off(sc, LMC_DS3_LED1);
-		sc->last_led_err[1] =3D 0;
-	}
-
-	return ret;
-}
-
-/* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
-static void lmc_ds3_set_crc_length(struct card * const sc, int state)
-{
-	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
-		/* 32 bit */
-		sc->lmc_miireg16 |=3D LMC_MII16_DS3_CRC;
-		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
-	} else {
-		/* 16 bit */
-		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_CRC;
-		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
-	}
-
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-}
-
-static void lmc_ds3_watchdog(struct card * const sc)
-{
-}
-
-
-/* SSI methods */
-
-static void lmc_ssi_init(struct card * const sc)
-{
-	u16 mii17;
-	int cable;
-
-	sc->ictl.cardtype =3D LMC_CTL_CARDTYPE_LMC1000;
-
-	mii17 =3D lmc_mii_readreg(sc, 0, 17);
-
-	cable =3D (mii17 & LMC_MII17_SSI_CABLE_MASK) >> LMC_MII17_SSI_CABLE_S=
HIFT;
-	sc->ictl.cable_type =3D cable;
-
-	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
-}
-
-static void lmc_ssi_default(struct card * const sc)
-{
-	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
-
-	/* make TXCLOCK always be an output */
-	lmc_gpio_mkoutput(sc, LMC_GEP_SSI_TXCLOCK);
-
-	lmc_ssi_set_link_status(sc, LMC_LINK_DOWN);
-	lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
-	lmc_ssi_set_speed(sc, NULL);
-	lmc_ssi_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
-}
-
-/* Given a user provided state, set ourselves up to match it.
-   This will always reset the card if needed. */
-static void lmc_ssi_set_status(struct card * const sc, struct control =
*ctl)
-{
-	if (ctl =3D=3D NULL) {
-		lmc_ssi_set_clock(sc, sc->ictl.clock_source);
-		lmc_ssi_set_speed(sc, &sc->ictl);
-		lmc_set_protocol(sc, NULL);
-		return;
-	}
-
-	/* check for change in clock source */
-	if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT
-	    && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
-		lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_INT);
-		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_INT;
-	} else if (ctl->clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_EXT
-		 && sc->ictl.clock_source =3D=3D LMC_CTL_CLOCK_SOURCE_INT) {
-		lmc_ssi_set_clock(sc, LMC_CTL_CLOCK_SOURCE_EXT);
-		sc->lmc_timing =3D LMC_CTL_CLOCK_SOURCE_EXT;
-	}
-
-	if (ctl->clock_rate !=3D sc->ictl.clock_rate)
-		lmc_ssi_set_speed(sc, ctl);
-
-	lmc_set_protocol(sc, ctl);
-}
-
-/* 1 =3D=3D internal, 0 =3D=3D external */
-static void lmc_ssi_set_clock(struct card * const sc, int ie)
-{
-	int old;
-	old =3D ie;
-	if (ie =3D=3D LMC_CTL_CLOCK_SOURCE_EXT) {
-		sc->lmc_gpio &=3D ~(LMC_GEP_SSI_TXCLOCK);
-		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_EXT;
-		if (ie !=3D old)
-			printk(LMC_PRINTF_FMT ": clock external\n",
-			       LMC_PRINTF_ARGS);
-	} else {
-		sc->lmc_gpio |=3D LMC_GEP_SSI_TXCLOCK;
-		LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-		sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
-		if (ie !=3D old)
-			printk(LMC_PRINTF_FMT ": clock internal\n",
-			       LMC_PRINTF_ARGS);
-	}
-}
-
-static void lmc_ssi_set_speed(struct card * const sc, struct control *=
ctl)
-{
-	struct control *ictl =3D &sc->ictl;
-	lmc_av9110_t *av;
-
-	/* original settings for clock rate of 100 Khz (8,25,0,0,2) were
-	   incorrect. They should have been 80,125,1,3,3. There are 17 param
-	   combinations to produce this freq. For 1.5 Mhz use 120,100,1,1,2
-	   (226 param. combinations) */
-	if (ctl =3D=3D NULL) {
-		av =3D &ictl->cardspec.ssi;
-		ictl->clock_rate =3D 1500000;
-		av->f =3D ictl->clock_rate;
-		av->n =3D 120;
-		av->m =3D 100;
-		av->v =3D 1;
-		av->x =3D 1;
-		av->r =3D 2;
-		write_av9110(sc, av->n, av->m, av->v, av->x, av->r);
-		return;
-	}
-
-	av =3D &ctl->cardspec.ssi;
-
-	if (av->f =3D=3D 0)
-		return;
-
-	ictl->clock_rate =3D av->f;	/* really, this is the rate we are */
-	ictl->cardspec.ssi =3D *av;
-
-	write_av9110(sc, av->n, av->m, av->v, av->x, av->r);
-}
-
-/* Return hardware link status. 0 =3D=3D link is down, 1 =3D=3D link i=
s up. */
-static int lmc_ssi_get_link_status(struct card * const sc)
-{
-	u16 link_status;
-	u32 ticks;
-	int ret =3D 1;
-	int hw_hdsk =3D 1;
-
-	/* missing CTS?  Hmm.  If we require CTS on, we may never get the
-	   link to come up, so omit it in this test.
-
-	   Also, it seems that with a loopback cable, DCD isn't asserted,
-	   so just check for things like this:
-	   - DSR _must_ be asserted.
-	   - One of DCD or CTS must be asserted. */
-
-	/* LMC 1000 (SSI) LED definitions
-	   - led0 green =3D power to adapter, Gate Array loaded & driver atta=
ched
-	   - led1 green =3D DSR and DTR and RTS and CTS are set
-	   - led2 green =3D Cable detected
-	   - led3 red   =3D No timing is available from the cable or the on-b=
oard
-			  frequency generator. */
-
-	link_status =3D lmc_mii_readreg(sc, 0, 16);
-
-	/* Is the transmit clock still available */
-	ticks =3D LMC_CSR_READ(sc, csr_gp_timer);
-	ticks =3D 0x0000ffff - (ticks & 0x0000ffff);
-
-	lmc_led_on(sc, LMC_MII16_LED0);
-
-	/* transmit clock determination */
-	if (sc->lmc_timing =3D=3D LMC_CTL_CLOCK_SOURCE_INT)
-		lmc_led_off(sc, LMC_MII16_LED3);
-	else if (ticks =3D=3D 0) {	/* no clock found ? */
+	    (link_status & LMC_FRAMER_REG0_OOFS)) {
 		ret =3D 0;
 		if (sc->last_led_err[3] !=3D 1) {
-			sc->extra_stats.tx_lossOfClockCnt++;
-			printk(KERN_WARNING "%s: Lost Clock, Link Down\n",
+			u16 r1;
+
+			 /* Turn on Xbit error as our cisco does */
+			lmc_mii_writereg(sc, 0, 17, 01);
+			r1 =3D lmc_mii_readreg(sc, 0, 18);
+			r1 &=3D 0xfe;
+			lmc_mii_writereg(sc, 0, 18, r1);
+			printk(KERN_WARNING
+			       "%s: Red Alarm - Loss of Signal or Loss of Framing\n",
 			       sc->name);
 		}
+		lmc_led_on(sc, LMC_DS3_LED3);	/* turn on red LED */
 		sc->last_led_err[3] =3D 1;
-		lmc_led_on(sc, LMC_MII16_LED3);	/* turn ON red LED */
 	} else {
-		if (sc->last_led_err[3] =3D=3D 1)
-			printk(KERN_WARNING "%s: Clock Returned\n", sc->name);
+		lmc_led_off(sc, LMC_DS3_LED3);	/* turn on red LED */
+		if (sc->last_led_err[3] =3D=3D 1) {
+			u16 r1;
+			/* Turn off Xbit error */
+			lmc_mii_writereg(sc, 0, 17, 01);
+			r1 =3D lmc_mii_readreg(sc, 0, 18);
+			r1 |=3D 0x01;
+			lmc_mii_writereg(sc, 0, 18, r1);
+		}
 		sc->last_led_err[3] =3D 0;
-		lmc_led_off(sc, LMC_MII16_LED3); /* turn OFF red LED */
 	}
=20
-	if ((link_status & LMC_MII16_SSI_DSR) =3D=3D 0) { /* Also HSSI CA */
+	lmc_mii_writereg(sc, 0, 17, 0x10);
+	link_status_11 =3D lmc_mii_readreg(sc, 0, 18);
+	if ((link_status & LMC_FRAMER_REG0_AIS) ||
+	   (link_status_11 & LMC_FRAMER_REG10_XBIT)) {
 		ret =3D 0;
-		hw_hdsk =3D 0;
+		if (sc->last_led_err[0] !=3D 1) {
+			printk(KERN_WARNING
+			       "%s: AIS Alarm or XBit Error\n", sc->name);
+			printk(KERN_WARNING
+			       "%s: Remote end has loss of signal or framing\n",
+			       sc->name);
+		}
+		lmc_led_on(sc, LMC_DS3_LED0);
+		sc->last_led_err[0] =3D 1;
+	} else {
+		lmc_led_off(sc, LMC_DS3_LED0);
+		sc->last_led_err[0] =3D 0;
 	}
=20
-#ifdef CONFIG_LMC_IGNORE_HARDWARE_HANDSHAKE
-	if ((link_status & (LMC_MII16_SSI_CTS | LMC_MII16_SSI_DCD)) =3D=3D 0)=
 {
-		ret =3D 0;
-		hw_hdsk =3D 0;
-	}
-#endif
+	lmc_mii_writereg(sc, 0, 17, 9);
+	link_status =3D lmc_mii_readreg(sc, 0, 18);
=20
-	if (hw_hdsk =3D=3D 0) {
-		if (sc->last_led_err[1] !=3D 1)
-			printk(KERN_WARNING "%s: DSR not asserted\n", sc->name);
+	if (link_status & LMC_FRAMER_REG9_RBLUE) {
+		ret =3D 0;
+		if (sc->last_led_err[1] !=3D 1) {
+			printk(KERN_WARNING
+			       "%s: Blue Alarm - Receiving all 1's\n",
+			       sc->name);
+		}
+		lmc_led_on(sc, LMC_DS3_LED1);
 		sc->last_led_err[1] =3D 1;
-		lmc_led_off(sc, LMC_MII16_LED1);
 	} else {
-		if (sc->last_led_err[1] !=3D 0)
-			printk(KERN_WARNING "%s: DSR now asserted\n", sc->name);
+		lmc_led_off(sc, LMC_DS3_LED1);
 		sc->last_led_err[1] =3D 0;
-		lmc_led_on(sc, LMC_MII16_LED1);
 	}
=20
-	if (ret =3D=3D 1)
-		lmc_led_on(sc, LMC_MII16_LED2); /* Over all good status? */
-
 	return ret;
 }
=20
-static void lmc_ssi_set_link_status(struct card * const sc, int state)
-{
-	if (state =3D=3D LMC_LINK_UP) {
-		sc->lmc_miireg16 |=3D (LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
-		printk(LMC_PRINTF_FMT ": asserting DTR and RTS\n",
-		       LMC_PRINTF_ARGS);
-	} else {
-		sc->lmc_miireg16 &=3D ~(LMC_MII16_SSI_DTR | LMC_MII16_SSI_RTS);
-		printk(LMC_PRINTF_FMT ": deasserting DTR and RTS\n",
-		       LMC_PRINTF_ARGS);
-	}
-
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-
-}
-
 /* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
-static void lmc_ssi_set_crc_length(struct card * const sc, int state)
+static void lmc_ds3_set_crc_length(struct card * const sc, int state)
 {
 	if (state =3D=3D LMC_CTL_CRC_LENGTH_32) {
 		/* 32 bit */
-		sc->lmc_miireg16 |=3D LMC_MII16_SSI_CRC;
+		sc->lmc_miireg16 |=3D LMC_MII16_DS3_CRC;
 		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_32;
-		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_4;
-
 	} else {
 		/* 16 bit */
-		sc->lmc_miireg16 &=3D ~LMC_MII16_SSI_CRC;
+		sc->lmc_miireg16 &=3D ~LMC_MII16_DS3_CRC;
 		sc->ictl.crc_length =3D LMC_CTL_CRC_LENGTH_16;
-		sc->lmc_crcSize =3D LMC_CTL_CRC_BYTESIZE_2;
 	}
=20
 	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
 }
=20
-/* These are bits to program the ssi frequency generator */
-static inline void write_av9110_bit(struct card *sc, int c)
+static void lmc_ds3_watchdog(struct card * const sc)
 {
-	/* set the data bit as we need it. */
-	sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
-	if (c & 0x01)
-		sc->lmc_gpio |=3D LMC_GEP_DATA;
-	else
-		sc->lmc_gpio &=3D ~(LMC_GEP_DATA);
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-
-	/* set the clock to high */
-	sc->lmc_gpio |=3D LMC_GEP_CLK;
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-
-	/* set the clock to low again. */
-	sc->lmc_gpio &=3D ~(LMC_GEP_CLK);
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
 }
=20
-static void write_av9110(struct card *sc, u32 n, u32 m, u32 v, u32 x, =
u32 r)
+static void lmc_ds3_default(struct card * const sc)
 {
-	int i;
-
-#if 0
-	printk(LMC_PRINTF_FMT ": speed %u, %d %d %d %d %d\n",
-	       LMC_PRINTF_ARGS, sc->ictl.clock_rate, n, m, v, x, r);
-#endif
-
-	sc->lmc_gpio |=3D LMC_GEP_SSI_GENERATOR;
-	sc->lmc_gpio &=3D ~(LMC_GEP_DATA | LMC_GEP_CLK);
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-
-	/* Set the TXCLOCK, GENERATOR, SERIAL, and SERIALCLK as outputs. */
-	lmc_gpio_mkoutput(sc, (LMC_GEP_DATA | LMC_GEP_CLK
-				| LMC_GEP_SSI_GENERATOR));
-
-	sc->lmc_gpio &=3D ~(LMC_GEP_SSI_GENERATOR);
-	LMC_CSR_WRITE(sc, csr_gp, sc->lmc_gpio);
-
-	/* a shifting we will go... */
-	for (i =3D 0; i < 7; i++)
-		write_av9110_bit(sc, n >> i);
-	for (i =3D 0; i < 7; i++)
-		write_av9110_bit(sc, m >> i);
-	for (i =3D 0; i < 1; i++)
-		write_av9110_bit(sc, v >> i);
-	for (i =3D 0; i < 2; i++)
-		write_av9110_bit(sc, x >> i);
-	for (i =3D 0; i < 2; i++)
-		write_av9110_bit(sc, r >> i);
-	for (i =3D 0; i < 5; i++)
-		write_av9110_bit(sc, 0x17 >> i);
+	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
=20
-	/* stop driving serial-related signals */
-	lmc_gpio_mkinput(sc, (LMC_GEP_DATA | LMC_GEP_CLK |
-			      LMC_GEP_SSI_GENERATOR));
+	lmc_ds3_set_100ft(sc, LMC_CTL_CABLE_LENGTH_LT_100FT);
+	lmc_ds3_set_scram(sc, LMC_CTL_OFF);
+	lmc_ds3_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
 }
=20
-static void lmc_ssi_watchdog(struct card * const sc)
-{
-	u16 mii17 =3D lmc_mii_readreg(sc, 0, 17);
-	if (((mii17 >> 3) & 7) =3D=3D 7)
-		lmc_led_off(sc, LMC_MII16_LED2);
-	else
-		lmc_led_on(sc, LMC_MII16_LED2);
-}
=20
 /* T1 methods */
=20
@@ -742,6 +662,21 @@ static int lmc_t1_read(struct card * const sc, int=
 a)
 }
 */
=20
+/* 1 =3D=3D T1 Circuit Type , 0 =3D=3D E1 Circuit Type */
+static void lmc_t1_set_circuit_type(struct card * const sc, int ie)
+{
+	if (ie =3D=3D LMC_CTL_CIRCUIT_TYPE_T1) {
+		sc->lmc_miireg16 |=3D LMC_MII16_T1_Z;
+		sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_T1;
+		printk(KERN_INFO "%s: In T1 Mode\n", sc->name);
+	} else {
+		sc->lmc_miireg16 &=3D ~LMC_MII16_T1_Z;
+		sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_E1;
+		printk(KERN_INFO "%s: In E1 Mode\n", sc->name);
+	}
+
+	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
+}
=20
 static void lmc_t1_init(struct card * const sc)
 {
@@ -802,14 +737,6 @@ static void lmc_t1_init(struct card * const sc)
 	sc->lmc_miireg16 =3D mii16;
 }
=20
-static void lmc_t1_default(struct card * const sc)
-{
-	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
-	lmc_t1_set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
-	lmc_t1_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
-	/* Right now we can only clock from out internal source */
-	sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
-}
 /* Given a user provided state, set ourselves up to match it.
    This will always reset the card if needed. */
 static void lmc_t1_set_status(struct card * const sc, struct control *=
ctl)
@@ -939,22 +866,6 @@ static int lmc_t1_get_link_status(struct card * co=
nst sc)
 	return ret;
 }
=20
-/* 1 =3D=3D T1 Circuit Type , 0 =3D=3D E1 Circuit Type */
-static void lmc_t1_set_circuit_type(struct card * const sc, int ie)
-{
-	if (ie =3D=3D LMC_CTL_CIRCUIT_TYPE_T1) {
-		sc->lmc_miireg16 |=3D LMC_MII16_T1_Z;
-		sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_T1;
-		printk(KERN_INFO "%s: In T1 Mode\n", sc->name);
-	} else {
-		sc->lmc_miireg16 &=3D ~LMC_MII16_T1_Z;
-		sc->ictl.circuit_type =3D LMC_CTL_CIRCUIT_TYPE_E1;
-		printk(KERN_INFO "%s: In E1 Mode\n", sc->name);
-	}
-
-	lmc_mii_writereg(sc, 0, 16, sc->lmc_miireg16);
-}
-
 /* 0 =3D=3D 16bit, 1 =3D=3D 32bit */
 static void lmc_t1_set_crc_length(struct card * const sc, int state)
 {
@@ -1000,8 +911,57 @@ static void lmc_t1_watchdog(struct card * const s=
c)
 {
 }
=20
-static void lmc_set_protocol(struct card * const sc, struct control *c=
tl)
+static void lmc_t1_default(struct card * const sc)
 {
-	if (!ctl)
-		sc->ictl.keepalive_onoff =3D LMC_CTL_ON;
+	sc->lmc_miireg16 =3D LMC_MII16_LED_ALL;
+	lmc_t1_set_circuit_type(sc, LMC_CTL_CIRCUIT_TYPE_T1);
+	lmc_t1_set_crc_length(sc, LMC_CTL_CRC_LENGTH_16);
+	/* Right now we can only clock from out internal source */
+	sc->ictl.clock_source =3D LMC_CTL_CLOCK_SOURCE_INT;
 }
+
+
+struct media lmc_ssi_media =3D {
+	.init =3D lmc_ssi_init,
+	.defaults =3D lmc_ssi_default,
+	.set_status =3D lmc_ssi_set_status,
+	.set_clock_source =3D lmc_ssi_set_clock,
+	.set_speed =3D lmc_ssi_set_speed,
+	.get_link_status =3D lmc_ssi_get_link_status,
+	.set_link_status =3D lmc_ssi_set_link_status,
+	.set_crc_length =3D lmc_ssi_set_crc_length,
+	.watchdog =3D lmc_ssi_watchdog,
+};
+
+struct media lmc_hssi_media =3D {
+	.init =3D lmc_hssi_init,
+	.defaults =3D lmc_hssi_default,
+	.set_status =3D lmc_hssi_set_status,
+	.set_clock_source =3D lmc_hssi_set_clock,
+	.get_link_status =3D lmc_hssi_get_link_status,
+	.set_link_status =3D lmc_hssi_set_link_status,
+	.set_crc_length =3D lmc_hssi_set_crc_length,
+	.watchdog =3D lmc_hssi_watchdog,
+};
+
+struct media lmc_ds3_media =3D {
+	.init =3D lmc_ds3_init,
+	.defaults =3D lmc_ds3_default,
+	.set_status =3D lmc_ds3_set_status,
+	.set_cable_length =3D lmc_ds3_set_100ft,
+	.set_scrambler =3D lmc_ds3_set_scram,
+	.get_link_status =3D lmc_ds3_get_link_status,
+	.set_crc_length =3D lmc_ds3_set_crc_length,
+	.watchdog =3D lmc_ds3_watchdog,
+};
+
+struct media lmc_t1_media =3D {
+	.init =3D lmc_t1_init,
+	.defaults =3D lmc_t1_default,
+	.set_status =3D lmc_t1_set_status,
+	.set_clock_source =3D lmc_t1_set_clock,
+	.get_link_status =3D lmc_t1_get_link_status,
+	.set_crc_length =3D lmc_t1_set_crc_length,
+	.set_circuit_type =3D lmc_t1_set_circuit_type,
+	.watchdog =3D lmc_t1_watchdog,
+};
--=20
1.7.1.1

