From: <netanel@amazon.com>
Subject: [PATCH net-next 1/8] net: ena: fix rare uncompleted admin command false alarm
Date: Sat, 10 Jun 2017 01:13:50 +0300
Message-ID: <1497046437-20390-2-git-send-email-netanel@amazon.com>
References: <1497046437-20390-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:7327 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751645AbdFIWOw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 18:14:52 -0400
In-Reply-To: <1497046437-20390-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

The current flow to detect admin completion is:
while (command_not_completed) {
	if (timeout)
		error

	check_for_completion()
		sleep()
   }
So in case the sleep took more than the timeout
(in case the thread/workqueue was not scheduled due to higher priority
task or prolonged VMexit), the driver can detect a stall even if
the completion is present.

The fix changes the order of this function to first check for
completion and only after that check if the timeout expired.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index 08d11ce..e1c2fab 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -508,15 +508,20 @@ static int ena_com_comp_status_to_errno(u8 comp_status)
 static int ena_com_wait_and_process_admin_cq_polling(struct ena_comp_ctx *comp_ctx,
 						     struct ena_com_admin_queue *admin_queue)
 {
-	unsigned long flags;
-	u32 start_time;
+	unsigned long flags, timeout;
 	int ret;
 
-	start_time = ((u32)jiffies_to_usecs(jiffies));
+	timeout = jiffies + ADMIN_CMD_TIMEOUT_US;
+
+	while (1) {
+		spin_lock_irqsave(&admin_queue->q_lock, flags);
+		ena_com_handle_admin_completion(admin_queue);
+		spin_unlock_irqrestore(&admin_queue->q_lock, flags);
 
-	while (comp_ctx->status == ENA_CMD_SUBMITTED) {
-		if ((((u32)jiffies_to_usecs(jiffies)) - start_time) >
-		    ADMIN_CMD_TIMEOUT_US) {
+		if (comp_ctx->status != ENA_CMD_SUBMITTED)
+			break;
+
+		if (time_is_before_jiffies(timeout)) {
 			pr_err("Wait for completion (polling) timeout\n");
 			/* ENA didn't have any completion */
 			spin_lock_irqsave(&admin_queue->q_lock, flags);
@@ -528,10 +533,6 @@ static int ena_com_wait_and_process_admin_cq_polling(struct ena_comp_ctx *comp_c
 			goto err;
 		}
 
-		spin_lock_irqsave(&admin_queue->q_lock, flags);
-		ena_com_handle_admin_completion(admin_queue);
-		spin_unlock_irqrestore(&admin_queue->q_lock, flags);
-
 		msleep(100);
 	}
 
-- 
2.7.4
