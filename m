From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCH 2.6.10-rc1 7/15] wireless/orinoco: Update card reset/init code and add card-specific data structures
Date: Wed, 27 Oct 2004 14:00:10 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027040010.GA1676@zax>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098816980.3663.62.camel@dcbw.boston.redhat.com> <417EA8D8.3060403@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@oss.sgi.com, jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <417EA8D8.3060403@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 03:43:20PM -0400, Jeff Garzik wrote:
> Dan Williams wrote:
> >+/* Orinoco PCI specific data */
> >+struct orinoco_pci_card {
> >+	u32 pci_state[16];	/* PCI suspend/resume state */
> >+};
> 
> no need with GregKH's latest upstream changes

And recently removed from the for_linus branch.

> >-	printk(KERN_NOTICE "Reset done");
> > 	timeout = jiffies + (HERMES_PCI_COR_ONT * HZ / 1000);
> >-	while(time_before(jiffies, timeout)) {
> >-		printk(".");
> >+	while(time_before(jiffies, timeout))
> > 		mdelay(1);
> 
> the loop is non-sensical... at this point use msleep() or actually 
> mdelay() for the correct period, rather than looping on mdelay(1)

Oh, yes, that really shouldn't have survived this long.  Now fixed in
CVS (for_linus branch, merge to HEAD coming shortly).

> >@@ -199,61 +194,68 @@
> > 	u16 *pci_ioaddr = NULL;
> > 	unsigned long pci_iolen;
> > 	struct orinoco_private *priv = NULL;
> >+	struct orinoco_pci_card *card;
> > 	struct net_device *dev = NULL;
> > 
> > 	err = pci_enable_device(pdev);
> >-	if (err)
> >-		return -EIO;
> >+	if (err) {
> >+		printk(KERN_ERR PFX "Cannot enable PCI device\n");
> >+		return -err;
> >+	}
> 
> incorrect...  err is already negative.

Also now fixed in CVS.

> >@@ -325,6 +327,9 @@
> > 	
> > 	orinoco_unlock(priv, &flags);
> > 
> >+	pci_save_state(pdev, card->pci_state);
> >+	pci_set_power_state(pdev, 3);
> >+
> > 	return 0;
> > }
> > 
> >@@ -332,11 +337,15 @@
> > {
> > 	struct net_device *dev = pci_get_drvdata(pdev);
> > 	struct orinoco_private *priv = netdev_priv(dev);
> >+	struct orinoco_pci_card *card = priv->card;
> > 	unsigned long flags;
> > 	int err;
> > 
> > 	printk(KERN_DEBUG "%s: Orinoco-PCI waking up\n", dev->name);
> > 
> >+	pci_set_power_state(pdev, 0);
> >+	pci_restore_state(pdev, card->pci_state);
> >+
> > 	err = orinoco_reinit_firmware(dev);
> > 	if (err) {
> > 		printk(KERN_ERR "%s: Error %d re-initializing firmware on 
> > 		orinoco_pci_resume()\n",
> 
> These two don't build in the latest 2.6.x kernel.

This was fixed by Pavel in the last day or so.

> >@@ -332,6 +374,8 @@
> > 	.id_table	= orinoco_plx_pci_id_table,
> > 	.probe		= orinoco_plx_init_one,
> > 	.remove		= __devexit_p(orinoco_plx_remove_one),
> >+	.suspend	= 0,
> >+	.resume		= 0,
> > };
> 
> superfluous change

Removed from CVS.

> >+ * Do a soft reset of the card using the Configuration Option Register
> >+ */
> >+static int orinoco_tmd_cor_reset(struct orinoco_private *priv)
> >+{
> >+	hermes_t *hw = &priv->hw;
> >+	struct orinoco_tmd_card *card = priv->card;
> >+	u32 addr = card->tmd_io;
> >+	unsigned long timeout;
> >+	u16 reg;
> >+
> >+	outb(COR_VALUE | COR_RESET, addr);
> >+	mdelay(1);
> >+
> >+	outb(COR_VALUE, addr);
> >+	mdelay(1);
> 
> PCI posting bugs?

That I don't know.  Unfortunately a lot of these cards are rather
nasty and fragile, so I don't really want to mess with it.

> >+	/* Just in case, wait more until the card is no longer busy */
> >+	timeout = jiffies + (TMD_RESET_TIME * HZ / 1000);
> >+	reg = hermes_read_regn(hw, CMD);
> >+	while (time_before(jiffies, timeout) && (reg & HERMES_CMD_BUSY)) {
> >+		mdelay(1);
> >+		reg = hermes_read_regn(hw, CMD);
> >+	}
> 
> max delay without sleep way too long

Yes, yes it is.  However, we've had a lot of trouble with timeouts and
locking and sleeping in the driver.  On the grounds that the bad case
usually won't be hit, I'd rather not mess with that until someone has
a rather better insight on how to organize this stuff to ensure we
give the cards the delays they need, without the blocks-in-sleep.  I
don't have a TMD card myself, so I'm extra wary about changing it.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
