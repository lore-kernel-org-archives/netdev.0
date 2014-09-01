From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 09/12] be2net: make be_cmd_get_regs() return a status
Date: Mon, 1 Sep 2014 11:54:21 +0530
Message-ID: <1409552664-15990-10-git-send-email-sathya.perla@emulex.com>
References: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:22507 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbaIAGV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 02:21:58 -0400
In-Reply-To: <1409552664-15990-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

There are a few failure cases in be_cmd_get_regs() that ideally must return
an error value. This style is used across all the routines in be_cmds.c with
this routine being an exception. This patch fixes this.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   10 +++++-----
 drivers/net/ethernet/emulex/benet/be_cmds.h |    2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index ca9ec18..5be100d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1681,17 +1681,17 @@ err:
 	return status;
 }
 
-void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
+int be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 {
 	struct be_dma_mem get_fat_cmd;
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_fat *req;
 	u32 offset = 0, total_size, buf_size,
 				log_offset = sizeof(u32), payload_len;
-	int status;
+	int status = 0;
 
 	if (buf_len == 0)
-		return;
+		return -EIO;
 
 	total_size = buf_len;
 
@@ -1700,10 +1700,9 @@ void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 					      get_fat_cmd.size,
 					      &get_fat_cmd.dma);
 	if (!get_fat_cmd.va) {
-		status = -ENOMEM;
 		dev_err(&adapter->pdev->dev,
 		"Memory allocation failure while retrieving FAT data\n");
-		return;
+		return -ENOMEM;
 	}
 
 	spin_lock_bh(&adapter->mcc_lock);
@@ -1746,6 +1745,7 @@ err:
 	pci_free_consistent(adapter->pdev, get_fat_cmd.size,
 			    get_fat_cmd.va, get_fat_cmd.dma);
 	spin_unlock_bh(&adapter->mcc_lock);
+	return status;
 }
 
 /* Uses synchronous mcc */
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 5284b82..0e11868 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -2101,7 +2101,7 @@ int be_cmd_get_die_temperature(struct be_adapter *adapter);
 int be_cmd_get_cntl_attributes(struct be_adapter *adapter);
 int be_cmd_req_native_mode(struct be_adapter *adapter);
 int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size);
-void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf);
+int be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf);
 int be_cmd_get_fn_privileges(struct be_adapter *adapter, u32 *privilege,
 			     u32 domain);
 int be_cmd_set_fn_privileges(struct be_adapter *adapter, u32 privileges,
-- 
1.7.1
