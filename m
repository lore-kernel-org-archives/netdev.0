From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net] tg3: Fix race condition in tg3_get_stats64().
Date: Fri,  6 Jan 2017 16:18:53 -0500
Message-ID: <1483737533-25059-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, wangyufen@huawei.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35515 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbdAFV0X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 16:26:23 -0500
Received: by mail-pf0-f181.google.com with SMTP id f144so6544653pfa.2
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 13:26:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver's ndo_get_stats64() method is not always called under RTNL.
So it can race with driver close or ethtool reconfigurations.  Fix the
race condition by taking tp->lock spinlock in tg3_free_consistent()
when freeing the tp->hw_stats memory block.  tg3_get_stats64() is
already taking tp->lock.

Reported-by: Wang Yufen <wangyufen@huawei.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 185e9e0..ae42de4 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -8720,11 +8720,14 @@ static void tg3_free_consistent(struct tg3 *tp)
 	tg3_mem_rx_release(tp);
 	tg3_mem_tx_release(tp);
 
+	/* Protect tg3_get_stats64() from reading freed tp->hw_stats. */
+	tg3_full_lock(tp, 0);
 	if (tp->hw_stats) {
 		dma_free_coherent(&tp->pdev->dev, sizeof(struct tg3_hw_stats),
 				  tp->hw_stats, tp->stats_mapping);
 		tp->hw_stats = NULL;
 	}
+	tg3_full_unlock(tp);
 }
 
 /*
-- 
1.8.3.1
