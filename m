From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] net/CXGB3: Avoid access MMIO on offlined PCI dev
Date: Thu, 25 Jul 2013 15:32:04 +0800
Message-ID: <1374737524-8410-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: divy@chelsio.com, davem@davemloft.net,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:43789 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab3GYHma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 03:42:30 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 25 Jul 2013 07:32:12 -0000
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 5949C19D8041
	for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 01:31:59 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6P7W9OK134884
	for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 01:32:09 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6P7W7d5026550
	for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 01:32:08 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While we have EEH errors happened on specific PCI device, the PE
(Partitionable Endpoint) which includes the PCI device is expected
to be reset. During the reset, the PCI device should have been
marked as "offline" and it's not safe to access MMIO of that PCI
device with "offline" state. That might cause the failure to do
EEH recovery and then the PCI device is removed from the system for
ever before manual recovery.

The patch avoids access to MMIO while the PCI device has been marked
"offline" so that to avoid additional EEH errors during reset and make
sure that the EEH recovery can be done successfully.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/chelsio/cxgb3/adapter.h |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/adapter.h b/drivers/net/ethernet/chelsio/cxgb3/adapter.h
index 8b395b5..5b20c5d 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb3/adapter.h
@@ -270,7 +270,10 @@ struct adapter {
 
 static inline u32 t3_read_reg(struct adapter *adapter, u32 reg_addr)
 {
-	u32 val = readl(adapter->regs + reg_addr);
+	u32 val = 0xFFFFFFFF;
+
+	if (!pci_channel_offline(adapter->pdev))
+		val = readl(adapter->regs + reg_addr);
 
 	CH_DBG(adapter, MMIO, "read register 0x%x value 0x%x\n", reg_addr, val);
 	return val;
@@ -279,7 +282,8 @@ static inline u32 t3_read_reg(struct adapter *adapter, u32 reg_addr)
 static inline void t3_write_reg(struct adapter *adapter, u32 reg_addr, u32 val)
 {
 	CH_DBG(adapter, MMIO, "setting register 0x%x to 0x%x\n", reg_addr, val);
-	writel(val, adapter->regs + reg_addr);
+	if (!pci_channel_offline(adapter->pdev))
+		writel(val, adapter->regs + reg_addr);
 }
 
 static inline struct port_info *adap2pinfo(struct adapter *adap, int idx)
-- 
1.7.5.4
