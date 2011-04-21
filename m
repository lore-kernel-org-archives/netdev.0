From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Fixed a bug in be_cmd_get_regs().
Date: Thu, 21 Apr 2011 18:48:12 +0530
Message-ID: <8a31447a-9317-4569-ae2b-865feb9ce594@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:27104 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751321Ab1DUNTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 09:19:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resending patch as the 'changelog' got missed out in my previous submission.

Same WRB entry was being reused over different iterations of a 
loop while issuing non-embedded IOCTL requests.Fixed couple of minor bugs 
in this path as well.
Re-factored code to alloc/free memory for DMA outside of loop


Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/benet/be_cmds.c |   53 ++++++++++++++++++++++--------------------
 1 files changed, 28 insertions(+), 25 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index af8cf3d..0fc06d3 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1214,8 +1214,8 @@ int be_cmd_get_reg_len(struct be_adapter *adapter, u32 *log_size)
 	if (!status) {
 		struct be_cmd_resp_get_fat *resp = embedded_payload(wrb);
 		if (log_size && resp->log_size)
-			*log_size = le32_to_cpu(resp->log_size -
-					sizeof(u32));
+			*log_size = le32_to_cpu(resp->log_size) -
+					sizeof(u32);
 	}
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
@@ -1228,7 +1228,8 @@ void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 	struct be_mcc_wrb *wrb;
 	struct be_cmd_req_get_fat *req;
 	struct be_sge *sge;
-	u32 offset = 0, total_size, buf_size, log_offset = sizeof(u32);
+	u32 offset = 0, total_size, buf_size,
+				log_offset = sizeof(u32), payload_len;
 	int status;
 
 	if (buf_len == 0)
@@ -1236,37 +1237,39 @@ void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 
 	total_size = buf_len;
 
+	get_fat_cmd.size = sizeof(struct be_cmd_req_get_fat) + 60*1024;
+	get_fat_cmd.va = pci_alloc_consistent(adapter->pdev,
+			get_fat_cmd.size,
+			&get_fat_cmd.dma);
+	if (!get_fat_cmd.va) {
+		status = -ENOMEM;
+		dev_err(&adapter->pdev->dev,
+		"Memory allocation failure while retrieving FAT data\n");
+		return;
+	}
+
 	spin_lock_bh(&adapter->mcc_lock);
 
-	wrb = wrb_from_mccq(adapter);
-	if (!wrb) {
-		status = -EBUSY;
-		goto err;
-	}
 	while (total_size) {
 		buf_size = min(total_size, (u32)60*1024);
 		total_size -= buf_size;
 
-		get_fat_cmd.size = sizeof(struct be_cmd_req_get_fat) + buf_size;
-		get_fat_cmd.va = pci_alloc_consistent(adapter->pdev,
-					get_fat_cmd.size,
-					&get_fat_cmd.dma);
-		if (!get_fat_cmd.va) {
-			status = -ENOMEM;
-			dev_err(&adapter->pdev->dev,
-					"Memory allocation failure while retrieving FAT data\n");
+		wrb = wrb_from_mccq(adapter);
+		if (!wrb) {
+			status = -EBUSY;
 			goto err;
 		}
 		req = get_fat_cmd.va;
 		sge = nonembedded_sgl(wrb);
 
-		be_wrb_hdr_prepare(wrb, get_fat_cmd.size, false, 1,
+		payload_len = sizeof(struct be_cmd_req_get_fat) + buf_size;
+		be_wrb_hdr_prepare(wrb, payload_len, false, 1,
 				OPCODE_COMMON_MANAGE_FAT);
 
 		be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
-				OPCODE_COMMON_MANAGE_FAT, get_fat_cmd.size);
+				OPCODE_COMMON_MANAGE_FAT, payload_len);
 
-		sge->pa_hi = cpu_to_le32(upper_32_bits(get_fat_cmd.size));
+		sge->pa_hi = cpu_to_le32(upper_32_bits(get_fat_cmd.dma));
 		sge->pa_lo = cpu_to_le32(get_fat_cmd.dma & 0xFFFFFFFF);
 		sge->len = cpu_to_le32(get_fat_cmd.size);
 
@@ -1281,17 +1284,17 @@ void be_cmd_get_regs(struct be_adapter *adapter, u32 buf_len, void *buf)
 			memcpy(buf + offset,
 				resp->data_buffer,
 				resp->read_log_length);
-		}
-		pci_free_consistent(adapter->pdev, get_fat_cmd.size,
-				get_fat_cmd.va,
-				get_fat_cmd.dma);
-		if (status)
+		} else {
 			dev_err(&adapter->pdev->dev, "FAT Table Retrieve error\n");
-
+			goto err;
+		}
 		offset += buf_size;
 		log_offset += buf_size;
 	}
 err:
+	pci_free_consistent(adapter->pdev, get_fat_cmd.size,
+			get_fat_cmd.va,
+			get_fat_cmd.dma);
 	spin_unlock_bh(&adapter->mcc_lock);
 }
 
-- 
1.5.6.1

