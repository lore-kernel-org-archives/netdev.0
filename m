From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/20] fm10k: Reset mailbox global interrupts
Date: Wed, 20 Jul 2016 15:23:42 -0700
Message-ID: <1469053438-85381-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21457 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755244AbcGTWYB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:01 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>

When a data path reset is initiated, write control to the PCIE_GMBX is
yanked from the switch manager. The switch manager writes to this
register to clear mailbox global interrupt bits as part of its mailbox
interrupt handling routine. When the device recovers from the data path
reset and these bits are not cleared, it will prevent future mailbox
global interrupts from being triggered. Upon confirming that the device
has exited from a data path reset, clear these bits to ensure the proper
functioning of the mailbox global interrupt.

Signed-off-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.h | 2 ++
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c  | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
index b7dbc8a..35c1dba 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.h
@@ -41,6 +41,8 @@ struct fm10k_mbx_info;
 #define FM10K_MBX_ACK_INTERRUPT			0x00000010
 #define FM10K_MBX_INTERRUPT_ENABLE		0x00000020
 #define FM10K_MBX_INTERRUPT_DISABLE		0x00000040
+#define FM10K_MBX_GLOBAL_REQ_INTERRUPT		0x00000200
+#define FM10K_MBX_GLOBAL_ACK_INTERRUPT		0x00000400
 #define FM10K_MBICR(_n)		((_n) + 0x18840)
 #define FM10K_GMBX		0x18842
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index dc75507..69e2c82 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -77,6 +77,10 @@ static s32 fm10k_reset_hw_pf(struct fm10k_hw *hw)
 	if (!(reg & FM10K_IP_NOTINRESET))
 		err = FM10K_ERR_RESET_FAILED;
 
+	/* Reset mailbox global interrupts */
+	reg = FM10K_MBX_GLOBAL_REQ_INTERRUPT | FM10K_MBX_GLOBAL_ACK_INTERRUPT;
+	fm10k_write_reg(hw, FM10K_GMBX, reg);
+
 out:
 	return err;
 }
-- 
2.5.5
