From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH 1/2] net/benet: Identify interface type in advance
Date: Fri, 25 Oct 2013 16:02:44 +0800
Message-ID: <1382688165-20957-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: sathya.perla@emulex.com, Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:45855 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751434Ab3JYIC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Oct 2013 04:02:57 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Fri, 25 Oct 2013 04:02:56 -0400
Received: from b01cxnp22035.gho.pok.ibm.com (b01cxnp22035.gho.pok.ibm.com [9.57.198.25])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 40DB56E803A
	for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 04:02:51 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22035.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9P82qZ364094392
	for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 08:02:52 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r9P82oUP001208
	for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 04:02:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function be_map_pci_bars() is being called in be_ctrl_init(). Since
be_ctrl_init() has fetched the value of PCI config register 0x58,
we needn't access the same register in be_map_pci_bars() again to
incur unnecessary PCI config access.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2c38cc4..1a799d2 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3960,11 +3960,6 @@ static int be_roce_map_pci_bars(struct be_adapter *adapter)
 static int be_map_pci_bars(struct be_adapter *adapter)
 {
 	u8 __iomem *addr;
-	u32 sli_intf;
-
-	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
-	adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
-				SLI_INTF_IF_TYPE_SHIFT;
 
 	if (BEx_chip(adapter) && be_physfn(adapter)) {
 		adapter->csr = pci_iomap(adapter->pdev, 2, 0);
@@ -4011,7 +4006,9 @@ static int be_ctrl_init(struct be_adapter *adapter)
 
 	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
 	adapter->sli_family = (sli_intf & SLI_INTF_FAMILY_MASK) >>
-				 SLI_INTF_FAMILY_SHIFT;
+				SLI_INTF_FAMILY_SHIFT;
+	adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
+				SLI_INTF_IF_TYPE_SHIFT;
 	adapter->virtfn = (sli_intf & SLI_INTF_FT_MASK) ? 1 : 0;
 
 	status = be_map_pci_bars(adapter);
-- 
1.7.9.5
