From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH] cxgb4: fix invalid checks in alloc_uld_rxqs
Date: Tue, 23 Aug 2016 08:16:19 +0200
Message-ID: <1471932979-17864-1-git-send-email-a.hajda@samsung.com>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        linux-kernel@vger.kernel.org (open list)
To: Hariprasad S <hariprasad@chelsio.com>,
        netdev@vger.kernel.org (open list:CXGB4 ETHERNET DRIVER (CXGB4))
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Local variable msi_idx defined as unsigned int is always >= 0, thus both
'if' checks are always true. On the other side presence of USING_MSIX flag
suggests the checks should not be trivially true.
The simplest solution is to replace incorrect checks with direct testing
of adap->flags and remove spare variables.

The problem has been detected using semantic patch
scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
Hi,

I am not familiar with the code, and it is not clear to me, so my solution
can be incorrect, anyway there is an issue here.

Regards
Andrzej
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
index aac6e44..1e0c952 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.c
@@ -121,20 +121,14 @@ static int alloc_uld_rxqs(struct adapter *adap,
 			  struct sge_uld_rxq_info *rxq_info,
 			  unsigned int nq, unsigned int offset, bool lro)
 {
-	struct sge *s = &adap->sge;
 	struct sge_ofld_rxq *q = rxq_info->uldrxq + offset;
 	unsigned short *ids = rxq_info->rspq_id + offset;
 	unsigned int per_chan = nq / adap->params.nports;
-	unsigned int msi_idx, bmap_idx;
+	unsigned int bmap_idx;
 	int i, err;
 
-	if (adap->flags & USING_MSIX)
-		msi_idx = 1;
-	else
-		msi_idx = -((int)s->intrq.abs_id + 1);
-
 	for (i = 0; i < nq; i++, q++) {
-		if (msi_idx >= 0) {
+		if (adap->flags & USING_MSIX) {
 			bmap_idx = get_msix_idx_from_bmap(adap);
 			adap->msi_idx++;
 		}
@@ -147,7 +141,7 @@ static int alloc_uld_rxqs(struct adapter *adap,
 				       0);
 		if (err)
 			goto freeout;
-		if (msi_idx >= 0)
+		if (adap->flags & USING_MSIX)
 			rxq_info->msix_tbl[i + offset] = bmap_idx;
 		memset(&q->stats, 0, sizeof(q->stats));
 		if (ids)
-- 
1.9.1
