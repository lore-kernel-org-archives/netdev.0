From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 1/1] qlge: Fix receive packets drop.
Date: Tue, 15 Mar 2016 07:13:45 -0400
Message-ID: <1458040425-12937-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	<harish.patil@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:44304 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934369AbcCOLyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 07:54:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running small packets [length < 256 bytes] traffic, packets were
being dropped due to invalid data in those packets which were
delivered by the driver upto the stack. Using pci_dma_sync_single_for_cpu
ensures copying latest and updated data into skb from the receive buffer.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 9979764..b28e73e 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1648,7 +1648,18 @@ static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 		return;
 	}
 	skb_reserve(new_skb, NET_IP_ALIGN);
+
+	pci_dma_sync_single_for_cpu(qdev->pdev,
+				    dma_unmap_addr(sbq_desc, mapaddr),
+				    dma_unmap_len(sbq_desc, maplen),
+				    PCI_DMA_FROMDEVICE);
+
 	memcpy(skb_put(new_skb, length), skb->data, length);
+
+	pci_dma_sync_single_for_device(qdev->pdev,
+				       dma_unmap_addr(sbq_desc, mapaddr),
+				       dma_unmap_len(sbq_desc, maplen),
+				       PCI_DMA_FROMDEVICE);
 	skb = new_skb;
 
 	/* Frame error, so drop the packet. */
-- 
2.7.2
