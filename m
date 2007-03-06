From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: [patch 18/19] mv643xx ethernet driver IRQ registration fix
Date: Tue, 6 Mar 2007 09:46:38 -0700
Message-ID: <20070306164638.GB22043@xyzzy.farnsworth.org>
References: <200703061042.l26Ag25d019787@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org, giri@lmc.cs.sunysb.edu,
	pgiri@yahoo.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:4651 "HELO farnsworth.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S965935AbXCFQqk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 11:46:40 -0500
Content-Disposition: inline
In-Reply-To: <200703061042.l26Ag25d019787@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 02:42:02AM -0800, akpm@linux-foundation.org wrote:
> From: Giridhar Pemmasani <giri@lmc.cs.sunysb.edu>
> 
> During initialization, mv643xx driver registers IRQ before setting up tx/rx
> rings.  This causes kernel oops because mv643xx_poll, which gets called
> right after registering IRQ, calls netif_rx_complete, which accesses the rx
> ring (I don't have the oops message anymore; I just remember this sequence
> of calls).  Attached (tested) patch first initializes the rx/tx rings and
> then registers the IRQ.

I believe a better fix is to disable any pending interrupt sources
before calling request_irq().  I sent the patch below to Giri for
confirmation, but haven't heard back.  I should've copied Andrew.

Giri, have you had a chance to test this alternative patch?

Thanks,
-Dale

> Date: Fri, 2 Mar 2007 17:03:53 -0700
> To: Giridhar Pemmasani <giri@lmc.cs.sunysb.edu>
> Message-ID: <20070303000353.GA1022@xyzzy.farnsworth.org>
> In-Reply-To: <es8ahm$64p$1@sea.gmane.org>
> 
> On Fri, Mar 02, 2007 at 04:52:06AM +0000, Giridhar Pemmasani wrote:
> > During initialization, mv643xx driver registers IRQ before setting up tx/rx
> > rings. This causes kernel oops because mv643xx_poll, which gets called
> > right after registering IRQ, calls netif_rx_complete, which accesses the rx
> > ring (I don't have the oops message anymore; I just remember this sequence
> > of calls). Attached (tested) patch first initializes the rx/tx rings and
> > then registers the IRQ.
> > 
> > Giri
> > 
> > Signed-off-by: Giridhar Pemmasani <pgiri@yahoo.com>
> 
> Giridhar, does the following patch fix your problem, in place of the
> patch you supplied?
> 
> -Dale

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 3e045a6..192b390 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -787,6 +787,12 @@ static int mv643xx_eth_open(struct net_device *dev)
 	unsigned int size;
 	int err;
 
+	/* Clear any pending ethernet port interrupts */
+	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	/* wait for previous write to complete */
+	mv_read (MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num));
+
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
 	if (err) {
@@ -875,10 +881,6 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	mv643xx_eth_rx_refill_descs(dev);	/* Fill RX ring with skb's */
 
-	/* Clear any pending ethernet port interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-
 	eth_port_start(dev);
 
 	/* Interrupt Coalescing */

