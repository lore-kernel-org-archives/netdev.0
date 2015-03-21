From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V2 20/23] ptp: dp83640: convert to the 64 bit get/set time methods.
Date: Sat, 21 Mar 2015 22:39:38 +0100
Message-ID: <55b6ec7c2e0c72a79762748981fad2ce2497f22d.1426973658.git.richardcochran@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:34807 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138AbbCUVkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 17:40:36 -0400
In-Reply-To: <cover.1426973658.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device stores the number of seconds in a 32 bit register.  So
more work is needed on this driver before the year 2038 comes around.

Compile tested only.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/phy/dp83640.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index e22e602..1a88235 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -427,7 +427,8 @@ static int ptp_dp83640_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	return err;
 }
 
-static int ptp_dp83640_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+static int ptp_dp83640_gettime(struct ptp_clock_info *ptp,
+			       struct timespec64 *ts)
 {
 	struct dp83640_clock *clock =
 		container_of(ptp, struct dp83640_clock, caps);
@@ -452,16 +453,17 @@ static int ptp_dp83640_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 }
 
 static int ptp_dp83640_settime(struct ptp_clock_info *ptp,
-			       const struct timespec *ts)
+			       const struct timespec64 *ts64)
 {
 	struct dp83640_clock *clock =
 		container_of(ptp, struct dp83640_clock, caps);
 	struct phy_device *phydev = clock->chosen->phydev;
+	struct timespec ts = timespec64_to_timespec(*ts64);
 	int err;
 
 	mutex_lock(&clock->extreg_lock);
 
-	err = tdr_write(1, phydev, ts, PTP_LOAD_CLK);
+	err = tdr_write(1, phydev, &ts, PTP_LOAD_CLK);
 
 	mutex_unlock(&clock->extreg_lock);
 
@@ -998,8 +1000,8 @@ static void dp83640_clock_init(struct dp83640_clock *clock, struct mii_bus *bus)
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
