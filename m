From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] fm10k: request reset when mbx->state changes
Date: Sun,  8 Jan 2017 02:10:29 -0800
Message-ID: <20170108101034.119851-4-jeffrey.t.kirsher@intel.com>
References: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Cc: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jacob Keller <jacob.e.keller@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60633 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162100AbdAHKKk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 05:10:40 -0500
In-Reply-To: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>

Multiple IES API resets can cause a race condition where the mailbox
interrupt request bits can be cleared before being handled. This can
leave certain mailbox messages from the PF to be untreated and the PF
will enter in some inactive state. If this situation occurs, the IES API
will initiate a mailbox version reset which, then, trigger a mailbox
state change. Once this mailbox transition occurs (from OPEN to CONNECT
state), a request for reset will be returned.

This ensures that PF will undergo a reset whenever IES API encounters an
unknown global mailbox interrupt event or whenever the IES API
terminates.

Signed-off-by: Ngai-Mint Kwan <ngai-mint.kwan@intel.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c | 10 +++++++---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c |  6 +++++-
 2 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index c9dfa65..334088a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -2011,9 +2011,10 @@ static void fm10k_sm_mbx_create_reply(struct fm10k_hw *hw,
  *  function can also be used to respond to an error as the connection
  *  resetting would also be a means of dealing with errors.
  **/
-static void fm10k_sm_mbx_process_reset(struct fm10k_hw *hw,
-				       struct fm10k_mbx_info *mbx)
+static s32 fm10k_sm_mbx_process_reset(struct fm10k_hw *hw,
+				      struct fm10k_mbx_info *mbx)
 {
+	s32 err = 0;
 	const enum fm10k_mbx_state state = mbx->state;
 
 	switch (state) {
@@ -2026,6 +2027,7 @@ static void fm10k_sm_mbx_process_reset(struct fm10k_hw *hw,
 	case FM10K_STATE_OPEN:
 		/* flush any incomplete work */
 		fm10k_sm_mbx_connect_reset(mbx);
+		err = FM10K_ERR_RESET_REQUESTED;
 		break;
 	case FM10K_STATE_CONNECT:
 		/* Update remote value to match local value */
@@ -2035,6 +2037,8 @@ static void fm10k_sm_mbx_process_reset(struct fm10k_hw *hw,
 	}
 
 	fm10k_sm_mbx_create_reply(hw, mbx, mbx->tail);
+
+	return err;
 }
 
 /**
@@ -2115,7 +2119,7 @@ static s32 fm10k_sm_mbx_process(struct fm10k_hw *hw,
 
 	switch (FM10K_MSG_HDR_FIELD_GET(mbx->mbx_hdr, SM_VER)) {
 	case 0:
-		fm10k_sm_mbx_process_reset(hw, mbx);
+		err = fm10k_sm_mbx_process_reset(hw, mbx);
 		break;
 	case FM10K_SM_MBX_VERSION:
 		err = fm10k_sm_mbx_process_version_1(hw, mbx);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index b1a2f84..e372a58 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1144,6 +1144,7 @@ static irqreturn_t fm10k_msix_mbx_pf(int __always_unused irq, void *data)
 	struct fm10k_hw *hw = &interface->hw;
 	struct fm10k_mbx_info *mbx = &hw->mbx;
 	u32 eicr;
+	s32 err = 0;
 
 	/* unmask any set bits related to this interrupt */
 	eicr = fm10k_read_reg(hw, FM10K_EICR);
@@ -1159,12 +1160,15 @@ static irqreturn_t fm10k_msix_mbx_pf(int __always_unused irq, void *data)
 
 	/* service mailboxes */
 	if (fm10k_mbx_trylock(interface)) {
-		mbx->ops.process(hw, mbx);
+		err = mbx->ops.process(hw, mbx);
 		/* handle VFLRE events */
 		fm10k_iov_event(interface);
 		fm10k_mbx_unlock(interface);
 	}
 
+	if (err == FM10K_ERR_RESET_REQUESTED)
+		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
+
 	/* if switch toggled state we should reset GLORTs */
 	if (eicr & FM10K_EICR_SWITCHNOTREADY) {
 		/* force link down for at least 4 seconds */
-- 
2.9.3
