From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 2/2] ixgbe: Clear head write-back registers on VF reset
Date: Wed, 15 Jan 2014 17:38:41 -0800
Message-ID: <1389836321-17013-3-git-send-email-aaron.f.brown@intel.com>
References: <1389836321-17013-1-git-send-email-aaron.f.brown@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31147 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751990AbaAPBij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 20:38:39 -0500
In-Reply-To: <1389836321-17013-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The Tx head write-back registers are not cleared during an FLR or VF reset.
As a result a configuration that had head write-back enabled can leave the
registers set after the driver is unloaded.  If the next driver loaded doesn't
use the write-back registers this can lead to a bad configuration where
head write-back is enabled, but the driver didn't request it.

To avoid this situation the PF should be resetting the Tx head write-back
registers when the VF requests a reset.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 9 +++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h  | 8 ++++++++
 2 files changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 43e10c6..0558c71 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -698,6 +698,15 @@ static int ixgbe_vf_reset_msg(struct ixgbe_adapter *adapter, u32 vf)
 	reg |= (1 << vf_shift);
 	IXGBE_WRITE_REG(hw, IXGBE_VMECM(reg_offset), reg);
 
+	/*
+	 * Reset the VFs TDWBAL and TDWBAH registers
+	 * which are not cleared by an FLR
+	 */
+	for (i = 0; i < q_per_pool; i++) {
+		IXGBE_WRITE_REG(hw, IXGBE_PVFTDWBAHn(q_per_pool, vf, i), 0);
+		IXGBE_WRITE_REG(hw, IXGBE_PVFTDWBALn(q_per_pool, vf, i), 0);
+	}
+
 	/* reply to reset with ack and vf mac address */
 	msgbuf[0] = IXGBE_VF_RESET;
 	if (!is_zero_ether_addr(vf_mac)) {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index d8e59f4..0d39cfc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -2174,6 +2174,14 @@ enum {
 #define IXGBE_MBVFICR(_i)		(0x00710 + ((_i) * 4))
 #define IXGBE_VFLRE(_i)		((((_i) & 1) ? 0x001C0 : 0x00600))
 #define IXGBE_VFLREC(_i)		(0x00700 + ((_i) * 4))
+/* Translated register #defines */
+#define IXGBE_PVFTDWBAL(P)	(0x06038 + (0x40 * (P)))
+#define IXGBE_PVFTDWBAH(P)	(0x0603C + (0x40 * (P)))
+
+#define IXGBE_PVFTDWBALn(q_per_pool, vf_number, vf_q_index) \
+		(IXGBE_PVFTDWBAL((q_per_pool)*(vf_number) + (vf_q_index)))
+#define IXGBE_PVFTDWBAHn(q_per_pool, vf_number, vf_q_index) \
+		(IXGBE_PVFTDWBAH((q_per_pool)*(vf_number) + (vf_q_index)))
 
 enum ixgbe_fdir_pballoc_type {
 	IXGBE_FDIR_PBALLOC_NONE = 0,
-- 
1.8.5.GIT
