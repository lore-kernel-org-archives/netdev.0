From: Rick Jones <rick.jones2@hp.com>
Subject: Re: smp_affinity, MSI-X and 2.6.21.1
Date: Tue, 15 May 2007 15:52:49 -0700
Message-ID: <464A39C1.5000807@hp.com>
References: <463F91D3.3010000@hp.com> <p733b26waha.fsf@bingen.suse.de>	<20070509.024614.48396047.davem@davemloft.net> <20070509115040.GC15029@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	tglx@linutronix.de, mingo@elte.hu
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:56646 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756748AbXEOWwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 May 2007 18:52:55 -0400
In-Reply-To: <20070509115040.GC15029@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
>>That's true, but we are talking about software state so in some sense
>>it might be better that the affinity-to-be is reported to the user in
>>this case.
>>
>>Delayed register updates are an implementation detail the user does
>>not need to know about here.
> 
> 
> This patch should fix it.

And it seems to when I apply it against the 2.6.21.1 kernel I'm messing about with:

hpcpc106:~/s2io-2.0.19-8893# cat /proc/irq/69/smp_affinity
ffffffff,ffffffff
hpcpc106:~/s2io-2.0.19-8893# echo "4" >> /proc/irq/69/smp_affinity
hpcpc106:~/s2io-2.0.19-8893# cat /proc/irq/69/smp_affinity
00000000,00000004
hpcpc106:~/s2io-2.0.19-8893# cat /proc/interrupts | grep 69
  69:          0          0          0          0         PCI-MSI  eth2:MSI-X-6-RX

It would be nice if this could find its way into the kernel at some point - 
2.6.23 or 2.6.24 perhaps?

rick jones

> -Andi
> 
> Report the pending irq if available in smp_affinity
> 
> Otherwise smp_affinity would only update after the next interrupt
> on x86 systems.
> 
> Cc: tglx@linutronix.de
> Cc: mingo@elte.hu
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> Index: linux/kernel/irq/proc.c
> ===================================================================
> --- linux.orig/kernel/irq/proc.c
> +++ linux/kernel/irq/proc.c
> @@ -19,7 +19,14 @@ static struct proc_dir_entry *root_irq_d
>  static int irq_affinity_read_proc(char *page, char **start, off_t off,
>  				  int count, int *eof, void *data)
>  {
> -	int len = cpumask_scnprintf(page, count, irq_desc[(long)data].affinity);
> +	struct irq_desc *desc = irq_desc + (long)data;
> +	cpumask_t *mask = &desc->affinity;
> +	int len;
> +#ifdef CONFIG_GENERIC_PENDING_IRQ
> +	if (desc->status & IRQ_MOVE_PENDING)
> +		mask = &desc->pending_mask;
> +#endif
> +	len = cpumask_scnprintf(page, count, *mask);
>  
>  	if (count - len < 2)
>  		return -EINVAL;

