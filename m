From: Richard Cochran <richardcochran@gmail.com>
Subject: [RFC net-next 11/22] ptp: i40e: convert to the 64 bit get/set time methods.
Date: Sat, 21 Mar 2015 21:59:41 +0100
Message-ID: <e17cbcd1f1f523ea3f38d52908703b5160c8541e.1426970294.git.richardcochran@gmail.com>
References: <cover.1426970294.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorense
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1426970294.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device appears to use a 64 bit nanoseconds register, and so with
this patch the driver should be ready for the year 2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index fabcfa1..a92b772 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -57,7 +57,7 @@
  * timespec. However, since the registers are 64 bits of nanoseconds, we must
  * convert the result to a timespec before we can return.
  **/
-static void i40e_ptp_read(struct i40e_pf *pf, struct timespec *ts)
+static void i40e_ptp_read(struct i40e_pf *pf, struct timespec64 *ts)
 {
 	struct i40e_hw *hw = &pf->hw;
 	u32 hi, lo;
@@ -69,7 +69,7 @@ static void i40e_ptp_read(struct i40e_pf *pf, struct timespec *ts)
 
 	ns = (((u64)hi) << 32) | lo;
 
-	*ts = ns_to_timespec(ns);
+	*ts = ns_to_timespec64(ns);
 }
 
 /**
@@ -81,10 +81,10 @@ static void i40e_ptp_read(struct i40e_pf *pf, struct timespec *ts)
  * we receive a timespec from the stack, we must convert that timespec into
  * nanoseconds before programming the registers.
  **/
-static void i40e_ptp_write(struct i40e_pf *pf, const struct timespec *ts)
+static void i40e_ptp_write(struct i40e_pf *pf, const struct timespec64 *ts)
 {
 	struct i40e_hw *hw = &pf->hw;
-	u64 ns = timespec_to_ns(ts);
+	u64 ns = timespec64_to_ns(ts);
 
 	/* The timer will not update until the high register is written, so
 	 * write the low register first.
@@ -159,14 +159,14 @@ static int i40e_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 static int i40e_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 {
 	struct i40e_pf *pf = container_of(ptp, struct i40e_pf, ptp_caps);
-	struct timespec now, then = ns_to_timespec(delta);
+	struct timespec64 now, then = ns_to_timespec64(delta);
 	unsigned long flags;
 
 	spin_lock_irqsave(&pf->tmreg_lock, flags);
 
 	i40e_ptp_read(pf, &now);
-	now = timespec_add(now, then);
-	i40e_ptp_write(pf, (const struct timespec *)&now);
+	now = timespec64_add(now, then);
+	i40e_ptp_write(pf, (const struct timespec64 *)&now);
 
 	spin_unlock_irqrestore(&pf->tmreg_lock, flags);
 
@@ -181,7 +181,7 @@ static int i40e_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
  * Read the device clock and return the correct value on ns, after converting it
  * into a timespec struct.
  **/
-static int i40e_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int i40e_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	struct i40e_pf *pf = container_of(ptp, struct i40e_pf, ptp_caps);
 	unsigned long flags;
@@ -202,7 +202,7 @@ static int i40e_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
  * to ns happens in the write function.
  **/
 static int i40e_ptp_settime(struct ptp_clock_info *ptp,
-			    const struct timespec *ts)
+			    const struct timespec64 *ts)
 {
 	struct i40e_pf *pf = container_of(ptp, struct i40e_pf, ptp_caps);
 	unsigned long flags;
@@ -613,8 +613,8 @@ static long i40e_ptp_create_clock(struct i40e_pf *pf)
 	pf->ptp_caps.pps = 0;
 	pf->ptp_caps.adjfreq = i40e_ptp_adjfreq;
 	pf->ptp_caps.adjtime = i40e_ptp_adjtime;
-	pf->ptp_caps.gettime = i40e_ptp_gettime;
-	pf->ptp_caps.settime = i40e_ptp_settime;
+	pf->ptp_caps.gettime64 = i40e_ptp_gettime;
+	pf->ptp_caps.settime64 = i40e_ptp_settime;
 	pf->ptp_caps.enable = i40e_ptp_feature_enable;
 
 	/* Attempt to register the clock before enabling the hardware. */
@@ -673,7 +673,7 @@ void i40e_ptp_init(struct i40e_pf *pf)
 		dev_err(&pf->pdev->dev, "%s: ptp_clock_register failed\n",
 			__func__);
 	} else {
-		struct timespec ts;
+		struct timespec64 ts;
 		u32 regval;
 
 		dev_info(&pf->pdev->dev, "%s: added PHC on %s\n", __func__,
@@ -695,7 +695,7 @@ void i40e_ptp_init(struct i40e_pf *pf)
 		i40e_ptp_set_timestamp_mode(pf, &pf->tstamp_config);
 
 		/* Set the clock value. */
-		ts = ktime_to_timespec(ktime_get_real());
+		ts = ktime_to_timespec64(ktime_get_real());
 		i40e_ptp_settime(&pf->ptp_caps, &ts);
 	}
 }
-- 
1.7.10.4
