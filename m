From: <netanel@amazon.com>
Subject: [PATCH net 4/9] net: ena: fix race condition between submit and completion admin command
Date: Sun, 11 Jun 2017 15:42:46 +0300
Message-ID: <1497184971-28178-5-git-send-email-netanel@amazon.com>
References: <1497184971-28178-1-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-6002.amazon.com ([52.95.49.90]:22528 "EHLO
        smtp-fw-6002.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751850AbdFKMxn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 08:53:43 -0400
In-Reply-To: <1497184971-28178-1-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Bug:
"Completion context is occupied" error printout will be noticed in
dmesg.
This error will cause the admin command to fail, which will lead to
an ena_probe() failure or a watchdog reset (depends on which admin
command failed).

Root cause:
__ena_com_submit_admin_cmd() is the function that submits new entries to
the admin queue.
The function have a check that makes sure the queue is not full and the
function does not override any outstanding command.
It uses head and tail indexes for this check.
The head is increased by ena_com_handle_admin_completion() which runs
from interrupt context, and the tail index is increased by the submit
function (the function is running under ->q_lock, so there is no risk
of multithread increment).
Each command is associated with a completion context. This context
allocated before call to __ena_com_submit_admin_cmd() and freed by
ena_com_wait_and_process_admin_cq_interrupts(), right after the command
was completed.

This can lead to a state where the head was increased, the check passed,
but the completion context is still in use.

Solution:
Use the atomic variable ->outstanding_cmds instead of using the head and
the tail indexes.
This variable is safe for use since it is bumped in get_comp_ctx() in
__ena_com_submit_admin_cmd() and is freed by comp_ctxt_release()

Fixes: 1738cd3ed342 ("Add a driver for Amazon Elastic Network Adapters (ENA)")
Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index e1c2fab6292f..ea60b9e67acb 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -232,11 +232,9 @@ static struct ena_comp_ctx *__ena_com_submit_admin_cmd(struct ena_com_admin_queu
 	tail_masked = admin_queue->sq.tail & queue_size_mask;
 
 	/* In case of queue FULL */
-	cnt = admin_queue->sq.tail - admin_queue->sq.head;
+	cnt = atomic_read(&admin_queue->outstanding_cmds);
 	if (cnt >= admin_queue->q_depth) {
-		pr_debug("admin queue is FULL (tail %d head %d depth: %d)\n",
-			 admin_queue->sq.tail, admin_queue->sq.head,
-			 admin_queue->q_depth);
+		pr_debug("admin queue is full.\n");
 		admin_queue->stats.out_of_space++;
 		return ERR_PTR(-ENOSPC);
 	}
-- 
2.7.4
