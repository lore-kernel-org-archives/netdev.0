From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] net: atheros: atl2: don't return zero on failure path in atl2_probe()
Date: Sat, 20 May 2017 01:52:11 +0300
Message-ID: <1495234331-27615-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Jay Cliburn <jcliburn@gmail.com>,
        Chris Snook <chris.snook@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If dma mask checks fail in atl2_probe(), it breaks off initialization,
deallocates all resources, but returns zero.

The patch adds proper error code return value and
make error code setup unified.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/atheros/atlx/atl2.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 63f2deec2a52..77a1c03255de 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -1353,6 +1353,7 @@ static int atl2_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) &&
 		pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
 		printk(KERN_ERR "atl2: No usable DMA configuration, aborting\n");
+		err = -EIO;
 		goto err_dma;
 	}
 
@@ -1366,10 +1367,11 @@ static int atl2_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * pcibios_set_master to do the needed arch specific settings */
 	pci_set_master(pdev);
 
-	err = -ENOMEM;
 	netdev = alloc_etherdev(sizeof(struct atl2_adapter));
-	if (!netdev)
+	if (!netdev) {
+		err = -ENOMEM;
 		goto err_alloc_etherdev;
+	}
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 
@@ -1408,8 +1410,6 @@ static int atl2_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_sw_init;
 
-	err = -EIO;
-
 	netdev->hw_features = NETIF_F_HW_VLAN_CTAG_RX;
 	netdev->features |= (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX);
 
-- 
2.7.4
