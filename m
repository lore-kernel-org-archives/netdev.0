From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net] bnx2x: limit fw delay in kdump to 5s after boot
Date: Thu,  7 May 2015 20:37:10 +0200
Message-ID: <1431023830-445-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbbEGSgn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 14:36:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 12a8541d5c82 "bnx2x: Delay during kdump load" added a 5 seconds
delay to bnx2x's probe function in the kdump case to let the firmware
realize the old driver is gone.

The problem with the delay is that it is per-device, so if you have
several bnx2x NICs in NPAR mode, the delays can accumulate to minutes.

Fix it by adjusting the delay so that we do not wait more than
necessary, i.e. no more delaying after 5 seconds of kernel boot time.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 556dcc1..fd52ce9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13371,8 +13371,13 @@ static int bnx2x_init_one(struct pci_dev *pdev,
 	/* Management FW 'remembers' living interfaces. Allow it some time
 	 * to forget previously living interfaces, allowing a proper re-load.
 	 */
-	if (is_kdump_kernel())
-		msleep(5000);
+	if (is_kdump_kernel()) {
+		ktime_t now = ktime_get_boottime();
+		ktime_t fw_ready_time = ktime_set(5, 0);
+
+		if (ktime_before(now, fw_ready_time))
+			msleep(ktime_ms_delta(fw_ready_time, now));
+	}
 
 	/* An estimated maximum supported CoS number according to the chip
 	 * version.
-- 
2.4.0
