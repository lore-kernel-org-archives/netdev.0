From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] i40e/i40evf: proper update of the page_offset field
Date: Tue,  6 Jun 2017 03:00:55 -0700
Message-ID: <20170606100055.63648-3-jeffrey.t.kirsher@intel.com>
References: <20170606100055.63648-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Bj=C3=B6rn=20T=C3=B6pel?= <bjorn.topel@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4324 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751430AbdFFKBB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 06:01:01 -0400
In-Reply-To: <20170606100055.63648-1-jeffrey.t.kirsher@intel.com>
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
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
2.12.2
