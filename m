From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 01/10] qed: Release CQ resource under lock on failure
Date: Mon, 20 Feb 2017 22:43:30 +0200
Message-ID: <1487623419-6442-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ram Amrani <Ram.Amrani@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46408 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751126AbdBTU7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 15:59:31 -0500
In-Reply-To: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ram Amrani <Ram.Amrani@cavium.com>

The CQ resource pool is protected by a spin lock. When a CQ creation
fails it now deallocates under that lock as well.

Signed-off-by: Ram Amrani <Ram.Amrani@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index c3c8c50..50fdcd3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -948,7 +948,9 @@ static int qed_rdma_create_cq(void *rdma_cxt,
 
 err:
 	/* release allocated icid */
+	spin_lock_bh(&p_info->lock);
 	qed_bmap_release_id(p_hwfn, &p_info->cq_map, returned_id);
+	spin_unlock_bh(&p_info->lock);
 	DP_NOTICE(p_hwfn, "Create CQ failed, rc = %d\n", rc);
 
 	return rc;
-- 
1.9.3
