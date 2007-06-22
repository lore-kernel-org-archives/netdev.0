From: Mithlesh Thukral <mithlesh@netxen.com>
Subject: [PATCH 1/3] NetXen: Fix MSI issues by using PCI function 0
Date: Fri, 22 Jun 2007 01:40:41 -0700
Message-ID: <200706220840.l5M8efE3021779@dut39.unminc.com>
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:5865 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752142AbXFVIkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 04:40:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetXen: Fix issue of MSI not working correctly
NetXen driver uses PCI function 0 to provide the functionality of MSI.
The patch makes driver check the bus master bit for function 0 and
enable it after the card initialization.

Signed-off-by: Milan Bag <mbag@netxen.com>
Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>
Signed-off-by: Mithlesh Thukral <mithlesh@netxen.com>

---

 drivers/net/netxen/netxen_nic_main.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6167b58..e68356b 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -355,13 +355,6 @@ #endif
 	/* initialize the adapter */
 	netxen_initialize_adapter_hw(adapter);
 
-#ifdef CONFIG_PPC
-	if ((adapter->ahw.boardcfg.board_type ==
-		NETXEN_BRDTYPE_P2_SB31_10G_IMEZ) &&
-			(pci_func_id == 2))
-		    goto err_out_free_adapter;
-#endif /* CONFIG_PPC */
-
 	/*
 	 *  Adapter in our case is quad port so initialize it before
 	 *  initializing the ports
@@ -509,6 +502,12 @@ #endif
 					NETXEN_CAM_RAM(0x1fc)));
 		if (val == 0x55555555) {
 		    /* This is the first boot after power up */
+		    netxen_nic_read_w0(adapter, NETXEN_PCIE_REG(0x4), &val);
+		    if (!(val & 0x4)) {
+			val |= 0x4;
+			netxen_nic_write_w0(adapter, NETXEN_PCIE_REG(0x4), val);
+			mdelay(100);
+		    }
 		    val = readl(NETXEN_CRB_NORMALIZE(adapter,
 					NETXEN_ROMUSB_GLB_SW_RESET));
 		    printk(KERN_INFO"NetXen: read 0x%08x for reset reg.\n",val);
