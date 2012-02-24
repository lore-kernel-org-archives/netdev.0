From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 3/5] be2net: reset queue address after freeing
Date: Fri, 24 Feb 2012 10:20:15 +0530
Message-ID: <1330059017-5976-4-git-send-email-sathya.perla@emulex.com>
References: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:20274 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756126Ab2BXEzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 23:55:43 -0500
In-Reply-To: <1330059017-5976-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will prevent double free in some cases where be_clear() is called
for cleanup when be_setup() fails half-way.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 36ad9a7..e382278 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -127,9 +127,11 @@ static inline bool be_is_mc(struct be_adapter *adapter) {
 static void be_queue_free(struct be_adapter *adapter, struct be_queue_info *q)
 {
 	struct be_dma_mem *mem = &q->dma_mem;
-	if (mem->va)
+	if (mem->va) {
 		dma_free_coherent(&adapter->pdev->dev, mem->size, mem->va,
 				  mem->dma);
+		mem->va = NULL;
+	}
 }
 
 static int be_queue_alloc(struct be_adapter *adapter, struct be_queue_info *q,
@@ -1660,7 +1662,7 @@ static int be_evt_queues_create(struct be_adapter *adapter)
 		if (rc)
 			return rc;
 	}
-	return rc;
+	return 0;
 }
 
 static void be_mcc_queues_destroy(struct be_adapter *adapter)
-- 
1.7.4
