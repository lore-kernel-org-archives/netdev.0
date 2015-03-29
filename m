From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 05/23] ptp: xgbe: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:11:55 +0200
Message-ID: <d3a16a744ab9ad7ff2d600f1962b77a4ad23da2d.1427662907.git.richardcochran@gmail.com>
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

This driver's clock is implemented using a timecounter, and so with
this patch the driver is ready for the year 2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
index f326178..b03e4f5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
@@ -179,7 +179,7 @@ static int xgbe_adjtime(struct ptp_clock_info *info, s64 delta)
 	return 0;
 }
 
-static int xgbe_gettime(struct ptp_clock_info *info, struct timespec *ts)
+static int xgbe_gettime(struct ptp_clock_info *info, struct timespec64 *ts)
 {
 	struct xgbe_prv_data *pdata = container_of(info,
 						   struct xgbe_prv_data,
@@ -193,12 +193,13 @@ static int xgbe_gettime(struct ptp_clock_info *info, struct timespec *ts)
 
 	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
 
-	*ts = ns_to_timespec(nsec);
+	*ts = ns_to_timespec64(nsec);
 
 	return 0;
 }
 
-static int xgbe_settime(struct ptp_clock_info *info, const struct timespec *ts)
+static int xgbe_settime(struct ptp_clock_info *info,
+			const struct timespec64 *ts)
 {
 	struct xgbe_prv_data *pdata = container_of(info,
 						   struct xgbe_prv_data,
@@ -206,7 +207,7 @@ static int xgbe_settime(struct ptp_clock_info *info, const struct timespec *ts)
 	unsigned long flags;
 	u64 nsec;
 
-	nsec = timespec_to_ns(ts);
+	nsec = timespec64_to_ns(ts);
 
 	spin_lock_irqsave(&pdata->tstamp_lock, flags);
 
@@ -236,8 +237,8 @@ void xgbe_ptp_register(struct xgbe_prv_data *pdata)
 	info->max_adj = pdata->ptpclk_rate;
 	info->adjfreq = xgbe_adjfreq;
 	info->adjtime = xgbe_adjtime;
-	info->gettime = xgbe_gettime;
-	info->settime = xgbe_settime;
+	info->gettime64 = xgbe_gettime;
+	info->settime64 = xgbe_settime;
 	info->enable = xgbe_enable;
 
 	clock = ptp_clock_register(info, pdata->dev);
-- 
1.7.10.4
