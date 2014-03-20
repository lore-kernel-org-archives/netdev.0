From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next v3 7/9] dp83640: implement programmable pin functions.
Date: Thu, 20 Mar 2014 22:21:58 +0100
Message-ID: <e8cef8ddc58d536a8980af90c2bfe4b6111703b7.1395350114.git.richardcochran@gmail.com>
References: <cover.1395350105.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Christian Riesch <christian.riesch@omicron.at>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1395350105.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adapts the dp83640 driver to allow reconfiguration of which
auxiliary function goes on which pin. The functions may be reassigned
freely with the one exception of the calibration function.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c |   52 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 52 insertions(+)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 9e26555..43b583b 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -47,6 +47,7 @@
 #define CAL_EVENT	7
 #define CAL_TRIGGER	7
 #define PER_TRIGGER	6
+#define DP83640_N_PINS	12
 
 #define MII_DP83640_MICR 0x11
 #define MII_DP83640_MISR 0x12
@@ -173,6 +174,37 @@ MODULE_PARM_DESC(chosen_phy, \
 MODULE_PARM_DESC(gpio_tab, \
 	"Which GPIO line to use for which purpose: cal,perout,extts1,...,extts6");
 
+static void dp83640_gpio_defaults(struct ptp_pin_desc *pd)
+{
+	int i, index;
+
+	for (i = 0; i < DP83640_N_PINS; i++) {
+		snprintf(pd[i].name, sizeof(pd[i].name), "GPIO%d", 1 + i);
+		pd[i].index = i;
+	}
+
+	for (i = 0; i < GPIO_TABLE_SIZE; i++) {
+		if (gpio_tab[i] < 1 || gpio_tab[i] > DP83640_N_PINS) {
+			pr_err("gpio_tab[%d]=%hu out of range", i, gpio_tab[i]);
+			return;
+		}
+	}
+
+	index = gpio_tab[CALIBRATE_GPIO] - 1;
+	pd[index].func = PTP_PF_PHYSYNC;
+	pd[index].chan = 0;
+
+	index = gpio_tab[PEROUT_GPIO] - 1;
+	pd[index].func = PTP_PF_PEROUT;
+	pd[index].chan = 0;
+
+	for (i = EXTTS0_GPIO; i < GPIO_TABLE_SIZE; i++) {
+		index = gpio_tab[i] - 1;
+		pd[index].func = PTP_PF_EXTTS;
+		pd[index].chan = i - EXTTS0_GPIO;
+	}
+}
+
 /* a list of clocks and a mutex to protect it */
 static LIST_HEAD(phyter_clocks);
 static DEFINE_MUTEX(phyter_clocks_lock);
@@ -459,6 +491,12 @@ static int ptp_dp83640_enable(struct ptp_clock_info *ptp,
 	return -EOPNOTSUPP;
 }
 
+static int ptp_dp83640_verify(struct ptp_clock_info *ptp, unsigned int pin,
+			      enum ptp_pin_function func, unsigned int chan)
+{
+	return 0;
+}
+
 static u8 status_frame_dst[6] = { 0x01, 0x1B, 0x19, 0x00, 0x00, 0x00 };
 static u8 status_frame_src[6] = { 0x08, 0x00, 0x17, 0x0B, 0x6B, 0x0F };
 
@@ -876,6 +914,7 @@ static void dp83640_free_clocks(void)
 		mutex_destroy(&clock->extreg_lock);
 		mutex_destroy(&clock->clock_lock);
 		put_device(&clock->bus->dev);
+		kfree(clock->caps.pin_config);
 		kfree(clock);
 	}
 
@@ -895,12 +934,18 @@ static void dp83640_clock_init(struct dp83640_clock *clock, struct mii_bus *bus)
 	clock->caps.n_alarm	= 0;
 	clock->caps.n_ext_ts	= N_EXT_TS;
 	clock->caps.n_per_out	= 1;
+	clock->caps.n_pins	= DP83640_N_PINS;
 	clock->caps.pps		= 0;
 	clock->caps.adjfreq	= ptp_dp83640_adjfreq;
 	clock->caps.adjtime	= ptp_dp83640_adjtime;
 	clock->caps.gettime	= ptp_dp83640_gettime;
 	clock->caps.settime	= ptp_dp83640_settime;
 	clock->caps.enable	= ptp_dp83640_enable;
+	clock->caps.verify	= ptp_dp83640_verify;
+	/*
+	 * Convert the module param defaults into a dynamic pin configuration.
+	 */
+	dp83640_gpio_defaults(clock->caps.pin_config);
 	/*
 	 * Get a reference to this bus instance.
 	 */
@@ -951,6 +996,13 @@ static struct dp83640_clock *dp83640_clock_get_bus(struct mii_bus *bus)
 	if (!clock)
 		goto out;
 
+	clock->caps.pin_config = kzalloc(sizeof(struct ptp_pin_desc) *
+					 DP83640_N_PINS, GFP_KERNEL);
+	if (!clock->caps.pin_config) {
+		kfree(clock);
+		clock = NULL;
+		goto out;
+	}
 	dp83640_clock_init(clock, bus);
 	list_add_tail(&phyter_clocks, &clock->list);
 out:
-- 
1.7.10.4
