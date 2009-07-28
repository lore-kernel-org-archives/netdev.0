From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 3/5] be2net: replace some printks with
	dev_err()/dev_warn()
Date: Tue, 28 Jul 2009 14:22:56 +0530
Message-ID: <20090728085256.GA4993@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:4598 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751597AbZG1IxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:53:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And get rid of some unnecessary printks.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   26 ++++++++++----------------
 drivers/net/benet/be_main.c |   17 +++++------------
 2 files changed, 15 insertions(+), 28 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index daa2fe8..7c1724e 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -62,8 +62,8 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 	if (compl_status != MCC_STATUS_SUCCESS) {
 		extd_status = (compl->status >> CQE_STATUS_EXTD_SHIFT) &
 				CQE_STATUS_EXTD_MASK;
-		printk(KERN_WARNING DRV_NAME
-			" error in cmd completion: status(compl/extd)=%d/%d\n",
+		dev_warn(&adapter->pdev->dev,
+			"Error in cmd completion: status(compl/extd)=%d/%d\n",
 			compl_status, extd_status);
 		return -1;
 	}
@@ -135,7 +135,7 @@ static void be_mcc_wait_compl(struct be_adapter *adapter)
 		udelay(100);
 	}
 	if (i == mcc_timeout)
-		printk(KERN_WARNING DRV_NAME "mcc poll timed out\n");
+		dev_err(&adapter->pdev->dev, "mccq poll timed out\n");
 }
 
 /* Notify MCC requests and wait for completion */
@@ -145,7 +145,7 @@ static void be_mcc_notify_wait(struct be_adapter *adapter)
 	be_mcc_wait_compl(adapter);
 }
 
-static int be_mbox_db_ready_wait(void __iomem *db)
+static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 {
 	int cnt = 0, wait = 5;
 	u32 ready;
@@ -156,8 +156,7 @@ static int be_mbox_db_ready_wait(void __iomem *db)
 			break;
 
 		if (cnt > 200000) {
-			printk(KERN_WARNING DRV_NAME
-				": mbox_db poll timed out\n");
+			dev_err(&adapter->pdev->dev, "mbox poll timed out\n");
 			return -1;
 		}
 
@@ -185,25 +184,22 @@ static int be_mbox_db_ring(struct be_adapter *adapter)
 
 	memset(cqe, 0, sizeof(*cqe));
 
-	val &= ~MPU_MAILBOX_DB_RDY_MASK;
 	val |= MPU_MAILBOX_DB_HI_MASK;
 	/* at bits 2 - 31 place mbox dma addr msb bits 34 - 63 */
 	val |= (upper_32_bits(mbox_mem->dma) >> 2) << 2;
 	iowrite32(val, db);
 
 	/* wait for ready to be set */
-	status = be_mbox_db_ready_wait(db);
+	status = be_mbox_db_ready_wait(adapter, db);
 	if (status != 0)
 		return status;
 
 	val = 0;
-	val &= ~MPU_MAILBOX_DB_RDY_MASK;
-	val &= ~MPU_MAILBOX_DB_HI_MASK;
 	/* at bits 2 - 31 place mbox dma addr lsb bits 4 - 33 */
 	val |= (u32)(mbox_mem->dma >> 4) << 2;
 	iowrite32(val, db);
 
-	status = be_mbox_db_ready_wait(db);
+	status = be_mbox_db_ready_wait(adapter, db);
 	if (status != 0)
 		return status;
 
@@ -214,7 +210,7 @@ static int be_mbox_db_ring(struct be_adapter *adapter)
 		if (status)
 			return status;
 	} else {
-		printk(KERN_WARNING DRV_NAME "invalid mailbox completion\n");
+		dev_err(&adapter->pdev->dev, "invalid mailbox completion\n");
 		return -1;
 	}
 	return 0;
@@ -705,15 +701,13 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 		opcode = OPCODE_COMMON_MCC_DESTROY;
 		break;
 	default:
-		printk(KERN_WARNING DRV_NAME ":bad Q type in Q destroy cmd\n");
-		status = -1;
-		goto err;
+		BUG();
 	}
 	be_cmd_hdr_prepare(&req->hdr, subsys, opcode, sizeof(*req));
 	req->id = cpu_to_le16(q->id);
 
 	status = be_mbox_db_ring(adapter);
-err:
+
 	spin_unlock(&adapter->mbox_lock);
 
 	return status;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 9c8654d..ab5fcc0 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -66,15 +66,14 @@ static void be_intr_set(struct be_adapter *adapter, bool enable)
 	u8 __iomem *addr = adapter->pcicfg + PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET;
 	u32 reg = ioread32(addr);
 	u32 enabled = reg & MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK;
-	if (!enabled && enable) {
+
+	if (!enabled && enable)
 		reg |= MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK;
-	} else if (enabled && !enable) {
+	else if (enabled && !enable)
 		reg &= ~MEMBAR_CTRL_INT_CTRL_HOSTINTR_MASK;
-	} else {
-		printk(KERN_WARNING DRV_NAME
-			": bad value in membar_int_ctrl reg=0x%x\n", reg);
+	else
 		return;
-	}
+
 	iowrite32(reg, addr);
 }
 
@@ -1981,12 +1980,6 @@ static int __init be_init_module(void)
 			" Using 2048\n");
 		rx_frag_size = 2048;
 	}
-	/* Ensure rx_frag_size is aligned to chache line */
-	if (SKB_DATA_ALIGN(rx_frag_size) != rx_frag_size) {
-		printk(KERN_WARNING DRV_NAME
-			" : Bad module param rx_frag_size. Using 2048\n");
-		rx_frag_size = 2048;
-	}
 
 	return pci_register_driver(&be_driver);
 }
-- 
1.6.0.4

