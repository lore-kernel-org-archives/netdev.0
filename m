From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 1/7] bnx2x: prevent crash when accessing PTP with interface down
Date: Fri,  3 Mar 2017 17:08:28 +0100
Message-ID: <20170303160834.4125-2-mschmidt@redhat.com>
References: <20170303160834.4125-1-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25416 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752122AbdCCQIs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 11:08:48 -0500
In-Reply-To: <20170303160834.4125-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible to crash the kernel by accessing a PTP device while its
associated bnx2x interface is down. Before the interface is brought up,
the timecounter is not initialized, so accessing it results in NULL
dereference.

Fix it by checking if the interface is up.

Use -ENETDOWN as the error code when the interface is down.
 -EFAULT in bnx2x_ptp_adjfreq() did not seem right.

Tested using phc_ctl get/set/adj/freq commands.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d8d06fdfc4..d57290b9ea 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13738,7 +13738,7 @@ static int bnx2x_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 	if (!netif_running(bp->dev)) {
 		DP(BNX2X_MSG_PTP,
 		   "PTP adjfreq called while the interface is down\n");
-		return -EFAULT;
+		return -ENETDOWN;
 	}
 
 	if (ppb < 0) {
@@ -13797,6 +13797,12 @@ static int bnx2x_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 {
 	struct bnx2x *bp = container_of(ptp, struct bnx2x, ptp_clock_info);
 
+	if (!netif_running(bp->dev)) {
+		DP(BNX2X_MSG_PTP,
+		   "PTP adjtime called while the interface is down\n");
+		return -ENETDOWN;
+	}
+
 	DP(BNX2X_MSG_PTP, "PTP adjtime called, delta = %llx\n", delta);
 
 	timecounter_adjtime(&bp->timecounter, delta);
@@ -13809,6 +13815,12 @@ static int bnx2x_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 	struct bnx2x *bp = container_of(ptp, struct bnx2x, ptp_clock_info);
 	u64 ns;
 
+	if (!netif_running(bp->dev)) {
+		DP(BNX2X_MSG_PTP,
+		   "PTP gettime called while the interface is down\n");
+		return -ENETDOWN;
+	}
+
 	ns = timecounter_read(&bp->timecounter);
 
 	DP(BNX2X_MSG_PTP, "PTP gettime called, ns = %llu\n", ns);
@@ -13824,6 +13836,12 @@ static int bnx2x_ptp_settime(struct ptp_clock_info *ptp,
 	struct bnx2x *bp = container_of(ptp, struct bnx2x, ptp_clock_info);
 	u64 ns;
 
+	if (!netif_running(bp->dev)) {
+		DP(BNX2X_MSG_PTP,
+		   "PTP settime called while the interface is down\n");
+		return -ENETDOWN;
+	}
+
 	ns = timespec64_to_ns(ts);
 
 	DP(BNX2X_MSG_PTP, "PTP settime called, ns = %llu\n", ns);
-- 
2.9.3
