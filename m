From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] bnx2: Try to recover from PCI block reset
Date: Mon, 16 Jul 2012 17:25:56 -0700
Message-ID: <1342484756-29615-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4012 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752671Ab2GQAOR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2012 20:14:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the PCI block has reset, the memory enable bit will be reset and
the device will not respond to MMIO access.  bnx2_reset_task() currently
will not recover when this happens.  Add code to detect this condition
and restore the PCI state.  This scenario has been reported by some
users.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 0ced154..79cebd8 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6388,6 +6388,7 @@ bnx2_reset_task(struct work_struct *work)
 {
 	struct bnx2 *bp = container_of(work, struct bnx2, reset_task);
 	int rc;
+	u16 pcicmd;
 
 	rtnl_lock();
 	if (!netif_running(bp->dev)) {
@@ -6397,6 +6398,12 @@ bnx2_reset_task(struct work_struct *work)
 
 	bnx2_netif_stop(bp, true);
 
+	pci_read_config_word(bp->pdev, PCI_COMMAND, &pcicmd);
+	if (!(pcicmd & PCI_COMMAND_MEMORY)) {
+		/* in case PCI block has reset */
+		pci_restore_state(bp->pdev);
+		pci_save_state(bp->pdev);
+	}
 	rc = bnx2_init_nic(bp, 1);
 	if (rc) {
 		netdev_err(bp->dev, "failed to reset NIC, closing\n");
-- 
1.7.1
