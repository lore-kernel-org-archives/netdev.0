From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: RE: Fw: Badness in local_bh_enable at kernel/softirq.c:119
Date: Tue, 30 Sep 2003 10:27:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <C6F5CF431189FA4CBAEC9E7DD5441E010222966E@orsmsx402.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <jgarzik@pobox.com>, <akpm@osdl.org>, <netdev@oss.sgi.com>,
        "cramerj" <cramerj@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Sorry, in case it isn't painfully obvious, instead of hinting
> at it let me state explicitly that ->xmit_lock is a BH 
> disabling lock not an IRQ disabling one.
> 
> Therefore, e1000's IRQ disabling when grabbing that lock is
> buggy and need to be changed to BH disabling.
> 
> If it needs to disable IRQs for it's own internal locking, it
> needs to do so such that such IRQ disabling internal locks 
> are not held while kfree_skb() is being invoked.
> 
> Calling kfree_skb() with IRQs disabled in the e1000 driver is
> the cause of this bug.

Thanks David for your help.
 
> Jeff, if you pushed these e1000 updates that make it grap
> ->xmit_lock() with disabling IRQs instead of BH into 2.4.x
> trees too, beware!

The e1000 driver has been like this (broken) for quite a while.  Recent
updates haven't messed with this code.

This gets back to the problem of trying to flush any queued transmits
when we lose link.  The e1000 hardware stops DMA when link lose is
detected, so any work queued to hardware is "stuck", and therefore we
don't release the associated skb resources until we regain link.  This
causes problems when we're sitting under a failover setup like bonding
or ANS.

At this point, I'm leaning towards removing the offending code in the
timer callback now, and taking a step back to solve the bigger problem,
either with a better locking scheme, or a new plan on how to flush the
"stuck" work.  We don't need kernel panics when you trip over the
Ethernet cable!  Sound like a plan?

@@ -1278,41 +1278,6 @@
 		e1000_leave_82542_rst(adapter);
 }
 
-static void
-e1000_tx_flush(struct e1000_adapter *adapter)
-{
-	uint32_t ctrl, tctl, txcw, icr;
-
-	e1000_irq_disable(adapter);
-
-	if(adapter->hw.mac_type < e1000_82543) {
-		/* Transmit Unit Reset */
-		tctl = E1000_READ_REG(&adapter->hw, TCTL);
-		E1000_WRITE_REG(&adapter->hw, TCTL, tctl |
E1000_TCTL_RST);
-		E1000_WRITE_REG(&adapter->hw, TCTL, tctl);
-		e1000_clean_tx_ring(adapter);
-		e1000_configure_tx(adapter);
-	} else {
-		txcw = E1000_READ_REG(&adapter->hw, TXCW);
-		E1000_WRITE_REG(&adapter->hw, TXCW, txcw &
~E1000_TXCW_ANE);
-
-		ctrl = E1000_READ_REG(&adapter->hw, CTRL);
-		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl |
E1000_CTRL_SLU |
-				E1000_CTRL_ILOS);
-
-		mdelay(10);
-
-		e1000_clean_tx_irq(adapter);
-		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
-		E1000_WRITE_REG(&adapter->hw, TXCW, txcw);
-
-		/* clear the link status change interrupts this caused
*/
-		icr = E1000_READ_REG(&adapter->hw, ICR);
-	}
-
-	e1000_irq_enable(adapter);
-}
-
 /* need to wait a few seconds after link up to get diagnostic
information from the phy */
 
 static void
@@ -1414,15 +1379,6 @@
 	e1000_update_stats(adapter);
 	e1000_update_adaptive(&adapter->hw);
 
-	if(!netif_carrier_ok(netdev)) {
-		if(E1000_DESC_UNUSED(txdr) + 1 < txdr->count) {
-			unsigned long flags;
-			spin_lock_irqsave(&netdev->xmit_lock, flags);
-			e1000_tx_flush(adapter);
-			spin_unlock_irqrestore(&netdev->xmit_lock,
flags);
-		}
-	}
-
 	/* Dynamic mode for Interrupt Throttle Rate (ITR) */
 	if(adapter->hw.mac_type >= e1000_82540 && adapter->itr == 1) {
 		/* Symmetric Tx/Rx gets a reduced ITR=2000; Total

-scott
