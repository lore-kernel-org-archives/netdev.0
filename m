From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: WARN due to local_bh_disable called with interrupts disabled
Date: Thu, 19 Nov 2015 11:42:08 +0100
Message-ID: <20151119114208.3b8e67c3@redhat.com>
References: <94ad7f112d565984ffdc4aaafe002803.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54833 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932541AbbKSKmN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2015 05:42:13 -0500
In-Reply-To: <94ad7f112d565984ffdc4aaafe002803.squirrel@www.codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 19 Nov 2015 02:37:54 -0000 subashab@codeaurora.org wrote:

> We are seeing a WARN due to local_bh_disable called with interrupts
> disabled with CONFIG_IRQSOFF_TRACER / CONFIG_PREEMPT_TRACER.

AFAIK this WARN happens due to a being called from hardware interrupt
context.  __local_bh_disable_ip calls:  WARN_ON_ONCE(in_irq());

> Here is the WARN trace
> 
>   1833.210427:   <6> Call trace:
>   1833.212833:   <2> [<ffffffc000088530>] dump_backtrace+0x0/0x270
>   1833.212838:   <2> [<ffffffc0000887b0>] show_stack+0x10/0x1c
>   1833.212853:   <2> [<ffffffc000c6edac>] dump_stack+0x74/0xb8
>   1833.212862:   <2> [<ffffffc0000a0fe4>] warn_slowpath_common+0x88/0xb0
>   1833.212865:   <2> [<ffffffc0000a10d0>] warn_slowpath_null+0x14/0x20
>   1833.212870:   <2> [<ffffffc0000a46dc>] __local_bh_disable_ip+0x4c/0xc8
>   1833.212882:   <2> [<ffffffc000ae2788>] destroy_conntrack+0x90/0x184
>   1833.212888:   <2> [<ffffffc000adcd50>] nf_conntrack_destroy+0x28/0x38
>   1833.212896:   <2> [<ffffffc000a97550>] skb_release_head_state+0xa4/0xe0
>   1833.212900:   <2> [<ffffffc000a977e0>] __kfree_skb+0x10/0xbc
>   1833.212904:   <2> [<ffffffc000a976bc>] kfree_skb+0xb4/0xdc
>   1833.212912:   <2> [<ffffffc000aa4660>] flush_backlog+0x88/0x120
>   1833.212922:   <2> [<ffffffc00010e544>] flush_smp_call_function_queue+0xb4/0x154
>   1833.212926:   <2> [<ffffffc00010efcc>] generic_smp_call_function_single_interrupt+0xc/0x18
>   1833.212932:   <2> [<ffffffc000091050>] handle_IPI+0x120/0x338
>   1833.212937:   <2> [<ffffffc000081580>] gic_handle_irq+0xb8/0xdc

The call gic_handle_irq() sounds like a hardware IRQ func/context.

The flush_backlog() call is due to the device is being unregistered. 


> Here is the callstack which leads to this WARN.
> 
> netdev_run_todo
> on_each_cpu //This disables irq with local_irq_save(flags)
> flush_backlog
> kfree_skb
> ..
> destroy_conntrack //This disables irq's again through local_bh_disable

__local_bh_disable_ip() (when CONFIG_TRACE_IRQFLAGS is enabled) calls:
 raw_local_irq_save(flags);
 raw_local_irq_restore(flags);

Thus, it should be safe, as the save/restore variants are used.

> I noticed that this was introduced by commit ca7433df3a ("netfilter:
> conntrack: seperate expect locking from nf_conntrack_lock ").
> 
> Since interrupts are already disabled when flush_backlog is called, is it
> expected to disable bottom halves in destroy_conntrack?

I'm surprised to see kfree_skb() being called from hardirq context, I
though that was not allowed.

AFAIK this is the reason we have: __dev_kfree_skb_any() which defer
freeing the SKB if (in_irq() || irqs_disabled()).

Code:
 void __dev_kfree_skb_any(struct sk_buff *skb, enum skb_free_reason reason)
 {
	if (in_irq() || irqs_disabled())
		__dev_kfree_skb_irq(skb, reason);
	else
		dev_kfree_skb(skb);
 }


> --
> Employee of Qualcomm Innovation Center, Inc.
> Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux
> Foundation Collaborative Project

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
