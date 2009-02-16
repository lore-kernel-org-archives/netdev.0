From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/3] netxen: remove superfluous doorbell map
Date: Mon, 16 Feb 2009 01:18:49 -0800
Message-ID: <1234775931-18518-2-git-send-email-dhananjay@netxen.com>
References: <1234775931-18518-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:48982 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752319AbZBPJS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2009 04:18:57 -0500
In-Reply-To: <1234775931-18518-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For NX3031 pci doorbells are not used. If unnecessary mapping
of doorbell space fails, pci probe bails out.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 9f33e44..be393a2 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -482,7 +482,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 
 	u8 __iomem *db_ptr = NULL;
-	unsigned long mem_base, mem_len, db_base, db_len, pci_len0 = 0;
+	unsigned long mem_base, mem_len, db_base, db_len = 0, pci_len0 = 0;
 	int i = 0, err;
 	int first_driver, first_boot;
 	u32 val;
@@ -611,6 +611,9 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	dev_info(&pdev->dev, "%dMB memory map\n", (int)(mem_len>>20));
 
+	if (NX_IS_REVISION_P3(revision_id))
+		goto skip_doorbell;
+
 	db_base = pci_resource_start(pdev, 4);	/* doorbell is on bar 4 */
 	db_len = pci_resource_len(pdev, 4);
 
@@ -620,8 +623,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		err = -EIO;
 		goto err_out_iounmap;
 	}
-	DPRINTK(INFO, "doorbell ioremap from %lx a size of %lx\n", db_base,
-		db_len);
 
 	db_ptr = ioremap(db_base, NETXEN_DB_MAPSIZE_BYTES);
 	if (!db_ptr) {
@@ -630,8 +631,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		err = -EIO;
 		goto err_out_iounmap;
 	}
-	DPRINTK(INFO, "doorbell ioremaped at %p\n", db_ptr);
 
+skip_doorbell:
 	adapter->ahw.pci_base0 = mem_ptr0;
 	adapter->ahw.pci_len0 = pci_len0;
 	adapter->ahw.first_page_group_start = first_page_group_start;
@@ -941,8 +942,9 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 	if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
 		pci_disable_msi(pdev);
 
-	iounmap(adapter->ahw.db_base);
 	iounmap(adapter->ahw.pci_base0);
+	if (adapter->ahw.db_base != NULL)
+		iounmap(adapter->ahw.db_base);
 	if (adapter->ahw.pci_base1 != NULL)
 		iounmap(adapter->ahw.pci_base1);
 	if (adapter->ahw.pci_base2 != NULL)
-- 
1.6.0.2

