From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/5 net-next] cnic: Fix interrupt logic
Date: Wed, 8 Jun 2011 22:29:32 -0700
Message-ID: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1234 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364Ab1FIGVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 02:21:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to keep looping until cnic_get_kcqes() returns 0.  cnic_get_kcqes()
returns a maximum of 64 entries.  If there are more entries in the queue
and we don't loop back, the remaining entries may not be serviced for a
long time.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 11a92af..5c0a669 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2778,13 +2778,10 @@ static u32 cnic_service_bnx2_queues(struct cnic_dev *dev)
 
 		/* Tell compiler that status_blk fields can change. */
 		barrier();
-		if (status_idx != *cp->kcq1.status_idx_ptr) {
-			status_idx = (u16) *cp->kcq1.status_idx_ptr;
-			/* status block index must be read first */
-			rmb();
-			cp->kwq_con_idx = *cp->kwq_con_idx_ptr;
-		} else
-			break;
+		status_idx = (u16) *cp->kcq1.status_idx_ptr;
+		/* status block index must be read first */
+		rmb();
+		cp->kwq_con_idx = *cp->kwq_con_idx_ptr;
 	}
 
 	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx);
@@ -2908,8 +2905,6 @@ static u32 cnic_service_bnx2x_kcq(struct cnic_dev *dev, struct kcq_info *info)
 
 		/* Tell compiler that sblk fields can change. */
 		barrier();
-		if (last_status == *info->status_idx_ptr)
-			break;
 
 		last_status = *info->status_idx_ptr;
 		/* status block index must be read before reading the KCQ */
-- 
1.6.4.GIT


