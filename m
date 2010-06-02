From: Joe Perches <joe@perches.com>
Subject: [net-next PATCH] drivers/net/enic: Use (pr|netdev)_<level> macro
 helpers
Date: Wed, 02 Jun 2010 08:30:16 -0700
Message-ID: <1275492616.2489.20.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Compile tested only

Add #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove #define PFX
Use pr_<level>
Use netdev_<level>
Remove trailing periods from most formats

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/enic/enic.h      |    1 -
 drivers/net/enic/enic_main.c |  120 ++++++++++++++++++------------------------
 drivers/net/enic/enic_res.c  |   51 +++++++++---------
 drivers/net/enic/vnic_cq.c   |    2 +-
 drivers/net/enic/vnic_dev.c  |   37 ++++++-------
 drivers/net/enic/vnic_intr.c |    5 +-
 drivers/net/enic/vnic_rq.c   |    8 ++-
 drivers/net/enic/vnic_wq.c   |    8 ++-
 8 files changed, 108 insertions(+), 124 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 85f2a2e..4277975 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -36,7 +36,6 @@
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
 #define DRV_VERSION		"1.3.1.1-pp"
 #define DRV_COPYRIGHT		"Copyright 2008-2009 Cisco Systems, Inc"
-#define PFX			DRV_NAME ": "
 
 #define ENIC_LRO_MAX_DESC	8
 #define ENIC_LRO_MAX_AGGR	64
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 6586b5c..8b3f300 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -17,6 +17,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -399,15 +401,15 @@ static void enic_log_q_error(struct enic *enic)
 	for (i = 0; i < enic->wq_count; i++) {
 		error_status = vnic_wq_error_status(&enic->wq[i]);
 		if (error_status)
-			printk(KERN_ERR PFX "%s: WQ[%d] error_status %d\n",
-				enic->netdev->name, i, error_status);
+			netdev_err(enic->netdev, "WQ[%d] error_status %d\n",
+				   i, error_status);
 	}
 
 	for (i = 0; i < enic->rq_count; i++) {
 		error_status = vnic_rq_error_status(&enic->rq[i]);
 		if (error_status)
-			printk(KERN_ERR PFX "%s: RQ[%d] error_status %d\n",
-				enic->netdev->name, i, error_status);
+			netdev_err(enic->netdev, "RQ[%d] error_status %d\n",
+				   i, error_status);
 	}
 }
 
@@ -417,10 +419,10 @@ static void enic_link_check(struct enic *enic)
 	int carrier_ok = netif_carrier_ok(enic->netdev);
 
 	if (link_status && !carrier_ok) {
-		printk(KERN_INFO PFX "%s: Link UP\n", enic->netdev->name);
+		netdev_info(enic->netdev, "Link UP\n");
 		netif_carrier_on(enic->netdev);
 	} else if (!link_status && carrier_ok) {
-		printk(KERN_INFO PFX "%s: Link DOWN\n", enic->netdev->name);
+		netdev_info(enic->netdev, "Link DOWN\n");
 		netif_carrier_off(enic->netdev);
 	}
 }
@@ -432,10 +434,10 @@ static void enic_mtu_check(struct enic *enic)
 	if (mtu && mtu != enic->port_mtu) {
 		enic->port_mtu = mtu;
 		if (mtu < enic->netdev->mtu)
-			printk(KERN_WARNING PFX
-				"%s: interface MTU (%d) set higher "
-				"than switch port MTU (%d)\n",
-				enic->netdev->name, enic->netdev->mtu, mtu);
+			netdev_warn(enic->netdev,
+				    "interface MTU (%d) set higher "
+				    "than switch port MTU (%d)\n",
+				    enic->netdev->mtu, mtu);
 	}
 }
 
@@ -444,8 +446,8 @@ static void enic_msglvl_check(struct enic *enic)
 	u32 msg_enable = vnic_dev_msg_lvl(enic->vdev);
 
 	if (msg_enable != enic->msg_enable) {
-		printk(KERN_INFO PFX "%s: msg lvl changed from 0x%x to 0x%x\n",
-			enic->netdev->name, enic->msg_enable, msg_enable);
+		netdev_info(enic->netdev, "msg lvl changed from 0x%x to 0x%x\n",
+			    enic->msg_enable, msg_enable);
 		enic->msg_enable = msg_enable;
 	}
 }
@@ -769,8 +771,7 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
 	    skb_shinfo(skb)->nr_frags + ENIC_DESC_MAX_SPLITS) {
 		netif_stop_queue(netdev);
 		/* This is a hard error, log it */
-		printk(KERN_ERR PFX "%s: BUG! Tx ring full when "
-			"queue awake!\n", netdev->name);
+		netdev_err(netdev, "BUG! Tx ring full when queue awake!\n");
 		spin_unlock_irqrestore(&enic->wq_lock[0], flags);
 		return NETDEV_TX_BUSY;
 	}
@@ -1703,16 +1704,13 @@ static int enic_open(struct net_device *netdev)
 
 	err = enic_request_intr(enic);
 	if (err) {
-		printk(KERN_ERR PFX "%s: Unable to request irq.\n",
-			netdev->name);
+		netdev_err(netdev, "Unable to request irq\n");
 		return err;
 	}
 
 	err = enic_notify_set(enic);
 	if (err) {
-		printk(KERN_ERR PFX
-			"%s: Failed to alloc notify buffer, aborting.\n",
-			netdev->name);
+		netdev_err(netdev, "Failed to alloc notify buffer, aborting\n");
 		goto err_out_free_intr;
 	}
 
@@ -1720,9 +1718,7 @@ static int enic_open(struct net_device *netdev)
 		vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
 		/* Need at least one buffer on ring to get going */
 		if (vnic_rq_desc_used(&enic->rq[i]) == 0) {
-			printk(KERN_ERR PFX
-				"%s: Unable to alloc receive buffers.\n",
-				netdev->name);
+			netdev_err(netdev, "Unable to alloc receive buffers\n");
 			err = -ENOMEM;
 			goto err_out_notify_unset;
 		}
@@ -1824,10 +1820,9 @@ static int enic_change_mtu(struct net_device *netdev, int new_mtu)
 	netdev->mtu = new_mtu;
 
 	if (netdev->mtu > enic->port_mtu)
-		printk(KERN_WARNING PFX
-			"%s: interface MTU (%d) set higher "
-			"than port MTU (%d)\n",
-			netdev->name, netdev->mtu, enic->port_mtu);
+		netdev_warn(netdev,
+			    "interface MTU (%d) set higher than port MTU (%d)\n",
+			    netdev->mtu, enic->port_mtu);
 
 	if (running)
 		enic_open(netdev);
@@ -1900,8 +1895,8 @@ static int enic_dev_open(struct enic *enic)
 	err = enic_dev_wait(enic->vdev, vnic_dev_open,
 		vnic_dev_open_done, 0);
 	if (err)
-		printk(KERN_ERR PFX
-			"vNIC device open failed, err %d.\n", err);
+		netdev_err(enic->netdev, "vNIC device open failed, err %d\n",
+			   err);
 
 	return err;
 }
@@ -1913,8 +1908,8 @@ static int enic_dev_soft_reset(struct enic *enic)
 	err = enic_dev_wait(enic->vdev, vnic_dev_soft_reset,
 		vnic_dev_soft_reset_done, 0);
 	if (err)
-		printk(KERN_ERR PFX
-			"vNIC soft reset failed, err %d.\n", err);
+		netdev_err(enic->netdev, "vNIC soft reset failed, err %d\n",
+			   err);
 
 	return err;
 }
@@ -2122,8 +2117,7 @@ int enic_dev_init(struct enic *enic)
 
 	err = enic_get_vnic_config(enic);
 	if (err) {
-		printk(KERN_ERR PFX
-			"Get vNIC configuration failed, aborting.\n");
+		netdev_err(netdev, "Get vNIC configuration failed, aborting\n");
 		return err;
 	}
 
@@ -2138,9 +2132,9 @@ int enic_dev_init(struct enic *enic)
 
 	err = enic_set_intr_mode(enic);
 	if (err) {
-		printk(KERN_ERR PFX
-			"Failed to set intr mode based on resource "
-			"counts and system capabilities, aborting.\n");
+		netdev_err(netdev,
+			   "Failed to set intr mode based on resource "
+			   "counts and system capabilities, aborting\n");
 		return err;
 	}
 
@@ -2149,8 +2143,7 @@ int enic_dev_init(struct enic *enic)
 
 	err = enic_alloc_vnic_resources(enic);
 	if (err) {
-		printk(KERN_ERR PFX
-			"Failed to alloc vNIC resources, aborting.\n");
+		netdev_err(netdev, "Failed to alloc vNIC resources, aborting\n");
 		goto err_out_free_vnic_resources;
 	}
 
@@ -2158,15 +2151,13 @@ int enic_dev_init(struct enic *enic)
 
 	err = enic_set_rq_alloc_buf(enic);
 	if (err) {
-		printk(KERN_ERR PFX
-			"Failed to set RQ buffer allocator, aborting.\n");
+		netdev_err(netdev, "Failed to set RQ buffer allocator, aborting\n");
 		goto err_out_free_vnic_resources;
 	}
 
 	err = enic_set_niccfg(enic);
 	if (err) {
-		printk(KERN_ERR PFX
-			"Failed to config nic, aborting.\n");
+		netdev_err(netdev, "Failed to config nic, aborting\n");
 		goto err_out_free_vnic_resources;
 	}
 
@@ -2212,7 +2203,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	netdev = alloc_etherdev(sizeof(struct enic));
 	if (!netdev) {
-		printk(KERN_ERR PFX "Etherdev alloc failed, aborting.\n");
+		pr_err("Etherdev alloc failed, aborting\n");
 		return -ENOMEM;
 	}
 
@@ -2229,15 +2220,13 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX
-			"Cannot enable PCI device, aborting.\n");
+		netdev_err(netdev, "Cannot enable PCI device, aborting\n");
 		goto err_out_free_netdev;
 	}
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
-		printk(KERN_ERR PFX
-			"Cannot request PCI regions, aborting.\n");
+		netdev_err(netdev, "Cannot request PCI regions, aborting\n");
 		goto err_out_disable_device;
 	}
 
@@ -2252,23 +2241,23 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	if (err) {
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
-			printk(KERN_ERR PFX
-				"No usable DMA configuration, aborting.\n");
+			netdev_err(netdev,
+				   "No usable DMA configuration, aborting\n");
 			goto err_out_release_regions;
 		}
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (err) {
-			printk(KERN_ERR PFX
-				"Unable to obtain 32-bit DMA "
-				"for consistent allocations, aborting.\n");
+			netdev_err(netdev,
+				   "Unable to obtain %u-bit DMA for consistent allocations, aborting\n",
+				   32);
 			goto err_out_release_regions;
 		}
 	} else {
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(40));
 		if (err) {
-			printk(KERN_ERR PFX
-				"Unable to obtain 40-bit DMA "
-				"for consistent allocations, aborting.\n");
+			netdev_err(netdev,
+				   "Unable to obtain %u-bit DMA for consistent allocations, aborting\n",
+				   40);
 			goto err_out_release_regions;
 		}
 		using_dac = 1;
@@ -2283,8 +2272,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		enic->bar[i].len = pci_resource_len(pdev, i);
 		enic->bar[i].vaddr = pci_iomap(pdev, i, enic->bar[i].len);
 		if (!enic->bar[i].vaddr) {
-			printk(KERN_ERR PFX
-				"Cannot memory-map BAR %d, aborting.\n", i);
+			netdev_err(netdev, "Cannot memory-map BAR %d, aborting\n", i);
 			err = -ENODEV;
 			goto err_out_iounmap;
 		}
@@ -2297,8 +2285,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	enic->vdev = vnic_dev_register(NULL, enic, pdev, enic->bar,
 		ARRAY_SIZE(enic->bar));
 	if (!enic->vdev) {
-		printk(KERN_ERR PFX
-			"vNIC registration failed, aborting.\n");
+		netdev_err(netdev, "vNIC registration failed, aborting\n");
 		err = -ENODEV;
 		goto err_out_iounmap;
 	}
@@ -2308,8 +2295,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	err = enic_dev_open(enic);
 	if (err) {
-		printk(KERN_ERR PFX
-			"vNIC dev open failed, aborting.\n");
+		netdev_err(netdev, "vNIC dev open failed, aborting\n");
 		goto err_out_vnic_unregister;
 	}
 
@@ -2326,16 +2312,14 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	if (!enic_is_dynamic(enic)) {
 		err = vnic_dev_init(enic->vdev, 0);
 		if (err) {
-			printk(KERN_ERR PFX
-				"vNIC dev init failed, aborting.\n");
+			netdev_err(netdev, "vNIC dev init failed, aborting\n");
 			goto err_out_dev_close;
 		}
 	}
 
 	err = enic_dev_init(enic);
 	if (err) {
-		printk(KERN_ERR PFX
-			"Device initialization failed, aborting.\n");
+		netdev_err(netdev, "Device initialization failed, aborting\n");
 		goto err_out_dev_close;
 	}
 
@@ -2361,8 +2345,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	err = enic_set_mac_addr(netdev, enic->mac_addr);
 	if (err) {
-		printk(KERN_ERR PFX
-			"Invalid MAC address, aborting.\n");
+		netdev_err(netdev, "Invalid MAC address, aborting\n");
 		goto err_out_dev_deinit;
 	}
 
@@ -2401,8 +2384,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 
 	err = register_netdev(netdev);
 	if (err) {
-		printk(KERN_ERR PFX
-			"Cannot register net device, aborting.\n");
+		netdev_err(netdev, "Cannot register net device, aborting\n");
 		goto err_out_dev_deinit;
 	}
 
@@ -2456,7 +2438,7 @@ static struct pci_driver enic_driver = {
 
 static int __init enic_init_module(void)
 {
-	printk(KERN_INFO PFX "%s, ver %s\n", DRV_DESCRIPTION, DRV_VERSION);
+	pr_info("%s, ver %s\n", DRV_DESCRIPTION, DRV_VERSION);
 
 	return pci_register_driver(&enic_driver);
 }
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index 9b18840..b69a016 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -46,7 +46,7 @@ int enic_get_vnic_config(struct enic *enic)
 
 	err = vnic_dev_mac_addr(enic->vdev, enic->mac_addr);
 	if (err) {
-		printk(KERN_ERR PFX "Error getting MAC addr, %d\n", err);
+		netdev_err(enic->netdev, "Error getting MAC addr, %d\n", err);
 		return err;
 	}
 
@@ -56,8 +56,8 @@ int enic_get_vnic_config(struct enic *enic)
 			offsetof(struct vnic_enet_config, m), \
 			sizeof(c->m), &c->m); \
 		if (err) { \
-			printk(KERN_ERR PFX \
-				"Error getting %s, %d\n", #m, err); \
+			netdev_err(enic->netdev, \
+				   "Error getting %s, %d\n", #m, err);	\
 			return err; \
 		} \
 	} while (0)
@@ -92,13 +92,13 @@ int enic_get_vnic_config(struct enic *enic)
 		INTR_COALESCE_HW_TO_USEC(VNIC_INTR_TIMER_MAX),
 		c->intr_timer_usec);
 
-	printk(KERN_INFO PFX "vNIC MAC addr %pM wq/rq %d/%d\n",
-		enic->mac_addr, c->wq_desc_count, c->rq_desc_count);
-	printk(KERN_INFO PFX "vNIC mtu %d csum tx/rx %d/%d tso/lro %d/%d "
-		"intr timer %d usec\n",
-		c->mtu, ENIC_SETTING(enic, TXCSUM),
-		ENIC_SETTING(enic, RXCSUM), ENIC_SETTING(enic, TSO),
-		ENIC_SETTING(enic, LRO), c->intr_timer_usec);
+	netdev_info(enic->netdev, "vNIC MAC addr %pM wq/rq %d/%d\n",
+		    enic->mac_addr, c->wq_desc_count, c->rq_desc_count);
+	netdev_info(enic->netdev, "vNIC mtu %d csum tx/rx %d/%d tso/lro %d/%d "
+		    "intr timer %d usec\n",
+		    c->mtu, ENIC_SETTING(enic, TXCSUM),
+		    ENIC_SETTING(enic, RXCSUM), ENIC_SETTING(enic, TSO),
+		    ENIC_SETTING(enic, LRO), c->intr_timer_usec);
 
 	return 0;
 }
@@ -121,7 +121,7 @@ void enic_add_vlan(struct enic *enic, u16 vlanid)
 
 	err = vnic_dev_cmd(enic->vdev, CMD_VLAN_ADD, &a0, &a1, wait);
 	if (err)
-		printk(KERN_ERR PFX "Can't add vlan id, %d\n", err);
+		netdev_err(enic->netdev, "Can't add vlan id, %d\n", err);
 }
 
 void enic_del_vlan(struct enic *enic, u16 vlanid)
@@ -132,7 +132,7 @@ void enic_del_vlan(struct enic *enic, u16 vlanid)
 
 	err = vnic_dev_cmd(enic->vdev, CMD_VLAN_DEL, &a0, &a1, wait);
 	if (err)
-		printk(KERN_ERR PFX "Can't delete vlan id, %d\n", err);
+		netdev_err(enic->netdev, "Can't delete vlan id, %d\n", err);
 }
 
 int enic_set_nic_cfg(struct enic *enic, u8 rss_default_cpu, u8 rss_hash_type,
@@ -198,10 +198,10 @@ void enic_get_res_counts(struct enic *enic)
 		vnic_dev_get_res_count(enic->vdev, RES_TYPE_INTR_CTRL),
 		ENIC_INTR_MAX);
 
-	printk(KERN_INFO PFX "vNIC resources avail: "
-		"wq %d rq %d cq %d intr %d\n",
-		enic->wq_count, enic->rq_count,
-		enic->cq_count, enic->intr_count);
+	netdev_info(enic->netdev, "vNIC resources avail: "
+		    "wq %d rq %d cq %d intr %d\n",
+		    enic->wq_count, enic->rq_count,
+		    enic->cq_count, enic->intr_count);
 }
 
 void enic_init_vnic_resources(struct enic *enic)
@@ -319,15 +319,14 @@ int enic_alloc_vnic_resources(struct enic *enic)
 
 	intr_mode = vnic_dev_get_intr_mode(enic->vdev);
 
-	printk(KERN_INFO PFX "vNIC resources used:  "
-		"wq %d rq %d cq %d intr %d intr mode %s\n",
-		enic->wq_count, enic->rq_count,
-		enic->cq_count, enic->intr_count,
-		intr_mode == VNIC_DEV_INTR_MODE_INTX ? "legacy PCI INTx" :
-		intr_mode == VNIC_DEV_INTR_MODE_MSI ? "MSI" :
-		intr_mode == VNIC_DEV_INTR_MODE_MSIX ? "MSI-X" :
-		"unknown"
-		);
+	netdev_info(enic->netdev, "vNIC resources used:  "
+		    "wq %d rq %d cq %d intr %d intr mode %s\n",
+		    enic->wq_count, enic->rq_count,
+		    enic->cq_count, enic->intr_count,
+		    intr_mode == VNIC_DEV_INTR_MODE_INTX ? "legacy PCI INTx" :
+		    intr_mode == VNIC_DEV_INTR_MODE_MSI ? "MSI" :
+		    intr_mode == VNIC_DEV_INTR_MODE_MSIX ? "MSI-X" :
+		    "unknown");
 
 	/* Allocate queue resources
 	 */
@@ -373,7 +372,7 @@ int enic_alloc_vnic_resources(struct enic *enic)
 	enic->legacy_pba = vnic_dev_get_res(enic->vdev,
 		RES_TYPE_INTR_PBA_LEGACY, 0);
 	if (!enic->legacy_pba && intr_mode == VNIC_DEV_INTR_MODE_INTX) {
-		printk(KERN_ERR PFX "Failed to hook legacy pba resource\n");
+		netdev_err(enic->netdev, "Failed to hook legacy pba resource\n");
 		err = -ENODEV;
 		goto err_out_cleanup;
 	}
diff --git a/drivers/net/enic/vnic_cq.c b/drivers/net/enic/vnic_cq.c
index 020ae6c..326ea40 100644
--- a/drivers/net/enic/vnic_cq.c
+++ b/drivers/net/enic/vnic_cq.c
@@ -42,7 +42,7 @@ int vnic_cq_alloc(struct vnic_dev *vdev, struct vnic_cq *cq, unsigned int index,
 
 	cq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_CQ, index);
 	if (!cq->ctrl) {
-		printk(KERN_ERR "Failed to hook CQ[%d] resource\n", index);
+		pr_err("Failed to hook CQ[%d] resource\n", index);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index 2b3e16d..6a7fb71 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -17,6 +17,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -78,22 +80,22 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 		return -EINVAL;
 
 	if (bar->len < VNIC_MAX_RES_HDR_SIZE) {
-		printk(KERN_ERR "vNIC BAR0 res hdr length error\n");
+		pr_err("vNIC BAR0 res hdr length error\n");
 		return -EINVAL;
 	}
 
 	rh = bar->vaddr;
 	if (!rh) {
-		printk(KERN_ERR "vNIC BAR0 res hdr not mem-mapped\n");
+		pr_err("vNIC BAR0 res hdr not mem-mapped\n");
 		return -EINVAL;
 	}
 
 	if (ioread32(&rh->magic) != VNIC_RES_MAGIC ||
 	    ioread32(&rh->version) != VNIC_RES_VERSION) {
-		printk(KERN_ERR "vNIC BAR0 res magic/version error "
-			"exp (%lx/%lx) curr (%x/%x)\n",
-			VNIC_RES_MAGIC, VNIC_RES_VERSION,
-			ioread32(&rh->magic), ioread32(&rh->version));
+		pr_err("vNIC BAR0 res magic/version error "
+		       "exp (%lx/%lx) curr (%x/%x)\n",
+		       VNIC_RES_MAGIC, VNIC_RES_VERSION,
+		       ioread32(&rh->magic), ioread32(&rh->version));
 		return -EINVAL;
 	}
 
@@ -122,7 +124,7 @@ static int vnic_dev_discover_res(struct vnic_dev *vdev,
 			/* each count is stride bytes long */
 			len = count * VNIC_RES_STRIDE;
 			if (len + bar_offset > bar[bar_num].len) {
-				printk(KERN_ERR "vNIC BAR0 resource %d "
+				pr_err("vNIC BAR0 resource %d "
 					"out-of-bounds, offset 0x%x + "
 					"size 0x%x > bar len 0x%lx\n",
 					type, bar_offset,
@@ -229,8 +231,7 @@ int vnic_dev_alloc_desc_ring(struct vnic_dev *vdev, struct vnic_dev_ring *ring,
 		&ring->base_addr_unaligned);
 
 	if (!ring->descs_unaligned) {
-		printk(KERN_ERR
-		  "Failed to allocate ring (size=%d), aborting\n",
+		pr_err("Failed to allocate ring (size=%d), aborting\n",
 			(int)ring->size);
 		return -ENOMEM;
 	}
@@ -268,7 +269,7 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 
 	status = ioread32(&devcmd->status);
 	if (status & STAT_BUSY) {
-		printk(KERN_ERR "Busy devcmd %d\n", _CMD_N(cmd));
+		pr_err("Busy devcmd %d\n", _CMD_N(cmd));
 		return -EBUSY;
 	}
 
@@ -294,7 +295,7 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 				err = (int)readq(&devcmd->args[0]);
 				if (err != ERR_ECMDUNKNOWN ||
 				    cmd != CMD_CAPABILITY)
-					printk(KERN_ERR "Error %d devcmd %d\n",
+					pr_err("Error %d devcmd %d\n",
 						err, _CMD_N(cmd));
 				return err;
 			}
@@ -309,7 +310,7 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 		}
 	}
 
-	printk(KERN_ERR "Timedout devcmd %d\n", _CMD_N(cmd));
+	pr_err("Timedout devcmd %d\n", _CMD_N(cmd));
 	return -ETIMEDOUT;
 }
 
@@ -527,7 +528,7 @@ void vnic_dev_packet_filter(struct vnic_dev *vdev, int directed, int multicast,
 
 	err = vnic_dev_cmd(vdev, CMD_PACKET_FILTER, &a0, &a1, wait);
 	if (err)
-		printk(KERN_ERR "Can't set packet filter\n");
+		pr_err("Can't set packet filter\n");
 }
 
 int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
@@ -542,7 +543,7 @@ int vnic_dev_add_addr(struct vnic_dev *vdev, u8 *addr)
 
 	err = vnic_dev_cmd(vdev, CMD_ADDR_ADD, &a0, &a1, wait);
 	if (err)
-		printk(KERN_ERR "Can't add addr [%pM], %d\n", addr, err);
+		pr_err("Can't add addr [%pM], %d\n", addr, err);
 
 	return err;
 }
@@ -559,7 +560,7 @@ int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
 
 	err = vnic_dev_cmd(vdev, CMD_ADDR_DEL, &a0, &a1, wait);
 	if (err)
-		printk(KERN_ERR "Can't del addr [%pM], %d\n", addr, err);
+		pr_err("Can't del addr [%pM], %d\n", addr, err);
 
 	return err;
 }
@@ -572,8 +573,7 @@ int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr)
 
 	err = vnic_dev_cmd(vdev, CMD_IAR, &a0, &a1, wait);
 	if (err)
-		printk(KERN_ERR "Failed to raise INTR[%d], err %d\n",
-			intr, err);
+		pr_err("Failed to raise INTR[%d], err %d\n", intr, err);
 
 	return err;
 }
@@ -604,8 +604,7 @@ int vnic_dev_notify_set(struct vnic_dev *vdev, u16 intr)
 	dma_addr_t notify_pa;
 
 	if (vdev->notify || vdev->notify_pa) {
-		printk(KERN_ERR "notify block %p still allocated",
-			vdev->notify);
+		pr_err("notify block %p still allocated", vdev->notify);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/enic/vnic_intr.c b/drivers/net/enic/vnic_intr.c
index 3934309..617e744 100644
--- a/drivers/net/enic/vnic_intr.c
+++ b/drivers/net/enic/vnic_intr.c
@@ -17,6 +17,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -39,8 +41,7 @@ int vnic_intr_alloc(struct vnic_dev *vdev, struct vnic_intr *intr,
 
 	intr->ctrl = vnic_dev_get_res(vdev, RES_TYPE_INTR_CTRL, index);
 	if (!intr->ctrl) {
-		printk(KERN_ERR "Failed to hook INTR[%d].ctrl resource\n",
-			index);
+		pr_err("Failed to hook INTR[%d].ctrl resource\n", index);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/enic/vnic_rq.c b/drivers/net/enic/vnic_rq.c
index cc580cf..0e456a2 100644
--- a/drivers/net/enic/vnic_rq.c
+++ b/drivers/net/enic/vnic_rq.c
@@ -17,6 +17,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -39,7 +41,7 @@ static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
 	for (i = 0; i < blks; i++) {
 		rq->bufs[i] = kzalloc(VNIC_RQ_BUF_BLK_SZ, GFP_ATOMIC);
 		if (!rq->bufs[i]) {
-			printk(KERN_ERR "Failed to alloc rq_bufs\n");
+			pr_err("Failed to alloc rq_bufs\n");
 			return -ENOMEM;
 		}
 	}
@@ -94,7 +96,7 @@ int vnic_rq_alloc(struct vnic_dev *vdev, struct vnic_rq *rq, unsigned int index,
 
 	rq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_RQ, index);
 	if (!rq->ctrl) {
-		printk(KERN_ERR "Failed to hook RQ[%d] resource\n", index);
+		pr_err("Failed to hook RQ[%d] resource\n", index);
 		return -EINVAL;
 	}
 
@@ -174,7 +176,7 @@ int vnic_rq_disable(struct vnic_rq *rq)
 		udelay(10);
 	}
 
-	printk(KERN_ERR "Failed to disable RQ[%d]\n", rq->index);
+	pr_err("Failed to disable RQ[%d]\n", rq->index);
 
 	return -ETIMEDOUT;
 }
diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/enic/vnic_wq.c
index 1378afb..abf4c27 100644
--- a/drivers/net/enic/vnic_wq.c
+++ b/drivers/net/enic/vnic_wq.c
@@ -17,6 +17,8 @@
  *
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/types.h>
@@ -39,7 +41,7 @@ static int vnic_wq_alloc_bufs(struct vnic_wq *wq)
 	for (i = 0; i < blks; i++) {
 		wq->bufs[i] = kzalloc(VNIC_WQ_BUF_BLK_SZ, GFP_ATOMIC);
 		if (!wq->bufs[i]) {
-			printk(KERN_ERR "Failed to alloc wq_bufs\n");
+			pr_err("Failed to alloc wq_bufs\n");
 			return -ENOMEM;
 		}
 	}
@@ -94,7 +96,7 @@ int vnic_wq_alloc(struct vnic_dev *vdev, struct vnic_wq *wq, unsigned int index,
 
 	wq->ctrl = vnic_dev_get_res(vdev, RES_TYPE_WQ, index);
 	if (!wq->ctrl) {
-		printk(KERN_ERR "Failed to hook WQ[%d] resource\n", index);
+		pr_err("Failed to hook WQ[%d] resource\n", index);
 		return -EINVAL;
 	}
 
@@ -167,7 +169,7 @@ int vnic_wq_disable(struct vnic_wq *wq)
 		udelay(10);
 	}
 
-	printk(KERN_ERR "Failed to disable WQ[%d]\n", wq->index);
+	pr_err("Failed to disable WQ[%d]\n", wq->index);
 
 	return -ETIMEDOUT;
 }
