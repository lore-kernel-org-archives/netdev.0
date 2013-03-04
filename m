From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 1/2] benet: Wait f/w POST until timeout
Date: Mon,  4 Mar 2013 15:48:46 +0800
Message-ID: <1362383327-32362-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:45258 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755116Ab3CDHuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Mar 2013 02:50:09 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 4 Mar 2013 02:48:54 -0500
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id BD564C90025
	for <netdev@vger.kernel.org>; Mon,  4 Mar 2013 02:48:51 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r247mpSP273258
	for <netdev@vger.kernel.org>; Mon, 4 Mar 2013 02:48:51 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r247mpDm007735
	for <netdev@vger.kernel.org>; Mon, 4 Mar 2013 04:48:51 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While PCI card faces EEH errors, reset (usually hot reset) is
expected to recover from the EEH errors. After EEH core finishes
the reset, the driver callback (be_eeh_reset) is called and wait
the firmware to complete POST successfully. The original code would
return with error once detecting failure during POST stage. That
seems not enough.

The patch forces the driver (be_eeh_reset) to wait the firmware
completes POST until timeout, instead of returning error upon
detection POST failure immediately. Also, it would improve the
reliability of the EEH funtionality of the driver.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   27 ++++++++++-----------------
 1 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 071aea7..813407f 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -473,7 +473,7 @@ static int be_mbox_notify_wait(struct be_adapter *adapter)
 	return 0;
 }
 
-static int be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
+static void be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
 {
 	u32 sem;
 	u32 reg = skyhawk_chip(adapter) ? SLIPORT_SEMAPHORE_OFFSET_SH :
@@ -481,11 +481,6 @@ static int be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
 
 	pci_read_config_dword(adapter->pdev, reg, &sem);
 	*stage = sem & POST_STAGE_MASK;
-
-	if ((sem >> POST_ERR_SHIFT) & POST_ERR_MASK)
-		return -1;
-	else
-		return 0;
 }
 
 int lancer_wait_ready(struct be_adapter *adapter)
@@ -579,19 +574,17 @@ int be_fw_wait_ready(struct be_adapter *adapter)
 	}
 
 	do {
-		status = be_POST_stage_get(adapter, &stage);
-		if (status) {
-			dev_err(dev, "POST error; stage=0x%x\n", stage);
-			return -1;
-		} else if (stage != POST_STAGE_ARMFW_RDY) {
-			if (msleep_interruptible(2000)) {
-				dev_err(dev, "Waiting for POST aborted\n");
-				return -EINTR;
-			}
-			timeout += 2;
-		} else {
+		be_POST_stage_get(adapter, &stage);
+		if (stage == POST_STAGE_ARMFW_RDY)
 			return 0;
+
+		dev_info(dev, "Waiting for POST, %ds elapsed\n",
+			 timeout);
+		if (msleep_interruptible(2000)) {
+			dev_err(dev, "Waiting for POST aborted\n");
+			return -EINTR;
 		}
+		timeout += 2;
 	} while (timeout < 60);
 
 	dev_err(dev, "POST timeout; stage=0x%x\n", stage);
-- 
1.7.5.4
