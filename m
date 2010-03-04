From: Robert Hancock <hancockrwd@gmail.com>
Subject: [PATCH RFC] fix problems with NETIF_F_HIGHDMA in networking drivers
 v2
Date: Wed, 03 Mar 2010 20:55:55 -0600
Message-ID: <4B8F213B.40603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
To: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linux-usb <linux-usb@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many networking drivers have issues with the use of the NETIF_F_HIGHDMA flag.
This flag actually indicates whether or not the device/driver can handle
skbs located in high memory (as opposed to lowmem). If the flag isn't set and
the skb is located in highmem, it needs to be copied. 
There are two problems with this flag:

-Many drivers only set the flag when they detect they can use 64-bit DMA,
since otherwise they could receive DMA addresses that they can't handle
(which on platforms without IOMMU/SWIOTLB support is fatal). This means that if
64-bit support isn't available, even buffers located below 4GB will get copied
unnecessarily.

-Some drivers set the flag even though they can't actually handle 64-bit DMA,
which would mean that on platforms without IOMMU/SWIOTLB they would get a DMA
mapping error if the memory they received happened to be located above 4GB.

In order to fix this problem, the existing NETIF_F_HIGHDMA flag is split into
two new flags:

NETIF_F_DMA_HIGH - indicates if the driver can do DMA to highmem at all
NETIF_F_DMA_64BIT - indicates the driver can do DMA to 64-bit memory

The check for NETIF_F_DMA_HIGH in the networking core is similar to the current
one for NETIF_F_HIGHDMA. The check for NETIF_F_DMA_64BIT is similar to the
block layer code that handles bounce limit checking.

The patch updates drivers that set NETIF_F_HIGHDMA to set NETIF_F_DMA_HIGH,
and also in some cases NETIF_F_DMA_64BIT where it appears the driver can
actually handle 64-bit DMA addresses.

For the USB kaweth and usbnet drivers, this patch also uncomments and corrects
some code to set the flags based on the USB host controller's DMA mask.
These drivers should be able to access highmem unless the host controller is
non-DMA-capable, which is indicated by the DMA mask being null. If the DMA mask
is additionally 64-bit, then the NETIF_F_DMA_64BIT flag is also set.

Signed-off-by: Robert Hancock <hancockrwd@gmail.com>

---

I suppose the API update and the driver update should likely be separate,
but this is mainly for comments on the new approach..

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 2d3dc7d..8404f7b 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -1382,7 +1382,7 @@ static void fwnet_init_dev(struct net_device *net)
 	net->netdev_ops		= &fwnet_netdev_ops;
 	net->watchdog_timeo	= 2 * HZ;
 	net->flags		= IFF_BROADCAST | IFF_MULTICAST;
-	net->features		= NETIF_F_HIGHDMA;
+	net->features		= NETIF_F_DMA_HIGH;
 	net->addr_len		= FWNET_ALEN;
 	net->hard_header_len	= FWNET_HLEN;
 	net->type		= ARPHRD_IEEE1394;
diff --git a/drivers/ieee1394/eth1394.c b/drivers/ieee1394/eth1394.c
index a4e9dcb..4588f70 100644
--- a/drivers/ieee1394/eth1394.c
+++ b/drivers/ieee1394/eth1394.c
@@ -529,7 +529,7 @@ static void ether1394_init_dev(struct net_device *dev)
 
 	dev->watchdog_timeo	= ETHER1394_TIMEOUT;
 	dev->flags		= IFF_BROADCAST | IFF_MULTICAST;
-	dev->features		= NETIF_F_HIGHDMA;
+	dev->features		= NETIF_F_DMA_HIGH;
 	dev->addr_len		= ETH1394_ALEN;
 	dev->hard_header_len 	= ETH1394_HLEN;
 	dev->type		= ARPHRD_IEEE1394;
diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 9384f5d..7fadc25 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1616,7 +1616,7 @@ struct net_device *nes_netdev_init(struct nes_device *nesdev,
 	netdev->hard_header_len = ETH_HLEN;
 	netdev->addr_len = ETH_ALEN;
 	netdev->type = ARPHRD_ETHER;
-	netdev->features = NETIF_F_HIGHDMA;
+	netdev->features = NETIF_F_DMA_HIGH;
 	netdev->netdev_ops = &nes_netdev_ops;
 	netdev->ethtool_ops = &nes_ethtool_ops;
 	netif_napi_add(netdev, &nesvnic->napi, nes_netdev_poll, 128);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index df3eb8c..53be462 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1058,7 +1058,7 @@ static void ipoib_setup(struct net_device *dev)
 	dev->type		 = ARPHRD_INFINIBAND;
 	dev->tx_queue_len	 = ipoib_sendq_size * 2;
 	dev->features		 = (NETIF_F_VLAN_CHALLENGED	|
-				    NETIF_F_HIGHDMA);
+				    NETIF_F_DMA_HIGH);
 	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 
 	memcpy(dev->broadcast, ipv4_bcast_addr, INFINIBAND_ALEN);
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index 3d4406b..d41aad4 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1967,8 +1967,9 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
 
+	dev->features |= NETIF_F_DMA_HIGH;
 	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 
 #if 0 /* disabled by default until verified */
 	dev->features |= NETIF_F_TSO;
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index b4efc91..f03d25d 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -989,7 +989,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
 	 * through the use of skb_copy_and_csum_dev we enable these
 	 * features
 	 */
-	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_DMA_HIGH;
 
 	dev->irq = pdev->irq;
 
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 4ae750e..4422f8f 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -607,8 +607,9 @@ static int __devinit acenic_probe_one(struct pci_dev *pdev,
 	}
 	ap->name = dev->name;
 
+	dev->features |= NETIF_F_DMA_HIGH;
 	if (ap->pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 
 	pci_set_drvdata(pdev, dev);
 
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a703ed8..1fb839d 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2335,9 +2335,10 @@ static int __devinit be_probe(struct pci_dev *pdev,
 
 	be_msix_enable(adapter);
 
+	netdev->features |= NETIF_F_DMA_HIGH;
 	status = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (!status) {
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 	} else {
 		status = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (status) {
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 381887b..cd44e75 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7935,8 +7935,9 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(64);
 
 	/* Configure DMA attributes. */
+	dev->features |= NETIF_F_DMA_HIGH;
 	if (pci_set_dma_mask(pdev, dma_mask) == 0) {
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 		rc = pci_set_consistent_dma_mask(pdev, persist_dma_mask);
 		if (rc) {
 			dev_err(&pdev->dev,
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index ed785a3..85e9264 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -11880,8 +11880,9 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	dev->ethtool_ops = &bnx2x_ethtool_ops;
 	dev->features |= NETIF_F_SG;
 	dev->features |= NETIF_F_HW_CSUM;
+	dev->features |= NETIF_F_DMA_HIGH;
 	if (bp->flags & USING_DAC_FLAG)
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 	dev->features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
 	dev->features |= NETIF_F_TSO6;
 #ifdef BCM_VLAN
@@ -11890,8 +11891,9 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 
 	dev->vlan_features |= NETIF_F_SG;
 	dev->vlan_features |= NETIF_F_HW_CSUM;
+	dev->vlan_features |= NETIF_F_DMA_HIGH;
 	if (bp->flags & USING_DAC_FLAG)
-		dev->vlan_features |= NETIF_F_HIGHDMA;
+		dev->vlan_features |= NETIF_F_DMA_64BIT;
 	dev->vlan_features |= (NETIF_F_TSO | NETIF_F_TSO_ECN);
 	dev->vlan_features |= NETIF_F_TSO6;
 #endif
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 7cbcfb0..b96ff3a 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -5133,8 +5133,9 @@ static int __devinit cas_init_one(struct pci_dev *pdev,
 	if ((cp->cas_flags & CAS_FLAG_NO_HW_CSUM) == 0)
 		dev->features |= NETIF_F_HW_CSUM | NETIF_F_SG;
 
+	dev->features |= NETIF_F_DMA_HIGH;
 	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 
 	if (register_netdev(dev)) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting\n");
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 0f71304..9d027db 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -1106,11 +1106,11 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->mem_end = mmio_start + mmio_len - 1;
 		netdev->ml_priv = adapter;
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
-		netdev->features |= NETIF_F_LLTX;
+		netdev->features |= NETIF_F_LLTX | NETIF_F_DMA_HIGH;
 
 		adapter->flags |= RX_CSUM_ENABLED | TCP_CSUM_CAPABLE;
 		if (pci_using_dac)
-			netdev->features |= NETIF_F_HIGHDMA;
+			netdev->features |= NETIF_F_DMA_64BIT;
 		if (vlan_tso_capable(adapter)) {
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 			adapter->flags |= VLAN_ACCEL_CAPABLE;
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 6fd968a..2133728 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -3242,9 +3242,9 @@ static int __devinit init_one(struct pci_dev *pdev,
 		netdev->mem_start = mmio_start;
 		netdev->mem_end = mmio_start + mmio_len - 1;
 		netdev->features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
-		netdev->features |= NETIF_F_GRO;
+		netdev->features |= NETIF_F_GRO | NETIF_F_DMA_HIGH;
 		if (pci_using_dac)
-			netdev->features |= NETIF_F_HIGHDMA;
+			netdev->features |= NETIF_F_DMA_64BIT;
 
 		netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		netdev->netdev_ops = &cxgb_netdev_ops;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8be6fae..6650583 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -914,8 +914,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	   (hw->mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 
+	netdev->features |= NETIF_F_DMA_HIGH;
 	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_HW_CSUM;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 88d54d3..2b1bdea 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5085,6 +5085,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
+	netdev->features |= NETIF_F_DMA_HIGH;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
@@ -5092,7 +5093,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_SG;
 
 	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 
 	if (e1000e_enable_mng_pass_thru(&adapter->hw))
 		adapter->flags |= FLAG_MNG_PT_ENABLED;
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index b004eab..fd395bc 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -3149,7 +3149,7 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	ehea_set_ethtool_ops(dev);
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
-		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
+		      | NETIF_F_DMA_HIGH | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
 		      | NETIF_F_LLTX;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index cf098bb..52c6807 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -2067,8 +2067,9 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 			NETIF_F_TSO6 | NETIF_F_TSO_ECN;
 	if (ENIC_SETTING(enic, LRO))
 		netdev->features |= NETIF_F_LRO;
+	netdev->features |= NETIF_F_DMA_HIGH;
 	if (using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 
 	enic->csum_rx_enabled = ENIC_SETTING(enic, RXCSUM);
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index ca05e56..0d9d40b 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5670,6 +5670,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	/* copy of device id */
 	np->device_id = id->device;
 
+	dev->features |= NETIF_F_DMA_HIGH;
 	/* handle different descriptor versions */
 	if (id->driver_data & DEV_HAS_HIGH_DMA) {
 		/* packet format 3: supports 40-bit addressing */
@@ -5680,7 +5681,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 				dev_printk(KERN_INFO, &pci_dev->dev,
 					"64-bit DMA failed, using 32-bit addressing\n");
 			else
-				dev->features |= NETIF_F_HIGHDMA;
+				dev->features |= NETIF_F_DMA_64BIT;
 			if (pci_set_consistent_dma_mask(pci_dev, DMA_BIT_MASK(39))) {
 				dev_printk(KERN_INFO, &pci_dev->dev,
 					"64-bit DMA (consistent) failed, using 32-bit ring buffers\n");
@@ -6014,7 +6015,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		   dev->dev_addr[5]);
 
 	dev_printk(KERN_INFO, &pci_dev->dev, "%s%s%s%s%s%s%s%s%s%sdesc-v%u\n",
-		   dev->features & NETIF_F_HIGHDMA ? "highdma " : "",
+		   dev->features & NETIF_F_DMA_64BIT ? "highdma " : "",
 		   dev->features & (NETIF_F_IP_CSUM | NETIF_F_SG) ?
 		   	"csum " : "",
 		   dev->features & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX) ?
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 6aa526e..63927c6 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -933,7 +933,8 @@ static int gfar_probe(struct of_device *ofdev,
 
 	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_CSUM) {
 		priv->rx_csum_enable = 1;
-		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG |
+				 NETIF_F_DMA_HIGH;
 	} else
 		priv->rx_csum_enable = 0;
 
diff --git a/drivers/net/greth.c b/drivers/net/greth.c
index 2b9c1cb..8679410 100644
--- a/drivers/net/greth.c
+++ b/drivers/net/greth.c
@@ -1531,7 +1531,7 @@ static int __devinit greth_of_probe(struct of_device *ofdev, const struct of_dev
 	GRETH_REGSAVE(regs->status, 0xFF);
 
 	if (greth->gbit_mac) {
-		dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_HIGHDMA;
+		dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_DMA_HIGH;
 		greth_netdev_ops.ndo_start_xmit = greth_start_xmit_gbit;
 		greth->flags = GRETH_FLAG_RX_CSUM;
 	}
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 583a21c..23849ed 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1525,6 +1525,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
 	netdev->features |= NETIF_F_GRO;
+	netdev->features |= NETIF_F_DMA_HIGH;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
@@ -1533,7 +1534,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_SG;
 
 	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 
 	if (hw->mac.type >= e1000_82576)
 		netdev->features |= NETIF_F_SCTP_CSUM;
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index a77afd8..bdcb9de 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2740,9 +2740,10 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
+	netdev->features |= NETIF_F_DMA_HIGH;
 
 	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 70871b9..7b3dad4 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1267,8 +1267,9 @@ static int __devinit ioc3_probe(struct pci_dev *pdev,
 		goto out_disable;
 	}
 
+	dev->features |= NETIF_F_DMA_HIGH;
 	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 
 	err = pci_request_regions(pdev, "ioc3");
 	if (err)
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index c9fef65..6e50c2b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -439,10 +439,10 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   NETIF_F_HW_VLAN_TX |
 			   NETIF_F_HW_VLAN_RX |
 			   NETIF_F_HW_VLAN_FILTER;
-	netdev->features |= NETIF_F_TSO;
+	netdev->features |= NETIF_F_TSO | NETIF_F_DMA_HIGH;
 
 	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 
 	/* make sure the EEPROM is good */
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 45e3532..8876b67 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6179,6 +6179,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
 	netdev->features |= NETIF_F_GRO;
+	netdev->features |= NETIF_F_DMA_HIGH;
 
 	if (adapter->hw.mac.type == ixgbe_mac_82599EB)
 		netdev->features |= NETIF_F_SCTP_CSUM;
@@ -6209,7 +6210,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 #endif /* IXGBE_FCOE */
 	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 		netdev->features |= NETIF_F_LRO;
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 235b5fd..f3986dc 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -3402,13 +3402,14 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
+	netdev->features |= NETIF_F_DMA_HIGH;
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
 	netdev->vlan_features |= NETIF_F_IP_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
 	if (pci_using_dac)
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 
 #endif /* MAX_SKB_FRAGS */
 
diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 0f31497..1b0fcff 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -669,7 +669,7 @@ jme_set_clean_rxdesc(struct jme_adapter *jme, int i)
 	rxdesc->desc1.bufaddrl	= cpu_to_le32(
 					(__u64)rxbi->mapping & 0xFFFFFFFFUL);
 	rxdesc->desc1.datalen	= cpu_to_le16(rxbi->len);
-	if (jme->dev->features & NETIF_F_HIGHDMA)
+	if (jme->dev->features & NETIF_F_DMA_64BIT)
 		rxdesc->desc1.flags = RXFLAG_64BIT;
 	wmb();
 	rxdesc->desc1.flags	|= RXFLAG_OWN | RXFLAG_INT;
@@ -1743,7 +1743,7 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 	struct jme_ring *txring = &(jme->txring[0]);
 	struct txdesc *txdesc = txring->desc, *ctxdesc;
 	struct jme_buffer_info *txbi = txring->bufinf, *ctxbi;
-	u8 hidma = jme->dev->features & NETIF_F_HIGHDMA;
+	u8 hidma = jme->dev->features & NETIF_F_DMA_64BIT;
 	int i, nr_frags = skb_shinfo(skb)->nr_frags;
 	int mask = jme->tx_ring_mask;
 	struct skb_frag_struct *frag;
@@ -2709,9 +2709,10 @@ jme_init_one(struct pci_dev *pdev,
 						NETIF_F_TSO |
 						NETIF_F_TSO6 |
 						NETIF_F_HW_VLAN_TX |
-						NETIF_F_HW_VLAN_RX;
+						NETIF_F_HW_VLAN_RX |
+						NETIF_F_DMA_HIGH;
 	if (using_dac)
-		netdev->features	|=	NETIF_F_HIGHDMA;
+		netdev->features	|=	NETIF_F_DMA_64BIT;
 
 	SET_NETDEV_DEV(netdev, &pdev->dev);
 	pci_set_drvdata(pdev, netdev);
diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 72b7949..7881064 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -177,7 +177,8 @@ static void loopback_setup(struct net_device *dev)
 	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
 		| NETIF_F_TSO
 		| NETIF_F_NO_CSUM
-		| NETIF_F_HIGHDMA
+		| NETIF_F_DMA_HIGH
+		| NETIF_F_DMA_64BIT
 		| NETIF_F_LLTX
 		| NETIF_F_NETNS_LOCAL;
 	dev->ethtool_ops	= &loopback_ethtool_ops;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 40faa36..5e8abb0 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -378,7 +378,7 @@ static struct lock_class_key macvlan_netdev_xmit_lock_key;
 static struct lock_class_key macvlan_netdev_addr_lock_key;
 
 #define MACVLAN_FEATURES \
-	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST | \
+	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_DMA_HIGH | NETIF_F_FRAGLIST | \
 	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
 	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO)
 
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index c48b0f4..5288ac0 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -1041,7 +1041,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	dev->vlan_features |= NETIF_F_SG;
 	dev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
 	dev->vlan_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-	dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_DMA_HIGH;
 	dev->features |= NETIF_F_HW_VLAN_TX |
 			 NETIF_F_HW_VLAN_RX |
 			 NETIF_F_HW_VLAN_FILTER;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 676c513..8760667 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3913,8 +3913,9 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->base_addr = mgp->iomem_base;
 	netdev->features = mgp->features;
 
+	netdev->features |= NETIF_F_DMA_HIGH;
 	if (dac_enabled)
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 	netdev->features |= NETIF_F_LRO;
 
 	netdev->vlan_features |= mgp->features;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 08780ef..6847f7b 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1198,9 +1198,11 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 
 	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
 
-	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
+	netdev->features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+			     NETIF_F_DMA_HIGH);
 	netdev->features |= (NETIF_F_GRO);
-	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
+	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+				  NETIF_F_DMA_HIGH);
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
 		netdev->features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
@@ -1208,8 +1210,8 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 	}
 
 	if (adapter->pci_using_dac) {
-		netdev->features |= NETIF_F_HIGHDMA;
-		netdev->vlan_features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
+		netdev->vlan_features |= NETIF_F_DMA_64BIT;
 	}
 
 	if (adapter->capabilities & NX_FW_CAPABILITY_FVLANTX)
diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 0678f31..044a3bd 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -9823,7 +9823,7 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 	dma_mask = DMA_BIT_MASK(44);
 	err = pci_set_dma_mask(pdev, dma_mask);
 	if (!err) {
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 		err = pci_set_consistent_dma_mask(pdev, dma_mask);
 		if (err) {
 			dev_err(&pdev->dev, "Unable to obtain 44 bit DMA for consistent allocations, aborting\n");
@@ -9838,7 +9838,7 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 		}
 	}
 
-	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM);
+	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_DMA_HIGH);
 
 	np->regs = pci_ioremap_bar(pdev, 0);
 	if (!np->regs) {
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 8dd509c..0b61710 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -2215,6 +2215,7 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
 	/* Yes, we support dumb IP checksum on transmit */
 	ndev->features |= NETIF_F_SG;
 	ndev->features |= NETIF_F_IP_CSUM;
+	ndev->features |= NETIF_F_DMA_HIGH;
 
 #ifdef NS83820_VLAN_ACCEL_SUPPORT
 	/* We also support hardware vlan acceleration */
@@ -2224,7 +2225,7 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
 	if (using_dac) {
 		printk(KERN_INFO "%s: using 64 bit addressing.\n",
 			ndev->name);
-		ndev->features |= NETIF_F_HIGHDMA;
+		ndev->features |= NETIF_F_DMA_64BIT;
 	}
 
 	printk(KERN_INFO "%s: ns83820 v" VERSION ": DP83820 v%u.%u: %pM io=0x%08lx irq=%d f=%s\n",
@@ -2232,7 +2233,7 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev,
 		(unsigned)readl(dev->base + SRR) >> 8,
 		(unsigned)readl(dev->base + SRR) & 0xff,
 		ndev->dev_addr, addr, pci_dev->irq,
-		(ndev->features & NETIF_F_HIGHDMA) ? "h,sg" : "sg"
+		(ndev->features & NETIF_F_DMA_64BIT) ? "h,sg" : "sg"
 		);
 
 #ifdef PHY_CODE_IS_FINISHED
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index d44d4a2..0f4ab9d 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1758,7 +1758,7 @@ pasemi_mac_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netif_napi_add(dev, &mac->napi, pasemi_mac_poll, 64);
 
 	dev->features = NETIF_F_IP_CSUM | NETIF_F_LLTX | NETIF_F_SG |
-			NETIF_F_HIGHDMA | NETIF_F_GSO;
+			NETIF_F_DMA_HIGH | NETIF_F_GSO;
 
 	mac->lro_mgr.max_aggr = LRO_MAX_AGGR;
 	mac->lro_mgr.max_desc = MAX_LRO_DESCRIPTORS;
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 4ef0afb..80df9fe 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3977,8 +3977,9 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	qdev->msg_enable = netif_msg_init(debug, default_msg);
 
+	ndev->features |= NETIF_F_DMA_HIGH;
 	if (pci_using_dac)
-		ndev->features |= NETIF_F_HIGHDMA;
+		ndev->features |= NETIF_F_DMA_64BIT;
 	if (qdev->device_id == QL3032_DEVICE_ID)
 		ndev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 665e8e5..6a3fa85 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1044,12 +1044,14 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter,
 	netdev->features |= (NETIF_F_GRO);
 	netdev->vlan_features |= (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
 
-	netdev->features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
-	netdev->vlan_features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
+	netdev->features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6 |
+			     NETIF_F_DMA_HIGH);
+	netdev->vlan_features |= (NETIF_F_IPV6_CSUM | NETIF_F_TSO6 |
+				  NETIF_F_DMA_HIGH);
 
 	if (adapter->pci_using_dac) {
-		netdev->features |= NETIF_F_HIGHDMA;
-		netdev->vlan_features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
+		netdev->vlan_features |= NETIF_F_DMA_64BIT;
 	}
 
 	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX)
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c26ec5d..a5defb8 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4644,10 +4644,10 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
 			  | NETIF_F_TSO_ECN
 			  | NETIF_F_HW_VLAN_TX
 			  | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER);
-	ndev->features |= NETIF_F_GRO;
+	ndev->features |= NETIF_F_GRO | NETIF_F_DMA_HIGH;
 
 	if (test_bit(QL_DMA64, &qdev->flags))
-		ndev->features |= NETIF_F_HIGHDMA;
+		ndev->features |= NETIF_F_DMA_64BIT;
 
 	/*
 	 * Set up net_device structure.
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dfc3573..ddfda5e 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3047,12 +3047,13 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (this_use_dac < 0)
 		this_use_dac = tp->pcie_cap != 0;
 
+	dev->features |= NETIF_F_DMA_HIGH;
 	if ((sizeof(dma_addr_t) > 4) &&
 	    this_use_dac &&
 	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
 		netif_info(tp, probe, dev, "using 64-bit DMA\n");
 		tp->cp_cmd |= PCIDAC;
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 	} else {
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc < 0) {
@@ -4327,7 +4328,7 @@ static void rtl8169_pcierr_interrupt(struct net_device *dev)
 		netif_info(tp, intr, dev, "disabling PCI DAC\n");
 		tp->cp_cmd &= ~PCIDAC;
 		RTL_W16(CPlusCmd, tp->cp_cmd);
-		dev->features &= ~NETIF_F_HIGHDMA;
+		dev->features &= ~NETIF_F_DMA_64BIT;
 	}
 
 	rtl8169_hw_reset(ioaddr);
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 43bc66a..d4b4724 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -7978,9 +7978,9 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 
-	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_DMA_HIGH;
 	if (sp->high_dma_flag == true)
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 	dev->features |= NETIF_F_TSO;
 	dev->features |= NETIF_F_TSO6;
 	if ((sp->device_type & XFRAME_II_DEVICE) && (ufo))  {
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
index d87c478..333b327 100644
--- a/drivers/net/sc92031.c
+++ b/drivers/net/sc92031.c
@@ -1462,7 +1462,7 @@ static int __devinit sc92031_probe(struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 
 	/* faked with skb_copy_and_csum_dev */
-	dev->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA;
+	dev->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_DMA_HIGH;
 
 	dev->netdev_ops		= &sc92031_netdev_ops;
 	dev->watchdog_timeo	= TX_TIMEOUT;
diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 88f2fb1..6aa4387 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2204,13 +2204,13 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	if (!net_dev)
 		return -ENOMEM;
 	net_dev->features |= (type->offload_features | NETIF_F_SG |
-			      NETIF_F_HIGHDMA | NETIF_F_TSO |
+			      NETIF_F_DMA_HIGH | NETIF_F_TSO |
 			      NETIF_F_GRO);
 	if (type->offload_features & NETIF_F_V6_CSUM)
 		net_dev->features |= NETIF_F_TSO6;
 	/* Mask for features that also apply to VLAN devices */
 	net_dev->vlan_features |= (NETIF_F_ALL_CSUM | NETIF_F_SG |
-				   NETIF_F_HIGHDMA | NETIF_F_TSO);
+				   NETIF_F_DMA_HIGH | NETIF_F_TSO);
 	efx = netdev_priv(net_dev);
 	pci_set_drvdata(pci_dev, efx);
 	rc = efx_init_struct(efx, type, pci_dev, net_dev);
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index d0058e5..ee183f4 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3813,8 +3813,9 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	dev->watchdog_timeo = TX_WATCHDOG;
 	dev->irq = hw->pdev->irq;
 
+	dev->features |= NETIF_F_DMA_HIGH;
 	if (highmem)
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 
 	skge = netdev_priv(dev);
 	netif_napi_add(dev, &skge->napi, skge_poll, NAPI_WEIGHT);
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 653bdd7..2e2df37 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4487,9 +4487,10 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 
 	sky2->port = port;
 
-	dev->features |= NETIF_F_TSO | NETIF_F_IP_CSUM | NETIF_F_SG;
+	dev->features |= NETIF_F_TSO | NETIF_F_IP_CSUM | NETIF_F_SG |
+			 NETIF_F_DMA_HIGH;
 	if (highmem)
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 
 #ifdef SKY2_VLAN_TAG_USED
 	/* The workaround for FE+ status conflicts with VLAN tag detection. */
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index 6dfa698..6f2a47c 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -732,8 +732,12 @@ static int __devinit starfire_init_one(struct pci_dev *pdev,
 #ifdef VLAN_SUPPORT
 	dev->features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
 #endif /* VLAN_RX_KILL_VID */
+
+	dev->features |= NETIF_F_DMA_HIGH;
+
 #ifdef ADDR_64BITS
-	dev->features |= NETIF_F_HIGHDMA;
+	/* FIXME: should be setting 64-bit DMA mask here */
+	dev->features |= NETIF_F_DMA_64BIT;
 #endif /* ADDR_64BITS */
 
 	/* Serial EEPROM reads are hidden by the hardware. */
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index a673361..a6a78b8 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1529,7 +1529,7 @@ static int stmmac_probe(struct net_device *dev)
 	dev->netdev_ops = &stmmac_netdev_ops;
 	stmmac_set_ethtool_ops(dev);
 
-	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_HIGHDMA);
+	dev->features |= (NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_DMA_HIGH);
 	dev->watchdog_timeo = msecs_to_jiffies(watchdog);
 #ifdef STMMAC_VLAN_TAG_USED
 	/* Both mac100 and gmac support receive VLAN tag detection */
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4344017..bf05253 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -3196,9 +3196,10 @@ static int __devinit gem_init_one(struct pci_dev *pdev,
 			gp->phy_mii.def ? gp->phy_mii.def->name : "no");
 
 	/* GEM can do it all... */
-	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_LLTX |
+			 NETIF_F_DMA_HIGH;
 	if (pci_using_dac)
-		dev->features |= NETIF_F_HIGHDMA;
+		dev->features |= NETIF_F_DMA_64BIT;
 
 	return 0;
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 0c97802..908e272 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -2024,12 +2024,12 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		ndev->irq = pdev->irq;
 		ndev->features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_TSO
 		    | NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-		    NETIF_F_HW_VLAN_FILTER
+		    NETIF_F_HW_VLAN_FILTER | NETIF_F_DMA_HIGH
 		    /*| NETIF_F_FRAGLIST */
 		    ;
 
 		if (pci_using_dac)
-			ndev->features |= NETIF_F_HIGHDMA;
+			ndev->features |= NETIF_F_DMA_64BIT;
 
 	/************** priv ****************/
 		priv = nic->priv[port] = netdev_priv(ndev);
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0fa7688..676111f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -14552,10 +14552,11 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(64);
 
 	/* Configure DMA attributes. */
+	dev->features |= NETIF_F_DMA_HIGH;
 	if (dma_mask > DMA_BIT_MASK(32)) {
 		err = pci_set_dma_mask(pdev, dma_mask);
 		if (!err) {
-			dev->features |= NETIF_F_HIGHDMA;
+			dev->features |= NETIF_F_DMA_64BIT;
 			err = pci_set_consistent_dma_mask(pdev,
 							  persist_dma_mask);
 			if (err < 0) {
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 647cdd1..db8d13f 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1628,7 +1628,7 @@ tsi108_init_one(struct platform_device *pdev)
 	 * a new function skb_csum_dev() in net/core/skbuff.c).
 	 */
 
-	dev->features = NETIF_F_HIGHDMA;
+	dev->features = NETIF_F_DMA_HIGH;
 
 	spin_lock_init(&data->txlock);
 	spin_lock_init(&data->misclock);
diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 52671ea..ad06569 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -1181,11 +1181,17 @@ err_fw:
 	INIT_DELAYED_WORK(&kaweth->lowmem_work, kaweth_resubmit_tl);
 	usb_set_intfdata(intf, kaweth);
 
-#if 0
-// dma_supported() is deeply broken on almost all architectures
-	if (dma_supported (&intf->dev, 0xffffffffffffffffULL))
-		kaweth->net->features |= NETIF_F_HIGHDMA;
-#endif
+	/* Some USB host controllers can't do DMA; they have to use PIO.
+	 * They indicate this by setting their dma_mask to NULL.  For
+	 * such controllers we need to make sure the networking layer doesn't
+	 * send us skbs in high memory.
+	 */
+	if (dev->bus->controller->dma_mask) {
+		kaweth->net->features |= NETIF_F_DMA_HIGH;
+		/* OK, using DMA, can it do 64 bit? */
+		if (*dev->bus->controller->dma_mask == DMA_BIT_MASK(64))
+			kaweth->net->features |= NETIF_F_DMA_64BIT;
+	}
 
 	SET_NETDEV_DEV(netdev, &intf->dev);
 	if (register_netdev(netdev) != 0) {
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 17b6a62..13e4b14 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1317,12 +1317,18 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	 * bind() should set rx_urb_size in that case.
 	 */
 	dev->hard_mtu = net->mtu + net->hard_header_len;
-#if 0
-// dma_supported() is deeply broken on almost all architectures
-	// possible with some EHCI controllers
-	if (dma_supported (&udev->dev, DMA_BIT_MASK(64)))
-		net->features |= NETIF_F_HIGHDMA;
-#endif
+
+	/* Some USB host controllers can't do DMA; they have to use PIO.
+	 * They indicate this by setting their dma_mask to NULL.  For
+	 * such controllers we need to make sure the networking layer doesn't
+	 * send us skbs in high memory.
+	 */
+	if (xdev->bus->controller->dma_mask) {
+		net->features |= NETIF_F_DMA_HIGH;
+		/* OK, using DMA, can it do 64 bit? */
+		if (*xdev->bus->controller->dma_mask == DMA_BIT_MASK(64))
+			net->features |= NETIF_F_DMA_64BIT;
+	}
 
 	net->netdev_ops = &usbnet_netdev_ops;
 	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 25dc77c..7f22900 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -900,7 +900,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 
 	/* Set up network device as normal. */
 	dev->netdev_ops = &virtnet_netdev;
-	dev->features = NETIF_F_HIGHDMA;
+	dev->features = NETIF_F_DMA_HIGH;
 	SET_ETHTOOL_OPS(dev, &virtnet_ethtool_ops);
 	SET_NETDEV_DEV(dev, &vdev->dev);
 
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index cff3485..ed438af 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2253,7 +2253,8 @@ vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool dma64)
 		NETIF_F_HW_VLAN_FILTER |
 		NETIF_F_TSO |
 		NETIF_F_TSO6 |
-		NETIF_F_LRO;
+		NETIF_F_LRO |
+		NETIF_F_DMA_HIGH;
 
 	printk(KERN_INFO "features: sg csum vlan jf tso tsoIPv6 lro");
 
@@ -2262,7 +2263,7 @@ vmxnet3_declare_features(struct vmxnet3_adapter *adapter, bool dma64)
 	adapter->lro = true;
 
 	if (dma64) {
-		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->features |= NETIF_F_DMA_64BIT;
 		printk(" highDMA");
 	}
 
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 46a7c9e..184886b 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -3292,8 +3292,9 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
 		"%s : checksuming enabled", __func__);
 
+	ndev->features |= NETIF_F_DMA_HIGH;
 	if (high_dma) {
-		ndev->features |= NETIF_F_HIGHDMA;
+		ndev->features |= NETIF_F_DMA_64BIT;
 		vxge_debug_init(vxge_hw_device_trace_level_get(hldev),
 			"%s : using High DMA", __func__);
 	}
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 599aa4e..c57cd66 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -633,7 +633,7 @@ void i2400m_netdev_setup(struct net_device *net_dev)
 	net_dev->tx_queue_len = I2400M_TX_QLEN;
 	net_dev->features =
 		  NETIF_F_VLAN_CHALLENGED
-		| NETIF_F_HIGHDMA;
+		| NETIF_F_DMA_HIGH;
 	net_dev->flags =
 		IFF_NOARP		/* i2400m is apure IP device */
 		& (~IFF_BROADCAST	/* i2400m is P2P */
diff --git a/drivers/uwb/i1480/i1480u-wlp/lc.c b/drivers/uwb/i1480/i1480u-wlp/lc.c
index f272dfe..052edb5 100644
--- a/drivers/uwb/i1480/i1480u-wlp/lc.c
+++ b/drivers/uwb/i1480/i1480u-wlp/lc.c
@@ -241,7 +241,7 @@ int i1480u_add(struct i1480u *i1480u, struct usb_interface *iface)
 	net_dev->features &= ~NETIF_F_SG;
 	net_dev->features &= ~NETIF_F_FRAGLIST;
 	/* All NETIF_F_*_CSUM disabled */
-	net_dev->features |= NETIF_F_HIGHDMA;
+	net_dev->features |= NETIF_F_DMA_HIGH;
 	net_dev->watchdog_timeo = 5*HZ;		/* FIXME: a better default? */
 
 	net_dev->netdev_ops = &i1480u_netdev_ops;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c79a88b..70200e1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -746,7 +746,7 @@ struct net_device {
 #define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack. */
 #define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
 #define NETIF_F_IPV6_CSUM	16	/* Can checksum TCP/UDP over IPV6 */
-#define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
+#define NETIF_F_DMA_HIGH	32	/* Can DMA to high memory. */
 #define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
 #define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
 #define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
@@ -764,6 +764,10 @@ struct net_device {
 #define NETIF_F_SCTP_CSUM	(1 << 25) /* SCTP checksum offload */
 #define NETIF_F_FCOE_MTU	(1 << 26) /* Supports max FCoE MTU, 2158 bytes*/
 #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
+#define NETIF_F_DMA_64BIT	(1 << 28) /* 64-bit DMA support */
+
+	/* for backward compatibility */
+#define NETIF_F_HIGHDMA		(NETIF_F_DMA_HIGH | NETIF_F_DMA_64BIT)
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -789,7 +793,7 @@ struct net_device {
 	 * for all in netdev_increment_features.
 	 */
 #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | \
-				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
+				 NETIF_F_SG | NETIF_F_DMA_HIGH |	\
 				 NETIF_F_FRAGLIST)
 
 	/* Interface index. Unique device identifier	*/
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index eb7062d..da24dd9 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -197,7 +197,7 @@ void br_dev_setup(struct net_device *dev)
 	dev->tx_queue_len = 0;
 	dev->priv_flags = IFF_EBRIDGE;
 
-	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
+	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_DMA_HIGH |
 			NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX |
-			NETIF_F_NETNS_LOCAL | NETIF_F_GSO;
+			NETIF_F_NETNS_LOCAL | NETIF_F_GSO | NETIF_F_DMA_64BIT;
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index bcc490c..4b1f50b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1785,15 +1785,24 @@ EXPORT_SYMBOL(netdev_rx_csum_fault);
 
 static inline int illegal_highdma(struct net_device *dev, struct sk_buff *skb)
 {
+	/* Note that these checks are skipped if CONFIG_HIGHMEM is not set.
+	   In that case, the PageHighMem check is obviously not applicable,
+	   and copying the skb may not result in 32-bit reachable memory
+	   anyway - IOMMU has to handle bounce buffering/mapping. */
 #ifdef CONFIG_HIGHMEM
 	int i;
 
-	if (dev->features & NETIF_F_HIGHDMA)
-		return 0;
-
-	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
-		if (PageHighMem(skb_shinfo(skb)->frags[i].page))
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		/* check for highmem page and non-highmem-capable device */
+		if (!(dev->features & NETIF_F_DMA_HIGH) &&
+		    PageHighMem(skb_shinfo(skb)->frags[i].page))
 			return 1;
+		/* check for page >4GB and non-64bit-capable device */
+		if (!(dev->features & NETIF_F_DMA_64BIT) &&
+		    page_to_pfn(skb_shinfo(skb)->frags[i].page) >
+			(0xffffffff >> PAGE_SHIFT))
+			return 1;
+	}
 
 #endif
 	return 0;
