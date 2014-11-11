From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/10] ixgbe: fix X540 Completion timeout
Date: Tue, 11 Nov 2014 06:44:42 -0800
Message-ID: <1415717086-3441-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3085 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515AbaKKOpa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 09:45:30 -0500
In-Reply-To: <1415717086-3441-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

On topologies including few levels of PCIe switching X540 can run into an
unexpected completion error.  We get around this by waiting after enabling
loopback a sufficient amount of time until Tx Data Fetch is sent.  We then
poll the pending transaction bit to ensure we received the completion.  Only
then do we go on to clear the buffers.

CC: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-of-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
v2: update the "goto" to "break" based on feedback from Sergei Shtylyov

 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index b5f484b..0406708 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -3583,7 +3583,8 @@ s32 ixgbe_set_fw_drv_ver_generic(struct ixgbe_hw *hw, u8 maj, u8 min,
  **/
 void ixgbe_clear_tx_pending(struct ixgbe_hw *hw)
 {
-	u32 gcr_ext, hlreg0;
+	u32 gcr_ext, hlreg0, i, poll;
+	u16 value;
 
 	/*
 	 * If double reset is not requested then all transactions should
@@ -3600,6 +3601,23 @@ void ixgbe_clear_tx_pending(struct ixgbe_hw *hw)
 	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
 	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0 | IXGBE_HLREG0_LPBK);
 
+	/* wait for a last completion before clearing buffers */
+	IXGBE_WRITE_FLUSH(hw);
+	usleep_range(3000, 6000);
+
+	/* Before proceeding, make sure that the PCIe block does not have
+	 * transactions pending.
+	 */
+	poll = ixgbe_pcie_timeout_poll(hw);
+	for (i = 0; i < poll; i++) {
+		usleep_range(100, 200);
+		value = ixgbe_read_pci_cfg_word(hw, IXGBE_PCI_DEVICE_STATUS);
+		if (ixgbe_removed(hw->hw_addr))
+			break;
+		if (!(value & IXGBE_PCI_DEVICE_STATUS_TRANSACTION_PENDING))
+			break;
+	}
+
 	/* initiate cleaning flow for buffers in the PCIe transaction layer */
 	gcr_ext = IXGBE_READ_REG(hw, IXGBE_GCR_EXT);
 	IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT,
-- 
1.9.3
