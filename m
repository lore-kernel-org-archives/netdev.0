From: Robert Hancock <hancockrwd@gmail.com>
Subject: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in networking drivers
Date: Mon, 22 Feb 2010 20:45:45 -0600
Message-ID: <4B834159.7070105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linux-usb <linux-usb@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many networking drivers have issues with the use of the NETIF_F_HIGHDMA flag.
This flag actually indicates whether or not the device/driver can handle
skbs located in high memory (as opposed to lowmem). However, many drivers
incorrectly treat this flag as indicating that 64-bit DMA is supported, which
has nothing to do with its actual function. It makes no sense to make setting
NETIF_F_HIGHDMA conditional on whether a 64-bit DMA mask has been set, as many
drivers do, since if highmem DMA is supported at all, it should work regardless
of whether 64-bit DMA is supported. Failing to set NETIF_F_HIGHDMA when it
should be can hurt performance on architectures which use highmem since it
results in needless data copying.

This fixes up the networking drivers which currently use NETIF_F_HIGHDMA to
not do so conditionally on DMA mask settings.

For the USB kaweth and usbnet drivers, this patch also uncomments and corrects
some code to set NETIF_F_HIGHDMA based on the USB host controller's DMA mask.
These drivers should be able to access highmem unless the host controller is
non-DMA-capable, which is indicated by the DMA mask being null.

Signed-off-by: Robert Hancock <hancockrwd@gmail.com>

---

Comments welcome on the approach. Not sure what the protocol is with a patch
touching so many drivers - should the maintainers all be CCed?

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 3d4406b..8695da3 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1967,8 +1967,7 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
 
-	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_HIGHDMA;
 
 #if 0 /* disabled by default until verified */
 	dev->features |= NETIF_F_TSO;
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 4ae750e..85e567e 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -607,8 +607,7 @@ static int __devinit acenic_probe_one(struct pci_dev *pdev,
 	}
 	ap->name = dev->name;
 
-	if (ap->pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_HIGHDMA;
 
 	pci_set_drvdata(pdev, dev);
 
@@ -1162,9 +1161,7 @@ static int __devinit ace_init(struct net_device *dev)
 	 * Configure DMA attributes.
 	 */
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		ap->pci_using_dac = 1;
 	} else if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) {
-		ap->pci_using_dac = 0;
 	} else {
 		ecode = -ENODEV;
 		goto init_error;
diff --git a/drivers/net/acenic.h b/drivers/net/acenic.h
index 17079b9..4407469 100644
--- a/drivers/net/acenic.h
+++ b/drivers/net/acenic.h
@@ -693,7 +693,6 @@ struct ace_private
 				__attribute__ ((aligned (SMP_CACHE_BYTES)));
 	u32			last_tx, last_std_rx, last_mini_rx;
 #endif
-	int			pci_using_dac;
 	u8			firmware_major;
 	u8			firmware_minor;
 	u8			firmware_fix;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index de0830e..9baacdc 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2337,9 +2337,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	be_msix_enable(adapter);
 
 	status = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
-	if (!status) {
-		netdev->features |= NETIF_F_HIGHDMA;
-	} else {
+	if (status) {
 		status = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (status) {
 			dev_err(&pdev->dev, "Could not set PCI DMA Mask\n");
@@ -2347,6 +2345,8 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		}
 	}
 
+	netdev->features |= NETIF_F_HIGHDMA;
+
 	status = be_ctrl_init(adapter);
 	if (status)
 		goto free_netdev;
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a6cc9d0..02e4070 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7948,9 +7948,10 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	else
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(64);
 
+	dev->features |= NETIF_F_HIGHDMA;
+
 	/* Configure DMA attributes. */
 	if (pci_set_dma_mask(pdev, dma_mask) == 0) {
-		dev->features |= NETIF_F_HIGHDMA;
 		rc = pci_set_consistent_dma_mask(pdev, persist_dma_mask);
 		if (rc) {
 			dev_err(&pdev->dev,
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 7f9db47..c14aa46 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11871,8 +11871,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	dev->ethtool_ops = &bnx2x_ethtool_ops;
 	dev->features |= NETIF_F_SG;
 	dev->features |= NETIF_F_HW_CSUM;
-	if (bp->flags & USING_DAC_FLAG)
-		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_HIGHDMA;
 	dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
 	dev->features |= NETIF_F_TSO6;
 #ifdef BCM_VLAN
@@ -11881,8 +11880,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 
 	dev->vlan_features |= NETIF_F_SG;
 	dev->vlan_features |= NETIF_F_HW_CSUM;
-	if (bp->flags & USING_DAC_FLAG)
-		dev->vlan_features |= NETIF_F_HIGHDMA;
+	dev->vlan_features |= NETIF_F_HIGHDMA;
 	dev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
 	dev->vlan_features |= NETIF_F_TSO6;
 #endif
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 7cbcfb0..122e0f5 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4938,7 +4938,7 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 	unsigned long casreg_len;
 	struct net_device *dev;
 	struct cas *cp;
-	int i, err, pci_using_dac;
+	int i, err;
 	u16 pci_cmd;
 	u8 orig_cacheline_size = 0, cas_cacheline_size = 0;
 
@@ -5012,7 +5012,6 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 
 	/* Configure DMA attributes. */
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		pci_using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev,
 						  DMA_BIT_MASK(64));
 		if (err < 0) {
@@ -5028,7 +5027,6 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 			       "aborting\n");
 			goto err_out_free_res;
 		}
-		pci_using_dac = 0;
 	}
 
 	casreg_len = pci_resource_len(pdev, 0);
@@ -5133,8 +5131,7 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 	if ((cp->cas_flags & CAS_FLAG_NO_HW_CSUM) == 0)
 		dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
 
-	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_HIGHDMA;
 
 	if (register_netdev(dev)) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting\n");
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index a54a32b..8193620 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1001,7 +1001,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 {
 	static int version_printed;
 
-	int i, err, pci_using_dac = 0;
+	int i, err;
 	unsigned long mmio_start, mmio_len;
 	const struct board_info *bi;
 	struct adapter *adapter = NULL;
@@ -1025,8 +1025,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 	}
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		pci_using_dac = 1;
-
 		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 			CH_ERR("%s: unable to obtain 64-bit DMA for "
 			       "consistent allocations\n", pci_name(pdev));
@@ -1108,9 +1106,8 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
 		netdev->features |= NETIF_F_LLTX;
 
-		adapter->flags |= RX_CSUM_ENABLED | TCP_CSUM_CAPABLE;
-		if (pci_using_dac)
-			netdev->features |= NETIF_F_HIGHDMA;
+		adapter->flags |= RX_CSUM_ENABLED | TCP_CSUM_CAPABLE |
+				  NETIF_F_HIGHDMA;
 		if (vlan_tso_capable(adapter)) {
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 			adapter->flags |= VLAN_ACCEL_CAPABLE;
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 6fd968a..874c054 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -3132,7 +3132,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 {
 	static int version_printed;
 
-	int i, err, pci_using_dac = 0;
+	int i, err;
 	resource_size_t mmio_start, mmio_len;
 	const struct adapter_info *ai;
 	struct adapter *adapter = NULL;
@@ -3166,7 +3166,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 	}
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		pci_using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err) {
 			dev_err(&pdev->dev, "unable to obtain 64-bit DMA for "
@@ -3243,8 +3242,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->mem_end = mmio_start + mmio_len - 1;
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 		netdev->features |= NETIF_F_GRO;
-		if (pci_using_dac)
-			netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_HIGHDMA;
 
 		netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		netdev->netdev_ops = &cxgb_netdev_ops;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 3b14dd7..0939734 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -809,7 +809,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	static int cards_found = 0;
 	static int global_quad_port_a = 0; /* global ksp3 port a indication */
-	int i, err, pci_using_dac;
+	int i, err;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 	int bars, need_ioport;
@@ -828,7 +828,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
 	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		pci_using_dac = 1;
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
@@ -839,7 +838,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 				goto err_dma;
 			}
 		}
-		pci_using_dac = 0;
 	}
 
 	err = pci_request_selected_regions(pdev, bars, e1000_driver_name);
@@ -914,8 +912,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	   (hw->mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 
-	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |= NETIF_F_HIGHDMA;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_HW_CSUM;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 88d54d3..32a821b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4946,7 +4946,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	resource_size_t flash_start, flash_len;
 
 	static int cards_found;
-	int i, err, pci_using_dac;
+	int i, err;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 
@@ -4956,12 +4956,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (err)
 		return err;
 
-	pci_using_dac = 0;
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!err) {
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
-		if (!err)
-			pci_using_dac = 1;
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
@@ -5091,8 +5088,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_HW_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
-	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |= NETIF_F_HIGHDMA;
 
 	if (e1000e_enable_mng_pass_thru(&adapter->hw))
 		adapter->flags |= FLAG_MNG_PT_ENABLED;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 94749eb..942fa0e 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1887,7 +1887,6 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 {
 	struct net_device *netdev;
 	struct enic *enic;
-	int using_dac = 0;
 	unsigned int i;
 	int err;
 
@@ -1956,7 +1955,6 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 				"for consistent allocations, aborting.\n");
 			goto err_out_release_regions;
 		}
-		using_dac = 1;
 	}
 
 	/* Map vNIC resources from BAR0-5
@@ -2065,8 +2063,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 			NETIF_F_TSO6 | NETIF_F_TSO_ECN;
 	if (ENIC_SETTING(enic, LRO))
 		netdev->features |= NETIF_F_LRO;
-	if (using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |= NETIF_F_HIGHDMA;
 
 	enic->csum_rx_enabled = ENIC_SETTING(enic, RXCSUM);
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 3eb713b..f8a93b0 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5672,6 +5672,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	/* copy of device id */
 	np->device_id = id->device;
 
+	dev->features |= NETIF_F_HIGHDMA;
+
 	/* handle different descriptor versions */
 	if (id->driver_data & DEV_HAS_HIGH_DMA) {
 		/* packet format 3: supports 40-bit addressing */
@@ -5681,8 +5683,6 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 			if (pci_set_dma_mask(pci_dev, DMA_BIT_MASK(39)))
 				dev_printk(KERN_INFO, &pci_dev->dev,
 					"64-bit DMA failed, using 32-bit addressing\n");
-			else
-				dev->features |= NETIF_F_HIGHDMA;
 			if (pci_set_consistent_dma_mask(pci_dev, DMA_BIT_MASK(39))) {
 				dev_printk(KERN_INFO, &pci_dev->dev,
 					"64-bit DMA (consistent) failed, using 32-bit ring buffers\n");
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index f588e49..7471992 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1409,7 +1409,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	static int global_quad_port_a; /* global quad port a indication */
 	const struct e1000_info *ei = igb_info_tbl[ent->driver_data];
 	unsigned long mmio_start, mmio_len;
-	int err, pci_using_dac;
+	int err;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
 
@@ -1417,12 +1417,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (err)
 		return err;
 
-	pci_using_dac = 0;
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!err) {
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
-		if (!err)
-			pci_using_dac = 1;
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
@@ -1532,8 +1529,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
-	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |= NETIF_F_HIGHDMA;
 
 	if (hw->mac.type >= e1000_82576)
 		netdev->features |= NETIF_F_SCTP_CSUM;
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 6029c40..767c285 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2651,18 +2651,15 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	const struct igbvf_info *ei = igbvf_info_tbl[ent->driver_data];
 
 	static int cards_found;
-	int err, pci_using_dac;
+	int err;
 
 	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;
 
-	pci_using_dac = 0;
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!err) {
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
-		if (!err)
-			pci_using_dac = 1;
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
@@ -2746,9 +2743,7 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
-
-	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |= NETIF_F_HIGHDMA;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 0bd5fef..3e49d23 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1236,12 +1236,11 @@ static int __devinit ioc3_probe(struct pci_dev *pdev,
 	struct ioc3 *ioc3;
 	unsigned long ioc3_base, ioc3_size;
 	u32 vendor, model, rev;
-	int err, pci_using_dac;
+	int err;
 
 	/* Configure DMA attributes. */
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!err) {
-		pci_using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err < 0) {
 			printk(KERN_ERR "%s: Unable to obtain 64 bit DMA "
@@ -1255,7 +1254,6 @@ static int __devinit ioc3_probe(struct pci_dev *pdev,
 			       "aborting.\n", pci_name(pdev));
 			goto out;
 		}
-		pci_using_dac = 0;
 	}
 
 	if (pci_enable_device(pdev))
@@ -1267,9 +1265,6 @@ static int __devinit ioc3_probe(struct pci_dev *pdev,
 		goto out_disable;
 	}
 
-	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
-
 	err = pci_request_regions(pdev, "ioc3");
 	if (err)
 		goto out_free;
@@ -1326,7 +1321,7 @@ static int __devinit ioc3_probe(struct pci_dev *pdev,
 	dev->watchdog_timeo	= 5 * HZ;
 	dev->netdev_ops		= &ioc3_netdev_ops;
 	dev->ethtool_ops	= &ioc3_ethtool_ops;
-	dev->features		= NETIF_F_IP_CSUM;
+	dev->features		= NETIF_F_IP_CSUM | NETIF_F_HIGHDMA;
 
 	sw_physid1 = ioc3_mdio_read(dev, ip->mii.phy_id, MII_PHYSID1);
 	sw_physid2 = ioc3_mdio_read(dev, ip->mii.phy_id, MII_PHYSID2);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 93d0185..8777a6b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -360,7 +360,6 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct net_device *netdev = NULL;
 	struct ixgb_adapter *adapter;
 	static int cards_found = 0;
-	int pci_using_dac;
 	int i;
 	int err;
 
@@ -370,7 +369,6 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) &&
 	    !(err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))) {
-		pci_using_dac = 1;
 	} else {
 		if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) ||
 		    (err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))) {
@@ -378,7 +376,6 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			 "ixgb: No usable DMA configuration, aborting\n");
 			goto err_dma_mask;
 		}
-		pci_using_dac = 0;
 	}
 
 	err = pci_request_regions(pdev, ixgb_driver_name);
@@ -440,9 +437,7 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
 	netdev->features |= NETIF_F_TSO;
-
-	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |= NETIF_F_HIGHDMA;
 
 	/* make sure the EEPROM is good */
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 43a8de3..ba8466f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5968,7 +5968,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	struct ixgbe_hw *hw;
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
 	static int cards_found;
-	int i, err, pci_using_dac;
+	int i, err;
 #ifdef IXGBE_FCOE
 	u16 device_caps;
 #endif
@@ -5980,7 +5980,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
 	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		pci_using_dac = 1;
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
@@ -5991,7 +5990,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 				goto err_dma;
 			}
 		}
-		pci_using_dac = 0;
 	}
 
 	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
@@ -6168,8 +6166,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		}
 	}
 #endif /* IXGBE_FCOE */
-	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |= NETIF_F_HIGHDMA;
 
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 		netdev->features |= NETIF_F_LRO;
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 235b5fd..2cc3726 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3306,7 +3306,7 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	struct ixgbe_hw *hw = NULL;
 	const struct ixgbevf_info *ii = ixgbevf_info_tbl[ent->driver_data];
 	static int cards_found;
-	int err, pci_using_dac;
+	int err;
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -3314,7 +3314,6 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) &&
 	    !pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		pci_using_dac = 1;
 	} else {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
@@ -3326,7 +3325,6 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 				goto err_dma;
 			}
 		}
-		pci_using_dac = 0;
 	}
 
 	err = pci_request_regions(pdev, ixgbevf_driver_name);
@@ -3406,9 +3404,7 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_TSO6;
 	netdev->vlan_features |= NETIF_F_IP_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
-
-	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |= NETIF_F_HIGHDMA;
 
 #endif /* MAX_SKB_FRAGS */
 
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 558b6a0..feb2a6b 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -669,7 +669,7 @@ jme_set_clean_rxdesc(struct jme_adapter *jme, int i)
 	rxdesc->desc1.bufaddrl	= cpu_to_le32(
 					(__u64)rxbi->mapping & 0xFFFFFFFFUL);
 	rxdesc->desc1.datalen	= cpu_to_le16(rxbi->len);
-	if (jme->dev->features & NETIF_F_HIGHDMA)
+	if (jme->using_dac)
 		rxdesc->desc1.flags = RXFLAG_64BIT;
 	wmb();
 	rxdesc->desc1.flags	|= RXFLAG_OWN | RXFLAG_INT;
@@ -1743,7 +1743,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 	struct jme_ring *txring = &(jme->txring[0]);
 	struct txdesc *txdesc = txring->desc, *ctxdesc;
 	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi;
-	u8 hidma = jme->dev->features & NETIF_F_HIGHDMA;
+	u8 hidma = jme->using_dac;
 	int i, nr_frags = skb_shinfo(skb)->nr_frags;
 	int mask = jme->tx_ring_mask;
 	struct skb_frag_struct *frag;
@@ -2713,9 +2713,8 @@ jme_init_one(struct pci_dev *pdev,
 						NETIF_F_TSO |
 						NETIF_F_TSO6 |
 						NETIF_F_HW_VLAN_TX |
-						NETIF_F_HW_VLAN_RX;
-	if (using_dac)
-		netdev->features	|=	NETIF_F_HIGHDMA;
+						NETIF_F_HW_VLAN_RX |
+						NETIF_F_HIGHDMA;
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	pci_set_drvdata(pdev, netdev);
@@ -2743,6 +2742,7 @@ jme_init_one(struct pci_dev *pdev,
 		rc = -ENOMEM;
 		goto err_out_free_netdev;
 	}
+	jme->using_dac = using_dac;
 
 	if (no_pseudohp) {
 		apmc = jread32(jme, JME_APMC) & ~JME_APMC_PSEUDO_HP_EN;
diff --git a/drivers/net/jme.h b/drivers/net/jme.h
index c19db91..f7fc9e5 100644
--- a/drivers/net/jme.h
+++ b/drivers/net/jme.h
@@ -387,6 +387,7 @@ struct jme_adapter {
 	struct pci_dev          *pdev;
 	struct net_device       *dev;
 	void __iomem            *regs;
+	u8			using_dac;
 	struct mii_if_info	mii_if;
 	struct jme_ring		rxring[RX_RING_NR];
 	struct jme_ring		txring[TX_RING_NR];
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index c0884a9..82e679c 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3825,7 +3825,6 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct device *dev = &pdev->dev;
 	int i;
 	int status = -ENXIO;
-	int dac_enabled;
 	unsigned hdr_offset, ss_offset;
 	static int board_number;
 
@@ -3867,10 +3866,8 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	pci_set_master(pdev);
-	dac_enabled = 1;
 	status = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (status != 0) {
-		dac_enabled = 0;
 		dev_err(&pdev->dev,
 			"64-bit pci address mask was refused, "
 			"trying 32-bit\n");
@@ -3957,8 +3954,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->base_addr = mgp->iomem_base;
 	netdev->features = mgp->features;
 
-	if (dac_enabled)
-		netdev->features |= NETIF_F_HIGHDMA;
+	netdev->features |= NETIF_F_HIGHDMA;
 	netdev->features |= NETIF_F_LRO;
 
 	netdev->vlan_features |= mgp->features;
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 144d2e8..48cefee 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1170,7 +1170,6 @@ struct netxen_adapter {
 	u8 driver_mismatch;
 	u8 msix_supported;
 	u8 rx_csum;
-	u8 pci_using_dac;
 	u8 portnum;
 	u8 physical_port;
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 08780ef..129d625 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -256,8 +256,6 @@ static int nx_set_dma_mask(struct netxen_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	uint64_t mask, cmask;
 
-	adapter->pci_using_dac = 0;
-
 	mask = DMA_BIT_MASK(32);
 	cmask = DMA_BIT_MASK(32);
 
@@ -272,7 +270,6 @@ static int nx_set_dma_mask(struct netxen_adapter *adapter)
 
 	if (pci_set_dma_mask(pdev, mask) == 0 &&
 		pci_set_consistent_dma_mask(pdev, cmask) == 0) {
-		adapter->pci_using_dac = 1;
 		return 0;
 	}
 
@@ -1207,10 +1204,8 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 		netdev->vlan_features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
 	}
 
-	if (adapter->pci_using_dac) {
-		netdev->features |= NETIF_F_HIGHDMA;
-		netdev->vlan_features |= NETIF_F_HIGHDMA;
-	}
+	netdev->features |= NETIF_F_HIGHDMA;
+	netdev->vlan_features |= NETIF_F_HIGHDMA;
 
 	if (adapter->capabilities & NX_FW_CAPABILITY_FVLANTX)
 		netdev->features |= (NETIF_F_HW_VLAN_TX);
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 5e604e3..15386ed 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -9823,7 +9823,6 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 	dma_mask = DMA_BIT_MASK(44);
 	err = pci_set_dma_mask(pdev, dma_mask);
 	if (!err) {
-		dev->features |= NETIF_F_HIGHDMA;
 		err = pci_set_consistent_dma_mask(pdev, dma_mask);
 		if (err) {
 			dev_err(&pdev->dev, "Unable to obtain 44 bit DMA for consistent allocations, aborting\n");
@@ -9838,7 +9837,7 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 		}
 	}
 
-	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM);
+	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA);
 
 	np->regs = pci_ioremap_bar(pdev, 0);
 	if (!np->regs) {
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 8dd509c..8a85c2d 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -2221,11 +2221,7 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
 	ndev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
 
-	if (using_dac) {
-		printk(KERN_INFO "%s: using 64 bit addressing.\n",
-			ndev->name);
-		ndev->features |= NETIF_F_HIGHDMA;
-	}
+	ndev->features |= NETIF_F_HIGHDMA;
 
 	printk(KERN_INFO "%s: ns83820 v" VERSION ": DP83820 v%u.%u: %pM io=0x%08lx irq=%d f=%s\n",
 		ndev->name,
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 4ef0afb..5c34dc4 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3922,7 +3922,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	struct net_device *ndev = NULL;
 	struct ql3_adapter *qdev = NULL;
 	static int cards_found = 0;
-	int uninitialized_var(pci_using_dac), err;
+	int err;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -3941,10 +3941,8 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		pci_using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	} else if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32)))) {
-		pci_using_dac = 0;
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	}
 
@@ -3977,8 +3975,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	qdev->msg_enable = netif_msg_init(debug, default_msg);
 
-	if (pci_using_dac)
-		ndev->features |= NETIF_F_HIGHDMA;
+	ndev->features |= NETIF_F_HIGHDMA;
 	if (qdev->device_id == QL3032_DEVICE_ID)
 		ndev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 
diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index b40a851..e7b9abd 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -918,7 +918,6 @@ struct qlcnic_adapter {
 	u8 driver_mismatch;
 	u8 msix_supported;
 	u8 rx_csum;
-	u8 pci_using_dac;
 	u8 portnum;
 	u8 physical_port;
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 665e8e5..abced3e 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -239,14 +239,11 @@ static int qlcnic_set_dma_mask(struct qlcnic_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	u64 mask, cmask;
 
-	adapter->pci_using_dac = 0;
-
 	mask = DMA_BIT_MASK(39);
 	cmask = mask;
 
 	if (pci_set_dma_mask(pdev, mask) == 0 &&
 			pci_set_consistent_dma_mask(pdev, cmask) == 0) {
-		adapter->pci_using_dac = 1;
 		return 0;
 	}
 
@@ -1047,10 +1044,8 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	netdev->features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
 	netdev->vlan_features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
 
-	if (adapter->pci_using_dac) {
-		netdev->features |= NETIF_F_HIGHDMA;
-		netdev->vlan_features |= NETIF_F_HIGHDMA;
-	}
+	netdev->features |= NETIF_F_HIGHDMA;
+	netdev->vlan_features |= NETIF_F_HIGHDMA;
 
 	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX)
 		netdev->features |= (NETIF_F_HW_VLAN_TX);
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c170349..5bebf29 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4643,9 +4643,7 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
 			  | NETIF_F_HW_VLAN_TX
 			  | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER);
 	ndev->features |= NETIF_F_GRO;
-
-	if (test_bit(QL_DMA64, &qdev->flags))
-		ndev->features |= NETIF_F_HIGHDMA;
+	ndev->features |= NETIF_F_HIGHDMA;
 
 	/*
 	 * Set up net_device structure.
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 83965ee..60cc3f1 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3052,7 +3052,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		netif_info(tp, probe, dev, "using 64-bit DMA\n");
 		tp->cp_cmd |= PCIDAC;
-		dev->features |= NETIF_F_HIGHDMA;
 	} else {
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc < 0) {
@@ -3061,6 +3060,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
+	dev->features |= NETIF_F_HIGHDMA;
+
 	/* ioremap MMIO region */
 	ioaddr = ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE);
 	if (!ioaddr) {
@@ -4325,9 +4326,9 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 	/* The infamous DAC f*ckup only happens at boot time */
 	if ((tp->cp_cmd & PCIDAC) && !tp->dirty_rx && !tp->cur_rx) {
 		netif_info(tp, intr, dev, "disabling PCI DAC\n");
+		pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
-		dev->features &= ~NETIF_F_HIGHDMA;
 	}
 
 	rtl8169_hw_reset(ioaddr);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 43bc66a..ead7437 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7761,7 +7761,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	struct s2io_nic *sp;
 	struct net_device *dev;
 	int i, j, ret;
-	int dma_flag = false;
 	u32 mac_up, mac_down;
 	u64 val64 = 0, tmp64 = 0;
 	struct XENA_dev_config __iomem *bar0 = NULL;
@@ -7785,7 +7784,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		DBG_PRINT(INIT_DBG, "%s: Using 64bit DMA\n", __func__);
-		dma_flag = true;
 		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
 			DBG_PRINT(ERR_DBG,
 				  "Unable to obtain 64bit DMA "
@@ -7826,7 +7824,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	memset(sp, 0, sizeof(struct s2io_nic));
 	sp->dev = dev;
 	sp->pdev = pdev;
-	sp->high_dma_flag = dma_flag;
 	sp->device_enabled_once = false;
 	if (rx_ring_mode == 1)
 		sp->rxd_mode = RXD_MODE_1;
@@ -7979,8 +7976,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-	if (sp->high_dma_flag == true)
-		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_HIGHDMA;
 	dev->features |= NETIF_F_TSO;
 	dev->features |= NETIF_F_TSO6;
 	if ((sp->device_type & XFRAME_II_DEVICE) && (ufo))  {
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 47c36e0..ae4b8bd 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -883,7 +883,6 @@ struct s2io_nic {
 	struct mac_addr def_mac_addr[256];
 
 	struct net_device_stats stats;
-	int high_dma_flag;
 	int device_enabled_once;
 
 	char name[60];
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index d0058e5..31108a8 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3796,8 +3796,7 @@ static const struct net_device_ops skge_netdev_ops = {
 
 
 /* Initialize network device */
-static struct net_device *skge_devinit(struct skge_hw *hw, int port,
-				       int highmem)
+static struct net_device *skge_devinit(struct skge_hw *hw, int port)
 {
 	struct skge_port *skge;
 	struct net_device *dev = alloc_etherdev(sizeof(*skge));
@@ -3813,8 +3812,7 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	dev->watchdog_timeo = TX_WATCHDOG;
 	dev->irq = hw->pdev->irq;
 
-	if (highmem)
-		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_HIGHDMA;
 
 	skge = netdev_priv(dev);
 	netif_napi_add(dev, &skge->napi, skge_poll, NAPI_WEIGHT);
@@ -3872,7 +3870,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 {
 	struct net_device *dev, *dev1;
 	struct skge_hw *hw;
-	int err, using_dac = 0;
+	int err;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -3889,10 +3887,8 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	} else if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32)))) {
-		using_dac = 0;
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	}
 
@@ -3942,7 +3938,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 		(unsigned long long)pci_resource_start(pdev, 0), pdev->irq,
 		skge_board_name(hw), hw->chip_rev);
 
-	dev = skge_devinit(hw, 0, using_dac);
+	dev = skge_devinit(hw, 0);
 	if (!dev)
 		goto err_out_led_off;
 
@@ -3965,7 +3961,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	skge_show_addr(dev);
 
 	if (hw->ports > 1) {
-		dev1 = skge_devinit(hw, 1, using_dac);
+		dev1 = skge_devinit(hw, 1);
 		if (dev1 && register_netdev(dev1) == 0)
 			skge_show_addr(dev1);
 		else {
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 653bdd7..61ffb70 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4444,7 +4444,7 @@ static const struct net_device_ops sky2_netdev_ops[2] = {
 /* Initialize network device */
 static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 						     unsigned port,
-						     int highmem, int wol)
+						     int wol)
 {
 	struct sky2_port *sky2;
 	struct net_device *dev = alloc_etherdev(sizeof(*sky2));
@@ -4487,9 +4487,8 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 
 	sky2->port = port;
 
-	dev->features |= NETIF_F_TSO | NETIF_F_IP_CSUM | NETIF_F_SG;
-	if (highmem)
-		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_TSO | NETIF_F_IP_CSUM | NETIF_F_SG |
+			 NETIF_F_HIGHDMA;
 
 #ifdef SKY2_VLAN_TAG_USED
 	/* The workaround for FE+ status conflicts with VLAN tag detection. */
@@ -4598,7 +4597,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 {
 	struct net_device *dev;
 	struct sky2_hw *hw;
-	int err, using_dac = 0, wol_default;
+	int err, wol_default;
 	u32 reg;
 	char buf1[16];
 
@@ -4634,7 +4633,6 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 
 	if (sizeof(dma_addr_t) > sizeof(u32) &&
 	    !(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64)))) {
-		using_dac = 1;
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 		if (err < 0) {
 			dev_err(&pdev->dev, "unable to obtain 64 bit DMA "
@@ -4696,7 +4694,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 
 	sky2_reset(hw);
 
-	dev = sky2_init_netdev(hw, 0, using_dac, wol_default);
+	dev = sky2_init_netdev(hw, 0, wol_default);
 	if (!dev) {
 		err = -ENOMEM;
 		goto err_out_free_pci;
@@ -4736,7 +4734,7 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 		struct net_device *dev1;
 
 		err = -ENOMEM;
-		dev1 = sky2_init_netdev(hw, 1, using_dac, wol_default);
+		dev1 = sky2_init_netdev(hw, 1, wol_default);
 		if (dev1 && (err = register_netdev(dev1)) == 0)
 			sky2_show_addr(dev1);
 		else {
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 0f405ef..2fc0810 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -732,9 +732,8 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 #ifdef VLAN_SUPPORT
 	dev->features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
 #endif /* VLAN_RX_KILL_VID */
-#ifdef ADDR_64BITS
+
 	dev->features |= NETIF_F_HIGHDMA;
-#endif /* ADDR_64BITS */
 
 	/* Serial EEPROM reads are hidden by the hardware. */
 	for (i = 0; i < 6; i++)
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4344017..22d0f29 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -3014,7 +3014,7 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	unsigned long gemreg_base, gemreg_len;
 	struct net_device *dev;
 	struct gem *gp;
-	int err, pci_using_dac;
+	int err;
 
 	if (gem_version_printed++ == 0)
 		printk(KERN_INFO "%s", version);
@@ -3042,18 +3042,15 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 	 *
 	 * For now we assume the various PPC GEMs are 32-bit only as well.
 	 */
-	if (pdev->vendor == PCI_VENDOR_ID_SUN &&
-	    pdev->device == PCI_DEVICE_ID_SUN_GEM &&
-	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		pci_using_dac = 1;
-	} else {
+	if (!(pdev->vendor == PCI_VENDOR_ID_SUN &&
+	      pdev->device == PCI_DEVICE_ID_SUN_GEM &&
+	      !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)))) {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
 			printk(KERN_ERR PFX "No usable DMA configuration, "
 			       "aborting.\n");
 			goto err_disable_device;
 		}
-		pci_using_dac = 0;
 	}
 
 	gemreg_base = pci_resource_start(pdev, 0);
@@ -3196,9 +3193,8 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 			gp->phy_mii.def ? gp->phy_mii.def->name : "no");
 
 	/* GEM can do it all... */
-	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX;
-	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX |
+			 NETIF_F_HIGHDMA;
 
 	return 0;
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 2517cc0..60a849f 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1921,7 +1921,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *ndev;
 	struct bdx_priv *priv;
-	int err, pci_using_dac, port;
+	int err, port;
 	unsigned long pciaddr;
 	u32 regionSize;
 	struct pci_nic *nic;
@@ -1939,14 +1939,12 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) &&
 	    !(err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)))) {
-		pci_using_dac = 1;
 	} else {
 		if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) ||
 		    (err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32)))) {
 			pr_err("No usable DMA configuration, aborting\n");
 			goto err_dma;
 		}
-		pci_using_dac = 0;
 	}
 
 	err = pci_request_regions(pdev, BDX_DRV_NAME);
@@ -2026,13 +2024,10 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		ndev->irq = pdev->irq;
 		ndev->features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO
 		    | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-		    NETIF_F_HW_VLAN_FILTER
+		    NETIF_F_HW_VLAN_FILTER | NETIF_F_HIGHDMA
 		    /*| NETIF_F_FRAGLIST */
 		    ;
 
-		if (pci_using_dac)
-			ndev->features |= NETIF_F_HIGHDMA;
-
 	/************** priv ****************/
 		priv = nic->priv[port] = netdev_priv(ndev);
 
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f204f73..2fec544 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -14571,11 +14571,12 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	} else
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(64);
 
+	dev->features |= NETIF_F_HIGHDMA;
+
 	/* Configure DMA attributes. */
 	if (dma_mask > DMA_BIT_MASK(32)) {
 		err = pci_set_dma_mask(pdev, dma_mask);
 		if (!err) {
-			dev->features |= NETIF_F_HIGHDMA;
 			err = pci_set_consistent_dma_mask(pdev,
 							  persist_dma_mask);
 			if (err < 0) {
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 52671ea..45eda33 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1181,11 +1181,13 @@ err_fw:
 	INIT_DELAYED_WORK(&kaweth->lowmem_work, kaweth_resubmit_tl);
 	usb_set_intfdata(intf, kaweth);
 
-#if 0
-// dma_supported() is deeply broken on almost all architectures
-	if (dma_supported (&intf->dev, 0xffffffffffffffffULL))
+	/* Some USB host controllers can't do DMA; they have to use PIO.
+	 * They indicate this by setting their dma_mask to NULL.  For
+	 * such controllers we need to make sure the networking layer doesn't
+	 * send us skbs in high memory.
+	 */
+	if (dev->bus->controller->dma_mask)
 		kaweth->net->features |= NETIF_F_HIGHDMA;
-#endif
 
 	SET_NETDEV_DEV(netdev, &intf->dev);
 	if (register_netdev(netdev) != 0) {
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 17b6a62..220e02f 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1317,12 +1317,14 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	 * bind() should set rx_urb_size in that case.
 	 */
 	dev->hard_mtu = net->mtu + net->hard_header_len;
-#if 0
-// dma_supported() is deeply broken on almost all architectures
-	// possible with some EHCI controllers
-	if (dma_supported (&udev->dev, DMA_BIT_MASK(64)))
+
+	/* Some USB host controllers can't do DMA; they have to use PIO.
+	 * They indicate this by setting their dma_mask to NULL.  For
+	 * such controllers we need to make sure the networking layer doesn't
+	 * send us skbs in high memory.
+	 */
+	if (xdev->bus->controller->dma_mask)
 		net->features |= NETIF_F_HIGHDMA;
-#endif
 
 	net->netdev_ops = &usbnet_netdev_ops;
 	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index ee1b397..099c47f 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1973,7 +1973,7 @@ vmxnet3_set_mac_addr(struct net_device *netdev, void *p)
 /* ==================== initialization and cleanup routines ============ */
 
 static int
-vmxnet3_alloc_pci_resources(struct vmxnet3_adapter *adapter, bool *dma64)
+vmxnet3_alloc_pci_resources(struct vmxnet3_adapter *adapter)
 {
 	int err;
 	unsigned long mmio_start, mmio_len;
@@ -1993,7 +1993,6 @@ vmxnet3_alloc_pci_resources(struct vmxnet3_adapter *adapter, bool *dma64)
 			err = -EIO;
 			goto err_set_mask;
 		}
-		*dma64 = true;
 	} else {
 		if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0) {
 			printk(KERN_ERR "pci_set_dma_mask failed for adapter "
@@ -2001,7 +2000,6 @@ vmxnet3_alloc_pci_resources(struct vmxnet3_adapter *adapter, bool *dma64)
 			err = -EIO;
 			goto err_set_mask;
 		}
-		*dma64 = false;
 	}
 
 	err = pci_request_selected_regions(pdev, (1 << 2) - 1,
@@ -2245,7 +2243,7 @@ out:
 
 
 static void
-vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool dma64)
+vmxnet3_declare_features(struct vmxnet3_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
@@ -2256,19 +2254,15 @@ vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool dma64)
 		NETIF_F_HW_VLAN_FILTER |
 		NETIF_F_TSO |
 		NETIF_F_TSO6 |
-		NETIF_F_LRO;
+		NETIF_F_LRO |
+		NETIF_F_HIGHDMA;
 
-	printk(KERN_INFO "features: sg csum vlan jf tso tsoIPv6 lro");
+	printk(KERN_INFO "features: sg csum vlan jf tso tsoIPv6 lro highDMA");
 
 	adapter->rxcsum = true;
 	adapter->jumbo_frame = true;
 	adapter->lro = true;
 
-	if (dma64) {
-		netdev->features |= NETIF_F_HIGHDMA;
-		printk(" highDMA");
-	}
-
 	netdev->vlan_features = netdev->features;
 	printk("\n");
 }
@@ -2398,7 +2392,6 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 #endif
 	};
 	int err;
-	bool dma64 = false; /* stupid gcc */
 	u32 ver;
 	struct net_device *netdev;
 	struct vmxnet3_adapter *adapter;
@@ -2448,7 +2441,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_alloc_pm;
 	}
 
-	err = vmxnet3_alloc_pci_resources(adapter, &dma64);
+	err = vmxnet3_alloc_pci_resources(adapter);
 	if (err < 0)
 		goto err_alloc_pci;
 
@@ -2472,7 +2465,7 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 		goto err_ver;
 	}
 
-	vmxnet3_declare_features(adapter, dma64);
+	vmxnet3_declare_features(adapter);
 
 	adapter->dev_number = atomic_read(&devices_found);
 	vmxnet3_alloc_intr_resources(adapter);
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index c248b01..44e332f 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3226,7 +3226,7 @@ static const struct net_device_ops vxge_netdev_ops = {
 
 int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 				   struct vxge_config *config,
-				   int high_dma, int no_of_vpath,
+				   int no_of_vpath,
 				   struct vxgedev **vdev_out)
 {
 	struct net_device *ndev;
@@ -3294,11 +3294,7 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
 		"%s : checksuming enabled", __func__);
 
-	if (high_dma) {
-		ndev->features |= NETIF_F_HIGHDMA;
-		vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
-			"%s : using High DMA", __func__);
-	}
+	ndev->features |= NETIF_F_HIGHDMA;
 
 	ndev->features |= NETIF_F_TSO | NETIF_F_TSO6;
 
@@ -4013,7 +4009,6 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 	struct __vxge_hw_device  *hldev;
 	enum vxge_hw_status status;
 	int ret;
-	int high_dma = 0;
 	u64 vpath_mask = 0;
 	struct vxgedev *vdev;
 	struct vxge_config ll_config;
@@ -4091,8 +4086,6 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 		vxge_debug_ll_config(VXGE_TRACE,
 			"%s : using 64bit DMA", __func__);
 
-		high_dma = 1;
-
 		if (pci_set_consistent_dma_mask(pdev,
 						DMA_BIT_MASK(64))) {
 			vxge_debug_init(VXGE_ERR,
@@ -4232,7 +4225,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 	ll_config.tx_pause_enable = VXGE_PAUSE_CTRL_ENABLE;
 	ll_config.rx_pause_enable = VXGE_PAUSE_CTRL_ENABLE;
 
-	if (vxge_device_register(hldev, &ll_config, high_dma, no_of_vpath,
+	if (vxge_device_register(hldev, &ll_config, no_of_vpath,
 		&vdev)) {
 		ret = -EINVAL;
 		goto _exit4;
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 7c83ba4..a9df5dc 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -402,7 +402,7 @@ struct vxge_tx_priv {
 
 int __devinit vxge_device_register(struct __vxge_hw_device *devh,
 				    struct vxge_config *config,
-				    int high_dma, int no_of_vpath,
+				    int no_of_vpath,
 				    struct vxgedev **vdev);
 
 void vxge_device_unregister(struct __vxge_hw_device *devh);
