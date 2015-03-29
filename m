From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 20/23] ptp: dp83640: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:12:10 +0200
Message-ID: <b5e220fd0b5d96288d2aa732f79e905421345e43.1427662907.git.richardcochran@gmail.com>
References: <cover.1427662906.git.richardcochran@gmail.com>
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
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rayagond K <rayagond@vayavyalabs.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zha
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427662906.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This device stores the number of seconds in a 32 bit register, and the
stored value is unsigned.  Therefore this driver and device are ready
for the year 2038.  However, more work will be needed prior to 2106.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c |   19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index e22e602..a83f8e5 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -257,7 +257,7 @@ static void ext_write(int broadcast, struct phy_device *phydev,
 
 /* Caller must hold extreg_lock. */
 static int tdr_write(int bc, struct phy_device *dev,
-		     const struct timespec *ts, u16 cmd)
+		     const struct timespec64 *ts, u16 cmd)
 {
 	ext_write(bc, dev, PAGE4, PTP_TDR, ts->tv_nsec & 0xffff);/* ns[15:0]  */
 	ext_write(bc, dev, PAGE4, PTP_TDR, ts->tv_nsec >> 16);   /* ns[31:16] */
@@ -411,12 +411,12 @@ static int ptp_dp83640_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	struct dp83640_clock *clock =
 		container_of(ptp, struct dp83640_clock, caps);
 	struct phy_device *phydev = clock->chosen->phydev;
-	struct timespec ts;
+	struct timespec64 ts;
 	int err;
 
 	delta += ADJTIME_FIX;
 
-	ts = ns_to_timespec(delta);
+	ts = ns_to_timespec64(delta);
 
 	mutex_lock(&clock->extreg_lock);
 
@@ -427,7 +427,8 @@ static int ptp_dp83640_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return err;
 }
 
-static int ptp_dp83640_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int ptp_dp83640_gettime(struct ptp_clock_info *ptp,
+			       struct timespec64 *ts)
 {
 	struct dp83640_clock *clock =
 		container_of(ptp, struct dp83640_clock, caps);
@@ -452,7 +453,7 @@ static int ptp_dp83640_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 }
 
 static int ptp_dp83640_settime(struct ptp_clock_info *ptp,
-			       const struct timespec *ts)
+			       const struct timespec64 *ts)
 {
 	struct dp83640_clock *clock =
 		container_of(ptp, struct dp83640_clock, caps);
@@ -605,7 +606,7 @@ static void recalibrate(struct dp83640_clock *clock)
 {
 	s64 now, diff;
 	struct phy_txts event_ts;
-	struct timespec ts;
+	struct timespec64 ts;
 	struct list_head *this;
 	struct dp83640_private *tmp;
 	struct phy_device *master = clock->chosen->phydev;
@@ -697,7 +698,7 @@ static void recalibrate(struct dp83640_clock *clock)
 		diff = now - (s64) phy2txts(&event_ts);
 		pr_info("slave offset %lld nanoseconds\n", diff);
 		diff += ADJTIME_FIX;
-		ts = ns_to_timespec(diff);
+		ts = ns_to_timespec64(diff);
 		tdr_write(0, tmp->phydev, &ts, PTP_STEP_CLK);
 	}
 
@@ -998,8 +999,8 @@ static void dp83640_clock_init(struct dp83640_clock *clock, struct mii_bus *bus)
 	clock->caps.pps		= 0;
 	clock->caps.adjfreq	= ptp_dp83640_adjfreq;
 	clock->caps.adjtime	= ptp_dp83640_adjtime;
-	clock->caps.gettime	= ptp_dp83640_gettime;
-	clock->caps.settime	= ptp_dp83640_settime;
+	clock->caps.gettime64	= ptp_dp83640_gettime;
+	clock->caps.settime64	= ptp_dp83640_settime;
 	clock->caps.enable	= ptp_dp83640_enable;
 	clock->caps.verify	= ptp_dp83640_verify;
 	/*
-- 
1.7.10.4
