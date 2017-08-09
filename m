From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: skb allocation from interrupt handler?
Date: Wed, 9 Aug 2017 12:36:36 -0400
Message-ID: <598B3A14.5020507@ti.com>
References: <598A3890.80705@ti.com>
 <20170808.160022.550877862496200067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:10877 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752069AbdHIQqE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 12:46:04 -0400
In-Reply-To: <20170808.160022.550877862496200067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 08/08/2017 07:00 PM, David Miller wrote:
> From: Murali Karicheri <m-karicheri2@ti.com>
> Date: Tue, 8 Aug 2017 18:17:52 -0400
> 
>> Is there an skb_alloc function that can be used from interrupt handler? Looks like netdev_alloc_skb()
>> can't be used since I see following trace with kernel hack debug options enabled.
>>
>> [  652.481713] [<c021007c>] (unwind_backtrace) from [<c020bdcc>] (show_stack+0x10/0x14)
>> [  652.481725] [<c020bdcc>] (show_stack) from [<c0517780>] (dump_stack+0x98/0xc4)
>> [  652.481736] [<c0517780>] (dump_stack) from [<c0256a70>] (___might_sleep+0x1b8/0x2a4)
>> [  652.481746] [<c0256a70>] (___might_sleep) from [<c0939e80>] (rt_spin_lock+0x24/0x5c)
>> [  652.481755] [<c0939e80>] (rt_spin_lock) from [<c07d827c>] (__netdev_alloc_skb+0xd0/0x254)
>> [  652.481774] [<c07d827c>] (__netdev_alloc_skb) from [<bf23a544>] (emac_rx_hardirq+0x374/0x554 [prueth])
>> [  652.481793] [<bf23a544>] (emac_rx_hardirq [prueth]) from [<c02925dc>] (__handle_irq_event_percpu+0x9c/0x128)
>>
>> This is running under RT kernel off 4.9.y
> 
> Your receive handler should be running from a NAPI poll, which is in
> software interrupt.  You should not be doing packet processing in
> hardware interrupt context as hardware interrupts should be as short
> as possible, and with NAPI polling packet input processing can be
> properly distributed amongst several devices, and if the system is
> overloaded such processing can be deferred to a kernel thread.
> 

Thanks for responding! I appreciate your feedback.

Our NetCP and CPSW device drivers do use NAPI poll to process receive packets. 
However these hardwares have capability to use ring buffers or descriptors setup
in DDR to enqueue the received packets to the CPU. However the specific hardware
(in fact a firmware running in the ICSS PRU that is available on our industrial
IDK SoCs) have limited internal memory that is shared between the ARM and PRU to
enqueue the received packets to the CPU for processing. This is using a 100Mbps
Ethernet link. As per NAPI documentation, at 

https://wiki.linuxfoundation.org/networking/napi 

two of the conditions mentioned there for using NAPI are

====== Quote from the above link ================================================

    DMA ring or enough RAM to store packets in software devices.
    Ability to turn off interrupts or maybe events that send packets up the stack.
==================================================================================

The internal memory or FIFO can store only up to 3 MTU sized packets. So that has to
be processed before PRU gets another packets to send to CPU. So per above, 
it is not ideal to run NAPI for this scenario, right? Also for NetCP we use
about 128 descriptors with MTU size buffers to handle 1Gbps Ethernet link.
Based on that roughly we would need at least 10-12 buffers in the FIFO.

Currently we have a NAPI implementation in use that gives throughput of 95Mbps for
MTU sized packets, but our UDP iperf tests shows less than 1% packet loss for an
offered traffic of 95Mbps with MTU sized packets.  This is not good for industrial
network using HSR/PRP protocol for network redundancy. We need to have zero packet
loss for MTU sized packets at 95Mbps throughput. That is the problem description.

As an experiment, I have moved the packet processing to irq handler to see if we 
can take advantage of CPU cycle to processing the packet instead of NAPI
and to check if the firmware encounters buffer overflow. The result is positive 
with no buffer overflow seen at the firmware and no packet loss in the iperf test.
But we want to do more testing as an experiment and ran into a uart console locks
up after running traffic for about 2 minutes. So I tried enabling the DEBUG HACK 
options to get some clue on what is happening and ran into the trace I shared 
earlier. So what function can I use to allocate SKB from interrupt handler?

Also wondering what is the best way to implement the packet processing in this
case to avoid the packet loss. 

> NAPI polling has a large number of other advantages as well, more
> streamlined GRO support, automatic support for busypolling... the
> list goes on and on and on.
> 
> I could show you how to do an SKB allocation in a hardware interrupt,
> but instead I'd rather teach you how to fish properly, and encourage
> you to convert your driver to NAPI polling instead.
> 

Would love to use NAPI if we can overcome the packet loss in some way.


Thanks and regards,

Murali
> Thanks.
> 


-- 
Murali Karicheri
Linux Kernel, Keystone
