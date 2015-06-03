From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/9] e1000e: fix flush_desc_ring implementation
Date: Wed,  3 Jun 2015 04:27:52 -0700
Message-ID: <1433330876-2658-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yanir Lubetkin <yanirx.lubetkin@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:63339 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754489AbbFCL2F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 07:28:05 -0400
In-Reply-To: <1433330876-2658-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yanir Lubetkin <yanirx.lubetkin@intel.com>

The indication that a descriptor ring flush is required was read from
FEXTNVM7 by mistake. It should be read from the PCI config space.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |  2 ++
 drivers/net/ethernet/intel/e1000e/ich8lan.h |  1 -
 drivers/net/ethernet/intel/e1000e/netdev.c  | 12 +++++++-----
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 0abc942..e78487a 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -98,6 +98,8 @@ struct e1000_info;
 #define DEFAULT_RADV			8
 #define BURST_RDTR			0x20
 #define BURST_RADV			0x20
+#define PCICFG_DESC_RING_STATUS		0xe4
+#define FLUSH_DESC_REQUIRED		0x100
 
 /* in the case of WTHRESH, it appears at least the 82571/2 hardware
  * writes back 4 descriptors when WTHRESH=5, and 3 descriptors when
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index bf72ef8..1500536 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -100,7 +100,6 @@
 #define E1000_FEXTNVM7_DISABLE_PB_READ	0x00040000
 
 #define E1000_FEXTNVM7_DISABLE_SMB_PERST	0x00000020
-#define E1000_FEXTNVM7_NEED_DESCRING_FLUSH	0x00000100
 #define E1000_FEXTNVM11_DISABLE_MULR_FIX	0x00002000
 
 /* bit24: RXDCTL thresholds granularity: 0 - cache lines, 1 - descriptors */
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index b2d77a5..4f029b6 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3867,7 +3867,7 @@ static void e1000_flush_rx_ring(struct e1000_adapter *adapter)
 
 static void e1000_flush_desc_rings(struct e1000_adapter *adapter)
 {
-	u32 hang_state;
+	u16 hang_state;
 	u32 fext_nvm11, tdlen;
 	struct e1000_hw *hw = &adapter->hw;
 
@@ -3877,13 +3877,15 @@ static void e1000_flush_desc_rings(struct e1000_adapter *adapter)
 	ew32(FEXTNVM11, fext_nvm11);
 	/* do nothing if we're not in faulty state, or if the queue is empty */
 	tdlen = er32(TDLEN(0));
-	hang_state = er32(FEXTNVM7);
-	if (!(hang_state & E1000_FEXTNVM7_NEED_DESCRING_FLUSH) || !tdlen)
+	pci_read_config_word(adapter->pdev, PCICFG_DESC_RING_STATUS,
+			     &hang_state);
+	if (!(hang_state & FLUSH_DESC_REQUIRED) || !tdlen)
 		return;
 	e1000_flush_tx_ring(adapter);
 	/* recheck, maybe the fault is caused by the rx ring */
-	hang_state = er32(FEXTNVM7);
-	if (hang_state & E1000_FEXTNVM7_NEED_DESCRING_FLUSH)
+	pci_read_config_word(adapter->pdev, PCICFG_DESC_RING_STATUS,
+			     &hang_state);
+	if (hang_state & FLUSH_DESC_REQUIRED)
 		e1000_flush_rx_ring(adapter);
 }
 
-- 
2.1.0
