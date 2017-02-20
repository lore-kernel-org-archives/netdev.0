From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 05/10] qede: Initialize lock and slowpath workqueue early
Date: Mon, 20 Feb 2017 22:43:34 +0200
Message-ID: <1487623419-6442-6-git-send-email-Yuval.Mintz@cavium.com>
References: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:46409 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751118AbdBTU7d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 15:59:33 -0500
In-Reply-To: <1487623419-6442-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to make sure the slowpath workqueue and the qede lock
are ready for the registration of the netdevice, as once
registered there's no guarantee those wouldn't be used.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index d163e72..7a8e07d 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -854,6 +854,13 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 	if (rc)
 		goto err3;
 
+	/* Prepare the lock prior to the registeration of the netdev,
+	 * as once it's registered we might reach flows requiring it
+	 * [it's even possible to reach a flow needing it directly
+	 * from there, although it's unlikely].
+	 */
+	INIT_DELAYED_WORK(&edev->sp_task, qede_sp_task);
+	mutex_init(&edev->qede_lock);
 	rc = register_netdev(edev->ndev);
 	if (rc) {
 		DP_NOTICE(edev, "Cannot register net-device\n");
@@ -878,8 +885,6 @@ static int __qede_probe(struct pci_dev *pdev, u32 dp_module, u8 dp_level,
 		qede_set_dcbnl_ops(edev->ndev);
 #endif
 
-	INIT_DELAYED_WORK(&edev->sp_task, qede_sp_task);
-	mutex_init(&edev->qede_lock);
 	edev->rx_copybreak = QEDE_RX_HDR_SIZE;
 
 	DP_INFO(edev, "Ending successfully qede probe\n");
-- 
1.9.3
