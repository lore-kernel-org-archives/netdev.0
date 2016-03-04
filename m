From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Subject: [PATCH V2 1/1] be2net: Don't leak iomapped memory on removal.
Date: Fri,  4 Mar 2016 15:36:56 -0600
Message-ID: <1457127416-21144-2-git-send-email-dougmill@linux.vnet.ibm.com>
References: <1457127416-21144-1-git-send-email-dougmill@linux.vnet.ibm.com>
Cc: sathya.perla@broadcom.com, ajit.khaparde@broadcom.com,
	padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:40943 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759498AbcCDVhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 16:37:03 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dougmill@linux.vnet.ibm.com>;
	Fri, 4 Mar 2016 14:37:02 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 19D403E40041
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 14:37:00 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u24Lb0Yj37290010
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2016 14:37:00 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u24LaxFZ023920
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2016 14:36:59 -0700
In-Reply-To: <1457127416-21144-1-git-send-email-dougmill@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The adapter->pcicfg resource is either mapped via pci_iomap() or
derived from adapter->db. During be_remove() this resource was ignored
and so could remain mapped after remove.

Add a flag to track whether adapter->pcicfg was mapped or not, then
use that flag in be_unmap_pci_bars() to unmap if required.

Fixes: 25848c901 ("use PCI MMIO read instead of config read for errors")

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
index f99de36..6a7260b 100644
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
+			adapter->pcicfg_mapped = true;
 		} else {
 			adapter->pcicfg = adapter->db + SRIOV_VF_PCICFG_OFFSET;
+			adapter->pcicfg_mapped = false;
 		}
 	}
 
-- 
1.7.1
