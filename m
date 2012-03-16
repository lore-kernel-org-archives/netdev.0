From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/1] eni: fix driver remove function and driver probe error path.
Date: Fri, 16 Mar 2012 12:52:04 +0100
Message-ID: <20120316115204.GA2028@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54633 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1032706Ab2CPLxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2012 07:53:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- add eni_do_release() to balance eni_do_init
- turn the zeroes DMA area into a per device data

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/atm/eni.c |   98 ++++++++++++++++++++++++++++++++++-------------------
 drivers/atm/eni.h |    5 +++
 2 files changed, 68 insertions(+), 35 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 485a11a6..6ff612d 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -156,9 +156,6 @@ static int tx_complete = 0,dma_complete = 0,queued = 0,requeued = 0,
 
 static struct atm_dev *eni_boards = NULL;
 
-static u32 *cpu_zeroes = NULL; /* aligned "magic" zeroes */
-static dma_addr_t zeroes;
-
 /* Read/write registers on card */
 #define eni_in(r)	readl(eni_dev->reg+(r)*4)
 #define eni_out(v,r)	writel((v),eni_dev->reg+(r)*4)
@@ -1138,8 +1135,10 @@ DPRINTK("doing direct send\n"); /* @@@ well, this doesn't work anyway */
 					skb_shinfo(skb)->frags[i].page_offset,
 				    skb_frag_size(&skb_shinfo(skb)->frags[i]));
 	}
-	if (skb->len & 3)
-		put_dma(tx->index,eni_dev->dma,&j,zeroes,4-(skb->len & 3));
+	if (skb->len & 3) {
+		put_dma(tx->index, eni_dev->dma, &j, eni_dev->zero.dma,
+			4 - (skb->len & 3));
+	}
 	/* JK for AAL5 trailer - AAL0 doesn't need it, but who cares ... */
 	eni_dev->dma[j++] = (((tx->tx_pos+size) & (tx->words-1)) <<
 	     MID_DMA_COUNT_SHIFT) | (tx->index << MID_DMA_CHAN_SHIFT) |
@@ -1728,6 +1727,7 @@ static int __devinit eni_do_init(struct atm_dev *dev)
 		    "mapping\n",dev->number);
 		return error;
 	}
+	eni_dev->ioaddr = base;
 	eni_dev->base_diff = real_base - (unsigned long) base;
 	/* id may not be present in ASIC Tonga boards - check this @@@ */
 	if (!eni_dev->asic) {
@@ -1789,6 +1789,14 @@ unmap:
 	goto out;
 }
 
+static void eni_do_release(struct atm_dev *dev)
+{
+	struct eni_dev *ed = ENI_DEV(dev);
+
+	dev->phy->stop(dev);
+	dev->phy = NULL;
+	iounmap(ed->ioaddr);
+}
 
 static int __devinit eni_start(struct atm_dev *dev)
 {
@@ -2220,48 +2228,60 @@ static const struct atmdev_ops ops = {
 
 
 static int __devinit eni_init_one(struct pci_dev *pci_dev,
-    const struct pci_device_id *ent)
+				  const struct pci_device_id *ent)
 {
 	struct atm_dev *dev;
 	struct eni_dev *eni_dev;
-	int error = -ENOMEM;
+	struct eni_zero *zero;
+	int rc;
+
+	rc = pci_enable_device(pci_dev);
+	if (rc < 0)
+		goto out;
 
-	DPRINTK("eni_init_one\n");
+	rc = -ENOMEM;
+	eni_dev = kmalloc(sizeof(struct eni_dev), GFP_KERNEL);
+	if (!eni_dev)
+		goto err_disable;
 
-	if (pci_enable_device(pci_dev)) {
-		error = -EIO;
-		goto out0;
-	}
+	zero = &eni_dev->zero;
+	zero->addr = pci_alloc_consistent(pci_dev, ENI_ZEROES_SIZE, &zero->dma);
+	if (!zero->addr)
+		goto err_kfree;
 
-	eni_dev = kmalloc(sizeof(struct eni_dev),GFP_KERNEL);
-	if (!eni_dev) goto out0;
-	if (!cpu_zeroes) {
-		cpu_zeroes = pci_alloc_consistent(pci_dev,ENI_ZEROES_SIZE,
-		    &zeroes);
-		if (!cpu_zeroes) goto out1;
-	}
 	dev = atm_dev_register(DEV_LABEL, &pci_dev->dev, &ops, -1, NULL);
-	if (!dev) goto out2;
+	if (!dev)
+		goto err_free_consistent;
+
+	dev->dev_data = eni_dev;
 	pci_set_drvdata(pci_dev, dev);
 	eni_dev->pci_dev = pci_dev;
-	dev->dev_data = eni_dev;
 	eni_dev->asic = ent->driver_data;
-	error = eni_do_init(dev);
-	if (error) goto out3;
-	error = eni_start(dev);
-	if (error) goto out3;
+
+	rc = eni_do_init(dev);
+	if (rc < 0)
+		goto err_unregister;
+
+	rc = eni_start(dev);
+	if (rc < 0)
+		goto err_eni_release;
+
 	eni_dev->more = eni_boards;
 	eni_boards = dev;
-	return 0;
-out3:
+out:
+	return rc;
+
+err_eni_release:
+	eni_do_release(dev);
+err_unregister:
 	atm_dev_deregister(dev);
-out2:
-	pci_free_consistent(eni_dev->pci_dev,ENI_ZEROES_SIZE,cpu_zeroes,zeroes);
-	cpu_zeroes = NULL;
-out1:
+err_free_consistent:
+	pci_free_consistent(pci_dev, ENI_ZEROES_SIZE, zero->addr, zero->dma);
+err_kfree:
 	kfree(eni_dev);
-out0:
-	return error;
+err_disable:
+	pci_disable_device(pci_dev);
+	goto out;
 }
 
 
@@ -2273,9 +2293,17 @@ static struct pci_device_id eni_pci_tbl[] = {
 MODULE_DEVICE_TABLE(pci,eni_pci_tbl);
 
 
-static void __devexit eni_remove_one(struct pci_dev *pci_dev)
+static void __devexit eni_remove_one(struct pci_dev *pdev)
 {
-	/* grrr */
+	struct atm_dev *dev = pci_get_drvdata(pdev);
+	struct eni_dev *ed = ENI_DEV(dev);
+	struct eni_zero *zero = &ed->zero;
+
+	eni_do_release(dev);
+	atm_dev_deregister(dev);
+	pci_free_consistent(pdev, ENI_ZEROES_SIZE, zero->addr, zero->dma);
+	kfree(ed);
+	pci_disable_device(pdev);
 }
 
 
diff --git a/drivers/atm/eni.h b/drivers/atm/eni.h
index dc9a62c..565e53a 100644
--- a/drivers/atm/eni.h
+++ b/drivers/atm/eni.h
@@ -72,6 +72,7 @@ struct eni_dev {
 	u32 events;			/* pending events */
 	/*-------------------------------- base pointers into Midway address
 					   space */
+	void __iomem *ioaddr;
 	void __iomem *phy;		/* PHY interface chip registers */
 	void __iomem *reg;		/* register base */
 	void __iomem *ram;		/* RAM base */
@@ -86,6 +87,10 @@ struct eni_dev {
 	wait_queue_head_t tx_wait;	/* for close */
 	int tx_bw;			/* remaining bandwidth */
 	u32 dma[TX_DMA_BUF*2];		/* DMA request scratch area */
+	struct eni_zero {		/* aligned "magic" zeroes */
+		u32 *addr;
+		dma_addr_t dma;
+	} zero;
 	int tx_mult;			/* buffer size multiplier (percent) */
 	/*-------------------------------- RX part */
 	u32 serv_read;			/* host service read index */
-- 
1.7.7.6
