From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [linux-next-20121127 pcnet32] warning at check_unmap()
Date: Wed, 28 Nov 2012 18:31:27 +0300
Message-ID: <CAOJe8K2b45TCVCCDcFb9n+bGWnrZTvfz6Q8RJxgYqw3U7HT-Vg@mail.gmail.com>
References: <201211282325.BHI28612.SHJtOLOMOFFFVQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pcnet32@frontier.com, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:65334 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932476Ab2K1Pb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 10:31:28 -0500
Received: by mail-lb0-f174.google.com with SMTP id gi11so7685983lbb.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 07:31:27 -0800 (PST)
In-Reply-To: <201211282325.BHI28612.SHJtOLOMOFFFVQ@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You have to convert the driver to generic DMA API

On 11/28/12, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
> dma_mapping_error() check seems to be missing at
>
>   static netdev_tx_t pcnet32_start_xmit(struct sk_buff *skb,
>                                         struct net_device *dev)
>   {
> (...snipped...)
>   	lp->tx_skbuff[entry] = skb;
>   	lp->tx_dma_addr[entry] =
>   	    pci_map_single(lp->pci_dev, skb->data, skb->len, PCI_DMA_TODEVICE);
> // this line
>   	lp->tx_ring[entry].base = cpu_to_le32(lp->tx_dma_addr[entry]);
>   	wmb();                  /* Make sure owner changes after all others are
> visible */
>   	lp->tx_ring[entry].status = cpu_to_le16(status);
> (...snipped...)
>   }
>
> but I don't know how to fix.
>
> [   20.908272] NET: Registered protocol family 10
> [   21.627711] pcnet32 0000:02:01.0 eth0: link up
> [   22.573436] ------------[ cut here ]------------
> [   22.574952] WARNING: at lib/dma-debug.c:933 check_unmap+0x4a6/0x920()
> [   22.575669] Hardware name: VMware Virtual Platform
> [   22.575669] pcnet32 0000:02:01.0: DMA-API: device driver failed to check
> map error[device address=0x000000001a3607f2] [size=90 bytes] [mapped as
> single]
> [   22.575669] Modules linked in: ipv6 binfmt_misc
> [   22.575669] Pid: 0, comm: swapper/1 Not tainted 3.7.0-rc7-next-20121127
> #91
> [   22.575669] Call Trace:
> [   22.575669]  [<c103370d>] warn_slowpath_common+0x6d/0xa0
> [   22.575669]  [<c1249b46>] ? check_unmap+0x4a6/0x920
> [   22.575669]  [<c1249b46>] ? check_unmap+0x4a6/0x920
> [   22.575669]  [<c10337be>] warn_slowpath_fmt+0x2e/0x30
> [   22.575669]  [<c1249b46>] check_unmap+0x4a6/0x920
> [   22.575669]  [<c124a1bb>] debug_dma_unmap_page+0x5b/0x80
> [   22.575669]  [<c13199be>] pcnet32_poll+0x45e/0x850
> [   22.575669]  [<c105dc30>] ? __wake_up+0x40/0x50
> [   22.575669]  [<c138dc70>] net_rx_action+0x90/0x140
> [   22.575669]  [<c103b6f8>] __do_softirq+0x98/0x160
> [   22.575669]  [<c103b660>] ? irq_enter+0x60/0x60
> [   22.575669]  <IRQ>  [<c103b52d>] ? irq_exit+0x7d/0x80
> [   22.575669]  [<c1023cb4>] ? smp_apic_timer_interrupt+0x54/0x90
> [   22.575669]  [<c1230fb4>] ? trace_hardirqs_off_thunk+0xc/0x18
> [   22.575669]  [<c144c47e>] ? apic_timer_interrupt+0x32/0x38
> [   22.575669]  [<c100a071>] ? default_idle+0x21/0x40
> [   22.575669]  [<c100a729>] ? cpu_idle+0x69/0xc0
> [   22.575669]  [<c1444e7e>] ? start_secondary+0x1b5/0x1bc
> [   22.575669] ---[ end trace d906affb5c70936d ]---
> [   22.575669] Mapped at:
> [   22.575669]  [<c124a4c8>] debug_dma_map_page+0x68/0x140
> [   22.575669]  [<c131acbb>] pcnet32_start_xmit+0x12b/0x220
> [   22.575669]  [<c138bea6>] dev_hard_start_xmit+0x1d6/0x3d0
> [   22.575669]  [<c13a3bc9>] sch_direct_xmit+0x99/0x240
> [   22.575669]  [<c138e003>] dev_queue_xmit+0x143/0x5f0
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
