From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 13/23] ptp: igb: convert to the 64 bit get/set time methods.
Date: Sat, 21 Mar 2015 22:39:31 +0100
Message-ID: <c63a73eca6e75dc82990266ba2e787b58b684721.1426973658.git.richardcochran@gmail.com>
References: <cover.1426973658.git.richardcochran@gmail.com>
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
In-Reply-To: <cover.1426973658.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For the 82576, the driver's clock is implemented using a timecounter,
and so with this patch that device is ready for the year 2038.

However, in the case of the i210, the device stores the number of
seconds in a 32 bit register.  Therefore, more work is needed on this
driver before the year 2038 comes around.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c |   41 +++++++++++++++---------------
 1 file changed, 21 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 52d01b8..0348b7e 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -116,7 +116,8 @@ static cycle_t igb_ptp_read_82580(const struct cyclecounter *cc)
 }
 
 /* SYSTIM read access for I210/I211 */
-static void igb_ptp_read_i210(struct igb_adapter *adapter, struct timespec *ts)
+static void igb_ptp_read_i210(struct igb_adapter *adapter,
+			      struct timespec64 *ts)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 sec, nsec;
@@ -134,7 +135,7 @@ static void igb_ptp_read_i210(struct igb_adapter *adapter, struct timespec *ts)
 }
 
 static void igb_ptp_write_i210(struct igb_adapter *adapter,
-			       const struct timespec *ts)
+			       const struct timespec64 *ts)
 {
 	struct e1000_hw *hw = &adapter->hw;
 
@@ -269,13 +270,13 @@ static int igb_ptp_adjtime_i210(struct ptp_clock_info *ptp, s64 delta)
 	struct igb_adapter *igb = container_of(ptp, struct igb_adapter,
 					       ptp_caps);
 	unsigned long flags;
-	struct timespec now, then = ns_to_timespec(delta);
+	struct timespec64 now, then = ns_to_timespec64(delta);
 
 	spin_lock_irqsave(&igb->tmreg_lock, flags);
 
 	igb_ptp_read_i210(igb, &now);
-	now = timespec_add(now, then);
-	igb_ptp_write_i210(igb, (const struct timespec *)&now);
+	now = timespec64_add(now, then);
+	igb_ptp_write_i210(igb, (const struct timespec64 *)&now);
 
 	spin_unlock_irqrestore(&igb->tmreg_lock, flags);
 
@@ -283,7 +284,7 @@ static int igb_ptp_adjtime_i210(struct ptp_clock_info *ptp, s64 delta)
 }
 
 static int igb_ptp_gettime_82576(struct ptp_clock_info *ptp,
-				 struct timespec *ts)
+				 struct timespec64 *ts)
 {
 	struct igb_adapter *igb = container_of(ptp, struct igb_adapter,
 					       ptp_caps);
@@ -304,7 +305,7 @@ static int igb_ptp_gettime_82576(struct ptp_clock_info *ptp,
 }
 
 static int igb_ptp_gettime_i210(struct ptp_clock_info *ptp,
-				struct timespec *ts)
+				struct timespec64 *ts)
 {
 	struct igb_adapter *igb = container_of(ptp, struct igb_adapter,
 					       ptp_caps);
@@ -320,7 +321,7 @@ static int igb_ptp_gettime_i210(struct ptp_clock_info *ptp,
 }
 
 static int igb_ptp_settime_82576(struct ptp_clock_info *ptp,
-				 const struct timespec *ts)
+				 const struct timespec64 *ts)
 {
 	struct igb_adapter *igb = container_of(ptp, struct igb_adapter,
 					       ptp_caps);
@@ -340,7 +341,7 @@ static int igb_ptp_settime_82576(struct ptp_clock_info *ptp,
 }
 
 static int igb_ptp_settime_i210(struct ptp_clock_info *ptp,
-				const struct timespec *ts)
+				const struct timespec64 *ts)
 {
 	struct igb_adapter *igb = container_of(ptp, struct igb_adapter,
 					       ptp_caps);
@@ -627,11 +628,11 @@ static void igb_ptp_overflow_check(struct work_struct *work)
 {
 	struct igb_adapter *igb =
 		container_of(work, struct igb_adapter, ptp_overflow_work.work);
-	struct timespec ts;
+	struct timespec64 ts;
 
-	igb->ptp_caps.gettime(&igb->ptp_caps, &ts);
+	igb->ptp_caps.gettime64(&igb->ptp_caps, &ts);
 
-	pr_debug("igb overflow check at %ld.%09lu\n", ts.tv_sec, ts.tv_nsec);
+	pr_debug("igb overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
 
 	schedule_delayed_work(&igb->ptp_overflow_work,
 			      IGB_SYSTIM_OVERFLOW_PERIOD);
@@ -989,8 +990,8 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.pps = 0;
 		adapter->ptp_caps.adjfreq = igb_ptp_adjfreq_82576;
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_82576;
-		adapter->ptp_caps.gettime = igb_ptp_gettime_82576;
-		adapter->ptp_caps.settime = igb_ptp_settime_82576;
+		adapter->ptp_caps.gettime64 = igb_ptp_gettime_82576;
+		adapter->ptp_caps.settime64 = igb_ptp_settime_82576;
 		adapter->ptp_caps.enable = igb_ptp_feature_enable;
 		adapter->cc.read = igb_ptp_read_82576;
 		adapter->cc.mask = CYCLECOUNTER_MASK(64);
@@ -1009,8 +1010,8 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.pps = 0;
 		adapter->ptp_caps.adjfreq = igb_ptp_adjfreq_82580;
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_82576;
-		adapter->ptp_caps.gettime = igb_ptp_gettime_82576;
-		adapter->ptp_caps.settime = igb_ptp_settime_82576;
+		adapter->ptp_caps.gettime64 = igb_ptp_gettime_82576;
+		adapter->ptp_caps.settime64 = igb_ptp_settime_82576;
 		adapter->ptp_caps.enable = igb_ptp_feature_enable;
 		adapter->cc.read = igb_ptp_read_82580;
 		adapter->cc.mask = CYCLECOUNTER_MASK(IGB_NBITS_82580);
@@ -1038,8 +1039,8 @@ void igb_ptp_init(struct igb_adapter *adapter)
 		adapter->ptp_caps.pin_config = adapter->sdp_config;
 		adapter->ptp_caps.adjfreq = igb_ptp_adjfreq_82580;
 		adapter->ptp_caps.adjtime = igb_ptp_adjtime_i210;
-		adapter->ptp_caps.gettime = igb_ptp_gettime_i210;
-		adapter->ptp_caps.settime = igb_ptp_settime_i210;
+		adapter->ptp_caps.gettime64 = igb_ptp_gettime_i210;
+		adapter->ptp_caps.settime64 = igb_ptp_settime_i210;
 		adapter->ptp_caps.enable = igb_ptp_feature_enable_i210;
 		adapter->ptp_caps.verify = igb_ptp_verify_pin;
 		/* Enable the timer functions by clearing bit 31. */
@@ -1057,7 +1058,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 
 	/* Initialize the clock and overflow work for devices that need it. */
 	if ((hw->mac.type == e1000_i210) || (hw->mac.type == e1000_i211)) {
-		struct timespec ts = ktime_to_timespec(ktime_get_real());
+		struct timespec64 ts = ktime_to_timespec64(ktime_get_real());
 
 		igb_ptp_settime_i210(&adapter->ptp_caps, &ts);
 	} else {
@@ -1171,7 +1172,7 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 
 	/* Re-initialize the timer. */
 	if ((hw->mac.type == e1000_i210) || (hw->mac.type == e1000_i211)) {
-		struct timespec ts = ktime_to_timespec(ktime_get_real());
+		struct timespec64 ts = ktime_to_timespec64(ktime_get_real());
 
 		igb_ptp_write_i210(adapter, &ts);
 	} else {
-- 
1.7.10.4
