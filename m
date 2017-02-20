From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 06/10] qede: Free netdevice only after stoping slowpath
Date: Mon, 20 Feb 2017 22:43:35 +0200
Message-ID: <1487623419-6442-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46409 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750844AbdBTU7c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 15:59:32 -0500
In-Reply-To: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

qed needs to be informed of the removal of the qede interface
prior to its actual removal, as qede has some registered callbacks
that might get called async to the removal flow.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 7a8e07d..88453ed 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -956,14 +956,20 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
 	if (edev->xdp_prog)
 		bpf_prog_put(edev->xdp_prog);
 
-	free_netdev(ndev);
-
 	/* Use global ops since we've freed edev */
 	qed_ops->common->slowpath_stop(cdev);
 	if (system_state == SYSTEM_POWER_OFF)
 		return;
 	qed_ops->common->remove(cdev);
 
+	/* Since this can happen out-of-sync with other flows,
+	 * don't release the netdevice until after slowpath stop
+	 * has been called to guarantee various other contexts
+	 * [e.g., QED register callbacks] won't break anything when
+	 * accessing the netdevice.
+	 */
+	 free_netdev(ndev);
+
 	dev_info(&pdev->dev, "Ending qede_remove successfully\n");
 }
 
-- 
1.9.3
