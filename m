From: "Hong H. Pham" <hong.pham@windriver.com>
Subject: Re: [PATCH 0/1] NIU: fix spurious interrupts
Date: Fri, 22 May 2009 12:42:30 -0400
Message-ID: <4A16D5F6.8040000@windriver.com>
References: <4A14285C.1040705@windriver.com>	<20090521.151841.160383267.davem@davemloft.net>	<4A15F466.70708@windriver.com> <20090522.010849.89655675.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020807020700090302010302"
Cc: netdev@vger.kernel.org, matheos.worku@sun.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39472 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757913AbZEVQml (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2009 12:42:41 -0400
In-Reply-To: <20090522.010849.89655675.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020807020700090302010302
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> I wonder if the spurious interrupts trigger exactly at the
> 
> 		nw64(LD_IM0(LDN_RXDMA(rp->rx_channel)), 0);
> 
> in niu_poll_core().
> 
> Can you run one more test?  Supplement the debugging output
> with:
> 
> 	"%pS", get_irq_regs()->tpc
> 
> so we can see where the program counter is at the time of
> the spurious interrupt?

The tpc at the time of the spurious interrupt is niu_poll+0x99c.
Looking this address up, it's at this line in niu_ldg_rearm():

   nw64(LDG_IMGMT(lp->ldg_num), val);

Since the timer is also reprogrammed when the LDG is rearmed,
interrupts should not have been generated immediately after
writing to LDG_IMGMT.

The tpc also showed interrupts happening in net_rx_action.  In
this case the LDG has been rearmed, but the timer prevented
interrupt delivery until after niu_poll is done.

> Meanwhile, even if we go with your patch to fix this, we can't
> use it as-is.  Let me explain.
> 
> Suppose that we get this spurious interrupt right after we unmask the
> interrupt and right before napi_complete().  Your change will make us
> re-mask the interrupts, but without scheduling NAPI.
> 
> So once the napi_complete() happens, if no further interrupts trigger
> in that LDG, we'll never process those interrupt events cleared by
> your new code.  See what I mean?

Understood.

> I don't know how to fix this, it's full of races.  I suppose we could
> recheck if events are pending in the LDG after we do the
> napi_complete() and reschedule NAPI again if so.  But that might be
> expensive (several register reads, just to check something that's not
> going to happen most of the time).

> I'm also wondering why we see this on Niagara-2 and not on PCI-E
> cards.  If the interrupts that go into the NCU unit of Niagara-2 are
> levelled interrupts, and somehow the ARM bit is not implemented
> correctly in the NIU logic when hooked up to NCU instead of PCI-E
> logic, that could explain things.
> 
> I bet that our Linux driver is the only one that bangs on the LDG
> mask registers like this.

I tried the test on a T5440, which has a PCI-E NIU (4 x 1GB) card.
I could not reproduce the spurious interrupts.  So this bug seems
to be limited to XAUI NIU cards.  Which also makes it a Niagara-2
specific problem.

Regards,
Hong

[ 2226.589782] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: spurious interrupt
[ 2226.589800]   tpc      = <niu_poll+0x99c/0xc20>
[ 2226.589814]   LD_IM0   = 0x0000000000000003 [ldf_mask=0x03]
[ 2226.589826]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2226.589855] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: spurious interrupt
[ 2226.589867]   tpc      = <niu_poll+0x99c/0xc20>
[ 2226.589878]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2226.589890]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2226.589915] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: spurious interrupt
[ 2226.589927]   tpc      = <niu_poll+0x99c/0xc20>
[ 2226.589938]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2226.589950]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2226.589974] NIU: eth4 CPU=5 LDG=41 rx_vec=0x2000: spurious interrupt
[ 2226.589986]   tpc      = <niu_poll+0x99c/0xc20>
[ 2226.589996]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2226.590008]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2229.380931] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: spurious interrupt
[ 2229.380949]   tpc      = <niu_poll+0x99c/0xc20>
[ 2229.380962]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2229.380974]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2229.381003] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: spurious interrupt
[ 2229.381015]   tpc      = <niu_poll+0x99c/0xc20>
[ 2229.381026]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2229.381038]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2229.381063] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: spurious interrupt
[ 2229.381075]   tpc      = <niu_poll+0x99c/0xc20>
[ 2229.381086]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2229.381097]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2229.381122] NIU: eth4 CPU=58 LDG=40 rx_vec=0x1000: spurious interrupt
[ 2229.381134]   tpc      = <niu_poll+0x99c/0xc20>
[ 2229.381145]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2229.381156]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2236.743967] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: spurious interrupt
[ 2236.743983]   tpc      = <net_rx_action+0x138/0x260>
[ 2236.743996]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2236.744008]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2236.744034] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: spurious interrupt
[ 2236.744046]   tpc      = <net_rx_action+0x138/0x260>
[ 2236.744058]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2236.744070]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2236.744095] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: spurious interrupt
[ 2236.744107]   tpc      = <net_rx_action+0x138/0x260>
[ 2236.744118]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2236.744130]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]
[ 2236.744155] NIU: eth4 CPU=21 LDG=43 rx_vec=0x8000: spurious interrupt
[ 2236.744167]   tpc      = <net_rx_action+0x138/0x260>
[ 2236.744178]   LD_IM0   = 0x0000000000000000 [ldf_mask=0x00]
[ 2236.744190]   LDG_IMGMT= 0x0000000000000000 [arm=0x00 timer=0x00]


--------------020807020700090302010302
Content-Type: text/plain;
 name="niu-instrument-ldg-interrupt.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="niu-instrument-ldg-interrupt.patch"

---
 drivers/net/niu.c |   52 +++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2b17453..cd47fad 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -24,8 +24,11 @@
 #include <linux/crc32.h>
 
 #include <linux/io.h>
 
+#include <linux/kallsyms.h>
+#include <asm/irq_regs.h>
+
 #ifdef CONFIG_SPARC64
 #include <linux/of_device.h>
 #endif
 
@@ -4214,8 +4217,54 @@ static void __niu_fastpath_interrupt(struct niu *np, int ldg, u64 v0)
 			niu_txchan_intr(np, rp, ldn);
 	}
 }
 
+// HHP
+static void niu_dump_ldg_irq(struct niu *np, int ldg, u64 v0)
+{
+	static DEFINE_PER_CPU(unsigned long, spurious_count) = { 4 };
+
+	struct niu_parent *parent = np->parent;
+	char buf[KSYM_SYMBOL_LEN];
+	u64 ld_im0_val, ldg_imgmt_val;
+	u32 rx_vec, tx_vec;
+	int ldn, i;
+
+	if (!__get_cpu_var(spurious_count))
+		return;
+
+	__get_cpu_var(spurious_count)--;
+
+	tx_vec = (v0 >> 32);
+	rx_vec = (v0 & 0xffffffff);
+	sprint_symbol(buf, get_irq_regs()->tpc);
+
+	printk(KERN_DEBUG "NIU: %s CPU=%i LDG=%i rx_vec=0x%04x: spurious interrupt\n",
+	       np->dev->name, smp_processor_id(), ldg, rx_vec);
+	printk(KERN_DEBUG "  tpc      = <%s>\n", buf);
+
+	for (i = 0; i < np->num_rx_rings; i++) {
+		struct rx_ring_info *rp = &np->rx_rings[i];
+
+		ldn = LDN_RXDMA(rp->rx_channel);
+		if (parent->ldg_map[ldn] != ldg)
+			continue;
+
+		ld_im0_val    = nr64(LD_IM0(ldn));
+		ldg_imgmt_val = nr64(LDG_IMGMT(ldn));
+		printk(KERN_DEBUG "  LD_IM0   = 0x%016lx [ldf_mask=0x%02lx]\n",
+		       (unsigned long)ld_im0_val,
+		       (unsigned long)(ld_im0_val & LD_IM0_MASK)),
+		printk(KERN_DEBUG "  LDG_IMGMT= 0x%016lx [arm=0x%02lx timer=0x%02lx]\n",
+		       (unsigned long)ldg_imgmt_val,
+		       (unsigned long)((ldg_imgmt_val & LDG_IMGMT_ARM) >> 31),
+		       (unsigned long)(ldg_imgmt_val & LDG_IMGMT_TIMER));
+	}
+
+	if (tx_vec)
+		printk(KERN_DEBUG "NIU: spurious TX interrupt. WTF?\n");
+}
+
 static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
 			      u64 v0, u64 v1, u64 v2)
 {
 	if (likely(napi_schedule_prep(&lp->napi))) {
@@ -4223,9 +4272,10 @@ static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
 		lp->v1 = v1;
 		lp->v2 = v2;
 		__niu_fastpath_interrupt(np, lp->ldg_num, v0);
 		__napi_schedule(&lp->napi);
-	}
+	} else
+		niu_dump_ldg_irq(np, lp->ldg_num, v0);
 }
 
 static irqreturn_t niu_interrupt(int irq, void *dev_id)
 {

--------------020807020700090302010302--
