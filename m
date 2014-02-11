From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v2 1/2] dp83640: Support a configurable number of periodic outputs
Date: Tue, 11 Feb 2014 16:29:21 +0100
Message-ID: <1392132562-23644-2-git-send-email-stefan.sorensen@spectralink.com>
References: <1392132562-23644-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, grant.likely@linaro.org,
	robh+dt@kernel.org, mark.rutland@arm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392132562-23644-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver is currently limited to a single periodic output. This patch=
 makes
the number of peridodic output dynamic by dropping the gpio_tab module
parameter and adding calibrate_pin, perout_pins, and extts_pins paramet=
ers.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/phy/dp83640.c | 75 ++++++++++++++++++++-------------------=
--------
 1 file changed, 32 insertions(+), 43 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 547725f..d4fe95d 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -38,15 +38,11 @@
 #define LAYER4		0x02
 #define LAYER2		0x01
 #define MAX_RXTS	64
-#define N_EXT_TS	6
+#define N_EXT		8
 #define PSF_PTPVER	2
 #define PSF_EVNT	0x4000
 #define PSF_RX		0x2000
 #define PSF_TX		0x1000
-#define EXT_EVENT	1
-#define CAL_EVENT	7
-#define CAL_TRIGGER	7
-#define PER_TRIGGER	6
=20
 #define MII_DP83640_MICR 0x11
 #define MII_DP83640_MISR 0x12
@@ -146,32 +142,24 @@ struct dp83640_clock {
 	struct ptp_clock *ptp_clock;
 };
=20
-/* globals */
-
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
=20
 static int chosen_phy =3D -1;
-static ushort gpio_tab[GPIO_TABLE_SIZE] =3D {
-	1, 2, 3, 4, 8, 9, 10, 11
-};
+static int calibrate_pin =3D 1;
+static int perout_pins[N_EXT] =3D {2};
+static int n_per_out =3D 1;
+static int extts_pins[N_EXT] =3D {3, 4, 8, 9, 10, 11};
+static int n_ext_ts =3D 6;
=20
 module_param(chosen_phy, int, 0444);
-module_param_array(gpio_tab, ushort, NULL, 0444);
+module_param(calibrate_pin, int, 0444);
+module_param_array(perout_pins, int, &n_per_out, 0444);
+module_param_array(extts_pins, int, &n_ext_ts, 0444);
=20
 MODULE_PARM_DESC(chosen_phy, \
 	"The address of the PHY to use for the ancillary clock features");
-MODULE_PARM_DESC(gpio_tab, \
-	"Which GPIO line to use for which purpose: cal,perout,extts1,...,extt=
s6");
+MODULE_PARM_DESC(calibrate_pin, "Which pin to use for calibration");
+MODULE_PARM_DESC(perout_pins, "Which pins to use for periodic output")=
;
+MODULE_PARM_DESC(extts_pins, "Which pins to use for external timestamp=
ing");
=20
 /* a list of clocks and a mutex to protect it */
 static LIST_HEAD(phyter_clocks);
@@ -267,15 +255,16 @@ static u64 phy2txts(struct phy_txts *p)
 }
=20
 static void periodic_output(struct dp83640_clock *clock,
-			    struct ptp_clock_request *clkreq, bool on)
+			    struct ptp_clock_request *clkreq, int index,
+			    bool on)
 {
 	struct dp83640_private *dp83640 =3D clock->chosen;
 	struct phy_device *phydev =3D dp83640->phydev;
 	u32 sec, nsec, period;
 	u16 gpio, ptp_trig, trigger, val;
=20
-	gpio =3D on ? gpio_tab[PEROUT_GPIO] : 0;
-	trigger =3D PER_TRIGGER;
+	gpio =3D on ? perout_pins[index] : 0;
+	trigger =3D n_ext_ts + index;
=20
 	ptp_trig =3D TRIG_WR |
 		(trigger & TRIG_CSEL_MASK) << TRIG_CSEL_SHIFT |
@@ -430,12 +419,12 @@ static int ptp_dp83640_enable(struct ptp_clock_in=
fo *ptp,
 	switch (rq->type) {
 	case PTP_CLK_REQ_EXTTS:
 		index =3D rq->extts.index;
-		if (index < 0 || index >=3D N_EXT_TS)
+		if (index < 0 || index >=3D n_ext_ts)
 			return -EINVAL;
-		event_num =3D EXT_EVENT + index;
+		event_num =3D index;
 		evnt =3D EVNT_WR | (event_num & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
 		if (on) {
-			gpio_num =3D gpio_tab[EXTTS0_GPIO + index];
+			gpio_num =3D extts_pins[index];
 			evnt |=3D (gpio_num & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
 			evnt |=3D EVNT_RISE;
 		}
@@ -443,9 +432,10 @@ static int ptp_dp83640_enable(struct ptp_clock_inf=
o *ptp,
 		return 0;
=20
 	case PTP_CLK_REQ_PEROUT:
-		if (rq->perout.index !=3D 0)
+		index =3D rq->perout.index;
+		if (index < 0 || index >=3D n_per_out)
 			return -EINVAL;
-		periodic_output(clock, rq, on);
+		periodic_output(clock, rq, index, on);
 		return 0;
=20
 	default:
@@ -538,10 +528,9 @@ static void recalibrate(struct dp83640_clock *cloc=
k)
 	struct list_head *this;
 	struct dp83640_private *tmp;
 	struct phy_device *master =3D clock->chosen->phydev;
-	u16 cal_gpio, cfg0, evnt, ptp_trig, trigger, val;
+	u16 cfg0, evnt, ptp_trig, trigger, val;
=20
-	trigger =3D CAL_TRIGGER;
-	cal_gpio =3D gpio_tab[CALIBRATE_GPIO];
+	trigger =3D n_ext_ts + n_per_out;
=20
 	mutex_lock(&clock->extreg_lock);
=20
@@ -564,8 +553,8 @@ static void recalibrate(struct dp83640_clock *clock=
)
 	 * enable an event timestamp
 	 */
 	evnt =3D EVNT_WR | EVNT_RISE | EVNT_SINGLE;
-	evnt |=3D (CAL_EVENT & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
-	evnt |=3D (cal_gpio & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
+	evnt |=3D (trigger & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
+	evnt |=3D (calibrate_pin & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
=20
 	list_for_each(this, &clock->phylist) {
 		tmp =3D list_entry(this, struct dp83640_private, list);
@@ -578,7 +567,7 @@ static void recalibrate(struct dp83640_clock *clock=
)
 	 */
 	ptp_trig =3D TRIG_WR | TRIG_IF_LATE | TRIG_PULSE;
 	ptp_trig |=3D (trigger  & TRIG_CSEL_MASK) << TRIG_CSEL_SHIFT;
-	ptp_trig |=3D (cal_gpio & TRIG_GPIO_MASK) << TRIG_GPIO_SHIFT;
+	ptp_trig |=3D (calibrate_pin & TRIG_GPIO_MASK) << TRIG_GPIO_SHIFT;
 	ext_write(0, master, PAGE5, PTP_TRIG, ptp_trig);
=20
 	/* load trigger */
@@ -642,7 +631,7 @@ static void recalibrate(struct dp83640_clock *clock=
)
=20
 static inline u16 exts_chan_to_edata(int ch)
 {
-	return 1 << ((ch + EXT_EVENT) * 2);
+	return 1 << ((ch) * 2);
 }
=20
 static int decode_evnt(struct dp83640_private *dp83640,
@@ -676,14 +665,14 @@ static int decode_evnt(struct dp83640_private *dp=
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
+	for (i =3D 0; i < n_ext_ts; i++) {
 		if (ext_status & exts_chan_to_edata(i)) {
 			event.index =3D i;
 			ptp_clock_event(dp83640->clock->ptp_clock, &event);
@@ -889,8 +878,8 @@ static void dp83640_clock_init(struct dp83640_clock=
 *clock, struct mii_bus *bus)
 	sprintf(clock->caps.name, "dp83640 timer");
 	clock->caps.max_adj	=3D 1953124;
 	clock->caps.n_alarm	=3D 0;
-	clock->caps.n_ext_ts	=3D N_EXT_TS;
-	clock->caps.n_per_out	=3D 1;
+	clock->caps.n_ext_ts	=3D n_ext_ts;
+	clock->caps.n_per_out	=3D n_per_out;
 	clock->caps.pps		=3D 0;
 	clock->caps.adjfreq	=3D ptp_dp83640_adjfreq;
 	clock->caps.adjtime	=3D ptp_dp83640_adjtime;
--=20
1.8.5.3
