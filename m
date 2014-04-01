From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH] net/mlx4_core: match pci_device_id including dynids
Date: Tue,  1 Apr 2014 12:36:01 +0800
Message-ID: <1396326961-20395-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>
To: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, amirv@mellanox.com, bhelgaas@google.com,
	linux-pci@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:40801 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbaDAEg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 00:36:28 -0400
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Tue, 1 Apr 2014 10:06:25 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
pci_device_id.driver_data to __mlx4_init_one during reset".

pci_match_id() just match the static pci_device_id, which may return NULL if
someone binds the driver to a device manually using
/sys/bus/pci/drivers/.../new_id.

This patch match pci_device_id with pci_match_device() to cover both dynids
and static id_table.

Thanks to Bjorn finding this issue.

CC: Bjorn Helgaas <bhelgaas@google.com>
CC: Amir Vadai <amirv@mellanox.com>
Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
Acked-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    4 +++-
 drivers/pci/pci-driver.c                  |    3 ++-
 include/linux/pci.h                       |    2 ++
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index aa54ef7..b0edb5c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2673,7 +2673,9 @@ static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
 	const struct pci_device_id *id;
 	int ret;
 
-	id = pci_match_id(mlx4_pci_table, pdev);
+	id = pci_match_device(pci_dev_driver(pdev), pdev);
+	BUG_ON(!id);
+
 	ret = __mlx4_init_one(pdev, id->driver_data);
 
 	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
diff --git a/drivers/pci/pci-driver.c b/drivers/pci/pci-driver.c
index 25f0bc6..1ee26a1 100644
--- a/drivers/pci/pci-driver.c
+++ b/drivers/pci/pci-driver.c
@@ -225,7 +225,7 @@ const struct pci_device_id *pci_match_id(const struct pci_device_id *ids,
  * system is in its list of supported devices.  Returns the matching
  * pci_device_id structure or %NULL if there is no match.
  */
-static const struct pci_device_id *pci_match_device(struct pci_driver *drv,
+const struct pci_device_id *pci_match_device(struct pci_driver *drv,
 						    struct pci_dev *dev)
 {
 	struct pci_dynid *dynid;
@@ -1355,6 +1355,7 @@ postcore_initcall(pci_driver_init);
 
 EXPORT_SYMBOL_GPL(pci_add_dynid);
 EXPORT_SYMBOL(pci_match_id);
+EXPORT_SYMBOL(pci_match_device);
 EXPORT_SYMBOL(__pci_register_driver);
 EXPORT_SYMBOL(pci_unregister_driver);
 EXPORT_SYMBOL(pci_dev_driver);
diff --git a/include/linux/pci.h b/include/linux/pci.h
index 44f6883..8ede1b5 100644
--- a/include/linux/pci.h
+++ b/include/linux/pci.h
@@ -1134,6 +1134,8 @@ int pci_add_dynid(struct pci_driver *drv,
 		  unsigned long driver_data);
 const struct pci_device_id *pci_match_id(const struct pci_device_id *ids,
 					 struct pci_dev *dev);
+const struct pci_device_id *pci_match_device(struct pci_driver *drv,
+						    struct pci_dev *dev);
 int pci_scan_bridge(struct pci_bus *bus, struct pci_dev *dev, int max,
 		    int pass);
 
-- 
1.7.9.5
