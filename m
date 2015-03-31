From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 08/11] ptp: ixgbe: use helpers for converting ns to timespec.
Date: Tue, 31 Mar 2015 23:08:13 +0200
Message-ID: <f7b4f8ac0c134cf49f635ecf10b96d8d46789288.1427835485.git.richardcochran@gmail.com>
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
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 75b9e93..e5ba040 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -284,15 +284,13 @@ static int ixgbe_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 	struct ixgbe_adapter *adapter =
 		container_of(ptp, struct ixgbe_adapter, ptp_caps);
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
@@ -313,8 +311,7 @@ static int ixgbe_ptp_settime(struct ptp_clock_info *ptp,
 	u64 ns;
 	unsigned long flags;
 
-	ns = ts->tv_sec * 1000000000ULL;
-	ns += ts->tv_nsec;
+	ns = timespec64_to_ns(ts);
 
 	/* reset the timecounter */
 	spin_lock_irqsave(&adapter->tmreg_lock, flags);
-- 
1.7.10.4
