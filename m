From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 hangs, hw csum errors with 2.6.18
Date: Fri, 22 Sep 2006 09:56:42 -0700
Message-ID: <20060922095642.5acf4ac9@dxpl.pdx.osdl.net>
References: <20060922112442.GB4161@dezo.moloch.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:57054 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932563AbWIVQ4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 12:56:48 -0400
To: Martin Lucina <mato@kotelna.sk>
In-Reply-To: <20060922112442.GB4161@dezo.moloch.sk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 13:24:43 +0200
Martin Lucina <mato@kotelna.sk> wrote:

> Hello,
> 
> I'm having problems with my sky2 NIC hanging under heavy load.  This
> appears to be an old problem since it happened for me with 2.6.17 as
> well.  Upgrading the affected systems to 2.6.18 has not solved the
> problem.  It's easily reproducible for me since I'm running some
> application stress testing that easily saturates the link.
> 
> I've had a look at the recent traffic on linux-kernel, netdev and the
> relevant bugzilla (http://bugzilla.kernel.org/show_bug.cgi?id=6839) but
> it's not clear to me which patch I should try against a stock 2.6.18
> kernel.  If someone could confirm that the "TX pause fix" attached to
> the bugzilla is sufficient, that would be great.

You can turn off TX pause and get the same effect.

> The card in question is a:
> 
> Sep 22 12:17:27 dezo kernel: sky2 v1.5 addr 0xf3000000 irq 169 Yukon-XL (0xb3) rev 1
> 
> it's a SysKonnect SK-9E21 PCI-E Server Adapter and the driver is using
> PCI-MSI interrupts on my system.
> 
> The chip on the card is a Marvell 88E8061.
> 
> The actual errors leading up to the latest hang are:
> 
> Sep 21 21:47:06 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
> Sep 21 21:47:06 dezo kernel: sky2 eth1: tx timeout
> Sep 21 21:47:06 dezo kernel: sky2 eth1: transmit ring 220 .. 179 report=220 done=220
> Sep 21 21:47:06 dezo kernel: sky2 hardware hung? flushing
> Sep 21 21:59:41 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
> Sep 21 21:59:41 dezo kernel: sky2 eth1: tx timeout
> Sep 21 21:59:41 dezo kernel: sky2 eth1: transmit ring 179 .. 138 report=220 done=220
> Sep 21 21:59:41 dezo kernel: sky2 status report lost?
> Sep 21 22:00:41 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
> Sep 21 22:00:41 dezo kernel: sky2 eth1: tx timeout
> Sep 21 22:00:41 dezo kernel: sky2 eth1: transmit ring 220 .. 179 report=220 done=220
> Sep 21 22:00:41 dezo kernel: sky2 hardware hung? flushing
> Sep 21 22:13:10 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
> Sep 21 22:13:10 dezo kernel: sky2 eth1: tx timeout
> Sep 21 22:13:10 dezo kernel: sky2 eth1: transmit ring 179 .. 138 report=220 done=220
> Sep 21 22:13:10 dezo kernel: sky2 status report lost?
> Sep 21 22:14:20 dezo kernel: NETDEV WATCHDOG: eth1: transmit timed out
> Sep 21 22:14:20 dezo kernel: sky2 eth1: tx timeout
> Sep 21 22:14:20 dezo kernel: sky2 eth1: transmit ring 220 .. 179 report=220 done=220
> Sep 21 22:14:20 dezo kernel: sky2 hardware hung? flushing
> Sep 21 22:15:09 dezo kernel: sky2 eth1: disabling interface
> Sep 21 22:15:09 dezo kernel: sky2 eth1: enabling interface
> Sep 21 22:15:12 dezo kernel: sky2 eth1: Link is up at 1000 Mbps, full duplex, flow control
>  both
> Sep 21 22:15:20 dezo kernel: eth1: no IPv6 routers present
> 
> While the interface does appear to have been reset, it never actually
> started working again and the system was hung until I rebooted it this
> morning.
> 
> I'm also seeing a lot of these under high load:
> 
> Sep 21 21:34:24 dezo kernel: eth1: hw csum failure.
> Sep 21 21:34:24 dezo kernel: 
> Sep 21 21:34:24 dezo kernel: Call Trace:
> Sep 21 21:34:24 dezo kernel:  [dump_stack+16/21] dump_stack+0x10/0x15
> Sep 21 21:34:24 dezo kernel:  [__skb_checksum_complete+85/121] __skb_checksum_complete+0x5
> 5/0x79
> Sep 21 21:34:24 dezo kernel:  [tcp_v4_rcv+218/2405] tcp_v4_rcv+0xda/0x965
> Sep 21 21:34:24 dezo kernel:  [ip_local_deliver+433/635] ip_local_deliver+0x1b1/0x27b
> Sep 21 21:34:24 dezo kernel:  [ip_rcv+1234/1311] ip_rcv+0x4d2/0x51f
> Sep 21 21:34:24 dezo kernel:  [netif_receive_skb+589/621] netif_receive_skb+0x24d/0x26d
> Sep 21 21:34:24 dezo kernel:  [__nosave_end+128712870/2129981440] :sky2:sky2_status_intr+0
> x23b/0x404
> Sep 21 21:34:24 dezo kernel:  [__nosave_end+128714646/2129981440] :sky2:sky2_poll+0x100/0x
> 1a1
> Sep 21 21:34:24 dezo kernel:  [net_rx_action+132/268] net_rx_action+0x84/0x10c
> Sep 21 21:34:24 dezo kernel:  [__do_softirq+107/226] __do_softirq+0x6b/0xe2
> Sep 21 21:34:24 dezo kernel:  [call_softirq+28/40] call_softirq+0x1c/0x28
> Sep 21 21:34:24 dezo kernel:  [do_softirq+45/129] do_softirq+0x2d/0x81
> Sep 21 21:34:24 dezo kernel:  [do_IRQ+112/132] do_IRQ+0x70/0x84
> Sep 21 21:34:24 dezo kernel:  [ret_from_intr+0/11] ret_from_intr+0x0/0xb
> Sep 21 21:34:24 dezo kernel:  [mwait_idle+58/82] mwait_idle+0x3a/0x52
> Sep 21 21:34:24 dezo kernel:  [cpu_idle+105/140] cpu_idle+0x69/0x8c
> Sep 21 21:34:24 dezo kernel:  [start_kernel+483/488] start_kernel+0x1e3/0x1e8
> Sep 21 21:34:24 dezo kernel:  [x86_64_start_kernel+459/474] x86_64_start_kernel+0x1cb/0x1d
> 
> Am happy to help with tracking this down...
> 
> Thanks,
> 
> -mato

Is this a dual port on single port card?
