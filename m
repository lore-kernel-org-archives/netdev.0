From: Andy Gospodarek <gospo@broadcom.com>
Subject: [PATCH net] bnxt: do not busy-poll when link is down
Date: Tue, 22 Nov 2016 13:14:08 -0500
Message-ID: <1479838448-44877-1-git-send-email-gospo@broadcom.com>
Cc: Andy Gospodarek <gospo@broadcom.com>,
        Michael Chan <michael.chan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:45624 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbcKVSUf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 13:20:35 -0500
Received: from mail-irv-17.broadcom.com (smtphost.broadcom.com [10.15.198.34])
        by relay.smtp.broadcom.com (Postfix) with ESMTP id 0E243280427
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2016 10:14:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When busy polling while a link is down (during a link-flap test), TX
timeouts were observed as well as the following messages in the ring
buffer:

bnxt_en 0008:01:00.2 enP8p1s0f2d2: Resp cmpl intr err msg: 0x51
bnxt_en 0008:01:00.2 enP8p1s0f2d2: hwrm_ring_free tx failed. rc:-1
bnxt_en 0008:01:00.2 enP8p1s0f2d2: Resp cmpl intr err msg: 0x51
bnxt_en 0008:01:00.2 enP8p1s0f2d2: hwrm_ring_free rx failed. rc:-1

These were resolved by checking for link status and returning if link
was not up.

Signed-off-by: Andy Gospodarek <gospo@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
Tested-by: Rob Miller <rob.miller@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index e18635b..013e373 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1811,6 +1811,9 @@ static int bnxt_busy_poll(struct napi_struct *napi)
 	if (atomic_read(&bp->intr_sem) != 0)
 		return LL_FLUSH_FAILED;
 
+	if (!bp->link_info.link_up)
+		return LL_FLUSH_FAILED;
+
 	if (!bnxt_lock_poll(bnapi))
 		return LL_FLUSH_BUSY;
 
-- 
2.1.0
