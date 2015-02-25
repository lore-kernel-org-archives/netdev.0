From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: enable packet split only when IOMMU present
Date: Wed, 25 Feb 2015 00:58:30 -0800
Message-ID: <1424854720-18825-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4721 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752608AbbBYI6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:46 -0500
In-Reply-To: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When an IOMMU is in use, the packet split receive path shows a distinct
advantage over the single-buffer path because it minimizes DMA mapping
and unmapping. However, this is not an advantage for systems with no
IOMMU. At init time, check to see if an IOMMU is enabled and enable
packet split receives.

Change-ID: I4f70d2e9c31bbea3dc8fd0c5734959a6e6602210
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      | 1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 3ee730d..eb6307e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -36,6 +36,7 @@
 #include <linux/aer.h>
 #include <linux/netdevice.h>
 #include <linux/ioport.h>
+#include <linux/iommu.h>
 #include <linux/slab.h>
 #include <linux/list.h>
 #include <linux/string.h>
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bb876e3..a8824c7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7279,8 +7279,12 @@ static int i40e_sw_init(struct i40e_pf *pf)
 	/* Set default capability flags */
 	pf->flags = I40E_FLAG_RX_CSUM_ENABLED |
 		    I40E_FLAG_MSI_ENABLED     |
-		    I40E_FLAG_MSIX_ENABLED    |
-		    I40E_FLAG_RX_PS_ENABLED;
+		    I40E_FLAG_MSIX_ENABLED;
+
+	if (iommu_present(&pci_bus_type))
+		pf->flags |= I40E_FLAG_RX_PS_ENABLED;
+	else
+		pf->flags |= I40E_FLAG_RX_1BUF_ENABLED;
 
 	/* Set default ITR */
 	pf->rx_itr_default = I40E_ITR_DYNAMIC | I40E_ITR_RX_DEF;
-- 
1.9.3
