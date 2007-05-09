From: Andi Kleen <andi@firstfloor.org>
Subject: Re: smp_affinity, MSI-X and 2.6.21.1
Date: Wed, 9 May 2007 13:50:40 +0200
Message-ID: <20070509115040.GC15029@one.firstfloor.org>
References: <463F91D3.3010000@hp.com> <p733b26waha.fsf@bingen.suse.de> <20070509.024614.48396047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, rick.jones2@hp.com, netdev@vger.kernel.org,
	tglx@linutronix.de, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:40721 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756900AbXEILun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 07:50:43 -0400
Content-Disposition: inline
In-Reply-To: <20070509.024614.48396047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> That's true, but we are talking about software state so in some sense
> it might be better that the affinity-to-be is reported to the user in
> this case.
> 
> Delayed register updates are an implementation detail the user does
> not need to know about here.

This patch should fix it.
-Andi

Report the pending irq if available in smp_affinity

Otherwise smp_affinity would only update after the next interrupt
on x86 systems.

Cc: tglx@linutronix.de
Cc: mingo@elte.hu

Signed-off-by: Andi Kleen <ak@suse.de>

Index: linux/kernel/irq/proc.c
===================================================================
--- linux.orig/kernel/irq/proc.c
+++ linux/kernel/irq/proc.c
@@ -19,7 +19,14 @@ static struct proc_dir_entry *root_irq_d
 static int irq_affinity_read_proc(char *page, char **start, off_t off,
 				  int count, int *eof, void *data)
 {
-	int len = cpumask_scnprintf(page, count, irq_desc[(long)data].affinity);
+	struct irq_desc *desc = irq_desc + (long)data;
+	cpumask_t *mask = &desc->affinity;
+	int len;
+#ifdef CONFIG_GENERIC_PENDING_IRQ
+	if (desc->status & IRQ_MOVE_PENDING)
+		mask = &desc->pending_mask;
+#endif
+	len = cpumask_scnprintf(page, count, *mask);
 
 	if (count - len < 2)
 		return -EINVAL;
