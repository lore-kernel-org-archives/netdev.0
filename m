From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bugreport: The r8169.c driver is calling netif_receive_skb from
 hardirq and with interrupts off
Date: Mon, 14 Apr 2008 11:31:51 -0700
Message-ID: <20080414113151.7c860830@extreme>
References: <48039BEC.7070008@linux.intel.com>
	<20080414112210.3c7ab1bb@extreme>
	<4803A144.3030300@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:39905 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933944AbYDNSb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 14:31:56 -0400
In-Reply-To: <4803A144.3030300@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Apr 2008 11:24:04 -0700
Arjan van de Ven <arjan@linux.intel.com> wrote:

> Stephen Hemminger wrote:
> > On Mon, 14 Apr 2008 11:01:16 -0700
> > Arjan van de Ven <arjan@linux.intel.com> wrote:
> > 
> >> The r8169.c driver is calling netif_receive_skb from hardirq and with interrupts off,
> >> which seems to be invalid (the comments of netif_receive_skb) certainly say so.
> >>
> >> The calltrace is like this:
> >>
> >> packet_rcv
> >> netif_receive_skb
> >> rtl8168_rx_interrupt
> >> rtl8168_interrupt
> >> handle_IRQ_event
> >> handle_fasteoi_irq
> >> do_IRQ
> >>
> >>
> >> Which triggers a warning in packet_rcv() since that does a local_bh_enable(),
> >> which gives a WARN_ON if irqs are disabled (rightfully so it seems).
> >>
> >> The code looks is in rtl8169_rx_interrupt() line 2832 and looks like
> >>
> >>                          if (rtl8169_rx_vlan_skb(tp, desc, skb) < 0)
> >>                                  rtl8169_rx_skb(skb);
> >>
> >> with
> >> #define rtl8169_rx_skb                  netif_receive_skb
> >> higher up in the file.
> >>
> >> This is the 46th highest ranking warnon/oops report for 2.6.25-rc
> >>
> > 
> > rtl8169_rx_skb is defined as netif_receive_skb only if NAPI is enabled.
> > But the backtrace has CONFIG_R8169_NAPI disabled.
> 
> what makes you think this config option is disabled ?
> (just curious)

The receive path for NAPI would be:
	netif_receive_skb
	rtl8169_rx_interrupt
	rtl8169_napi
  
*** But we are both wrong ***
This is not the mainline r8169 driver but more likely the out of tree 
vendor 8168 driver. There is no rtl8168_rx_interrupt in mainline.



    
