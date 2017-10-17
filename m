From: <netanel@amazon.com>
Subject: [PATCH net-next 1/6] net: ena: improve ENA driver boot time.
Date: Tue, 17 Oct 2017 07:33:56 +0000
Message-ID: <1508225641-106366-2-git-send-email-netanel@amazon.com>
References: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:23398 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933027AbdJQHeb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:34:31 -0400
In-Reply-To: <1508225641-106366-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

The ena admin commands timeout is in resolutions of 100ms.
Therefore, When the driver works in polling mode, it sleeps for 100ms
each time. The overall boot time of the ENA driver is ~1.5 sec.
To reduce the boot time, This change modifies the granularity of
the sleeps to 5ms.
This change improves the boot time to 220ms.

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index ded29af648c9..bf2de5298005 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -63,6 +63,8 @@
 
 #define ENA_REGS_ADMIN_INTR_MASK 1
 
+#define ENA_POLL_MS	5
+
 /*****************************************************************************/
 /*****************************************************************************/
 /*****************************************************************************/
@@ -533,7 +535,7 @@ static int ena_com_wait_and_process_admin_cq_polling(struct ena_comp_ctx *comp_c
 			goto err;
 		}
 
-		msleep(100);
+		msleep(ENA_POLL_MS);
 	}
 
 	if (unlikely(comp_ctx->status == ENA_CMD_ABORTED)) {
@@ -746,6 +748,9 @@ static int wait_for_reset_state(struct ena_com_dev *ena_dev, u32 timeout,
 {
 	u32 val, i;
 
+	/* Convert timeout from resolution of 100ms to ENA_POLL_MS */
+	timeout = (timeout * 100) / ENA_POLL_MS;
+
 	for (i = 0; i < timeout; i++) {
 		val = ena_com_reg_bar_read32(ena_dev, ENA_REGS_DEV_STS_OFF);
 
@@ -758,8 +763,7 @@ static int wait_for_reset_state(struct ena_com_dev *ena_dev, u32 timeout,
 			exp_state)
 			return 0;
 
-		/* The resolution of the timeout is 100ms */
-		msleep(100);
+		msleep(ENA_POLL_MS);
 	}
 
 	return -ETIME;
@@ -1253,7 +1257,7 @@ void ena_com_wait_for_abort_completion(struct ena_com_dev *ena_dev)
 	spin_lock_irqsave(&admin_queue->q_lock, flags);
 	while (atomic_read(&admin_queue->outstanding_cmds) != 0) {
 		spin_unlock_irqrestore(&admin_queue->q_lock, flags);
-		msleep(20);
+		msleep(ENA_POLL_MS);
 		spin_lock_irqsave(&admin_queue->q_lock, flags);
 	}
 	spin_unlock_irqrestore(&admin_queue->q_lock, flags);
-- 
1.8.3.1
