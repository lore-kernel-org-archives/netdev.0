From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] skge: request IRQ on activating the interface
Date: Tue, 22 Sep 2009 14:01:31 +0200
Message-ID: <20090922120127.14242.71353.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52599 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754477AbZIVL4w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2009 07:56:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skge requests IRQ in its probe function. This causes a problem in
the following real-life scenario with two different NICs in the machine:

1. modprobe skge
   The card is detected as eth0 and requests IRQ 17. Directory
   /proc/irq/17/eth0 is created.
2. There is an udev rule which says this interface should be called
   eth1, so udev renames eth0 -> eth1.
3. modprobe 8139too
   The Realtek card is detected as eth0. It will be using IRQ 17 too.
4. ip link set eth0 up
   Now 8139too requests IRQ 17.

The result is:
WARNING: at fs/proc/generic.c:590 proc_register ...
proc_dir_entry '17/eth0' already registered
...

And "ls /proc/irq/17" shows two subdirectories, both called eth0.

Fix it by requesting the IRQ in skge when the interface is activated.
This works, because interfaces can be renamed only while they are down.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---

 drivers/net/skge.c |   27 +++++++++++++++------------
 1 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 62e852e..7e90f27 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -105,6 +105,7 @@ static void yukon_init(struct skge_hw *hw, int port);
 static void genesis_mac_init(struct skge_hw *hw, int port);
 static void genesis_link_up(struct skge_port *skge);
 static void skge_set_multicast(struct net_device *dev);
+static irqreturn_t skge_intr(int irq, void *dev_id);
 
 /* Avoid conditionals by using array */
 static const int txqaddr[] = { Q_XA1, Q_XA2 };
@@ -2572,18 +2573,26 @@ static int skge_up(struct net_device *dev)
 	if (netif_msg_ifup(skge))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 
+	err = request_irq(dev->irq, skge_intr, IRQF_SHARED, dev->name, hw);
+	if (err) {
+		dev_err(&hw->pdev->dev, "%s: cannot assign irq %d\n",
+			dev->name, dev->irq);
+		return err;
+	}
+
 	if (dev->mtu > RX_BUF_SIZE)
 		skge->rx_buf_size = dev->mtu + ETH_HLEN;
 	else
 		skge->rx_buf_size = RX_BUF_SIZE;
 
-
 	rx_size = skge->rx_ring.count * sizeof(struct skge_rx_desc);
 	tx_size = skge->tx_ring.count * sizeof(struct skge_tx_desc);
 	skge->mem_size = tx_size + rx_size;
 	skge->mem = pci_alloc_consistent(hw->pdev, skge->mem_size, &skge->dma);
-	if (!skge->mem)
-		return -ENOMEM;
+	if (!skge->mem) {
+		err = -ENOMEM;
+		goto free_irq;
+	}
 
 	BUG_ON(skge->dma & 7);
 
@@ -2646,6 +2655,8 @@ static int skge_up(struct net_device *dev)
  free_pci_mem:
 	pci_free_consistent(hw->pdev, skge->mem_size, skge->mem, skge->dma);
 	skge->mem = NULL;
+ free_irq:
+	free_irq(dev->irq, hw);
 
 	return err;
 }
@@ -2733,6 +2744,7 @@ static int skge_down(struct net_device *dev)
 	kfree(skge->tx_ring.start);
 	pci_free_consistent(hw->pdev, skge->mem_size, skge->mem, skge->dma);
 	skge->mem = NULL;
+	free_irq(dev->irq, hw);
 	return 0;
 }
 
@@ -3974,12 +3986,6 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 		goto err_out_free_netdev;
 	}
 
-	err = request_irq(pdev->irq, skge_intr, IRQF_SHARED, dev->name, hw);
-	if (err) {
-		dev_err(&pdev->dev, "%s: cannot assign irq %d\n",
-		       dev->name, pdev->irq);
-		goto err_out_unregister;
-	}
 	skge_show_addr(dev);
 
 	if (hw->ports > 1 && (dev1 = skge_devinit(hw, 1, using_dac))) {
@@ -3996,8 +4002,6 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 
 	return 0;
 
-err_out_unregister:
-	unregister_netdev(dev);
 err_out_free_netdev:
 	free_netdev(dev);
 err_out_led_off:
@@ -4041,7 +4045,6 @@ static void __devexit skge_remove(struct pci_dev *pdev)
 	skge_write16(hw, B0_LED, LED_STAT_OFF);
 	skge_write8(hw, B0_CTST, CS_RST_SET);
 
-	free_irq(pdev->irq, hw);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 	if (dev1)

