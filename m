From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] cirrus logic ep93xx ethernet driver
Date: Fri, 22 Sep 2006 02:27:46 +0200
Message-ID: <20060922002746.GD30338@xi.wantstofly.org>
References: <20060921210536.GA29520@xi.wantstofly.org> <45131BCA.3050809@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:18906 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932137AbWIVA1u
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 20:27:50 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <45131BCA.3050809@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 21, 2006 at 07:10:02PM -0400, Jeff Garzik wrote:

> >+		if (!(rstat0 & RSTAT0_RFP)) {
> >+			printk(KERN_CRIT "ep93xx_rx: buffer not done "
> >+					 " %.8x %.8x\n", rstat0, rstat1);
> >+			BUG();
> >+		}
> >+		if (!(rstat0 & RSTAT0_EOF)) {
> >+			printk(KERN_CRIT "ep93xx_rx: not end-of-frame "
> >+					 " %.8x %.8x\n", rstat0, rstat1);
> >+			BUG();
> >+		}
> >+		if (!(rstat0 & RSTAT0_EOB)) {
> >+			printk(KERN_CRIT "ep93xx_rx: not end-of-buffer "
> >+					 " %.8x %.8x\n", rstat0, rstat1);
> >+			BUG();
> >+		}
> >+		if (!(rstat1 & RSTAT1_RFP)) {
> >+			printk(KERN_CRIT "ep93xx_rx: buffer1 not done "
> >+					 " %.8x %.8x\n", rstat0, rstat1);
> >+			BUG();
> >+		}
> >+		if ((rstat1 & RSTAT1_BUFFER_INDEX) >> 16 != entry) {
> >+			printk(KERN_CRIT "ep93xx_rx: entry mismatch "
> >+					 " %.8x %.8x\n", rstat0, rstat1);
> >+			BUG();
> >+		}
> 
> NAK all these BUGs.
> 
> Very unfriendly

If any of these checks trigger, we are in a very bad state, and
something is likely trampling over random bits of memory, but OK,
removed.


> >+		if (tstat0 & TSTAT0_TXWE) {
> >+			int length = ep->descs->tdesc[entry].tdesc1 & 0xfff;
> >+
> >+			ep->stats.tx_packets++;
> >+			ep->stats.tx_bytes += length;
> >+		} else {
> >+			ep->stats.tx_errors++;
> >+		}
> >+#if 0
> >+		/* This is only valid in half duplex mode.  */
> >+		if (tstat0 & TSTAT0_LCRS)
> >+			ep->stats.tx_carrier_errors++;
> >+#endif
> 
> why #if 0'd?

The CRS bit will be set in the tx completion entry if the MII CRS
(Carrier Sense) signal wasn't asserted after the first N nibbles have
been transmitted.  However, if the PHY is running in full duplex mode,
the CRS signal isn't supposed to assert at all, and so we ended up
counting tx_carrier_errors for every transmitted packet if the
interface was in full duplex mode.

I removed this bit of code rather than #if 0'ing it out.


> >+static irqreturn_t ep93xx_irq(int irq, void *dev_id, struct pt_regs *regs)
> >+{
> >+	struct net_device *dev = dev_id;
> >+	struct ep93xx_priv *ep = netdev_priv(dev);
> >+	u32 status;
> >+
> >+	status = rdl(ep, REG_INTSTSC);
> >+	if (status == 0)
> >+		return IRQ_NONE;
> 
> also check for status == 0xffffffff

As the ethernet controller is on the CPU die itself, it's not very
likely to be unplugged?


> >+static int ep93xx_alloc_buffers(struct ep93xx_priv *ep)
> >+{
> >+	int i;
> >+
> >+	ep->descs = dma_alloc_coherent(NULL, sizeof(struct ep93xx_descs),
> >+				&ep->descs_dma_addr, GFP_KERNEL | GFP_DMA);
> >+	if (ep->descs == NULL)
> >+		return 1;
> >+
> >+	for (i = 0; i < RX_QUEUE_ENTRIES; i += 2) {
> >+		void *page;
> >+		dma_addr_t d;
> >+
> >+		page = (void *)get_zeroed_page(GFP_KERNEL | GFP_DMA);
> >+		if (page == NULL)
> >+			goto err;
> 
> do you really need a zeroed page?

No, any page will do -- fixed.


> >+static int ep93xx_eth_remove(struct platform_device *pdev)
> >+{
> >+	struct net_device *dev;
> >+	struct ep93xx_priv *ep;
> >+
> >+	dev = platform_get_drvdata(pdev);
> >+	if (dev == NULL)
> >+		return 0;
> >+	platform_set_drvdata(pdev, NULL);
> >+
> >+	ep = netdev_priv(dev);
> >+
> >+	/* @@@ Force down.  */
> >+	unregister_netdev(dev);
> >+	ep93xx_free_buffers(ep);
> >+
> >+	if (ep->base_addr != NULL)
> >+		iounmap(ep->base_addr);
> >+
> >+	if (ep->res != NULL) {
> >+		release_resource(ep->res);
> >+		kfree(ep->res);
> >+	}
> 
> when will these ever be NULL ?

ep93xx_eth_remove is called from ep93xx_eth_probe's error path (see
below.)

All other issues fixed as well.  Thanks for your time.


> >+	free_netdev(dev);
> >+
> >+	return 0;
> >+}
> >+
> >+static int ep93xx_eth_probe(struct platform_device *pdev)
> >+{
> >+	struct ep93xx_eth_data *data;
> >+	struct net_device *dev;
> >+	struct ep93xx_priv *ep;
> >+	int err;
> >+
> >+	data = pdev->dev.platform_data;
> >+	if (pdev == NULL)
> >+		return -ENODEV;
> >+
> >+	dev = ep93xx_dev_alloc(data);
> >+	if (dev == NULL) {
> >+		err = -ENOMEM;
> >+		goto err_out;
> >+	}
> >+	ep = netdev_priv(dev);
> >+
> >+	platform_set_drvdata(pdev, dev);
> >+
> >+	ep->res = request_mem_region(pdev->resource[0].start,
> >+			pdev->resource[0].end - pdev->resource[0].start + 1,
> >+			pdev->dev.bus_id);
> >+	if (ep->res == NULL) {
> >+		dev_err(&pdev->dev, "Could not reserve memory region\n");
> >+		err = -ENOMEM;
> >+		goto err_out;
> >+	}
> >+
> >+	ep->base_addr = ioremap(pdev->resource[0].start,
> >+			pdev->resource[0].end - pdev->resource[0].start);
> >+	if (ep->base_addr == NULL) {
> >+		dev_err(&pdev->dev, "Failed to ioremap ethernet 
> >registers\n");
> >+		err = -EIO;
> >+		goto err_out;
> >+	}
> >+	ep->irq = pdev->resource[1].start;
> >+
> >+	ep->mii.phy_id = data->phy_id;
> >+	ep->mii.phy_id_mask = 0x1f;
> >+	ep->mii.reg_num_mask = 0x1f;
> >+	ep->mii.dev = dev;
> >+	ep->mii.mdio_read = ep93xx_mdio_read;
> >+	ep->mii.mdio_write = ep93xx_mdio_write;
> >+	ep->mdc_divisor = 40;	/* Max HCLK 100 MHz, min MDIO clk 2.5 MHz.  
> >*/
> >+
> >+	err = register_netdev(dev);
> >+	if (err) {
> >+		dev_err(&pdev->dev, "Failed to register netdev\n");
> >+		goto err_out;
> >+	}
> >+
> >+	printk(KERN_INFO "%s: ep93xx on-chip ethernet, IRQ %d, "
> >+			 "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x.\n", dev->name,
> >+			ep->irq, data->dev_addr[0], data->dev_addr[1],
> >+			data->dev_addr[2], data->dev_addr[3],
> >+			data->dev_addr[4], data->dev_addr[5]);
> >+
> >+	return 0;
> >+
> >+err_out:
> >+	ep93xx_eth_remove(pdev);
> >+	return err;
> >+}
