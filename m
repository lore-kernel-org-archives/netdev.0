From: Richard Cochran <richardcochran@gmail.com>
Subject: [RFC net-next 18/22] ptp: tilegx: convert to the 64 bit get/set time methods.
Date: Sat, 21 Mar 2015 21:59:48 +0100
Message-ID: <73f0fb1696e83d372ec97b608234f7b385e2b7a5.1426970294.git.richardcochran@gmail.com>
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

This driver calls code (via gxio_mpipe_get/set_timestamp) that makes
the assumption that the tv_sec field is 64 bits wide.  So apparently
this driver is 64 bit only.  So maybe this driver and device are ready
for 2038, but maybe not.

Not even compile tested.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/tile/tilegx.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index bea8cd2..614ea83 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -838,24 +838,28 @@ static int ptp_mpipe_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return ret;
 }
 
-static int ptp_mpipe_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int ptp_mpipe_gettime(struct ptp_clock_info *ptp,
+			     struct timespec64 *ts64)
 {
 	int ret = 0;
 	struct mpipe_data *md = container_of(ptp, struct mpipe_data, caps);
+	struct timespec ts;
 	mutex_lock(&md->ptp_lock);
-	if (gxio_mpipe_get_timestamp(&md->context, ts))
+	if (gxio_mpipe_get_timestamp(&md->context, &ts))
 		ret = -EBUSY;
 	mutex_unlock(&md->ptp_lock);
+	*ts64 = timespec_to_timespec64(ts);
 	return ret;
 }
 
 static int ptp_mpipe_settime(struct ptp_clock_info *ptp,
-			     const struct timespec *ts)
+			     const struct timespec64 *ts64)
 {
 	int ret = 0;
+	struct timespec ts = timespec64_to_timespec(*ts64);
 	struct mpipe_data *md = container_of(ptp, struct mpipe_data, caps);
 	mutex_lock(&md->ptp_lock);
-	if (gxio_mpipe_set_timestamp(&md->context, ts))
+	if (gxio_mpipe_set_timestamp(&md->context, &ts))
 		ret = -EBUSY;
 	mutex_unlock(&md->ptp_lock);
 	return ret;
@@ -876,8 +880,8 @@ static struct ptp_clock_info ptp_mpipe_caps = {
 	.pps		= 0,
 	.adjfreq	= ptp_mpipe_adjfreq,
 	.adjtime	= ptp_mpipe_adjtime,
-	.gettime	= ptp_mpipe_gettime,
-	.settime	= ptp_mpipe_settime,
+	.gettime64	= ptp_mpipe_gettime,
+	.settime64	= ptp_mpipe_settime,
 	.enable		= ptp_mpipe_enable,
 };
 
-- 
1.7.10.4
