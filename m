From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/20][BNX2]: Fix race conditions when calling
 register_netdev().
Date: Tue, 01 May 2007 18:14:07 -0700
Message-ID: <1178068447.4820.40.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1949 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161717AbXEBA1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 20:27:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix race conditions when calling register_netdev().
    
Hot-plug scripts can call bnx2_open() as soon as register_netdev() is
called in bnx2_init_one().  We need to call pci_set_drvdata() and
setup everything before calling register_netdev(). netif_carrier_off()
also needs to be moved to bnx2_open() to avoid race conditions with
the irq.
    
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index dba4088..971607c 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4350,6 +4350,8 @@ bnx2_open(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	int rc;
 
+	netif_carrier_off(dev);
+
 	bnx2_set_power_state(bp, PCI_D0);
 	bnx2_disable_int(bp);
 
@@ -6195,6 +6197,18 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->poll_controller = poll_bnx2;
 #endif
 
+	pci_set_drvdata(pdev, dev);
+
+	memcpy(dev->dev_addr, bp->mac_addr, 6);
+	memcpy(dev->perm_addr, bp->mac_addr, 6);
+	bp->name = board_info[ent->driver_data].name;
+
+	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
+#ifdef BCM_VLAN
+	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+#endif
+	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
+
 	if ((rc = register_netdev(dev))) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
 		if (bp->regview)
@@ -6206,11 +6220,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return rc;
 	}
 
-	pci_set_drvdata(pdev, dev);
-
-	memcpy(dev->dev_addr, bp->mac_addr, 6);
-	memcpy(dev->perm_addr, bp->mac_addr, 6);
-	bp->name = board_info[ent->driver_data].name,
 	printk(KERN_INFO "%s: %s (%c%d) PCI%s %s %dMHz found at mem %lx, "
 		"IRQ %d, ",
 		dev->name,
@@ -6228,15 +6237,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		printk("%2.2x", dev->dev_addr[i]);
 	printk("\n");
 
-	dev->features |= NETIF_F_SG;
-	dev->features |= NETIF_F_IP_CSUM;
-#ifdef BCM_VLAN
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-#endif
-	dev->features |= NETIF_F_TSO | NETIF_F_TSO_ECN;
-
-	netif_carrier_off(bp->dev);
-
 	return 0;
 }
 


