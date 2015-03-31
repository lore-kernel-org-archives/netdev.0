From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 04/11] ptp: fec: use helpers for converting ns to timespec.
Date: Tue, 31 Mar 2015 23:08:09 +0200
Message-ID: <61ce28ae31fffa338831a8730e7c60f27a2ad62d.1427835485.git.richardcochran@gmail.com>
References: <cover.1427835485.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
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
	Sonic Zhang <sonic.zhang@analog.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Thomas Gleixner <tglx@linutronix.de>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427835485.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch changes the driver to use ns_to_timespec64() and
timespec64_to_ns() instead of open coding the same logic.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/freescale/fec_ptp.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index b833993..a583d89 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -395,15 +395,13 @@ static int fec_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 	struct fec_enet_private *adapter =
 	    container_of(ptp, struct fec_enet_private, ptp_caps);
 	u64 ns;
-	u32 remainder;
 	unsigned long flags;
 
 	spin_lock_irqsave(&adapter->tmreg_lock, flags);
 	ns = timecounter_read(&adapter->tc);
 	spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
 
-	ts->tv_sec = div_u64_rem(ns, 1000000000ULL, &remainder);
-	ts->tv_nsec = remainder;
+	*ts = ns_to_timespec64(ns);
 
 	return 0;
 }
@@ -433,8 +431,7 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
 		return -EINVAL;
 	}
 
-	ns = ts->tv_sec * 1000000000ULL;
-	ns += ts->tv_nsec;
+	ns = timespec64_to_ns(ts);
 	/* Get the timer value based on timestamp.
 	 * Update the counter with the masked value.
 	 */
-- 
1.7.10.4
