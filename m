From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH-2.6.28] net: ipg.c fix bracing on endian swapping
Date: Mon, 17 Nov 2008 13:42:09 -0800
Message-ID: <1226958129.6150.10.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:39324 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751279AbYKQVmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 16:42:12 -0500
Received: by wf-out-1314.google.com with SMTP id 27so2809105wfd.4
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2008 13:42:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rxfd->frag_info is a __le64, IPG_RFI_FRAGLEN is a cpu-endian
constant and wants to be outside of the le64_to_cpu. Fixed
in multiple places.

Also an occurrence where le64_to_cpu was used instead of cpu_to_le64

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/ipg.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 7373daf..0593698 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1112,7 +1112,7 @@ static void ipg_nic_rx_free_skb(struct net_device *dev)
 		struct ipg_rx *rxfd = sp->rxd + entry;
 
 		pci_unmap_single(sp->pdev,
-			le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
+			le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 			sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 		dev_kfree_skb_irq(sp->rx_buff[entry]);
 		sp->rx_buff[entry] = NULL;
@@ -1179,7 +1179,7 @@ static int ipg_nic_rx_check_error(struct net_device *dev)
 		 */
 		if (sp->rx_buff[entry]) {
 			pci_unmap_single(sp->pdev,
-				le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
+				le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 				sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
 			dev_kfree_skb_irq(sp->rx_buff[entry]);
@@ -1246,7 +1246,7 @@ static void ipg_nic_rx_with_start(struct net_device *dev,
 	if (jumbo->found_start)
 		dev_kfree_skb_irq(jumbo->skb);
 
-	pci_unmap_single(pdev, le64_to_cpu(rxfd->frag_info & ~IPG_RFI_FRAGLEN),
+	pci_unmap_single(pdev, le64_to_cpu(rxfd->frag_info) & ~IPG_RFI_FRAGLEN,
 			 sp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
 	skb_put(skb, sp->rxfrag_size);
@@ -1349,7 +1349,7 @@ static int ipg_nic_rx_jumbo(struct net_device *dev)
 		unsigned int entry = curr % IPG_RFDLIST_LENGTH;
 		struct ipg_rx *rxfd = sp->rxd + entry;
 
-		if (!(rxfd->rfs & le64_to_cpu(IPG_RFS_RFDDONE)))
+		if (!(rxfd->rfs & cpu_to_le64(IPG_RFS_RFDDONE)))
 			break;
 
 		switch (ipg_nic_rx_check_frame_type(dev)) {
-- 
1.6.0.4.994.g16bd3e



