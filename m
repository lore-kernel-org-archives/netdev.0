From: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@gmail.com>
Subject: [PATCH net v2] i40e/i40evf: proper update of the page_offset field
Date: Mon, 15 May 2017 06:52:00 +0200
Message-ID: <20170515045200.27789-1-bjorn.topel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        alexander.h.duyck@intel.com, jeffrey.t.kirsher@intel.com,
        alexander.duyck@gmail.com
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28788 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750937AbdEOEw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 15 May 2017 00:52:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Björn Töpel <bjorn.topel@intel.com>

In f8b45b74cc62 ("i40e/i40evf: Use build_skb to build frames")
i40e_build_skb updates the page_offset field with an incorrect offset,
which can lead to data corruption. This patch updates page_offset
correctly, by properly setting truesize.

Note that the bug only appears on architectures where PAGE_SIZE is
8192 or larger.

Fixes: f8b45b74cc62 ("i40e/i40evf: Use build_skb to build frames")
Signed-off-by: Björn Töpel <bjorn.topel@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 3 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

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
 
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index dfe241a12ad0..12b02e530503 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1190,7 +1190,8 @@ static struct sk_buff *i40e_build_skb(struct i40e_ring *rx_ring,
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
