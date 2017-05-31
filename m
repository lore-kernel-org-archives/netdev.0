From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net] cxgb4: avoid enabling napi twice to the same queue
Date: Wed, 31 May 2017 18:26:28 +0530
Message-ID: <1496235388-20496-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, indranil@chelsio.com,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:35656 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751011AbdEaM4j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 08:56:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Take uld mutex to avoid race between cxgb_up() and
cxgb4_register_uld() to enable napi for the same uld
queue.

Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index b512149..77ed2f6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2196,10 +2196,14 @@ static int cxgb_up(struct adapter *adap)
 		if (err)
 			goto irq_err;
 	}
+
+	mutex_lock(&uld_mutex);
 	enable_rx(adap);
 	t4_sge_start(adap);
 	t4_intr_enable(adap);
 	adap->flags |= FULL_INIT_DONE;
+	mutex_unlock(&uld_mutex);
+
 	notify_ulds(adap, CXGB4_STATE_UP);
 #if IS_ENABLED(CONFIG_IPV6)
 	update_clip(adap);
-- 
2.1.0
