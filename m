From: Chris Snook <csnook@redhat.com>
Subject: [PATCH 2/2] atl1: wrap problematic optimizations in CONFIG_ATL1_EXPERIMENTAL
Date: Fri, 7 Sep 2007 19:52:09 -0400
Message-ID: <20070907235209.GB12055@shell.boston.redhat.com>
References: <46E1E1AC.5030801@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: atl1-devel@lists.sourceforge.net,
	Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751565AbXIGXwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 19:52:15 -0400
Content-Disposition: inline
In-Reply-To: <46E1E1AC.5030801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Snook <csnook@redhat.com>

Make certain problematic optimizations build-time configurable.

Signed-off-by: Chris Snook <csnook@redhat.com>
Acked-by: Jay Cliburn <jacliburn@bellsouth.net>

--- a/drivers/net/atl1/atl1_main.c	2007-09-04 10:12:38.000000000 -0400
+++ b/drivers/net/atl1/atl1_main.c	2007-09-04 11:23:26.000000000 -0400
@@ -2203,22 +2203,26 @@ static int __devinit atl1_probe(struct p
 	struct net_device *netdev;
 	struct atl1_adapter *adapter;
 	static int cards_found = 0;
-	bool pci_using_64 = true;
+	bool pci_using_64 = false;
 	int err;
 
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
 
+#ifdef CONFIG_ATL1_EXPERIMENTAL
 	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	if (!err) {
+		pci_using_64 = true;
+		goto dma_ok;
+	}
+#endif /* CONFIG_ATL1_EXPERIMENTAL */
+	err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 	if (err) {
-		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
-		if (err) {
-			dev_err(&pdev->dev, "no usable DMA configuration\n");
-			goto err_dma;
-		}
-		pci_using_64 = false;
+		dev_err(&pdev->dev, "no usable DMA configuration\n");
+		goto err_dma;
 	}
+dma_ok:
 	/* Mark all PCI regions associated with PCI device
 	 * pdev as being reserved by owner atl1_driver_name
 	 */
@@ -2294,11 +2298,13 @@ static int __devinit atl1_probe(struct p
 	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 
 	/*
-	 * FIXME - Until tso performance gets fixed, disable the feature.
+	 * TSO currently has performance problems,
+	 * so let's disable it by default.
 	 * Enable it with ethtool -K if desired.
 	 */
-	/* netdev->features |= NETIF_F_TSO; */
-
+#ifdef CONFIG_ATL1_EXPERIMENTAL
+	netdev->features |= NETIF_F_TSO;
+#endif
 	if (pci_using_64)
 		netdev->features |= NETIF_F_HIGHDMA;
 
