From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next v4 7/8] qlcnic: Skip unknown entry type while collecting firmware dump
Date: Fri, 18 Oct 2013 12:22:34 -0400
Message-ID: <5bb945612cf00b550775bcf5be30b11ffed4aaf0.1382090311.git.himanshu.madhani@qlogic.com>
References: <cover.1382090311.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:62099 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756574Ab3JRQxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 12:53:16 -0400
In-Reply-To: <cover.1382090311.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

o Driver aborts the minidump collection operation when it finds
  an unknown entry opcode. This patch skips unknown entry type
  and resumes the minidump collection operation.
o Removed a comparision of collected dump size with expected dump size.
  Size may differ when driver decides to skip an entry.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   | 41 ++++++++++------------
 1 file changed, 19 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index 1551360..7763962 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -1187,41 +1187,38 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 		}
 
 		if (ops_index == ops_cnt) {
-			dev_info(&adapter->pdev->dev,
-				 "Invalid entry type %d, exiting dump\n",
+			dev_info(dev, "Skipping unknown entry opcode %d\n",
 				 entry->hdr.type);
-			goto error;
+			entry->hdr.flags |= QLCNIC_DUMP_SKIP;
+			entry_offset += entry->hdr.offset;
+			continue;
 		}
 
 		/* Collect dump for this entry */
 		dump = fw_dump_ops[ops_index].handler(adapter, entry, buffer);
-		if (!qlcnic_valid_dump_entry(&adapter->pdev->dev, entry, dump))
+		if (!qlcnic_valid_dump_entry(dev, entry, dump)) {
 			entry->hdr.flags |= QLCNIC_DUMP_SKIP;
+			entry_offset += entry->hdr.offset;
+			continue;
+		}
+
 		buf_offset += entry->hdr.cap_size;
 		entry_offset += entry->hdr.offset;
 		buffer = fw_dump->data + buf_offset;
 	}
-	if (dump_size != buf_offset) {
-		dev_info(&adapter->pdev->dev,
-			 "Captured(%d) and expected size(%d) do not match\n",
-			 buf_offset, dump_size);
-		goto error;
-	} else {
-		fw_dump->clr = 1;
-		snprintf(mesg, sizeof(mesg), "FW_DUMP=%s",
-			 adapter->netdev->name);
-		dev_info(&adapter->pdev->dev, "%s: Dump data, %d bytes captured\n",
-			 adapter->netdev->name, fw_dump->size);
-		/* Send a udev event to notify availability of FW dump */
-		kobject_uevent_env(&adapter->pdev->dev.kobj, KOBJ_CHANGE, msg);
-		return 0;
-	}
-error:
+
+	fw_dump->clr = 1;
+	snprintf(mesg, sizeof(mesg), "FW_DUMP=%s", adapter->netdev->name);
+	dev_info(dev, "%s: Dump data %d bytes captured, template header size %d bytes\n",
+		 adapter->netdev->name, fw_dump->size, tmpl_hdr->size);
+	/* Send a udev event to notify availability of FW dump */
+	kobject_uevent_env(&dev->kobj, KOBJ_CHANGE, msg);
+
 	if (fw_dump->use_pex_dma)
 		dma_free_coherent(dev, QLC_PEX_DMA_READ_SIZE,
 				  fw_dump->dma_buffer, fw_dump->phys_addr);
-	vfree(fw_dump->data);
-	return -EINVAL;
+
+	return 0;
 }
 
 void qlcnic_83xx_get_minidump_template(struct qlcnic_adapter *adapter)
-- 
1.8.1.4
