From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-2.6 1/2] cnic: Prevent status block race conditions
 with hardware
Date: Wed, 2 Mar 2011 15:00:49 -0800
Message-ID: <1299106850-23645-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1292 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755733Ab1CBXzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 18:55:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The status block index is used to acknowledge interrupt events and must
be read before checking for the interrupt events, so we need to add rmb()
to guarantee that.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 7ff170c..b0d9e4a 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2760,6 +2760,8 @@ static u32 cnic_service_bnx2_queues(struct cnic_dev *dev)
 	u32 status_idx = (u16) *cp->kcq1.status_idx_ptr;
 	int kcqe_cnt;
 
+	/* status block index must be read before reading other fields */
+	rmb();
 	cp->kwq_con_idx = *cp->kwq_con_idx_ptr;
 
 	while ((kcqe_cnt = cnic_get_kcqes(dev, &cp->kcq1))) {
@@ -2770,6 +2772,8 @@ static u32 cnic_service_bnx2_queues(struct cnic_dev *dev)
 		barrier();
 		if (status_idx != *cp->kcq1.status_idx_ptr) {
 			status_idx = (u16) *cp->kcq1.status_idx_ptr;
+			/* status block index must be read first */
+			rmb();
 			cp->kwq_con_idx = *cp->kwq_con_idx_ptr;
 		} else
 			break;
@@ -2888,6 +2892,8 @@ static u32 cnic_service_bnx2x_kcq(struct cnic_dev *dev, struct kcq_info *info)
 	u32 last_status = *info->status_idx_ptr;
 	int kcqe_cnt;
 
+	/* status block index must be read before reading the KCQ */
+	rmb();
 	while ((kcqe_cnt = cnic_get_kcqes(dev, info))) {
 
 		service_kcqes(dev, kcqe_cnt);
@@ -2898,6 +2904,8 @@ static u32 cnic_service_bnx2x_kcq(struct cnic_dev *dev, struct kcq_info *info)
 			break;
 
 		last_status = *info->status_idx_ptr;
+		/* status block index must be read before reading the KCQ */
+		rmb();
 	}
 	return last_status;
 }
-- 
1.6.4.GIT


