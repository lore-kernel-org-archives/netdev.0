From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [RFC PATCH v0.2] net driver: mpc52xx fec
Date: Tue, 2 Oct 2007 14:49:39 +0200
Message-ID: <20071002124939.GC10481@pengutronix.de>
References: <20070810095153.GC13994@moe.telargo.com> <20070902074143.GB2642@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-embedded@ozlabs.org, netdev@vger.kernel.org
To: Domen Puncer <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.extern.pengutronix.de ([83.236.181.26]:49554 "EHLO
	metis.extern.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752682AbXJBMtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 08:49:50 -0400
Content-Disposition: inline
In-Reply-To: <20070902074143.GB2642@nd47.coderock.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Domen,

On Sun, Sep 02, 2007 at 09:41:43AM +0200, Domen Puncer wrote:
 + */
> +static void fec_start(struct net_device *dev)
> +{
> +	struct fec_priv *priv = netdev_priv(dev);
> +	struct mpc52xx_fec __iomem *fec = priv->fec;
> +	u32 rcntrl;
> +	u32 tcntrl;
> +	u32 tmp;
> +
> +	/* clear sticky error bits */
> +	tmp = FEC_FIFO_STATUS_ERR | FEC_FIFO_STATUS_UF | FEC_FIFO_STATUS_OF;
> +	out_be32(&fec->rfifo_status, in_be32(&fec->rfifo_status) & tmp);
> +	out_be32(&fec->tfifo_status, in_be32(&fec->tfifo_status) & tmp);
> +
> +	/* FIFOs will reset on fec_enable */
> +	out_be32(&fec->reset_cntrl, FEC_RESET_CNTRL_ENABLE_IS_RESET);
> +
> +	/* Set station address. */
> +	fec_set_paddr(dev, dev->dev_addr);
> +
> +	fec_set_multicast_list(dev);
> +
> +	/* set max frame len, enable flow control, select mii mode */
> +	rcntrl = FEC_RX_BUFFER_SIZE << 16;	/* max frame length */
> +	rcntrl |= FEC_RCNTRL_FCE;
> +	rcntrl |= MII_RCNTL_MODE;
> +	if (priv->duplex == DUPLEX_FULL)
> +		tcntrl = FEC_TCNTRL_FDEN;	/* FD enable */
> +	else {
> +		rcntrl |= FEC_RCNTRL_DRT;	/* disable Rx on Tx (HD) */
> +		tcntrl = 0;
> +	}
> +	out_be32(&fec->r_cntrl, rcntrl);
> +	out_be32(&fec->x_cntrl, tcntrl);
> +
> +	/* Clear any outstanding interrupt. */
> +	out_be32(&fec->ievent, 0xffffffff);
> +
> +	/* Enable interrupts we wish to service. */
> +	out_be32(&fec->imask, FEC_IMASK_ENABLE);


This disables phy interrupts.


> +static int fec_mdio_read(struct mii_bus *bus, int phy_id, int reg)
> +{
> +	struct fec_mdio_priv *priv = bus->priv;
> +	int tries = 100;
> +
> +	u32 request = FEC_MII_READ_FRAME;
> +	request |= (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
> +	request |= (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
> +
> +	out_be32(&priv->regs->mii_data, request);
> +
> +	/* wait for it to finish, this takes about 23 us on lite5200b */
> +	while (priv->completed == 0 && tries--)
> +		udelay(5);
> +
> +	priv->completed = 0;
> +
> +	if (tries == 0)
> +		return -ETIMEDOUT;

This does not work as expected. When a timeout occurs tries is -1 not 0,
so the test above will never trigger.
Using --tries instead of tries-- reveals another bug. We get a timeout
everytime now, because MII interrupts are accidently disabled in
fec_start().

We cannot use a waitqueue or similar for waiting for the mii transfer
because we are atomic here.
A simple fix is provided below. It removes the need for the interrupt
handler in the phy handling routines. Anyway, it might be better to fix
the phy layer not to use atomic contexts, so this patch might not be the
way to go.


Regards, 
  Sascha

 +
> +static int fec_mdio_probe(struct of_device *of, const struct of_device_id *match)
> +{
> +	struct device *dev = &of->dev;
>
>       [...]
>
> +	init_waitqueue_head(&priv->wq);

This waitqueue is never used. wake_up() is called in the interrupt
handler, but noone ever sleeps on the queue.


---
 drivers/net/fec_mpc52xx/fec.c     |    7 +---
 drivers/net/fec_mpc52xx/fec_phy.c |   59 +++++++-------------------------------
 2 files changed, 15 insertions(+), 51 deletions(-)

Index: linux-2.6.23-rc8/drivers/net/fec_mpc52xx/fec.c
===================================================================
--- linux-2.6.23-rc8.orig/drivers/net/fec_mpc52xx/fec.c
+++ linux-2.6.23-rc8/drivers/net/fec_mpc52xx/fec.c
@@ -265,7 +265,6 @@ static void fec_phy_hw_init(struct fec_p
 		return;
 
 	out_be32(&fec->mii_speed, priv->phy_speed);
-	out_be32(&fec->imask, in_be32(&fec->imask) | FEC_IMASK_MII);
 }
 
 static int fec_open(struct net_device *dev)
@@ -654,7 +653,7 @@ static void fec_hw_init(struct net_devic
 	out_be32(&fec->iaddr1, 0x00000000);	/* No individual filter */
 	out_be32(&fec->iaddr2, 0x00000000);	/* No individual filter */
 
-	/* set phy speed and enable MII interrupt
+	/* set phy speed.
 	 * this can't be done in phy driver, since it needs to be called
 	 * before fec stuff (even on resume) */
 	fec_phy_hw_init(priv);
@@ -730,8 +729,8 @@ static void fec_stop(struct net_device *
 	struct mpc52xx_fec __iomem *fec = priv->fec;
 	unsigned long timeout;
 
-	/* disable all but MII interrupt */
-	out_be32(&fec->imask, in_be32(&fec->imask) & FEC_IMASK_MII);
+	/* disable all interrupts */
+	out_be32(&fec->imask, 0);
 
 	/* Disable the rx task. */
 	bcom_disable(priv->rx_dmatsk);
Index: linux-2.6.23-rc8/drivers/net/fec_mpc52xx/fec_phy.c
===================================================================
--- linux-2.6.23-rc8.orig/drivers/net/fec_mpc52xx/fec_phy.c
+++ linux-2.6.23-rc8/drivers/net/fec_mpc52xx/fec_phy.c
@@ -18,29 +18,28 @@
 #include "fec.h"
 
 struct fec_mdio_priv {
-	int completed;
-	wait_queue_head_t wq;
 	struct mpc52xx_fec __iomem *regs;
-	int irq;
 };
 
 static int fec_mdio_read(struct mii_bus *bus, int phy_id, int reg)
 {
 	struct fec_mdio_priv *priv = bus->priv;
+	struct mpc52xx_fec __iomem *fec;
 	int tries = 100;
-
 	u32 request = FEC_MII_READ_FRAME;
+
+	fec = priv->regs;
+	out_be32(&fec->ievent, FEC_IEVENT_MII);
+
 	request |= (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
 	request |= (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
 
 	out_be32(&priv->regs->mii_data, request);
 
 	/* wait for it to finish, this takes about 23 us on lite5200b */
-	while (priv->completed == 0 && tries--)
+	while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --tries)
 		udelay(5);
 
-	priv->completed = 0;
-
 	if (tries == 0)
 		return -ETIMEDOUT;
 
@@ -50,9 +49,13 @@ static int fec_mdio_read(struct mii_bus 
 static int fec_mdio_write(struct mii_bus *bus, int phy_id, int reg, u16 data)
 {
 	struct fec_mdio_priv *priv = bus->priv;
+	struct mpc52xx_fec __iomem *fec;
 	u32 value = data;
 	int tries = 100;
 
+	fec = priv->regs;
+	out_be32(&fec->ievent, FEC_IEVENT_MII);
+
 	value |= FEC_MII_WRITE_FRAME;
 	value |= (phy_id << FEC_MII_DATA_PA_SHIFT) & FEC_MII_DATA_PA_MSK;
 	value |= (reg << FEC_MII_DATA_RA_SHIFT) & FEC_MII_DATA_RA_MSK;
@@ -60,38 +63,15 @@ static int fec_mdio_write(struct mii_bus
 	out_be32(&priv->regs->mii_data, value);
 
 	/* wait for request to finish */
-	while (priv->completed == 0 && tries--)
+	while (!(in_be32(&fec->ievent) & FEC_IEVENT_MII) && --tries)
 		udelay(5);
 
-	priv->completed = 0;
-
 	if (tries == 0)
 		return -ETIMEDOUT;
 
 	return 0;
 }
 
-static irqreturn_t fec_mdio_interrupt(int irq, void *dev_id)
-{
-	struct fec_mdio_priv *priv = dev_id;
-	struct mpc52xx_fec __iomem *fec;
-	int ievent;
-
-	fec = priv->regs;
-	ievent = in_be32(&fec->ievent);
-
-	ievent &= FEC_IEVENT_MII;
-	if (!ievent)
-		return IRQ_NONE;
-
-	out_be32(&fec->ievent, ievent);
-
-	priv->completed = 1;
-	wake_up(&priv->wq);
-
-	return IRQ_HANDLED;
-}
-
 static int fec_mdio_probe(struct of_device *of, const struct of_device_id *match)
 {
 	struct device *dev = &of->dev;
@@ -143,22 +123,12 @@ static int fec_mdio_probe(struct of_devi
 		goto out_free;
 	}
 
-	priv->irq = irq_of_parse_and_map(np, 0);
-	err = request_irq(priv->irq, &fec_mdio_interrupt, IRQF_DISABLED | IRQF_SHARED,
-	                "fec_mdio", priv);
-	if (err) {
-		printk(KERN_ERR "%s: interrupt request failed with %i\n", __func__, err);
-		goto out_unmap;
-	}
-
 	bus->id = res.start;
 	bus->priv = priv;
 
 	bus->dev = dev;
 	dev_set_drvdata(dev, bus);
 
-	init_waitqueue_head(&priv->wq);
-
 	/* set MII speed */
 	out_be32(&priv->regs->mii_speed, ((mpc52xx_find_ipb_freq(of->node) >> 20) / 5) << 1);
 
@@ -167,13 +137,10 @@ static int fec_mdio_probe(struct of_devi
 
 	err = mdiobus_register(bus);
 	if (err)
-		goto out_free_irq;
+		goto out_unmap;
 
 	return 0;
 
- out_free_irq:
-	free_irq(priv->irq, dev);
-	irq_dispose_mapping(priv->irq);
  out_unmap:
 	iounmap(priv->regs);
  out_free:
@@ -197,8 +164,6 @@ static int fec_mdio_remove(struct of_dev
 	mdiobus_unregister(bus);
 	dev_set_drvdata(dev, NULL);
 
-	free_irq(priv->irq, dev);
-	irq_dispose_mapping(priv->irq);
 	iounmap(priv->regs);
 	for (i=0; i<PHY_MAX_ADDR; i++)
 		if (bus->irq[i])

--
Pengutronix - Linux Solutions for Science and Industry
Entwicklungszentrum Nord     http://www.pengutronix.de
