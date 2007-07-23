From: "Veena Parat" <Veena.Parat@neterion.com>
Subject: RE: [PATCH 2.6.22 1/4]S2IO: Removing MSI support from driver
Date: Mon, 23 Jul 2007 02:33:32 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7701ED0874@nekter>
References: <Pine.GSO.4.10.10707230221490.2793-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "support" <support@neterion.com>
To: "Veena Parat" <Veena.Parat@neterion.com>, <netdev@vger.kernel.org>,
	<jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:6653 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756308AbXGWGdo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 02:33:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <Pine.GSO.4.10.10707230221490.2793-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The patch number is incorrect in the below mail. It should be 
[PATCH 2.6.22 2/4] instead of [PATCH 2.6.22 1/4].
Pls consider it as the second patch in this series.
Sorry for the inconvenience.

Regards
Veena

-----Original Message-----
From: Veena Parat [mailto:Veena.Parat@neterion.com] 
Sent: Monday, July 23, 2007 11:54 AM
To: netdev@vger.kernel.org; jeff@garzik.org
Cc: support
Subject: [PATCH 2.6.22 1/4]S2IO: Removing MSI support from driver

 - Removed MSI support from driver - unused feature
 - Replaced request_mem_region with pci_request_regions
 
Signed-off-by: Veena Parat <veena.parat@neterion.com>
---
diff -urpN patch_1/drivers/net/s2io.c patch_2/drivers/net/s2io.c
--- patch_1/drivers/net/s2io.c	2007-07-19 14:20:53.000000000 +0530
+++ patch_2/drivers/net/s2io.c	2007-07-19 15:08:18.000000000 +0530
@@ -37,7 +37,7 @@
  * tx_fifo_len: This too is an array of 8. Each element defines the
number of
  * Tx descriptors that can be associated with each corresponding FIFO.
  * intr_type: This defines the type of interrupt. The values can be
0(INTA),
- *     1(MSI), 2(MSI_X). Default value is '0(INTA)'
+ *     2(MSI_X). Default value is '0(INTA)'
  * lro: Specifies whether to enable Large Receive Offload (LRO) or not.
  *     Possible values '1' for enable '0' for disable. Default is '0'
  * lro_max_pkts: This parameter defines maximum number of packets can
be
@@ -426,7 +426,7 @@ S2IO_PARM_INT(bimodal, 0);
 S2IO_PARM_INT(l3l4hdr_size, 128);
 /* Frequency of Rx desc syncs expressed as power of 2 */
 S2IO_PARM_INT(rxsync_frequency, 3);
-/* Interrupt type. Values can be 0(INTA), 1(MSI), 2(MSI_X) */
+/* Interrupt type. Values can be 0(INTA), 2(MSI_X) */
 S2IO_PARM_INT(intr_type, 0);
 /* Large receive offload feature */
 S2IO_PARM_INT(lro, 0);
@@ -3662,56 +3662,6 @@ static void store_xmsi_data(struct s2io_
 	}
 }
 
-int s2io_enable_msi(struct s2io_nic *nic)
-{
-	struct XENA_dev_config __iomem *bar0 = nic->bar0;
-	u16 msi_ctrl, msg_val;
-	struct config_param *config = &nic->config;
-	struct net_device *dev = nic->dev;
-	u64 val64, tx_mat, rx_mat;
-	int i, err;
-
-	val64 = readq(&bar0->pic_control);
-	val64 &= ~BIT(1);
-	writeq(val64, &bar0->pic_control);
-
-	err = pci_enable_msi(nic->pdev);
-	if (err) {
-		DBG_PRINT(ERR_DBG, "%s: enabling MSI failed\n",
-			  nic->dev->name);
-		return err;
-	}
-
-	/*
-	 * Enable MSI and use MSI-1 in stead of the standard MSI-0
-	 * for interrupt handling.
-	 */
-	pci_read_config_word(nic->pdev, 0x4c, &msg_val);
-	msg_val ^= 0x1;
-	pci_write_config_word(nic->pdev, 0x4c, msg_val);
-	pci_read_config_word(nic->pdev, 0x4c, &msg_val);
-
-	pci_read_config_word(nic->pdev, 0x42, &msi_ctrl);
-	msi_ctrl |= 0x10;
-	pci_write_config_word(nic->pdev, 0x42, msi_ctrl);
-
-	/* program MSI-1 into all usable Tx_Mat and Rx_Mat fields */
-	tx_mat = readq(&bar0->tx_mat0_n[0]);
-	for (i=0; i<config->tx_fifo_num; i++) {
-		tx_mat |= TX_MAT_SET(i, 1);
-	}
-	writeq(tx_mat, &bar0->tx_mat0_n[0]);
-
-	rx_mat = readq(&bar0->rx_mat);
-	for (i=0; i<config->rx_ring_num; i++) {
-		rx_mat |= RX_MAT_SET(i, 1);
-	}
-	writeq(rx_mat, &bar0->rx_mat);
-
-	dev->irq = nic->pdev->irq;
-	return 0;
-}
-
 static int s2io_enable_msi_x(struct s2io_nic *nic)
 {
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
@@ -4117,39 +4067,6 @@ static int s2io_chk_rx_buffers(struct s2
 	return 0;
 }
 
-static irqreturn_t s2io_msi_handle(int irq, void *dev_id)
-{
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct s2io_nic *sp = dev->priv;
-	int i;
-	struct mac_info *mac_control;
-	struct config_param *config;
-
-	atomic_inc(&sp->isr_cnt);
-	mac_control = &sp->mac_control;
-	config = &sp->config;
-	DBG_PRINT(INTR_DBG, "%s: MSI handler\n", __FUNCTION__);
-
-	/* If Intr is because of Rx Traffic */
-	for (i = 0; i < config->rx_ring_num; i++)
-		rx_intr_handler(&mac_control->rings[i]);
-
-	/* If Intr is because of Tx Traffic */
-	for (i = 0; i < config->tx_fifo_num; i++)
-		tx_intr_handler(&mac_control->fifos[i]);
-
-	/*
-	 * If the Rx buffer count is below the panic threshold then
-	 * reallocate the buffers from the interrupt handler itself,
-	 * else schedule a tasklet to reallocate the buffers.
-	 */
-	for (i = 0; i < config->rx_ring_num; i++)
-		s2io_chk_rx_buffers(sp, i);
-
-	atomic_dec(&sp->isr_cnt);
-	return IRQ_HANDLED;
-}
-
 static irqreturn_t s2io_msix_ring_handle(int irq, void *dev_id)
 {
 	struct ring_info *ring = (struct ring_info *)dev_id;
@@ -6332,9 +6249,7 @@ static int s2io_add_isr(struct s2io_nic 
 	struct net_device *dev = sp->dev;
 	int err = 0;
 
-	if (sp->intr_type == MSI)
-		ret = s2io_enable_msi(sp);
-	else if (sp->intr_type == MSI_X)
+	if (sp->intr_type == MSI_X)
 		ret = s2io_enable_msi_x(sp);
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "%s: Defaulting to INTA\n",
dev->name);
@@ -6345,16 +6260,6 @@ static int s2io_add_isr(struct s2io_nic 
 	store_xmsi_data(sp);
 
 	/* After proper initialization of H/W, register ISR */
-	if (sp->intr_type == MSI) {
-		err = request_irq((int) sp->pdev->irq, s2io_msi_handle,
-			IRQF_SHARED, sp->name, dev);
-		if (err) {
-			pci_disable_msi(sp->pdev);
-			DBG_PRINT(ERR_DBG, "%s: MSI registration
failed\n",
-				  dev->name);
-			return -1;
-		}
-	}
 	if (sp->intr_type == MSI_X) {
 		int i, msix_tx_cnt=0,msix_rx_cnt=0;
 
@@ -6441,14 +6346,6 @@ static void s2io_rem_isr(struct s2io_nic
 		pci_disable_msix(sp->pdev);
 	} else {
 		free_irq(sp->pdev->irq, dev);
-		if (sp->intr_type == MSI) {
-			u16 val;
-
-			pci_disable_msi(sp->pdev);
-			pci_read_config_word(sp->pdev, 0x4c, &val);
-			val ^= 0x1;
-			pci_write_config_word(sp->pdev, 0x4c, val);
-		}
 	}
 	/* Waiting till all Interrupt handlers are complete */
 	cnt = 0;
@@ -6994,7 +6891,7 @@ static int s2io_verify_parm(struct pci_d
 		*dev_intr_type = INTA;
 	}
 #else
-	if (*dev_intr_type > MSI_X) {
+	if ((*dev_intr_type != INTA) && (*dev_intr_type != MSI_X)) {
 		DBG_PRINT(ERR_DBG, "s2io: Wrong intr_type requested. "
 			  "Defaulting to INTA\n");
 		*dev_intr_type = INTA;
@@ -7103,28 +7000,10 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		pci_disable_device(pdev);
 		return -ENOMEM;
 	}
-	if (dev_intr_type != MSI_X) {
-		if (pci_request_regions(pdev, s2io_driver_name)) {
-			DBG_PRINT(ERR_DBG, "Request Regions failed\n");
-			pci_disable_device(pdev);
-			return -ENODEV;
-		}
-	}
-	else {
-		if (!(request_mem_region(pci_resource_start(pdev, 0),
-               	         pci_resource_len(pdev, 0),
s2io_driver_name))) {
-			DBG_PRINT(ERR_DBG, "bar0 Request Regions
failed\n");
-			pci_disable_device(pdev);
-			return -ENODEV;
-		}
-        	if (!(request_mem_region(pci_resource_start(pdev, 2),
-               	         pci_resource_len(pdev, 2),
s2io_driver_name))) {
-			DBG_PRINT(ERR_DBG, "bar1 Request Regions
failed\n");
-                	release_mem_region(pci_resource_start(pdev, 0),
-                                   pci_resource_len(pdev, 0));
-			pci_disable_device(pdev);
-			return -ENODEV;
-		}
+	if ((ret = pci_request_regions(pdev, s2io_driver_name))) {
+		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n",
__FUNCTION__, ret);
+		pci_disable_device(pdev);
+		return -ENODEV;
 	}
 
 	dev = alloc_etherdev(sizeof(struct s2io_nic));
@@ -7434,9 +7313,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		case INTA:
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type INTA\n",
dev->name);
 		    break;
-		case MSI:
-		    DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI\n",
dev->name);
-		    break;
 		case MSI_X:
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI-X\n",
dev->name);
 		    break;
@@ -7476,14 +7352,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
       mem_alloc_failed:
 	free_shared_mem(sp);
 	pci_disable_device(pdev);
-	if (dev_intr_type != MSI_X)
-		pci_release_regions(pdev);
-	else {
-		release_mem_region(pci_resource_start(pdev, 0),
-			pci_resource_len(pdev, 0));
-		release_mem_region(pci_resource_start(pdev, 2),
-			pci_resource_len(pdev, 2));
-	}
+	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 
@@ -7518,14 +7387,7 @@ static void __devexit s2io_rem_nic(struc
 	free_shared_mem(sp);
 	iounmap(sp->bar0);
 	iounmap(sp->bar1);
-	if (sp->intr_type != MSI_X)
-		pci_release_regions(pdev);
-	else {
-		release_mem_region(pci_resource_start(pdev, 0),
-			pci_resource_len(pdev, 0));
-		release_mem_region(pci_resource_start(pdev, 2),
-			pci_resource_len(pdev, 2));
-	}
+	pci_release_regions(pdev);
 	pci_set_drvdata(pdev, NULL);
 	free_netdev(dev);
 	pci_disable_device(pdev);
diff -urpN patch_1/drivers/net/s2io.h patch_2/drivers/net/s2io.h
--- patch_1/drivers/net/s2io.h	2007-07-19 14:20:53.000000000 +0530
+++ patch_2/drivers/net/s2io.h	2007-07-19 14:43:39.000000000 +0530
@@ -875,7 +875,6 @@ struct s2io_nic {
 	u16		lro_max_aggr_per_sess;
 
 #define INTA	0
-#define MSI	1
 #define MSI_X	2
 	u8 intr_type;
 
@@ -1019,8 +1018,6 @@ static int s2io_poll(struct net_device *
 static void s2io_init_pci(struct s2io_nic * sp);
 static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
 static void s2io_alarm_handle(unsigned long data);
-static int s2io_enable_msi(struct s2io_nic *nic);
-static irqreturn_t s2io_msi_handle(int irq, void *dev_id);
 static irqreturn_t
 s2io_msix_ring_handle(int irq, void *dev_id);
 static irqreturn_t

