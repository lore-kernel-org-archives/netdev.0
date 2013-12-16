From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 2/9] cxgb4: Reserve stid 0 for T4/T5 adapters
Date: Mon, 16 Dec 2013 17:42:11 +0530
Message-ID: <1387195938-3531-3-git-send-email-hariprasad@chelsio.com>
References: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, hariprasad@chelsio.com,
	nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22493 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab3LPMT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 07:19:57 -0500
In-Reply-To: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

When creating offload server entries, an IPv6 passive connection request
can trigger a reply with a null STID, whereas the driver would expect
the reply 'STID to match the value used for the request.
This happens due to h/w limitation on T4 and T5.

This patch ensures that STID 0 is never used if the stid range starts
from zero.

Based on original work by Santosh Rastapur <santosh@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f9f0505..f1015ee 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3138,6 +3138,7 @@ static int tid_init(struct tid_info *t)
 	size_t size;
 	unsigned int stid_bmap_size;
 	unsigned int natids = t->natids;
+	struct adapter *adap = container_of(t, struct adapter, tids);
 
 	stid_bmap_size = BITS_TO_LONGS(t->nstids + t->nsftids);
 	size = t->ntids * sizeof(*t->tid_tab) +
@@ -3172,6 +3173,11 @@ static int tid_init(struct tid_info *t)
 		t->afree = t->atid_tab;
 	}
 	bitmap_zero(t->stid_bmap, t->nstids + t->nsftids);
+	/* Reserve stid 0 for T4/T5 adapters */
+	if (!t->stid_base &&
+	    (is_t4(adap->params.chip) || is_t5(adap->params.chip)))
+		__set_bit(0, t->stid_bmap);
+
 	return 0;
 }
 
-- 
1.8.0
