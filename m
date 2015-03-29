From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 11/23] ptp: fm10k: convert to the 64 bit get/set time methods.
Date: Sun, 29 Mar 2015 23:12:01 +0200
Message-ID: <a86165db2868a60047ba1ba04ff570afafd54054.1427662907.git.richardcochran@gmail.com>
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

The device appears to use a 64 bit nanoseconds register, and so with
this patch the driver should be ready for the year 2038.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
index d966044..02008e9 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ptp.c
@@ -285,7 +285,7 @@ static int fm10k_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return 0;
 }
 
-static int fm10k_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int fm10k_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	struct fm10k_intfc *interface;
 	unsigned long flags;
@@ -297,17 +297,17 @@ static int fm10k_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 	now = fm10k_systime_read(interface) + interface->ptp_adjust;
 	read_unlock_irqrestore(&interface->systime_lock, flags);
 
-	*ts = ns_to_timespec(now);
+	*ts = ns_to_timespec64(now);
 
 	return 0;
 }
 
 static int fm10k_ptp_settime(struct ptp_clock_info *ptp,
-			     const struct timespec *ts)
+			     const struct timespec64 *ts)
 {
 	struct fm10k_intfc *interface;
 	unsigned long flags;
-	u64 ns = timespec_to_ns(ts);
+	u64 ns = timespec64_to_ns(ts);
 
 	interface = container_of(ptp, struct fm10k_intfc, ptp_caps);
 
@@ -419,8 +419,8 @@ void fm10k_ptp_register(struct fm10k_intfc *interface)
 	ptp_caps->max_adj	= 976562;
 	ptp_caps->adjfreq	= fm10k_ptp_adjfreq;
 	ptp_caps->adjtime	= fm10k_ptp_adjtime;
-	ptp_caps->gettime	= fm10k_ptp_gettime;
-	ptp_caps->settime	= fm10k_ptp_settime;
+	ptp_caps->gettime64	= fm10k_ptp_gettime;
+	ptp_caps->settime64	= fm10k_ptp_settime;
 
 	/* provide pins if BAR4 is accessible */
 	if (interface->sw_addr) {
-- 
1.7.10.4
