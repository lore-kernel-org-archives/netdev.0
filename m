From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [PATCH net] i40e: proper update of the page_offset field
Date: Sun, 14 May 2017 19:56:49 +0200
Message-ID: <20170514175649.31616-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4520 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759089AbdENR5k (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 14 May 2017 13:57:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

In f8b45b74cc62 ("i40e/i40evf: Use build_skb to build frames")
i40e_build_skb updates the page_offset field with an incorrect offset,
which can lead to data corruption. This patch updates page_offset
correctly.

Note that the bug only appears on architectures where PAGE_SIZE is
8192 or larger.

Fixes: f8b45b74cc62 ("i40e/i40evf: Use build_skb to build frames")
Signed-off-by: Björn Töpel <bjorn.topel@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 29321a6167a6..cd894f4023b1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1854,7 +1854,8 @@ static struct sk_buff *i40e_build_skb(struct i40e_ring *rx_ring,
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = i40e_rx_pg_size(rx_ring) / 2;
 #else
-	unsigned int truesize = SKB_DATA_ALIGN(size);
+	unsigned int truesize = SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) +
+				SKB_DATA_ALIGN(I40E_SKB_PAD + size);
 #endif
 	struct sk_buff *skb;
 
-- 
2.11.0
