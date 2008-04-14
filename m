From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bugreport: The r8169.c driver is calling netif_receive_skb from
 hardirq and with interrupts off
Date: Mon, 14 Apr 2008 11:22:10 -0700
Message-ID: <20080414112210.3c7ab1bb@extreme>
References: <48039BEC.7070008@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39531 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933376AbYDNSWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 14:22:15 -0400
In-Reply-To: <48039BEC.7070008@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Apr 2008 11:01:16 -0700
Arjan van de Ven <arjan@linux.intel.com> wrote:

> The r8169.c driver is calling netif_receive_skb from hardirq and with interrupts off,
> which seems to be invalid (the comments of netif_receive_skb) certainly say so.
> 
> The calltrace is like this:
> 
> packet_rcv
> netif_receive_skb
> rtl8168_rx_interrupt
> rtl8168_interrupt
> handle_IRQ_event
> handle_fasteoi_irq
> do_IRQ
> 
> 
> Which triggers a warning in packet_rcv() since that does a local_bh_enable(),
> which gives a WARN_ON if irqs are disabled (rightfully so it seems).
> 
> The code looks is in rtl8169_rx_interrupt() line 2832 and looks like
> 
>                          if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
>                                  rtl8169_rx_skb(skb);
> 
> with
> #define rtl8169_rx_skb                  netif_receive_skb
> higher up in the file.
> 
> This is the 46th highest ranking warnon/oops report for 2.6.25-rc
> 

rtl8169_rx_skb is defined as netif_receive_skb only if NAPI is enabled.
But the backtrace has CONFIG_R8169_NAPI disabled.

I also concerned that the reset_task calls rx_interrupt with different locking
than normal interrupt. 
