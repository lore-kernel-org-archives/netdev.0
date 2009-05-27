From: "Hong H. Pham" <hong.pham@windriver.com>
Subject: Re: [PATCH 0/1] NIU: fix spurious interrupts
Date: Wed, 27 May 2009 12:29:38 -0400
Message-ID: <4A1D6A72.5070801@windriver.com>
References: <4A15F466.70708@windriver.com>	<20090522.010849.89655675.davem@davemloft.net>	<4A16D5F6.8040000@windriver.com> <20090525.231622.222754412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040606030405080409050107"
Cc: netdev@vger.kernel.org, matheos.worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64850 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752901AbZE0QaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 May 2009 12:30:16 -0400
In-Reply-To: <20090525.231622.222754412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040606030405080409050107
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> I wonder if it's the niu_interrupt path, and all the v0 bits are
> clear.  Yeah, I bet that's it.  We're taking some slowpath interrupt
> for RX or TX counter overflows or errors, and then we try to rearm the
> LDG even though we're already handling normal RX/TX via NAPI.
> 
> But that shouldn't happen, the thing that went into RX/TX NAPI work
> should have turned those interrupt off.  We handle RX normal work and
> error interrupts in the same LDG, and similar for TX, and thus using
> the same interrupt.
> 
> Can you check to see who calls niu_ldg_rearm() when we see it trigger
> the interrupt with NAPI already scheduled?  That will help narrow this
> down even further.  Probably the best thing to do is to get a full
> stack trace using show_stack() or dump_stack().
> 
> This is looking more and more like a driver bug at this point.

I've added a check for v0 being zero in niu_interrupt().  I have not seen
this check succeed, so niu_ldg_rearm() is never invoked prior to or
during a spurious interrupt in niu_interrupt().  So it seems the only
other place where the LDG is rearmed during network activity is in
niu_poll(), which is expected.

Here's something else that doesn't make sense.  I've added a check
in __niu_fastpath_interrupt() and niu_rx_work() to see if the RCR qlen
is zero, i.e. we're scheduling NAPI with no work.  This could happen if
there's a spurious interrupt, but the interrupt is not a run away that
would hang the CPU.  This check happens quite frequently, much more than
the spurious interrupt check.  Also, it happens with both the PCI-E and
XAUI cards (I could not reproduce run away spurious interrupts with a
PCI-E card).

This is a log from a test with 1 TCP stream.  If there's no work to do,
one would expect to see for each __niu_fastpath_interrupt(), there is only
one corresponding niu_rx_work().  i.e. work_done in niu_poll is 0, so NAPI
is done and should not have been rescheduled.  The check for spurious
interrupts in niu_schedule_napi() is not reached.

[  474.387984] niu: __niu_fastpath_interrupt() CPU=58 rx_channel=12 qlen is 0!
[  474.388009] niu: niu_rx_work() CPU=58 rx_channel=12 qlen is zero!
[  474.663008] niu: __niu_fastpath_interrupt() CPU=58 rx_channel=12 qlen is 0!
[  474.663034] niu: niu_rx_work() CPU=58 rx_channel=12 qlen is zero!
[  474.805663] niu: niu_rx_work() CPU=58 rx_channel=12 qlen is zero!
[  475.657501] niu: niu_rx_work() CPU=58 rx_channel=12 qlen is zero!
[  476.139072] niu: niu_rx_work() CPU=58 rx_channel=12 qlen is zero!
[  476.264352] niu: niu_rx_work() CPU=58 rx_channel=12 qlen is zero!
[  476.474596] niu: niu_rx_work() CPU=58 rx_channel=12 qlen is zero!
[  476.698176] niu: __niu_fastpath_interrupt() CPU=58 rx_channel=12 qlen is 0!
[  476.698201] niu: niu_rx_work() CPU=58 rx_channel=12 qlen is zero!

Here's another log excerpt with 1 TCP stream.  In this case NAPI is being
rescheduled multiple times with no work to do.  Again, run away spurious
interrupts did not happen.

[ 1098.870170] niu: niu_rx_work() CPU=50 rx_channel=11 qlen is zero!
[ 1098.879759] niu: __niu_fastpath_interrupt() CPU=50 rx_channel=11 qlen is 0!
[ 1098.904478] niu: __niu_fastpath_interrupt() CPU=50 rx_channel=11 qlen is 0!
[ 1098.908674] niu: __niu_fastpath_interrupt() CPU=50 rx_channel=11 qlen is 0!
[ 1098.908703] niu: niu_rx_work() CPU=50 rx_channel=11 qlen is zero!

In any case, interrupts with qlen being 0 always happen before we see the
run away spurious interrupts (but that could be due to the latter happening
a lot less frequently).

Regards,
Hong





--------------040606030405080409050107
Content-Type: text/plain;
 name="niu-debug-spurious-interrupts.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="niu-debug-spurious-interrupts.patch"

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2b17453..125450a 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3724,6 +3724,10 @@ static int niu_rx_work(struct napi_struct *napi, struct niu *np,
 	mbox->rx_dma_ctl_stat = 0;
 	mbox->rcrstat_a = 0;
 
+	if (!qlen)
+		printk(KERN_DEBUG PFX "%s() CPU=%i rx_channel=%i qlen is zero!\n",
+		       __FUNCTION__, raw_smp_processor_id(), rp->rx_channel);
+
 	niudbg(RX_STATUS, "%s: niu_rx_work(chan[%d]), stat[%llx] qlen=%d\n",
 	       np->dev->name, rp->rx_channel, (unsigned long long) stat, qlen);
 
@@ -4193,10 +4197,17 @@ static void __niu_fastpath_interrupt(struct niu *np, int ldg, u64 v0)
 	for (i = 0; i < np->num_rx_rings; i++) {
 		struct rx_ring_info *rp = &np->rx_rings[i];
 		int ldn = LDN_RXDMA(rp->rx_channel);
+		u64 qlen;
 
 		if (parent->ldg_map[ldn] != ldg)
 			continue;
 
+		qlen = nr64(RCRSTAT_A(rp->rx_channel)) & RCRSTAT_A_QLEN;
+		if (!qlen) {
+			printk(KERN_DEBUG PFX "%s() CPU=%i rx_channel=%i qlen is 0!\n",
+			       __FUNCTION__, smp_processor_id(), rp->rx_channel);
+		}
+
 		nw64(LD_IM0(ldn), LD_IM0_MASK);
 		if (rx_vec & (1 << rp->rx_channel))
 			niu_rxchan_intr(np, rp, ldn);
@@ -4215,6 +4226,22 @@ static void __niu_fastpath_interrupt(struct niu *np, int ldg, u64 v0)
 	}
 }
 
+static void niu_dump_ldg_irq(struct niu *np, int ldg, u64 v0)
+{
+	static DEFINE_PER_CPU(unsigned long, spurious_count) = { 4 };
+
+	struct niu_parent *parent = np->parent;
+	int qlen, ldn, i;
+
+	if (!__get_cpu_var(spurious_count))
+		return;
+
+	__get_cpu_var(spurious_count)--;
+
+	printk(KERN_DEBUG PFX "%s CPU=%i LDG=%i v0=%p: spurious interrupt\n",
+	       np->dev->name, smp_processor_id(), ldg, (void *)v0);
+}
+
 static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
 			      u64 v0, u64 v1, u64 v2)
 {
@@ -4224,7 +4251,8 @@ static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
 		lp->v2 = v2;
 		__niu_fastpath_interrupt(np, lp->ldg_num, v0);
 		__napi_schedule(&lp->napi);
-	}
+	} else
+		niu_dump_ldg_irq(np, lp->ldg_num, v0);
 }
 
 static irqreturn_t niu_interrupt(int irq, void *dev_id)
@@ -4251,6 +4279,10 @@ static irqreturn_t niu_interrupt(int irq, void *dev_id)
 		       (unsigned long long) v1,
 		       (unsigned long long) v2);
 
+	if (!v0)
+		printk(KERN_DEBUG PFX "%s() CPU=%i LDG=%i v0 is zero!\n",
+		       __FUNCTION__, smp_processor_id(), ldg);
+
 	if (unlikely(!v0 && !v1 && !v2)) {
 		spin_unlock_irqrestore(&np->lock, flags);
 		return IRQ_NONE;
@@ -4263,8 +4295,11 @@ static irqreturn_t niu_interrupt(int irq, void *dev_id)
 	}
 	if (likely(v0 & ~((u64)1 << LDN_MIF)))
 		niu_schedule_napi(np, lp, v0, v1, v2);
-	else
+	else {
+		printk(KERN_DEBUG PFX "%s() CPU=%i no DMA work, rearming LDG\n",
+		       __FUNCTION__, smp_processor_id());
 		niu_ldg_rearm(np, lp, 1);
+	}
 out:
 	spin_unlock_irqrestore(&np->lock, flags);
 

--------------040606030405080409050107--
