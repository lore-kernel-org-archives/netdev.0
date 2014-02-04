From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH] dp83640: Support a configurable number of periodic outputs
Date: Tue,  4 Feb 2014 09:52:22 +0100
Message-ID: <1391503942-694-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:48760 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750937AbaBDIxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 03:53:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver is currently limited to a single periodic output.
This patch makes the number of peridodic output dynamic by
dropping the gpio_tab module parameter and adding cal_gpio,
perout_gpio_tab and extts_gpio_tabs parameters.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 70 ++++++++++++++++++++-------------------=
--------
 1 file changed, 30 insertions(+), 40 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 547725f..0a54c79 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -38,15 +38,11 @@
 #define LAYER4		0x02
 #define LAYER2		0x01
 #define MAX_RXTS	64
-#define N_EXT_TS	6
 #define PSF_PTPVER	2
 #define PSF_EVNT	0x4000
 #define PSF_RX		0x2000
 #define PSF_TX		0x1000
-#define EXT_EVENT	1
-#define CAL_EVENT	7
-#define CAL_TRIGGER	7
-#define PER_TRIGGER	6
+#define N_EXT		8
=20
 #define MII_DP83640_MICR 0x11
 #define MII_DP83640_MISR 0x12
@@ -148,30 +144,23 @@ struct dp83640_clock {
=20
 /* globals */
=20
-enum {
-	CALIBRATE_GPIO,
-	PEROUT_GPIO,
-	EXTTS0_GPIO,
-	EXTTS1_GPIO,
-	EXTTS2_GPIO,
-	EXTTS3_GPIO,
-	EXTTS4_GPIO,
-	EXTTS5_GPIO,
-	GPIO_TABLE_SIZE
-};
-
 static int chosen_phy =3D -1;
-static ushort gpio_tab[GPIO_TABLE_SIZE] =3D {
-	1, 2, 3, 4, 8, 9, 10, 11
-};
+static int cal_gpio =3D 1;
+static int perout_gpio_tab[N_EXT] =3D {2};
+static int n_perout =3D 1;
+static int extts_gpio_tab[N_EXT] =3D {3, 4, 8, 9, 10, 11};
+static int n_extts =3D 6;
=20
 module_param(chosen_phy, int, 0444);
-module_param_array(gpio_tab, ushort, NULL, 0444);
+module_param(cal_gpio, int, 0444);
+module_param_array(perout_gpio_tab, int, &n_perout, 0444);
+module_param_array(extts_gpio_tab, int, &n_extts, 0444);
=20
 MODULE_PARM_DESC(chosen_phy, \
 	"The address of the PHY to use for the ancillary clock features");
-MODULE_PARM_DESC(gpio_tab, \
-	"Which GPIO line to use for which purpose: cal,perout,extts1,...,extt=
s6");
+MODULE_PARM_DESC(cal_gpio, "Which GPIO line to use for calibration");
+MODULE_PARM_DESC(perout_gpio_tab, "Which GPIO lines to use for periodi=
c output");
+MODULE_PARM_DESC(extts_gpio_tab, "Which GPIO lines to use for external=
 timestamping");
=20
 /* a list of clocks and a mutex to protect it */
 static LIST_HEAD(phyter_clocks);
@@ -267,15 +256,16 @@ static u64 phy2txts(struct phy_txts *p)
 }
=20
 static void periodic_output(struct dp83640_clock *clock,
-			    struct ptp_clock_request *clkreq, bool on)
+			    struct ptp_clock_request *clkreq,
+			    int index, bool on)
 {
 	struct dp83640_private *dp83640 =3D clock->chosen;
 	struct phy_device *phydev =3D dp83640->phydev;
 	u32 sec, nsec, period;
 	u16 gpio, ptp_trig, trigger, val;
=20
-	gpio =3D on ? gpio_tab[PEROUT_GPIO] : 0;
-	trigger =3D PER_TRIGGER;
+	gpio =3D on ? perout_gpio_tab[index] : 0;
+	trigger =3D n_extts + index;
=20
 	ptp_trig =3D TRIG_WR |
 		(trigger & TRIG_CSEL_MASK) << TRIG_CSEL_SHIFT |
@@ -430,12 +420,12 @@ static int ptp_dp83640_enable(struct ptp_clock_in=
fo *ptp,
 	switch (rq->type) {
 	case PTP_CLK_REQ_EXTTS:
 		index =3D rq->extts.index;
-		if (index < 0 || index >=3D N_EXT_TS)
+		if (index < 0 || index >=3D n_extts)
 			return -EINVAL;
-		event_num =3D EXT_EVENT + index;
+		event_num =3D index;
 		evnt =3D EVNT_WR | (event_num & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
 		if (on) {
-			gpio_num =3D gpio_tab[EXTTS0_GPIO + index];
+			gpio_num =3D extts_gpio_tab[index];
 			evnt |=3D (gpio_num & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
 			evnt |=3D EVNT_RISE;
 		}
@@ -443,9 +433,10 @@ static int ptp_dp83640_enable(struct ptp_clock_inf=
o *ptp,
 		return 0;
=20
 	case PTP_CLK_REQ_PEROUT:
-		if (rq->perout.index !=3D 0)
+		index =3D rq->perout.index;
+		if (index < 0 || index >=3D n_perout)
 			return -EINVAL;
-		periodic_output(clock, rq, on);
+		periodic_output(clock, rq, index, on);
 		return 0;
=20
 	default:
@@ -538,10 +529,9 @@ static void recalibrate(struct dp83640_clock *cloc=
k)
 	struct list_head *this;
 	struct dp83640_private *tmp;
 	struct phy_device *master =3D clock->chosen->phydev;
-	u16 cal_gpio, cfg0, evnt, ptp_trig, trigger, val;
+	u16 cfg0, evnt, ptp_trig, trigger, val;
=20
-	trigger =3D CAL_TRIGGER;
-	cal_gpio =3D gpio_tab[CALIBRATE_GPIO];
+	trigger =3D n_extts + n_perout;
=20
 	mutex_lock(&clock->extreg_lock);
=20
@@ -564,7 +554,7 @@ static void recalibrate(struct dp83640_clock *clock=
)
 	 * enable an event timestamp
 	 */
 	evnt =3D EVNT_WR | EVNT_RISE | EVNT_SINGLE;
-	evnt |=3D (CAL_EVENT & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
+	evnt |=3D (trigger & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
 	evnt |=3D (cal_gpio & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
=20
 	list_for_each(this, &clock->phylist) {
@@ -642,7 +632,7 @@ static void recalibrate(struct dp83640_clock *clock=
)
=20
 static inline u16 exts_chan_to_edata(int ch)
 {
-	return 1 << ((ch + EXT_EVENT) * 2);
+	return 1 << ((ch) * 2);
 }
=20
 static int decode_evnt(struct dp83640_private *dp83640,
@@ -676,14 +666,14 @@ static int decode_evnt(struct dp83640_private *dp=
83640,
 		parsed =3D words + 2;
 	} else {
 		parsed =3D words + 1;
-		i =3D ((ests >> EVNT_NUM_SHIFT) & EVNT_NUM_MASK) - EXT_EVENT;
+		i =3D ((ests >> EVNT_NUM_SHIFT) & EVNT_NUM_MASK);
 		ext_status =3D exts_chan_to_edata(i);
 	}
=20
 	event.type =3D PTP_CLOCK_EXTTS;
 	event.timestamp =3D phy2txts(&dp83640->edata);
=20
-	for (i =3D 0; i < N_EXT_TS; i++) {
+	for (i =3D 0; i < n_extts; i++) {
 		if (ext_status & exts_chan_to_edata(i)) {
 			event.index =3D i;
 			ptp_clock_event(dp83640->clock->ptp_clock, &event);
@@ -889,8 +879,8 @@ static void dp83640_clock_init(struct dp83640_clock=
 *clock, struct mii_bus *bus)
 	sprintf(clock->caps.name, "dp83640 timer");
 	clock->caps.max_adj	=3D 1953124;
 	clock->caps.n_alarm	=3D 0;
-	clock->caps.n_ext_ts	=3D N_EXT_TS;
-	clock->caps.n_per_out	=3D 1;
+	clock->caps.n_ext_ts	=3D n_extts;
+	clock->caps.n_per_out	=3D n_perout;
 	clock->caps.pps		=3D 0;
 	clock->caps.adjfreq	=3D ptp_dp83640_adjfreq;
 	clock->caps.adjtime	=3D ptp_dp83640_adjtime;
--=20
1.8.5.3
