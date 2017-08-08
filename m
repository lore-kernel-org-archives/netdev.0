From: David Miller <davem@davemloft.net>
Subject: Re: skb allocation from interrupt handler?
Date: Tue, 08 Aug 2017 16:00:22 -0700 (PDT)
Message-ID: <20170808.160022.550877862496200067.davem@davemloft.net>
References: <598A3890.80705@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: m-karicheri2@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751971AbdHHXAZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 19:00:25 -0400
In-Reply-To: <598A3890.80705@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Murali Karicheri <m-karicheri2@ti.com>
Date: Tue, 8 Aug 2017 18:17:52 -0400

> Is there an skb_alloc function that can be used from interrupt handler? Looks like netdev_alloc_skb()
> can't be used since I see following trace with kernel hack debug options enabled.
> 
> [  652.481713] [<c021007c>] (unwind_backtrace) from [<c020bdcc>] (show_stack+0x10/0x14)
> [  652.481725] [<c020bdcc>] (show_stack) from [<c0517780>] (dump_stack+0x98/0xc4)
> [  652.481736] [<c0517780>] (dump_stack) from [<c0256a70>] (___might_sleep+0x1b8/0x2a4)
> [  652.481746] [<c0256a70>] (___might_sleep) from [<c0939e80>] (rt_spin_lock+0x24/0x5c)
> [  652.481755] [<c0939e80>] (rt_spin_lock) from [<c07d827c>] (__netdev_alloc_skb+0xd0/0x254)
> [  652.481774] [<c07d827c>] (__netdev_alloc_skb) from [<bf23a544>] (emac_rx_hardirq+0x374/0x554 [prueth])
> [  652.481793] [<bf23a544>] (emac_rx_hardirq [prueth]) from [<c02925dc>] (__handle_irq_event_percpu+0x9c/0x128)
> 
> This is running under RT kernel off 4.9.y

Your receive handler should be running from a NAPI poll, which is in
software interrupt.  You should not be doing packet processing in
hardware interrupt context as hardware interrupts should be as short
as possible, and with NAPI polling packet input processing can be
properly distributed amongst several devices, and if the system is
overloaded such processing can be deferred to a kernel thread.

NAPI polling has a large number of other advantages as well, more
streamlined GRO support, automatic support for busypolling... the
list goes on and on and on.

I could show you how to do an SKB allocation in a hardware interrupt,
but instead I'd rather teach you how to fish properly, and encourage
you to convert your driver to NAPI polling instead.

Thanks.
