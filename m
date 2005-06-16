From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]: Tigon3 new NAPI locking v2
Date: Thu, 16 Jun 2005 21:59:46 +1000
Message-ID: <20050616115945.GA23064@gondor.apana.org.au>
References: <20050603.122558.88474819.davem@davemloft.net> <20050616113732.GA22367@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Cc: netdev@oss.sgi.com, mchan@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050616113732.GA22367@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jun 16, 2005 at 09:37:32PM +1000, herbert wrote:
> 
> The advantage of this is that we won't have to rely on the interrupt
> to occur after setting SYNC.  The disadvantage is that on certain
> architectures (sparc64 obviously :) we're now doing the relatively
> expensive bit operations on each IRQ.

Actually, why don't we utilise the existing synchronize_irq mechanism?
Here is what we could do.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

--- linux-2.6/drivers/net/tg3.h.orig	2005-06-16 21:52:01.000000000 +1000
+++ linux-2.6/drivers/net/tg3.h	2005-06-16 21:58:02.000000000 +1000
@@ -2008,22 +2008,20 @@
 
 	/* If the IRQ handler (which runs lockless) needs to be
 	 * quiesced, the following bitmask state is used.  The
-	 * SYNC bit is set by non-IRQ context code to initiate
-	 * the quiescence.  The setter of this bit also forces
-	 * an interrupt to run via the GRC misc host control
-	 * register.
-	 *
-	 * The IRQ handler notes this, disables interrupts, and
-	 * sets the COMPLETE bit.  At this point the SYNC bit
-	 * setter can be assured that interrupts will no longer
-	 * get run.
+	 * SYNC flag is set by non-IRQ context code to initiate
+	 * the quiescence.
+	 *
+	 * When the IRQ handler notices that SYNC is set, it
+	 * disables interrupts and returns.
+	 *
+	 * When all outstanding IRQ handlers have returned after
+	 * the SYNC flag has been set, the setter can be assured
+	 * that interrupts will no longer get run.
 	 *
 	 * In this way all SMP driver locks are never acquired
 	 * in hw IRQ context, only sw IRQ context or lower.
 	 */
-	unsigned long			irq_state;
-#define TG3_IRQSTATE_SYNC		0
-#define TG3_IRQSTATE_COMPLETE		1
+	unsigned int			irq_sync;
 
 	/* SMP locking strategy:
 	 *
--- linux-2.6/drivers/net/tg3.c.orig	2005-06-16 21:52:04.000000000 +1000
+++ linux-2.6/drivers/net/tg3.c	2005-06-16 21:58:36.000000000 +1000
@@ -435,7 +435,7 @@
 	tw32_mailbox(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW,
 		     (tp->last_tag << 24));
 	tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
-	tp->irq_state = 0;
+	tp->irq_sync = 0;
 	tg3_cond_int(tp);
 }
 
@@ -2931,32 +2931,18 @@
 	return (done ? 0 : 1);
 }
 
-static void tg3_irq_quiesce(struct tg3 *tp)
+static inline void tg3_irq_quiesce(struct tg3 *tp)
 {
-	BUG_ON(test_bit(TG3_IRQSTATE_SYNC, &tp->irq_state));
+	BUG_ON(tp->irq_sync);
 
-	set_bit(TG3_IRQSTATE_SYNC, &tp->irq_state);
-	smp_mb();
-	tw32(GRC_LOCAL_CTRL,
-	     tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
+	tp->irq_sync = 1;
 
-	while (!test_bit(TG3_IRQSTATE_COMPLETE, &tp->irq_state)) {
-		u32 val = tr32(MAILBOX_INTERRUPT_0 + TG3_64BIT_REG_LOW);
-
-		if (val == 0x00000001)
-			break;
-
-		cpu_relax();
-	}
+	synchronize_irq(tp->pdev->irq);
 }
 
 static inline int tg3_irq_sync(struct tg3 *tp)
 {
-	if (test_bit(TG3_IRQSTATE_SYNC, &tp->irq_state)) {
-		set_bit(TG3_IRQSTATE_COMPLETE, &tp->irq_state);
-		return 1;
-	}
-	return 0;
+	return tp->irq_sync;
 }
 
 /* Fully shutdown all tg3 driver activity elsewhere in the system.

--bp/iNruPH9dso1Pn--
