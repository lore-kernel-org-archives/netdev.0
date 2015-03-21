From: Richard Cochran <richardcochran@gmail.com>
Subject: [RFC net-next 15/22] ptp: sfc: convert to the 64 bit get/set time methods.
Date: Sat, 21 Mar 2015 21:59:45 +0100
Message-ID: <050616911b4ce1f899147f8fb2d69fcd53034cd4.1426970294.git.richardcochran@gmail.com>
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

This patch changes the driver to use the newer API.

Depending on how the hardware represents a time value, this driver may
or may not yet be ready for the year 2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/sfc/ptp.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 6b861e3..a2e9aee 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -323,9 +323,9 @@ struct efx_ptp_data {
 
 static int efx_phc_adjfreq(struct ptp_clock_info *ptp, s32 delta);
 static int efx_phc_adjtime(struct ptp_clock_info *ptp, s64 delta);
-static int efx_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts);
+static int efx_phc_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts);
 static int efx_phc_settime(struct ptp_clock_info *ptp,
-			   const struct timespec *e_ts);
+			   const struct timespec64 *e_ts);
 static int efx_phc_enable(struct ptp_clock_info *ptp,
 			  struct ptp_clock_request *request, int on);
 
@@ -1198,8 +1198,8 @@ static const struct ptp_clock_info efx_phc_clock_info = {
 	.pps		= 1,
 	.adjfreq	= efx_phc_adjfreq,
 	.adjtime	= efx_phc_adjtime,
-	.gettime	= efx_phc_gettime,
-	.settime	= efx_phc_settime,
+	.gettime64	= efx_phc_gettime,
+	.settime64	= efx_phc_settime,
 	.enable		= efx_phc_enable,
 };
 
@@ -1837,7 +1837,7 @@ static int efx_phc_adjtime(struct ptp_clock_info *ptp, s64 delta)
 			    NULL, 0, NULL);
 }
 
-static int efx_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int efx_phc_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	struct efx_ptp_data *ptp_data = container_of(ptp,
 						     struct efx_ptp_data,
@@ -1859,28 +1859,28 @@ static int efx_phc_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 	kt = ptp_data->nic_to_kernel_time(
 		MCDI_DWORD(outbuf, PTP_OUT_READ_NIC_TIME_MAJOR),
 		MCDI_DWORD(outbuf, PTP_OUT_READ_NIC_TIME_MINOR), 0);
-	*ts = ktime_to_timespec(kt);
+	*ts = ktime_to_timespec64(kt);
 	return 0;
 }
 
 static int efx_phc_settime(struct ptp_clock_info *ptp,
-			   const struct timespec *e_ts)
+			   const struct timespec64 *e_ts)
 {
 	/* Get the current NIC time, efx_phc_gettime.
 	 * Subtract from the desired time to get the offset
 	 * call efx_phc_adjtime with the offset
 	 */
 	int rc;
-	struct timespec time_now;
-	struct timespec delta;
+	struct timespec64 time_now;
+	struct timespec64 delta;
 
 	rc = efx_phc_gettime(ptp, &time_now);
 	if (rc != 0)
 		return rc;
 
-	delta = timespec_sub(*e_ts, time_now);
+	delta = timespec64_sub(*e_ts, time_now);
 
-	rc = efx_phc_adjtime(ptp, timespec_to_ns(&delta));
+	rc = efx_phc_adjtime(ptp, timespec64_to_ns(&delta));
 	if (rc != 0)
 		return rc;
 
-- 
1.7.10.4
