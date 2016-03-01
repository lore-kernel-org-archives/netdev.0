From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Subject: [PATCH 1/1] Fix bug where remove of device fails to free all resources.
Date: Tue,  1 Mar 2016 14:34:52 -0600
Message-ID: <1456864492-32257-2-git-send-email-dougmill@linux.vnet.ibm.com>
References: <1456864492-32257-1-git-send-email-dougmill@linux.vnet.ibm.com>
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:33864 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751778AbcCAUfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 15:35:09 -0500
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dougmill@linux.vnet.ibm.com>;
	Tue, 1 Mar 2016 13:35:08 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id A667C3E40041
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2016 13:34:57 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u21KYvos33226898
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 13:34:57 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u21KYuRE021551
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2016 13:34:57 -0700
In-Reply-To: <1456864492-32257-1-git-send-email-dougmill@linux.vnet.ibm.com>
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
