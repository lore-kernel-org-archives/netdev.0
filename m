From: Tina Yang <tina.yang@oracle.com>
Subject: Re: netconsole problems
Date: Thu, 04 Oct 2007 18:22:06 -0700
Message-ID: <470591BE.9020704@oracle.com>
References: <47052A0A.2080100@oracle.com> <20071005002754.GH19691@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:58061 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756464AbXJEBZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 21:25:22 -0400
In-Reply-To: <20071005002754.GH19691@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Mackall wrote:
> On Thu, Oct 04, 2007 at 10:59:38AM -0700, Tina Yang wrote:
>   
>> We recently run into a few problems with netconsole
>> in at least 2.6.9, 2.6.18 and 2.6.23.  It either panicked
>> at netdevice.h:890 or hung the system, and sometimes depending
>> on which NIC we are using, the following console message,
>> e1000:
>>      "e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang"
>> tg3:
>>      "NETDEV WATCHDOG: eth4: transmit timed out"
>>      "tg3: eth4: transmit timed out, resetting"
>>
>> The postmortem vmcore analysis indicated race between normal
>> network stack (net_rx_action) and netpoll, and disabling the
>> following code segment cures all the problems.
>>     
>
> That doesn't tell us much. Can you provide any more details? Like the
> call chains on both sides?
>   
       I've filed a bug with details, 
http://bugzilla.kernel.org/show_bug.cgi?id=9124
       Basically for 2.6.9, tg3_poll from net_rx_action had panicked 
because
        __LINK_STATE_RX_SCHED is not set, and the net_device from the vmcore
       showed the device is not on any of the per_cpu poll_list at the time.
       For 2.6.18, same crash, however, the net_device showed the dev is 
on one
       poll_list.  The discrepancy between the two crashes can be 
explained as follows,
       1) netpoll on cpu0 called dev->poll(), removed the dev from the 
list and enabled the interrupt
       2) net_rx_action on cpu1 called dev->poll() again, panicked on 
removing the dev from the list
       3) interrupt delivered to, say cpu2, and scheduled the device again

       Because of the race, it could result in a condition where you 
could have more than
       one cpu deal with interrupt (hw or soft) from the same device at 
the same time ?
     
>  
>   
>> netpoll.c
>>    178         /* Process pending work on NIC */
>>    179         np->dev->poll_controller(np->dev);
>>    180         if (np->dev->poll)
>>    181                 poll_napi(np);
>>     
>
> There are a couple different places this gets called, and for
> different reasons. If we have a -large- netconsole dump (like
> sysrq-t), we'll swallow up all of our SKB pool and may get stuck waiting
> for the NIC to send them (because it's waiting to hand packets back to
> the kernel and has no free buffers for outgoing packets).
>
>   
       But the softirq will process and free them ?  The problem is the 
poll_list
       is in a per_cpu structure, shouldn't be manipulated by another 
cpu where
       netpoll is running.
>> Big or small, there seems to be several race windows in the code,
>> and fixing them probably has consequence on overall system performance.
>>     
>
> Yes, the networking layer goes to great lengths to avoid having any
> locking in its fast paths and we don't want to undo any of that
> effort.
>
>   
>> Maybe this code should only run when the machine is single-threaded ?
>>     
>
> In the not-very-distant future, such machines will be extremely rare.
>
>   
       I meant the special case such as in crash mode.

