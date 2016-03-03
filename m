From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Subject: [PATCH 1/1] be2net: Don't leak iomapped memory on removal.
Date: Thu,  3 Mar 2016 16:35:49 -0600
Message-ID: <1457044549-10563-2-git-send-email-dougmill@linux.vnet.ibm.com>
References: <1457044549-10563-1-git-send-email-dougmill@linux.vnet.ibm.com>
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:53836 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757500AbcCCWgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:36:22 -0500
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dougmill@linux.vnet.ibm.com>;
	Thu, 3 Mar 2016 15:36:20 -0700
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 4F8423E40041
	for <netdev@vger.kernel.org>; Thu,  3 Mar 2016 15:35:53 -0700 (MST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u23MZqQY31654076
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2016 22:35:52 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u23MZqmE027289
	for <netdev@vger.kernel.org>; Thu, 3 Mar 2016 17:35:52 -0500
In-Reply-To: <1457044549-10563-1-git-send-email-dougmill@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The adapter->pcicfg resource is either mapped via pci_iomap() or
derived from adapter->db. During be_remove() this resource was ignored
and so could remain mapped after remove.

Add a flag to track whether adapter->pcicfg was mapped or not, then
use that flag in be_unmap_pci_bars() to unmap if required.

Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index cf83783..f975129 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -531,6 +531,7 @@ struct be_adapter {
 
 	struct delayed_work be_err_detection_work;
 	u8 err_flags;
+	bool pcicfg_mapped;	/* pcicfg obtained via pci_iomap() */
 	u32 flags;
 	u32 cmd_privileges;
 	/* Ethtool knobs and info */
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f99de36..a79b8a5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4968,6 +4968,8 @@ static void be_unmap_pci_bars(struct be_adapter *adapter)
 		pci_iounmap(adapter->pdev, adapter->csr);
 	if (adapter->db)
 		pci_iounmap(adapter->pdev, adapter->db);
+	if (adapter->pcicfg && adapter->pcicfg_mapped)
+		pci_iounmap(adapter->pdev, adapter->pcicfg);
 }
 
 static int db_bar(struct be_adapter *adapter)
@@ -5019,8 +5021,10 @@ static int be_map_pci_bars(struct be_adapter *adapter)
 			if (!addr)
 				goto pci_map_err;
 			adapter->pcicfg = addr;
+			adapter->pcicfg_mapped = 1;
 		} else {
 			adapter->pcicfg = adapter->db + SRIOV_VF_PCICFG_OFFSET;
+			adapter->pcicfg_mapped = 0;
 		}
 	}
 
-- 
1.7.1
