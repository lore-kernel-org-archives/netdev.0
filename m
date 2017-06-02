From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] amd-xgbe: use PAGE_ALLOC_COSTLY_ORDER in xgbe_map_rx_buffer
Date: Fri,  2 Jun 2017 17:54:08 +0200
Message-ID: <20170602155408.12792-1-mhocko@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Michal Hocko <mhocko@suse.com>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

xgbe_map_rx_buffer is rather confused about what PAGE_ALLOC_COSTLY_ORDER
means. It uses PAGE_ALLOC_COSTLY_ORDER-1 assuming that
PAGE_ALLOC_COSTLY_ORDER is the first costly order which is not the case
actually because orders larger than that are costly. And even that
applies only to sleeping allocations which is not the case here. We
simply do not perform any costly operations like reclaim or compaction
for those. Simplify the code by dropping the order calculation and use
PAGE_ALLOC_COSTLY_ORDER directly.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index b3bc87fe3764..0a98c369df20 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -324,7 +324,7 @@ static int xgbe_map_rx_buffer(struct xgbe_prv_data *pdata,
 			      struct xgbe_ring *ring,
 			      struct xgbe_ring_data *rdata)
 {
-	int order, ret;
+	int ret;
 
 	if (!ring->rx_hdr_pa.pages) {
 		ret = xgbe_alloc_pages(pdata, &ring->rx_hdr_pa, GFP_ATOMIC, 0);
@@ -333,9 +333,8 @@ static int xgbe_map_rx_buffer(struct xgbe_prv_data *pdata,
 	}
 
 	if (!ring->rx_buf_pa.pages) {
-		order = max_t(int, PAGE_ALLOC_COSTLY_ORDER - 1, 0);
 		ret = xgbe_alloc_pages(pdata, &ring->rx_buf_pa, GFP_ATOMIC,
-				       order);
+				       PAGE_ALLOC_COSTLY_ORDER);
 		if (ret)
 			return ret;
 	}
-- 
2.11.0
