From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 06/10] qede: Free netdevice only after stoping slowpath
Date: Sun, 19 Feb 2017 15:26:19 +0200
Message-ID: <1487510783-19919-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:54349 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751864AbdBSN0v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 08:26:51 -0500
In-Reply-To: <1487510783-19919-1-git-send-email-Yuval.Mintz@cavium.com>
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
index 5e76249..9c9f50c 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2972,14 +2972,20 @@ static void __qede_remove(struct pci_dev *pdev, enum qede_remove_mode mode)
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
