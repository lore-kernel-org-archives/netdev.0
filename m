From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: bugreport: The r8169.c driver is calling netif_receive_skb from
 hardirq and with interrupts off
Date: Mon, 14 Apr 2008 11:24:04 -0700
Message-ID: <4803A144.3030300@linux.intel.com>
References: <48039BEC.7070008@linux.intel.com> <20080414112210.3c7ab1bb@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:19426 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933796AbYDNSYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 14:24:12 -0400
In-Reply-To: <20080414112210.3c7ab1bb@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 14 Apr 2008 11:01:16 -0700
> Arjan van de Ven <arjan@linux.intel.com> wrote:
> 
>> The r8169.c driver is calling netif_receive_skb from hardirq and with interrupts off,
>> which seems to be invalid (the comments of netif_receive_skb) certainly say so.
>>
>> The calltrace is like this:
>>
>> packet_rcv
>> netif_receive_skb
>> rtl8168_rx_interrupt
>> rtl8168_interrupt
>> handle_IRQ_event
>> handle_fasteoi_irq
>> do_IRQ
>>
>>
>> Which triggers a warning in packet_rcv() since that does a local_bh_enable(),
>> which gives a WARN_ON if irqs are disabled (rightfully so it seems).
>>
>> The code looks is in rtl8169_rx_interrupt() line 2832 and looks like
>>
>>                          if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
>>                                  rtl8169_rx_skb(skb);
>>
>> with
>> #define rtl8169_rx_skb                  netif_receive_skb
>> higher up in the file.
>>
>> This is the 46th highest ranking warnon/oops report for 2.6.25-rc
>>
> 
> rtl8169_rx_skb is defined as netif_receive_skb only if NAPI is enabled.
> But the backtrace has CONFIG_R8169_NAPI disabled.

what makes you think this config option is disabled ?
(just curious)

> I also concerned that the reset_task calls rx_interrupt with different locking
> than normal interrupt. 

