From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]: Tigon3 new NAPI locking v2
Date: Thu, 16 Jun 2005 21:37:32 +1000
Message-ID: <20050616113732.GA22367@gondor.apana.org.au>
References: <20050603.122558.88474819.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="5vNYLRcllDrimb99"
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050603.122558.88474819.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jun 03, 2005 at 07:25:58PM +0000, David S. Miller wrote:
> 
> This version incorporates two bug fixes from Michael.
> 
> 1) Check the mailbox register for 0x1 while polling on the COMPLETE
>    state bit.
> 
> 2) Remove the BUG_ON() check in tg3_restart_ints(), it can legally and
>    harmlessly occur.
> 
> Point #2 may want some refinements, but this patch below is good
> enough for testing.

Nice work Dave.

I was thinking of how we could avoid waiting for the interrupt to
occur after setting SYNC.  Here is one way which is essentially
a hand-coded spin lock.  In fact with a bit of work we could convert
it back to a real spin lock with spin_trylock.

The advantage of this is that we won't have to rely on the interrupt
to occur after setting SYNC.  The disadvantage is that on certain
architectures (sparc64 obviously :) we're now doing the relatively
expensive bit operations on each IRQ.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--5vNYLRcllDrimb99
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- linux-2.6/drivers/net/tg3.h.orig	2005-06-16 21:10:30.000000000 +1000
+++ linux-2.6/drivers/net/tg3.h	2005-06-16 21:12:00.000000000 +1000
@@ -2009,21 +2009,22 @@
 	/* If the IRQ handler (which runs lockless) needs to be
 	 * quiesced, the following bitmask state is used.  The
 	 * SYNC bit is set by non-IRQ context code to initiate
-	 * the quiescence.  The setter of this bit also forces
-	 * an interrupt to run via the GRC misc host control
-	 * register.
-	 *
-	 * The IRQ handler notes this, disables interrupts, and
-	 * sets the COMPLETE bit.  At this point the SYNC bit
-	 * setter can be assured that interrupts will no longer
-	 * get run.
+	 * the quiescence.
+	 *
+	 * The IRQ sets the BUSY bit whenever it runs.  When it
+	 * notices that SYNC is set, it disables interrupts,
+	 * clears the BUSY bit and returns.
+	 *
+	 * When the BUSY bit is cleared after the SYNC bit has
+	 * been set, the setter can be assured that interrupts
+	 * will no longer get run.
 	 *
 	 * In this way all SMP driver locks are never acquired
 	 * in hw IRQ context, only sw IRQ context or lower.
 	 */
 	unsigned long			irq_state;
 #define TG3_IRQSTATE_SYNC		0
-#define TG3_IRQSTATE_COMPLETE		1
+#define TG3_IRQSTATE_BUSY		1
 
 	/* SMP locking strategy:
 	 *
--- linux-2.6/drivers/net/tg3.c.orig	2005-06-16 21:10:27.000000000 +1000
+++ linux-2.6/drivers/net/tg3.c	2005-06-16 21:24:54.000000000 +1000
@@ -2931,32 +2931,26 @@
 	return (done ? 0 : 1);
 }
 
-static void tg3_irq_quiesce(struct tg3 *tp)
+static inline void tg3_irq_quiesce(struct tg3 *tp)
 {
 	BUG_ON(test_bit(TG3_IRQSTATE_SYNC, &tp->irq_state));
 
 	set_bit(TG3_IRQSTATE_SYNC, &tp->irq_state);
-	smp_mb();
-	tw32(GRC_LOCAL_CTRL,
-	     tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
-
-	while (!test_bit(TG3_IRQSTATE_COMPLETE, &tp->irq_state)) {
-		u32 val = tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
-
-		if (val == 0x00000001)
-			break;
 
+	while (test_bit(TG3_IRQSTATE_BUSY, &tp->irq_state))
 		cpu_relax();
-	}
 }
 
-static inline int tg3_irq_sync(struct tg3 *tp)
+static inline int tg3_irq_enter(struct tg3 *tp)
 {
-	if (test_bit(TG3_IRQSTATE_SYNC, &tp->irq_state)) {
-		set_bit(TG3_IRQSTATE_COMPLETE, &tp->irq_state);
-		return 1;
-	}
-	return 0;
+	set_bit(TG3_IRQSTATE_BUSY, &tp->irq_state);
+	return test_bit(TG3_IRQSTATE_SYNC, &tp->irq_state);
+}
+
+static inline void tg3_irq_exit(struct tg3 *tp)
+{
+	smp_mb__before_clear_bit();
+	clear_bit(TG3_IRQSTATE_BUSY, &tp->irq_state);
 }
 
 /* Fully shutdown all tg3 driver activity elsewhere in the system.
@@ -2997,8 +2991,10 @@
 	 */
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW, 0x00000001);
 	tp->last_tag = sblk->status_tag;
-	if (tg3_irq_sync(tp))
+
+	if (tg3_irq_enter(tp))
 		goto out;
+
 	sblk->status &= ~SD_STATUS_UPDATED;
 	if (likely(tg3_has_work(tp)))
 		netif_rx_schedule(dev);		/* schedule NAPI poll */
@@ -3007,7 +3003,10 @@
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     tp->last_tag << 24);
 	}
+
 out:
+	tg3_irq_exit(tp);
+
 	return IRQ_RETVAL(1);
 }
 
@@ -3034,8 +3033,10 @@
 		 */
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
-		if (tg3_irq_sync(tp))
+
+		if (tg3_irq_enter(tp))
 			goto out;
+
 		sblk->status &= ~SD_STATUS_UPDATED;
 		if (likely(tg3_has_work(tp)))
 			netif_rx_schedule(dev);		/* schedule NAPI poll */
@@ -3047,10 +3048,13 @@
 			     	0x00000000);
 			tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
 		}
+
+out:
+		tg3_irq_exit(tp);
 	} else {	/* shared interrupt */
 		handled = 0;
 	}
-out:
+
 	return IRQ_RETVAL(handled);
 }
 
@@ -3078,8 +3082,10 @@
 		tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 			     0x00000001);
 		tp->last_tag = sblk->status_tag;
-		if (tg3_irq_sync(tp))
+
+		if (tg3_irq_enter(tp))
 			goto out;
+
 		sblk->status &= ~SD_STATUS_UPDATED;
 		if (likely(tg3_has_work(tp)))
 			netif_rx_schedule(dev);		/* schedule NAPI poll */
@@ -3091,10 +3097,13 @@
 				     tp->last_tag << 24);
 			tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
 		}
+
+out:
+		tg3_irq_exit(tp);
 	} else {	/* shared interrupt */
 		handled = 0;
 	}
-out:
+
 	return IRQ_RETVAL(handled);
 }
 

--5vNYLRcllDrimb99--
