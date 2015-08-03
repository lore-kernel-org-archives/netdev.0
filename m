From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH]Fix a null dereference in e1000_open
Date: Mon,  3 Aug 2015 09:36:26 +0800
Message-ID: <1438565786-5070-1-git-send-email-baijiaju1990@163.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When e1000e_setup_rx_resources is failed in e1000_open,
e1000e_free_tx_resources in "err_setup_rx" segment is executed.
"writel(0, tx_ring->head)" statement in e1000_clean_tx_ring
in e1000e_free_tx_resources will cause a null dereference(crash), 
because "tx_ring->head" is only assigned in e1000_configure_tx
in e1000_configure, but it is after e1000e_setup_rx_resources.
This patch adds a check to fix it.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 89d788d..838ec8e 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2448,7 +2448,8 @@ static void e1000_clean_tx_ring(struct e1000_ring *tx_ring)
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 
-	writel(0, tx_ring->head);
+	if (tx_ring->head)
+		writel(0, tx_ring->head);
 	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
 		e1000e_update_tdt_wa(tx_ring, 0);
 	else
-- 
1.7.9.5
