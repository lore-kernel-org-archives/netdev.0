From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio VF: reduce load time of module
Date: Wed, 11 Jan 2017 17:40:27 -0800
Message-ID: <20170112014027.GA9704@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0069.outbound.protection.outlook.com ([104.47.37.69]:58507
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752912AbdALBla (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 20:41:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasad Kanneganti <prasad.kanneganti@cavium.com>

Reduce the load time of the VF driver by decreasing the wait time between
iterations of the loop that polls for a mailbox response from the PF. Also
change the wait time units from jiffies to milliseconds.

Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c | 5 +++--
 drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h | 4 ++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
index 73696b42..201b987 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.c
@@ -131,6 +131,7 @@ int octeon_mbox_write(struct octeon_device *oct,
 {
 	struct octeon_mbox *mbox = oct->mbox[mbox_cmd->q_no];
 	u32 count, i, ret = OCTEON_MBOX_STATUS_SUCCESS;
+	long timeout = LIO_MBOX_WRITE_WAIT_TIME;
 	unsigned long flags;
 
 	spin_lock_irqsave(&mbox->lock, flags);
@@ -158,7 +159,7 @@ int octeon_mbox_write(struct octeon_device *oct,
 	count = 0;
 
 	while (readq(mbox->mbox_write_reg) != OCTEON_PFVFSIG) {
-		schedule_timeout_uninterruptible(LIO_MBOX_WRITE_WAIT_TIME);
+		schedule_timeout_uninterruptible(timeout);
 		if (count++ == LIO_MBOX_WRITE_WAIT_CNT) {
 			ret = OCTEON_MBOX_STATUS_FAILED;
 			break;
@@ -171,7 +172,7 @@ int octeon_mbox_write(struct octeon_device *oct,
 			count = 0;
 			while (readq(mbox->mbox_write_reg) !=
 			       OCTEON_PFVFACK) {
-				schedule_timeout_uninterruptible(10);
+				schedule_timeout_uninterruptible(timeout);
 				if (count++ == LIO_MBOX_WRITE_WAIT_CNT) {
 					ret = OCTEON_MBOX_STATUS_FAILED;
 					break;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h
index fe60a3e..c9376fe 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mailbox.h
@@ -31,8 +31,8 @@
 #define OCTEON_PFVFSIG			0x1122334455667788
 #define OCTEON_PFVFERR			0xDEADDEADDEADDEAD
 
-#define LIO_MBOX_WRITE_WAIT_CNT          1000
-#define LIO_MBOX_WRITE_WAIT_TIME           10
+#define LIO_MBOX_WRITE_WAIT_CNT         1000
+#define LIO_MBOX_WRITE_WAIT_TIME        msecs_to_jiffies(1)
 
 enum octeon_mbox_cmd_status {
 	OCTEON_MBOX_STATUS_SUCCESS = 0,
