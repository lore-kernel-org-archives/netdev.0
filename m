From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 1/3] qed: Release CQ resource under lock on failure
Date: Tue, 24 Jan 2017 23:15:21 +0200
Message-ID: <1485292523-8821-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1485292523-8821-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <Ram.Amrani@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:42035 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750850AbdAXVQA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:16:00 -0500
In-Reply-To: <1485292523-8821-1-git-send-email-Yuval.Mintz@cavium.com>
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
index bd4cad2..7ab6d4e 100644
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
1.8.3.1
