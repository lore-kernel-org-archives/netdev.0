From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: R[PATCH 2.6.10-rc1 8/15] wireless/orinoco: Refactor spinlocks so	we don't necessarily have to disable interrupts
Date: Wed, 27 Oct 2004 14:14:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027041428.GD1676@zax>
References: <1098814320.3663.24.camel@dcbw.boston.redhat.com> <1098817472.3663.66.camel@dcbw.boston.redhat.com> <417EA915.9090500@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>, netdev@oss.sgi.com, jgarzik@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <417EA915.9090500@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 03:44:21PM -0400, Jeff Garzik wrote:
> Dan Williams wrote:
> >Update in-kernel orinoco wireless drivers to upstream CVS.
> >None of this is original code by Dan Williams, simply a
> >broken down patch set split-out from upstream orinoco CVS.
> >
> >o Refactor spinlocks so we don't necessarily have to disable
> interrupts

No, this should *not* be applied.  This again is orinoco_usb stuff,
which is in HEAD but not for_linus and which should not go upstream.

> >10:44:41.445687264 -0400
> >+++ b/drivers/net/wireless/orinoco.h	2004-10-26 10:45:39.296892544 -0400
> >@@ -71,6 +71,8 @@
> > 	u16 channel_mask;
> > 	int broken_disableport;
> > 
> >+	unsigned int irq_no_disable:1;
> >+
> > 	/* Configuration paramaters */
> > 	u32 iw_mode;
> > 	int prefer_port3;
> >@@ -129,11 +131,17 @@
> > extern inline int orinoco_lock(struct orinoco_private *priv,
> > 			       unsigned long *flags)
> > {
> >-	spin_lock_irqsave(&priv->lock, *flags);
> >+	if (priv->irq_no_disable)
> >+		spin_lock_bh(&priv->lock);
> >+	else
> >+		spin_lock_irqsave(&priv->lock, *flags);
> > 	if (priv->hw_unavailable) {
> >-		printk(KERN_DEBUG "orinoco_lock() called with hw_unavailable 
> >(dev=%p)\n",
> >+		DEBUG(1, "orinoco_lock() called with hw_unavailable 
> >(dev=%p)\n",
> > 		       priv->ndev);
> >-		spin_unlock_irqrestore(&priv->lock, *flags);
> >+		if (priv->irq_no_disable)
> >+			spin_unlock_bh(&priv->lock);
> >+		else
> >+			spin_unlock_irqrestore(&priv->lock, *flags);
> > 		return -EBUSY;
> 
> This entire area has problems.

Yes, it does.

> Orinoco doesn't need to invent its own locking primitives, nor does it 
> need to be inventing functions that take *flags as an argument.

The (already existing) orinoco_lock()/unlock() functions are somewhat
yucky, though I don't think abolishing them is an urgent item.  This
conditional locking stuff is completely insane.  It was added in HEAD
as part of the orinco_usb support, because I got sick of people
whinging about me not merging the usb support - in the hope that the
vile hacks would get removed over time.  I've told the USB folks on
several occasions that this conditional locking stuff is absolutely
too ugly to live, and needs to be done differently, but I've got
nothing but the "but it works!" argument.  I have neither the hardware
nor the time to figure out how to fix it properly myself.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
