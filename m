From: Richard Cochran <richardcochran@gmail.com>
Subject: [RFC net-next 09/22] ptp: e1000e: convert to the 64 bit get/set time methods.
Date: Sat, 21 Mar 2015 21:59:39 +0100
Message-ID: <1d011e26b2b1c868f70c9d973977ef4b90109d17.1426970294.git.richardcochran@gmail.com>
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

This driver's clock is implemented using a timecounter, and so with
this patch the driver is ready for the year 2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/ptp.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 1490f1e..b747a3e 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -106,7 +106,7 @@ static int e1000e_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
  * Read the timecounter and return the correct value in ns after converting
  * it into a struct timespec.
  **/
-static int e1000e_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int e1000e_phc_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	struct e1000_adapter *adapter = container_of(ptp, struct e1000_adapter,
 						     ptp_clock_info);
@@ -133,14 +133,14 @@ static int e1000e_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
  * wall timer value.
  **/
 static int e1000e_phc_settime(struct ptp_clock_info *ptp,
-			      const struct timespec *ts)
+			      const struct timespec64 *ts)
 {
 	struct e1000_adapter *adapter = container_of(ptp, struct e1000_adapter,
 						     ptp_clock_info);
 	unsigned long flags;
 	u64 ns;
 
-	ns = timespec_to_ns(ts);
+	ns = timespec64_to_ns(ts);
 
 	/* reset the timecounter */
 	spin_lock_irqsave(&adapter->systim_lock, flags);
@@ -171,11 +171,11 @@ static void e1000e_systim_overflow_work(struct work_struct *work)
 	struct e1000_adapter *adapter = container_of(work, struct e1000_adapter,
 						     systim_overflow_work.work);
 	struct e1000_hw *hw = &adapter->hw;
-	struct timespec ts;
+	struct timespec64 ts;
 
-	adapter->ptp_clock_info.gettime(&adapter->ptp_clock_info, &ts);
+	adapter->ptp_clock_info.gettime64(&adapter->ptp_clock_info, &ts);
 
-	e_dbg("SYSTIM overflow check at %ld.%09lu\n", ts.tv_sec, ts.tv_nsec);
+	e_dbg("SYSTIM overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
 
 	schedule_delayed_work(&adapter->systim_overflow_work,
 			      E1000_SYSTIM_OVERFLOW_PERIOD);
@@ -190,8 +190,8 @@ static const struct ptp_clock_info e1000e_ptp_clock_info = {
 	.pps		= 0,
 	.adjfreq	= e1000e_phc_adjfreq,
 	.adjtime	= e1000e_phc_adjtime,
-	.gettime	= e1000e_phc_gettime,
-	.settime	= e1000e_phc_settime,
+	.gettime64	= e1000e_phc_gettime,
+	.settime64	= e1000e_phc_settime,
 	.enable		= e1000e_phc_enable,
 };
 
-- 
1.7.10.4
