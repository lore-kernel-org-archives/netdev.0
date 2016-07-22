From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 1/9] staging: slicoss: handle allocation failure in
 slic_init_adapter
Date: Fri, 22 Jul 2016 23:09:11 +0200
Message-ID: <1469221759-17652-2-git-send-email-LinoSanfilippo@gmx.de>
References: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Lino Sanfilippo <LinoSanfilippo@gmx.de>, linux-kernel@vger.kernel.org
To: liodot@gmail.com,
	charrer@alacritech.com,
	gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The memory allocation in slic_init_adapter() can fail. Return an error in
this case and unwind properly. Also make sure that the allocated memory is
properly freed in case of an error in the calling probe() function.
By doing this also replace the alloc() followed by memset to zero the
memory with a zalloc() version.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/staging/slicoss/slicoss.c | 38 ++++++++++++++++++++++----------------
 1 file changed, 22 insertions(+), 16 deletions(-)

diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index ac126d4..dae07410 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -2896,10 +2896,10 @@ static void slic_init_driver(void)
 	}
 }
 
-static void slic_init_adapter(struct net_device *netdev,
-			      struct pci_dev *pcidev,
-			      const struct pci_device_id *pci_tbl_entry,
-			      void __iomem *memaddr, int chip_idx)
+static int slic_init_adapter(struct net_device *netdev,
+			     struct pci_dev *pcidev,
+			     const struct pci_device_id *pci_tbl_entry,
+			     void __iomem *memaddr, int chip_idx)
 {
 	ushort index;
 	struct slic_handle *pslic_handle;
@@ -2938,13 +2938,13 @@ static void slic_init_adapter(struct net_device *netdev,
 		pslic_handle->next = adapter->pfree_slic_handles;
 		adapter->pfree_slic_handles = pslic_handle;
 	}
-	adapter->pshmem = (struct slic_shmem *)
-					pci_alloc_consistent(adapter->pcidev,
-					sizeof(struct slic_shmem),
-					&adapter->
-					phys_shmem);
-	if (adapter->pshmem)
-		memset(adapter->pshmem, 0, sizeof(struct slic_shmem));
+	adapter->pshmem = pci_zalloc_consistent(adapter->pcidev,
+						sizeof(struct slic_shmem),
+						&adapter->phys_shmem);
+	if (!adapter->pshmem)
+		return -ENOMEM;
+
+	return 0;
 }
 
 static const struct net_device_ops slic_netdev_ops = {
@@ -3142,13 +3142,17 @@ static int slic_entry_probe(struct pci_dev *pcidev,
 
 	slic_init_driver();
 
-	slic_init_adapter(netdev,
-			  pcidev, pci_tbl_entry, memmapped_ioaddr, cards_found);
+	err = slic_init_adapter(netdev, pcidev, pci_tbl_entry, memmapped_ioaddr,
+				cards_found);
+	if (err) {
+		dev_err(&pcidev->dev, "failed to init adapter: %i\n", err);
+		goto err_out_unmap;
+	}
 
 	err = slic_card_locate(adapter);
 	if (err) {
 		dev_err(&pcidev->dev, "cannot locate card\n");
-		goto err_out_unmap;
+		goto err_clean_init;
 	}
 
 	card = adapter->card;
@@ -3160,7 +3164,7 @@ static int slic_entry_probe(struct pci_dev *pcidev,
 
 	err = slic_card_init(card, adapter);
 	if (err)
-		goto err_out_unmap;
+		goto err_clean_init;
 
 	slic_adapter_set_hwaddr(adapter);
 
@@ -3172,13 +3176,15 @@ static int slic_entry_probe(struct pci_dev *pcidev,
 	err = register_netdev(netdev);
 	if (err) {
 		dev_err(&pcidev->dev, "Cannot register net device, aborting.\n");
-		goto err_out_unmap;
+		goto err_clean_init;
 	}
 
 	cards_found++;
 
 	return 0;
 
+err_clean_init:
+	slic_init_cleanup(adapter);
 err_out_unmap:
 	iounmap(memmapped_ioaddr);
 err_out_free_netdev:
-- 
1.9.1
