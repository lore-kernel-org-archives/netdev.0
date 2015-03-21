From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 03/23] ptp: use the 64 bit get/set time methods for the posix clock.
Date: Sat, 21 Mar 2015 22:39:21 +0100
Message-ID: <bec65650e57830a9ed0cbb1d454eeca0a39cc7b1.1426973658.git.richardcochran@gmail.com>
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

This patch changes the posix clock code to prefer the new methods
whenever they are implemented by the PHC drivers.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_clock.c |   19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
index 296b0ec..df50d5e 100644
--- a/drivers/ptp/ptp_clock.c
+++ b/drivers/ptp/ptp_clock.c
@@ -107,13 +107,28 @@ static int ptp_clock_getres(struct posix_clock *pc, struct timespec *tp)
 static int ptp_clock_settime(struct posix_clock *pc, const struct timespec *tp)
 {
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
-	return ptp->info->settime(ptp->info, tp);
+	struct timespec64 ts = timespec_to_timespec64(*tp);
+
+	return  ptp->info->settime64 ?
+		ptp->info->settime64(ptp->info, &ts) :
+		ptp->info->settime(ptp->info, tp);
 }
 
 static int ptp_clock_gettime(struct posix_clock *pc, struct timespec *tp)
 {
 	struct ptp_clock *ptp = container_of(pc, struct ptp_clock, clock);
-	return ptp->info->gettime(ptp->info, tp);
+	struct timespec64 ts;
+	int err;
+
+	if (ptp->info->gettime64) {
+		err = ptp->info->gettime64(ptp->info, &ts);
+		if (!err)
+			*tp = timespec64_to_timespec(ts);
+	} else {
+		err = ptp->info->gettime(ptp->info, tp);
+	}
+
+	return err;
 }
 
 static int ptp_clock_adjtime(struct posix_clock *pc, struct timex *tx)
-- 
1.7.10.4
