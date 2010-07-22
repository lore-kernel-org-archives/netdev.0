From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/qla3xxx.c: Update logging message style
Date: Thu, 22 Jul 2010 15:33:31 -0700
Message-ID: <4057a685dc2c277e9e3137c4f0e01eeb389971a4.1279837596.git.joe@perches.com>
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use pr_<level>
Use netdev_<level>
Use netif_<level>
Remove #define PFX
Improve a couple of loops to avoid deep indentation.

Compile tested only

$ size drivers/net/qla3xxx.o.*
   text    data     bss     dec     hex filename
  51603     212   13864   65679   1008f drivers/net/qla3xxx.o.old
  50413     212   13864   64489    fbe9 drivers/net/qla3xxx.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/qla3xxx.c |  524 +++++++++++++++++++------------------------------
 1 files changed, 200 insertions(+), 324 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 54ebb65..74debf1 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -5,6 +5,8 @@
  * See LICENSE.qla3xxx for copyright and licensing details.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/types.h>
@@ -39,11 +41,13 @@
 #define DRV_NAME  	"qla3xxx"
 #define DRV_STRING 	"QLogic ISP3XXX Network Driver"
 #define DRV_VERSION	"v2.03.00-k5"
-#define PFX		DRV_NAME " "
 
 static const char ql3xxx_driver_name[] = DRV_NAME;
 static const char ql3xxx_driver_version[] = DRV_VERSION;
 
+#define TIMED_OUT_MSG							\
+"Timed out waiting for management port to get free before issuing command\n"
+
 MODULE_AUTHOR("QLogic Corporation");
 MODULE_DESCRIPTION("QLogic ISP3XXX Network Driver " DRV_VERSION " ");
 MODULE_LICENSE("GPL");
@@ -139,27 +143,22 @@ static int ql_wait_for_drvr_lock(struct ql3_adapter *qdev)
 {
 	int i = 0;
 
-	while (1) {
-		if (!ql_sem_lock(qdev,
-				 QL_DRVR_SEM_MASK,
-				 (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index)
-				  * 2) << 1)) {
-			if (i < 10) {
-				ssleep(1);
-				i++;
-			} else {
-				printk(KERN_ERR PFX "%s: Timed out waiting for "
-				       "driver lock...\n",
-				       qdev->ndev->name);
-				return 0;
-			}
-		} else {
-			printk(KERN_DEBUG PFX
-			       "%s: driver lock acquired.\n",
-			       qdev->ndev->name);
+	while (i < 10) {
+		if (i)
+			ssleep(1);
+
+		if (ql_sem_lock(qdev,
+				QL_DRVR_SEM_MASK,
+				(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index)
+				 * 2) << 1)) {
+			netdev_printk(KERN_DEBUG, qdev->ndev,
+				      "driver lock acquired\n");
 			return 1;
 		}
 	}
+
+	netdev_err(qdev->ndev, "Timed out waiting for driver lock...\n");
+	return 0;
 }
 
 static void ql_set_register_page(struct ql3_adapter *qdev, u32 page)
@@ -308,8 +307,7 @@ static void ql_release_to_lrg_buf_free_list(struct ql3_adapter *qdev,
 		lrg_buf_cb->skb = netdev_alloc_skb(qdev->ndev,
 						   qdev->lrg_buffer_len);
 		if (unlikely(!lrg_buf_cb->skb)) {
-			printk(KERN_ERR PFX "%s: failed netdev_alloc_skb().\n",
-			       qdev->ndev->name);
+			netdev_err(qdev->ndev, "failed netdev_alloc_skb()\n");
 			qdev->lrg_buf_skb_check++;
 		} else {
 			/*
@@ -324,8 +322,9 @@ static void ql_release_to_lrg_buf_free_list(struct ql3_adapter *qdev,
 					     PCI_DMA_FROMDEVICE);
 			err = pci_dma_mapping_error(qdev->pdev, map);
 			if(err) {
-				printk(KERN_ERR "%s: PCI mapping failed with error: %d\n",
-				       qdev->ndev->name, err);
+				netdev_err(qdev->ndev,
+					   "PCI mapping failed with error: %d\n",
+					   err);
 				dev_kfree_skb(lrg_buf_cb->skb);
 				lrg_buf_cb->skb = NULL;
 
@@ -556,8 +555,7 @@ static int ql_get_nvram_params(struct ql3_adapter *qdev)
 	if(ql_sem_spinlock(qdev, QL_NVRAM_SEM_MASK,
 			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
 			 2) << 10)) {
-		printk(KERN_ERR PFX"%s: Failed ql_sem_spinlock().\n",
-			__func__);
+		pr_err("%s: Failed ql_sem_spinlock()\n", __func__);
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		return -1;
 	}
@@ -570,8 +568,8 @@ static int ql_get_nvram_params(struct ql3_adapter *qdev)
 	ql_sem_unlock(qdev, QL_NVRAM_SEM_MASK);
 
 	if (checksum != 0) {
-		printk(KERN_ERR PFX "%s: checksum should be zero, is %x!!\n",
-		       qdev->ndev->name, checksum);
+		netdev_err(qdev->ndev, "checksum should be zero, is %x!!\n",
+			   checksum);
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		return -1;
 	}
@@ -668,11 +666,7 @@ static int ql_mii_write_reg_ex(struct ql3_adapter *qdev,
 	scanWasEnabled = ql_mii_disable_scan_mode(qdev);
 
 	if (ql_wait_for_mii_ready(qdev)) {
-		if (netif_msg_link(qdev))
-			printk(KERN_WARNING PFX
-			       "%s Timed out waiting for management port to "
-			       "get free before issuing command.\n",
-			       qdev->ndev->name);
+		netif_warn(qdev, link, qdev->ndev, TIMED_OUT_MSG);
 		return -1;
 	}
 
@@ -683,11 +677,7 @@ static int ql_mii_write_reg_ex(struct ql3_adapter *qdev,
 
 	/* Wait for write to complete 9/10/04 SJP */
 	if (ql_wait_for_mii_ready(qdev)) {
-		if (netif_msg_link(qdev))
-			printk(KERN_WARNING PFX
-			       "%s: Timed out waiting for management port to "
-			       "get free before issuing command.\n",
-			       qdev->ndev->name);
+		netif_warn(qdev, link, qdev->ndev, TIMED_OUT_MSG);
 		return -1;
 	}
 
@@ -708,11 +698,7 @@ static int ql_mii_read_reg_ex(struct ql3_adapter *qdev, u16 regAddr,
 	scanWasEnabled = ql_mii_disable_scan_mode(qdev);
 
 	if (ql_wait_for_mii_ready(qdev)) {
-		if (netif_msg_link(qdev))
-			printk(KERN_WARNING PFX
-			       "%s: Timed out waiting for management port to "
-			       "get free before issuing command.\n",
-			       qdev->ndev->name);
+		netif_warn(qdev, link, qdev->ndev, TIMED_OUT_MSG);
 		return -1;
 	}
 
@@ -727,11 +713,7 @@ static int ql_mii_read_reg_ex(struct ql3_adapter *qdev, u16 regAddr,
 
 	/* Wait for the read to complete */
 	if (ql_wait_for_mii_ready(qdev)) {
-		if (netif_msg_link(qdev))
-			printk(KERN_WARNING PFX
-			       "%s: Timed out waiting for management port to "
-			       "get free after issuing command.\n",
-			       qdev->ndev->name);
+		netif_warn(qdev, link, qdev->ndev, TIMED_OUT_MSG);
 		return -1;
 	}
 
@@ -752,11 +734,7 @@ static int ql_mii_write_reg(struct ql3_adapter *qdev, u16 regAddr, u16 value)
 	ql_mii_disable_scan_mode(qdev);
 
 	if (ql_wait_for_mii_ready(qdev)) {
-		if (netif_msg_link(qdev))
-			printk(KERN_WARNING PFX
-			       "%s: Timed out waiting for management port to "
-			       "get free before issuing command.\n",
-			       qdev->ndev->name);
+		netif_warn(qdev, link, qdev->ndev, TIMED_OUT_MSG);
 		return -1;
 	}
 
@@ -767,11 +745,7 @@ static int ql_mii_write_reg(struct ql3_adapter *qdev, u16 regAddr, u16 value)
 
 	/* Wait for write to complete. */
 	if (ql_wait_for_mii_ready(qdev)) {
-		if (netif_msg_link(qdev))
-			printk(KERN_WARNING PFX
-			       "%s: Timed out waiting for management port to "
-			       "get free before issuing command.\n",
-			       qdev->ndev->name);
+		netif_warn(qdev, link, qdev->ndev, TIMED_OUT_MSG);
 		return -1;
 	}
 
@@ -789,11 +763,7 @@ static int ql_mii_read_reg(struct ql3_adapter *qdev, u16 regAddr, u16 *value)
 	ql_mii_disable_scan_mode(qdev);
 
 	if (ql_wait_for_mii_ready(qdev)) {
-		if (netif_msg_link(qdev))
-			printk(KERN_WARNING PFX
-			       "%s: Timed out waiting for management port to "
-			       "get free before issuing command.\n",
-			       qdev->ndev->name);
+		netif_warn(qdev, link, qdev->ndev, TIMED_OUT_MSG);
 		return -1;
 	}
 
@@ -808,11 +778,7 @@ static int ql_mii_read_reg(struct ql3_adapter *qdev, u16 regAddr, u16 *value)
 
 	/* Wait for the read to complete */
 	if (ql_wait_for_mii_ready(qdev)) {
-		if (netif_msg_link(qdev))
-			printk(KERN_WARNING PFX
-			       "%s: Timed out waiting for management port to "
-			       "get free before issuing command.\n",
-			       qdev->ndev->name);
+		netif_warn(qdev, link, qdev->ndev, TIMED_OUT_MSG);
 		return -1;
 	}
 
@@ -898,7 +864,7 @@ static int ql_is_petbi_neg_pause(struct ql3_adapter *qdev)
 
 static void phyAgereSpecificInit(struct ql3_adapter *qdev, u32 miiAddr)
 {
-	printk(KERN_INFO "%s: enabling Agere specific PHY\n", qdev->ndev->name);
+	netdev_info(qdev->ndev, "enabling Agere specific PHY\n");
 	/* power down device bit 11 = 1 */
 	ql_mii_write_reg_ex(qdev, 0x00, 0x1940, miiAddr);
 	/* enable diagnostic mode bit 2 = 1 */
@@ -952,12 +918,12 @@ static PHY_DEVICE_et getPhyType (struct ql3_adapter *qdev,
 
 	/* Scan table for this PHY */
 	for(i = 0; i < MAX_PHY_DEV_TYPES; i++) {
-		if ((oui == PHY_DEVICES[i].phyIdOUI) && (model == PHY_DEVICES[i].phyIdModel))
-		{
+		if ((oui == PHY_DEVICES[i].phyIdOUI) &&
+		    (model == PHY_DEVICES[i].phyIdModel)) {
 			result = PHY_DEVICES[i].phyDevice;
 
-			printk(KERN_INFO "%s: Phy: %s\n",
-				qdev->ndev->name, PHY_DEVICES[i].name);
+			netdev_info(qdev->ndev, "Phy: %s\n",
+				    PHY_DEVICES[i].name);
 
 		        break;
 		}
@@ -1041,15 +1007,13 @@ static int PHY_Setup(struct ql3_adapter *qdev)
 	/*  Determine the PHY we are using by reading the ID's */
 	err = ql_mii_read_reg(qdev, PHY_ID_0_REG, &reg1);
 	if(err != 0) {
-		printk(KERN_ERR "%s: Could not read from reg PHY_ID_0_REG\n",
-		       qdev->ndev->name);
+		netdev_err(qdev->ndev, "Could not read from reg PHY_ID_0_REG\n");
                 return err;
 	}
 
 	err = ql_mii_read_reg(qdev, PHY_ID_1_REG, &reg2);
 	if(err != 0) {
-		printk(KERN_ERR "%s: Could not read from reg PHY_ID_0_REG\n",
-		       qdev->ndev->name);
+		netdev_err(qdev->ndev, "Could not read from reg PHY_ID_1_REG\n");
                 return err;
 	}
 
@@ -1066,15 +1030,14 @@ static int PHY_Setup(struct ql3_adapter *qdev)
 
 		err =ql_mii_read_reg_ex(qdev, PHY_ID_0_REG, &reg1, miiAddr);
 		if(err != 0) {
-			printk(KERN_ERR "%s: Could not read from reg PHY_ID_0_REG after Agere detected\n",
-		       	       qdev->ndev->name);
+			netdev_err(qdev->ndev,
+				   "Could not read from reg PHY_ID_0_REG after Agere detected\n");
 			return err;
 		}
 
 		err = ql_mii_read_reg_ex(qdev, PHY_ID_1_REG, &reg2, miiAddr);
 		if(err != 0) {
-			printk(KERN_ERR "%s: Could not read from reg PHY_ID_0_REG after Agere detected\n",
-			       qdev->ndev->name);
+			netdev_err(qdev->ndev, "Could not read from reg PHY_ID_1_REG after Agere detected\n");
         	        return err;
 		}
 
@@ -1090,7 +1053,7 @@ static int PHY_Setup(struct ql3_adapter *qdev)
 		/* need this here so address gets changed */
 		phyAgereSpecificInit(qdev, miiAddr);
 	} else if (qdev->phyType == PHY_TYPE_UNKNOWN) {
-		printk(KERN_ERR "%s: PHY is unknown\n", qdev->ndev->name);
+		netdev_err(qdev->ndev, "PHY is unknown\n");
 		return -EIO;
 	}
 
@@ -1250,18 +1213,11 @@ static int ql_is_auto_neg_complete(struct ql3_adapter *qdev)
 
 	temp = ql_read_page0_reg(qdev, &port_regs->portStatus);
 	if (temp & bitToCheck) {
-		if (netif_msg_link(qdev))
-			printk(KERN_INFO PFX
-			       "%s: Auto-Negotiate complete.\n",
-			       qdev->ndev->name);
+		netif_info(qdev, link, qdev->ndev, "Auto-Negotiate complete\n");
 		return 1;
-	} else {
-		if (netif_msg_link(qdev))
-			printk(KERN_WARNING PFX
-			       "%s: Auto-Negotiate incomplete.\n",
-			       qdev->ndev->name);
-		return 0;
 	}
+	netif_info(qdev, link, qdev->ndev, "Auto-Negotiate incomplete\n");
+	return 0;
 }
 
 /*
@@ -1387,16 +1343,13 @@ static int ql_this_adapter_controls_port(struct ql3_adapter *qdev)
 
 	temp = ql_read_page0_reg(qdev, &port_regs->portStatus);
 	if (temp & bitToCheck) {
-		if (netif_msg_link(qdev))
-			printk(KERN_DEBUG PFX
-			       "%s: is not link master.\n", qdev->ndev->name);
+		netif_printk(qdev, link, KERN_DEBUG, qdev->ndev,
+			     "not link master\n");
 		return 0;
-	} else {
-		if (netif_msg_link(qdev))
-			printk(KERN_DEBUG PFX
-			       "%s: is link master.\n", qdev->ndev->name);
-		return 1;
 	}
+
+	netif_printk(qdev, link, KERN_DEBUG, qdev->ndev, "link master\n");
+	return 1;
 }
 
 static void ql_phy_reset_ex(struct ql3_adapter *qdev)
@@ -1518,8 +1471,7 @@ static int ql_port_start(struct ql3_adapter *qdev)
 	if(ql_sem_spinlock(qdev, QL_PHY_GIO_SEM_MASK,
 		(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
 			 2) << 7)) {
-		printk(KERN_ERR "%s: Could not get hw lock for GIO\n",
-		       qdev->ndev->name);
+		netdev_err(qdev->ndev, "Could not get hw lock for GIO\n");
 		return -1;
 	}
 
@@ -1545,11 +1497,8 @@ static int ql_finish_auto_neg(struct ql3_adapter *qdev)
 	if (!ql_auto_neg_error(qdev)) {
 		if (test_bit(QL_LINK_MASTER,&qdev->flags)) {
 			/* configure the MAC */
-			if (netif_msg_link(qdev))
-				printk(KERN_DEBUG PFX
-				       "%s: Configuring link.\n",
-				       qdev->ndev->
-				       name);
+			netif_printk(qdev, link, KERN_DEBUG, qdev->ndev,
+				     "Configuring link\n");
 			ql_mac_cfg_soft_reset(qdev, 1);
 			ql_mac_cfg_gig(qdev,
 				       (ql_get_link_speed
@@ -1564,34 +1513,24 @@ static int ql_finish_auto_neg(struct ql3_adapter *qdev)
 			ql_mac_cfg_soft_reset(qdev, 0);
 
 			/* enable the MAC */
-			if (netif_msg_link(qdev))
-				printk(KERN_DEBUG PFX
-				       "%s: Enabling mac.\n",
-				       qdev->ndev->
-					       name);
+			netif_printk(qdev, link, KERN_DEBUG, qdev->ndev,
+				     "Enabling mac\n");
 			ql_mac_enable(qdev, 1);
 		}
 
 		qdev->port_link_state = LS_UP;
 		netif_start_queue(qdev->ndev);
 		netif_carrier_on(qdev->ndev);
-		if (netif_msg_link(qdev))
-			printk(KERN_INFO PFX
-			       "%s: Link is up at %d Mbps, %s duplex.\n",
-			       qdev->ndev->name,
-			       ql_get_link_speed(qdev),
-			       ql_is_link_full_dup(qdev)
-			       ? "full" : "half");
+		netif_info(qdev, link, qdev->ndev,
+			   "Link is up at %d Mbps, %s duplex\n",
+			   ql_get_link_speed(qdev),
+			   ql_is_link_full_dup(qdev) ? "full" : "half");
 
 	} else {	/* Remote error detected */
 
 		if (test_bit(QL_LINK_MASTER,&qdev->flags)) {
-			if (netif_msg_link(qdev))
-				printk(KERN_DEBUG PFX
-				       "%s: Remote error detected. "
-				       "Calling ql_port_start().\n",
-				       qdev->ndev->
-				       name);
+			netif_printk(qdev, link, KERN_DEBUG, qdev->ndev,
+				     "Remote error detected. Calling ql_port_start()\n");
 			/*
 			 * ql_port_start() is shared code and needs
 			 * to lock the PHY on it's own.
@@ -1620,15 +1559,13 @@ static void ql_link_state_machine_work(struct work_struct *work)
 	curr_link_state = ql_get_link_state(qdev);
 
 	if (test_bit(QL_RESET_ACTIVE,&qdev->flags)) {
-		if (netif_msg_link(qdev))
-			printk(KERN_INFO PFX
-			       "%s: Reset in progress, skip processing link "
-			       "state.\n", qdev->ndev->name);
+		netif_info(qdev, link, qdev->ndev,
+			   "Reset in progress, skip processing link state\n");
 
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 
 		/* Restart timer on 2 second interval. */
-		mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);\
+		mod_timer(&qdev->adapter_timer, jiffies + HZ * 1);
 
 		return;
 	}
@@ -1643,9 +1580,7 @@ static void ql_link_state_machine_work(struct work_struct *work)
 
 	case LS_DOWN:
 		if (curr_link_state == LS_UP) {
-			if (netif_msg_link(qdev))
-				printk(KERN_INFO PFX "%s: Link is up.\n",
-				       qdev->ndev->name);
+			netif_info(qdev, link, qdev->ndev, "Link is up\n");
 			if (ql_is_auto_neg_complete(qdev))
 				ql_finish_auto_neg(qdev);
 
@@ -1662,9 +1597,7 @@ static void ql_link_state_machine_work(struct work_struct *work)
 		 * back up
 		 */
 		if (curr_link_state == LS_DOWN) {
-			if (netif_msg_link(qdev))
-				printk(KERN_INFO PFX "%s: Link is down.\n",
-				       qdev->ndev->name);
+			netif_info(qdev, link, qdev->ndev, "Link is down\n");
 			qdev->port_link_state = LS_DOWN;
 		}
 		if (ql_link_down_detect(qdev))
@@ -1888,9 +1821,8 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
 			lrg_buf_cb->skb = netdev_alloc_skb(qdev->ndev,
 							   qdev->lrg_buffer_len);
 			if (unlikely(!lrg_buf_cb->skb)) {
-				printk(KERN_DEBUG PFX
-				       "%s: Failed netdev_alloc_skb().\n",
-				       qdev->ndev->name);
+				netdev_printk(KERN_DEBUG, qdev->ndev,
+					      "Failed netdev_alloc_skb()\n");
 				break;
 			} else {
 				/*
@@ -1906,8 +1838,9 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
 
 				err = pci_dma_mapping_error(qdev->pdev, map);
 				if(err) {
-					printk(KERN_ERR "%s: PCI mapping failed with error: %d\n",
-					       qdev->ndev->name, err);
+					netdev_err(qdev->ndev,
+						   "PCI mapping failed with error: %d\n",
+						   err);
 					dev_kfree_skb(lrg_buf_cb->skb);
 					lrg_buf_cb->skb = NULL;
 					break;
@@ -2012,14 +1945,16 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 	int retval = 0;
 
 	if(mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
-		printk(KERN_WARNING "Frame short but, frame was padded and sent.\n");
+		netdev_warn(qdev->ndev,
+			    "Frame too short but it was padded and sent\n");
 	}
 
 	tx_cb = &qdev->tx_buf[mac_rsp->transaction_id];
 
 	/*  Check the transmit response flags for any errors */
 	if(mac_rsp->flags & OB_MAC_IOCB_RSP_S) {
-		printk(KERN_ERR "Frame too short to be legal, frame not sent.\n");
+		netdev_err(qdev->ndev,
+			   "Frame too short to be legal, frame not sent\n");
 
 		qdev->ndev->stats.tx_errors++;
 		retval = -EIO;
@@ -2027,7 +1962,8 @@ static void ql_process_mac_tx_intr(struct ql3_adapter *qdev,
 	}
 
 	if(tx_cb->seg_count == 0) {
-		printk(KERN_ERR "tx_cb->seg_count == 0: %d\n", mac_rsp->transaction_id);
+		netdev_err(qdev->ndev, "tx_cb->seg_count == 0: %d\n",
+			   mac_rsp->transaction_id);
 
 		qdev->ndev->stats.tx_errors++;
 		retval = -EIO;
@@ -2177,12 +2113,11 @@ static void ql_process_macip_rx_intr(struct ql3_adapter *qdev,
 		if (checksum &
 			(IB_IP_IOCB_RSP_3032_ICE |
 			 IB_IP_IOCB_RSP_3032_CE)) {
-			printk(KERN_ERR
-			       "%s: Bad checksum for this %s packet, checksum = %x.\n",
-			       __func__,
-			       ((checksum &
-				IB_IP_IOCB_RSP_3032_TCP) ? "TCP" :
-				"UDP"),checksum);
+			netdev_err(ndev,
+				   "%s: Bad checksum for this %s packet, checksum = %x\n",
+				   __func__,
+				   ((checksum & IB_IP_IOCB_RSP_3032_TCP) ?
+				    "TCP" : "UDP"), checksum);
 		} else if ((checksum & IB_IP_IOCB_RSP_3032_TCP) ||
 				(checksum & IB_IP_IOCB_RSP_3032_UDP &&
 				!(checksum & IB_IP_IOCB_RSP_3032_NUC))) {
@@ -2245,18 +2180,15 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
 		default:
 			{
 				u32 *tmp = (u32 *) net_rsp;
-				printk(KERN_ERR PFX
-				       "%s: Hit default case, not "
-				       "handled!\n"
-				       "	dropping the packet, opcode = "
-				       "%x.\n",
-				       ndev->name, net_rsp->opcode);
-				printk(KERN_ERR PFX
-				       "0x%08lx 0x%08lx 0x%08lx 0x%08lx\n",
-				       (unsigned long int)tmp[0],
-				       (unsigned long int)tmp[1],
-				       (unsigned long int)tmp[2],
-				       (unsigned long int)tmp[3]);
+				netdev_err(ndev,
+					   "Hit default case, not handled!\n"
+					   "	dropping the packet, opcode = %x\n"
+					   "0x%08lx 0x%08lx 0x%08lx 0x%08lx\n",
+					   net_rsp->opcode,
+					   (unsigned long int)tmp[0],
+					   (unsigned long int)tmp[1],
+					   (unsigned long int)tmp[2],
+					   (unsigned long int)tmp[3]);
 			}
 		}
 
@@ -2328,18 +2260,18 @@ static irqreturn_t ql3xxx_isr(int irq, void *dev_id)
 			var =
 			    ql_read_page0_reg_l(qdev,
 					      &port_regs->PortFatalErrStatus);
-			printk(KERN_WARNING PFX
-			       "%s: Resetting chip. PortFatalErrStatus "
-			       "register = 0x%x\n", ndev->name, var);
+			netdev_warn(ndev,
+				    "Resetting chip. PortFatalErrStatus register = 0x%x\n",
+				    var);
 			set_bit(QL_RESET_START,&qdev->flags) ;
 		} else {
 			/*
 			 * Soft Reset Requested.
 			 */
 			set_bit(QL_RESET_PER_SCSI,&qdev->flags) ;
-			printk(KERN_ERR PFX
-			       "%s: Another function issued a reset to the "
-			       "chip. ISR value = %x.\n", ndev->name, value);
+			netdev_err(ndev,
+				   "Another function issued a reset to the chip. ISR value = %x\n",
+				   value);
 		}
 		queue_delayed_work(qdev->workqueue, &qdev->reset_work, 0);
 		spin_unlock(&qdev->adapter_lock);
@@ -2438,8 +2370,8 @@ static int ql_send_map(struct ql3_adapter *qdev,
 
 	err = pci_dma_mapping_error(qdev->pdev, map);
 	if(err) {
-		printk(KERN_ERR "%s: PCI mapping failed with error: %d\n",
-		       qdev->ndev->name, err);
+		netdev_err(qdev->ndev, "PCI mapping failed with error: %d\n",
+			   err);
 
 		return NETDEV_TX_BUSY;
 	}
@@ -2472,8 +2404,9 @@ static int ql_send_map(struct ql3_adapter *qdev,
 				err = pci_dma_mapping_error(qdev->pdev, map);
 				if(err) {
 
-					printk(KERN_ERR "%s: PCI mapping outbound address list with error: %d\n",
-					       qdev->ndev->name, err);
+					netdev_err(qdev->ndev,
+						   "PCI mapping outbound address list with error: %d\n",
+						   err);
 					goto map_error;
 				}
 
@@ -2498,8 +2431,9 @@ static int ql_send_map(struct ql3_adapter *qdev,
 
 			err = pci_dma_mapping_error(qdev->pdev, map);
 			if(err) {
-				printk(KERN_ERR "%s: PCI mapping frags failed with error: %d\n",
-				       qdev->ndev->name, err);
+				netdev_err(qdev->ndev,
+					   "PCI mapping frags failed with error: %d\n",
+					   err);
 				goto map_error;
 			}
 
@@ -2582,7 +2516,7 @@ static netdev_tx_t ql3xxx_send(struct sk_buff *skb,
 	tx_cb = &qdev->tx_buf[qdev->req_producer_index] ;
 	if((tx_cb->seg_count = ql_get_seg_count(qdev,
 						(skb_shinfo(skb)->nr_frags))) == -1) {
-		printk(KERN_ERR PFX"%s: invalid segment count!\n",__func__);
+		netdev_err(ndev, "%s: invalid segment count!\n", __func__);
 		return NETDEV_TX_OK;
 	}
 
@@ -2599,7 +2533,7 @@ static netdev_tx_t ql3xxx_send(struct sk_buff *skb,
 		ql_hw_csum_setup(skb, mac_iocb_ptr);
 
 	if(ql_send_map(qdev,mac_iocb_ptr,tx_cb,skb) != NETDEV_TX_OK) {
-		printk(KERN_ERR PFX"%s: Could not map the segments!\n",__func__);
+		netdev_err(ndev, "%s: Could not map the segments!\n", __func__);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -2612,9 +2546,9 @@ static netdev_tx_t ql3xxx_send(struct sk_buff *skb,
 			    &port_regs->CommonRegs.reqQProducerIndex,
 			    qdev->req_producer_index);
 
-	if (netif_msg_tx_queued(qdev))
-		printk(KERN_DEBUG PFX "%s: tx queued, slot %d, len %d\n",
-		       ndev->name, qdev->req_producer_index, skb->len);
+	netif_printk(qdev, tx_queued, KERN_DEBUG, ndev,
+		     "tx queued, slot %d, len %d\n",
+		     qdev->req_producer_index, skb->len);
 
 	atomic_dec(&qdev->tx_count);
 	return NETDEV_TX_OK;
@@ -2632,8 +2566,7 @@ static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
 
 	if ((qdev->req_q_virt_addr == NULL) ||
 	    LS_64BITS(qdev->req_q_phy_addr) & (qdev->req_q_size - 1)) {
-		printk(KERN_ERR PFX "%s: reqQ failed.\n",
-		       qdev->ndev->name);
+		netdev_err(qdev->ndev, "reqQ failed\n");
 		return -ENOMEM;
 	}
 
@@ -2646,9 +2579,7 @@ static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
 
 	if ((qdev->rsp_q_virt_addr == NULL) ||
 	    LS_64BITS(qdev->rsp_q_phy_addr) & (qdev->rsp_q_size - 1)) {
-		printk(KERN_ERR PFX
-		       "%s: rspQ allocation failed\n",
-		       qdev->ndev->name);
+		netdev_err(qdev->ndev, "rspQ allocation failed\n");
 		pci_free_consistent(qdev->pdev, (size_t) qdev->req_q_size,
 				    qdev->req_q_virt_addr,
 				    qdev->req_q_phy_addr);
@@ -2663,8 +2594,7 @@ static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
 static void ql_free_net_req_rsp_queues(struct ql3_adapter *qdev)
 {
 	if (!test_bit(QL_ALLOC_REQ_RSP_Q_DONE,&qdev->flags)) {
-		printk(KERN_INFO PFX
-		       "%s: Already done.\n", qdev->ndev->name);
+		netdev_info(qdev->ndev, "Already done\n");
 		return;
 	}
 
@@ -2695,8 +2625,7 @@ static int ql_alloc_buffer_queues(struct ql3_adapter *qdev)
 
 	qdev->lrg_buf = kmalloc(qdev->num_large_buffers * sizeof(struct ql_rcv_buf_cb),GFP_KERNEL);
 	if (qdev->lrg_buf == NULL) {
-		printk(KERN_ERR PFX
-		       "%s: qdev->lrg_buf alloc failed.\n", qdev->ndev->name);
+		netdev_err(qdev->ndev, "qdev->lrg_buf alloc failed\n");
 		return -ENOMEM;
 	}
 
@@ -2706,8 +2635,7 @@ static int ql_alloc_buffer_queues(struct ql3_adapter *qdev)
 				 &qdev->lrg_buf_q_alloc_phy_addr);
 
 	if (qdev->lrg_buf_q_alloc_virt_addr == NULL) {
-		printk(KERN_ERR PFX
-		       "%s: lBufQ failed\n", qdev->ndev->name);
+		netdev_err(qdev->ndev, "lBufQ failed\n");
 		return -ENOMEM;
 	}
 	qdev->lrg_buf_q_virt_addr = qdev->lrg_buf_q_alloc_virt_addr;
@@ -2727,9 +2655,7 @@ static int ql_alloc_buffer_queues(struct ql3_adapter *qdev)
 				 &qdev->small_buf_q_alloc_phy_addr);
 
 	if (qdev->small_buf_q_alloc_virt_addr == NULL) {
-		printk(KERN_ERR PFX
-		       "%s: Small Buffer Queue allocation failed.\n",
-		       qdev->ndev->name);
+		netdev_err(qdev->ndev, "Small Buffer Queue allocation failed\n");
 		pci_free_consistent(qdev->pdev, qdev->lrg_buf_q_alloc_size,
 				    qdev->lrg_buf_q_alloc_virt_addr,
 				    qdev->lrg_buf_q_alloc_phy_addr);
@@ -2745,8 +2671,7 @@ static int ql_alloc_buffer_queues(struct ql3_adapter *qdev)
 static void ql_free_buffer_queues(struct ql3_adapter *qdev)
 {
 	if (!test_bit(QL_ALLOC_BUFQS_DONE,&qdev->flags)) {
-		printk(KERN_INFO PFX
-		       "%s: Already done.\n", qdev->ndev->name);
+		netdev_info(qdev->ndev, "Already done\n");
 		return;
 	}
 	if(qdev->lrg_buf) kfree(qdev->lrg_buf);
@@ -2783,9 +2708,7 @@ static int ql_alloc_small_buffers(struct ql3_adapter *qdev)
 				 &qdev->small_buf_phy_addr);
 
 	if (qdev->small_buf_virt_addr == NULL) {
-		printk(KERN_ERR PFX
-		       "%s: Failed to get small buffer memory.\n",
-		       qdev->ndev->name);
+		netdev_err(qdev->ndev, "Failed to get small buffer memory\n");
 		return -ENOMEM;
 	}
 
@@ -2811,8 +2734,7 @@ static int ql_alloc_small_buffers(struct ql3_adapter *qdev)
 static void ql_free_small_buffers(struct ql3_adapter *qdev)
 {
 	if (!test_bit(QL_ALLOC_SMALL_BUF_DONE,&qdev->flags)) {
-		printk(KERN_INFO PFX
-		       "%s: Already done.\n", qdev->ndev->name);
+		netdev_info(qdev->ndev, "Already done\n");
 		return;
 	}
 	if (qdev->small_buf_virt_addr != NULL) {
@@ -2874,11 +2796,9 @@ static int ql_alloc_large_buffers(struct ql3_adapter *qdev)
 				       qdev->lrg_buffer_len);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
-			printk(KERN_ERR PFX
-			       "%s: large buff alloc failed, "
-			       "for %d bytes at index %d.\n",
-			       qdev->ndev->name,
-			       qdev->lrg_buffer_len * 2, i);
+			netdev_err(qdev->ndev,
+				   "large buff alloc failed for %d bytes at index %d\n",
+				   qdev->lrg_buffer_len * 2, i);
 			ql_free_large_buffers(qdev);
 			return -ENOMEM;
 		} else {
@@ -2900,8 +2820,9 @@ static int ql_alloc_large_buffers(struct ql3_adapter *qdev)
 
 			err = pci_dma_mapping_error(qdev->pdev, map);
 			if(err) {
-				printk(KERN_ERR "%s: PCI mapping failed with error: %d\n",
-				       qdev->ndev->name, err);
+				netdev_err(qdev->ndev,
+					   "PCI mapping failed with error: %d\n",
+					   err);
 				ql_free_large_buffers(qdev);
 				return -ENOMEM;
 			}
@@ -2968,9 +2889,8 @@ static int ql_alloc_mem_resources(struct ql3_adapter *qdev)
 		qdev->num_lbufq_entries = JUMBO_NUM_LBUFQ_ENTRIES;
 		qdev->lrg_buffer_len = JUMBO_MTU_SIZE;
 	} else {
-		printk(KERN_ERR PFX
-		       "%s: Invalid mtu size.  Only 1500 and 9000 are accepted.\n",
-		       qdev->ndev->name);
+		netdev_err(qdev->ndev, "Invalid mtu size: %d.  Only %d and %d are accepted.\n",
+			   qdev->ndev->mtu, NORMAL_MTU_SIZE, JUMBO_MTU_SIZE);
 		return -ENOMEM;
 	}
 	qdev->num_large_buffers = qdev->num_lbufq_entries * QL_ADDR_ELE_PER_BUFQ_ENTRY;
@@ -3001,34 +2921,27 @@ static int ql_alloc_mem_resources(struct ql3_adapter *qdev)
 		qdev->rsp_producer_index_phy_addr_low =
 		    qdev->req_consumer_index_phy_addr_low + 8;
 	} else {
-		printk(KERN_ERR PFX
-		       "%s: shadowReg Alloc failed.\n", qdev->ndev->name);
+		netdev_err(qdev->ndev, "shadowReg Alloc failed\n");
 		return -ENOMEM;
 	}
 
 	if (ql_alloc_net_req_rsp_queues(qdev) != 0) {
-		printk(KERN_ERR PFX
-		       "%s: ql_alloc_net_req_rsp_queues failed.\n",
-		       qdev->ndev->name);
+		netdev_err(qdev->ndev, "ql_alloc_net_req_rsp_queues failed\n");
 		goto err_req_rsp;
 	}
 
 	if (ql_alloc_buffer_queues(qdev) != 0) {
-		printk(KERN_ERR PFX
-		       "%s: ql_alloc_buffer_queues failed.\n",
-		       qdev->ndev->name);
+		netdev_err(qdev->ndev, "ql_alloc_buffer_queues failed\n");
 		goto err_buffer_queues;
 	}
 
 	if (ql_alloc_small_buffers(qdev) != 0) {
-		printk(KERN_ERR PFX
-		       "%s: ql_alloc_small_buffers failed\n", qdev->ndev->name);
+		netdev_err(qdev->ndev, "ql_alloc_small_buffers failed\n");
 		goto err_small_buffers;
 	}
 
 	if (ql_alloc_large_buffers(qdev) != 0) {
-		printk(KERN_ERR PFX
-		       "%s: ql_alloc_large_buffers failed\n", qdev->ndev->name);
+		netdev_err(qdev->ndev, "ql_alloc_large_buffers failed\n");
 		goto err_small_buffers;
 	}
 
@@ -3353,8 +3266,7 @@ static int ql_adapter_initialize(struct ql3_adapter *qdev)
 	} while (--delay);
 
 	if (delay == 0) {
-		printk(KERN_ERR PFX
-		       "%s: Hw Initialization timeout.\n", qdev->ndev->name);
+		netdev_err(qdev->ndev, "Hw Initialization timeout\n");
 		status = -1;
 		goto out;
 	}
@@ -3396,17 +3308,14 @@ static int ql_adapter_reset(struct ql3_adapter *qdev)
 	/*
 	 * Issue soft reset to chip.
 	 */
-	printk(KERN_DEBUG PFX
-	       "%s: Issue soft reset to chip.\n",
-	       qdev->ndev->name);
+	netdev_printk(KERN_DEBUG, qdev->ndev, "Issue soft reset to chip\n");
 	ql_write_common_reg(qdev,
 			    &port_regs->CommonRegs.ispControlStatus,
 			    ((ISP_CONTROL_SR << 16) | ISP_CONTROL_SR));
 
 	/* Wait 3 seconds for reset to complete. */
-	printk(KERN_DEBUG PFX
-	       "%s: Wait 10 milliseconds for reset to complete.\n",
-	       qdev->ndev->name);
+	netdev_printk(KERN_DEBUG, qdev->ndev,
+		      "Wait 10 milliseconds for reset to complete\n");
 
 	/* Wait until the firmware tells us the Soft Reset is done */
 	max_wait_time = 5;
@@ -3427,8 +3336,8 @@ static int ql_adapter_reset(struct ql3_adapter *qdev)
 	value =
 	    ql_read_common_reg(qdev, &port_regs->CommonRegs.ispControlStatus);
 	if (value & ISP_CONTROL_RI) {
-		printk(KERN_DEBUG PFX
-		       "ql_adapter_reset: clearing RI after reset.\n");
+		netdev_printk(KERN_DEBUG, qdev->ndev,
+			      "clearing RI after reset\n");
 		ql_write_common_reg(qdev,
 				    &port_regs->CommonRegs.
 				    ispControlStatus,
@@ -3503,9 +3412,9 @@ static void ql_set_mac_info(struct ql3_adapter *qdev)
 	case ISP_CONTROL_FN0_SCSI:
 	case ISP_CONTROL_FN1_SCSI:
 	default:
-		printk(KERN_DEBUG PFX
-		       "%s: Invalid function number, ispControlStatus = 0x%x\n",
-		       qdev->ndev->name,value);
+		netdev_printk(KERN_DEBUG, qdev->ndev,
+			      "Invalid function number, ispControlStatus = 0x%x\n",
+			      value);
 		break;
 	}
 	qdev->numPorts = qdev->nvram_data.version_and_numPorts >> 8;
@@ -3516,32 +3425,26 @@ static void ql_display_dev_info(struct net_device *ndev)
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
 	struct pci_dev *pdev = qdev->pdev;
 
-	printk(KERN_INFO PFX
-	       "\n%s Adapter %d RevisionID %d found %s on PCI slot %d.\n",
-	       DRV_NAME, qdev->index, qdev->chip_rev_id,
-	       (qdev->device_id == QL3032_DEVICE_ID) ? "QLA3032" : "QLA3022",
-	       qdev->pci_slot);
-	printk(KERN_INFO PFX
-	       "%s Interface.\n",
-	       test_bit(QL_LINK_OPTICAL,&qdev->flags) ? "OPTICAL" : "COPPER");
+	netdev_info(ndev,
+		    "%s Adapter %d RevisionID %d found %s on PCI slot %d\n",
+		    DRV_NAME, qdev->index, qdev->chip_rev_id,
+		    (qdev->device_id == QL3032_DEVICE_ID) ? "QLA3032" : "QLA3022",
+		    qdev->pci_slot);
+	netdev_info(ndev, "%s Interface\n",
+		test_bit(QL_LINK_OPTICAL, &qdev->flags) ? "OPTICAL" : "COPPER");
 
 	/*
 	 * Print PCI bus width/type.
 	 */
-	printk(KERN_INFO PFX
-	       "Bus interface is %s %s.\n",
-	       ((qdev->pci_width == 64) ? "64-bit" : "32-bit"),
-	       ((qdev->pci_x) ? "PCI-X" : "PCI"));
+	netdev_info(ndev, "Bus interface is %s %s\n",
+		    ((qdev->pci_width == 64) ? "64-bit" : "32-bit"),
+		    ((qdev->pci_x) ? "PCI-X" : "PCI"));
 
-	printk(KERN_INFO PFX
-	       "mem  IO base address adjusted = 0x%p\n",
-	       qdev->mem_map_registers);
-	printk(KERN_INFO PFX "Interrupt number = %d\n", pdev->irq);
+	netdev_info(ndev, "mem  IO base address adjusted = 0x%p\n",
+		    qdev->mem_map_registers);
+	netdev_info(ndev, "Interrupt number = %d\n", pdev->irq);
 
-	if (netif_msg_probe(qdev))
-		printk(KERN_INFO PFX
-		       "%s: MAC address %pM\n",
-		       ndev->name, ndev->dev_addr);
+	netif_info(qdev, probe, ndev, "MAC address %pM\n", ndev->dev_addr);
 }
 
 static int ql_adapter_down(struct ql3_adapter *qdev, int do_reset)
@@ -3560,8 +3463,7 @@ static int ql_adapter_down(struct ql3_adapter *qdev, int do_reset)
 	free_irq(qdev->pdev->irq, ndev);
 
 	if (qdev->msi && test_bit(QL_MSI_ENABLED,&qdev->flags)) {
-		printk(KERN_INFO PFX
-		       "%s: calling pci_disable_msi().\n", qdev->ndev->name);
+		netdev_info(qdev->ndev, "calling pci_disable_msi()\n");
 		clear_bit(QL_MSI_ENABLED,&qdev->flags);
 		pci_disable_msi(qdev->pdev);
 	}
@@ -3577,16 +3479,14 @@ static int ql_adapter_down(struct ql3_adapter *qdev, int do_reset)
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 		if (ql_wait_for_drvr_lock(qdev)) {
 			if ((soft_reset = ql_adapter_reset(qdev))) {
-				printk(KERN_ERR PFX
-				       "%s: ql_adapter_reset(%d) FAILED!\n",
-				       ndev->name, qdev->index);
+				netdev_err(ndev, "ql_adapter_reset(%d) FAILED!\n",
+					   qdev->index);
 			}
-			printk(KERN_ERR PFX
-				"%s: Releaseing driver lock via chip reset.\n",ndev->name);
+			netdev_err(ndev,
+				   "Releasing driver lock via chip reset\n");
 		} else {
-			printk(KERN_ERR PFX
-			       "%s: Could not acquire driver lock to do "
-			       "reset!\n", ndev->name);
+			netdev_err(ndev,
+				   "Could not acquire driver lock to do reset!\n");
 			retval = -1;
 		}
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
@@ -3603,20 +3503,17 @@ static int ql_adapter_up(struct ql3_adapter *qdev)
 	unsigned long hw_flags;
 
 	if (ql_alloc_mem_resources(qdev)) {
-		printk(KERN_ERR PFX
-		       "%s Unable to  allocate buffers.\n", ndev->name);
+		netdev_err(ndev, "Unable to  allocate buffers\n");
 		return -ENOMEM;
 	}
 
 	if (qdev->msi) {
 		if (pci_enable_msi(qdev->pdev)) {
-			printk(KERN_ERR PFX
-			       "%s: User requested MSI, but MSI failed to "
-			       "initialize.  Continuing without MSI.\n",
-			       qdev->ndev->name);
+			netdev_err(ndev,
+				   "User requested MSI, but MSI failed to initialize.  Continuing without MSI.\n");
 			qdev->msi = 0;
 		} else {
-			printk(KERN_INFO PFX "%s: MSI Enabled...\n", qdev->ndev->name);
+			netdev_info(ndev, "MSI Enabled...\n");
 			set_bit(QL_MSI_ENABLED,&qdev->flags);
 			irq_flags &= ~IRQF_SHARED;
 		}
@@ -3625,9 +3522,9 @@ static int ql_adapter_up(struct ql3_adapter *qdev)
 	if ((err = request_irq(qdev->pdev->irq,
 			       ql3xxx_isr,
 			       irq_flags, ndev->name, ndev))) {
-		printk(KERN_ERR PFX
-		       "%s: Failed to reserve interrupt %d already in use.\n",
-		       ndev->name, qdev->pdev->irq);
+		netdev_err(ndev,
+			   "Failed to reserve interrupt %d already in use\n",
+			   qdev->pdev->irq);
 		goto err_irq;
 	}
 
@@ -3635,18 +3532,13 @@ static int ql_adapter_up(struct ql3_adapter *qdev)
 
 	if ((err = ql_wait_for_drvr_lock(qdev))) {
 		if ((err = ql_adapter_initialize(qdev))) {
-			printk(KERN_ERR PFX
-			       "%s: Unable to initialize adapter.\n",
-			       ndev->name);
+			netdev_err(ndev, "Unable to initialize adapter\n");
 			goto err_init;
 		}
-		printk(KERN_ERR PFX
-				"%s: Releaseing driver lock.\n",ndev->name);
+		netdev_err(ndev, "Releasing driver lock\n");
 		ql_sem_unlock(qdev, QL_DRVR_SEM_MASK);
 	} else {
-		printk(KERN_ERR PFX
-		       "%s: Could not acquire driver lock.\n",
-		       ndev->name);
+		netdev_err(ndev, "Could not acquire driver lock\n");
 		goto err_lock;
 	}
 
@@ -3667,9 +3559,7 @@ err_lock:
 	free_irq(qdev->pdev->irq, ndev);
 err_irq:
 	if (qdev->msi && test_bit(QL_MSI_ENABLED,&qdev->flags)) {
-		printk(KERN_INFO PFX
-		       "%s: calling pci_disable_msi().\n",
-		       qdev->ndev->name);
+		netdev_info(ndev, "calling pci_disable_msi()\n");
 		clear_bit(QL_MSI_ENABLED,&qdev->flags);
 		pci_disable_msi(qdev->pdev);
 	}
@@ -3679,9 +3569,8 @@ err_irq:
 static int ql_cycle_adapter(struct ql3_adapter *qdev, int reset)
 {
 	if( ql_adapter_down(qdev,reset) || ql_adapter_up(qdev)) {
-		printk(KERN_ERR PFX
-				"%s: Driver up/down cycle failed, "
-				"closing device\n",qdev->ndev->name);
+		netdev_err(qdev->ndev,
+			   "Driver up/down cycle failed, closing device\n");
 		rtnl_lock();
 		dev_close(qdev->ndev);
 		rtnl_unlock();
@@ -3750,7 +3639,7 @@ static void ql3xxx_tx_timeout(struct net_device *ndev)
 {
 	struct ql3_adapter *qdev = (struct ql3_adapter *)netdev_priv(ndev);
 
-	printk(KERN_ERR PFX "%s: Resetting...\n", ndev->name);
+	netdev_err(ndev, "Resetting...\n");
 	/*
 	 * Stop the queues, we've got a problem.
 	 */
@@ -3783,9 +3672,8 @@ static void ql_reset_work(struct work_struct *work)
 			int j;
 			tx_cb = &qdev->tx_buf[i];
 			if (tx_cb->skb) {
-				printk(KERN_DEBUG PFX
-				       "%s: Freeing lost SKB.\n",
-				       qdev->ndev->name);
+				netdev_printk(KERN_DEBUG, ndev,
+					      "Freeing lost SKB\n");
 				pci_unmap_single(qdev->pdev,
 					 dma_unmap_addr(&tx_cb->map[0], mapaddr),
 					 dma_unmap_len(&tx_cb->map[0], maplen),
@@ -3801,8 +3689,7 @@ static void ql_reset_work(struct work_struct *work)
 			}
 		}
 
-		printk(KERN_ERR PFX
-		       "%s: Clearing NRI after reset.\n", qdev->ndev->name);
+		netdev_err(ndev, "Clearing NRI after reset\n");
 		spin_lock_irqsave(&qdev->hw_lock, hw_flags);
 		ql_write_common_reg(qdev,
 				    &port_regs->CommonRegs.
@@ -3818,16 +3705,14 @@ static void ql_reset_work(struct work_struct *work)
 
 						   ispControlStatus);
 			if ((value & ISP_CONTROL_SR) == 0) {
-				printk(KERN_DEBUG PFX
-				       "%s: reset completed.\n",
-				       qdev->ndev->name);
+				netdev_printk(KERN_DEBUG, ndev,
+					      "reset completed\n");
 				break;
 			}
 
 			if (value & ISP_CONTROL_RI) {
-				printk(KERN_DEBUG PFX
-				       "%s: clearing NRI after reset.\n",
-				       qdev->ndev->name);
+				netdev_printk(KERN_DEBUG, ndev,
+					      "clearing NRI after reset\n");
 				ql_write_common_reg(qdev,
 						    &port_regs->
 						    CommonRegs.
@@ -3848,11 +3733,9 @@ static void ql_reset_work(struct work_struct *work)
 			 * Set the reset flags and clear the board again.
 			 * Nothing else to do...
 			 */
-			printk(KERN_ERR PFX
-			       "%s: Timed out waiting for reset to "
-			       "complete.\n", ndev->name);
-			printk(KERN_ERR PFX
-			       "%s: Do a reset.\n", ndev->name);
+			netdev_err(ndev,
+				   "Timed out waiting for reset to complete\n");
+			netdev_err(ndev, "Do a reset\n");
 			clear_bit(QL_RESET_PER_SCSI,&qdev->flags);
 			clear_bit(QL_RESET_START,&qdev->flags);
 			ql_cycle_adapter(qdev,QL_DO_RESET);
@@ -3920,15 +3803,13 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX "%s cannot enable PCI device\n",
-		       pci_name(pdev));
+		pr_err("%s cannot enable PCI device\n", pci_name(pdev));
 		goto err_out;
 	}
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
-		printk(KERN_ERR PFX "%s cannot obtain PCI resources\n",
-		       pci_name(pdev));
+		pr_err("%s cannot obtain PCI resources\n", pci_name(pdev));
 		goto err_out_disable_pdev;
 	}
 
@@ -3943,15 +3824,13 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	}
 
 	if (err) {
-		printk(KERN_ERR PFX "%s no usable DMA configuration\n",
-		       pci_name(pdev));
+		pr_err("%s no usable DMA configuration\n", pci_name(pdev));
 		goto err_out_free_regions;
 	}
 
 	ndev = alloc_etherdev(sizeof(struct ql3_adapter));
 	if (!ndev) {
-		printk(KERN_ERR PFX "%s could not alloc etherdev\n",
-		       pci_name(pdev));
+		pr_err("%s could not alloc etherdev\n", pci_name(pdev));
 		err = -ENOMEM;
 		goto err_out_free_regions;
 	}
@@ -3978,8 +3857,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	qdev->mem_map_registers = pci_ioremap_bar(pdev, 1);
 	if (!qdev->mem_map_registers) {
-		printk(KERN_ERR PFX "%s: cannot map device registers\n",
-		       pci_name(pdev));
+		pr_err("%s: cannot map device registers\n", pci_name(pdev));
 		err = -EIO;
 		goto err_out_free_ndev;
 	}
@@ -3998,9 +3876,8 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	/* make sure the EEPROM is good */
 	if (ql_get_nvram_params(qdev)) {
-		printk(KERN_ALERT PFX
-		       "ql3xxx_probe: Adapter #%d, Invalid NVRAM parameters.\n",
-		       qdev->index);
+		pr_alert("%s: Adapter #%d, Invalid NVRAM parameters\n",
+			 __func__, qdev->index);
 		err = -EIO;
 		goto err_out_iounmap;
 	}
@@ -4032,8 +3909,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 
 	err = register_netdev(ndev);
 	if (err) {
-		printk(KERN_ERR PFX "%s: cannot register net device\n",
-		       pci_name(pdev));
+		pr_err("%s: cannot register net device\n", pci_name(pdev));
 		goto err_out_iounmap;
 	}
 
@@ -4052,10 +3928,10 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	qdev->adapter_timer.expires = jiffies + HZ * 2;	/* two second delay */
 	qdev->adapter_timer.data = (unsigned long)qdev;
 
-	if(!cards_found) {
-		printk(KERN_ALERT PFX "%s\n", DRV_STRING);
-		printk(KERN_ALERT PFX "Driver name: %s, Version: %s.\n",
-	    	   DRV_NAME, DRV_VERSION);
+	if (!cards_found) {
+		pr_alert("%s\n", DRV_STRING);
+		pr_alert("Driver name: %s, Version: %s\n",
+			 DRV_NAME, DRV_VERSION);
 	}
 	ql_display_dev_info(ndev);
 
-- 
1.7.2
