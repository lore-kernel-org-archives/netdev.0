From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/6] ixgbe: fully disable hardware RSC logic when disabling RSC
Date: Fri, 13 Sep 2013 14:12:05 -0700
Message-ID: <1379106730-14994-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38706 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754647Ab3IMVMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 17:12:18 -0400
In-Reply-To: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch modifies the configure_rx path in order to properly disable RSC
hardware logic when the user disables it. Previously we only disabled RSC in the
queue settings, but this does not fully disable hardware RSC logic which can
lead to some unexpected performance issues.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 9 ++++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h | 1 +
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7aba452..ae26786 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -3571,7 +3571,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
-	u32 rxctrl;
+	u32 rxctrl, rfctl;
 
 	/* disable receives while setting up the descriptors */
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
@@ -3580,6 +3580,13 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	ixgbe_setup_psrtype(adapter);
 	ixgbe_setup_rdrxctl(adapter);
 
+	/* RSC Setup */
+	rfctl = IXGBE_READ_REG(hw, IXGBE_RFCTL);
+	rfctl &= ~IXGBE_RFCTL_RSC_DIS;
+	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))
+		rfctl |= IXGBE_RFCTL_RSC_DIS;
+	IXGBE_WRITE_REG(hw, IXGBE_RFCTL, rfctl);
+
 	/* Program registers for the distribution of queues */
 	ixgbe_setup_mrqc(adapter);
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 6442cf8..10775cb 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -1861,6 +1861,7 @@ enum {
 #define IXGBE_RFCTL_ISCSI_DIS       0x00000001
 #define IXGBE_RFCTL_ISCSI_DWC_MASK  0x0000003E
 #define IXGBE_RFCTL_ISCSI_DWC_SHIFT 1
+#define IXGBE_RFCTL_RSC_DIS		0x00000020
 #define IXGBE_RFCTL_NFSW_DIS        0x00000040
 #define IXGBE_RFCTL_NFSR_DIS        0x00000080
 #define IXGBE_RFCTL_NFS_VER_MASK    0x00000300
-- 
1.8.3.1
