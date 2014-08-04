From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 2/3] qlcnic: Set driver version before registering netdev
Date: Mon, 4 Aug 2014 11:51:17 -0400
Message-ID: <1407167478-22277-3-git-send-email-rajesh.borundia@qlogic.com>
References: <1407167478-22277-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:52342 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752178AbaHDQXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 12:23:23 -0400
In-Reply-To: <1407167478-22277-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Earlier, set_drv_version was getting called after register_netdev.
  This was resulting in a race between set_drv_version and FLR called
  from open(). Moving set_drv_version before register_netdev avoids
  the race.

o Log response code in error message on CDRP failure.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c  |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 304e247..ffbae29 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -136,7 +136,7 @@ int qlcnic_82xx_issue_cmd(struct qlcnic_adapter *adapter,
 	rsp = qlcnic_poll_rsp(adapter);
 
 	if (rsp == QLCNIC_CDRP_RSP_TIMEOUT) {
-		dev_err(&pdev->dev, "card response timeout.\n");
+		dev_err(&pdev->dev, "command timeout, response = 0x%x\n", rsp);
 		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
 	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
 		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1), &err);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 4fc1867..158e1d9 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2623,13 +2623,13 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_out_disable_mbx_intr;
 
+	if (adapter->portnum == 0)
+		qlcnic_set_drv_version(adapter);
+
 	err = qlcnic_setup_netdev(adapter, netdev, pci_using_dac);
 	if (err)
 		goto err_out_disable_mbx_intr;
 
-	if (adapter->portnum == 0)
-		qlcnic_set_drv_version(adapter);
-
 	pci_set_drvdata(pdev, adapter);
 
 	if (qlcnic_82xx_check(adapter))
-- 
1.6.3.3
