From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 2/2] benet: Wait I/O while resuming device
Date: Mon,  4 Mar 2013 15:48:47 +0800
Message-ID: <1362383327-32362-2-git-send-email-shangw@linux.vnet.ibm.com>
References: <1362383327-32362-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:38723 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755216Ab3CDHs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 02:48:59 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Mon, 4 Mar 2013 00:48:58 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 839D33E4003E
	for <netdev@vger.kernel.org>; Mon,  4 Mar 2013 00:48:46 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r247mt6A093492
	for <netdev@vger.kernel.org>; Mon, 4 Mar 2013 00:48:55 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r247mtYI014966
	for <netdev@vger.kernel.org>; Mon, 4 Mar 2013 00:48:55 -0700
In-Reply-To: <1362383327-32362-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After resetting the adapter, the config space register (0x7c) might
give fake information to indicate the f/w is ready. In turn, 0xFF's
is always returned while accessing on I/O space registers. The patch
adds more check to make sure the I/O space is ready for access before
accessing that region.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   29 +++++++++++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |    5 ++++
 3 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 813407f..3e8824e 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -696,6 +696,35 @@ static struct be_mcc_wrb *wrb_from_mccq(struct be_adapter *adapter)
 	return wrb;
 }
 
+int be_cmd_fw_wait_io(struct be_adapter *adapter)
+{
+	void __iomem *db = adapter->db + MPU_MAILBOX_DB_OFFSET;
+	int timeout = 0;
+	u32 val;
+
+	if (lancer_chip(adapter))
+		return 0;
+
+	do {
+		val = ioread32(db);
+		if (val != 0xffffffff)
+			return 0;
+
+		dev_info(&adapter->pdev->dev,
+			"Wating for I/O (0x%08x), %ds elapsed\n",
+			val, timeout);
+		if (msleep_interruptible(2000)) {
+			dev_err(&adapter->pdev->dev,
+				"Waiting for I/O aborted\n");
+			return -EIO;
+		}
+		timeout += 2;
+	} while (timeout < 60);
+
+	dev_err(&adapter->pdev->dev, "Timeout waiting for I/O (%d)\n", timeout);
+	return -1;
+}
+
 /* Tell fw we're about to start firing cmds by writing a
  * special pattern across the wrb hdr; uses mbox
  */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 9697086..9d03cb1 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -1888,6 +1888,7 @@ int be_cmd_get_flash_crc(struct be_adapter *adapter, u8 *flashed_crc,
 				int offset);
 extern int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
 				struct be_dma_mem *nonemb_cmd);
+extern int be_cmd_fw_wait_io(struct be_adapter *adapter);
 extern int be_cmd_fw_init(struct be_adapter *adapter);
 extern int be_cmd_fw_clean(struct be_adapter *adapter);
 extern void be_async_mcc_enable(struct be_adapter *adapter);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3860888..7609424 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4347,6 +4347,11 @@ static void be_eeh_resume(struct pci_dev *pdev)
 
 	pci_save_state(pdev);
 
+	/* Wating for I/O ready */
+	status = be_cmd_fw_wait_io(adapter);
+	if (status)
+		goto err;
+
 	/* tell fw we're ready to fire cmds */
 	status = be_cmd_fw_init(adapter);
 	if (status)
-- 
1.7.5.4
