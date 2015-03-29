From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 19/23] ptp: tilegx: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:12:09 +0200
Message-ID: <1f1b045d69be2bf9f73e0883877fb2cb710b7084.1427662907.git.richardcochran@gmail.com>
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

This driver is 64 bit only, and so this driver and device are ready
for 2038.  This patch changes the driver to the new PHC and also
carries the timespec64 parameter on out to the gxio_mpipe_get-
set_timestamp functions, making explicit the fact that the tv_sec
field is 64 bits wide.

Not even compile tested.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 arch/tile/gxio/mpipe.c             |    4 ++--
 arch/tile/include/gxio/mpipe.h     |    4 ++--
 drivers/net/ethernet/tile/tilegx.c |    9 +++++----
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/arch/tile/gxio/mpipe.c b/arch/tile/gxio/mpipe.c
index 6f00e985..ee186e1 100644
--- a/arch/tile/gxio/mpipe.c
+++ b/arch/tile/gxio/mpipe.c
@@ -456,7 +456,7 @@ int gxio_mpipe_equeue_init(gxio_mpipe_equeue_t *equeue,
 EXPORT_SYMBOL_GPL(gxio_mpipe_equeue_init);
 
 int gxio_mpipe_set_timestamp(gxio_mpipe_context_t *context,
-			     const struct timespec *ts)
+			     const struct timespec64 *ts)
 {
 	cycles_t cycles = get_cycles();
 	return gxio_mpipe_set_timestamp_aux(context, (uint64_t)ts->tv_sec,
@@ -466,7 +466,7 @@ int gxio_mpipe_set_timestamp(gxio_mpipe_context_t *context,
 EXPORT_SYMBOL_GPL(gxio_mpipe_set_timestamp);
 
 int gxio_mpipe_get_timestamp(gxio_mpipe_context_t *context,
-			     struct timespec *ts)
+			     struct timespec64 *ts)
 {
 	int ret;
 	cycles_t cycles_prev, cycles_now, clock_rate;
diff --git a/arch/tile/include/gxio/mpipe.h b/arch/tile/include/gxio/mpipe.h
index e37cf4f..73e83a1 100644
--- a/arch/tile/include/gxio/mpipe.h
+++ b/arch/tile/include/gxio/mpipe.h
@@ -1830,7 +1830,7 @@ extern int gxio_mpipe_link_set_attr(gxio_mpipe_link_t *link, uint32_t attr,
  *  code.
  */
 extern int gxio_mpipe_get_timestamp(gxio_mpipe_context_t *context,
-				    struct timespec *ts);
+				    struct timespec64 *ts);
 
 /* Set the timestamp of mPIPE.
  *
@@ -1840,7 +1840,7 @@ extern int gxio_mpipe_get_timestamp(gxio_mpipe_context_t *context,
  *  code.
  */
 extern int gxio_mpipe_set_timestamp(gxio_mpipe_context_t *context,
-				    const struct timespec *ts);
+				    const struct timespec64 *ts);
 
 /* Adjust the timestamp of mPIPE.
  *
diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index bea8cd2..a789a20 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -838,7 +838,8 @@ static int ptp_mpipe_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return ret;
 }
 
-static int ptp_mpipe_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int ptp_mpipe_gettime(struct ptp_clock_info *ptp,
+			     struct timespec64 *ts)
 {
 	int ret = 0;
 	struct mpipe_data *md = container_of(ptp, struct mpipe_data, caps);
@@ -850,7 +851,7 @@ static int ptp_mpipe_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 }
 
 static int ptp_mpipe_settime(struct ptp_clock_info *ptp,
-			     const struct timespec *ts)
+			     const struct timespec64 *ts)
 {
 	int ret = 0;
 	struct mpipe_data *md = container_of(ptp, struct mpipe_data, caps);
@@ -876,8 +877,8 @@ static struct ptp_clock_info ptp_mpipe_caps = {
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
