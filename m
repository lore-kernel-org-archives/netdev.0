From: Andy Fleming <afleming@freescale.com>
Subject: Using schedule_work for interrupt handling
Date: Fri, 3 Sep 2004 17:18:20 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <29D06014-FDF7-11D8-942E-000393C30512@freescale.com>
Mime-Version: 1.0 (Apple Message framework v618)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

So I've done another bk pull (just a few minutes ago), and my driver is 
still broken.  If this isn't the place to ask, please direct me to the 
appropriate list -- I'm getting desperate!

So what I'm doing in my driver is handling the PHY link change 
interrupt by disabling and clearing the interrupt I recieve, then 
calling schedule_work() to invoke my actual handler outside of 
interrupt time.  That function calls the various PHY configuration 
functions, configures the controller state appropriately, and then 
enables interrupts before returning.  The entire interrupt function is:

static irqreturn_t phy_interrupt(int irq, void *dev_id, struct pt_regs 
*regs)
{
         struct net_device *dev = (struct net_device *) dev_id;
         struct gfar_private *priv = netdev_priv(dev);

         /* Clear the interrupt */
         mii_clear_phy_interrupt(priv->mii_info);

         /* Disable PHY interrupts */
         mii_configure_phy_interrupt(priv->mii_info,
                         MII_INTERRUPT_DISABLED);

         /* Schedule the phy change */
         schedule_work(&priv->tq);

         return IRQ_HANDLED;
}

In the gfar_startup() function (called from gfar_open()), I initialize 
the work queue:

INIT_WORK(&priv->tq, gfar_phy_change, dev);

And later, I request the irq:

if (priv->einfo->flags & GFAR_HAS_PHY_INTR) {
                 if (request_irq(priv->einfo->interruptPHY,
                                         phy_interrupt,
                                         SA_SHIRQ,
                                         "phy_interrupt",
                                         mii_info->dev) < 0) {
                         printk(KERN_ERR "%s: Can't get IRQ %d (PHY)\n",
                                         mii_info->dev->name,
                                         priv->einfo->interruptPHY);
                 } else {
                         mii_configure_phy_interrupt(priv->mii_info,
                                         MII_INTERRUPT_ENABLED);
                         return;
                 }
}

(If the requesting the interrupt fails, it uses a timer, instead)

Is this right?  Am I missing a crucial step?  I ask because this no 
longer works.  The driver never successfully invokes gfar_phy_change(), 
and therefore never brings up the interface.  I have tried MANY, MANY 
things to get this working for the last 2+ weeks, and nothing has 
succeeded.  I can detail what I have done so far, if people think it 
will help, but for now I'm just seeing if anyone notices a flaw in my 
code (code which, I might add, works in 2.6.8.1).  Is this just what I 
get for not using a "stable" kernel?  If that's the case, then should I 
be submitting a bug to someone, so they know there may be a 
problem...somewhere?

Thanks for any help,
Andy Fleming
PowerPC Software Enablement
Freescale Semiconductor, Inc.
