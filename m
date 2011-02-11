From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 v2 04/15] igb: Enable PF side of SR-IOV support for i350 devices
Date: Fri, 11 Feb 2011 09:20:51 -0800
Message-ID: <1297444862-32091-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:11125 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757840Ab1BKRVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Feb 2011 12:21:19 -0500
In-Reply-To: <1297444862-32091-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds full support for SR-IOV by enabling the PF side.
VF side has already been committed.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_82575.c |   10 ++++++++--
 drivers/net/igb/e1000_mbx.c   |   38 ++++++++++++++++++--------------------
 drivers/net/igb/igb_main.c    |    9 +++++++--
 3 files changed, 33 insertions(+), 24 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index c1552b6..65c1833 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -238,9 +238,15 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		size = 14;
 	nvm->word_size = 1 << size;
 
-	/* if 82576 then initialize mailbox parameters */
-	if (mac->type == e1000_82576)
+	/* if part supports SR-IOV then initialize mailbox parameters */
+	switch (mac->type) {
+	case e1000_82576:
+	case e1000_i350:
 		igb_init_mbx_params_pf(hw);
+		break;
+	default:
+		break;
+	}
 
 	/* setup PHY parameters */
 	if (phy->media_type != e1000_media_type_copper) {
diff --git a/drivers/net/igb/e1000_mbx.c b/drivers/net/igb/e1000_mbx.c
index c474cdb..78d48c7 100644
--- a/drivers/net/igb/e1000_mbx.c
+++ b/drivers/net/igb/e1000_mbx.c
@@ -422,26 +422,24 @@ s32 igb_init_mbx_params_pf(struct e1000_hw *hw)
 {
 	struct e1000_mbx_info *mbx = &hw->mbx;
 
-	if (hw->mac.type == e1000_82576) {
-		mbx->timeout = 0;
-		mbx->usec_delay = 0;
-
-		mbx->size = E1000_VFMAILBOX_SIZE;
-
-		mbx->ops.read = igb_read_mbx_pf;
-		mbx->ops.write = igb_write_mbx_pf;
-		mbx->ops.read_posted = igb_read_posted_mbx;
-		mbx->ops.write_posted = igb_write_posted_mbx;
-		mbx->ops.check_for_msg = igb_check_for_msg_pf;
-		mbx->ops.check_for_ack = igb_check_for_ack_pf;
-		mbx->ops.check_for_rst = igb_check_for_rst_pf;
-
-		mbx->stats.msgs_tx = 0;
-		mbx->stats.msgs_rx = 0;
-		mbx->stats.reqs = 0;
-		mbx->stats.acks = 0;
-		mbx->stats.rsts = 0;
-	}
+	mbx->timeout = 0;
+	mbx->usec_delay = 0;
+
+	mbx->size = E1000_VFMAILBOX_SIZE;
+
+	mbx->ops.read = igb_read_mbx_pf;
+	mbx->ops.write = igb_write_mbx_pf;
+	mbx->ops.read_posted = igb_read_posted_mbx;
+	mbx->ops.write_posted = igb_write_posted_mbx;
+	mbx->ops.check_for_msg = igb_check_for_msg_pf;
+	mbx->ops.check_for_ack = igb_check_for_ack_pf;
+	mbx->ops.check_for_rst = igb_check_for_rst_pf;
+
+	mbx->stats.msgs_tx = 0;
+	mbx->stats.msgs_rx = 0;
+	mbx->stats.reqs = 0;
+	mbx->stats.acks = 0;
+	mbx->stats.rsts = 0;
 
 	return 0;
 }
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 200cc32..cb6bf7b 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2287,9 +2287,14 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 
 	spin_lock_init(&adapter->stats64_lock);
 #ifdef CONFIG_PCI_IOV
-	if (hw->mac.type == e1000_82576)
+	switch (hw->mac.type) {
+	case e1000_82576:
+	case e1000_i350:
 		adapter->vfs_allocated_count = (max_vfs > 7) ? 7 : max_vfs;
-
+		break;
+	default:
+		break;
+	}
 #endif /* CONFIG_PCI_IOV */
 	adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES, num_online_cpus());
 
-- 
1.7.4

