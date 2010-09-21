From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: [RFC] skge: limit DMA to 32 bit
Date: Tue, 21 Sep 2010 09:15:19 +0200
Message-ID: <20100921071518.GA9081@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49456 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755739Ab0IUHOR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Sep 2010 03:14:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have old fedora bug report about not working skge device on some
Gigabyte motherboard:
https://bugzilla.redhat.com/show_bug.cgi?id=447489

In dmesg there are messages:

skge 0000:02:0b.0: PCI error cmd=0x7 status=0x22b0
skge 0000:02:0b.0: unable to clear error (so ignoring them)

Status value 0x22b0 include PCI_STATUS_REC_MASTER_ABORT bit set, what
mean that DMA transfer on PCI bus was aborted.

I provided to user modified driver with module parameter, that allow
to experiment with different dma_mask's. He told that maximum working 
dma_mask for him is 32 bits set.

Is 32bit DMA limit for every skge device acceptable patch?

Note, patch change possible driver DMA address space as below:
- 32bit     - no change, still low mem only (896MB)
- 32bit-PAE - down from 36bit to low mem (896MB)
- 64bit     - down from 64bit to 32bit

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index a8a6358..1a674e3 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3797,8 +3797,7 @@ static const struct net_device_ops skge_netdev_ops = {
 
 
 /* Initialize network device */
-static struct net_device *skge_devinit(struct skge_hw *hw, int port,
-				       int highmem)
+static struct net_device *skge_devinit(struct skge_hw *hw, int port)
 {
 	struct skge_port *skge;
 	struct net_device *dev = alloc_etherdev(sizeof(*skge));
@@ -3814,9 +3813,6 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	dev->watchdog_timeo = TX_WATCHDOG;
 	dev->irq = hw->pdev->irq;
 
-	if (highmem)
-		dev->features |= NETIF_F_HIGHDMA;
-
 	skge = netdev_priv(dev);
 	netif_napi_add(dev, &skge->napi, skge_poll, NAPI_WEIGHT);
 	skge->netdev = dev;
@@ -3874,7 +3870,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 {
 	struct net_device *dev, *dev1;
 	struct skge_hw *hw;
-	int err, using_dac = 0;
+	int err;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -3890,13 +3886,9 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 
 	pci_set_master(pdev);
 
-	if (!pci_set_dma_mask(pdev, DMA_BIT_MASK(64))) {
-		using_dac = 1;
-		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
-	} else if (!(err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32)))) {
-		using_dac = 0;
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+	if (!err)
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
-	}
 
 	if (err) {
 		dev_err(&pdev->dev, "no usable DMA configuration\n");
@@ -3944,7 +3936,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 		(unsigned long long)pci_resource_start(pdev, 0), pdev->irq,
 		skge_board_name(hw), hw->chip_rev);
 
-	dev = skge_devinit(hw, 0, using_dac);
+	dev = skge_devinit(hw, 0);
 	if (!dev)
 		goto err_out_led_off;
 
@@ -3967,7 +3959,7 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	skge_show_addr(dev);
 
 	if (hw->ports > 1) {
-		dev1 = skge_devinit(hw, 1, using_dac);
+		dev1 = skge_devinit(hw, 1);
 		if (dev1 && register_netdev(dev1) == 0)
 			skge_show_addr(dev1);
 		else {
