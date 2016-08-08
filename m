From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: [PATCH net] bnx2x: don't reset chip on cleanup if PCI function is offline
Date: Mon,  8 Aug 2016 17:13:47 -0300
Message-ID: <1470687227-21024-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, gpiccoli@linux.vnet.ibm.com
To: ariel.elior@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:44667 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752238AbcHHUON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 16:14:13 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u78JhKXZ121384
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2016 16:14:12 -0400
Received: from e24smtp05.br.ibm.com (e24smtp05.br.ibm.com [32.104.18.26])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24n8tycdvr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 16:14:12 -0400
Received: from localhost
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
	Mon, 8 Aug 2016 17:14:10 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id EEF7A352006E
	for <netdev@vger.kernel.org>; Mon,  8 Aug 2016 16:13:46 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u78KE7vG33096058
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2016 17:14:07 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u78KE63x021949
	for <netdev@vger.kernel.org>; Mon, 8 Aug 2016 17:14:06 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When PCI error is detected, in some architectures (like PowerPC) a slot
reset is performed - the driver's error handlers are in charge of "disable"
device before the reset, and re-enable it after a successful slot reset.

There are two cases though that another path is taken on the code: if the
slot reset is not successful or if too many errors already happened in the
specific adapter (meaning that possibly the device is experiencing a HW
failure that slot reset is not able to solve), the core PCI error mechanism
(called EEH in PowerPC) will remove the adapter from the system, since it
will consider this as a permanent failure on device. In this case, a path
is taken that leads to bnx2x_chip_cleanup() calling bnx2x_reset_hw(), which
then tries to perform a HW reset on chip. This reset won't succeed since
the HW is in a fault state, which can be seen by multiple messages on
kernel log like below:

	bnx2x: [bnx2x_issue_dmae_with_comp:552(eth1)]DMAE timeout!
	bnx2x: [bnx2x_write_dmae:600(eth1)]DMAE returned failure -1

After some time, the PCI error mechanism gives up on waiting the driver's
correct removal procedure and forcibly remove the adapter from the system.
We can see soft lockup while core PCI error mechanism is waiting for driver
to accomplish the right removal process.

This patch adds a verification to avoid a chip reset whenever the function
is in PCI error state - since this case is only reached when we have a
device being removed because of a permanent failure, the HW chip reset is
not expected to work fine neither is necessary.

Also, we avoid the MCP information dump in case of non-recoverable PCI
error (when adapter is about to be removed), since it will certainly fail.

Reported-by: Harsha Thyagaraja <hathyaga@in.ibm.com>
Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 97e8925..e6329dc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -772,6 +772,11 @@ void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl)
 		(bp->common.bc_ver & 0xff00) >> 8,
 		(bp->common.bc_ver & 0xff));
 
+	if (unlikely(pci_channel_offline(bp->pdev))) {
+		BNX2X_ERR("Cannot dump MCP info while in PCI error\n");
+		return;
+	}
+
 	val = REG_RD(bp, MCP_REG_MCPR_CPU_PROGRAM_COUNTER);
 	if (val == REG_RD(bp, MCP_REG_MCPR_CPU_PROGRAM_COUNTER))
 		BNX2X_ERR("%s" "MCP PC at 0x%x\n", lvl, val);
@@ -9415,10 +9420,16 @@ unload_error:
 	/* Release IRQs */
 	bnx2x_free_irq(bp);
 
-	/* Reset the chip */
-	rc = bnx2x_reset_hw(bp, reset_code);
-	if (rc)
-		BNX2X_ERR("HW_RESET failed\n");
+	/* Reset the chip, unless PCI function is offline. If we reach this
+	 * point following a PCI error handling, it means device is really
+	 * in a bad state and we're about to remove it, so reset the chip
+	 * is not a good idea.
+	 */
+	if (!pci_channel_offline(bp->pdev)) {
+		rc = bnx2x_reset_hw(bp, reset_code);
+		if (rc)
+			BNX2X_ERR("HW_RESET failed\n");
+	}
 
 	/* Report UNLOAD_DONE to MCP */
 	bnx2x_send_unload_done(bp, keep_link);
-- 
2.1.0
