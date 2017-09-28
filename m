From: Brandon Streiff <brandon.streiff@ni.com>
Subject: [PATCH net-next RFC 4/9] net: dsa: mv88e6xxx: add support for event capture
Date: Thu, 28 Sep 2017 10:25:36 -0500
Message-ID: <1506612341-18061-5-git-send-email-brandon.streiff@ni.com>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>,
        Brandon Streiff <brandon.streiff@ni.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for configuring mv88e6xxx GPIO lines as PTP
pins, so that they may be used for time stamping external events or for
periodic output.

Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
---
 drivers/net/dsa/mv88e6xxx/chip.h |   4 +
 drivers/net/dsa/mv88e6xxx/ptp.c  | 317 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/ptp.h  |  16 ++
 3 files changed, 335 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 5f132e2..b763778 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -227,6 +227,10 @@ struct mv88e6xxx_chip {
 
 	struct ptp_clock	*ptp_clock;
 	struct ptp_clock_info	ptp_clock_info;
+	struct delayed_work	tai_event_work;
+	struct ptp_pin_desc	pin_config[MV88E6XXX_MAX_GPIO];
+	u16 trig_config;
+	u16 evcap_config;
 };
 
 struct mv88e6xxx_bus_ops {
diff --git a/drivers/net/dsa/mv88e6xxx/ptp.c b/drivers/net/dsa/mv88e6xxx/ptp.c
index 155f8e9..1422d85 100644
--- a/drivers/net/dsa/mv88e6xxx/ptp.c
+++ b/drivers/net/dsa/mv88e6xxx/ptp.c
@@ -18,6 +18,8 @@
 #include "global2.h"
 #include "ptp.h"
 
+#define TAI_EVENT_WORK_INTERVAL msecs_to_jiffies(100)
+
 static int mv88e6xxx_tai_read(struct mv88e6xxx_chip *chip, int addr,
 			      u16 *data, int len)
 {
@@ -27,6 +29,14 @@ static int mv88e6xxx_tai_read(struct mv88e6xxx_chip *chip, int addr,
 	return chip->info->ops->avb_ops->tai_read(chip, addr, data, len);
 }
 
+static int mv88e6xxx_tai_write(struct mv88e6xxx_chip *chip, int addr, u16 data)
+{
+	if (!chip->info->ops->avb_ops->tai_write)
+		return -EOPNOTSUPP;
+
+	return chip->info->ops->avb_ops->tai_write(chip, addr, data);
+}
+
 static u64 mv88e6xxx_ptp_clock_read(const struct cyclecounter *cc)
 {
 	struct mv88e6xxx_chip *chip =
@@ -42,6 +52,144 @@ static u64 mv88e6xxx_ptp_clock_read(const struct cyclecounter *cc)
 		return ((u32)phc_time[1] << 16) | phc_time[0];
 }
 
+static int mv88e6xxx_disable_trig(struct mv88e6xxx_chip *chip)
+{
+	int err;
+	u16 global_config;
+
+	chip->trig_config = 0;
+	global_config = (chip->evcap_config | chip->trig_config);
+	err = mv88e6xxx_tai_write(chip, MV88E6XXX_TAI_CFG, global_config);
+
+	return err;
+}
+
+static int mv88e6xxx_config_periodic_trig(struct mv88e6xxx_chip *chip,
+					  u32 ns, u16 picos)
+{
+	int err;
+	u16 global_config;
+
+	if (picos >= 1000)
+		return -ERANGE;
+
+	/* TRIG generation is in units of 8 ns clock periods. Convert ns
+	 * and ps into 8 ns clock periods and up to 8000 additional ps
+	 */
+	picos += (ns & 0x7) * 1000;
+	ns = ns >> 3;
+
+	err = mv88e6xxx_tai_write(chip, MV88E6XXX_TAI_TRIG_GEN_AMOUNT_LO,
+				  ns & 0xffff);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_tai_write(chip, MV88E6XXX_TAI_TRIG_GEN_AMOUNT_HI,
+				  ns >> 16);
+	if (err)
+		return err;
+
+	err = mv88e6xxx_tai_write(chip, MV88E6XXX_TAI_TRIG_CLOCK_COMP,
+				  picos);
+	if (err)
+		return err;
+
+	chip->trig_config = MV88E6XXX_TAI_CFG_TRIG_ENABLE;
+	global_config = (chip->evcap_config | chip->trig_config);
+	err = mv88e6xxx_tai_write(chip, MV88E6XXX_TAI_CFG, global_config);
+
+	return err;
+}
+
+/* mv88e6xxx_config_eventcap - configure TAI event capture
+ * @event: PTP_CLOCK_PPS (internal) or PTP_CLOCK_EXTTS (external)
+ * @rising: zero for falling-edge trigger, else rising-edge trigger
+ *
+ * This will also reset the capture sequence counter.
+ */
+static int mv88e6xxx_config_eventcap(struct mv88e6xxx_chip *chip, int event,
+				     int rising)
+{
+	u16 global_config;
+	u16 cap_config;
+	int err;
+
+	chip->evcap_config = MV88E6XXX_TAI_CFG_CAP_OVERWRITE |
+			     MV88E6XXX_TAI_CFG_CAP_CTR_START;
+	if (!rising)
+		chip->evcap_config |= MV88E6XXX_TAI_CFG_EVREQ_FALLING;
+
+	global_config = (chip->evcap_config | chip->trig_config);
+	err = mv88e6xxx_tai_write(chip, MV88E6XXX_TAI_CFG, global_config);
+	if (err)
+		return err;
+
+	if (event == PTP_CLOCK_PPS) {
+		cap_config = MV88E6XXX_TAI_EVENT_STATUS_CAP_TRIG;
+	} else if (event == PTP_CLOCK_EXTTS) {
+		/* if STATUS_CAP_TRIG is unset we capture PTP_EVREQ events */
+		cap_config = 0;
+	} else {
+		return -EINVAL;
+	}
+
+	/* Write the capture config; this also clears the capture counter */
+	err = mv88e6xxx_tai_write(chip, MV88E6XXX_TAI_EVENT_STATUS,
+				  cap_config);
+
+	return err;
+}
+
+static void mv88e6xxx_tai_event_work(struct work_struct *ugly)
+{
+	struct delayed_work *dw = to_delayed_work(ugly);
+	struct mv88e6xxx_chip *chip =
+		container_of(dw, struct mv88e6xxx_chip, tai_event_work);
+	u16 ev_status[4];
+	int err;
+
+	mutex_lock(&chip->reg_lock);
+
+	err = mv88e6xxx_tai_read(chip, MV88E6XXX_TAI_EVENT_STATUS,
+				 ev_status, ARRAY_SIZE(ev_status));
+	if (err) {
+		mutex_unlock(&chip->reg_lock);
+		return;
+	}
+
+	if (ev_status[0] & MV88E6XXX_TAI_EVENT_STATUS_ERROR)
+		dev_warn(chip->dev, "missed event capture\n");
+
+	if (ev_status[0] & MV88E6XXX_TAI_EVENT_STATUS_VALID) {
+		struct ptp_clock_event ev;
+		u32 raw_ts = ((u32)ev_status[2] << 16) | ev_status[1];
+
+		/* Clear the valid bit so the next timestamp can come in */
+		ev_status[0] &= ~MV88E6XXX_TAI_EVENT_STATUS_VALID;
+		err = mv88e6xxx_tai_write(chip, MV88E6XXX_TAI_EVENT_STATUS,
+					  ev_status[0]);
+
+		if (ev_status[0] & MV88E6XXX_TAI_EVENT_STATUS_CAP_TRIG) {
+			/* TAI is configured to timestamp internal events.
+			 * This will be a PPS event.
+			 */
+			ev.type = PTP_CLOCK_PPS;
+		} else {
+			/* Otherwise this is an external timestamp */
+			ev.type = PTP_CLOCK_EXTTS;
+		}
+		/* We only have one timestamping channel. */
+		ev.index = 0;
+		ev.timestamp = timecounter_cyc2time(&chip->tstamp_tc, raw_ts);
+
+		ptp_clock_event(chip->ptp_clock, &ev);
+	}
+
+	mutex_unlock(&chip->reg_lock);
+
+	schedule_delayed_work(&chip->tai_event_work, TAI_EVENT_WORK_INTERVAL);
+}
+
 static int mv88e6xxx_ptp_adjfine(struct ptp_clock_info *ptp, long scaled_ppm)
 {
 	if (scaled_ppm == 0)
@@ -95,16 +243,163 @@ static int mv88e6xxx_ptp_settime(struct ptp_clock_info *ptp,
 	return 0;
 }
 
+static int mv88e6xxx_ptp_enable_extts(struct mv88e6xxx_chip *chip,
+				      struct ptp_clock_request *rq, int on)
+{
+	int rising = (rq->extts.flags & PTP_RISING_EDGE);
+	int pin;
+	int err;
+
+	pin = ptp_find_pin(chip->ptp_clock, PTP_PF_EXTTS, rq->extts.index);
+
+	if (pin < 0)
+		return -EBUSY;
+
+	mutex_lock(&chip->reg_lock);
+
+	if (on) {
+		err = mv88e6xxx_g2_set_gpio_config(
+			chip, pin, MV88E6XXX_G2_SCRATCH_GPIO_MODE_EVREQ,
+			MV88E6XXX_G2_SCRATCH_GPIO_DIR_IN);
+		if (err)
+			goto out;
+
+		schedule_delayed_work(&chip->tai_event_work,
+				      TAI_EVENT_WORK_INTERVAL);
+
+		err = mv88e6xxx_config_eventcap(chip, PTP_CLOCK_EXTTS,
+						rising);
+	} else {
+		err = mv88e6xxx_g2_set_gpio_config(
+			chip, pin, MV88E6XXX_G2_SCRATCH_GPIO_MODE_GPIO,
+			MV88E6XXX_G2_SCRATCH_GPIO_DIR_IN);
+
+		cancel_delayed_work_sync(&chip->tai_event_work);
+	}
+
+out:
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
+static int mv88e6xxx_ptp_enable_perout(struct mv88e6xxx_chip *chip,
+				       struct ptp_clock_request *rq, int on)
+{
+	struct timespec ts;
+	u64 ns;
+	int pin;
+	int err;
+
+	pin = ptp_find_pin(chip->ptp_clock, PTP_PF_PEROUT, rq->extts.index);
+
+	if (pin < 0)
+		return -EBUSY;
+
+	ts.tv_sec = rq->perout.period.sec;
+	ts.tv_nsec = rq->perout.period.nsec;
+	ns = timespec_to_ns(&ts);
+
+	if (ns > U32_MAX)
+		return -ERANGE;
+
+	mutex_lock(&chip->reg_lock);
+
+	err = mv88e6xxx_config_periodic_trig(chip, (u32)ns, 0);
+	if (err)
+		goto out;
+
+	if (on) {
+		err = mv88e6xxx_g2_set_gpio_config(
+			chip, pin, MV88E6XXX_G2_SCRATCH_GPIO_MODE_TRIG,
+			MV88E6XXX_G2_SCRATCH_GPIO_DIR_OUT);
+	} else {
+		err = mv88e6xxx_g2_set_gpio_config(
+			chip, pin, MV88E6XXX_G2_SCRATCH_GPIO_MODE_GPIO,
+			MV88E6XXX_G2_SCRATCH_GPIO_DIR_IN);
+	}
+
+out:
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
+static int mv88e6xxx_ptp_enable_pps(struct mv88e6xxx_chip *chip,
+				    struct ptp_clock_request *rq, int on)
+{
+	int pin;
+	int err;
+
+	pin = ptp_find_pin(chip->ptp_clock, PTP_PF_PEROUT, rq->extts.index);
+
+	if (pin < 0)
+		return -EBUSY;
+
+	mutex_lock(&chip->reg_lock);
+
+	if (on) {
+		err = mv88e6xxx_g2_set_gpio_config(
+			chip, pin, MV88E6XXX_G2_SCRATCH_GPIO_MODE_TRIG,
+			MV88E6XXX_G2_SCRATCH_GPIO_DIR_OUT);
+		if (err)
+			goto out;
+		err = mv88e6xxx_config_periodic_trig(chip,
+						     NSEC_PER_SEC, 0);
+		if (err)
+			goto out;
+
+		schedule_delayed_work(&chip->tai_event_work, 0);
+
+		err = mv88e6xxx_config_eventcap(chip, PTP_CLOCK_PPS, 1);
+	} else {
+		err = mv88e6xxx_g2_set_gpio_config(
+			chip, pin, MV88E6XXX_G2_SCRATCH_GPIO_MODE_GPIO,
+			MV88E6XXX_G2_SCRATCH_GPIO_DIR_IN);
+		if (err)
+			goto out;
+
+		err = mv88e6xxx_disable_trig(chip);
+
+		cancel_delayed_work_sync(&chip->tai_event_work);
+	}
+
+out:
+	mutex_unlock(&chip->reg_lock);
+
+	return err;
+}
+
 static int mv88e6xxx_ptp_enable(struct ptp_clock_info *ptp,
 				struct ptp_clock_request *rq, int on)
 {
-	return -EOPNOTSUPP;
+	struct mv88e6xxx_chip *chip =
+		container_of(ptp, struct mv88e6xxx_chip, ptp_clock_info);
+
+	switch (rq->type) {
+	case PTP_CLK_REQ_EXTTS:
+		return mv88e6xxx_ptp_enable_extts(chip, rq, on);
+	case PTP_CLK_REQ_PEROUT:
+		return mv88e6xxx_ptp_enable_perout(chip, rq, on);
+	case PTP_CLK_REQ_PPS:
+		return mv88e6xxx_ptp_enable_pps(chip, rq, on);
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static int mv88e6xxx_ptp_verify(struct ptp_clock_info *ptp, unsigned int pin,
 				enum ptp_pin_function func, unsigned int chan)
 {
-	return -EOPNOTSUPP;
+	switch (func) {
+	case PTP_PF_NONE:
+	case PTP_PF_EXTTS:
+	case PTP_PF_PEROUT:
+		break;
+	case PTP_PF_PHYSYNC:
+		return -EOPNOTSUPP;
+	}
+	return 0;
 }
 
 /* The 32-bit timestamp counter overflows every ~34.3 seconds; this task
@@ -132,6 +427,8 @@ static void mv88e6xxx_ptp_overflow_check(struct work_struct *work)
 
 int mv88e6xxx_ptp_setup(struct mv88e6xxx_chip *chip)
 {
+	int i;
+
 	/* Set up the cycle counter */
 	memset(&chip->tstamp_cc, 0, sizeof(chip->tstamp_cc));
 	chip->tstamp_cc.read	= mv88e6xxx_ptp_clock_read;
@@ -146,12 +443,27 @@ int mv88e6xxx_ptp_setup(struct mv88e6xxx_chip *chip)
 	chip->last_overflow_check = jiffies;
 
 	INIT_DELAYED_WORK(&chip->overflow_work, mv88e6xxx_ptp_overflow_check);
+	INIT_DELAYED_WORK(&chip->tai_event_work, mv88e6xxx_tai_event_work);
 
 	chip->ptp_clock_info.owner = THIS_MODULE;
 	snprintf(chip->ptp_clock_info.name, sizeof(chip->ptp_clock_info.name),
 		 dev_name(chip->dev));
 	chip->ptp_clock_info.max_adj	= 0;
 
+	chip->ptp_clock_info.n_ext_ts	= 1;
+	chip->ptp_clock_info.n_per_out	= 1;
+	chip->ptp_clock_info.n_pins	= mv88e6xxx_num_gpio(chip);
+	chip->ptp_clock_info.pps	= 1;
+
+	for (i = 0; i < chip->ptp_clock_info.n_pins; ++i) {
+		struct ptp_pin_desc *ppd = &chip->pin_config[i];
+
+		snprintf(ppd->name, sizeof(ppd->name), "mv88e6xxx_gpio%d", i);
+		ppd->index = i;
+		ppd->func = PTP_PF_NONE;
+	}
+	chip->ptp_clock_info.pin_config = chip->pin_config;
+
 	chip->ptp_clock_info.adjfine	= mv88e6xxx_ptp_adjfine;
 	chip->ptp_clock_info.adjtime	= mv88e6xxx_ptp_adjtime;
 	chip->ptp_clock_info.gettime64	= mv88e6xxx_ptp_gettime;
@@ -173,6 +485,7 @@ void mv88e6xxx_ptp_free(struct mv88e6xxx_chip *chip)
 {
 	if (chip->ptp_clock) {
 		cancel_delayed_work_sync(&chip->overflow_work);
+		cancel_delayed_work_sync(&chip->tai_event_work);
 
 		ptp_clock_unregister(chip->ptp_clock);
 		chip->ptp_clock = NULL;
diff --git a/drivers/net/dsa/mv88e6xxx/ptp.h b/drivers/net/dsa/mv88e6xxx/ptp.h
index c662953..33b1842 100644
--- a/drivers/net/dsa/mv88e6xxx/ptp.h
+++ b/drivers/net/dsa/mv88e6xxx/ptp.h
@@ -21,6 +21,18 @@
 
 /* Offset 0x00: TAI Global Config */
 #define MV88E6XXX_TAI_CFG			0x00
+#define MV88E6XXX_TAI_CFG_CAP_OVERWRITE		0x8000
+#define MV88E6XXX_TAI_CFG_CAP_CTR_START		0x4000
+#define MV88E6XXX_TAI_CFG_EVREQ_FALLING		0x2000
+#define MV88E6XXX_TAI_CFG_TRIG_ACTIVE_LO	0x1000
+#define MV88E6XXX_TAI_CFG_IRL_ENABLE		0x0400
+#define MV88E6XXX_TAI_CFG_TRIG_IRQ_EN		0x0200
+#define MV88E6XXX_TAI_CFG_EVREQ_IRQ_EN		0x0100
+#define MV88E6XXX_TAI_CFG_TRIG_LOCK		0x0080
+#define MV88E6XXX_TAI_CFG_BLOCK_UPDATE		0x0008
+#define MV88E6XXX_TAI_CFG_MULTI_PTP		0x0004
+#define MV88E6XXX_TAI_CFG_TRIG_MODE_ONESHOT	0x0002
+#define MV88E6XXX_TAI_CFG_TRIG_ENABLE		0x0001
 
 /* Offset 0x01: Timestamp Clock Period (ps) */
 #define MV88E6XXX_TAI_CLOCK_PERIOD		0x01
@@ -46,6 +58,10 @@
 
 /* Offset 0x09: Event Status */
 #define MV88E6XXX_TAI_EVENT_STATUS		0x09
+#define MV88E6XXX_TAI_EVENT_STATUS_CAP_TRIG	0x4000
+#define MV88E6XXX_TAI_EVENT_STATUS_ERROR	0x0200
+#define MV88E6XXX_TAI_EVENT_STATUS_VALID	0x0100
+#define MV88E6XXX_TAI_EVENT_STATUS_CTR_MASK	0x00ff
 
 /* Offset 0x0A/0x0B: Event Time */
 #define MV88E6XXX_TAI_EVENT_TIME_LO		0x0a
-- 
2.1.4
