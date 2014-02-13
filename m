From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v3 3/3] net:phy:dp83640: Get pin and master/slave configuration from DT
Date: Thu, 13 Feb 2014 15:35:25 +0100
Message-ID: <1392302129-24947-4-git-send-email-stefan.sorensen@spectralink.com>
References: <1392302129-24947-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, grant.likely@linaro.org,
	robh+dt@kernel.org, mark.rutland@arm.com,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392302129-24947-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds configuration of the periodic output and external times=
tamp
pins available on the dp83640 family of PHYs. It also configures the
master/slave relationship in a group of PHYs on the same MDIO bus and t=
he pins
used for clock calibration in the group.

The configuration is retrieved from DT through the properties
    dp83640,slave
    dp83640,calibrate-pin
    dp83640,perout-pins
    dp83640,extts-pins
The configuration module parameters are retained as fallback for the no=
n-DT
case.

Since the pin configuration is now stored for each clock device, groups=
 of
devices on different mdio busses can now have different pin configurati=
ons.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 Documentation/devicetree/bindings/net/dp83640.txt |  29 +++++
 drivers/net/phy/dp83640.c                         | 139 ++++++++++++++=
++++----
 2 files changed, 143 insertions(+), 25 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dp83640.txt

diff --git a/Documentation/devicetree/bindings/net/dp83640.txt b/Docume=
ntation/devicetree/bindings/net/dp83640.txt
new file mode 100644
index 0000000..b9a57c0
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/dp83640.txt
@@ -0,0 +1,29 @@
+Required properties for the National DP83640 ethernet phy:
+
+- compatible : Must contain "national,dp83640"
+
+Optional properties:
+
+- dp83640,slave: If present, this phy will be slave to another dp83640
+  on the same mdio bus.
+- dp83640,perout-pins : List of the pin pins used for periodic output
+  triggers.
+- dp83640,extts-pins : List of the pin pins used for external event
+  timestamping.
+- dp83640,calibrate-pin : The pin used for master/slave calibration.
+
+Example:
+
+	ethernet-phy@1 {
+		compatible =3D "national,dp83640", "ethernet-phy-ieee802.3-c22";
+		reg =3D <1>;
+		dp83640,perout-pins =3D <2>;
+		dp83640,extts-pins =3D <3 4 8 9 10 11>;
+		dp83640,calibrate-pin =3D <1>;
+	};
+
+	ethernet-phy@2 {
+		compatible =3D "national,dp83640", "ethernet-phy-ieee802.3-c22";
+		reg =3D <2>;
+		dp83640,slave;
+	};
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 28a6e1d..077bdc2 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -30,6 +30,7 @@
 #include <linux/phy.h>
 #include <linux/ptp_classify.h>
 #include <linux/ptp_clock_kernel.h>
+#include <linux/of_device.h>
=20
 #include "dp83640_reg.h"
=20
@@ -120,6 +121,8 @@ struct dp83640_private {
 	/* queues of incoming and outgoing packets */
 	struct sk_buff_head rx_queue;
 	struct sk_buff_head tx_queue;
+	/* is this phyter a slave */
+	bool slave;
 };
=20
 struct dp83640_clock {
@@ -141,6 +144,7 @@ struct dp83640_clock {
 	struct list_head phylist;
 	/* reference to our PTP hardware clock */
 	struct ptp_clock *ptp_clock;
+	u32 perout_pins[N_EXT], extts_pins[N_EXT], calibrate_pin;
 };
=20
=20
@@ -264,7 +268,7 @@ static void periodic_output(struct dp83640_clock *c=
lock,
 	u32 sec, nsec, period;
 	u16 gpio, ptp_trig, val;
=20
-	gpio =3D on ? perout_pins[trigger] : 0;
+	gpio =3D on ? clock->perout_pins[trigger] : 0;
=20
 	ptp_trig =3D TRIG_WR |
 		(trigger & TRIG_CSEL_MASK) << TRIG_CSEL_SHIFT |
@@ -435,12 +439,12 @@ static int ptp_dp83640_enable(struct ptp_clock_in=
fo *ptp,
 	switch (rq->type) {
 	case PTP_CLK_REQ_EXTTS:
 		index =3D rq->extts.index;
-		if (index < 0 || index >=3D n_ext_ts)
+		if (index < 0 || index >=3D clock->caps.n_ext_ts)
 			return -EINVAL;
 		event_num =3D index;
 		evnt =3D EVNT_WR | (event_num & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
 		if (on) {
-			gpio_num =3D extts_pins[index];
+			gpio_num =3D clock->extts_pins[index];
 			evnt |=3D (gpio_num & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
 			if (rq->extts.flags & PTP_FALLING_EDGE)
 				evnt |=3D EVNT_FALL;
@@ -452,7 +456,7 @@ static int ptp_dp83640_enable(struct ptp_clock_info=
 *ptp,
=20
 	case PTP_CLK_REQ_PEROUT:
 		index =3D rq->perout.index;
-		if (index < 0 || index >=3D n_per_out)
+		if (index < 0 || index >=3D clock->caps.n_per_out)
 			return -EINVAL;
 		periodic_output(clock, rq, index, on);
 		return 0;
@@ -573,7 +577,7 @@ static void recalibrate(struct dp83640_clock *clock=
)
 	 */
 	evnt =3D EVNT_WR | EVNT_RISE | EVNT_SINGLE;
 	evnt |=3D (trigger & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
-	evnt |=3D (calibrate_pin & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
+	evnt |=3D (clock->calibrate_pin & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
=20
 	list_for_each(this, &clock->phylist) {
 		tmp =3D list_entry(this, struct dp83640_private, list);
@@ -586,7 +590,7 @@ static void recalibrate(struct dp83640_clock *clock=
)
 	 */
 	ptp_trig =3D TRIG_WR | TRIG_IF_LATE | TRIG_PULSE;
 	ptp_trig |=3D (trigger  & TRIG_CSEL_MASK) << TRIG_CSEL_SHIFT;
-	ptp_trig |=3D (calibrate_pin & TRIG_GPIO_MASK) << TRIG_GPIO_SHIFT;
+	ptp_trig |=3D (clock->calibrate_pin & TRIG_GPIO_MASK) << TRIG_GPIO_SH=
IFT;
 	ext_write(0, master, PAGE5, PTP_TRIG, ptp_trig);
=20
 	/* load trigger */
@@ -691,7 +695,7 @@ static int decode_evnt(struct dp83640_private *dp83=
640,
 	event.type =3D PTP_CLOCK_EXTTS;
 	event.timestamp =3D phy2txts(&dp83640->edata);
=20
-	for (i =3D 0; i < n_ext_ts; i++) {
+	for (i =3D 0; i < dp83640->clock->caps.n_ext_ts; i++) {
 		if (ext_status & exts_chan_to_edata(i)) {
 			event.index =3D i;
 			ptp_clock_event(dp83640->clock->ptp_clock, &event);
@@ -893,12 +897,11 @@ static void dp83640_clock_init(struct dp83640_clo=
ck *clock, struct mii_bus *bus)
 	mutex_init(&clock->extreg_lock);
 	mutex_init(&clock->clock_lock);
 	INIT_LIST_HEAD(&clock->phylist);
+	clock->calibrate_pin =3D -1;
 	clock->caps.owner =3D THIS_MODULE;
 	sprintf(clock->caps.name, "dp83640 timer");
 	clock->caps.max_adj	=3D 1953124;
 	clock->caps.n_alarm	=3D 0;
-	clock->caps.n_ext_ts	=3D n_ext_ts;
-	clock->caps.n_per_out	=3D n_per_out;
 	clock->caps.pps		=3D 0;
 	clock->caps.adjfreq	=3D ptp_dp83640_adjfreq;
 	clock->caps.adjtime	=3D ptp_dp83640_adjtime;
@@ -911,18 +914,6 @@ static void dp83640_clock_init(struct dp83640_cloc=
k *clock, struct mii_bus *bus)
 	get_device(&bus->dev);
 }
=20
-static int choose_this_phy(struct dp83640_clock *clock,
-			   struct phy_device *phydev)
-{
-	if (chosen_phy =3D=3D -1 && !clock->chosen)
-		return 1;
-
-	if (chosen_phy =3D=3D phydev->addr)
-		return 1;
-
-	return 0;
-}
-
 static struct dp83640_clock *dp83640_clock_get(struct dp83640_clock *c=
lock)
 {
 	if (clock)
@@ -968,6 +959,86 @@ static void dp83640_clock_put(struct dp83640_clock=
 *clock)
 	mutex_unlock(&clock->clock_lock);
 }
=20
+#ifdef CONFIG_OF
+static int dp83640_probe_dt(struct device_node *node,
+			    struct dp83640_private *dp83640)
+{
+	struct dp83640_clock *clock =3D dp83640->clock;
+	struct property *prop;
+	int err, proplen, n_cal =3D 0;
+
+	dp83640->slave =3D of_property_read_bool(node, "dp83640,slave");
+	if (!dp83640->slave && clock->chosen) {
+		pr_err("More then one dp83640 master on the same bus");
+		return -EINVAL;
+	}
+
+	prop =3D of_find_property(node, "dp83640,calibrate-pin", &proplen);
+	if (prop) {
+		if (dp83640->slave) {
+			pr_err("dp83640 slave cannot have calibrate pin");
+			return -EINVAL;
+		}
+		of_property_read_u32(node, "dp83640,calibrate-pin",
+				     &clock->calibrate_pin);
+		n_cal =3D 1;
+	}
+
+	prop =3D of_find_property(node, "dp83640,perout-pins", &proplen);
+	if (prop) {
+		if (dp83640->slave) {
+			pr_err("dp83640 slave cannot have perout pins");
+			return -EINVAL;
+		}
+
+		clock->caps.n_per_out =3D proplen / sizeof(u32);
+		if (clock->caps.n_per_out + n_cal > N_EXT) {
+			pr_err("Too many dp83640,perout-pins");
+			return -EINVAL;
+		}
+		err =3D of_property_read_u32_array(node, "dp83640,perout-pins",
+						 clock->perout_pins,
+						 clock->caps.n_per_out);
+		if (err < 0)
+			return err;
+	}
+
+	prop =3D of_find_property(node, "dp83640,extts-pins", &proplen);
+	if (prop) {
+		if (dp83640->slave) {
+			pr_err("dp83640 slave cannot have extts pins");
+			return -EINVAL;
+		}
+
+		clock->caps.n_ext_ts =3D proplen / sizeof(u32);
+		if (clock->caps.n_ext_ts + n_cal > N_EXT) {
+			pr_err("Too many dp83640,extts-pins");
+			return -EINVAL;
+		}
+		err =3D of_property_read_u32_array(node, "dp83640,extts-pins",
+						 clock->extts_pins,
+						 clock->caps.n_ext_ts);
+		if (err < 0)
+			return err;
+	}
+
+	return 0;
+}
+
+static const struct of_device_id dp83640_of_match_table[] =3D {
+	{ .compatible =3D "national,dp83640", },
+	{ },
+};
+MODULE_DEVICE_TABLE(of, dp83640_of_match_table);
+#else
+
+static inline int dp83640_probe_dt(struct device_node *node,
+				   struct dp83640_private *dp83640)
+{
+	return 0;
+}
+#endif
+
 static int dp83640_probe(struct phy_device *phydev)
 {
 	struct dp83640_clock *clock;
@@ -985,7 +1056,24 @@ static int dp83640_probe(struct phy_device *phyde=
v)
 	if (!dp83640)
 		goto no_memory;
=20
+	dp83640->clock =3D clock;
 	dp83640->phydev =3D phydev;
+
+	if (phydev->dev.of_node) {
+		err =3D dp83640_probe_dt(phydev->dev.of_node, dp83640);
+		if (err)
+			return err;
+	} else {
+		clock->calibrate_pin =3D calibrate_pin;
+		memcpy(clock->perout_pins, perout_pins,
+		       sizeof(clock->perout_pins));
+		memcpy(clock->extts_pins, extts_pins,
+		       sizeof(clock->extts_pins));
+		if (clock->chosen ||
+		    (chosen_phy !=3D -1 && phydev->addr !=3D chosen_phy))
+			dp83640->slave =3D true;
+	}
+
 	INIT_WORK(&dp83640->ts_work, rx_timestamp_work);
=20
 	INIT_LIST_HEAD(&dp83640->rxts);
@@ -999,9 +1087,7 @@ static int dp83640_probe(struct phy_device *phydev=
)
 	skb_queue_head_init(&dp83640->rx_queue);
 	skb_queue_head_init(&dp83640->tx_queue);
=20
-	dp83640->clock =3D clock;
-
-	if (choose_this_phy(clock, phydev)) {
+	if (!dp83640->slave) {
 		clock->chosen =3D dp83640;
 		clock->ptp_clock =3D ptp_clock_register(&clock->caps, &phydev->dev);
 		if (IS_ERR(clock->ptp_clock)) {
@@ -1353,7 +1439,10 @@ static struct phy_driver dp83640_driver =3D {
 	.hwtstamp	=3D dp83640_hwtstamp,
 	.rxtstamp	=3D dp83640_rxtstamp,
 	.txtstamp	=3D dp83640_txtstamp,
-	.driver		=3D {.owner =3D THIS_MODULE,}
+	.driver		=3D {
+		.owner =3D THIS_MODULE,
+		.of_match_table =3D of_match_ptr(dp83640_of_match_table),
+	}
 };
=20
 static int __init dp83640_init(void)
--=20
1.8.5.3
