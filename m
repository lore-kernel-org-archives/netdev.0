From: Daniel Ritz <daniel.ritz@gmx.ch>
Subject: Re: [PATCH 2.6] missing s/dev->priv/netdev_priv(dev) in drivers/net/pcmcia/
Date: Wed, 24 Mar 2004 23:27:28 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403242327.28378.daniel.ritz@gmx.ch>
References: <200403242315.53770.daniel.ritz@gmx.ch> <40620ADD.90307@pobox.com>
Reply-To: daniel.ritz@gmx.ch
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40620ADD.90307@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 24 March 2004 23:25, Jeff Garzik wrote:
> Daniel Ritz wrote:
> > clean up the last two instances of dev->priv in drivers/net/pcmcia.
> > against 2.6.5-rc2-bk.
> > 
> > --- 1.27/drivers/net/pcmcia/3c589_cs.c	Wed Mar  3 01:03:51 2004
> > +++ edited/drivers/net/pcmcia/3c589_cs.c	Wed Mar 24 22:29:35 2004
> > @@ -716,7 +716,7 @@
> >  	  "status %4.4x.\n", dev->name, (long)skb->len,
> >  	  inw(ioaddr + EL3_STATUS));
> >  
> > -    ((struct el3_private *)dev->priv)->stats.tx_bytes += skb->len;
> > +    ((struct el3_private *)netdev_priv(dev))->stats.tx_bytes += skb->len;
> >  
> >      /* Put out the doubleword header... */
> >      outw(skb->len, ioaddr + TX_FIFO);
> > --- 1.24/drivers/net/pcmcia/ibmtr_cs.c	Wed Mar  3 01:06:03 2004
> > +++ edited/drivers/net/pcmcia/ibmtr_cs.c	Wed Mar 24 22:29:51 2004
> > @@ -444,7 +444,7 @@
> >          link->state &= ~DEV_PRESENT;
> >          if (link->state & DEV_CONFIG) {
> >  	    /* set flag to bypass normal interrupt code */
> > -	    ((struct tok_info *)dev->priv)->sram_virt |= 1;
> > +	    ((struct tok_info *)netdev_priv(dev))->sram_virt |= 1;
> >  	    netif_device_detach(dev);
> >  	    ibmtr_release(link);
> 
> 
> although the patch is OK, the code itself is a bit yucky.
> 
> Can you please create a temporary variable, of struct el3_private or 
> tok_info type, and eliminate that cast?
> 
> struct el3_private *priv = netdev_priv(dev);
> priv->stats.tx_bytes += skb->len;
> 
> Much nicer :)
> 

agreed. here we go...

--- 1.27/drivers/net/pcmcia/3c589_cs.c	Wed Mar  3 01:03:51 2004
+++ edited/drivers/net/pcmcia/3c589_cs.c	Wed Mar 24 23:22:59 2004
@@ -711,12 +711,13 @@
 static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
     ioaddr_t ioaddr = dev->base_addr;
+    struct el3_private *priv = netdev_priv(dev);
 
     DEBUG(3, "%s: el3_start_xmit(length = %ld) called, "
 	  "status %4.4x.\n", dev->name, (long)skb->len,
 	  inw(ioaddr + EL3_STATUS));
 
-    ((struct el3_private *)dev->priv)->stats.tx_bytes += skb->len;
+    priv->stats.tx_bytes += skb->len;
 
     /* Put out the doubleword header... */
     outw(skb->len, ioaddr + TX_FIFO);
--- 1.24/drivers/net/pcmcia/ibmtr_cs.c	Wed Mar  3 01:06:03 2004
+++ edited/drivers/net/pcmcia/ibmtr_cs.c	Wed Mar 24 23:24:39 2004
@@ -444,7 +444,8 @@
         link->state &= ~DEV_PRESENT;
         if (link->state & DEV_CONFIG) {
 	    /* set flag to bypass normal interrupt code */
-	    ((struct tok_info *)dev->priv)->sram_virt |= 1;
+	    struct tok_info *priv = netdev_priv(dev);
+	    priv->sram_virt |= 1;
 	    netif_device_detach(dev);
 	    ibmtr_release(link);
         }
