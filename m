From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] cnic: Fix rtnl deadlock
Date: Fri, 8 Apr 2011 10:44:14 -0700
Message-ID: <1302284654-25864-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2081 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756856Ab1DHShZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 14:37:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When cnic_stop_hw() -> cnic_cm_stop_bnx2x_hw() is called under rtnl_lock()
from NETDEV_DOWN event, it waits for cnic_delete_task() to complete.
It will deadlock when cnic_delete_task() takes rtnl_lock() before
calling cnic_ulp_stop_one().

We fix it by removing the rtnl_lock() in cnic_delete_task().
cnic_ulp_stop_one() has mutex and atomic bit ops to prevent important
operations from being done more than once, so it is not necessary to take
rtnl_lock().

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 5dfbff0..cde59b4 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3983,9 +3983,7 @@ static void cnic_delete_task(struct work_struct *work)
 	if (test_and_clear_bit(CNIC_LCL_FL_STOP_ISCSI, &cp->cnic_local_flags)) {
 		struct drv_ctl_info info;
 
-		rtnl_lock();
 		cnic_ulp_stop_one(cp, CNIC_ULP_ISCSI);
-		rtnl_unlock();
 
 		info.cmd = DRV_CTL_ISCSI_STOPPED_CMD;
 		cp->ethdev->drv_ctl(dev->netdev, &info);
-- 
1.6.4.GIT


